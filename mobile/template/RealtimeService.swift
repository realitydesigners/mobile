//
//  RealtimeService.swift
//  mobile
//
//  Service for fetching real-time box data from backend
//

import Foundation
import Combine

class RealtimeService: ObservableObject {
    static let shared = RealtimeService()
    
    @Published var priceData: [String: PriceData] = [:]
    @Published var isConnected = false
    
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = "https://boxes.rthmn.com"
    private var timer: Timer?
    
    private init() {
        startPolling()
    }
    
    // MARK: - Price Updates
    
    func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task {
                await self?.fetchLatestPrices()
            }
        }
        isConnected = true
    }
    
    func stopPolling() {
        timer?.invalidate()
        timer = nil
        isConnected = false
    }
    
    private func fetchLatestPrices() async {
        guard let url = URL(string: "\(baseURL)/api/liveprice/latest") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let prices = try JSONDecoder().decode([String: PriceResponse].self, from: data)
            
            await MainActor.run {
                var updated: [String: PriceData] = [:]
                for (pair, priceResponse) in prices {
                    updated[pair.uppercased()] = PriceData(
                        price: priceResponse.price,
                        timestamp: priceResponse.timestamp,
                        volume: 0
                    )
                }
                self.priceData = updated
            }
        } catch {
            print("Error fetching prices: \(error)")
        }
    }
    
    // MARK: - Box Slices
    
    func fetchBoxSlices(for pairs: [String]) async -> [String: BoxSlice] {
        guard !pairs.isEmpty else { return [:] }
        
        let pairsString = pairs.map { $0.uppercased() }.joined(separator: ",")
        guard let url = URL(string: "\(baseURL)/api/boxes/latest?pairs=\(pairsString)") else {
            return [:]
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode([String: BoxSliceResponse?].self, from: data)
            
            var result: [String: BoxSlice] = [:]
            for (pair, boxResponse) in response {
                guard let boxResponse = boxResponse else { continue }
                let boxes = boxResponse.boxes.map { Box(high: $0.high, low: $0.low, value: $0.value) }
                result[pair.uppercased()] = BoxSlice(
                    timestamp: boxResponse.timestamp,
                    boxes: boxes
                )
            }
            return result
        } catch {
            print("Error fetching box slices: \(error)")
            return [:]
        }
    }
    
    func subscribeToBoxSlices(pairs: [String], onUpdate: @escaping ([String: BoxSlice]) -> Void) {
        Task {
            let slices = await fetchBoxSlices(for: pairs)
            await MainActor.run {
                onUpdate(slices)
            }
        }
        
        _ = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            Task {
                let slices = await self?.fetchBoxSlices(for: pairs) ?? [:]
                await MainActor.run {
                    onUpdate(slices)
                }
            }
        }
    }
}

// MARK: - Response Models

private struct PriceResponse: Codable {
    let price: Double
    let timestamp: String
}

private struct BoxSliceResponse: Codable {
    let timestamp: String
    let boxes: [BoxData]
}

private struct BoxData: Codable {
    let high: Double
    let low: Double
    let value: Double
}

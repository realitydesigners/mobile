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
    private let convexURL = AppConfig.convexURL
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
        // Call Convex query: liveprice.getLatestPrices
        guard let url = URL(string: "\(convexURL)/api/query") else { return }
        
        // Get all pairs we want prices for - use a reasonable subset for now
        let allPairs = ["BTCUSD", "ETHUSD", "SOLUSD", "XRPUSD", "ADAUSD", "DOGEUSD", "EURUSD", "GBPUSD", "USDJPY", "XAUUSD"]
        
        let args: [String: Any] = ["pairs": allPairs]
        let requestBody: [String: Any] = [
            "path": "liveprice:getLatestPrices",
            "args": args,
            "format": "json"
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard httpResponse.statusCode == 200 else {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Convex price query error (status \(httpResponse.statusCode)): \(responseString.prefix(200))")
                    }
                    return
                }
            }
            
            // Debug: print response to see what Convex returns
            if let responseString = String(data: data, encoding: .utf8) {
                print("Convex price response: \(responseString.prefix(500))")
            }
            
            // Convex returns: { "value": { "BTCUSD": { "price": ..., "timestamp": ... }, ... } }
            let convexResponse = try JSONDecoder().decode(ConvexQueryResponse<[String: PriceResponse]>.self, from: data)
            
            await MainActor.run {
                var updated: [String: PriceData] = [:]
                for (pair, priceResponse) in convexResponse.value {
                    updated[pair.uppercased()] = PriceData(
                        price: priceResponse.price,
                        timestamp: priceResponse.timestamp,
                        volume: 0
                    )
                }
                self.priceData = updated
            }
        } catch {
            if let responseString = String(data: (try? await URLSession.shared.data(for: request).0) ?? Data(), encoding: .utf8) {
                print("Error fetching prices from Convex: \(error)")
                print("Response was: \(responseString.prefix(500))")
            } else {
                print("Error fetching prices from Convex: \(error)")
            }
        }
    }
    
    // MARK: - Box Slices
    
    func fetchBoxSlices(for pairs: [String]) async -> [String: BoxSlice] {
        guard !pairs.isEmpty else { return [:] }
        
        // Call Convex query: boxes.getLatestBoxes
        guard let url = URL(string: "\(convexURL)/api/query") else { return [:] }
        
        let args: [String: Any] = ["pairs": pairs.map { $0.uppercased() }]
        let requestBody: [String: Any] = [
            "path": "boxes:getLatestBoxes",
            "args": args,
            "format": "json"
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return [:] }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard httpResponse.statusCode == 200 else {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Convex boxes query error (status \(httpResponse.statusCode)): \(responseString.prefix(200))")
                    }
                    return [:]
                }
            }
            
            // Debug: print response to see what Convex returns
            if let responseString = String(data: data, encoding: .utf8) {
                print("Convex boxes response: \(responseString.prefix(500))")
            }
            
            // Convex returns: { "value": { "BTCUSD": { "timestamp": ..., "boxes": [...] }, ... } }
            let convexResponse = try JSONDecoder().decode(ConvexQueryResponse<[String: BoxSliceResponse?]>.self, from: data)
            
            var result: [String: BoxSlice] = [:]
            for (pair, boxResponse) in convexResponse.value {
                guard let boxResponse = boxResponse else { continue }
                let boxes = boxResponse.boxes.map { Box(high: $0.high, low: $0.low, value: $0.value) }
                result[pair.uppercased()] = BoxSlice(
                    timestamp: boxResponse.timestamp,
                    boxes: boxes
                )
            }
            return result
        } catch {
            print("Error fetching box slices from Convex: \(error)")
            if let responseString = String(data: (try? await URLSession.shared.data(for: request).0) ?? Data(), encoding: .utf8) {
                print("Response was: \(responseString.prefix(500))")
            }
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

private struct ConvexQueryResponse<T: Codable>: Codable {
    let value: T
}

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

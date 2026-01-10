//
//  DashboardProvider.swift
//  mobile
//
//  ObservableObject for managing dashboard pair data
//

import Foundation
import Combine
import SwiftUI

class DashboardProvider: ObservableObject {
    static let shared = DashboardProvider()
    
    @Published var pairData: [String: PairData] = [:]
    @Published var isLoading = false
    @Published var isConnected = false
    @Published var isReady = false
    
    private let realtimeService = RealtimeService.shared
    private var cancellables = Set<AnyCancellable>()
    private var subscriptionTimer: Timer?
    private var subscribedPairs: Set<String> = []
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        realtimeService.$isConnected
            .assign(to: &$isConnected)
    }
    
    func initialize(initialPairData: [String: PairData] = [:], favorites: [String]) {
        pairData = initialPairData
        isReady = !favorites.isEmpty
        
        if !favorites.isEmpty {
            subscribeToPairs(favorites)
        }
    }
    
    func subscribeToPairs(_ pairs: [String]) {
        let normalizedPairs = pairs.map { $0.uppercased().trimmingCharacters(in: .whitespaces) }
        let pairsSet = Set(normalizedPairs)
        
        // Unsubscribe from removed pairs
        for pair in subscribedPairs {
            if !pairsSet.contains(pair) {
                unsubscribeFromPair(pair)
            }
        }
        
        // Subscribe to new pairs
        for pair in normalizedPairs {
            if !subscribedPairs.contains(pair) {
                subscribeToPair(pair)
            }
        }
    }
    
    private func subscribeToPair(_ pair: String) {
        subscribedPairs.insert(pair)
        
        realtimeService.subscribeToBoxSlices(pairs: [pair]) { [weak self] slices in
            guard let self = self, let slice = slices[pair] else { return }
            
            DispatchQueue.main.async {
                self.pairData[pair] = PairData(
                    boxes: [slice],
                    initialBoxData: slice
                )
            }
        }
    }
    
    private func unsubscribeFromPair(_ pair: String) {
        subscribedPairs.remove(pair)
        
        DispatchQueue.main.async {
            self.pairData.removeValue(forKey: pair)
        }
    }
    
    func getCurrentPrice(for pair: String) -> Double? {
        return realtimeService.priceData[pair.uppercased()]?.price
    }
    
    func getBoxSlice(for pair: String) -> BoxSlice? {
        return pairData[pair.uppercased()]?.boxes.first ?? pairData[pair.uppercased()]?.initialBoxData
    }
}

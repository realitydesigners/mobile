//
//  DashboardView.swift
//  mobile
//
//  Main dashboard view with grid of pair visualizations
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dashboardProvider: DashboardProvider
    @State private var favorites: [String] = ["BTCUSD", "ETHUSD"]
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background1
                    .ignoresSafeArea()
                
                EtherealBackgroundView()
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ],
                        spacing: 16
                    ) {
                        ForEach(favorites, id: \.self) { pair in
                            PairResoBox(
                                pair: pair,
                                boxSlice: dashboardProvider.getBoxSlice(for: pair),
                                isLoading: isLoading,
                                signal: nil
                            )
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                initializeDashboard()
            }
        }
    }
    
    private func initializeDashboard() {
        isLoading = true
        
        Task {
            let initialData = await fetchInitialData()
            
            await MainActor.run {
                dashboardProvider.initialize(
                    initialPairData: initialData,
                    favorites: favorites
                )
                isLoading = false
            }
        }
    }
    
    private func fetchInitialData() async -> [String: PairData] {
        let service = RealtimeService.shared
        let slices = await service.fetchBoxSlices(for: favorites)
        
        var result: [String: PairData] = [:]
        for (pair, slice) in slices {
            result[pair] = PairData(
                boxes: [slice],
                initialBoxData: slice
            )
        }
        
        return result
    }
}

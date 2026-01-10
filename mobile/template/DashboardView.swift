//
//  DashboardView.swift
//  mobile
//
//  Main dashboard view with grid of pair visualizations
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dashboardProvider: DashboardProvider
    @EnvironmentObject var favoritesService: FavoritesService
    @State private var isLoading = false
    @State private var hasInitialized = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Global view mode toggle header
                    HStack {
                        Spacer()
                        ViewModeSelector(viewMode: $dashboardProvider.viewMode)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    
                    if favoritesService.favorites.isEmpty && !favoritesService.isLoading {
                        emptyFavoritesView
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 16) {
                                ForEach(favoritesService.favorites, id: \.self) { pair in
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
                }
                
                if favoritesService.isLoading || isLoading {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                initializeDashboard()
            }
            .onChange(of: favoritesService.favorites) { _, newFavorites in
                if !newFavorites.isEmpty {
                    Task {
                        await loadDataForFavorites(newFavorites)
                    }
                }
            }
        }
    }
    
    private var emptyFavoritesView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "star.slash")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "606878"))
            
            Text("No Favorites")
                .font(.russoOne(size: 20))
                .foregroundColor(.white)
            
            Text("Add instruments from the web app\nto see them here")
                .font(.outfit(size: 14))
                .foregroundColor(Color(hex: "606878"))
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
    
    private func initializeDashboard() {
        guard !hasInitialized else { return }
        hasInitialized = true
        
        Task {
            // Fetch favorites if not already loaded
            if favoritesService.favorites.isEmpty {
                await favoritesService.fetchFavorites()
            }
            
            // Then load box data
            if !favoritesService.favorites.isEmpty {
                await loadDataForFavorites(favoritesService.favorites)
            }
        }
    }
    
    private func loadDataForFavorites(_ favorites: [String]) async {
        await MainActor.run { isLoading = true }
        
        let initialData = await fetchInitialData(for: favorites)
        
        await MainActor.run {
            dashboardProvider.initialize(
                initialPairData: initialData,
                favorites: favorites
            )
            isLoading = false
        }
    }
    
    private func fetchInitialData(for favorites: [String]) async -> [String: PairData] {
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

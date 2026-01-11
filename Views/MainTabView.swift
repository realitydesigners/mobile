//
//  MainTabView.swift
//  AppTemplate
//
//  Main tab navigation - customize tabs for your app
//

import SwiftUI
import UIKit
import CoreData

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var favoritesService: FavoritesService
    @EnvironmentObject var dashboardProvider: DashboardProvider
    
    init() {
        // Customize tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.black
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppTheme.textMuted)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(AppTheme.textMuted),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppTheme.pearl)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(AppTheme.pearl),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Home
            HomeView()
                .tabItem {
                    Image(systemName: TabConfig.home.icon)
                    Text(TabConfig.home.title)
                }
                .tag(0)
            
            // Tab 2: Charts (Dashboard with view modes)
            ChartsView()
                .environmentObject(favoritesService)
                .environmentObject(dashboardProvider)
                .tabItem {
                    Image(systemName: TabConfig.charts.icon)
                    Text(TabConfig.charts.title)
                }
                .tag(1)
            
            // Tab 3: Symbols (Instruments)
            SymbolsView()
                .tabItem {
                    Image(systemName: TabConfig.symbols.icon)
                    Text(TabConfig.symbols.title)
                }
                .tag(2)
            
            // Tab 4: History/Activity (Optional - remove if not needed)
            HistoryPlaceholderView()
                .tabItem {
                    Image(systemName: TabConfig.history.icon)
                    Text(TabConfig.history.title)
                }
                .tag(3)
            
            // Tab 5: Settings
            SettingsView()
                .tabItem {
                    Image(systemName: TabConfig.settings.icon)
                    Text(TabConfig.settings.title)
                }
                .tag(4)
        }
        .tint(AppTheme.pearl)
    }
}

// MARK: - Symbols View

struct SymbolsView: View {
    @EnvironmentObject var favoritesService: FavoritesService
    @EnvironmentObject var dashboardProvider: DashboardProvider
    @State private var searchQuery = ""
    @State private var selectedFilter: InstrumentsPanelView.FilterType = .favorites
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    searchBar
                    
                    // Filter tabs
                    filterTabs
                    
                    // Pairs list
                    pairsList
                }
            }
            .navigationTitle("Symbols")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "808080"))
            
            TextField("Search instruments...", text: $searchQuery)
                .font(.outfit(size: 14))
                .foregroundColor(.white)
                .autocapitalization(.allCharacters)
                .disableAutocorrection(true)
            
            if !searchQuery.isEmpty {
                Button {
                    searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "606878"))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.02))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
    
    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(InstrumentsPanelView.FilterType.allCases, id: \.self) { filter in
                    FilterButton(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter,
                        count: getCount(for: filter)
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = filter
                            searchQuery = ""
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 12)
    }
    
    private func getCount(for filter: InstrumentsPanelView.FilterType) -> Int? {
        switch filter {
        case .favorites:
            return favoritesService.favorites.count
        default:
            return nil
        }
    }
    
    private var filteredPairs: [String] {
        let basePairs: [String]
        
        if !searchQuery.isEmpty {
            basePairs = InstrumentPairs.all.filter {
                $0.lowercased().contains(searchQuery.lowercased())
            }
        } else {
            switch selectedFilter {
            case .favorites:
                basePairs = favoritesService.favorites
            case .all:
                basePairs = InstrumentPairs.all
            case .fx:
                basePairs = InstrumentPairs.forex
            case .crypto:
                basePairs = InstrumentPairs.crypto
            case .equity:
                basePairs = InstrumentPairs.equity
            case .etf:
                basePairs = InstrumentPairs.etf
            }
        }
        
        return basePairs
    }
    
    private var pairsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 4) {
                if filteredPairs.isEmpty {
                    emptyState
                } else {
                    ForEach(filteredPairs, id: \.self) { pair in
                        PairRow(
                            pair: pair,
                            isFavorite: favoritesService.favorites.contains(pair),
                            price: dashboardProvider.getCurrentPrice(for: pair)
                        ) {
                            toggleFavorite(pair)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: selectedFilter == .favorites ? "star.slash" : "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(Color(hex: "606878"))
            
            Text(selectedFilter == .favorites ? "No favorites yet" : "No results found")
                .font(.outfit(size: 14))
                .foregroundColor(Color(hex: "606878"))
            
            if selectedFilter == .favorites {
                Text("Browse All to add instruments")
                    .font(.outfit(size: 12))
                    .foregroundColor(Color(hex: "505560"))
            }
        }
        .padding(.top, 60)
    }
    
    private func toggleFavorite(_ pair: String) {
        Task {
            if favoritesService.favorites.contains(pair) {
                await favoritesService.removeFavorite(pair)
            } else {
                await favoritesService.addFavorite(pair)
            }
        }
    }
}

// MARK: - History Placeholder

/// Placeholder for a history/activity tab - replace with your actual content
struct HistoryPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                EmptyStateView(
                    icon: "clock",
                    title: "History",
                    message: "Your activity history will appear here.\n\nReplace this with your app's history or activity view."
                )
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(FavoritesService.shared)
        .environmentObject(DashboardProvider.shared)
        .environmentObject(AuthManager.shared)
}

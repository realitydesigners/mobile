//
//  InstrumentsPanelView.swift
//  mobile
//
//  Bottom sheet for selecting and managing instrument pairs
//

import SwiftUI

// Available pairs - matching web version
enum InstrumentPairs {
    static let forex = [
        "EURUSD", "GBPUSD", "USDJPY", "USDCHF", "AUDUSD", "USDCAD", "NZDUSD",
        "EURGBP", "EURJPY", "GBPJPY", "AUDJPY", "EURAUD", "EURCHF", "GBPCHF"
    ]
    
    static let crypto = [
        "BTCUSD", "ETHUSD", "SOLUSD", "BNBUSD", "XRPUSD", "ADAUSD", "DOGEUSD",
        "DOTUSD", "MATICUSD", "LINKUSD", "AVAXUSD", "LTCUSD"
    ]
    
    static let equity = [
        "AAPL", "MSFT", "GOOGL", "AMZN", "NVDA", "META", "TSLA",
        "JPM", "V", "JNJ", "WMT", "PG", "MA", "HD"
    ]
    
    static let etf = [
        "SPY", "QQQ", "IWM", "DIA", "VTI", "VOO", "VEA", "EEM"
    ]
    
    static var all: [String] {
        forex + crypto + equity + etf
    }
}

struct InstrumentsPanelView: View {
    @EnvironmentObject var favoritesService: FavoritesService
    @EnvironmentObject var dashboardProvider: DashboardProvider
    @Binding var isPresented: Bool
    
    @State private var searchQuery = ""
    @State private var selectedFilter: FilterType = .favorites
    
    enum FilterType: String, CaseIterable {
        case favorites = "Favorites"
        case all = "All"
        case fx = "FX"
        case crypto = "Crypto"
        case equity = "Equity"
        case etf = "ETF"
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
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Handle bar
                handleBar
                
                // Search bar
                searchBar
                
                // Filter tabs
                filterTabs
                
                // Pairs list
                pairsList
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.black)
    }
    
    private var handleBar: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.white.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
            
            Text("Instruments")
                .font(.russoOne(size: 18))
                .foregroundColor(.white)
                .padding(.bottom, 8)
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
        .padding(.bottom, 12)
    }
    
    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FilterType.allCases, id: \.self) { filter in
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
    
    private func getCount(for filter: FilterType) -> Int? {
        switch filter {
        case .favorites:
            return favoritesService.favorites.count
        default:
            return nil
        }
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

// MARK: - Filter Button

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let count: Int?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.outfit(size: 13, weight: .medium))
                
                if let count = count {
                    Text("\(count)")
                        .font(.kodeMono(size: 11))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            .foregroundColor(isSelected ? .white : Color(hex: "A0A0A0"))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? Color.white.opacity(0.05)
                    : Color.clear
            )
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Pair Row

struct PairRow: View {
    let pair: String
    let isFavorite: Bool
    let price: Double?
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Pair name
            Text(pair)
                .font(.russoOne(size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            // Price
            if let price = price {
                Text(formatPrice(price, pair: pair))
                    .font(.kodeMono(size: 12))
                    .foregroundColor(Color(hex: "A0A0A0"))
            }
            
            // Toggle button
            Button(action: onToggle) {
                Image(systemName: isFavorite ? "checkmark" : "plus")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isFavorite ? Color(hex: "A0A0A0") : Color(hex: "808080"))
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(isFavorite ? 0.05 : 0.03))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.02))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
        )
    }
    
    private func formatPrice(_ price: Double, pair: String) -> String {
        if pair.contains("JPY") {
            return String(format: "%.2f", price)
        } else if pair.contains("USD") || pair.contains("EUR") || pair.contains("GBP") {
            return String(format: "%.5f", price)
        } else {
            return String(format: "%.2f", price)
        }
    }
}

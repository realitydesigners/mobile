//
//  ChartsView.swift
//  mobile
//
//  Charts view with view mode selection panel
//

import SwiftUI

struct ChartsView: View {
    @EnvironmentObject var favoritesService: FavoritesService
    @EnvironmentObject var dashboardProvider: DashboardProvider
    @State private var showViewModeSelection = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if showViewModeSelection {
                    viewModeSelectionView
                } else {
                    DashboardView()
                        .environmentObject(dashboardProvider)
                        .environmentObject(favoritesService)
                }
            }
            .navigationTitle("Charts")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !showViewModeSelection {
                        Button {
                            withAnimation {
                                showViewModeSelection = true
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: iconForMode(dashboardProvider.viewMode))
                                    .font(.system(size: 14, weight: .medium))
                                Text(dashboardProvider.viewMode.rawValue)
                                    .font(.outfit(size: 13, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                            )
                        }
                    }
                }
            }
            .onAppear {
                // Reset to selection view when tab is first opened
                if !showViewModeSelection {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showViewModeSelection = true
                    }
                }
            }
        }
    }
    
    private func iconForMode(_ mode: ViewMode) -> String {
        switch mode {
        case .twoD:
            return "square.grid.2x2"
        case .threeD:
            return "cube"
        }
    }
    
    private var viewModeSelectionView: some View {
        VStack(spacing: 0) {
            // Title
            VStack(spacing: 8) {
                Text("Select View Mode")
                    .font(.russoOne(size: 18))
                    .foregroundColor(.white)
            }
            .padding(.top, 24)
            .padding(.bottom, 32)
            
            // Grid of view mode options
            viewModeGrid
        }
    }
    
    private var viewModeGrid: some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(ViewMode.allCases, id: \.self) { mode in
                    ViewModeCard(
                        mode: mode,
                        isSelected: dashboardProvider.viewMode == mode
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            dashboardProvider.viewMode = mode
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showViewModeSelection = false
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - View Mode Card

struct ViewModeCard: View {
    let mode: ViewMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: iconForMode(mode))
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                    .frame(height: 48)
                
                VStack(spacing: 6) {
                    Text(mode.rawValue)
                        .font(.russoOne(size: 18))
                        .foregroundColor(.white)
                    
                    Text(descriptionForMode(mode))
                        .font(.outfit(size: 12))
                        .foregroundColor(Color(hex: "808080"))
                        .multilineTextAlignment(.center)
                }
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "A0A0A0"))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.white.opacity(0.05) : Color.white.opacity(0.02))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.white.opacity(0.1) : Color.white.opacity(0.05), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func iconForMode(_ mode: ViewMode) -> String {
        switch mode {
        case .twoD:
            return "square.grid.2x2"
        case .threeD:
            return "cube"
        }
    }
    
    private func descriptionForMode(_ mode: ViewMode) -> String {
        switch mode {
        case .twoD:
            return "Flat nested\nbox visualization"
        case .threeD:
            return "Three-dimensional\nbox visualization"
        }
    }
}

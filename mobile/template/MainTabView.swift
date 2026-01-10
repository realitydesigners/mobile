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
    
    init() {
        // Customize tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(AppTheme.background1.opacity(0.95))
        
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
            // Tab 1: Home (Main feature)
            HomeView()
                .tabItem {
                    Image(systemName: TabConfig.home.icon)
                    Text(TabConfig.home.title)
                }
                .tag(0)
            
            // Tab 2: History/Activity (Optional - remove if not needed)
            HistoryPlaceholderView()
                .tabItem {
                    Image(systemName: TabConfig.history.icon)
                    Text(TabConfig.history.title)
                }
                .tag(1)
            
            // Tab 3: Settings
            SettingsView()
                .tabItem {
                    Image(systemName: TabConfig.settings.icon)
                    Text(TabConfig.settings.title)
                }
                .tag(2)
        }
        .tint(AppTheme.pearl)
    }
}

// MARK: - History Placeholder

/// Placeholder for a history/activity tab - replace with your actual content
struct HistoryPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background1
                    .ignoresSafeArea()
                
                EtherealBackgroundView()
                
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
}

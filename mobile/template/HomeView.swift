//
//  HomeView.swift
//  AppTemplate
//
//  Main content view - replace this with your app's primary feature
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \UserProfile.createdAt, ascending: false)],
        animation: .default
    )
    private var userProfiles: FetchedResults<UserProfile>
    
    private var userProfile: UserProfile? {
        userProfiles.first
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppTheme.background1
                    .ignoresSafeArea()
                
                EtherealBackgroundView()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Header
                        headerSection
                            .padding(.top, 20)
                        
                        // Welcome card
                        if let profile = userProfile {
                            welcomeCard(profile: profile)
                        }
                        
                        // Main content placeholder
                        mainContentSection
                        
                        // Feature cards
                        featureCardsSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            // App logo/icon placeholder
            ZStack {
                // Outer glow
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(AppTheme.pearl.opacity(0.03 - Double(i) * 0.01), lineWidth: 0.5)
                        .frame(width: 100 + CGFloat(i) * 30)
                }
                
                // Icon background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.pearl,
                                AppTheme.opal,
                                AppTheme.moonstone
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 70, height: 70)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.pearl.opacity(0.3), lineWidth: 0.5)
                    )
                    .shadow(color: AppTheme.pearl.opacity(0.2), radius: 30)
                    .shadow(color: AppTheme.celestialBlue.opacity(0.1), radius: 50)
                
                // Replace with your app icon
                Image(systemName: "star.fill")
                    .font(.system(size: 28))
                    .foregroundColor(AppTheme.void)
            }
            
            VStack(spacing: 8) {
                Text(AppConfig.appName)
                    .font(.system(size: 24, weight: .light, design: .serif))
                    .foregroundColor(AppTheme.pearl)
                
                Text(formattedDate)
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(AppTheme.textMuted)
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
    
    // MARK: - Welcome Card
    
    private func welcomeCard(profile: UserProfile) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                if let name = profile.name {
                    Text("Hello, \(name)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                } else {
                    Text("Welcome back")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                Text("Ready to get started?")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
        }
        .padding(16)
        .glass(intensity: 0.05, cornerRadius: 16)
    }
    
    // MARK: - Main Content Section
    
    private var mainContentSection: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Main Feature")
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundColor(AppTheme.pearl)
                
                Text("Replace this section with your app's primary functionality")
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(AppTheme.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Placeholder action button
            Button(action: {
                // TODO: Add your main action here
            }) {
                Text("Get Started")
                    .etherealButton()
            }
        }
        .etherealCard(padding: 24)
    }
    
    // MARK: - Feature Cards Section
    
    private var featureCardsSection: some View {
        VStack(spacing: 16) {
            Text("Features")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppTheme.textMuted)
                .textCase(.uppercase)
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                FeatureCard(icon: "star.fill", title: "Feature 1", color: AppTheme.celestialBlue)
                FeatureCard(icon: "heart.fill", title: "Feature 2", color: AppTheme.cosmicPink)
                FeatureCard(icon: "bolt.fill", title: "Feature 3", color: AppTheme.starlightGold)
                FeatureCard(icon: "sparkles", title: "Feature 4", color: AppTheme.twilightPurple)
            }
        }
    }
}

// MARK: - Feature Card

struct FeatureCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .glass(intensity: 0.05, cornerRadius: 16)
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}


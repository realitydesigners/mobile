//
//  AppConfig.swift
//  AppTemplate
//
//  Template configuration file - customize these values for your app
//

import Foundation
import SwiftUI

// MARK: - App Configuration
/// Central configuration for your app. Update these values when creating a new app from this template.

enum AppConfig {
    
    // MARK: - App Identity
    
    /// Your app's display name
    static let appName = "App Template"
    
    /// Short tagline for loading screens
    static let tagline = "Your App Tagline"
    
    /// Longer description for onboarding/about
    static let description = "A beautiful app built with love."
    
    /// App version (usually pulled from Info.plist in production)
    static let version = "1.0"
    
    // MARK: - Branding Colors
    /// Override these to customize the theme colors
    
    static let primaryColor = Color(hex: "7EB8DA")      // Main accent color
    static let secondaryColor = Color(hex: "9B8DC4")    // Secondary accent
    static let accentGold = Color(hex: "D4C4A0")        // Highlight/badge color
    
    // MARK: - API Keys
    /// IMPORTANT: Do NOT commit real API keys to git!
    /// Add "AppConfig.swift" to your .gitignore or use environment variables
    
    /// OpenAI API Key (if using AI features)
    /// Get your key at: https://platform.openai.com/api-keys
    static let openAIAPIKey = "YOUR_OPENAI_API_KEY_HERE"
    
    /// OpenAI API endpoint
    static let openAIEndpoint = "https://api.openai.com/v1/chat/completions"
    
    /// Model to use for AI responses
    static let openAIModel = "gpt-4o-mini"
    
    // MARK: - In-App Purchase
    /// Product ID from App Store Connect
    /// Create this in App Store Connect -> Your App -> In-App Purchases
    static let productId = "your.app.product.id"
    
    // MARK: - URLs
    
    /// Convex deployment URL - update with your actual Convex URL
    /// Format: https://your-deployment.convex.cloud
    static let convexURL = "https://tame-gopher-165.convex.cloud"
    
    /// Privacy Policy URL
    static let privacyPolicyURL = URL(string: "https://yourwebsite.com/privacy")!
    
    /// Terms of Service URL
    static let termsOfServiceURL = URL(string: "https://yourwebsite.com/terms")!
    
    /// Support Email
    static let supportEmail = "support@yourwebsite.com"
    
    // MARK: - Company Info
    
    static let companyName = "Your Company LLC"
    
    // MARK: - Feature Flags
    
    /// Set to true to bypass paywall during development
    static let debugBypassPaywall = true
    
    /// Enable onboarding flow (set false to skip)
    static let enableOnboarding = false
    
    /// Enable loading/splash screen
    static let enableLoadingScreen = false
    
    // MARK: - Paywall Configuration
    
    /// Features to display on the paywall
    static let paywallFeatures: [(icon: String, text: String)] = [
        ("star.fill", "Premium Feature One"),
        ("bolt.fill", "Premium Feature Two"),
        ("heart.fill", "Premium Feature Three"),
        ("sparkles", "Premium Feature Four")
    ]
    
    /// Paywall headline
    static let paywallTitle = "Unlock \(appName)"
    
    /// Paywall subtitle
    static let paywallSubtitle = "Get access to all premium features"
    
    // MARK: - Loading Screen Phrases
    
    static let loadingPhrases = [
        "Loading...",
        "Almost there...",
        appName
    ]
    
    // MARK: - Onboarding
    
    static let onboardingTitle = "Welcome"
    static let onboardingSubtitle = "Let's get you set up"
    static let onboardingButtonText = "Get Started"
}

// MARK: - Tab Configuration

enum TabConfig {
    case home
    case charts
    case symbols
    case history
    case settings
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .charts: return "Charts"
        case .symbols: return "Symbols"
        case .history: return "History"
        case .settings: return "Settings"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .charts: return "chart.bar.fill"
        case .symbols: return "chart.line.uptrend.xyaxis"
        case .history: return "clock"
        case .settings: return "gear"
        }
    }
}


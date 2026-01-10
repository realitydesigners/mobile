//
//  OnboardingView.swift
//  AppTemplate
//
//  User onboarding flow - customize fields as needed for your app
//

import SwiftUI
import CoreData

struct OnboardingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var currentStep = 0
    @State private var name = ""
    @State private var email = ""
    @State private var isNameFocused = false
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.background1
                .ignoresSafeArea()
            
            // Subtle ambient glow
            EtherealBackgroundView()
            
            VStack(spacing: 0) {
                if currentStep == 0 {
                    welcomeScreen
                } else {
                    formScreen
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                appearAnimation = true
            }
        }
    }
    
    // MARK: - Welcome Screen
    
    private var welcomeScreen: some View {
        VStack(spacing: 48) {
            Spacer()
            
            // App logo
            ZStack {
                // Glow rings
                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .stroke(
                            AppTheme.pearl.opacity(0.04 - Double(i) * 0.01),
                            lineWidth: 0.5
                        )
                        .frame(width: 120 + CGFloat(i) * 50)
                }
                
                // Logo background
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
                            endRadius: 70
                        )
                    )
                    .frame(width: 90, height: 90)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.pearl.opacity(0.4), lineWidth: 0.5)
                    )
                    .shadow(color: AppTheme.pearl.opacity(0.25), radius: 40)
                    .shadow(color: AppTheme.celestialBlue.opacity(0.15), radius: 80)
                
                // Replace with your app icon
                Image(systemName: "star.fill")
                    .font(.system(size: 36))
                    .foregroundColor(AppTheme.void)
            }
            .opacity(appearAnimation ? 1 : 0)
            .scaleEffect(appearAnimation ? 1 : 0.9)
            
            // Text
            VStack(spacing: 20) {
                Text(AppConfig.appName)
                    .font(.system(size: 40, weight: .light, design: .serif))
                    .foregroundColor(AppTheme.pearl)
                
                Text(AppConfig.description)
                    .font(.system(size: 17, weight: .light, design: .serif))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 20)
            
            Spacer()
            
            // Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentStep = 1
                }
            }) {
                Text(AppConfig.onboardingButtonText)
                    .etherealButton()
            }
            .padding(.horizontal, 48)
            .padding(.bottom, 60)
            .opacity(appearAnimation ? 1 : 0)
        }
    }
    
    // MARK: - Form Screen
    
    private var formScreen: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 16) {
                    // Small logo
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [AppTheme.pearl, AppTheme.opal],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 25
                            )
                        )
                        .frame(width: 40, height: 40)
                        .shadow(color: AppTheme.pearl.opacity(0.3), radius: 20)
                    
                    Text(AppConfig.onboardingTitle)
                        .font(.system(size: 28, weight: .light, design: .serif))
                        .foregroundColor(AppTheme.pearl)
                    
                    Text(AppConfig.onboardingSubtitle)
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.top, 48)
                
                // Form
                VStack(spacing: 28) {
                    // Name field
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Name")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(1)
                        
                        TextField("", text: $name, prompt: Text("Your name").foregroundColor(AppTheme.textMuted))
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.textPrimary)
                            .etherealInput(isFocused: isNameFocused)
                    }
                    
                    // Email field (optional - remove if not needed)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Text("Email")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)
                                .textCase(.uppercase)
                                .tracking(1)
                            
                            Text("Optional")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.textMuted)
                        }
                        
                        TextField("", text: $email, prompt: Text("your@email.com").foregroundColor(AppTheme.textMuted))
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.textPrimary)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .etherealInput(isFocused: false)
                    }
                    
                    // Add more fields as needed for your app
                    // Examples: birthday, location, preferences, etc.
                }
                .padding(.horizontal, 28)
                
                // Continue button
                Button(action: saveProfile) {
                    Text("Continue")
                        .etherealButton()
                }
                .padding(.horizontal, 48)
                .padding(.top, 20)
                .padding(.bottom, 48)
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveProfile() {
        let newProfile = UserProfile(context: viewContext)
        newProfile.id = UUID()
        newProfile.name = name.isEmpty ? nil : name
        newProfile.email = email.isEmpty ? nil : email
        newProfile.createdAt = Date()
        newProfile.updatedAt = Date()
        newProfile.hasCompletedOnboarding = true
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving profile: \(error)")
        }
    }
}

#Preview {
    OnboardingView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

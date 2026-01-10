//
//  LoadingView.swift
//  AppTemplate
//
//  Animated loading/splash screen - customize text and timing
//

import SwiftUI

struct LoadingView: View {
    @Binding var isLoaded: Bool
    @State private var currentScreen = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.95
    
    var body: some View {
        ZStack {
            // Deep background
            AppTheme.background1
                .ignoresSafeArea()
            
            // Subtle radial glow
            RadialGradient(
                colors: [
                    AppTheme.twilightPurple.opacity(0.15),
                    AppTheme.celestialBlue.opacity(0.08),
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            VStack(spacing: 48) {
                Spacer()
                
                // App logo
                ZStack {
                    // Outer glow rings
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(
                                AppTheme.pearl.opacity(0.03 - Double(i) * 0.01),
                                lineWidth: 1
                            )
                            .frame(width: 140 + CGFloat(i) * 40)
                    }
                    
                    // Main logo background
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppTheme.pearl.opacity(0.9),
                                    AppTheme.opal.opacity(0.7),
                                    AppTheme.moonstone.opacity(0.5)
                                ],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay(
                            Circle()
                                .stroke(AppTheme.pearl.opacity(0.3), lineWidth: 0.5)
                        )
                        .shadow(color: AppTheme.pearl.opacity(0.3), radius: 30)
                        .shadow(color: AppTheme.celestialBlue.opacity(0.2), radius: 60)
                    
                    // Replace with your app icon
                    Image(systemName: "star.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.void)
                }
                .scaleEffect(scale)
                .opacity(opacity)
                
                // Text
                VStack(spacing: 12) {
                    Text(AppConfig.loadingPhrases[min(currentScreen, AppConfig.loadingPhrases.count - 1)])
                        .font(.system(size: currentScreen == AppConfig.loadingPhrases.count - 1 ? 36 : 24, weight: currentScreen == AppConfig.loadingPhrases.count - 1 ? .semibold : .light, design: .serif))
                        .foregroundColor(AppTheme.pearl)
                        .opacity(opacity)
                    
                    if currentScreen < AppConfig.loadingPhrases.count - 1 {
                        Text("...")
                            .font(.system(size: 20, weight: .ultraLight))
                            .foregroundColor(AppTheme.textSecondary)
                            .opacity(opacity * 0.6)
                    }
                }
                
                Spacer()
                
                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<AppConfig.loadingPhrases.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentScreen ? AppTheme.pearl : AppTheme.pearl.opacity(0.2))
                            .frame(width: 6, height: 6)
                            .animation(.easeInOut(duration: 0.3), value: currentScreen)
                    }
                }
                .padding(.bottom, 60)
                .opacity(0.8)
            }
        }
        .onAppear {
            startLoadingSequence()
        }
    }
    
    private func startLoadingSequence() {
        // Initial animation
        withAnimation(.easeOut(duration: 0.8)) {
            opacity = 1
            scale = 1
        }
        
        // Advance through screens
        let phraseCount = AppConfig.loadingPhrases.count
        for i in 1..<phraseCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.2) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    opacity = 0
                    scale = 0.95
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    currentScreen = i
                    withAnimation(.easeOut(duration: 0.6)) {
                        opacity = 1
                        scale = 1
                    }
                }
            }
        }
        
        // Complete loading
        let totalTime = Double(phraseCount) * 1.2 + 0.8
        DispatchQueue.main.asyncAfter(deadline: .now() + totalTime) {
            withAnimation(.easeInOut(duration: 0.6)) {
                isLoaded = true
            }
        }
    }
}

#Preview {
    LoadingView(isLoaded: .constant(false))
}

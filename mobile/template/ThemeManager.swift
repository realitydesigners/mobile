//
//  ThemeManager.swift
//  AppTemplate
//
//  Reusable theming system with glass morphism effects
//

import SwiftUI

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - App Theme

enum AppTheme {
    
    // MARK: - Background Colors (Dark Mode)
    
    static let void = Color(hex: "05070A")              // True deep black
    static let background1 = Color(hex: "080B12")       // Primary background
    static let background2 = Color(hex: "0C1018")       // Elevated surface
    
    // MARK: - Primary Palette
    
    static let pearl = Color(hex: "E8E4F0")             // Soft white
    static let opal = Color(hex: "C4D4E8")              // Opalescent blue-white
    static let nacre = Color(hex: "D8D0E4")             // Mother of pearl pink
    static let moonstone = Color(hex: "B8C8DC")         // Blue-gray
    
    // MARK: - Accent Colors
    
    static let celestialBlue = Color(hex: "7EB8DA")     // Primary accent
    static let twilightPurple = Color(hex: "9B8DC4")    // Secondary accent
    static let auroraGreen = Color(hex: "8CCFB8")       // Success/positive
    static let starlightGold = Color(hex: "D4C4A0")     // Warning/highlight
    
    // MARK: - Glass Colors
    
    static let glassWhite = Color.white.opacity(0.08)
    static let glassBorder = Color.white.opacity(0.12)
    static let glassHighlight = Color.white.opacity(0.15)
    
    // MARK: - Text Colors
    
    static let textPrimary = Color(hex: "F0EEF4")       // Primary text
    static let textSecondary = Color(hex: "A0A8B8")     // Secondary text
    static let textMuted = Color(hex: "606878")         // Muted/disabled text
    
    // MARK: - Semantic Colors
    
    static let cardBackground = glassWhite
    static let primaryAccent = celestialBlue
    static let secondaryAccent = twilightPurple
    static let success = auroraGreen
    static let warning = starlightGold
    static let cosmicPink = Color(hex: "C8A0B8")
    static let cosmicTeal = auroraGreen
    
    // MARK: - Gradients
    
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(hex: "080B12"),
            Color(hex: "0E1420"),
            Color(hex: "101828")
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let pearlGradient = LinearGradient(
        colors: [
            Color(hex: "C4D4E8").opacity(0.9),
            Color(hex: "D8D0E4").opacity(0.7),
            Color(hex: "E8E4F0").opacity(0.8)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let glassGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.12),
            Color.white.opacity(0.05),
            Color.white.opacity(0.08)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [
            Color(hex: "7EB8DA").opacity(0.8),
            Color(hex: "9B8DC4").opacity(0.8)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = glassGradient
    
    static let subtleShimmer = LinearGradient(
        colors: [
            Color.white.opacity(0.0),
            Color.white.opacity(0.1),
            Color.white.opacity(0.0)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Glass Morphism Modifier

struct GlassModifier: ViewModifier {
    var intensity: Double = 0.08
    var cornerRadius: CGFloat = 20
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Base glass
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.white.opacity(intensity))
                    
                    // Inner highlight
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.clear,
                                    Color.white.opacity(0.02)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.05),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
    }
}

// MARK: - Ethereal Card Modifier

struct EtherealCardModifier: ViewModifier {
    var padding: CGFloat = 20
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.06))
                    
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.08),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            )
    }
}

// MARK: - Glowing Input Field

struct EtherealInputModifier: ViewModifier {
    var isFocused: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color.white.opacity(0.04))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isFocused 
                            ? AppTheme.celestialBlue.opacity(0.5)
                            : Color.white.opacity(0.08),
                        lineWidth: isFocused ? 1 : 0.5
                    )
            )
    }
}

// MARK: - Ethereal Button

struct EtherealButtonModifier: ViewModifier {
    var isEnabled: Bool = true
    var style: ButtonStyle = .primary
    
    enum ButtonStyle {
        case primary, secondary, ghost
    }
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(backgroundView)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 0.5)
            )
            .opacity(isEnabled ? 1 : 0.5)
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return AppTheme.void
        case .secondary, .ghost:
            return AppTheme.pearl
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            AppTheme.pearlGradient
        case .secondary:
            Color.white.opacity(0.08)
        case .ghost:
            Color.clear
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary:
            return Color.clear
        case .secondary:
            return Color.white.opacity(0.1)
        case .ghost:
            return Color.white.opacity(0.2)
        }
    }
}

// MARK: - View Extensions

extension View {
    func glass(intensity: Double = 0.08, cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassModifier(intensity: intensity, cornerRadius: cornerRadius))
    }
    
    func etherealCard(padding: CGFloat = 20) -> some View {
        modifier(EtherealCardModifier(padding: padding))
    }
    
    func etherealInput(isFocused: Bool) -> some View {
        modifier(EtherealInputModifier(isFocused: isFocused))
    }
    
    func etherealButton(isEnabled: Bool = true, style: EtherealButtonModifier.ButtonStyle = .primary) -> some View {
        modifier(EtherealButtonModifier(isEnabled: isEnabled, style: style))
    }
    
    // Legacy support aliases
    func mysticalCard() -> some View {
        etherealCard()
    }
    
    func glowingTextField(isFocused: Bool) -> some View {
        etherealInput(isFocused: isFocused)
    }
    
    func mysticalButton(isEnabled: Bool = true) -> some View {
        etherealButton(isEnabled: isEnabled)
    }
}

// MARK: - Animated Shimmer

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.5)
                    .offset(x: -geo.size.width * 0.25 + phase * geo.size.width * 1.5)
                    .mask(content)
                }
            )
            .onAppear {
                withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Reusable Background Views

struct EtherealBackgroundView: View {
    var body: some View {
        ZStack {
            // Top glow
            RadialGradient(
                colors: [
                    AppTheme.twilightPurple.opacity(0.08),
                    Color.clear
                ],
                center: .top,
                startRadius: 0,
                endRadius: 400
            )
            
            // Bottom glow
            RadialGradient(
                colors: [
                    AppTheme.celestialBlue.opacity(0.05),
                    Color.clear
                ],
                center: .bottom,
                startRadius: 0,
                endRadius: 300
            )
        }
        .ignoresSafeArea()
    }
}

struct StarsBackgroundView: View {
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<30, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.05...0.2)))
                    .frame(width: CGFloat.random(in: 1...2))
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height)
                    )
            }
        }
    }
}

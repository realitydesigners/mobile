//
//  Utilities.swift
//  AppTemplate
//
//  Reusable utility views and helpers
//

import SwiftUI

// MARK: - Share Sheet (UIKit Wrapper)

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Loading Indicator

struct LoadingIndicator: View {
    var message: String = "Loading..."
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(message)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(AppTheme.textMuted)
        }
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var action: (() -> Void)? = nil
    var actionTitle: String = "Get Started"
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(AppTheme.textMuted)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .medium, design: .serif))
                    .foregroundColor(AppTheme.pearl)
                
                Text(message)
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.celestialBlue)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(AppTheme.celestialBlue.opacity(0.15))
                        .cornerRadius(24)
                }
            }
        }
        .padding(32)
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil
    var actionTitle: String = "See All"
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppTheme.textMuted)
                .textCase(.uppercase)
                .tracking(1)
            
            Spacer()
            
            if let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.celestialBlue)
                }
            }
        }
    }
}

// MARK: - Divider Line

struct DividerLine: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.clear, AppTheme.pearl.opacity(0.15), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 0.5)
    }
}

// MARK: - Date Formatting Helpers

extension Date {
    func formatted(style: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: self)
    }
    
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - View Extensions

extension View {
    /// Hide keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// Conditional modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}


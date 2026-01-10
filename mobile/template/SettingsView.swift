//
//  SettingsView.swift
//  AppTemplate
//
//  Settings screen with profile, about, privacy policy, and terms
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \UserProfile.createdAt, ascending: false)],
        animation: .default
    )
    private var userProfiles: FetchedResults<UserProfile>
    
    @State private var showEditProfile = false
    @State private var showDeleteConfirmation = false
    @State private var showAbout = false
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    
    private var userProfile: UserProfile? {
        userProfiles.first
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background1
                    .ignoresSafeArea()
                
                EtherealBackgroundView()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        profileSection
                        appInfoSection
                        dangerZoneSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(profile: userProfile)
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showTermsOfService) {
                TermsOfServiceView()
            }
            .alert("Delete All Data", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("This will permanently delete your profile and all data.")
            }
        }
    }
    
    // MARK: - Profile Section
    
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profile")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppTheme.textMuted)
                .textCase(.uppercase)
                .tracking(1)
            
            if let profile = userProfile {
                VStack(spacing: 20) {
                    HStack(spacing: 16) {
                        // Avatar
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [AppTheme.pearl.opacity(0.8), AppTheme.opal.opacity(0.6)],
                                    center: .topLeading,
                                    startRadius: 0,
                                    endRadius: 25
                                )
                            )
                            .frame(width: 50, height: 50)
                            .shadow(color: AppTheme.pearl.opacity(0.2), radius: 15)
                            .overlay(
                                Text(String(profile.name?.prefix(1) ?? "?").uppercased())
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(AppTheme.void)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.name ?? "User")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            if let email = profile.email {
                                Text(email)
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Edit button
                    Button(action: { showEditProfile = true }) {
                        Text("Edit Profile")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.celestialBlue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppTheme.celestialBlue.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding(20)
                .glass(intensity: 0.05, cornerRadius: 20)
            }
        }
    }
    
    // MARK: - App Info Section
    
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppTheme.textMuted)
                .textCase(.uppercase)
                .tracking(1)
            
            VStack(spacing: 1) {
                SettingsRow(icon: "info.circle", title: "About \(AppConfig.appName)", color: AppTheme.twilightPurple) {
                    showAbout = true
                }
                
                Divider()
                    .background(Color.white.opacity(0.05))
                
                SettingsRow(icon: "hand.raised", title: "Privacy Policy", color: AppTheme.celestialBlue) {
                    showPrivacyPolicy = true
                }
                
                Divider()
                    .background(Color.white.opacity(0.05))
                
                SettingsRow(icon: "doc.text", title: "Terms of Service", color: AppTheme.textSecondary) {
                    showTermsOfService = true
                }
            }
            .glass(intensity: 0.05, cornerRadius: 16)
        }
    }
    
    // MARK: - Danger Zone
    
    private var dangerZoneSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppTheme.textMuted)
                .textCase(.uppercase)
                .tracking(1)
            
            Button(action: { showDeleteConfirmation = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.red.opacity(0.8))
                    
                    Text("Delete All Data")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.red.opacity(0.8))
                    
                    Spacer()
                }
                .padding(16)
                .background(Color.red.opacity(0.08))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.red.opacity(0.15), lineWidth: 0.5)
                )
            }
        }
    }
    
    private func deleteAllData() {
        for profile in userProfiles {
            viewContext.delete(profile)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error deleting data: \(error)")
        }
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(16)
        }
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    let profile: UserProfile?
    
    @State private var name = ""
    @State private var email = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background1
                    .ignoresSafeArea()
                
                EtherealBackgroundView()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(spacing: 20) {
                            FormField(label: "Name", text: $name)
                            FormField(label: "Email", text: $email, placeholder: "Optional")
                        }
                        .padding(20)
                        
                        Button(action: saveProfile) {
                            Text("Save")
                                .etherealButton()
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
            }
            .onAppear {
                loadProfile()
            }
        }
    }
    
    private func loadProfile() {
        guard let profile = profile else { return }
        name = profile.name ?? ""
        email = profile.email ?? ""
    }
    
    private func saveProfile() {
        guard let profile = profile else { return }
        
        profile.name = name.isEmpty ? nil : name
        profile.email = email.isEmpty ? nil : email
        profile.updatedAt = Date()
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving profile: \(error)")
        }
    }
}

// MARK: - Form Field

struct FormField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
                .textCase(.uppercase)
                .tracking(1)
            
            TextField("", text: $text, prompt: Text(placeholder.isEmpty ? label : placeholder).foregroundColor(AppTheme.textMuted))
                .font(.system(size: 16))
                .foregroundColor(AppTheme.textPrimary)
                .padding(14)
                .background(Color.white.opacity(0.04))
                .cornerRadius(14)
        }
    }
}

// MARK: - About View

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background1
                    .ignoresSafeArea()
                
                EtherealBackgroundView()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Logo
                    ZStack {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .stroke(AppTheme.pearl.opacity(0.03 - Double(i) * 0.01), lineWidth: 0.5)
                                .frame(width: 100 + CGFloat(i) * 40)
                        }
                        
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [AppTheme.pearl, AppTheme.opal, AppTheme.moonstone],
                                    center: .topLeading,
                                    startRadius: 0,
                                    endRadius: 50
                                )
                            )
                            .frame(width: 70, height: 70)
                            .shadow(color: AppTheme.pearl.opacity(0.25), radius: 30)
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppTheme.void)
                    }
                    
                    VStack(spacing: 12) {
                        Text(AppConfig.appName)
                            .font(.system(size: 32, weight: .light, design: .serif))
                            .foregroundColor(AppTheme.pearl)
                        
                        Text("Version \(AppConfig.version)")
                            .font(.system(size: 13, weight: .light))
                            .foregroundColor(AppTheme.textMuted)
                    }
                    
                    Text(AppConfig.description)
                        .font(.system(size: 15, weight: .light, design: .serif))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    
                    Spacer()
                    
                    Text("Made with ❤️")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(AppTheme.textMuted)
                        .padding(.bottom, 40)
                }
                .padding(32)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
    }
}

// MARK: - Privacy Policy View

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background1
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Privacy Policy")
                            .font(.system(size: 28, weight: .light, design: .serif))
                            .foregroundColor(AppTheme.pearl)
                        
                        Text("Last updated: \(Date().formatted(style: .medium))")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(AppTheme.textMuted)
                        
                        Group {
                            PolicySection(title: "Introduction", content: """
\(AppConfig.appName) ("we," "our," or "us") respects your privacy. This Privacy Policy explains how we collect, use, and protect your information when you use the \(AppConfig.appName) mobile application.
""")
                            
                            PolicySection(title: "Information We Collect", content: """
• Profile Information: Name and email (optional) that you provide during setup.

• Usage Data: Information about how you use the app, stored locally on your device.
""")
                            
                            PolicySection(title: "Data Storage", content: """
• All your personal data is stored locally on your device.

• We do not store your personal information on external servers.

• Your data syncs only if you enable iCloud backup on your device.
""")
                            
                            PolicySection(title: "Third-Party Services", content: """
• Apple: Payment processing and subscription management is handled by Apple through the App Store.
""")
                            
                            PolicySection(title: "Your Rights", content: """
• You can delete all your data at any time through the Settings menu in the app.

• You can modify your profile information at any time.

• Uninstalling the app will remove all locally stored data.
""")
                            
                            PolicySection(title: "Contact Us", content: """
If you have questions about this Privacy Policy, please contact us at:
\(AppConfig.supportEmail)
""")
                        }
                    }
                    .padding(24)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.celestialBlue)
                }
            }
        }
    }
}

// MARK: - Terms of Service View

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background1
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Terms of Service")
                            .font(.system(size: 28, weight: .light, design: .serif))
                            .foregroundColor(AppTheme.pearl)
                        
                        Text("Last updated: \(Date().formatted(style: .medium))")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(AppTheme.textMuted)
                        
                        Group {
                            PolicySection(title: "Acceptance of Terms", content: """
By downloading, installing, or using \(AppConfig.appName), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app.
""")
                            
                            PolicySection(title: "Description of Service", content: """
\(AppConfig.appName) is a mobile application that provides [describe your app's functionality here].
""")
                            
                            PolicySection(title: "Subscription Terms", content: """
• \(AppConfig.appName) offers subscription plans that provide access to premium features.

• Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period.

• You can manage and cancel subscriptions in your Apple ID account settings.

• No refunds will be provided for partial subscription periods.
""")
                            
                            PolicySection(title: "User Responsibilities", content: """
You agree to:

• Provide accurate information in your profile.

• Use the app for personal, non-commercial purposes only.

• Not attempt to reverse engineer, hack, or disrupt the service.
""")
                            
                            PolicySection(title: "Disclaimer of Warranties", content: """
\(AppConfig.appName) is provided "as is" without warranties of any kind. We do not guarantee that the service will be uninterrupted or error-free.
""")
                            
                            PolicySection(title: "Contact", content: """
For questions about these Terms of Service, please contact:
\(AppConfig.supportEmail)
""")
                        }
                    }
                    .padding(24)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.celestialBlue)
                }
            }
        }
    }
}

// MARK: - Policy Section Helper

struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.pearl)
            
            Text(content)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(4)
        }
    }
}

#Preview {
    SettingsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

//
//  AuthManager.swift
//  mobile
//
//  Handles Supabase authentication with Google OAuth
//

import Foundation
import Combine
import Supabase
import AuthenticationServices

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var user: User?
    @Published var error: String?
    
    private init() {
        Task {
            await checkSession()
        }
    }
    
    func checkSession() async {
        isLoading = true
        do {
            let session = try await supabase.auth.session
            self.user = session.user
            self.isAuthenticated = true
        } catch {
            self.user = nil
            self.isAuthenticated = false
        }
        isLoading = false
    }
    
    func signInWithGoogle() async {
        isLoading = true
        error = nil
        
        do {
            try await supabase.auth.signInWithOAuth(
                provider: .google,
                redirectTo: SupabaseConfig.redirectURL
            )
        } catch {
            self.error = error.localizedDescription
            print("Google sign-in error: \(error)")
        }
        
        isLoading = false
    }
    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            self.user = nil
            self.isAuthenticated = false
        } catch {
            print("Sign out error: \(error)")
        }
    }
    
    func handleURL(_ url: URL) async {
        do {
            try await supabase.auth.session(from: url)
            await checkSession()
        } catch {
            print("Error handling auth URL: \(error)")
        }
    }
}

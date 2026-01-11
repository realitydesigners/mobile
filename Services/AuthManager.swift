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
    
    private var authStateTask: Task<Void, Never>?
    
    private init() {
        setupAuthStateListener()
        Task {
            await checkSession()
        }
    }
    
    private func setupAuthStateListener() {
        authStateTask = Task {
            for await (event, session) in supabase.auth.authStateChanges {
                await MainActor.run {
                    print("Auth state changed: \(event)")
                    switch event {
                    case .signedIn:
                        self.user = session?.user
                        self.isAuthenticated = true
                        self.isLoading = false
                        print("User signed in: \(session?.user.email ?? "unknown")")
                    case .signedOut:
                        self.user = nil
                        self.isAuthenticated = false
                        self.isLoading = false
                        print("User signed out")
                    case .initialSession:
                        self.user = session?.user
                        self.isAuthenticated = session != nil
                        self.isLoading = false
                        print("Initial session: \(session != nil ? "exists" : "none")")
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func checkSession() async {
        isLoading = true
        do {
            let session = try await supabase.auth.session
            self.user = session.user
            self.isAuthenticated = true
            print("Session check: authenticated as \(session.user.email ?? "unknown")")
        } catch {
            self.user = nil
            self.isAuthenticated = false
            print("Session check: not authenticated - \(error)")
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
            isLoading = false
        }
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
        print("Handling auth URL: \(url)")
        isLoading = true
        do {
            let session = try await supabase.auth.session(from: url)
            self.user = session.user
            self.isAuthenticated = true
            print("Auth URL handled, user: \(session.user.email ?? "unknown")")
        } catch {
            print("Error handling auth URL: \(error)")
        }
        isLoading = false
    }
}

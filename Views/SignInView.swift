//
//  SignInView.swift
//  mobile
//
//  Sign in screen with Google OAuth
//

import SwiftUI

struct SignInView: View {
    @ObservedObject var authManager = AuthManager.shared
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Logo/Title
                VStack(spacing: 8) {
                    Text("RTHMN")
                        .font(.russoOne(size: 48))
                        .foregroundColor(.white)
                    
                    Text("Sign in to access your dashboard")
                        .font(.outfit(size: 14))
                        .foregroundColor(Color(hex: "808080"))
                }
                
                Spacer()
                
                // Sign in button
                VStack(spacing: 16) {
                    Button {
                        Task {
                            await authManager.signInWithGoogle()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            // Google icon
                            Image(systemName: "g.circle.fill")
                                .font(.system(size: 20))
                            
                            Text("SIGN IN WITH GOOGLE")
                                .font(.kodeMono(size: 14))
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                    .disabled(authManager.isLoading)
                    .opacity(authManager.isLoading ? 0.6 : 1)
                    
                    if let error = authManager.error {
                        Text(error)
                            .font(.outfit(size: 12))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                    .frame(height: 60)
            }
            
            if authManager.isLoading {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
            }
        }
    }
}

#Preview {
    SignInView()
}

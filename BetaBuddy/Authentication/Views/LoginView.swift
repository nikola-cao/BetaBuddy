//
//  LoginView.swift
//  BetaBuddy
//
//  Beautiful login screen with brand styling
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var navigateToFeed = false
    
    @Environment(AuthenticationVM.self) var authVM
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Back button
                    backButton
                    
                    // Logo & Welcome Section
                    headerSection
                    
                    // Form Section
                    formSection
                    
                    // Sign In Button
                    signInButton
                    
                    // Forgot Password
                    forgotPasswordLink
                    
                    Spacer(minLength: 40)
                    
                    // Register Link
                    registerLink
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToFeed) {
            FeedView()
                .environment(authVM)
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.betaBlue.opacity(0.15),
                Color.backgroundBase,
                Color.backgroundBase
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Back Button
    
    private var backButton: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                }
                .foregroundColor(Color.textSecondary)
            }
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Mascot illustration (slightly smaller for login)
            AnimatedMascotView(size: 120)
            
            // Welcome text
            VStack(spacing: 8) {
                Text("Welcome Back!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color.cruxNavy)
                
                Text("Sign in to continue your climbing journey")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Form Section
    
    private var formSection: some View {
        VStack(spacing: 16) {
            // Email Field
            BetaBuddyTextField(
                placeholder: "Email",
                text: $email,
                icon: "envelope.fill",
                keyboardType: .emailAddress
            )
            
            // Password Field
            BetaBuddySecureField(
                placeholder: "Password",
                text: $password,
                icon: "lock.fill"
            )
            
            // Error Message
            if let errorMessage = authVM.errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 14))
                    Text(errorMessage)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                }
                .foregroundColor(Color.red)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Sign In Button
    
    private var signInButton: some View {
        Button {
            Task {
                await authVM.login(email: email, password: password)
                await authVM.updateCurrentUser()
                if authVM.isLoggedIn {
                    navigateToFeed = true
                }
            }
        } label: {
            HStack(spacing: 10) {
                if authVM.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        .scaleEffect(0.9)
                } else {
                    Text("Sign In")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .foregroundColor(Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.betaBlue, Color.betaBlue.opacity(0.85)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: Color.betaBlue.opacity(0.4), radius: 10, x: 0, y: 6)
        }
        .disabled(authVM.isLoading || email.isEmpty || password.isEmpty)
        .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)
        .padding(.bottom, 16)
    }
    
    // MARK: - Forgot Password
    
    private var forgotPasswordLink: some View {
        Button {
            // Forgot password action
        } label: {
            Text("Forgot Password?")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Color.betaBlue)
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Register Link
    
    private var registerLink: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(Color.textSecondary)
            
            Button {
                dismiss()
            } label: {
                Text("Sign Up")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Color.sendOrange)
            }
        }
        .padding(.bottom, 24)
    }
}

// MARK: - Preview

#Preview("Login") {
    NavigationStack {
        LoginView()
            .environment(AuthenticationVM())
    }
}

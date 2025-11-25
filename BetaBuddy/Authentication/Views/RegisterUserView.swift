//
//  RegisterUserView.swift
//  BetaBuddy
//
//  Beautiful registration screen with brand styling
//

import SwiftUI

struct RegisterUserView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var navigateToFeed = false
    @State private var showPassword = false
    
    @FocusState private var focusedField: Field?
    
    @Environment(AuthenticationVM.self) var authVM
    
    enum Field {
        case username, email, password
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Logo & Welcome Section
                    headerSection
                    
                    // Form Section
                    formSection
                    
                    // Sign Up Button
                    signUpButton
                    
                    // Divider
                    orDivider
                    
                    // Login Link
                    loginLink
                    
                    Spacer(minLength: 40)
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
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Mascot illustration
            AnimatedMascotView(size: 140)
                .padding(.top, 40)
            
            // App name & tagline
            VStack(spacing: 4) {
                LogoTextView(fontSize: 36)
                
                Text("Your climbing journey starts here")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color.textSecondary)
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Form Section
    
    private var formSection: some View {
        VStack(spacing: 16) {
            // Username Field
            BetaBuddyTextField(
                placeholder: "Username",
                text: $username,
                icon: "person.fill"
            )
            
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
    
    // MARK: - Sign Up Button
    
    private var signUpButton: some View {
        Button {
            Task {
                await authVM.register(email: email, password: password, username: username)
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
                    Text("Create Account")
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
                    colors: [Color.sendOrange, Color.sendOrange.opacity(0.9)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: Color.sendOrange.opacity(0.4), radius: 10, x: 0, y: 6)
        }
        .disabled(authVM.isLoading || username.isEmpty || email.isEmpty || password.isEmpty)
        .opacity(username.isEmpty || email.isEmpty || password.isEmpty ? 0.6 : 1.0)
        .padding(.bottom, 24)
    }
    
    // MARK: - Or Divider
    
    private var orDivider: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(Color.textSecondary.opacity(0.3))
                .frame(height: 1)
            
            Text("or")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color.textSecondary)
            
            Rectangle()
                .fill(Color.textSecondary.opacity(0.3))
                .frame(height: 1)
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Login Link
    
    private var loginLink: some View {
        NavigationLink {
            LoginView()
                .environment(authVM)
        } label: {
            HStack(spacing: 4) {
                Text("Already have an account?")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(Color.textSecondary)
                
                Text("Sign In")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Color.betaBlue)
            }
        }
    }
}

// MARK: - Preview

#Preview("Register") {
    NavigationStack {
        RegisterUserView()
            .environment(AuthenticationVM())
    }
}

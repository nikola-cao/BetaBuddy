//
//  LoginView.swift
//  BetaBuddy
//
//  Created by Nikola Cao on 11/8/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var navigateToFeed = false
    
    @Environment(AuthenticationVM.self) var authVM
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
            
            // Error message display
            if let errorMessage = authVM.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
            
            Button("Sign In") {
                Task {
                    await authVM.login(email: email, password: password)
                    await authVM.updateCurrentUser()
                    if authVM.isLoggedIn {
                        navigateToFeed = true
                    }
                }
            }
            .padding()
            .disabled(authVM.isLoading)
            
            if authVM.isLoading {
                ProgressView()
                    .padding()
            }
            
            Button("Still Need to Register?") {
                dismiss()
            }
            .font(.system(size: 13))
        }
        .navigationDestination(isPresented: $navigateToFeed) {
            FeedView()
                .environment(authVM)
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthenticationVM())
}

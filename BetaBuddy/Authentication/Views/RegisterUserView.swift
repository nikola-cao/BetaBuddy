//
//  RegisterUserView.swift
//  BetaBuddy
//
//  Created by Nikola Cao on 11/7/25.
//

import SwiftUI

struct RegisterUserView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    
    @State private var navigateToFeed = false
    
    @Environment(AuthenticationVM.self) var authVM
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
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
            
            Button("Sign Up") {
                Task {
                    await authVM.register(email: email, password: password, username: username)
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
            
            NavigationLink("Already Signed Up?") {
                LoginView()
                    .environment(authVM)
            }
            .font(.system(size: 13))
            .foregroundStyle(Color(.blue))
        }
        .navigationDestination(isPresented: $navigateToFeed) {
            FeedView()
                .environment(authVM)
        }
    }
}

#Preview {
    NavigationStack {
        RegisterUserView()
            .environment(AuthenticationVM())
    }
}

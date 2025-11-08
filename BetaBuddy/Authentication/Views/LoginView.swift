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
    @State private var navigateToTemp = false
    
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
            
            Button("Sign In") {
                Task {
                    await authVM.login(email: email, password: password)
                    if authVM.isLoggedIn {
                        navigateToTemp = true
                    }
                }
            }
            .padding()
            
            Button("Still Need to Register?") {
                dismiss()
            }
            .font(.system(size: 13))
        }
        .navigationDestination(isPresented: $navigateToTemp) {
            Temp()
                .environment(authVM)
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthenticationVM())
}

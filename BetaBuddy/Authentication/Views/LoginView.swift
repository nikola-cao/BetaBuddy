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
    
    @Environment(AuthenticationVM.self) var authVM
    
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
                }
            }
            .padding()
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthenticationVM())
}

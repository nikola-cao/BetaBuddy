//
//  RegisterUserView.swift
//  BetaBuddy
//
//  Created by Nikola Cao on 11/7/25.
//

import SwiftUI

struct RegisterUserView: View {
    let authVM: AuthenticationVM = AuthenticationVM()
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    
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
            
            Button("Sign Up") {
                authVM.register(email: email, password: password, username: username)
            }
            .padding()
            
            Button("Already Signed Up?") {
                
            }
            .font(.system(size: 13))
        }
    }
}

#Preview {
    RegisterUserView()
}

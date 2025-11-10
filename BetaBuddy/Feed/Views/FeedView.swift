//
//  Temp.swift
//  BetaBuddy
//
//  Created by Nikola Cao on 11/8/25.
//

import SwiftUI

struct FeedView: View {
    @State private var navigateToCreatePostView = false
    
    @Environment(AuthenticationVM.self) var authVM
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack {
                
                if let user = authVM.currentUser {
                    Text("Logged in to \(user.username)")
                } else {
                    Text("Couldn't find current user")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    navigateToCreatePostView = true
                }) {
                    Label("addPost", systemImage: "plus.circle")
                }
            }
        }
        .navigationDestination(isPresented: $navigateToCreatePostView) {
            CreatePostView()
                .environment(authVM)
        }
    }
}

#Preview {
    NavigationStack {
        FeedView()
            .environment(AuthenticationVM())
    }
}

//
//  Temp.swift
//  BetaBuddy
//
//  Created by Nikola Cao on 11/8/25.
//

import SwiftUI

struct FeedView: View {
    @State private var navigateToCreatePostView = false
    @State private var navigateToSearchUsersView = false
    
    @State private var feedVM = FeedVM()
    @Environment(AuthenticationVM.self) var authVM
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // Welcome header
                if let user = authVM.currentUser {
                    HStack {
                        Text("Welcome, \(user.username)!")
                            .font(.title2)
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                
                // Loading state
                if feedVM.isLoading {
                    ProgressView("Loading posts...")
                        .padding()
                }
                
                // Error message
                if let errorMessage = feedVM.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // Posts list
                if !feedVM.isLoading && feedVM.posts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No posts yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Be the first to share a climb!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 60)
                } else {
                    ForEach(feedVM.posts) { post in
                        PostView(post: post)
                    }
                }
            }
            .padding(.bottom, 16)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    navigateToSearchUsersView = true
                }) {
                    Label("searchUsers", systemImage: "magnifyingglass")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    navigateToCreatePostView = true
                }) {
                    Label("addPost", systemImage: "plus.circle")
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    if let currentUserID = authVM.currentUser?.userId {
                        feedVM.fetchAllPosts(currentUserID: currentUserID, friends: authVM.currentUser?.friends ?? [])
                    }
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        }
        .navigationDestination(isPresented: $navigateToCreatePostView) {
            CreatePostView()
                .environment(authVM)
        }
        .navigationDestination(isPresented: $navigateToSearchUsersView) {
            SearchUsersView()
                .environment(authVM)
                .environment(feedVM)
        }
        .onAppear {
            // Fetch posts when view appears
            if let currentUserID = authVM.currentUser?.userId {
                feedVM.fetchAllPosts(currentUserID: currentUserID, friends: authVM.currentUser?.friends ?? [])
            }
        }
    }
}

#Preview {
    NavigationStack {
        FeedView()
            .environment(AuthenticationVM())
    }
}

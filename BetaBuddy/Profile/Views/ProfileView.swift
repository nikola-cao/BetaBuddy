//
//  ProfileView.swift
//  BetaBuddy
//
//  Created by Sarvesh Gade on 11/16/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var profileVM = ProfileVM()
    @Environment(AuthenticationVM.self) var authVM
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 16) {
                    // Profile Picture
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    // Username and Email
                    if let user = authVM.currentUser {
                        Text(user.username)
                            .font(.title)
                            .bold()
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Post count
                        Text("\(profileVM.posts.count) \(profileVM.posts.count == 1 ? "Post" : "Posts")")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    
                    // Sign Out Button
                    Button(action: {
                        authVM.signOut()
                    }) {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                Divider()
                    .padding(.horizontal, 16)
                
                // Posts Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("My Posts")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal, 16)
                    
                    // Loading state
                    if profileVM.isLoading {
                        ProgressView("Loading posts...")
                            .padding()
                    }
                    
                    // Error message
                    if let errorMessage = profileVM.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    // Posts list or empty state
                    if !profileVM.isLoading && profileVM.posts.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No posts yet")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Start sharing your climbs!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else {
                        ForEach(profileVM.posts) { post in
                            ProfilePostView(
                                post: post,
                                onDelete: {
                                    if let userID = authVM.currentUser?.userId {
                                        profileVM.deletePost(postID: post.postID, userID: userID)
                                    }
                                }
                            )
                        }
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView().environment(authVM)) {
                    Image(systemName: "gearshape")
                        .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            // Fetch user's posts when view appears
            if let userID = authVM.currentUser?.userId {
                profileVM.fetchUserPosts(userID: userID)
            }
        }
    }
}

// Post view with delete menu for profile page
struct ProfilePostView: View {
    let post: PostModel
    let onDelete: () -> Void
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Post content (reusing the same layout as PostView)
            VStack(alignment: .leading, spacing: 12) {
                // Header with username and date
                HStack {
                    Text(post.username)
                        .font(.headline)
                    Spacer()
                    Text(post.date.toString())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    // Climb details
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Grade:")
                                .foregroundColor(.secondary)
                            Text(post.grade.rawValue)
                                .bold()
                        }
                        
                        HStack {
                            Text("Attempts:")
                                .foregroundColor(.secondary)
                            Text("\(post.attempts)")
                        }
                        
                        HStack {
                            Text("Gym:")
                                .foregroundColor(.secondary)
                            Text("\(post.gymName)")
                        }
                        
                        HStack {
                            Text("Location:")
                                .foregroundColor(.secondary)
                            Text(post.location)
                        }
                    }
                    
                    Spacer()
                    
                    // Notes section
                    if !post.notes.isEmpty {
                        Text(post.notes)
                            .font(.body)
                            .padding(.top, 4)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            
            // Delete button with menu
            Menu {
                Button(role: .destructive, action: {
                    showDeleteConfirmation = true
                }) {
                    Label("Delete Post", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .confirmationDialog(
            "Are you sure you want to delete this post?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environment(AuthenticationVM())
    }
}

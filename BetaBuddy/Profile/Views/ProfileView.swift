//
//  ProfileView.swift
//  BetaBuddy
//
//  Profile View with Design System styling
//

import SwiftUI

struct ProfileView: View {
    @State private var profileVM = ProfileVM()
    @Environment(AuthenticationVM.self) var authVM
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileHeader
                statsGrid
                postsSection
            }
            .padding(.bottom, 100)
        }
        .background(Color.backgroundBase)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: SettingsView().environment(authVM)) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color.textPrimary)
                }
            }
        }
        .onAppear {
            if let userID = authVM.currentUser?.userId {
                profileVM.fetchUserPosts(userID: userID)
            }
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.betaBlue, Color.betaBlue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                if let user = authVM.currentUser {
                    Text(user.username.prefix(1).uppercased())
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(Color.white)
                }
            }
            .shadow(color: Color.betaBlue.opacity(0.3), radius: 10, x: 0, y: 4)
            
            if let user = authVM.currentUser {
                VStack(spacing: 6) {
                    Text(user.username)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                    
                    Text(user.email)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color.textSecondary)
                }
            }
            
            Button {
                authVM.signOut()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Sign Out")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(Color.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color.red.opacity(0.9), Color.red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
        .padding(.top, 20)
        .padding(.bottom, 8)
    }
    
    // MARK: - Stats Grid
    
    private var statsGrid: some View {
        HStack(spacing: 0) {
            ProfileStatItem(
                value: "\(profileVM.posts.count)",
                label: "Posts",
                icon: "doc.text.fill",
                color: Color.sendOrange
            )
            
            Divider()
                .frame(height: 50)
                .background(Color.textSecondary.opacity(0.2))
            
            ProfileStatItem(
                value: "\(authVM.currentUser?.friends.count ?? 0)",
                label: "Friends",
                icon: "person.2.fill",
                color: Color.betaBlue
            )
            
            Divider()
                .frame(height: 50)
                .background(Color.textSecondary.opacity(0.2))
            
            ProfileStatItem(
                value: "\(authVM.currentUser?.myStats.numClimbs ?? 0)",
                label: "Climbs",
                icon: "figure.climbing",
                color: Color.green
            )
        }
        .padding(.vertical, 16)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Posts Section
    
    private var postsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("My Climbs")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                
                Spacer()
                
                Text("\(profileVM.posts.count) total")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color.textSecondary)
            }
            .padding(.horizontal, 16)
            
            if profileVM.isLoading {
                loadingView
            } else if let errorMessage = profileVM.errorMessage {
                errorView(message: errorMessage)
            } else if profileVM.posts.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(profileVM.posts) { post in
                        ProfilePostCard(
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
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(Color.betaBlue)
            
            Text("Loading your posts...")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Error View
    
    @ViewBuilder
    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundColor(Color.sendOrange)
            
            Text(message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color.red)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.betaBlue.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "figure.climbing")
                    .font(.system(size: 36))
                    .foregroundColor(Color.betaBlue)
            }
            
            VStack(spacing: 6) {
                Text("No Climbs Yet")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                
                Text("Start sharing your climbing sessions!")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Profile Stat Item

struct ProfileStatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color.textPrimary)
            
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Profile Post Card

struct ProfilePostCard: View {
    let post: PostModel
    let onDelete: () -> Void
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                    Text(formatDate(post.date))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                }
                .foregroundColor(Color.textSecondary)
                
                Spacer()
                
                Menu {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete Post", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18))
                        .foregroundColor(Color.textSecondary)
                        .padding(8)
                }
            }
            
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "mountain.2.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color.betaBlue)
                    
                    Text(post.grade.rawValue.uppercased())
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                }
                
                Text("•")
                    .foregroundColor(Color.textSecondary)
                
                HStack(spacing: 4) {
                    Text("\(post.attempts)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.sendOrange)
                    Text(post.attempts == 1 ? "attempt" : "attempts")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color.textSecondary)
                }
                
                if post.attempts == 1 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                        Text("Flash!")
                    }
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.sendOrange)
                    .clipShape(Capsule())
                }
                
                Spacer()
            }
            
            HStack(spacing: 6) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color.sendOrange)
                
                Text("\(post.gymName), \(post.location)")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color.textSecondary)
                    .lineLimit(1)
            }
            
            if !post.notes.isEmpty {
                Text(post.notes)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                    .lineLimit(2)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .confirmationDialog(
            "Delete this post?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    private func formatDate(_ postDate: PostDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        var components = DateComponents()
        components.year = postDate.year
        components.month = postDate.month
        components.day = postDate.day
        
        if let date = Calendar.current.date(from: components) {
            return dateFormatter.string(from: date)
        }
        return postDate.toString()
    }
}

// MARK: - Preview

#Preview("ProfileView") {
    NavigationStack {
        ProfileView()
            .environment(AuthenticationVM())
    }
}

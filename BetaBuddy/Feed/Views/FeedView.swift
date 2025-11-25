//
//  FeedView.swift
//  BetaBuddy
//
//  Legacy Feed View - Now uses ClimbCard components
//

import SwiftUI

struct FeedView: View {
    @State private var feedVM = FeedVM()
    @Environment(AuthenticationVM.self) var authVM
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                
                if feedVM.isLoading {
                    loadingView
                } else if let errorMessage = feedVM.errorMessage {
                    errorView(message: errorMessage)
                } else if feedVM.posts.isEmpty {
                    emptyStateView
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(feedVM.posts) { post in
                            ClimbCard(post: post)
                        }
                    }
                }
            }
            .padding(.bottom, 16)
        }
        .background(Color.backgroundBase)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Image(systemName: "figure.climbing")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.betaBlue)
                    
                    Text("BetaBuddy")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                }
            }
        }
        .onAppear {
            loadFeed()
        }
        .onChange(of: authVM.currentUser?.friends) { _, newValue in
            if let currentUserID = authVM.currentUser?.userId,
               let friends = newValue {
                feedVM.updateFriends(friends)
                feedVM.fetchAllPosts(currentUserID: currentUserID, friends: friends)
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let user = authVM.currentUser {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back,")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(Color.textSecondary)
                    
                    Text(user.username)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                }
            }
            
            activitySummaryCard
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
    
    // MARK: - Activity Summary Card
    
    private var activitySummaryCard: some View {
        HStack(spacing: 0) {
            SummaryStatItem(
                icon: "flame.fill",
                value: "\(authVM.currentUser?.myStats.numClimbs ?? 0)",
                label: "Climbs",
                color: Color.sendOrange
            )
            
            Divider()
                .frame(height: 44)
                .background(Color.betaBlue.opacity(0.2))
            
            SummaryStatItem(
                icon: "person.2.fill",
                value: "\(authVM.currentUser?.friends.count ?? 0)",
                label: "Friends",
                color: Color.betaBlue
            )
            
            Divider()
                .frame(height: 44)
                .background(Color.betaBlue.opacity(0.2))
            
            SummaryStatItem(
                icon: "star.fill",
                value: "Active",
                label: "Status",
                color: Color.green
            )
        }
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [Color.betaBlue.opacity(0.06), Color.cruxNavy.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.betaBlue.opacity(0.15), lineWidth: 1)
        )
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(Color.betaBlue)
            
            Text("Loading posts...")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
    
    // MARK: - Error View
    
    @ViewBuilder
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(Color.sendOrange)
            
            Text(message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color.red)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                loadFeed()
            }
            .buttonStyle(.secondary)
        }
        .padding()
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.betaBlue.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "figure.climbing")
                    .font(.system(size: 44))
                    .foregroundColor(Color.betaBlue)
            }
            
            VStack(spacing: 8) {
                Text("No Posts Yet")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                
                Text("Be the first to share a climb!\nAdd friends to see their activity.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
    
    // MARK: - Helper Methods
    
    private func loadFeed() {
        print("FeedView onAppear - Current user: \(authVM.currentUser?.username ?? "nil")")
        print("FeedView onAppear - Friends count: \(authVM.currentUser?.friends.count ?? 0)")
        
        if let currentUserID = authVM.currentUser?.userId,
           let friends = authVM.currentUser?.friends {
            feedVM.fetchAllPosts(currentUserID: currentUserID, friends: friends)
            feedVM.getLivePostChanges(currentUserID: currentUserID, friends: friends)
        }
    }
}

// MARK: - Summary Stat Item

struct SummaryStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Color.textPrimary)
            
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview("FeedView") {
    NavigationStack {
        FeedView()
            .environment(AuthenticationVM())
    }
}

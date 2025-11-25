//
//  MainTabView.swift
//  BetaBuddy
//
//  Main navigation container with custom floating tab bar
//

import SwiftUI

struct MainTabView: View {
    @Environment(AuthenticationVM.self) var authVM
    @State private var selectedTab = 0
    @State private var showRecordSheet = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.backgroundBase
                .ignoresSafeArea()
            
            Group {
                switch selectedTab {
                case 0:
                    NavigationStack {
                        HomeFeedView()
                            .environment(authVM)
                    }
                case 1:
                    NavigationStack {
                        SearchUsersView()
                            .environment(authVM)
                    }
                case 3:
                    NavigationStack {
                        AnalyticsPlaceholderView()
                            .environment(authVM)
                    }
                case 4:
                    NavigationStack {
                        ProfileView()
                            .environment(authVM)
                    }
                default:
                    NavigationStack {
                        HomeFeedView()
                            .environment(authVM)
                    }
                }
            }
            .padding(.bottom, 70)
            
            CustomTabBar(selectedTab: $selectedTab) {
                showRecordSheet = true
            }
            .ignoresSafeArea(.keyboard)
        }
        .sheet(isPresented: $showRecordSheet) {
            NavigationStack {
                CreatePostView(selectedTab: $selectedTab)
                    .environment(authVM)
            }
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Home Feed View

struct HomeFeedView: View {
    @State private var feedVM = FeedVM()
    @Environment(AuthenticationVM.self) var authVM
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                feedContent
            }
        }
        .background(Color.backgroundBase)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Image(systemName: "figure.climbing")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.betaBlue)
                    
                    Text("BetaBuddy")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Notifications
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color.textPrimary)
                        
                        Circle()
                            .fill(Color.sendOrange)
                            .frame(width: 8, height: 8)
                            .offset(x: 2, y: -2)
                    }
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
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(Color.textSecondary)
                    
                    Text(user.username)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                }
            }
            
            quickStatsCard
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    // MARK: - Quick Stats Card
    
    private var quickStatsCard: some View {
        HStack(spacing: 0) {
            QuickStatItem(
                icon: "flame.fill",
                value: "\(authVM.currentUser?.myStats.numClimbs ?? 0)",
                label: "Total Climbs",
                color: Color.sendOrange
            )
            
            Divider()
                .frame(height: 50)
                .background(Color.betaBlue.opacity(0.3))
            
            QuickStatItem(
                icon: "person.2.fill",
                value: "\(authVM.currentUser?.friends.count ?? 0)",
                label: "Friends",
                color: Color.betaBlue
            )
            
            Divider()
                .frame(height: 50)
                .background(Color.betaBlue.opacity(0.3))
            
            QuickStatItem(
                icon: "calendar",
                value: "Active",
                label: "This Week",
                color: Color.green
            )
        }
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [Color.betaBlue.opacity(0.08), Color.cruxNavy.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.betaBlue.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Feed Content
    
    private var feedContent: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Activity Feed")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                
                Spacer()
                
                Button {
                    loadFeed()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.betaBlue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            
            if feedVM.isLoading {
                loadingView
            } else if feedVM.posts.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(feedVM.posts) { post in
                        ClimbCard(post: post)
                    }
                }
            }
            
            if let errorMessage = feedVM.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color.red)
                    .padding()
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(Color.betaBlue)
            
            Text("Loading your feed...")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color.textSecondary)
        }
        .padding(.top, 60)
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
                Text("No Climbs Yet!")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                
                Text("Start your climbing journey by recording\nyour first send or add some friends!")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                // Navigate to record
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Record a Climb")
                }
            }
            .buttonStyle(.primary)
            .padding(.top, 8)
        }
        .padding(.horizontal, 32)
        .padding(.top, 40)
    }
    
    // MARK: - Helper Methods
    
    private func loadFeed() {
        if let currentUserID = authVM.currentUser?.userId,
           let friends = authVM.currentUser?.friends {
            feedVM.fetchAllPosts(currentUserID: currentUserID, friends: friends)
            feedVM.getLivePostChanges(currentUserID: currentUserID, friends: friends)
        }
    }
}

// MARK: - Quick Stat Item

struct QuickStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color.textPrimary)
            
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Analytics Placeholder View

struct AnalyticsPlaceholderView: View {
    @Environment(AuthenticationVM.self) var authVM
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.betaBlue.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Color.betaBlue)
            }
            
            VStack(spacing: 8) {
                Text("Analytics Coming Soon")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                
                Text("Track your climbing progress with\ndetailed stats and insights")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.backgroundBase)
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Preview

#Preview("MainTabView") {
    MainTabView()
        .environment(AuthenticationVM())
}

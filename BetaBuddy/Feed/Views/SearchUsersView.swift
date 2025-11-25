//
//  SearchUsersView.swift
//  BetaBuddy
//
//  Explore & Friends - Find climbing buddies
//

import SwiftUI

struct SearchUsersView: View {
    
    @State private var feedVM = FeedVM()
    @Environment(AuthenticationVM.self) var authVM
    @State private var searchText = ""
    
    // MARK: - Filtered Lists
    
    private func matchesSearch(_ userID: String) -> Bool {
        if searchText.isEmpty { return true }
        let username = feedVM.userMap[userID]?.lowercased() ?? ""
        return username.contains(searchText.lowercased())
    }
    
    private var filteredFriends: [String] {
        (authVM.currentUser?.friends ?? []).filter { matchesSearch($0) }
    }
    
    private var filteredReceivedRequests: [String] {
        (authVM.currentUser?.receivedFriendRequests ?? []).filter { matchesSearch($0) }
    }
    
    private var filteredSentRequests: [String] {
        (authVM.currentUser?.sentFriendRequests ?? []).filter { matchesSearch($0) }
    }
    
    private var availableUsers: [String] {
        let friends = authVM.currentUser?.friends ?? []
        let sentRequests = authVM.currentUser?.sentFriendRequests ?? []
        let receivedRequests = authVM.currentUser?.receivedFriendRequests ?? []
        
        return feedVM.users.filter { userID in
            !friends.contains(userID) &&
            !sentRequests.contains(userID) &&
            !receivedRequests.contains(userID) &&
            matchesSearch(userID)
        }
    }
    
    private var hasNoResults: Bool {
        !searchText.isEmpty &&
        filteredFriends.isEmpty &&
        filteredReceivedRequests.isEmpty &&
        filteredSentRequests.isEmpty &&
        availableUsers.isEmpty
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Stats Header
                statsHeader
                
                if hasNoResults {
                    emptySearchState
                } else {
                    // Friend Requests (priority)
                    if !filteredReceivedRequests.isEmpty {
                        sectionView(
                            title: "Friend Requests",
                            icon: "bell.badge.fill",
                            iconColor: Color.sendOrange,
                            badge: filteredReceivedRequests.count
                        ) {
                            ForEach(filteredReceivedRequests, id: \.self) { requestID in
                                FriendRequestCard(
                                    userID: requestID,
                                    username: feedVM.userMap[requestID] ?? "Unknown",
                                    onAccept: { acceptRequest(requestID) },
                                    onReject: { rejectRequest(requestID) }
                                )
                            }
                        }
                    }
                    
                    // Friends
                    if !filteredFriends.isEmpty {
                        sectionView(
                            title: "Friends",
                            icon: "person.2.fill",
                            iconColor: Color.betaBlue
                        ) {
                            ForEach(filteredFriends, id: \.self) { friendID in
                                FriendCard(
                                    userID: friendID,
                                    username: feedVM.userMap[friendID] ?? "Unknown",
                                    onRemove: { removeFriend(friendID) }
                                )
                            }
                        }
                    }
                    
                    // Pending Requests
                    if !filteredSentRequests.isEmpty {
                        sectionView(
                            title: "Pending",
                            icon: "clock.fill",
                            iconColor: Color.textSecondary
                        ) {
                            ForEach(filteredSentRequests, id: \.self) { requestID in
                                PendingRequestCard(
                                    userID: requestID,
                                    username: feedVM.userMap[requestID] ?? "Unknown",
                                    onCancel: { cancelRequest(requestID) }
                                )
                            }
                        }
                    }
                    
                    // Discover New Climbers
                    if !availableUsers.isEmpty {
                        sectionView(
                            title: "Discover Climbers",
                            icon: "figure.climbing",
                            iconColor: Color.cruxNavy
                        ) {
                            ForEach(availableUsers, id: \.self) { userID in
                                DiscoverUserCard(
                                    userID: userID,
                                    username: feedVM.userMap[userID] ?? "Unknown",
                                    onSendRequest: { sendRequest(userID) }
                                )
                            }
                        }
                    }
                }
                
                Spacer(minLength: 100)
            }
        }
        .background(Color.backgroundBase)
        .navigationTitle("Explore")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            feedVM.fetchAllUsers(excludeUserID: authVM.currentUser?.userId)
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color.textSecondary)
            
            TextField("Search climbers...", text: $searchText)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Color.textPrimary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    // MARK: - Stats Header
    
    private var statsHeader: some View {
        HStack(spacing: 0) {
            ExploreStatItem(
                value: "\(authVM.currentUser?.friends.count ?? 0)",
                label: "Friends",
                icon: "person.2.fill",
                color: Color.betaBlue
            )
            
            Divider()
                .frame(height: 40)
                .background(Color.textSecondary.opacity(0.2))
            
            ExploreStatItem(
                value: "\(authVM.currentUser?.receivedFriendRequests.count ?? 0)",
                label: "Requests",
                icon: "bell.badge.fill",
                color: Color.sendOrange
            )
            
            Divider()
                .frame(height: 40)
                .background(Color.textSecondary.opacity(0.2))
            
            ExploreStatItem(
                value: "\(feedVM.users.count)",
                label: "Climbers",
                icon: "figure.climbing",
                color: Color.cruxNavy
            )
        }
        .padding(.vertical, 14)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
    
    // MARK: - Section View
    
    @ViewBuilder
    private func sectionView<Content: View>(
        title: String,
        icon: String,
        iconColor: Color,
        badge: Int? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                
                if let badge = badge, badge > 0 {
                    Text("\(badge)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(iconColor)
                        .clipShape(Capsule())
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // Content
            VStack(spacing: 8) {
                content()
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Empty Search State
    
    private var emptySearchState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.betaBlue.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 32))
                    .foregroundColor(Color.betaBlue)
            }
            
            VStack(spacing: 6) {
                Text("No Climbers Found")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                
                Text("Try a different search term")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
    
    // MARK: - Actions
    
    private func acceptRequest(_ userID: String) {
        guard let currentUserID = authVM.currentUser?.userId else { return }
        feedVM.acceptFriendRequest(currentUserID: currentUserID, otherUserID: userID)
        authVM.currentUser?.receivedFriendRequests.removeAll { $0 == userID }
        if authVM.currentUser?.friends.contains(userID) == false {
            authVM.currentUser?.friends.append(userID)
        }
    }
    
    private func rejectRequest(_ userID: String) {
        guard let currentUserID = authVM.currentUser?.userId else { return }
        feedVM.rejectFriendRequest(currentUserID: currentUserID, otherUserID: userID)
        authVM.currentUser?.receivedFriendRequests.removeAll { $0 == userID }
    }
    
    private func removeFriend(_ userID: String) {
        guard let currentUserID = authVM.currentUser?.userId else { return }
        feedVM.unfriend(currentUserID: currentUserID, otherUserID: userID)
        authVM.currentUser?.friends.removeAll { $0 == userID }
    }
    
    private func cancelRequest(_ userID: String) {
        guard let currentUserID = authVM.currentUser?.userId else { return }
        feedVM.cancelFriendRequest(currentUserID: currentUserID, otherUserID: userID)
        authVM.currentUser?.sentFriendRequests.removeAll { $0 == userID }
    }
    
    private func sendRequest(_ userID: String) {
        guard let currentUserID = authVM.currentUser?.userId else { return }
        feedVM.sendFriendRequest(currentUserID: currentUserID, otherUserID: userID)
        if authVM.currentUser?.sentFriendRequests.contains(userID) == false {
            authVM.currentUser?.sentFriendRequests.append(userID)
        }
    }
}

// MARK: - Explore Stat Item

struct ExploreStatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color.textPrimary)
            
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Friend Request Card

struct FriendRequestCard: View {
    let userID: String
    let username: String
    let onAccept: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            UserAvatarView(username: username, size: 44, color: Color.sendOrange)
            
            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(username)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                
                Text("Wants to be friends")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(Color.textSecondary)
            }
            
            Spacer()
            
            // Accept Button
            Button(action: onAccept) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color.green)
            }
            
            // Reject Button
            Button(action: onReject) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color.red.opacity(0.7))
            }
        }
        .padding(12)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.sendOrange.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Friend Card

struct FriendCard: View {
    let userID: String
    let username: String
    let onRemove: () -> Void
    @State private var showRemoveConfirm = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            UserAvatarView(username: username, size: 44, color: Color.betaBlue)
            
            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(username)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color.betaBlue)
                    Text("Climbing Buddy")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(Color.textSecondary)
                }
            }
            
            Spacer()
            
            // Remove Button
            Menu {
                Button(role: .destructive) {
                    onRemove()
                } label: {
                    Label("Remove Friend", systemImage: "person.badge.minus")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.textSecondary)
                    .padding(8)
            }
        }
        .padding(12)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Pending Request Card

struct PendingRequestCard: View {
    let userID: String
    let username: String
    let onCancel: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            UserAvatarView(username: username, size: 44, color: Color.textSecondary)
            
            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(username)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                    Text("Request pending")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                }
                .foregroundColor(Color.textSecondary)
            }
            
            Spacer()
            
            // Cancel Button
            Button(action: onCancel) {
                Text("Cancel")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.textSecondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.textSecondary.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(12)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Discover User Card

struct DiscoverUserCard: View {
    let userID: String
    let username: String
    let onSendRequest: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            UserAvatarView(username: username, size: 44, color: Color.cruxNavy)
            
            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(username)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                
                Text("Climber")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(Color.textSecondary)
            }
            
            Spacer()
            
            // Add Friend Button
            Button(action: onSendRequest) {
                HStack(spacing: 6) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Add")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .foregroundColor(Color.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.betaBlue)
                .clipShape(Capsule())
            }
        }
        .padding(12)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

// MARK: - User Avatar View

struct UserAvatarView: View {
    let username: String
    var size: CGFloat = 44
    var color: Color = Color.betaBlue
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            Text(username.prefix(1).uppercased())
                .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                .foregroundColor(Color.white)
        }
    }
}

// MARK: - Preview

#Preview("Explore") {
    NavigationStack {
        SearchUsersView()
            .environment(AuthenticationVM())
    }
}

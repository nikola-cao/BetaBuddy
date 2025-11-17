//
//  SearchUsersView.swift
//  BetaBuddy
//
//  Created by Nikola Cao on 11/9/25.
//

import SwiftUI

struct SearchUsersView: View {
    
    @State private var feedVM = FeedVM()
    @Environment(AuthenticationVM.self) var authVM
    @State private var searchText = ""
    
    // Helper function to filter users by search text
    private func matchesSearch(_ userID: String) -> Bool {
        if searchText.isEmpty {
            return true
        }
        let username = feedVM.userMap[userID]?.lowercased() ?? ""
        return username.contains(searchText.lowercased())
    }
    
    // Computed property to get filtered friends
    private var filteredFriends: [String] {
        let friends = authVM.currentUser?.friends ?? []
        return friends.filter { matchesSearch($0) }
    }
    
    // Computed property to get filtered received requests
    private var filteredReceivedRequests: [String] {
        let receivedRequests = authVM.currentUser?.receivedFriendRequests ?? []
        return receivedRequests.filter { matchesSearch($0) }
    }
    
    // Computed property to get filtered sent requests
    private var filteredSentRequests: [String] {
        let sentRequests = authVM.currentUser?.sentFriendRequests ?? []
        return sentRequests.filter { matchesSearch($0) }
    }
    
    // Computed property to get available users (excluding friends and pending requests)
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
    
    var body: some View {
        List {
            // Show empty state if searching and no results
            if !searchText.isEmpty && 
               filteredFriends.isEmpty && 
               filteredReceivedRequests.isEmpty && 
               filteredSentRequests.isEmpty && 
               availableUsers.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No users found")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Try a different search term")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
                .listRowBackground(Color.clear)
            }
            
            // Friends section
            if !filteredFriends.isEmpty {
                Section("Friends") {
                    ForEach(filteredFriends, id: \.self) { friendID in
                        HStack {
                            Text(feedVM.userMap[friendID] ?? "Unknown")
                            Spacer()
                            
                            Button(action: {
                                guard let currentUserID = authVM.currentUser?.userId else { return }
                                feedVM.unfriend(currentUserID: currentUserID, otherUserID: friendID)
                                // Update local state
                                authVM.currentUser?.friends.removeAll { $0 == friendID }
                            }) {
                                Label("Remove Friend", systemImage: "person.fill.xmark")
                                    .labelStyle(.iconOnly)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            
            // Received friend requests section
            if !filteredReceivedRequests.isEmpty {
                Section("Friend Requests") {
                    ForEach(filteredReceivedRequests, id: \.self) { requestID in
                        HStack {
                            Text(feedVM.userMap[requestID] ?? "Unknown")
                            Spacer()
                            
                            // Accept button
                            Button(action: {
                                guard let currentUserID = authVM.currentUser?.userId else { return }
                                feedVM.acceptFriendRequest(currentUserID: currentUserID, otherUserID: requestID)
                                // Update local state
                                authVM.currentUser?.receivedFriendRequests.removeAll { $0 == requestID }
                                if authVM.currentUser?.friends.contains(requestID) == false {
                                    authVM.currentUser?.friends.append(requestID)
                                }
                            }) {
                                Label("Accept", systemImage: "checkmark.circle")
                                    .labelStyle(.iconOnly)
                                    .foregroundColor(.green)
                            }
                            
                            // Reject button
                            Button(action: {
                                guard let currentUserID = authVM.currentUser?.userId else { return }
                                feedVM.rejectFriendRequest(currentUserID: currentUserID, otherUserID: requestID)
                                // Update local state
                                authVM.currentUser?.receivedFriendRequests.removeAll { $0 == requestID }
                            }) {
                                Label("Reject", systemImage: "xmark.circle")
                                    .labelStyle(.iconOnly)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            
            // Sent friend requests section
            if !filteredSentRequests.isEmpty {
                Section("Pending Requests") {
                    ForEach(filteredSentRequests, id: \.self) { requestID in
                        HStack {
                            Text(feedVM.userMap[requestID] ?? "Unknown")
                            Spacer()
                            
                            Button(action: {
                                guard let currentUserID = authVM.currentUser?.userId else { return }
                                feedVM.cancelFriendRequest(currentUserID: currentUserID, otherUserID: requestID)
                                // Update local state
                                authVM.currentUser?.sentFriendRequests.removeAll { $0 == requestID }
                            }) {
                                Label("Cancel Request", systemImage: "clock.badge.xmark")
                                    .labelStyle(.iconOnly)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
            }
            
            // Available users section
            Section("Other Users") {
                ForEach(availableUsers, id: \.self) { userID in
                    HStack {
                        Text(feedVM.userMap[userID] ?? "Unknown")
                        Spacer()
                        
                        Button(action: {
                            guard let currentUserID = authVM.currentUser?.userId else { return }
                            feedVM.sendFriendRequest(currentUserID: currentUserID, otherUserID: userID)
                            // Update local state
                            if authVM.currentUser?.sentFriendRequests.contains(userID) == false {
                                authVM.currentUser?.sentFriendRequests.append(userID)
                            }
                        }) {
                            Label("Send Friend Request", systemImage: "person.crop.circle.badge.plus")
                                .labelStyle(.iconOnly)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .onAppear {
            feedVM.fetchAllUsers(excludeUserID: authVM.currentUser?.userId)
        }
        .navigationTitle("Friends")
        .searchable(text: $searchText, prompt: "Search users...")
    }
}

#Preview {
    SearchUsersView()
        .environment(AuthenticationVM())
        .environment(FeedVM())
}

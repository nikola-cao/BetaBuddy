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
    
    // Computed property to get available users (excluding friends and pending requests)
    private var availableUsers: [String] {
        let friends = authVM.currentUser?.friends ?? []
        let sentRequests = authVM.currentUser?.sentFriendRequests ?? []
        let receivedRequests = authVM.currentUser?.receivedFriendRequests ?? []
        
        return feedVM.users.filter { userID in
            !friends.contains(userID) &&
            !sentRequests.contains(userID) &&
            !receivedRequests.contains(userID)
        }
    }
    
    var body: some View {
        List {
            // Friends section
            if !(authVM.currentUser?.friends ?? []).isEmpty {
                Section("Friends") {
                    ForEach(authVM.currentUser?.friends ?? [], id: \.self) { friendID in
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
            if !(authVM.currentUser?.receivedFriendRequests ?? []).isEmpty {
                Section("Friend Requests") {
                    ForEach(authVM.currentUser?.receivedFriendRequests ?? [], id: \.self) { requestID in
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
            if !(authVM.currentUser?.sentFriendRequests ?? []).isEmpty {
                Section("Pending Requests") {
                    ForEach(authVM.currentUser?.sentFriendRequests ?? [], id: \.self) { requestID in
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
    }
}

#Preview {
    SearchUsersView()
        .environment(AuthenticationVM())
        .environment(FeedVM())
}

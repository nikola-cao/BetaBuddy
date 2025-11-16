//
//  MainTabView.swift
//  BetaBuddy
//
//  Created by Nikola Cao on 11/16/25.
//

import SwiftUI

struct MainTabView: View {
    @Environment(AuthenticationVM.self) var authVM
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Feed Tab
            NavigationStack {
                FeedView()
                    .environment(authVM)
            }
            .tabItem {
                Label("Feed", systemImage: "house.fill")
            }
            .tag(0)
            
            // Create Post Tab - resets when you navigate away
            NavigationStack {
                CreatePostView(selectedTab: $selectedTab)
                    .environment(authVM)
            }
            .tabItem {
                Label("Create", systemImage: "plus.circle.fill")
            }
            .tag(1)
            .id(selectedTab == 1 ? UUID() : nil) // Reset view when switching away and back
            
            // Search Users Tab
            NavigationStack {
                SearchUsersView()
                    .environment(authVM)
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(2)
            
            // Profile Tab (placeholder - you can expand this later)
            ProfileTabView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
    }
}

// Placeholder Profile View - you can expand this later
struct ProfileTabView: View {
    @Environment(AuthenticationVM.self) var authVM
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let user = authVM.currentUser {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text(user.username)
                        .font(.title)
                        .bold()
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("Sign Out") {
                        authVM.signOut()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    MainTabView()
        .environment(AuthenticationVM())
}

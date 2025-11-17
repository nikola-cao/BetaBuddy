//
//  SettingsView.swift
//  BetaBuddy
//
//  Created by Sarvesh Gade on 11/16/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AuthenticationVM.self) var authVM
    @State private var showDeleteConfirmation = false
    @State private var isDeleting = false
    
    var body: some View {
        List {
            Section {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    HStack {
                        Label("Delete Account", systemImage: "trash")
                        Spacer()
                        if isDeleting {
                            ProgressView()
                        }
                    }
                }
                .disabled(isDeleting)
            } header: {
                Text("Danger Zone")
            } footer: {
                Text("Deleting your account will permanently remove all your data, including posts, friends, and statistics. This action cannot be undone.")
                    .font(.caption)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Delete My Account", role: .destructive) {
                Task {
                    isDeleting = true
                    await authVM.deleteAccount()
                    isDeleting = false
                    // No dismiss() needed - app automatically shows login when currentUser becomes nil
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to permanently delete your account? All your posts, friends, and data will be lost forever. This action cannot be undone.")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(AuthenticationVM())
    }
}


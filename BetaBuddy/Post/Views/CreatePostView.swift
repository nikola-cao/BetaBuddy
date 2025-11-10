//
//  CreatePost.swift
//  BetaBuddy
//
//  Created by Nikola Cao on 11/8/25.
//

import SwiftUI

struct CreatePostView: View {
    // State variables for form inputs
    @State private var grade: Grades = .v4tov6
    @State private var attempts: String = ""
    @State private var gymName: String = ""
    @State private var location: String = ""
    @State private var notes: String = ""
    
    // Date components
    @State private var selectedDate: Date = Date()
    
    @State private var navigateToFeed = false
    
    @Environment(AuthenticationVM.self) var authVM
    @State private var createPostVM = CreatePostVM()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Preview Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preview")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                    
                    // Live preview of the post
                    PostView(post: createPreviewPost())
                }
                
                Divider()
                    .padding(.horizontal, 16)
                
                // Form Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Post Details")
                        .font(.headline)
                        .padding(.horizontal, 16)
                    
                    VStack(spacing: 16) {
                        // Grade Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Grade")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Picker("Grade", selection: $grade) {
                                ForEach(Grades.allCases, id: \.self) { grade in
                                    Text(grade.rawValue).tag(grade)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // Attempts TextField
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Attempts")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Number of attempts", text: $attempts)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        // Gym Name TextField
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Gym Name")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Enter gym name", text: $gymName)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        // Location TextField
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Location")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("City or area", text: $location)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        // Date Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        // Notes TextEditor
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextEditor(text: $notes)
                                .frame(height: 120)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Post Button
                Button(action: {
                    // Action placeholder - to be implemented later
                    print("Post button tapped")
                    if authVM.currentUser == nil {
                        print("Couldn't get current user")
                    } else {
                        createPostVM.addNewPost(post: createPreviewPost())
                        navigateToFeed = true
                    }
                    
                }) {
                    Text("Post")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .padding(.top, 16)
        }
        .navigationTitle("Create Post")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(isPresented: $navigateToFeed) {
            FeedView()
                .environment(authVM)
        }
    }
    
    // Helper function to create preview post
    private func createPreviewPost() -> PostModel {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let postDate = PostDate(
            year: components.year ?? 2025,
            month: components.month ?? 1,
            day: components.day ?? 1
        )
        
        return PostModel(
            postID: UUID().uuidString,
            userID: authVM.currentUser?.userId ?? "",
            username: authVM.currentUser?.username ?? "",
            attempts: Int(attempts) ?? 0,
            date: postDate,
            grade: grade,
            gymName: gymName.isEmpty ? "Gym Name" : gymName,
            location: location.isEmpty ? "Location" : location,
            notes: notes.isEmpty ? "" : notes
        )
    }
}

#Preview {
    NavigationStack {
        CreatePostView()
            .environment(AuthenticationVM())
    }
}

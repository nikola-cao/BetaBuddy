//
//  PostView.swift
//  BetaBuddy
//
//  Created by Nikola Cao on 11/8/25.
//

import SwiftUI

struct PostView: View {
    let post: PostModel  // Pass in the post data
    
    var body: some View {
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
                
                // Climb details (styled like form but not editable)
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
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

#Preview {
    PostView(post: PostModel(postID: "123", userID: "123", username: "John Doe", attempts: 5, date: PostDate(year: 2025,month: 1,day: 1), grade: Grades.v4tov6, gymName: "CRG", location: "Atlanta", notes: "Great climb!"))
}

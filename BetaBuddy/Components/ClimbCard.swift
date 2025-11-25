//
//  ClimbCard.swift
//  BetaBuddy
//
//  A reusable Strava-style activity card for climbing entries
//

import SwiftUI

struct ClimbCard: View {
    let post: PostModel
    
    @State private var isLiked: Bool = false
    @State private var likeCount: Int = 0
    
    // MARK: - Constants
    
    private enum Layout {
        static let cardPadding: CGFloat = 16
        static let avatarSize: CGFloat = 44
        static let cornerRadius: CGFloat = 16
        static let imageHeight: CGFloat = 180
        static let iconSize: CGFloat = 22
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            titleSection
            dataGridSection
            visualSection
            
            if !post.notes.isEmpty {
                notesSection
            }
            
            footerSection
        }
        .padding(Layout.cardPadding)
        .cardStyle()
        .padding(.horizontal, Layout.cardPadding)
        .padding(.vertical, 8)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack(spacing: 12) {
            // User Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.betaBlue, Color.betaBlue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: Layout.avatarSize, height: Layout.avatarSize)
                
                Text(post.username.prefix(1).uppercased())
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white)
            }
            
            // Name & Timestamp
            VStack(alignment: .leading, spacing: 2) {
                Text(post.username)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                    Text(formatDate(post.date))
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                }
                .foregroundColor(Color.textSecondary)
            }
            
            Spacer()
            
            // Location Badge
            HStack(spacing: 4) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color.sendOrange)
                
                Text(post.location)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.sendOrange.opacity(0.1))
            .clipShape(Capsule())
        }
        .padding(.bottom, 12)
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(generateClimbTitle())
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color.textPrimary)
            
            Text("at \(post.gymName)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color.textSecondary)
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - Data Grid Section
    
    private var dataGridSection: some View {
        HStack(spacing: 0) {
            StatCell(
                icon: "mountain.2.fill",
                label: "Grade",
                value: post.grade.rawValue.uppercased(),
                iconColor: Color.betaBlue
            )
            
            Divider()
                .frame(height: 40)
                .background(Color.textSecondary.opacity(0.3))
            
            StatCell(
                icon: "arrow.counterclockwise",
                label: "Attempts",
                value: "\(post.attempts)",
                iconColor: Color.sendOrange
            )
            
            Divider()
                .frame(height: 40)
                .background(Color.textSecondary.opacity(0.3))
            
            StatCell(
                icon: post.attempts == 1 ? "flame.fill" : "checkmark.circle.fill",
                label: "Status",
                value: post.attempts == 1 ? "Flash!" : "Sent",
                iconColor: post.attempts == 1 ? Color.sendOrange : Color.green
            )
        }
        .padding(.vertical, 12)
        .background(Color.backgroundBase)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.bottom, 16)
    }
    
    // MARK: - Visual Section
    
    private var visualSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.betaBlue.opacity(0.15),
                            Color.cruxNavy.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 8) {
                Image(systemName: "figure.climbing")
                    .font(.system(size: 40))
                    .foregroundColor(Color.betaBlue.opacity(0.6))
                
                Text("Climbing Activity")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(Color.textSecondary)
            }
        }
        .frame(height: Layout.imageHeight)
        .padding(.bottom, 12)
    }
    
    // MARK: - Notes Section
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "text.quote")
                    .font(.system(size: 12))
                    .foregroundColor(Color.textSecondary)
                
                Text("Notes")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.textSecondary)
            }
            
            Text(post.notes)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(Color.textPrimary)
                .lineLimit(3)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundBase)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.bottom, 12)
    }
    
    // MARK: - Footer Section
    
    private var footerSection: some View {
        HStack(spacing: 0) {
            // Clap/Like Button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isLiked.toggle()
                    likeCount += isLiked ? 1 : -1
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isLiked ? "hands.clap.fill" : "hands.clap")
                        .font(.system(size: Layout.iconSize))
                        .foregroundColor(isLiked ? Color.sendOrange : Color.textSecondary)
                        .scaleEffect(isLiked ? 1.1 : 1.0)
                    
                    Text(likeCount > 0 ? "\(likeCount)" : "Clap")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(isLiked ? Color.sendOrange : Color.textSecondary)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Comment Button
            Button {
                // Comment action
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: Layout.iconSize - 2))
                    Text("Comment")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                }
                .foregroundColor(Color.textSecondary)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Share Button
            Button {
                // Share action
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: Layout.iconSize - 2))
                    Text("Share")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                }
                .foregroundColor(Color.textSecondary)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
    }
    
    // MARK: - Helper Methods
    
    private func generateClimbTitle() -> String {
        let timeOfDay = getTimeOfDay()
        let gradeEmoji = getGradeEmoji()
        return "\(timeOfDay) \(gradeEmoji) Session"
    }
    
    private func getTimeOfDay() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Morning"
        case 12..<17: return "Afternoon"
        case 17..<21: return "Evening"
        default: return "Night"
        }
    }
    
    private func getGradeEmoji() -> String {
        switch post.grade {
        case .vb, .v0tov1: return "Beginner"
        case .v1tov2, .v2tov4: return "Intermediate"
        case .v4tov6, .v6tov8: return "Advanced"
        case .v8tov10, .v10tov12, .v12plus: return "Elite"
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

// MARK: - Stat Cell Component

struct StatCell: View {
    let icon: String
    let label: String
    let value: String
    let iconColor: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Color.textPrimary)
            
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview("ClimbCard") {
    ScrollView {
        VStack(spacing: 0) {
            ClimbCard(
                post: PostModel(
                    postID: "1",
                    userID: "user1",
                    username: "Alex Honnold",
                    attempts: 1,
                    date: PostDate(year: 2025, month: 11, day: 24),
                    grade: .v6tov8,
                    gymName: "Red Rocks Climbing Center",
                    location: "Las Vegas, NV",
                    notes: "Finally sent this project! The crux move on the overhang was tricky but stuck it on the flash. 🔥"
                )
            )
            
            ClimbCard(
                post: PostModel(
                    postID: "2",
                    userID: "user2",
                    username: "Tommy Caldwell",
                    attempts: 5,
                    date: PostDate(year: 2025, month: 11, day: 23),
                    grade: .v4tov6,
                    gymName: "Movement Climbing",
                    location: "Denver, CO",
                    notes: ""
                )
            )
        }
    }
    .background(Color.backgroundBase)
}

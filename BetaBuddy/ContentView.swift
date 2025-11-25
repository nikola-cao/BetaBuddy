//
//  ContentView.swift
//  BetaBuddy
//
//  Main entry point with Design System showcase
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        DesignSystemShowcase()
    }
}

// MARK: - Design System Showcase

/// A demonstration view showcasing all design system components
struct DesignSystemShowcase: View {
    @State private var isLiked = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    colorsSection
                    typographySection
                    buttonsSection
                    cardSection
                    iconsSection
                }
                .padding(16)
            }
            .background(Color.backgroundBase)
            .navigationTitle("Design System")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Colors Section
    
    private var colorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Color Palette")
                .headingStyle(size: 22)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ColorSwatch(name: "Beta Blue", color: Color.betaBlue)
                ColorSwatch(name: "Crux Navy", color: Color.cruxNavy)
                ColorSwatch(name: "Send Orange", color: Color.sendOrange)
                ColorSwatch(name: "Background", color: Color.backgroundBase)
                ColorSwatch(name: "Surface", color: Color.surfaceCard)
                ColorSwatch(name: "Text Secondary", color: Color.textSecondary)
            }
        }
    }
    
    // MARK: - Typography Section
    
    private var typographySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Typography")
                .headingStyle(size: 22)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Heading Bold - 28pt")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                
                Text("Title Semibold - 20pt")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                
                Text("Body Regular - 16pt")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                
                Text("Caption - 13pt Secondary")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(Color.textSecondary)
            }
            .padding(16)
            .cardStyle()
        }
    }
    
    // MARK: - Buttons Section
    
    private var buttonsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Buttons")
                .headingStyle(size: 22)
            
            VStack(spacing: 12) {
                Button("Primary Action") { }
                    .buttonStyle(.primary)
                
                Button("Secondary Action") { }
                    .buttonStyle(.secondary)
            }
        }
    }
    
    // MARK: - Card Section
    
    private var cardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cards")
                .headingStyle(size: 22)
            
            ClimbCard(
                post: PostModel(
                    postID: "preview-1",
                    userID: "user1",
                    username: "Demo Climber",
                    attempts: 3,
                    date: PostDate(year: 2025, month: 11, day: 24),
                    grade: .v4tov6,
                    gymName: "BetaBuddy Gym",
                    location: "San Francisco",
                    notes: "Great session today! 🧗‍♂️"
                )
            )
            .padding(.horizontal, -16)
        }
    }
    
    // MARK: - Icons Section
    
    private var iconsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Icons")
                .headingStyle(size: 22)
            
            HStack(spacing: 24) {
                IconDemo(icon: "figure.climbing", label: "Climb")
                IconDemo(icon: "mountain.2.fill", label: "Grade")
                IconDemo(icon: "hands.clap.fill", label: "Clap")
                IconDemo(icon: "flame.fill", label: "Flash")
                IconDemo(icon: "chart.bar.fill", label: "Stats")
            }
            .padding(16)
            .cardStyle()
        }
    }
}

// MARK: - Supporting Views

struct ColorSwatch: View {
    let name: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(color)
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.cruxNavy.opacity(0.1), lineWidth: 1)
                )
            
            Text(name)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Color.textSecondary)
        }
    }
}

struct IconDemo: View {
    let icon: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color.betaBlue)
            
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(Color.textSecondary)
        }
    }
}

// MARK: - Preview

#Preview("Design System") {
    ContentView()
}

#Preview("Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}

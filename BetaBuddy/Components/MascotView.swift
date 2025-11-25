//
//  MascotView.swift
//  BetaBuddy
//
//  Reusable mascot component for branding
//

import SwiftUI

// MARK: - Mascot View

struct MascotView: View {
    var size: CGFloat = 150
    var showWall: Bool = true
    
    var body: some View {
        if showWall {
            // Try to load the mascot with wall image, fallback to SF Symbol
            Image("ClimberMascotWall")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            // Just the climber character
            Image("ClimberMascot")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
    }
}

// MARK: - Mascot Fallback View (SF Symbol version)

struct MascotFallbackView: View {
    var size: CGFloat = 150
    
    var body: some View {
        ZStack {
            // Orange climbing wall shape
            ClimbingWallShape()
                .fill(Color.sendOrange)
                .frame(width: size * 0.5, height: size * 0.7)
                .offset(x: size * 0.15)
            
            // Navy climber
            Image(systemName: "figure.climbing")
                .font(.system(size: size * 0.45, weight: .medium))
                .foregroundColor(Color.cruxNavy)
                .offset(x: -size * 0.05)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Climbing Wall Shape

struct ClimbingWallShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Trapezoid shape (wider at bottom)
        let topInset: CGFloat = rect.width * 0.15
        
        path.move(to: CGPoint(x: rect.minX + topInset, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topInset, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Animated Mascot View

struct AnimatedMascotView: View {
    var size: CGFloat = 150
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(Color.betaBlue.opacity(0.1))
                .frame(width: size * 1.2, height: size * 1.2)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
            
            // Try custom image first, then fallback
            Group {
                if UIImage(named: "ClimberMascotWall") != nil {
                    Image("ClimberMascotWall")
                        .resizable()
                        .scaledToFit()
                } else {
                    MascotFallbackView(size: size)
                }
            }
            .frame(width: size, height: size)
            .offset(y: isAnimating ? -5 : 5)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Logo Text View

struct LogoTextView: View {
    var fontSize: CGFloat = 36
    
    var body: some View {
        HStack(spacing: 0) {
            Text("beta")
                .font(.system(size: fontSize, weight: .medium, design: .rounded))
                .foregroundColor(Color.cruxNavy)
            
            Text("Buddy")
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundColor(Color.cruxNavy)
        }
    }
}

// MARK: - Full Logo View

struct FullLogoView: View {
    var mascotSize: CGFloat = 120
    var textSize: CGFloat = 32
    var spacing: CGFloat = 12
    
    var body: some View {
        VStack(spacing: spacing) {
            AnimatedMascotView(size: mascotSize)
            LogoTextView(fontSize: textSize)
        }
    }
}

// MARK: - Preview

#Preview("Mascot Views") {
    VStack(spacing: 40) {
        MascotFallbackView(size: 150)
        
        AnimatedMascotView(size: 150)
        
        FullLogoView()
    }
    .padding()
    .background(Color.backgroundBase)
}


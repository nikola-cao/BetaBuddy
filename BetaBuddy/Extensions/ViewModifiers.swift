//
//  ViewModifiers.swift
//  BetaBuddy
//
//  Design System - Reusable View Modifiers
//

import SwiftUI

// MARK: - Card Style Modifier

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// MARK: - Primary Button Style

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(Color.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color.sendOrange)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

// MARK: - Secondary Button Style

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(Color.betaBlue)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color.betaBlue.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

// MARK: - Typography Modifiers

struct HeadingStyle: ViewModifier {
    let size: CGFloat
    let weight: Font.Weight
    
    init(size: CGFloat = 28, weight: Font.Weight = .bold) {
        self.size = size
        self.weight = weight
    }
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: weight, design: .rounded))
            .foregroundColor(Color.textPrimary)
    }
}

struct BodyStyle: ViewModifier {
    let secondary: Bool
    
    init(secondary: Bool = false) {
        self.secondary = secondary
    }
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .foregroundColor(secondary ? Color.textSecondary : Color.textPrimary)
    }
}

struct CaptionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 13, weight: .regular, design: .rounded))
            .foregroundColor(Color.textSecondary)
    }
}

extension View {
    func headingStyle(size: CGFloat = 28, weight: Font.Weight = .bold) -> some View {
        modifier(HeadingStyle(size: size, weight: weight))
    }
    
    func bodyStyle(secondary: Bool = false) -> some View {
        modifier(BodyStyle(secondary: secondary))
    }
    
    func captionStyle() -> some View {
        modifier(CaptionStyle())
    }
}

// MARK: - Icon Modifier

struct IconStyle: ViewModifier {
    let size: CGFloat
    let color: Color
    
    init(size: CGFloat = 22, color: Color = Color.textSecondary) {
        self.size = size
        self.color = color
    }
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: .medium))
            .foregroundColor(color)
    }
}

extension View {
    func iconStyle(size: CGFloat = 22, color: Color = Color.textSecondary) -> some View {
        modifier(IconStyle(size: size, color: color))
    }
}

//
//  CustomTabBar.swift
//  BetaBuddy
//
//  A custom floating tab bar with centered Record button
//

import SwiftUI

// MARK: - Tab Items Enum

enum TabItem: Int, CaseIterable {
    case home = 0
    case explore = 1
    case record = 2
    case analytics = 3
    case profile = 4
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .explore: return "magnifyingglass"
        case .record: return "plus"
        case .analytics: return "chart.bar"
        case .profile: return "person"
        }
    }
    
    var filledIcon: String {
        switch self {
        case .home: return "house.fill"
        case .explore: return "magnifyingglass"
        case .record: return "plus"
        case .analytics: return "chart.bar.fill"
        case .profile: return "person.fill"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .explore: return "Explore"
        case .record: return "Record"
        case .analytics: return "Stats"
        case .profile: return "Profile"
        }
    }
}

// MARK: - Custom Tab Bar View

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let onRecordTap: () -> Void
    
    // MARK: - Constants
    
    private enum Layout {
        static let tabBarHeight: CGFloat = 70
        static let recordButtonSize: CGFloat = 60
        static let recordButtonOffset: CGFloat = -20
        static let iconSize: CGFloat = 24
        static let cornerRadius: CGFloat = 24
    }
    
    var body: some View {
        ZStack {
            // Tab Bar Background
            tabBarBackground
            
            // Tab Items
            HStack(spacing: 0) {
                ForEach(TabItem.allCases, id: \.rawValue) { tab in
                    if tab == .record {
                        recordButton
                    } else {
                        tabButton(for: tab)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(height: Layout.tabBarHeight + 20)
    }
    
    // MARK: - Tab Bar Background
    
    private var tabBarBackground: some View {
        VStack {
            Spacer()
            
            RoundedRectangle(cornerRadius: Layout.cornerRadius, style: .continuous)
                .fill(Color.cruxNavy)
                .frame(height: Layout.tabBarHeight)
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -5)
        }
    }
    
    // MARK: - Record Button
    
    private var recordButton: some View {
        Button {
            onRecordTap()
        } label: {
            ZStack {
                // Outer glow ring
                Circle()
                    .fill(Color.sendOrange.opacity(0.3))
                    .frame(width: Layout.recordButtonSize + 12, height: Layout.recordButtonSize + 12)
                
                // Main button
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.sendOrange, Color.sendOrange.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: Layout.recordButtonSize, height: Layout.recordButtonSize)
                    .shadow(color: Color.sendOrange.opacity(0.4), radius: 8, x: 0, y: 4)
                
                // Plus icon
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.white)
            }
            .offset(y: Layout.recordButtonOffset)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Tab Button
    
    @ViewBuilder
    private func tabButton(for tab: TabItem) -> some View {
        let isSelected = selectedTab == tab.rawValue
        
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab.rawValue
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? tab.filledIcon : tab.icon)
                    .font(.system(size: Layout.iconSize, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color.betaBlue : Color.white.opacity(0.6))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundColor(isSelected ? Color.betaBlue : Color.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Alternative Pill Tab Bar

struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    let onRecordTap: () -> Void
    
    private enum Layout {
        static let pillHeight: CGFloat = 64
        static let recordButtonSize: CGFloat = 56
        static let iconSize: CGFloat = 22
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach([TabItem.home, TabItem.explore], id: \.rawValue) { tab in
                floatingTabButton(for: tab)
            }
            
            // Center Record Button
            Button {
                onRecordTap()
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.sendOrange, Color.sendOrange.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: Layout.recordButtonSize, height: Layout.recordButtonSize)
                        .shadow(color: Color.sendOrange.opacity(0.4), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.white)
                }
            }
            .buttonStyle(.plain)
            .offset(y: -8)
            .padding(.horizontal, 8)
            
            ForEach([TabItem.analytics, TabItem.profile], id: \.rawValue) { tab in
                floatingTabButton(for: tab)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.cruxNavy)
                .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    private func floatingTabButton(for tab: TabItem) -> some View {
        let isSelected = selectedTab == tab.rawValue
        
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab.rawValue
            }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: isSelected ? tab.filledIcon : tab.icon)
                    .font(.system(size: Layout.iconSize, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color.betaBlue : Color.white.opacity(0.6))
                
                Text(tab.title)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? Color.betaBlue : Color.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Custom Tab Bar") {
    ZStack {
        Color.backgroundBase
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            
            CustomTabBar(selectedTab: .constant(0)) {
                print("Record tapped")
            }
        }
    }
}

#Preview("Floating Tab Bar") {
    ZStack {
        Color.backgroundBase
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            
            FloatingTabBar(selectedTab: .constant(0)) {
                print("Record tapped")
            }
            .padding(.bottom, 20)
        }
    }
}

//
//  AnalyticsView.swift
//  BetaBuddy
//
//  Analytics View displaying user climbing statistics
//

import SwiftUI

struct AnalyticsView: View {
    @State private var analyticsVM = AnalyticsVM()
    @Environment(AuthenticationVM.self) var authVM
    
    var body: some View {
        ScrollView {
            if analyticsVM.isLoading {
                loadingView
            } else if let errorMessage = analyticsVM.errorMessage {
                errorView(message: errorMessage)
            } else if analyticsVM.totalClimbs == 0 {
                emptyStateView
            } else {
                VStack(spacing: 24) {
                    summaryCard
                    gradeBreakdownSection
                    gymSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
        }
        .background(Color.backgroundBase)
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if let userID = authVM.currentUser?.userId {
                analyticsVM.fetchUserAnalytics(userID: userID)
            }
        }
    }
    
    // MARK: - Summary Card
    
    private var summaryCard: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Overview")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                Spacer()
            }
            
            HStack(spacing: 0) {
                AnalyticsStatItem(
                    icon: "figure.climbing",
                    value: "\(analyticsVM.totalClimbs)",
                    label: "Total Climbs",
                    color: Color.sendOrange
                )
                
                Divider()
                    .frame(height: 60)
                    .background(Color.textSecondary.opacity(0.2))
                
                AnalyticsStatItem(
                    icon: "mountain.2.fill",
                    value: "\(analyticsVM.gradeBreakdown.count)",
                    label: "Grades Sent",
                    color: Color.betaBlue
                )
                
                Divider()
                    .frame(height: 60)
                    .background(Color.textSecondary.opacity(0.2))
                
                AnalyticsStatItem(
                    icon: "building.2.fill",
                    value: "\(analyticsVM.gymVisits.count)",
                    label: "Gyms Visited",
                    color: Color.green
                )
            }
            .padding(.vertical, 16)
            .background(Color.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Grade Breakdown Section
    
    private var gradeBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Grade Breakdown")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color.textPrimary)
            
            VStack(spacing: 12) {
                ForEach(analyticsVM.getSortedGradeBreakdown(), id: \.0) { grade, count in
                    GradeBreakdownRow(
                        grade: grade,
                        count: count,
                        total: analyticsVM.totalClimbs
                    )
                }
            }
            .padding(16)
            .background(Color.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Gym Section
    
    private var gymSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Most Visited Gym")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color.textPrimary)
            
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.betaBlue.opacity(0.2), Color.cruxNavy.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color.betaBlue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(analyticsVM.mostVisitedGym)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                    
                    if let visitCount = analyticsVM.gymVisits[analyticsVM.mostVisitedGym] {
                        Text("\(visitCount) visits")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Color.textSecondary)
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // All gyms list
            if analyticsVM.gymVisits.count > 1 {
                VStack(alignment: .leading, spacing: 12) {
                    Text("All Gyms")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                    
                    VStack(spacing: 8) {
                        ForEach(analyticsVM.gymVisits.sorted(by: { $0.value > $1.value }), id: \.key) { gym, visits in
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.sendOrange)
                                
                                Text(gym)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(Color.textPrimary)
                                
                                Spacer()
                                
                                Text("\(visits)")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.betaBlue)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding(16)
                .background(Color.surfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(Color.betaBlue)
            
            Text("Loading analytics...")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(Color.red)
            
            Text(message)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.betaBlue.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Color.betaBlue)
            }
            
            VStack(spacing: 8) {
                Text("No Analytics Yet")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                
                Text("Start recording your climbs to see\nyour progress and statistics")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
    }
}

// MARK: - Analytics Stat Item

struct AnalyticsStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color.textPrimary)
            
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Grade Breakdown Row

struct GradeBreakdownRow: View {
    let grade: Grades
    let count: Int
    let total: Int
    
    private var percentage: Double {
        total > 0 ? Double(count) / Double(total) : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(grade.rawValue.uppercased())
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                
                Spacer()
                
                Text("\(count)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color.betaBlue)
                
                Text("(\(Int(percentage * 100))%)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color.textSecondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.betaBlue.opacity(0.1))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color.betaBlue, Color.sendOrange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * percentage, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Preview

#Preview("AnalyticsView") {
    NavigationStack {
        AnalyticsView()
            .environment(AuthenticationVM())
    }
}

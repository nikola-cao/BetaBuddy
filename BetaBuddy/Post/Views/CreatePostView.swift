//
//  CreatePostView.swift
//  BetaBuddy
//
//  Log a new climbing session with consistent design
//

import SwiftUI

struct CreatePostView: View {
    @Binding var selectedTab: Int
    
    // Form State
    @State private var grade: Grades = .v4tov6
    @State private var attempts: String = ""
    @State private var gymName: String = ""
    @State private var location: String = ""
    @State private var notes: String = ""
    @State private var selectedDate: Date = Date()
    @State private var showPreview: Bool = false
    
    @Environment(AuthenticationVM.self) var authVM
    @Environment(\.dismiss) var dismiss
    @State private var createPostVM = CreatePostVM()
    
    private var isFormValid: Bool {
        !attempts.isEmpty && !gymName.isEmpty && !location.isEmpty && Int(attempts) != nil
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Form Fields
                formSection
                
                // Preview Toggle
                previewSection
                
                // Post Button
                postButton
                
                Spacer(minLength: 40)
            }
        }
        .background(Color.backgroundBase)
        .navigationTitle("Log Climb")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.textSecondary)
                }
            }
            
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.sendOrange)
                    
                    Text("Log Climb")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.sendOrange.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "figure.climbing")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(Color.sendOrange)
            }
            
            VStack(spacing: 4) {
                Text("Record Your Send")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                
                Text("Share your climbing achievement")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color.textSecondary)
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 24)
    }
    
    // MARK: - Form Section
    
    private var formSection: some View {
        VStack(spacing: 20) {
            // Grade & Attempts Row
            HStack(spacing: 12) {
                // Grade Picker
                FormFieldContainer(label: "Grade", icon: "mountain.2.fill", iconColor: Color.betaBlue) {
                    Menu {
                        ForEach(Grades.allCases, id: \.self) { gradeOption in
                            Button {
                                grade = gradeOption
                            } label: {
                                HStack {
                                    Text(gradeOption.rawValue)
                                    if grade == gradeOption {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(grade.rawValue.uppercased())
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color.textSecondary)
                        }
                    }
                }
                
                // Attempts
                FormFieldContainer(label: "Attempts", icon: "arrow.counterclockwise", iconColor: Color.sendOrange) {
                    TextField("0", text: $attempts)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.leading)
                }
            }
            
            // Gym Name
            FormFieldContainer(label: "Gym Name", icon: "building.2.fill", iconColor: Color.cruxNavy, fullWidth: true) {
                TextField("Where did you climb?", text: $gymName)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(Color.textPrimary)
            }
            
            // Location
            FormFieldContainer(label: "Location", icon: "mappin.circle.fill", iconColor: Color.sendOrange, fullWidth: true) {
                TextField("City or area", text: $location)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(Color.textPrimary)
            }
            
            // Date
            FormFieldContainer(label: "Date", icon: "calendar", iconColor: Color.betaBlue, fullWidth: true) {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
            
            // Notes
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "text.quote")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.textSecondary)
                    
                    Text("Notes (optional)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color.textSecondary)
                }
                
                ZStack(alignment: .topLeading) {
                    if notes.isEmpty {
                        Text("How was your session? Any beta to share?")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(Color.textSecondary.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                    }
                    
                    TextEditor(text: $notes)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                        .frame(minHeight: 100)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                }
                .background(Color.surfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.textSecondary.opacity(0.2), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }
    
    // MARK: - Preview Section
    
    private var previewSection: some View {
        VStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showPreview.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 14, weight: .medium))
                    
                    Text(showPreview ? "Hide Preview" : "Show Preview")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    
                    Spacer()
                    
                    Image(systemName: showPreview ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(Color.betaBlue)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.betaBlue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .padding(.horizontal, 16)
            
            if showPreview {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preview")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color.textSecondary)
                        .padding(.horizontal, 16)
                    
                    ClimbCard(post: createPreviewPost())
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Post Button
    
    @ViewBuilder
    private var postButton: some View {
        VStack(spacing: 0) {
            Button {
                submitPost()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Post Climb")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: isFormValid
                            ? [Color.sendOrange, Color.sendOrange.opacity(0.9)]
                            : [Color.textSecondary.opacity(0.4), Color.textSecondary.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(
                    color: isFormValid ? Color.sendOrange.opacity(0.4) : Color.clear,
                    radius: 10, x: 0, y: 6
                )
            }
            .disabled(!isFormValid)
            .padding(.horizontal, 16)
            
            // Validation hints
            if !isFormValid {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                    Text("Fill in attempts, gym name, and location")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                }
                .foregroundColor(Color.textSecondary)
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Actions
    
    private func submitPost() {
        guard authVM.currentUser != nil else {
            print("Couldn't get current user")
            return
        }
        
        createPostVM.addNewPost(post: createPreviewPost())
        
        // Dismiss the sheet
        dismiss()
        
        // Switch to Feed tab
        selectedTab = 0
    }
    
    // MARK: - Preview Post
    
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
            username: authVM.currentUser?.username ?? "You",
            attempts: Int(attempts) ?? 1,
            date: postDate,
            grade: grade,
            gymName: gymName.isEmpty ? "Gym Name" : gymName,
            location: location.isEmpty ? "Location" : location,
            notes: notes
        )
    }
}

// MARK: - Form Field Container

struct FormFieldContainer<Content: View>: View {
    let label: String
    let icon: String
    let iconColor: Color
    var fullWidth: Bool = false
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(iconColor)
                
                Text(label)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(Color.textSecondary)
            }
            
            content
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(maxWidth: fullWidth ? .infinity : nil, alignment: .leading)
                .background(Color.surfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.textSecondary.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

// MARK: - Preview

#Preview("Create Post") {
    NavigationStack {
        CreatePostView(selectedTab: .constant(1))
            .environment(AuthenticationVM())
    }
}

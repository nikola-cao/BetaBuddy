//
//  TextFieldStyles.swift
//  BetaBuddy
//
//  Custom text field styles for the design system
//

import SwiftUI

// MARK: - BetaBuddy Text Field Style

struct BetaBuddyTextFieldStyle: TextFieldStyle {
    let icon: String
    @FocusState.Binding var isFocused: Bool
    let fieldIsFocused: Bool
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(fieldIsFocused ? Color.betaBlue : Color.textSecondary)
                .frame(width: 24)
            
            configuration
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Color.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(fieldIsFocused ? Color.betaBlue : Color.textSecondary.opacity(0.2), lineWidth: fieldIsFocused ? 2 : 1)
        )
        .shadow(color: fieldIsFocused ? Color.betaBlue.opacity(0.1) : Color.clear, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Custom Secure Field

struct BetaBuddySecureField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    @FocusState var isFocused: Bool
    @State private var isSecure: Bool = true
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(isFocused ? Color.betaBlue : Color.textSecondary)
                .frame(width: 24)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .foregroundColor(Color.textPrimary)
            .focused($isFocused)
            
            Button {
                isSecure.toggle()
            } label: {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isFocused ? Color.betaBlue : Color.textSecondary.opacity(0.2), lineWidth: isFocused ? 2 : 1)
        )
        .shadow(color: isFocused ? Color.betaBlue.opacity(0.1) : Color.clear, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Custom Text Field Component

struct BetaBuddyTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    @FocusState var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(isFocused ? Color.betaBlue : Color.textSecondary)
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Color.textPrimary)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .focused($isFocused)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isFocused ? Color.betaBlue : Color.textSecondary.opacity(0.2), lineWidth: isFocused ? 2 : 1)
        )
        .shadow(color: isFocused ? Color.betaBlue.opacity(0.1) : Color.clear, radius: 8, x: 0, y: 4)
    }
}


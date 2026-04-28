//
//  ProfileView.swift
//  Blush
//
//  Created by Bhoomi on 27/04/26.
//


import SwiftUI

struct ProfileView: View {
    @State private var notificationsEnabled = true
    @State private var syncEnabled = true
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    
                    preferencesSection
                    
                    dataPrivacySection
                    
                    aboutSection
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - UI Components
extension ProfileView {
    
    var headerSection: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                    .padding(12)
                    .background(.ultraThinMaterial, in: Circle())
            }
            
            Spacer()
            
            Text("Settings")
                .font(.custom("Sniglet-ExtraBold", size: 24))
                .foregroundStyle(Theme.textPrimary)
            
            Spacer()
            
            // Dummy spacer to balance the back button
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.vertical, 10)
    }
    
    var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preferences")
                .font(.custom("Sniglet-ExtraBold", size: 18))
                .foregroundStyle(Theme.accentPink)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                ProfileToggleRow(icon: "bell.fill", title: "Notifications", subtitle: "Daily reminders & insights", isOn: $notificationsEnabled)
                
                Divider().background(Theme.glassBorder).padding(.horizontal, 16)
                
                ProfileToggleRow(icon: "arrow.triangle.2.circlepath", title: "iCloud Sync", subtitle: "Keep your data backed up", isOn: $syncEnabled)
            }
            .background(Theme.cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        }
    }
    
    var dataPrivacySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data & Privacy")
                .font(.custom("Sniglet-ExtraBold", size: 18))
                .foregroundStyle(Theme.accentPink)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                ProfileActionRow(icon: "square.and.arrow.up.fill", title: "Export Data")
                
                Divider().background(Theme.glassBorder).padding(.horizontal, 16)
                
                ProfileActionRow(icon: "lock.fill", title: "Privacy Policy")
                
                Divider().background(Theme.glassBorder).padding(.horizontal, 16)
                
                ProfileActionRow(icon: "trash.fill", title: "Delete Account", isDestructive: true)
            }
            .background(Theme.cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        }
    }
    
    var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About BlushAI")
                .font(.custom("Sniglet-ExtraBold", size: 18))
                .foregroundStyle(Theme.accentPink)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                ProfileActionRow(icon: "star.fill", title: "Rate Us")
                
                Divider().background(Theme.glassBorder).padding(.horizontal, 16)
                
                ProfileActionRow(icon: "envelope.fill", title: "Contact Support")
            }
            .background(Theme.cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
            
            Text("Version 1.0.0")
                .font(.custom("Sniglet-Regular", size: 14))
                .foregroundStyle(Theme.textMuted)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
        }
    }
}

// MARK: - Reusable Rows

struct ProfileToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Theme.accentPink)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Sniglet-Regular", size: 17))
                    .foregroundStyle(Theme.textPrimary)
                Text(subtitle)
                    .font(.custom("Sniglet-Regular", size: 13))
                    .foregroundStyle(Theme.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(Theme.accentPink)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

struct ProfileActionRow: View {
    let icon: String
    let title: String
    var isDestructive: Bool = false
    
    var body: some View {
        Button {
            // Action placeholder
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isDestructive ? .red : Theme.accentPink)
                    .frame(width: 24)
                
                Text(title)
                    .font(.custom("Sniglet-Regular", size: 17))
                    .foregroundStyle(isDestructive ? .red : Theme.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.textMuted)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
    }
}

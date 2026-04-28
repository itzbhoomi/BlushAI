//
// MoodView.swift
// Blush
//

import SwiftUI

struct MoodView: View {
    let hasLoggedMoodToday: Bool
    let selectedMood: String
    let currentPhase: CyclePhase
    let cycleDay: Int
    let risk: RiskLevel
    let sleep: Double
    let stress: Double
    let onComplete: (String, String) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var chosenMood = ""
    @State private var insight = ""
    @State private var loading = false
    
    let moods = ["😊", "🙂", "😐", "😴", "😣"]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                headerTitle
                
                if hasLoggedMoodToday {
                    alreadyLoggedView
                } else {
                    moodSelectionView
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .background(Theme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Mood Check-In")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerTitle: some View {
        Text("How are you feeling today?")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(Theme.textPrimary)
            .multilineTextAlignment(.center)
    }
    
    private var alreadyLoggedView: some View {
        VStack(spacing: 20) {
            Text(selectedMood)
                .font(.system(size: 80))
            
            Text("You've already checked in today 💕")
                .font(.system(size: 17))
                .foregroundStyle(Theme.textSecondary)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Your Insight")
                    .font(.headline)
                    .foregroundStyle(Theme.accentPink)
                
                Text(cleanMarkdown(savedInsight()))
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
            .background(Theme.cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
    
    private var moodSelectionView: some View {
        VStack(spacing: 28) {
            HStack(spacing: 16) {
                ForEach(moods, id: \.self) { mood in
                    moodButton(mood)
                }
            }
            
            if loading {
                ProgressView()
                    .scaleEffect(1.2)
            }
            
            if !insight.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Insight")
                        .font(.headline)
                        .foregroundStyle(Theme.accentPink)
                    
                    Text(cleanMarkdown(insight))
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(20)
                .background(Theme.cardGradient)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
        }
    }
    
    // MARK: - New: Clean Markdown Asterisks
    private func cleanMarkdown(_ text: String) -> String {
        var cleaned = text
        
        // Remove bold (**text**)
        cleaned = cleaned.replacingOccurrences(of: "**", with: "")
        
        // Remove italic (*text*)
        cleaned = cleaned.replacingOccurrences(of: "*", with: "")
        
        // Optional: Remove extra newlines or clean up
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleaned
    }
    
    // MARK: - Mood Button
    func moodButton(_ emoji: String) -> some View {
        Button {
            chosenMood = emoji
            Task {
                await generateInsight(emoji)
            }
        } label: {
            Text(emoji)
                .font(.system(size: 42))
                .frame(width: 72, height: 72)
                .background(Theme.glassOverlay2)
                .clipShape(Circle())
                .shadow(color: Theme.accentPink.opacity(0.15), radius: 12)
                .overlay(
                    Circle().stroke(Theme.glassBorder, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Logic (unchanged)
    func generateInsight(_ emoji: String) async {
        loading = true
        let result = await AIService.shared.generateMoodInsight(
            selectedMood: moodName(emoji),
            phase: currentPhase.rawValue,
            cycleDay: cycleDay,
            sleep: sleep,
            stress: stress,
            risk: risk.rawValue
        )
        
        await MainActor.run {
            insight = result
            loading = false
            saveInsight(result)
            onComplete(emoji, result)
        }
    }
    
    func savedInsight() -> String {
        let key = todayMoodKey()
        return UserDefaults.standard.string(forKey: "\(key)_insight")
            ?? "You checked in today 💕"
    }
    
    func saveInsight(_ text: String) {
        let key = todayMoodKey()
        UserDefaults.standard.set(text, forKey: "\(key)_insight")
    }
    
    func todayMoodKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "mood_\(formatter.string(from: Date()))"
    }
    
    func moodName(_ emoji: String) -> String {
        switch emoji {
        case "😊": return "happy"
        case "🙂": return "good"
        case "😐": return "neutral"
        case "😴": return "tired"
        case "😣": return "stressed"
        default:   return "unknown"
        }
    }
}

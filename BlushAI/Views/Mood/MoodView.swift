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

        ScrollView {
            VStack(spacing: 20) {

                Text("Mood Check-In")
                    .font(.largeTitle.bold())

                if hasLoggedMoodToday {

                    Text(selectedMood)
                        .font(.system(size: 70))

                    Text("You've already checked in today 💕")
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 12) {

                        Text("Your Insight")
                            .font(.headline)

                        Text(savedInsight())
                            .foregroundColor(.secondary)

                    }
                    .padding(20)
                    .glassCardStyle()
                    
                    Spacer()
                    Spacer()
                    Spacer()
                } else {
                    Text("How are you feeling?")
                        .foregroundColor(.secondary)

                    HStack(spacing: 14) {
                        ForEach(moods, id: \.self) { mood in
                            moodButton(mood)
                        }
                    }

                    if loading {
                        ProgressView()
                            .padding(.top)
                    }

                    if !insight.isEmpty {

                        VStack(alignment: .leading, spacing: 12) {

                            Text("Your Insight")
                                .font(.headline)

                            Text(insight)
                                .foregroundColor(.secondary)

                        }
                        .padding(20)
                        .glassCardStyle()
                        Spacer()
                        Spacer()
                        Spacer()
                    }
                }
            }
            .padding()
        }
        .background(AppBackground())
        .navigationTitle("Mood")
    }

    func moodButton(_ emoji: String) -> some View {

        Button {

            chosenMood = emoji

            Task {
                await generateInsight(emoji)
            }

        } label: {

            Text(emoji)
                .font(.system(size: 34))
                .frame(width: 64, height: 64)
                .background(Theme.glassOverlay2)
                .clipShape(Circle())
                .shadow(color: Theme.accentPink.opacity(0.1), radius: 10)
                .overlay(Circle().stroke(Theme.glassBorder, lineWidth: 1))
        }
    }

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

        return UserDefaults.standard.string(
            forKey: "\(key)_insight"
        ) ?? "You checked in today 💕"
    }

    func saveInsight(_ text: String) {

        let key = todayMoodKey()

        UserDefaults.standard.set(
            text,
            forKey: "\(key)_insight"
        )
    }

    func todayMoodKey() -> String {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return "mood_\(formatter.string(from: Date()))"
    }

    func moodName(_ emoji: String) -> String {
        switch emoji {
        case "😊": return "happy"
        case "🙂": return "okay"
        case "😐": return "neutral"
        case "😴": return "tired"
        case "😣": return "stressed"
        default: return "unknown"
        }
    }
}

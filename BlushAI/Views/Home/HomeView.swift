//
// HomeView.swift
// Blush
//

import SwiftUI
import SwiftData

struct HomeView: View {
  
    @State private var userName = "User"
    @State private var insight = "Loading your insight..."
  
    @State private var predictedCycleLength: Double = 28
    @State private var nextDate = Date()
    @State private var daysLeft = 0
  
    @State private var currentPhase: CyclePhase = .luteal
    @State private var risk: RiskLevel = .low
  
    @State private var selectedMood = ""
    @State private var hasLoggedMoodToday = false
    
    @State private var showFullMotivation = false
  
    @Query var profiles: [UserProfile]
  
    @Query(
        sort: \CycleLog.startDate,
        order: .reverse
    )
    var logs: [CycleLog]
  
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                    cycleCard
                    HStack(spacing: 14) {
                        moodCard
                        journalCard
                    }
                    insightCard
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Theme.backgroundGradient.ignoresSafeArea())
            .task {
                await loadHomeData()
                checkMoodLoggedToday()
            }
            .onChange(of: logs.count) { _ in
                Task { await loadHomeData() }
            }
            .onChange(of: profiles.count) { _ in
                Task { await loadHomeData() }
            }
        }
        .font(Font.custom("Sniglet-Regular", size: 14))
    }
}

// MARK: - UI
extension HomeView {
   
    var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText())
                    .font(Font.custom("Sniglet-Regular", size: 28))
    
               
                Text("You're doing amazing, let's make today beautiful 🎀")
                    .font(Font.custom("Sniglet-Regular", size: 17))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
           
            Spacer()
           
            Button {
                // Notification action (can be expanded later)
            } label: {
                Image(systemName: "bell.fill")
                    .font(.custom("Sniglet-ExtraBold", size: 20))
                    .foregroundStyle(Theme.accentPink)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
        .padding(.top, 10)
    }
   
    // MARK: - Cycle Card with Gradient Progress Ring
    var cycleCard: some View {
        VStack(spacing: 10) {
                Label("Your Cycle", systemImage: "heart.fill")
                    .font(Font.custom("Sniglet-Regular", size: 17))
                    .foregroundStyle(Theme.accentPink)
                    .frame(maxWidth: .infinity, alignment: .leading)
         
           
            HStack(alignment: .top, spacing: 20) {
                // Left side - Phase Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Day \(cycleDay())")
                        .font(Font.custom("Sniglet-ExtraBold", size: 36))
                        .foregroundStyle(Theme.textPrimary)
                   
                    Text(currentPhase.rawValue)
                        .font(.custom("Sniglet-ExtraBold", size: 17))
                        .foregroundStyle(Theme.accentPink)
                   
                    Text(phaseMotivation())
                        .font(Font.custom("Sniglet-Regular", size: 15))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(3)
                        .onTapGesture {
                            showFullMotivation = true
                        }
                    
                        .sheet(isPresented: $showFullMotivation) {
                            VStack(spacing: 5) {
                                Text("Your Phase Insight")
                                    .font(.title3.bold())
                                
                                Text(phaseMotivation())
                                    .font(Font.custom("Sniglet-Regular", size: 16))
                                    .multilineTextAlignment(.center)
                                
                                Button("Close") {
                                    showFullMotivation = false
                                }
                                .padding(.top, 10)
                            }
                            .padding()
                            .presentationDetents([.medium]) // 👈 controls height
                            .presentationDragIndicator(.visible)
                            
                        }
                    
                    HStack(spacing: 6) {
                                            Text("Risk:")
                                                
                                                .foregroundStyle(Theme.textSecondary)
                                            Text(risk.rawValue.capitalized)
                                               
                                                .foregroundStyle(riskColor())
                                        }
                    .font(Font.custom("Sniglet-Regular", size: 12))
                }
               
                Spacer()
               
                // Circular Progress Ring with Gradient
                ZStack {
                    Circle()
                        .stroke(Theme.accentGradient.opacity(0.15), lineWidth: 13)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(cycleDay()) / CGFloat(max(predictedCycleLength, 1)))
                        .stroke(Theme.accentGradient,
                                style: StrokeStyle(lineWidth: 13, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .shadow(color: Theme.accentPink.opacity(0.5), radius: 8)
                    
                    VStack(spacing: 2) {
                        Text("\(cycleDay())")
                            .font(.custom("Sniglet-ExtraBold", size: 28))
                            .foregroundStyle(Theme.accentPink)
                        Text("of \(Int(predictedCycleLength))")
                            .font(.custom("Sniglet-Regular", size: 13))
                            .foregroundStyle(Theme.textSecondary)

                    }
                }
                .frame(width: 130, height: 130)
            }
           
            // View Full Cycle Button with Gradient
            Button {
                // Navigate to CalendarView
                // You can wrap this in NavigationLink or use navigation destination
            } label: {
                Text("Log Period")
                    .font(.custom("Sniglet-ExtraBold", size: 16))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Theme.accentGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(Theme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
    }
   
    var moodCard: some View {
        NavigationLink {
            MoodView(
                hasLoggedMoodToday: hasLoggedMoodToday,
                selectedMood: selectedMood,
                currentPhase: currentPhase,
                cycleDay: cycleDay(),
                risk: risk,
                sleep: logs.first?.sleepHours ?? 7,
                stress: logs.first?.stressScore ?? 5
            ) { emoji, _ in
                selectedMood = emoji
                hasLoggedMoodToday = true
                saveMoodToday(emoji: emoji)
            }
        } label: {
            VStack(spacing: 12) {
                // Title
                Label("Mood Check", systemImage: "face.smiling.fill")
                    .font(.custom("Sniglet-ExtraBold", size: 15))
                    .foregroundStyle(Theme.accentPink)
                
                
                // Mood Emoji / State
                if hasLoggedMoodToday {
                    Text(selectedMood)
                        .font(.custom("Sniglet-Regular", size: 50))
                    
                    Text(moodDescription(for: selectedMood))
                        .font(.custom("Sniglet-Regular", size: 12))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("😊")
                        .font(.custom("Sniglet-Regular", size: 50))
                    
                    Text("How are you feeling?")
                        .font(.custom("Sniglet-Regular", size: 14))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                
                // Track Mood Button
                Text("Track Mood")
                    .font(.custom("Sniglet-Regular", size: 12))
                    .foregroundStyle(Theme.accentPink)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.white)
                    .clipShape(Capsule())
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 160)
            .background(Theme.cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }
   
    var journalCard: some View {
        NavigationLink {
            JournalView()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Label("Journal", systemImage: "book.pages.fill")
                    .font(.custom("Sniglet-ExtraBold", size: 17))
                    .foregroundStyle(Theme.accentPink)
               
                Text("Write It Out")
                    .font(.custom("Sniglet-ExtraBold", size: 20))
                    .foregroundStyle(Theme.textPrimary)
               
                Text("Release your thoughts and feel lighter.")
                    .font(.custom("Sniglet-Regular", size: 14))
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
       
                Text("New Entry")
                    .font(.custom("Sniglet-Regular", size: 12))
                    .foregroundStyle(Theme.accentPink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.white)
                    .clipShape(Capsule())
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 160)
            .background(Theme.cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }
   
    var insightCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Today's Insight", systemImage: "sparkles")
                .font(.custom("Sniglet-ExtraBold", size: 17))
                .foregroundStyle(Theme.accentPink)
           
            Text(insight)
                .font(.custom("Sniglet-Regular", size: 16))
                .foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
           
            HStack {
                Spacer()
                Text("Keep showing up for yourself 💕")
                    .font(.custom("Sniglet-Regular", size: 12))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(20)
        .background(Theme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
}

// MARK: - Helper Functions (UI only)
extension HomeView {
   
    private func phaseMotivation() -> String {
        switch currentPhase {
        case .menstrual:
            return "This can be a physically demanding time. Take it slow, listen to your body, and prioritize rest."
        case .follicular:
            return "You're in your power phase. Great time for new ideas and fresh starts."
        case .ovulation:
            return "Your energy is peaking. Great time for connection and creativity."
        case .luteal:
            return "Time to slow down and nurture yourself. Listen to your body."
        }
    }
    
    private func riskColor() -> Color {
            switch risk {
            case .low:
                return .green
            case .moderate:
                return .orange
            case .high:
                return .red
            }
        }
   
    func greetingText() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }
   
    func cycleDay() -> Int {
        guard let latestLog = logs.first else { return 1 }
        let days = Calendar.current.dateComponents([.day], from: latestLog.startDate, to: Date()).day ?? 0
        let cycleLength = max(Int(predictedCycleLength.rounded()), 1)
        return (days % cycleLength) + 1
    }
}

// MARK: - Logic (Unchanged - Keep Same)
extension HomeView {
   
    func averageLast3() -> Double {
        let last3 = Array(logs.prefix(3))
        guard !last3.isEmpty else { return 28 }
        let total = last3.reduce(0) { $0 + Double($1.cycleLength) }
        return total / Double(last3.count)
    }
   
    func stdLast6() -> Double {
        let last6 = Array(logs.prefix(6))
        guard last6.count > 1 else { return 1.5 }
        let values = last6.map { Double($0.cycleLength) }
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.reduce(0) { $0 + pow($1 - mean, 2) } / Double(values.count)
        return sqrt(variance)
    }
   
    func checkMoodLoggedToday() {
        let key = todayMoodKey()
        hasLoggedMoodToday = UserDefaults.standard.bool(forKey: key)
        if hasLoggedMoodToday {
            selectedMood = UserDefaults.standard.string(forKey: "\(key)_emoji") ?? "😊"
        }
    }
   
    func moodDescription(for emoji: String) -> String {
            switch emoji {
            case "😊":
                return "You're feeling happy"
            case "🙂":
                return "You're feeling good"
            case "😐":
                return "You're feeling steady"
            case "😴":
                return "You're feeling tired"
            case "😣":
                return "You're feeling stressed"
            default:
                return "You're feeling okay"
            }
        }
    func saveMoodToday(emoji: String) {
        let key = todayMoodKey()
        UserDefaults.standard.set(true, forKey: key)
        UserDefaults.standard.set(emoji, forKey: "\(key)_emoji")
    }
   
    func todayMoodKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "mood_\(formatter.string(from: Date()))"
    }
   
    func loadHomeData() async {
        guard let profile = profiles.first, let latestLog = logs.first else { return }
       
        userName = profile.name
        if let predictedDate = CyclePredictionEngine.shared.nextPeriodDate(from: logs) {
            
            nextDate = predictedDate
            
            // derive cycle length from prediction
            if let lastLog = logs.first {
                let diff = Calendar.current.dateComponents(
                    [.day],
                    from: lastLog.startDate,
                    to: predictedDate
                ).day ?? 28
                
                predictedCycleLength = Double(max(diff, 1))
            }
            
            daysLeft = max(0, DateUtils.daysUntil(predictedDate))
        }
       
        daysLeft = max(0, DateUtils.daysUntil(nextDate))
       
        currentPhase = PhaseEngine.currentPhase(
            lastStartDate: latestLog.startDate,
            predictedCycleLength: Int(predictedCycleLength.rounded())
        )
       
        risk = RiskEngine.calculate(
            stdDeviation: stdLast6(),
            stressScore: latestLog.stressScore,
            hasPCOS: profile.hasPCOS
        )
       
        await loadDailyInsight(
            stress: Int(latestLog.stressScore),
            sleep: latestLog.sleepHours,
            mood: latestLog.moodScore
        )
    }
   
    func loadDailyInsight(stress: Int, sleep: Double, mood: Int) async {
        let key = todayInsightKey()
        if let saved = UserDefaults.standard.string(forKey: key) {
            insight = saved
            return
        }
        let generated = await AIService.shared.generateDailyInsight(
            stress: stress,
            sleep: sleep,
            mood: mood
        )
        let trimmed = generated.split(separator: " ").prefix(40).joined(separator: " ")
        insight = trimmed
        UserDefaults.standard.set(trimmed, forKey: key)
    }
   
    func todayInsightKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "daily_insight_\(formatter.string(from: Date()))"
    }
}

//
//  HomeView.swift
//  Blush
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
    
    @Query var profiles: [UserProfile]
    
    @Query(
        sort: \CycleLog.startDate,
        order: .reverse
    )
    var logs: [CycleLog]
    
    var body: some View {
        
        NavigationStack {
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 18) {
                    
                    headerSection
                    
                    cycleCard
                    
                    HStack(spacing: 14) {
                        moodCard
                        journalCard
                    }
                    
                    insightCard
                    Spacer()
                    Spacer()
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
            .background(AppBackground())
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
    }
}

// MARK: - UI
extension HomeView {
    
    var headerSection: some View {
        HStack(alignment: .top) {
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(greetingText())
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
                
                Text(userName)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Image(systemName: "bell")
                    .font(.title3)
                    .foregroundColor(.pink)
                
                Text("🐼")
                    .font(.system(size: 42))
            }
        }
        .padding(.top, 10)
    }
    
    var cycleCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Next period in")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                
                Text("\(daysLeft)")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.pink)
                
                Text("days")
                    .font(.system(size: 25, weight: .semibold))
            }
            
            Text("Day \(cycleDay()) of your cycle")
                .foregroundColor(.secondary)
            
            ProgressView(
                value: Double(cycleDay()),
                total: max(predictedCycleLength, 1)
            )
            .tint(.pink)
            .scaleEffect(y: 2.2)
            .padding(.top, 8)
            
            HStack {
                
                Label(
                    currentPhase.rawValue,
                    systemImage: "sparkles"
                )
         
                
                Text("Risk: \(risk.rawValue)")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.top, 4)
        }
        .padding(18)
        .glassCardStyle()
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
            
            VStack(alignment: .leading, spacing: 10) {
                
                Text("Mood")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                if hasLoggedMoodToday {
                    
                    Text(selectedMood)
                        .font(.system(size: 34))
                    
                    Text("Logged today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                } else {
                    
                    Text("😊")
                        .font(.system(size: 34))
                    
                    Text("Tap to check in")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(18)
            .frame(
                maxWidth: .infinity,
                minHeight: 120
            )
            .glassCardStyle()
        }
        .buttonStyle(.plain)
    }
    
    var journalCard: some View {
        
        NavigationLink {
            JournalView()
        } label: {
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text("Journal")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                Text("📔")
                    .font(.system(size: 34))
                
                Text("Write freely")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(18)
            .frame(
                maxWidth: .infinity,
                minHeight: 140
            )
            .glassCardStyle()
        }
        .buttonStyle(.plain)
    }
    
    var insightCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Today's Insight")
                .font(.headline)
            
            Text(insight)
                .foregroundColor(.secondary)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
            
            HStack {
                Spacer()
                
                Text("🐼💕")
                    .font(.system(size: 30))
            }
        }
        .padding(18)
        .glassCardStyle()
    }
    
}

// MARK: - Logic
extension HomeView {
    
    func greetingText() -> String {
        
        let hour =
        Calendar.current.component(
            .hour,
            from: Date()
        )
        
        switch hour {
        case 5..<12:
            return "Good morning,"
        case 12..<17:
            return "Good afternoon,"
        case 17..<21:
            return "Good evening,"
        default:
            return "Good night,"
        }
    }
    
    func cycleDay() -> Int {
        
        guard let latestLog = logs.first else {
            return 1
        }
        
        let days =
        Calendar.current.dateComponents(
            [.day],
            from: latestLog.startDate,
            to: Date()
        ).day ?? 0
        
        let cycleLength =
        max(
            Int(predictedCycleLength.rounded()),
            1
        )
        
        return (days % cycleLength) + 1
    }
    
    func averageLast3() -> Double {
        
        let last3 = Array(logs.prefix(3))
        
        guard !last3.isEmpty else {
            return 28
        }
        
        let total =
        last3.reduce(0) {
            $0 + Double($1.cycleLength)
        }
        
        return total / Double(last3.count)
    }
    
    func stdLast6() -> Double {
        
        let last6 = Array(logs.prefix(6))
        
        guard last6.count > 1 else {
            return 1.5
        }
        
        let values =
        last6.map {
            Double($0.cycleLength)
        }
        
        let mean =
        values.reduce(0,+)
        / Double(values.count)
        
        let variance =
        values.reduce(0) {
            $0 + pow($1 - mean, 2)
        } / Double(values.count)
        
        return sqrt(variance)
    }
    
    func checkMoodLoggedToday() {
        
        let key = todayMoodKey()
        
        hasLoggedMoodToday =
        UserDefaults.standard.bool(forKey: key)
        
        if hasLoggedMoodToday {
            selectedMood =
            UserDefaults.standard.string(
                forKey: "\(key)_emoji"
            ) ?? "😊"
        }
    }
    
    func saveMoodToday(emoji: String) {
        
        let key = todayMoodKey()
        
        UserDefaults.standard.set(
            true,
            forKey: key
        )
        
        UserDefaults.standard.set(
            emoji,
            forKey: "\(key)_emoji"
        )
    }
    
    func todayMoodKey() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return "mood_\(formatter.string(from: Date()))"
    }
    
    func loadHomeData() async {
        
        guard let profile = profiles.first,
              let latestLog = logs.first else {
            return
        }
        
        userName = profile.name
        
        predictedCycleLength =
        PredictionService.shared.predictCycleLength(
            cycleNumber: logs.count,
            cycleLengthDays: Double(latestLog.cycleLength),
            prevCycleLength: Double(latestLog.cycleLength),
            painLevel: latestLog.painLevel,
            moodScore: latestLog.moodScore,
            stressScoreCycle: latestLog.stressScore,
            sleepHoursCycle: latestLog.sleepHours,
            energyLevel: 7,
            concentrationScore: 7,
            overallHealthScore: 8,
            age: profile.age,
            bmi: profile.bmi,
            sleepHours: profile.sleepHours,
            stressScoreBaseline: profile.baselineStress,
            avgLast3Cycles: averageLast3(),
            stdLast6Cycles: stdLast6(),
            cyclePhase: 2,
            flowLevel: latestLog.flowLevel,
            pmsSymptoms: 0,
            dietQuality: 2,
            exerciseFrequency: 2,
            birthControlUse: 0,
            pcosDiagnosed: profile.hasPCOS ? 1 : 0
        )
        
        nextDate =
        PredictionService.shared.predictNextDate(
            lastStartDate: latestLog.startDate,
            predictedCycleLength: predictedCycleLength
        )
        
        daysLeft =
        max(
            0,
            DateUtils.daysUntil(nextDate)
        )
        
        currentPhase =
        PhaseEngine.currentPhase(
            lastStartDate: latestLog.startDate,
            predictedCycleLength:
                Int(predictedCycleLength.rounded())
        )
        
        risk =
        RiskEngine.calculate(
            stdDeviation: stdLast6(),
            stressScore: latestLog.stressScore,
            hasPCOS: profile.hasPCOS
        )
        
        await loadDailyInsight(
            stress: Int(latestLog.stressScore),
            sleep: latestLog.sleepHours,
            mood: latestLog.moodScore
        )
        
        func loadDailyInsight(
            stress: Int,
            sleep: Double,
            mood: Int
        ) async {

            let key = todayInsightKey()

            if let saved =
                UserDefaults.standard.string(forKey: key) {

                insight = saved
                return
            }

            let generated =
            await AIService.shared.generateDailyInsight(
                stress: stress,
                sleep: sleep,
                mood: mood
            )

            let trimmed =
            generated
                .split(separator: " ")
                .prefix(40)
                .joined(separator: " ")

            insight = trimmed

            UserDefaults.standard.set(
                trimmed,
                forKey: key
            )
        }

        func todayInsightKey() -> String {

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"

            return "daily_insight_\(formatter.string(from: Date()))"
        }
        
    }
}

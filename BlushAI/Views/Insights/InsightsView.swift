import SwiftUI
import SwiftData

struct InsightsView: View {
    
    @Query(sort: \DailyLog.date)
    var dailyLogs: [DailyLog]
    
    @Query(sort: \CycleLog.startDate, order: .reverse)
    var cycleLogs: [CycleLog]
    
    @Query var profiles: [UserProfile]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                
                highlightCard
                
                moodTrendCard
                
                HStack(spacing: 12) {
                    cycleStatsCard
                    wellnessMiniCard
                }
                
                aiPhaseCard
                aiRiskCard
                
                Spacer(minLength: 40)
            }
            .padding(18)
        }
        .background(Theme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Your Patterns")
    }
}

////////////////////////////////////////////////////////////
// MARK: - Highlight Card
////////////////////////////////////////////////////////////

extension InsightsView {
    
    var highlightCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Your Pattern 🌸")
                .font(.custom("Sniglet-ExtraBold", size: 16))
            
            Text(insightText())
                .font(.custom("Sniglet-Regular", size: 13))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.accentGradient.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

////////////////////////////////////////////////////////////
// MARK: - Mood Trend (WITH MOCK SUPPORT)
////////////////////////////////////////////////////////////

extension InsightsView {
    
    var moodTrendCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Mood Trend 📈")
                .font(.custom("Sniglet-ExtraBold", size: 16))
            
            let logsToUse = dailyLogs.isEmpty ? mockMoodLogs : Array(dailyLogs.suffix(7))
            
            if dailyLogs.isEmpty {
                Text("Showing sample data ✨")
                    .foregroundStyle(.secondary)
            }
            
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(logsToUse, id: \.date) { log in
                    
                    VStack(spacing: 6) {
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Theme.accentGradient)
                            .frame(height: CGFloat(log.mood * 12))
                        
                        Text(dayLabel(log.date))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(height: 140)
        }
        .padding(16)
        .background(Theme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

////////////////////////////////////////////////////////////
// MARK: - Cycle Stats
////////////////////////////////////////////////////////////

extension InsightsView {
    
    var cycleStatsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text("Cycle 🌙")
                .font(.custom("Sniglet-ExtraBold", size: 14))
            
            if cycleLogs.isEmpty {
                Text("28 days")
                    .font(.title3.bold())
                
                Text("avg length (sample)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                let lengths = cycleLogs.map { Double($0.cycleLength) }
                let avg = lengths.reduce(0, +) / Double(lengths.count)
                
                Text("\(Int(avg)) days")
                    .font(.title3.bold())
                
                Text("avg length")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

////////////////////////////////////////////////////////////
// MARK: - Wellness Mini
////////////////////////////////////////////////////////////

extension InsightsView {
    
    var wellnessMiniCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text("Wellness 💗")
                .font(.custom("Sniglet-ExtraBold", size: 14))
            
            if dailyLogs.isEmpty {
                Text("Mood 7")
                    .font(.title3.bold())
                
                Text("avg score (sample)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Mood \(avg(\.mood))")
                    .font(.title3.bold())
                
                Text("avg score")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

////////////////////////////////////////////////////////////
// MARK: - AI Insights Cards
////////////////////////////////////////////////////////////

extension InsightsView {
    
    var aiPhaseCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack {
                Text("AI Cycle Phase ✨")
                    .font(.custom("Sniglet-ExtraBold", size: 16))
                Spacer()
                Image(systemName: "sparkles")
                    .foregroundStyle(Theme.accentPink)
            }
            
            let lastStart = cycleLogs.first?.startDate ?? Date()
            let predictedLength = cycleLogs.first?.cycleLength ?? 28
            let phase = PhaseEngine.currentPhase(lastStartDate: lastStart, predictedCycleLength: predictedLength)
            
            Text("You are currently in your **\(phase.rawValue)** phase.")
                .font(.custom("Sniglet-Regular", size: 14))
                .foregroundStyle(Theme.textPrimary)
            
            Text("Powered by AI Phase Engine")
                .font(.custom("Sniglet-Regular", size: 11))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    var aiRiskCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack {
                Text("AI Health Risk 🩺")
                    .font(.custom("Sniglet-ExtraBold", size: 16))
                Spacer()
                Image(systemName: "heart.text.square")
                    .foregroundStyle(Theme.accentPink)
            }
            
            let lengths = cycleLogs.map { Double($0.cycleLength) }
            let stdDev = calculateStdDev(lengths)
            let stressScore = Double(avg(\.stress))
            let hasPCOS = profiles.first?.hasPCOS ?? false
            
            let risk = RiskEngine.calculate(stdDeviation: stdDev, stressScore: stressScore, hasPCOS: hasPCOS)
            
            HStack {
                Text("Assessed Risk Level:")
                    .font(.custom("Sniglet-Regular", size: 14))
                
                Text(risk.rawValue)
                    .font(.custom("Sniglet-ExtraBold", size: 14))
                    .foregroundStyle(riskColor(for: risk))
            }
            
            Text("Based on cycle variance, stress levels, and profile data.")
                .font(.custom("Sniglet-Regular", size: 12))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    func calculateStdDev(_ array: [Double]) -> Double {
        guard array.count > 1 else { return 0.0 }
        let mean = array.reduce(0, +) / Double(array.count)
        let v = array.reduce(0) { $0 + ($1 - mean) * ($1 - mean) }
        return sqrt(v / Double(array.count - 1))
    }
    
    func riskColor(for risk: RiskLevel) -> Color {
        switch risk {
        case .low: return .green
        case .moderate: return .orange
        case .high: return .red
        }
    }
}

////////////////////////////////////////////////////////////
// MARK: - Mock Data
////////////////////////////////////////////////////////////

extension InsightsView {
    
    var mockMoodLogs: [DailyLog] {
        let today = Calendar.current.startOfDay(for: Date())
        
        return (0..<7).map { i in
            let date = Calendar.current.date(byAdding: .day, value: -i, to: today)!
            
            let log = DailyLog(date: date)
            log.mood = [5,6,7,8,6,7,9][i]   // stable nice curve
            log.pain = 2
            log.energy = 6
            log.sleep = 7
            log.stress = 4
            
            return log
        }.reversed()
    }
}

////////////////////////////////////////////////////////////
// MARK: - Helpers
////////////////////////////////////////////////////////////

extension InsightsView {
    
    func avg(_ keyPath: KeyPath<DailyLog, Int>) -> Int {
        guard !dailyLogs.isEmpty else { return 0 }
        let total = dailyLogs.reduce(0) { $0 + $1[keyPath: keyPath] }
        return total / dailyLogs.count
    }
    
    func dayLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "E"
        return f.string(from: date)
    }
}

////////////////////////////////////////////////////////////
// MARK: - Insight Logic
////////////////////////////////////////////////////////////

extension InsightsView {
    
    func insightText() -> String {
        if dailyLogs.isEmpty {
            return "Start logging daily to discover your patterns 💗"
        }
        
        let mood = avg(\.mood)
        let stress = avg(\.stress)
        
        if stress > 7 {
            return "You've been under high stress lately. Try slowing down 🌿"
        } else if mood > 7 {
            return "You've been feeling really good lately ✨ keep it up!"
        } else {
            return "Your patterns are stabilizing. Stay consistent 💗"
        }
    }
}

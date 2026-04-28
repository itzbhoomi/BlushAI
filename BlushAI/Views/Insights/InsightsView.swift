import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    
    @Query(sort: \DailyLog.date)
    var dailyLogs: [DailyLog]
    
    @Query(sort: \CycleLog.startDate, order: .reverse)
    var cycleLogs: [CycleLog]
    
    @Query var profiles: [UserProfile]
    
    @State private var selectedSheet: InsightSheetType?
    
    enum InsightSheetType: Identifiable {
        case phase, risk, suggestions
        case mood, sleep, energy
        var id: Self { self }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                
                highlightCard
                
                // MASONRY LAYOUT FOR CHARTS AND MINIS
                HStack(alignment: .top, spacing: 12) {
                    
                    // LEFT COLUMN
                    VStack(spacing: 12) {
                        moodTrendCard
                        sleepTrendCard
                    }
                    
                    // RIGHT COLUMN
                    VStack(spacing: 12) {
                        energyTrendCard
                        cycleStatsCard
                        wellnessMiniCard
                    }
                }
                
                // FULL WIDTH AI CARDS
                VStack(spacing: 12) {
                    aiPhaseCard
                    aiRiskCard
                    aiSuggestionsCard
                }
                
                Spacer(minLength: 40)
            }
            .padding(18)
        }
        .background(Theme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Your Patterns")
        .sheet(item: $selectedSheet) { sheet in
            sheetContent(for: sheet)
        }
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
// MARK: - Masonry Cards
////////////////////////////////////////////////////////////

extension InsightsView {
    
    var moodTrendCard: some View {
        Button {
            selectedSheet = .mood
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                
                HStack {
                    Text("Mood 📈")
                        .font(.custom("Sniglet-ExtraBold", size: 16))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                
                let logsToUse = dailyLogs.isEmpty ? mockMoodLogs : Array(dailyLogs.suffix(7))
                
                if dailyLogs.isEmpty {
                    Text("Sample data ✨")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Chart {
                    ForEach(logsToUse, id: \.date) { log in
                        LineMark(
                            x: .value("Day", dayLabel(log.date)),
                            y: .value("Mood", log.mood)
                        )
                        .interpolationMethod(.monotone)
                        .foregroundStyle(Theme.accentPink)
                        
                        PointMark(
                            x: .value("Day", dayLabel(log.date)),
                            y: .value("Mood", log.mood)
                        )
                        .foregroundStyle(Theme.accentPink)
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) { _ in
                        AxisValueLabel().font(.caption2)
                    }
                }
                .chartYAxis(.hidden)
                .frame(height: 100)
                
                // AI Insight summary for Mood
                let avgMood = logsToUse.reduce(0) { $0 + $1.mood } / max(1, logsToUse.count)
                Text(avgMood >= 7 ? "AI Insight: Your mood is consistently high this week. ✨" : "AI Insight: Mood fluctuations detected. Get some rest. 🌿")
                    .font(.custom("Sniglet-Regular", size: 11))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(Theme.cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }

    var sleepTrendCard: some View {
        Button {
            selectedSheet = .sleep
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                
                HStack {
                    Text("Sleep 😴")
                        .font(.custom("Sniglet-ExtraBold", size: 16))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                
                let logsToUse = dailyLogs.isEmpty ? mockMoodLogs : Array(dailyLogs.suffix(7))
                
                if dailyLogs.isEmpty {
                    Text("Sample data ✨")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Chart {
                    ForEach(logsToUse, id: \.date) { log in
                        BarMark(
                            x: .value("Day", dayLabel(log.date)),
                            y: .value("Sleep", log.sleep)
                        )
                        .foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .bottom, endPoint: .top))
                        .cornerRadius(4)
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) { _ in
                        AxisValueLabel().font(.caption2)
                    }
                }
                .chartYAxis(.hidden)
                .frame(height: 120) // Adjusted height to sync masonry columns
            }
            .padding(14)
            .background(Theme.cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
    
    var energyTrendCard: some View {
        Button {
            selectedSheet = .energy
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                
                HStack {
                    Text("Energy ⚡️")
                        .font(.custom("Sniglet-ExtraBold", size: 16))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                
                let logsToUse = dailyLogs.isEmpty ? mockMoodLogs : Array(dailyLogs.suffix(7))
                
                if dailyLogs.isEmpty {
                    Text("Sample data ✨")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Chart {
                    ForEach(logsToUse, id: \.date) { log in
                        AreaMark(
                            x: .value("Day", dayLabel(log.date)),
                            y: .value("Energy", log.energy)
                        )
                        .foregroundStyle(LinearGradient(colors: [.orange.opacity(0.6), .yellow.opacity(0.1)], startPoint: .top, endPoint: .bottom))
                        .interpolationMethod(.catmullRom)
                        
                        LineMark(
                            x: .value("Day", dayLabel(log.date)),
                            y: .value("Energy", log.energy)
                        )
                        .foregroundStyle(.orange)
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) { _ in
                        AxisValueLabel().font(.caption2)
                    }
                }
                .chartYAxis(.hidden)
                .frame(height: 90)
                
                // AI Insight summary for Energy
                let avgEnergy = logsToUse.reduce(0) { $0 + $1.energy } / max(1, logsToUse.count)
                Text(avgEnergy >= 6 ? "AI Insight: You have great energy reserves right now! 🚀" : "AI Insight: Energy is a bit low, take it easy. 🛌")
                    .font(.custom("Sniglet-Regular", size: 11))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(Theme.cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
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
// MARK: - AI Insights Cards (Full Width Clickable)
////////////////////////////////////////////////////////////

extension InsightsView {
    
    var aiPhaseCard: some View {
        Button {
            selectedSheet = .phase
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                
                HStack {
                    Text("Phase ✨")
                        .font(.custom("Sniglet-ExtraBold", size: 16))
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                
                let lastStart = cycleLogs.first?.startDate ?? Date()
                let predictedLength = cycleLogs.first?.cycleLength ?? 28
                let phase = PhaseEngine.currentPhase(lastStartDate: lastStart, predictedCycleLength: predictedLength)
                
                Text("You are currently in your **\(phase.rawValue)** phase.")
                    .font(.custom("Sniglet-Regular", size: 14))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Text("Tap for AI Phase Insight")
                    .font(.custom("Sniglet-Regular", size: 11))
                    .foregroundStyle(Theme.accentPink)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
    
    var aiRiskCard: some View {
        Button {
            selectedSheet = .risk
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                
                HStack {
                    Text("Health Risk 🩺")
                        .font(.custom("Sniglet-ExtraBold", size: 16))
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                
                let lengths = cycleLogs.map { Double($0.cycleLength) }
                let stdDev = calculateStdDev(lengths)
                let stressScore = Double(avg(\.stress))
                let hasPCOS = profiles.first?.hasPCOS ?? false
                
                let risk = RiskEngine.calculate(stdDeviation: stdDev, stressScore: stressScore, hasPCOS: hasPCOS)
                
                HStack {
                    Text("Risk Level:")
                        .font(.custom("Sniglet-Regular", size: 14))
                    
                    Text(risk.rawValue)
                        .font(.custom("Sniglet-ExtraBold", size: 14))
                        .foregroundStyle(riskColor(for: risk))
                }
                
                Text("Tap for AI Risk Assessment")
                    .font(.custom("Sniglet-Regular", size: 11))
                    .foregroundStyle(Theme.accentPink)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
    
    var aiSuggestionsCard: some View {
        Button {
            selectedSheet = .suggestions
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                
                HStack {
                    Text("AI Wellness Coach 🌿")
                        .font(.custom("Sniglet-ExtraBold", size: 16))
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                
                Text("Tap for personalized daily suggestions based on your recent activity.")
                    .font(.custom("Sniglet-Regular", size: 14))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Text("Physical & Mental Wellness")
                    .font(.custom("Sniglet-Regular", size: 11))
                    .foregroundStyle(Theme.accentPink)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
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
// MARK: - Sheets
////////////////////////////////////////////////////////////

extension InsightsView {
    
    @ViewBuilder
    func sheetContent(for type: InsightSheetType) -> some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    switch type {
                    case .phase:
                        phaseSheetBody
                    case .risk:
                        riskSheetBody
                    case .suggestions:
                        suggestionsSheetBody
                    case .mood:
                        moodSheetBody
                    case .sleep:
                        sleepSheetBody
                    case .energy:
                        energySheetBody
                    }
                }
                .padding(20)
            }
            .background(Theme.backgroundGradient.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        selectedSheet = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // --- Mood Sheet ---
    var moodSheetBody: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mood Trend Analysis 📈")
                .font(.custom("Sniglet-ExtraBold", size: 28))
                .foregroundStyle(Theme.accentPink)
            
            let logsToUse = dailyLogs.isEmpty ? mockMoodLogs : Array(dailyLogs.suffix(14))
            
            Chart {
                ForEach(logsToUse, id: \.date) { log in
                    LineMark(
                        x: .value("Day", detailedDayLabel(log.date)),
                        y: .value("Mood", log.mood)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(Theme.accentPink)
                    
                    PointMark(
                        x: .value("Day", detailedDayLabel(log.date)),
                        y: .value("Mood", log.mood)
                    )
                    .foregroundStyle(Theme.accentPink)
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { _ in
                    AxisValueLabel().font(.caption2)
                }
            }
            .frame(height: 250)
            .padding(.vertical)
            
            Text("Detailed Breakdown")
                .font(.custom("Sniglet-ExtraBold", size: 18))
            
            let avgMood = logsToUse.reduce(0) { $0 + $1.mood } / max(1, logsToUse.count)
            Text("Your mood has been averaging around \(avgMood)/10 recently.")
                .font(.custom("Sniglet-Regular", size: 15))
                .foregroundStyle(Theme.textPrimary)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("✨ Extended AI Insight")
                    .font(.custom("Sniglet-ExtraBold", size: 16))
                Text(avgMood >= 7 ? "You are experiencing a sustained period of elevated mood! This correlates with good energy and stable stress levels. Keep prioritizing whatever you've been doing." : "There have been some fluctuations in your mood. Make sure you are setting aside time for hobbies, connecting with loved ones, and avoiding burnout.")
                    .font(.custom("Sniglet-Regular", size: 14))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.accentGradient.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // --- Sleep Sheet ---
    var sleepSheetBody: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sleep Trend Analysis 😴")
                .font(.custom("Sniglet-ExtraBold", size: 28))
                .foregroundStyle(.cyan)
            
            let logsToUse = dailyLogs.isEmpty ? mockMoodLogs : Array(dailyLogs.suffix(14))
            
            Chart {
                ForEach(logsToUse, id: \.date) { log in
                    BarMark(
                        x: .value("Day", detailedDayLabel(log.date)),
                        y: .value("Sleep", log.sleep)
                    )
                    .foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .bottom, endPoint: .top))
                    .cornerRadius(4)
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { _ in
                    AxisValueLabel().font(.caption2)
                }
            }
            .frame(height: 250)
            .padding(.vertical)
            
            Text("Detailed Breakdown")
                .font(.custom("Sniglet-ExtraBold", size: 18))
            
            let avgSleep = logsToUse.reduce(0.0) { $0 + $1.sleep } / Double(max(1, logsToUse.count))
            Text("Your sleep duration averages \(String(format: "%.1f", avgSleep)) hours per night.")
                .font(.custom("Sniglet-Regular", size: 15))
                .foregroundStyle(Theme.textPrimary)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("✨ Extended AI Insight")
                    .font(.custom("Sniglet-ExtraBold", size: 16))
                Text(avgSleep >= 7.0 ? "You are getting an optimal amount of rest. This is highly beneficial for your hormonal balance and mood regulation." : "You might be running on a sleep deficit. Try to establish a calming bedtime routine and limit screen time before bed to improve your sleep quality.")
                    .font(.custom("Sniglet-Regular", size: 14))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cyan.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // --- Energy Sheet ---
    var energySheetBody: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Energy Trend Analysis ⚡️")
                .font(.custom("Sniglet-ExtraBold", size: 28))
                .foregroundStyle(.orange)
            
            let logsToUse = dailyLogs.isEmpty ? mockMoodLogs : Array(dailyLogs.suffix(14))
            
            Chart {
                ForEach(logsToUse, id: \.date) { log in
                    AreaMark(
                        x: .value("Day", detailedDayLabel(log.date)),
                        y: .value("Energy", log.energy)
                    )
                    .foregroundStyle(LinearGradient(colors: [.orange.opacity(0.6), .yellow.opacity(0.1)], startPoint: .top, endPoint: .bottom))
                    .interpolationMethod(.catmullRom)
                    
                    LineMark(
                        x: .value("Day", detailedDayLabel(log.date)),
                        y: .value("Energy", log.energy)
                    )
                    .foregroundStyle(.orange)
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { _ in
                    AxisValueLabel().font(.caption2)
                }
            }
            .frame(height: 250)
            .padding(.vertical)
            
            Text("Detailed Breakdown")
                .font(.custom("Sniglet-ExtraBold", size: 18))
            
            let avgEnergy = logsToUse.reduce(0) { $0 + $1.energy } / max(1, logsToUse.count)
            Text("Your energy level is sitting at an average of \(avgEnergy)/10.")
                .font(.custom("Sniglet-Regular", size: 15))
                .foregroundStyle(Theme.textPrimary)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("✨ Extended AI Insight")
                    .font(.custom("Sniglet-ExtraBold", size: 16))
                Text(avgEnergy >= 6 ? "Your energy reserves are great. Capitalize on this by tackling challenging tasks, working out, and being social." : "Your energy levels are on the lower side. Listen to your body and prioritize rest and recovery over strenuous activities.")
                    .font(.custom("Sniglet-Regular", size: 14))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.orange.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // --- Phase Sheet ---
    var phaseSheetBody: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            let lastStart = cycleLogs.first?.startDate ?? Date()
            let predictedLength = cycleLogs.first?.cycleLength ?? 28
            let phase = PhaseEngine.currentPhase(lastStartDate: lastStart, predictedCycleLength: predictedLength)
            
            Text("\(phase.rawValue) Phase")
                .font(.custom("Sniglet-ExtraBold", size: 28))
                .foregroundStyle(Theme.accentPink)
            
            Text("AI Analysis")
                .font(.custom("Sniglet-ExtraBold", size: 18))
            
            let phaseDesc = getPhaseDescription(phase: phase)
            Text(phaseDesc)
                .font(.custom("Sniglet-Regular", size: 15))
                .lineSpacing(4)
                .foregroundStyle(Theme.textPrimary)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("✨ AI Insight")
                    .font(.custom("Sniglet-ExtraBold", size: 16))
                Text("Based on your data, your \(phase.rawValue) phase tends to bring varying energy levels. This is completely normal. Keep tracking your daily logs to see more precise patterns over time.")
                    .font(.custom("Sniglet-Regular", size: 14))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.accentGradient.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func getPhaseDescription(phase: CyclePhase) -> String {
        switch phase {
        case .menstrual:
            return "Your body is shedding its uterine lining. Energy is typically at its lowest, and you might feel more introspective. Rest and gentle movement are key."
        case .follicular:
            return "Estrogen is rising. You'll likely feel a boost in energy, creativity, and sociability. It's a great time to start new projects or engage in high-intensity workouts."
        case .ovulation:
            return "Estrogen peaks and an egg is released. Energy and confidence are usually at their highest. You might feel more communicative and energetic."
        case .luteal:
            return "Progesterone rises, bringing a natural wind-down. You may experience PMS symptoms like bloating or mood shifts. Focus on grounding activities and self-care."
        }
    }
    
    // --- Risk Sheet ---
    var riskSheetBody: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Health Risk Assessment")
                .font(.custom("Sniglet-ExtraBold", size: 28))
                .foregroundStyle(Theme.accentPink)
            
            let lengths = cycleLogs.map { Double($0.cycleLength) }
            let stdDev = calculateStdDev(lengths)
            let stressScore = Double(avg(\.stress))
            let hasPCOS = profiles.first?.hasPCOS ?? false
            let risk = RiskEngine.calculate(stdDeviation: stdDev, stressScore: stressScore, hasPCOS: hasPCOS)
            
            HStack {
                Text("Current Risk Level:")
                    .font(.custom("Sniglet-ExtraBold", size: 18))
                Text(risk.rawValue)
                    .font(.custom("Sniglet-ExtraBold", size: 18))
                    .foregroundStyle(riskColor(for: risk))
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("AI Breakdown")
                    .font(.custom("Sniglet-ExtraBold", size: 16))
                
                HStack(alignment: .top) {
                    Image(systemName: "chart.xyaxis.line")
                        .foregroundStyle(.blue)
                        .frame(width: 20)
                    Text("Cycle Variance: Your average cycle variance is \(String(format: "%.1f", stdDev)) days. \(stdDev > 5 ? "This high variance could indicate irregular cycles." : "This is within a healthy range.")")
                        .font(.custom("Sniglet-Regular", size: 14))
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "brain.head.profile")
                        .foregroundStyle(.orange)
                        .frame(width: 20)
                    Text("Stress Levels: Your average stress score is \(Int(stressScore)). \(stressScore > 6 ? "High stress is heavily impacting your wellness." : "Stress levels appear manageable right now.")")
                        .font(.custom("Sniglet-Regular", size: 14))
                }
                
                if hasPCOS {
                    HStack(alignment: .top) {
                        Image(systemName: "staroflife.fill")
                            .foregroundStyle(.red)
                            .frame(width: 20)
                        Text("PCOS Profile: Your PCOS profile influences risk calculations, prioritizing symptom tracking and variance monitoring.")
                            .font(.custom("Sniglet-Regular", size: 14))
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 10) {
                Text("💡 AI Recommendation")
                    .font(.custom("Sniglet-ExtraBold", size: 16))
                Text(risk == .high ? "Your risk level is high due to a combination of stress and cycle irregularity. We recommend consulting a healthcare provider for a personalized evaluation." : "Your risk is currently manageable. Continue logging your symptoms daily to keep the AI model accurate.")
                    .font(.custom("Sniglet-Regular", size: 14))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.accentGradient.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // --- Suggestions Sheet ---
    var suggestionsSheetBody: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("AI Wellness Coach")
                .font(.custom("Sniglet-ExtraBold", size: 28))
                .foregroundStyle(Theme.accentPink)
            
            Text("Based on your recent logs, here are some personalized suggestions to help you feel your best today.")
                .font(.custom("Sniglet-Regular", size: 15))
                .foregroundStyle(Theme.textPrimary)
            
            let avgEnergy = avg(\.energy)
            let avgMood = avg(\.mood)
            let avgStress = avg(\.stress)
            
            VStack(alignment: .leading, spacing: 16) {
                
                // Physical
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("🏃‍♀️ Physical Wellness")
                            .font(.custom("Sniglet-ExtraBold", size: 16))
                    }
                    Text(avgEnergy < 5 ? "Your energy is low. Opt for gentle stretching, yoga, or a short walk instead of intense cardio today." : "You have good energy! It's a great day for strength training, a run, or a dance class.")
                        .font(.custom("Sniglet-Regular", size: 14))
                        .foregroundStyle(.secondary)
                }
                
                Divider().background(.white.opacity(0.2))
                
                // Mental
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("🧠 Mental Wellness")
                            .font(.custom("Sniglet-ExtraBold", size: 16))
                    }
                    Text(avgStress > 6 ? "Stress is elevated. Try a 5-minute deep breathing exercise or a guided meditation before bed to lower cortisol." : "Your mental state seems stable. Keep up your current routines, and maybe take a moment for a gratitude journal.")
                        .font(.custom("Sniglet-Regular", size: 14))
                        .foregroundStyle(.secondary)
                }
                
                Divider().background(.white.opacity(0.2))
                
                // Nutrition/Care
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("🍎 Nutrition & Care")
                            .font(.custom("Sniglet-ExtraBold", size: 16))
                    }
                    Text(avgMood < 6 ? "Your mood has dipped. Ensure you are eating nutrient-dense foods rich in Omega-3s and Magnesium, like dark chocolate, nuts, and salmon." : "Keep hydrating! Drinking at least 8 glasses of water a day will help maintain your balanced mood and energy.")
                        .font(.custom("Sniglet-Regular", size: 14))
                        .foregroundStyle(.secondary)
                }
                
            }
            .padding(18)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Text("These suggestions update dynamically as you log more data.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

////////////////////////////////////////////////////////////
// MARK: - Mock Data
////////////////////////////////////////////////////////////

extension InsightsView {
    
    var mockMoodLogs: [DailyLog] {
        let today = Calendar.current.startOfDay(for: Date())
        
        return (0..<14).map { i in
            let date = Calendar.current.date(byAdding: .day, value: -i, to: today)!
            
            let log = DailyLog(date: date)
            log.mood = [5,6,7,8,6,7,9,6,5,4,5,7,8,9][i]
            log.pain = 2
            log.energy = [4,5,6,8,7,5,8,4,3,5,6,7,8,7][i]
            log.sleep = [6,7,8,7,6,7,8,5,6,7,8,7,6,7][i]
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
    
    func detailedDayLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "M/d"
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

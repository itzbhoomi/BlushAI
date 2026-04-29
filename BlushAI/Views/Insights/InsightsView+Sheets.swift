import SwiftUI
import SwiftData
import Charts

// ////////////////////////////////////////////////////////////
// MARK: - Sheets
// ////////////////////////////////////////////////////////////



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
        
        let logsToUse = dailyLogs.isEmpty ? mockMoodLogs : Array(dailyLogs.suffix(14))
        
        return VStack(alignment: .leading, spacing: 16) {
            
            Text("Mood Trend Analysis 📈")
                .font(.custom("Sniglet-ExtraBold", size: 28))
                .foregroundStyle(Theme.accentPink)
            
            // MARK: Chart
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
            .frame(height: 250)
            .padding(.vertical)
            
            Text("Detailed Breakdown")
                .font(.custom("Sniglet-ExtraBold", size: 18))
            
            let avgMood = logsToUse.reduce(0) { $0 + $1.mood } / max(1, logsToUse.count)
            
            Text("Your mood has been averaging around \(avgMood)/10 recently.")
            
            VStack(alignment: .leading, spacing: 10) {
                Text("✨Extended AI Insight")
                    .font(.custom("Sniglet-ExtraBold", size: 18))
                
                if isGeneratingInsight {
                    ProgressView()
                } else {
                    Text(aiInsight.isEmpty ? "Generating insight..." : aiInsight)
                        .font(.custom("Sniglet-Regular", size: 14))
                }
            }
            .padding(10)
            .background(Color.pink.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
        }
        
        .task(id: logsToUse.map(\.date)) {
            await generateMoodInsight(logs: logsToUse)
        }
    }
    
    // --- Sleep Sheet ---
    var sleepSheetBody: some View {
        
        let logsToUse = dailyLogs.isEmpty ? mockMoodLogs : Array(dailyLogs.suffix(14))
        
        return VStack(alignment: .leading, spacing: 16) {
            
            Text("Sleep Trend Analysis 😴")
                .font(.custom("Sniglet-ExtraBold", size: 28))
                .foregroundStyle(.cyan)
            
            // MARK: Chart
            Chart {
                ForEach(logsToUse, id: \.date) { log in
                    BarMark(
                        x: .value("Day", detailedDayLabel(log.date)),
                        y: .value("Sleep", log.sleep)
                    )
                    .foregroundStyle(
                        LinearGradient(colors: [.blue, .cyan], startPoint: .bottom, endPoint: .top)
                    )
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
            
            // MARK: Stats
            Text("Detailed Breakdown")
                .font(.custom("Sniglet-ExtraBold", size: 18))
            
            let avgSleep = logsToUse.reduce(0.0) { $0 + $1.sleep } / Double(max(1, logsToUse.count))
            
            Text("Your sleep duration averages \(String(format: "%.1f", avgSleep)) hours per night.")
                .font(.custom("Sniglet-Regular", size: 15))
                .foregroundStyle(Theme.textPrimary)
            
            // MARK: AI Insight
            VStack(alignment: .leading, spacing: 10) {
                
                Text("✨ AI Insight")
                    .font(.custom("Sniglet-ExtraBold", size: 16))
                
                if isGeneratingSleepInsight {
                    HStack {
                        ProgressView()
                        Text("Analyzing your sleep patterns...")
                            .font(.custom("Sniglet-Regular", size: 14))
                    }
                } else {
                    Text(sleepInsight.isEmpty ? "Generating insight..." : sleepInsight)
                        .font(.custom("Sniglet-Regular", size: 14))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cyan.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        // MARK: Trigger AI
        .task(id: logsToUse.map(\.date)) {
            await generateSleepInsight(logs: logsToUse)
        }
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
        
        let lastStart = cycleLogs.first?.startDate ?? Date()
        let predictedLength = cycleLogs.first?.cycleLength ?? 28
        let phase = PhaseEngine.currentPhase(
            lastStartDate: lastStart,
            predictedCycleLength: predictedLength
        )
        
        return VStack(alignment: .leading, spacing: 16) {
            
            Text("\(phase.rawValue) Phase")
                .font(.custom("Sniglet-ExtraBold", size: 28))
                .foregroundStyle(Theme.accentPink)
            
            Text("About this phase")
                .font(.custom("Sniglet-ExtraBold", size: 18))
            
            let phaseDesc = getPhaseDescription(phase: phase)
            
            Text(phaseDesc)
                .font(.custom("Sniglet-Regular", size: 15))
                .lineSpacing(4)
                .foregroundStyle(Theme.textPrimary)
            
            // MARK: AI Insight
            VStack(alignment: .leading, spacing: 10) {
                
                Text("✨ Personalized Insight")
                    .font(.custom("Sniglet-ExtraBold", size: 16))
                
                if isGeneratingPhaseInsight {
                    HStack {
                        ProgressView()
                        Text("Understanding your current phase...")
                            .font(.custom("Sniglet-Regular", size: 14))
                    }
                } else {
                    Text(phaseInsight.isEmpty ? "Generating insight..." : phaseInsight)
                        .font(.custom("Sniglet-Regular", size: 14))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.accentGradient.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        // MARK: Trigger AI
        .task(id: "\(phase.rawValue)-\(lastStart)") {
            await generatePhaseInsight(
                phase: phase,
                lastStart: lastStart,
                predictedLength: predictedLength
            )
        }
    }
    // --- Risk Sheet ---
    var riskSheetBody: some View {
        
        let lengths = cycleLogs.map { Double($0.cycleLength) }
        let stdDev = calculateStdDev(lengths)
        let stressScore = Double(avg(\.stress))
        let hasPCOS = profiles.first?.hasPCOS ?? false
        let risk = RiskEngine.calculate(
            stdDeviation: stdDev,
            stressScore: stressScore,
            hasPCOS: hasPCOS
        )
        
        return VStack(alignment: .leading, spacing: 16) {
            
            Text("Health Risk Assessment")
                .font(.custom("Sniglet-ExtraBold", size: 28))
                .foregroundStyle(Theme.accentPink)
            
            // MARK: Risk Level
            HStack {
                Text("Current Risk Level:")
                    .font(.custom("Sniglet-ExtraBold", size: 18))
                Text(risk.rawValue)
                    .font(.custom("Sniglet-ExtraBold", size: 18))
                    .foregroundStyle(riskColor(for: risk))
            }
            
            // MARK: AI Insight (Replaces breakdown + recommendation)
            VStack(alignment: .leading, spacing: 10) {
                
                Text("✨ AI Insight")
                    .font(.custom("Sniglet-ExtraBold", size: 16))
                
                if isGeneratingRiskInsight {
                    HStack {
                        ProgressView()
                        Text("Analyzing your health patterns...")
                            .font(.custom("Sniglet-Regular", size: 14))
                    }
                } else {
                    Text(riskInsight.isEmpty ? "Generating insight..." : riskInsight)
                        .font(.custom("Sniglet-Regular", size: 14))
                }
                
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.accentGradient.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        // MARK: Trigger AI
        .task(id: "\(stdDev)-\(stressScore)-\(hasPCOS)") {
            await generateRiskInsight(
                stdDev: stdDev,
                stress: stressScore,
                hasPCOS: hasPCOS,
                risk: risk
            )
        }
    }
    
    // --- Suggestions Sheet ---
    var suggestionsSheetBody: some View {
        
        let logsToUse = dailyLogs.isEmpty ? mockMoodLogs : Array(dailyLogs.suffix(14))
        
        return VStack(alignment: .leading, spacing: 16) {
            
            Text("AI Wellness Coach")
                .font(.custom("Sniglet-ExtraBold", size: 28))
                .foregroundStyle(Theme.accentPink)
            
            Text("Personalized guidance based on your recent patterns.")
                .font(.custom("Sniglet-Regular", size: 15))
                .foregroundStyle(Theme.textPrimary)
            
            VStack(alignment: .leading, spacing: 16) {
                
                if isGeneratingSuggestions {
                    HStack {
                        ProgressView()
                        Text("Creating your wellness plan...")
                            .font(.custom("Sniglet-Regular", size: 16))
                    }
                } else {
                    
                    // Physical
                    VStack(alignment: .leading, spacing: 6) {
                        Text("🏃‍♀️ Physical Wellness")
                            .font(.custom("Sniglet-ExtraBold", size: 16))
                        
                        Text(physicalSuggestion)
                            .font(.custom("Sniglet-Regular", size: 14))
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider().background(.white.opacity(0.2))
                    
                    // Mental
                    VStack(alignment: .leading, spacing: 6) {
                        Text("🧠 Mental Wellness")
                            .font(.custom("Sniglet-ExtraBold", size: 16))
                        
                        Text(mentalSuggestion)
                            .font(.custom("Sniglet-Regular", size: 14))
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider().background(.white.opacity(0.2))
                    
                    // Nutrition
                    VStack(alignment: .leading, spacing: 6) {
                        Text("🍎 Nutrition & Care")
                            .font(.custom("Sniglet-ExtraBold", size: 16))
                        
                        Text(nutritionSuggestion)
                            .font(.custom("Sniglet-Regular", size: 14))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(18)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Text("These adapt as your patterns evolve.")
                .font(.custom("Sniglet-Regular", size: 12))
                .foregroundStyle(.secondary)
                .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        .task(id: logsToUse.map(\.date)) {
            await generateSuggestions()
        }
    }
}

import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    
    @Query(sort: \DailyLog.date)
    var dailyLogs: [DailyLog]
    
    @Query(sort: \CycleLog.startDate, order: .reverse)
    var cycleLogs: [CycleLog]
    
    @Query var profiles: [UserProfile]
    @State var aiInsight: String = ""
    @State var isGeneratingInsight = false
    @State var selectedSheet: InsightSheetType?
    @State var sleepInsight: String = ""
    @State var isGeneratingSleepInsight = false
    @State var riskInsight: String = ""
    @State var isGeneratingRiskInsight = false
    @State var phaseInsight: String = ""
    @State var isGeneratingPhaseInsight = false
    @State var physicalSuggestion: String = ""
    @State var mentalSuggestion: String = ""
    @State var nutritionSuggestion: String = ""
    @State var isGeneratingSuggestions = false
    
    enum InsightSheetType: Identifiable {
        case phase, risk, suggestions
        case mood, sleep, energy
        var id: Self { self }
    }
    
    func generateMoodInsight(logs: [DailyLog]) async {
        
        guard !logs.isEmpty else { return }
        
        isGeneratingInsight = true
        
        let moods = logs.map { $0.mood }
        let avgMood = moods.reduce(0, +) / moods.count
        
        let avgStress = logs.compactMap { $0.stress }.reduce(0, +) / max(1, logs.count)
        let avgSleep = logs.compactMap { $0.sleep }.reduce(0, +) / Double(max(1, logs.count))
        
        let result = await AIService.shared.generateTrendInsight(
            moods: moods,
            avgSleep: avgSleep,
            avgStress: avgStress
        )
        
        aiInsight = result
        isGeneratingInsight = false
    }
    
    func generateSleepInsight(logs: [DailyLog]) async {
        
        guard !logs.isEmpty else { return }
        if !sleepInsight.isEmpty { return } // prevent reruns
        
        isGeneratingSleepInsight = true
        
        let sleepValues = logs.map { $0.sleep }
        let avgSleep = sleepValues.reduce(0, +) / Double(sleepValues.count)
        
        let result = await AIService.shared.generateSleepInsight(
            sleepValues: sleepValues,
            avgSleep: avgSleep
        )
        
        sleepInsight = result
        isGeneratingSleepInsight = false
    }
    
    func generateRiskInsight(
        stdDev: Double,
        stress: Double,
        hasPCOS: Bool,
        risk: RiskLevel
    ) async {
        
        if !riskInsight.isEmpty { return }
        
        isGeneratingRiskInsight = true
        
        let result = await AIService.shared.generateRiskInsight(
            stdDev: stdDev,
            stress: stress,
            hasPCOS: hasPCOS,
            riskLevel: risk.rawValue
        )
        
        riskInsight = result
        isGeneratingRiskInsight = false
    }
    
    func generatePhaseInsight(
        phase: CyclePhase,
        lastStart: Date,
        predictedLength: Int
    ) async {
        
        if !phaseInsight.isEmpty { return }
        
        isGeneratingPhaseInsight = true
        
        // derive cycle day
        let cycleDay = Calendar.current.dateComponents(
            [.day],
            from: lastStart,
            to: Date()
        ).day ?? 0
        
        let logsToUse = dailyLogs.isEmpty ? mockMoodLogs : Array(dailyLogs.suffix(14))
        
        let avgMood = logsToUse.reduce(0) { $0 + $1.mood } / max(1, logsToUse.count)
        let avgEnergy = logsToUse.reduce(0) { $0 + $1.energy } / max(1, logsToUse.count)
        
        let stressValues = logsToUse.compactMap { $0.stress }
        let avgStress = stressValues.isEmpty ? 0 : stressValues.reduce(0, +) / stressValues.count
        
        let result = await AIService.shared.generatePhaseInsight(
            phase: phase.rawValue,
            cycleDay: cycleDay,
            avgMood: avgMood,
            avgEnergy: avgEnergy,
            avgStress: avgStress
        )
        
        phaseInsight = result
        isGeneratingPhaseInsight = false
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
    
    func generateSuggestions() async {
        
        if !physicalSuggestion.isEmpty { return }
        
        isGeneratingSuggestions = true
        
        let logsToUse = dailyLogs.isEmpty ? mockMoodLogs : Array(dailyLogs.suffix(14))
        
        let avgMood = logsToUse.reduce(0) { $0 + $1.mood } / max(1, logsToUse.count)
        let avgEnergy = logsToUse.reduce(0) { $0 + $1.energy } / max(1, logsToUse.count)
        
        let stressValues = logsToUse.compactMap { $0.stress }
        let avgStress = stressValues.isEmpty ? 0 : stressValues.reduce(0, +) / stressValues.count
        
        let avgSleep = logsToUse.reduce(0.0) { $0 + $1.sleep } / Double(max(1, logsToUse.count))
        
        let result = await AIService.shared.generateWellnessSuggestions(
            avgMood: avgMood,
            avgEnergy: avgEnergy,
            avgStress: avgStress,
            avgSleep: avgSleep
        )
        
        physicalSuggestion = result.physical
        mentalSuggestion = result.mental
        nutritionSuggestion = result.nutrition
        
        isGeneratingSuggestions = false
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

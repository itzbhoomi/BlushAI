import SwiftUI
import SwiftData

// ////////////////////////////////////////////////////////////
// MARK: - AI Insights Cards (Full Width Clickable)
// ////////////////////////////////////////////////////////////

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

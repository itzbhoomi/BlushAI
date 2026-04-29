import SwiftUI
import SwiftData

// ////////////////////////////////////////////////////////////
// MARK: - Highlight Card
// ////////////////////////////////////////////////////////////

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

// ////////////////////////////////////////////////////////////
// MARK: - Cycle Stats
// ////////////////////////////////////////////////////////////

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
                    .font(.custom("Sniglet-Regular", size: 16))
                
                Text("avg length")
                    .font(.custom("Sniglet-Regular", size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// ////////////////////////////////////////////////////////////
// MARK: - Wellness Mini
// ////////////////////////////////////////////////////////////

extension InsightsView {
    
    var wellnessMiniCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text("Wellness 💗")
                .font(.custom("Sniglet-ExtraBold", size: 14))
            
            if dailyLogs.isEmpty {
                Text("Please Log data to see insights")
                    .font(.custom("Sniglet-Regular", size: 10))
                
                Text("avg score (sample)")
                    .font(.custom("Sniglet-Regular", size: 10))
                    .foregroundStyle(.secondary)
            } else {
                Text("Mood \(avg(\.mood))")
                    .font(.custom("Sniglet-Regular", size: 16))
                
                Text("avg score")
                    .font(.custom("Sniglet-Regular", size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

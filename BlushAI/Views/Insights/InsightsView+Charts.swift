import SwiftUI
import SwiftData
import Charts

// ////////////////////////////////////////////////////////////
// MARK: - Masonry Cards
// ////////////////////////////////////////////////////////////

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

import SwiftUI
import SwiftData

// ////////////////////////////////////////////////////////////
// MARK: - Mock Data
// ////////////////////////////////////////////////////////////

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

// ////////////////////////////////////////////////////////////
// MARK: - Helpers
// ////////////////////////////////////////////////////////////

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

// ////////////////////////////////////////////////////////////
// MARK: - Insight Logic
// ////////////////////////////////////////////////////////////

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

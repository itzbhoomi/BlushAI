//
//  CycleEngine.swift
//  BlushAI
//
//  Created by Bhoomi on 28/04/26.
//

import SwiftUI
import Foundation

enum DayType {
    case period
    case fertile
    case ovulation
    case normal
}

struct CycleEngine {
    
    static func dayType(for date: Date, logs: [CycleLog]) -> DayType {
        
        guard let log = logs.sorted(by: { $0.startDate > $1.startDate }).first else {
            print("❌ No logs found")
            return .normal
        }
        
        let calendar = Calendar.current
        
        let start = calendar.startOfDay(for: log.startDate)
        let target = calendar.startOfDay(for: date)
        
        let diff = calendar.dateComponents([.day], from: start, to: target).day ?? 0
        
        print("🧠 Using log:", start)
        print("📅 Target:", target)
        print("📏 Diff:", diff)
        
        if diff < 0 {
            return .normal
        }
        
        let day = diff % log.cycleLength
        
        print("🔁 Cycle day:", day)
        
        let periodLength = max(log.periodLength, 5)

        if day < periodLength  {
            return .period
        }
        
        let ovulationDay = log.cycleLength - 14
        
        if day == ovulationDay {
            return .ovulation
        }
        
        if (ovulationDay - 4)...(ovulationDay + 1) ~= day {
            return .fertile
        }
        
        return .normal
    }
    
    static func phaseText(for type: DayType) -> String {
        switch type {
        case .period: return "Menstrual Phase"
        case .fertile: return "Fertile Window"
        case .ovulation: return "Ovulation"
        case .normal: return "Normal Phase"
        }
    }
    
    static func color(for type: DayType) -> Color {
        switch type {
        case .period: return .red
        case .fertile: return .purple.opacity(0.6)
        case .ovulation: return .pink
        case .normal: return Theme.textMuted.opacity(0.3)
        }
    }
}

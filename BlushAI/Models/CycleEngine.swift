//
//  CycleEngine.swift
//  BlushAI
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
    
    // ✅ Pass latest log directly (no sorting inside)
    static func dayType(for date: Date, log: CycleLog?) -> DayType {
        
        guard let log else {
            return .normal
        }
        
        let calendar = Calendar.current
        
        let start = calendar.startOfDay(for: log.startDate)
        let target = calendar.startOfDay(for: date)
        
        let diff = calendar.dateComponents([.day], from: start, to: target).day ?? 0
        
        // before cycle start
        if diff < 0 {
            return .normal
        }
        
        let day = diff % log.cycleLength
        
        let periodLength = max(log.periodLength, 5)
        
        // period phase
        if day < periodLength {
            return .period
        }
        
        // ovulation
        let ovulationDay = log.cycleLength - 14
        
        if day == ovulationDay {
            return .ovulation
        }
        
        // fertile window
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

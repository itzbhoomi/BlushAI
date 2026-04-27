//
//  RiskEngine.swift
//  Blush
//
//  Created by Bhoomi on 27/04/26.
//

import Foundation

enum RiskLevel: String {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
}

struct RiskEngine {

    static func calculate(
        stdDeviation: Double,
        stressScore: Double,
        hasPCOS: Bool
    ) -> RiskLevel {

        var score = 0

        if stdDeviation > 5 { score += 2 }
        else if stdDeviation > 2 { score += 1 }

        if stressScore > 7 { score += 1 }

        if hasPCOS { score += 2 }

        switch score {
        case 0...1:
            return .low
        case 2...3:
            return .moderate
        default:
            return .high
        }
    }
}

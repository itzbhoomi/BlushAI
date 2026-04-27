//
//  PhaseEngine.swift
//  Blush
//
//  Created by Bhoomi on 27/04/26.
//

import Foundation

enum CyclePhase: String {
    case menstrual = "Menstrual"
    case follicular = "Follicular"
    case ovulation = "Ovulation"
    case luteal = "Luteal"
}

struct PhaseEngine {

    static func currentPhase(
        lastStartDate: Date,
        predictedCycleLength: Int
    ) -> CyclePhase {

        let today = Date()

        let days = Calendar.current.dateComponents(
            [.day],
            from: lastStartDate,
            to: today
        ).day ?? 0

        let cycleDay = max(1, days + 1)

        if cycleDay <= 5 {
            return .menstrual
        } else if cycleDay <= 13 {
            return .follicular
        } else if cycleDay <= 16 {
            return .ovulation
        } else if cycleDay <= predictedCycleLength {
            return .luteal
        } else {
            return .menstrual
        }
    }
}

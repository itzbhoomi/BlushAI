//
//  CyclePredictionEngine.swift
//  BlushAI
//
//  Created by Bhoomi on 29/04/26.
//


import Foundation

final class CyclePredictionEngine {
    
    static let shared = CyclePredictionEngine()
    
    private init() {}
    
    func nextPeriodDate(from logs: [CycleLog]) -> Date? {
        guard let lastLog = logs.first else { return nil }
        
        let features = CycleFeatureBuilder.build(from: logs)
        
        let predictedLength = PredictionService.shared.predictCycleLength(
            cycleNumber: logs.count,
            cycleLengthDays: Double(lastLog.cycleLength),
            prevCycleLength: Double(lastLog.cycleLength),
            painLevel: lastLog.painLevel,
            moodScore: lastLog.moodScore,
            stressScoreCycle: Double(lastLog.stressScore),
            sleepHoursCycle: lastLog.sleepHours,
            energyLevel: 5,
            concentrationScore: 5,
            overallHealthScore: 5,
            age: 22,
            bmi: 22,
            sleepHours: features.avgSleep,
            stressScoreBaseline: features.baselineStress,
            avgLast3Cycles: features.avgLast3,
            stdLast6Cycles: features.stdLast6,
            cyclePhase: 0,
            flowLevel: lastLog.flowLevel,
            pmsSymptoms: 2,
            dietQuality: 5,
            exerciseFrequency: 3,
            birthControlUse: 0,
            pcosDiagnosed: 0
        )
        
        return PredictionService.shared.predictNextDate(
            lastStartDate: lastLog.startDate,
            predictedCycleLength: predictedLength
        )
    }
}
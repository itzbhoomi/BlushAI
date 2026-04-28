//
//  CycleFeatures.swift
//  BlushAI
//
//  Created by Bhoomi on 29/04/26.
//


import Foundation

struct CycleFeatures {
    let avgLast3: Double
    let stdLast6: Double
    let baselineStress: Double
    let avgSleep: Double
}

final class CycleFeatureBuilder {
    
    static func build(from logs: [CycleLog]) -> CycleFeatures {
        
        let sorted = logs.sorted { $0.startDate < $1.startDate }
        let lengths = sorted.map { Double($0.cycleLength) }
        
        // Last 3 avg
        let last3 = Array(lengths.suffix(3))
        let avgLast3 = last3.isEmpty ? 28 : last3.reduce(0, +) / Double(last3.count)
        
        // Last 6 std deviation
        let last6 = Array(lengths.suffix(6))
        let mean = last6.isEmpty ? 28 : last6.reduce(0, +) / Double(last6.count)
        
        let variance = last6.map { pow($0 - mean, 2) }.reduce(0, +) / Double(max(last6.count, 1))
        let stdLast6 = sqrt(variance)
        
        // Baseline stress
        let stressValues = sorted.map { Double($0.stressScore) }
        let baselineStress = stressValues.isEmpty ? 5 : stressValues.reduce(0, +) / Double(stressValues.count)
        
        // Avg sleep
        let sleepValues = sorted.map { $0.sleepHours }
        let avgSleep = sleepValues.isEmpty ? 7 : sleepValues.reduce(0, +) / Double(sleepValues.count)
        
        return CycleFeatures(
            avgLast3: avgLast3,
            stdLast6: stdLast6,
            baselineStress: baselineStress,
            avgSleep: avgSleep
        )
    }
}
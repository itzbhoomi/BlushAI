//
//  UserProfile.swift
//  BlushAI
//
//  Created by Bhoomi on 27/04/26.
//


import Foundation
import SwiftData

@Model
final class UserProfile {

    var name: String
    var age: Int
    var bmi: Double
    var hasPCOS: Bool
    var sleepHours: Double
    var baselineStress: Double

    init(
        name: String = "Bhoomi",
        age: Int = 22,
        bmi: Double = 21.0,
        hasPCOS: Bool = false,
        sleepHours: Double = 7.0,
        baselineStress: Double = 5.0
    ) {
        self.name = name
        self.age = age
        self.bmi = bmi
        self.hasPCOS = hasPCOS
        self.sleepHours = sleepHours
        self.baselineStress = baselineStress
    }
}

@Model
final class CycleLog {

    var startDate: Date
    var cycleLength: Int
    var painLevel: Int
    var moodScore: Int
    var stressScore: Double
    var sleepHours: Double
    var flowLevel: Int

    init(
        startDate: Date,
        cycleLength: Int,
        painLevel: Int,
        moodScore: Int,
        stressScore: Double,
        sleepHours: Double,
        flowLevel: Int
    ) {
        self.startDate = startDate
        self.cycleLength = cycleLength
        self.painLevel = painLevel
        self.moodScore = moodScore
        self.stressScore = stressScore
        self.sleepHours = sleepHours
        self.flowLevel = flowLevel
    }
}
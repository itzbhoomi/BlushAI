//
//  DailyLog.swift
//  BlushAI
//
//  Created by Bhoomi on 28/04/26.
//


import SwiftData
import Foundation

@Model
class DailyLog {
    var date: Date
    
    var mood: Int
    var pain: Int
    var energy: Int
    var sleep: Double
    var stress: Int
    
    init(date: Date) {
        self.date = date
        self.mood = 5
        self.pain = 0
        self.energy = 5
        self.sleep = 7
        self.stress = 5
    }
}
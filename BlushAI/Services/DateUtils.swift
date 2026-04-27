//
//  DateUtils.swift
//  Blush
//
//  Created by Bhoomi on 27/04/26.
//


import Foundation

struct DateUtils {

    static func daysUntil(_ futureDate: Date) -> Int {

        let days = Calendar.current.dateComponents(
            [.day],
            from: Date(),
            to: futureDate
        ).day ?? 0

        return max(0, days)
    }

    static func short(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
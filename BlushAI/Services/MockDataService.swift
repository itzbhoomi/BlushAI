//
//  MockDataService.swift
//  Blush
//
//  Created by Bhoomi on 27/04/26.
//


import Foundation
import Combine

@MainActor
final class MockDataService: ObservableObject {

    static let shared = MockDataService()

    private init() {}

    let userName = "Bhoomi"
    let nextPeriodDays = 3
}

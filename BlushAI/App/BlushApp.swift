//
//  BlushApp.swift
//  Blush
//
//  Created by Bhoomi on 27/04/26.
//

import SwiftUI
import SwiftData
import Combine

@main
struct BlushAIApp: App {

    @StateObject var aiService = AIService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(aiService)
        }
        .modelContainer(for: [
            UserProfile.self,
            CycleLog.self
        ])
    }
}

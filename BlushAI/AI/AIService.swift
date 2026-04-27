//
// AIService.swift
//

import Foundation
import Combine
import FoundationModels

@MainActor
final class AIService: ObservableObject {

    static let shared = AIService()

    @Published var isLoading = false

    private let session = LanguageModelSession()

    private init() {}

    // MARK: Mood Engine (REAL AI)

    func generateMoodInsight(
        selectedMood: String,
        phase: String,
        cycleDay: Int,
        sleep: Double,
        stress: Double,
        risk: String
    ) async -> String {

        print("========== AI DEBUG START ==========")
        print("Mood:", selectedMood)
        print("Phase:", phase)
        print("Cycle Day:", cycleDay)
        print("Sleep:", sleep)
        print("Stress:", stress)
        print("Risk:", risk)

        #if targetEnvironment(simulator)
        print("Running in SIMULATOR")
        #else
        print("Running on REAL DEVICE")
        #endif

        print("Checking model availability...")

        if SystemLanguageModel.default.isAvailable {
            print("✅ Apple model AVAILABLE")
        } else {
            print("❌ Apple model NOT AVAILABLE")
        }

        isLoading = true
        defer {
            isLoading = false
            print("========== AI DEBUG END ==========")
        }

        let prompt = """
        User mood: \(selectedMood)
        Phase: \(phase)
        Cycle day: \(cycleDay)
        Sleep: \(sleep)
        Stress: \(stress)

        Give short supportive wellness advice.
        """

        do {
            print("Creating LanguageModelSession...")
            let session = LanguageModelSession()

            print("Sending prompt...")
            let response = try await session.respond(to: prompt)

            print("✅ Response received:")
            print(response.content)

            return response.content.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        } catch {
            print("❌ AI ERROR:")
            print(error.localizedDescription)
            print(error)

            return "Fallback triggered."
        }
    }
    
    func generateDailyInsight(
        stress: Int,
        sleep: Double,
        mood: Int
    ) async -> String {

        isLoading = true
        defer { isLoading = false }

        let prompt = """
        You are a premium wellness assistant inside a menstrual health app.

        User context:
        Stress: \(stress)/10
        Sleep: \(sleep) hours
        Mood score: \(mood)/10

        Generate one short uplifting daily wellness insight.

        Rules:
        - warm feminine tone
        - calm and motivating
        - 1-2 sentences
        - no medical diagnosis
        """

        do {
            let response = try await session.respond(to: prompt)
            return response.content.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        } catch {
            return "Move gently today. Small care rituals can shift more than you think 💕"
        }
    }

    // MARK: Fallback

    private func fallbackMoodInsight(
        mood: String,
        phase: String
    ) -> String {

        return "Your \(phase.lowercased()) phase may be shaping how today feels. Give yourself grace and move gently today 💕"
    }
}

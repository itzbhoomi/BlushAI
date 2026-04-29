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
    
    func generateTrendInsight(
        moods: [Int],
        avgSleep: Double,
        avgStress: Int
    ) async -> String {
        
        isLoading = true
        defer { isLoading = false }
        
        let prompt = """
        You are an AI wellness assistant in a premium menstrual health app.

        User mood trend (last days):
        \(moods)

        Average sleep: \(avgSleep) hours
        Average stress: \(avgStress)/10

        Analyze:
        - Is mood improving, declining, or fluctuating?
        
        Then give:
        - 1–2 sentence emotional insight
        - warm, feminine, supportive tone
        - no medical advice
        """

        do {
            let response = try await session.respond(to: prompt)
            return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return "Your emotions are moving through natural rhythms. Stay gentle with yourself and honor what your body needs 💕"
        }
    }
    
    func generateSleepInsight(
        sleepValues: [Double],
        avgSleep: Double
    ) async -> String {
        
        isLoading = true
        defer { isLoading = false }
        
        let prompt = """
        You are an AI wellness assistant in a premium menstrual health app.

        Sleep data (last days):
        \(sleepValues)

        Average sleep: \(avgSleep) hours

        Analyze:
        - consistency (regular vs irregular)
        - adequacy (sufficient vs deficit)

        Then generate:
        - 1–2 sentence insight
        - soft, calming, feminine tone
        - supportive, not clinical
        """

        do {
            let response = try await session.respond(to: prompt)
            return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return "Your body might be asking for deeper rest. Try slowing your evenings and giving yourself a softer landing into sleep 💙"
        }
    }
    
    func generateRiskInsight(
        stdDev: Double,
        stress: Double,
        hasPCOS: Bool,
        riskLevel: String
    ) async -> String {
        
        isLoading = true
        defer { isLoading = false }
        
        let prompt = """
        You are an AI wellness assistant in a premium menstrual health app.

        User health data:
        - Cycle variability (std deviation): \(stdDev) days
        - Stress level: \(stress)/10
        - PCOS: \(hasPCOS ? "Yes" : "No")
        - Risk level: \(riskLevel)

        Explain:
        - what this risk level means for the user
        - what factors are influencing it most

        Then give:
        - 1–2 sentence supportive recommendation
        - warm, reassuring tone
        - no medical diagnosis
        """

        do {
            let response = try await session.respond(to: prompt)
            return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return "Your body is giving you signals worth paying attention to. Small, consistent care can make a meaningful difference over time 💗"
        }
    }
    
    func generatePhaseInsight(
        phase: String,
        cycleDay: Int,
        avgMood: Int,
        avgEnergy: Int,
        avgStress: Int
    ) async -> String {
        
        isLoading = true
        defer { isLoading = false }
        
        let prompt = """
        You are a premium wellness assistant in a menstrual health app.

        User context:
        Phase: \(phase)
        Cycle day: \(cycleDay)
        Avg mood: \(avgMood)/10
        Avg energy: \(avgEnergy)/10
        Avg stress: \(avgStress)/10

        Explain:
        - how this phase is likely affecting the user personally (not generic biology)

        Then give:
        - 1–2 sentence supportive guidance
        - warm, feminine, reassuring tone
        - no medical advice
        """

        do {
            let response = try await session.respond(to: prompt)
            return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return "Your body is moving through a natural rhythm right now. Try to align your pace with how you're feeling instead of pushing against it 💗"
        }
    }
    
    func generateWellnessSuggestions(
        avgMood: Int,
        avgEnergy: Int,
        avgStress: Int,
        avgSleep: Double
    ) async -> (physical: String, mental: String, nutrition: String) {
        
        isLoading = true
        defer { isLoading = false }
        
        let prompt = """
        You are an AI wellness coach in a premium menstrual health app.

        User data:
        - Mood: \(avgMood)/10
        - Energy: \(avgEnergy)/10
        - Stress: \(avgStress)/10
        - Sleep: \(avgSleep) hours

        Generate 3 short suggestions:

        1. Physical Wellness
        2. Mental Wellness
        3. Nutrition & Care

        Rules:
        - Each should be 1 sentence
        - Personalized to the data
        - Warm, feminine, calm tone
        - No medical advice

        Format EXACTLY like:
        Physical: ...
        Mental: ...
        Nutrition: ...
        """

        do {
            let response = try await session.respond(to: prompt)
            let text = response.content
            
            // simple parsing
            let lines = text.components(separatedBy: "\n")
            
            let physical = lines.first(where: { $0.lowercased().contains("physical") })?
                .replacingOccurrences(of: "Physical:", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            let mental = lines.first(where: { $0.lowercased().contains("mental") })?
                .replacingOccurrences(of: "Mental:", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            let nutrition = lines.first(where: { $0.lowercased().contains("nutrition") })?
                .replacingOccurrences(of: "Nutrition:", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            return (physical, mental, nutrition)
            
        } catch {
            return (
                "Move gently today—light movement is enough 💗",
                "Take a few quiet minutes to reset your mind 🌿",
                "Nourish yourself with simple, comforting foods 🥣"
            )
        }
    }
}

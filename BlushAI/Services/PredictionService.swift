import Foundation
import CoreML

final class PredictionService {

    static let shared = PredictionService()

    private init() {}

    func predictCycleLength(
        cycleNumber: Int,
        cycleLengthDays: Double,
        prevCycleLength: Double,
        painLevel: Int,
        moodScore: Int,
        stressScoreCycle: Double,
        sleepHoursCycle: Double,
        energyLevel: Int,
        concentrationScore: Int,
        overallHealthScore: Double,
        age: Int,
        bmi: Double,
        sleepHours: Double,
        stressScoreBaseline: Double,
        avgLast3Cycles: Double,
        stdLast6Cycles: Double,
        cyclePhase: Int,
        flowLevel: Int,
        pmsSymptoms: Int,
        dietQuality: Int,
        exerciseFrequency: Int,
        birthControlUse: Int,
        pcosDiagnosed: Int
    ) -> Double {

        do {
            let model = try CyclePredictor(configuration: MLModelConfiguration())

            let input = CyclePredictorInput(
                cycle_number: Double(cycleNumber),
                cycle_length_days: cycleLengthDays,
                prev_cycle_length: prevCycleLength,
                pain_level: Double(painLevel),
                mood_score: Double(moodScore),
                stress_score_cycle: stressScoreCycle,
                sleep_hours_cycle: sleepHoursCycle,
                energy_level: Double(energyLevel),
                concentration_score: Double(concentrationScore),
                overall_health_score: overallHealthScore,
                age: Double(age),
                bmi: bmi,
                sleep_hours: sleepHours,
                stress_score_baseline: stressScoreBaseline,
                avg_last_3_cycles: avgLast3Cycles,
                std_last_6_cycles: stdLast6Cycles,
                cycle_phase: Double(cyclePhase),
                flow_level: Double(flowLevel),
                pms_symptoms: Double(pmsSymptoms),
                diet_quality: Double(dietQuality),
                exercise_frequency: Double(exerciseFrequency),
                birth_control_use: Double(birthControlUse),
                pcos_diagnosed: Double(pcosDiagnosed)
            )

            let output = try model.prediction(input: input)
            return output.predicted_cycle_length

        } catch {
            print("Prediction error:", error)
            return prevCycleLength
        }
    }

    func predictNextDate(
        lastStartDate: Date,
        predictedCycleLength: Double
    ) -> Date {

        let cycleLength = max(Int(predictedCycleLength.rounded()), 1)
        let today = Date()

        var nextDate = lastStartDate

        while nextDate < today {
            nextDate = Calendar.current.date(
                byAdding: .day,
                value: cycleLength,
                to: nextDate
            ) ?? nextDate
        }

        return nextDate
    }
    }


import SwiftUI
import SwiftData

struct DailyLogView: View {
    
    var selectedDate: Date
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    
    @Query(sort: \DailyLog.date, order: .reverse)
    var logs: [DailyLog]
    
    // ✅ Single source of truth for selected day (normalized)
    var todayLog: DailyLog? {
        let target = Calendar.current.startOfDay(for: selectedDate)
        return logs.first {
            Calendar.current.isDate(
                Calendar.current.startOfDay(for: $0.date),
                inSameDayAs: target
            )
        }
    }
    
    @State private var mood: Int = 5
    @State private var pain: Int = 0
    @State private var energy: Int = 5
    @State private var sleep: Double = 7
    @State private var stress: Int = 5
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Daily Check-in")
                .font(.title2.bold())
            
            Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                .font(.headline)
            
            Stepper("Mood 😊: \(mood)", value: $mood, in: 0...10)
            Stepper("Pain 😣: \(pain)", value: $pain, in: 0...10)
            Stepper("Energy ⚡️: \(energy)", value: $energy, in: 0...10)
            Stepper("Sleep 😴: \(String(format: "%.1f", sleep))", value: $sleep, in: 0...12, step: 0.5)
            Stepper("Stress 😵‍💫: \(stress)", value: $stress, in: 0...10)
            
            Button("Save") {
                save()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.pink)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Spacer()
        }
        .padding()
        .onAppear {
            loadExisting()
        }
    }
}

extension DailyLogView {
    
    func loadExisting() {
        guard let existing = todayLog else { return }
        
        mood = existing.mood
        pain = existing.pain
        energy = existing.energy
        sleep = existing.sleep
        stress = existing.stress
        
        print("🔁 Loaded existing log")
    }
    
    func save() {
        print("🟡 Saving daily log")
        
        let normalizedDate = Calendar.current.startOfDay(for: selectedDate)
        
        if let existing = todayLog {
            print("♻️ Updating existing log")
            
            existing.mood = mood
            existing.pain = pain
            existing.energy = energy
            existing.sleep = sleep
            existing.stress = stress
            
        } else {
            print("🟢 Creating new log")
            
            let newLog = DailyLog(date: normalizedDate)
            
            newLog.mood = mood
            newLog.pain = pain
            newLog.energy = energy
            newLog.sleep = sleep
            newLog.stress = stress
            
            context.insert(newLog)
        }
        
        do {
            try context.save()
            print("✅ Saved")
            dismiss()
        } catch {
            print("❌ Error:", error)
        }
    }
}

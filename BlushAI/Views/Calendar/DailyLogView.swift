import SwiftUI
import SwiftData

struct DailyLogView: View {
    
    var selectedDate: Date
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    
    @Query var logs: [DailyLog]
    
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
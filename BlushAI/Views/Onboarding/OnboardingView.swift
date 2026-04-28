//
//  OnboardingView.swift
//  Blush
//
//  Created by Bhoomi on 27/04/26.
//


import SwiftUI
import SwiftData

struct OnboardingView: View {

    @Environment(\.modelContext) private var context

    @State private var name = ""
    @State private var age = 22
    @State private var weight: Double = 55   // kg
    @State private var height: Double = 160  // cm
    @State private var hasPCOS = false
    @State private var sleepHours = 7.0
    @State private var stress = 5
    @State private var periodLength = 5

    @State private var lastPeriodDate = Date()
    @State private var avgCycleLength = 28

    @Query var profiles: [UserProfile]

    var body: some View {
        if profiles.isEmpty {
            onboardingContent
        } else {
            ContentView()
        }
    }

    var onboardingContent: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {

                        Text("Welcome to Blush")
                            .font(.custom("Sniglet-ExtraBold", size: 34))
                            .foregroundColor(Theme.textPrimary)

                        Text("Let's personalize your cycle insights.")
                            .foregroundColor(Theme.textSecondary)

                        Group {
                            fieldCard(
                                title: "Your Name"
                            ) {
                                TextField(
                                    "Name",
                                    text: $name
                                )
                                .textFieldStyle(.roundedBorder)
                            }

                            fieldCard(
                                title: "Age"
                            ) {
                                Picker("Age", selection: $age) {
                                    ForEach(13...55, id: \.self) { a in
                                        Text("\(a) years").tag(a)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 100)
                                .clipped()
                            }

                            fieldCard(title: "Weight (kg)") {
                                Slider(value: $weight, in: 35...120, step: 0.5)
                                Text("\(weight, specifier: "%.1f") kg")
                            }
                            
                            fieldCard(title: "Height (cm)") {
                                Slider(value: $height, in: 140...190, step: 1)
                                Text("\(height, specifier: "%.0f") cm")
                            }
                            

                            fieldCard(
                                title: "PCOS Diagnosed?"
                            ) {
                                Toggle(
                                    "Yes / No",
                                    isOn: $hasPCOS
                                )
                            }

                            fieldCard(
                                title: "Average Sleep"
                            ) {
                                Slider(
                                    value: $sleepHours,
                                    in: 3...10,
                                    step: 0.5
                                )
                                Text("\(sleepHours, specifier: "%.1f") hrs")
                            }

                            fieldCard(
                                title: "Stress Level"
                            ) {
                                Picker("Stress Level", selection: $stress) {
                                    ForEach(1...10, id: \.self) { s in
                                        Text("\(s) / 10").tag(s)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 100)
                                .clipped()
                            }

                            fieldCard(
                                title: "Last Period Start Date"
                            ) {
                                DatePicker(
                                    "",
                                    selection: $lastPeriodDate,
                                    displayedComponents: .date
                                )
                                .labelsHidden()
                            }
                            
                            fieldCard(title: "Period Length") {
                                Stepper(
                                    "\(periodLength) days",
                                    value: $periodLength,
                                    in: 2...10
                                )
                            }

                            fieldCard(
                                title: "Average Cycle Length"
                            ) {
                                Stepper(
                                    "\(avgCycleLength) days",
                                    value: $avgCycleLength,
                                    in: 21...40
                                )
                            }
                        }

                        Button {
                            saveUser()
                        } label: {
                            Text("Start Blush")
                                .font(.custom("Sniglet-ExtraBold", size: 17))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.accentPink)
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 18
                                    )
                                )
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                }
                .background(AppBackground())
            }
        }
    

    func fieldCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {

        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.custom("Sniglet-Regular", size: 17))
                .foregroundColor(Theme.textPrimary)

            content()
        }
        .padding(20)
        .glassCardStyle()
    }

    func saveUser() {
        
        let heightInMeters = height / 100
        let calculatedBMI = weight / (heightInMeters * heightInMeters)
       
        let profile = UserProfile(
            name: name.isEmpty ? "Bhoomi" : name,
            age: age,
            bmi: calculatedBMI,
            hasPCOS: hasPCOS,
            sleepHours: sleepHours,
            baselineStress: Double(stress)
        )

        context.insert(profile)

        let firstLog = CycleLog(
            startDate: lastPeriodDate,
            cycleLength: avgCycleLength,
            painLevel: 4,
            moodScore: 7,
            stressScore: Double(stress),
            sleepHours: sleepHours,
            flowLevel: 2,
            periodLength: periodLength
        )

        context.insert(firstLog)

        do {
            try context.save()
            print("✅ Saved successfully")
            
        } catch {
            print("❌ Save failed:", error)
        }
    }
}

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
    @State private var bmi = 21.0
    @State private var hasPCOS = false
    @State private var sleepHours = 7.0
    @State private var stress = 5.0

    @State private var lastPeriodDate = Date()
    @State private var avgCycleLength = 28

    @State private var completed = false

    var body: some View {

        if completed {
            ContentView()
        } else {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {

                        Text("Welcome to Blush")
                            .font(.largeTitle.bold())

                        Text("Let's personalize your cycle insights.")
                            .foregroundColor(.secondary)

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
                                Stepper(
                                    "\(age) years",
                                    value: $age,
                                    in: 13...55
                                )
                            }

                            fieldCard(
                                title: "BMI"
                            ) {
                                Slider(
                                    value: $bmi,
                                    in: 15...40,
                                    step: 0.1
                                )
                                Text(String(format: "%.1f", bmi))
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
                                Slider(
                                    value: $stress,
                                    in: 1...10,
                                    step: 0.5
                                )
                                Text("\(stress, specifier: "%.1f") / 10")
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
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.pink)
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
            }
        }
    }

    func fieldCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {

        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

            content()
        }
        .padding()
        .background(.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20
            )
        )
    }

    func saveUser() {

        let profile = UserProfile(
            name: name.isEmpty ? "Bhoomi" : name,
            age: age,
            bmi: bmi,
            hasPCOS: hasPCOS,
            sleepHours: sleepHours,
            baselineStress: stress
        )

        context.insert(profile)

        let firstLog = CycleLog(
            startDate: lastPeriodDate,
            cycleLength: avgCycleLength,
            painLevel: 4,
            moodScore: 7,
            stressScore: stress,
            sleepHours: sleepHours,
            flowLevel: 2
        )

        context.insert(firstLog)

        try? context.save()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            completed = true
        }    }
}

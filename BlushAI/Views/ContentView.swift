//
//  ContentView.swift
//  Blush
//
//  Created by Bhoomi on 27/04/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    @Query var profiles: [UserProfile]

    var body: some View {

        if profiles.isEmpty {
            OnboardingView()
        } else {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                CalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }

                InsightsView()
                    .tabItem {
                        Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
                    }

                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
            }
        }
    }
}

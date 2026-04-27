//
//  InsightsView.swift
//  Blush
//
//  Created by Bhoomi on 27/04/26.
//


import SwiftUI

struct InsightsView: View {
    var body: some View {
        VStack(spacing: 16) {
            StatCard(title: "Consistency", value: "Strong")
            StatCard(title: "Stress Impact", value: "Moderate")
            StatCard(title: "Sleep Trend", value: "Improving")
        }
        .padding()
    }
}
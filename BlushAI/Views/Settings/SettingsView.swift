//
//  SettingsView.swift
//  Blush
//
//  Created by Bhoomi on 27/04/26.
//


import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Text("Notifications")
            Text("Privacy")
            Text("Export Data")
        }
        .navigationTitle("Settings")
    }
}
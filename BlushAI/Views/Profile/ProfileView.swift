//
//  ProfileView.swift
//  Blush
//
//  Created by Bhoomi on 27/04/26.
//


import SwiftUI

struct ProfileView: View {
    var body: some View {
        List {
            Text("Bhoomi")
            Text("Premium Member")
            NavigationLink("Settings") { SettingsView() }
        }
    }
}
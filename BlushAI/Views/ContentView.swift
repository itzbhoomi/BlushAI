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
    
    @State private var selectedTab = 0

    var body: some View {

        if profiles.isEmpty {
            OnboardingView()
        } else {
            ZStack() {
                
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tag(0)
                        .toolbar(.hidden, for: .tabBar)

                    CalendarView()
                        .tag(1)
                        .toolbar(.hidden, for: .tabBar)

                    InsightsView()
                        .tag(2)
                        .toolbar(.hidden, for: .tabBar)

                    ProfileView()
                        .tag(3)
                        .toolbar(.hidden, for: .tabBar)
                }
                
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    floatingTabBar
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
    
    var floatingTabBar: some View {
        HStack(spacing: 0) {
            tabButton(icon: "house.fill", tag: 0)
            Spacer()
            tabButton(icon: "calendar", tag: 1)
            Spacer()
            tabButton(icon: "chart.line.uptrend.xyaxis", tag: 2)
            Spacer()
            tabButton(icon: "person.fill", tag: 3)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 10) // keep tap comfort
        .background(
            Color(red: 255/255, green: 240/255, blue: 245/255).opacity(0.72)
        )
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .padding(.horizontal, 10)
        .offset(y: 15)
    }
        
    
    func tabButton(icon: String, tag: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedTab = tag
            }
        } label: {
            Image(systemName: icon)
                .font(.custom(selectedTab == tag ? "Sniglet-ExtraBold" : "Sniglet-Regular", size: 22))
                .foregroundColor(selectedTab == tag ? Theme.accentPink : Theme.textMuted)
                .scaleEffect(selectedTab == tag ? 1.15 : 1.0)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(TabButtonStyle())
    }
}

struct TabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}

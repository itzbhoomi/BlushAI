//
//  CalendarView.swift
//  Blush
//
//  Created by Bhoomi on 27/04/26.
//


//
//  CalendarView.swift
//  Blush
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date = Date()
    
    @State private var insight: String = "Tap a date to see your insight 🌸"
    @State private var showLogSheet = false
    
    @Query(
        sort: \CycleLog.startDate,
        order: .reverse
    )
    var logs: [CycleLog]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    header
                    
                    calendarGrid
                    
                    selectedDayCard
                    
                    logButton
                    
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 40)
            }
            .background(Theme.backgroundGradient.ignoresSafeArea())
            .onChange(of: selectedDate) { _ in
                loadInsight()
            }
            .onAppear {
                loadInsight()
            }
        }
        .font(Font.custom("Sniglet-Regular", size: 14))
    }
}

extension CalendarView {
    
    var header: some View {
        HStack {
            Button {
                currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
            } label: {
                Image(systemName: "chevron.left")
            }
            
            Spacer()
            
            Text(monthYearString(from: currentMonth))
                .font(Font.custom("Sniglet-ExtraBold", size: 20))
            
            Spacer()
            
            Button {
                currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .foregroundStyle(Theme.textPrimary)
    }
}

extension CalendarView {
    
    var calendarGrid: some View {
        let days = generateDays()
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            
            ForEach(days, id: \.self) { date in
                if let date = date {
                    dayCell(for: date)
                } else {
                    Color.clear.frame(height: 40)
                }
            }
        }
    }
    
    func dayCell(for date: Date) -> some View {
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        let isToday = Calendar.current.isDateInToday(date)
        
        return VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(Font.custom("Sniglet-Regular", size: 14))
                .foregroundStyle(isSelected ? .white : Theme.textPrimary)
            
            Circle()
                .fill(dayColor(for: date))
                .frame(width: 6, height: 6)
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(
            ZStack {
                if isSelected {
                    Theme.accentGradient
                } else if isToday {
                    Theme.accentPink.opacity(0.2)
                } else {
                    Color.clear
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            selectedDate = date
        }
    }
}

extension CalendarView {
    
    var selectedDayCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text(dateString(selectedDate))
                .font(Font.custom("Sniglet-ExtraBold", size: 18))
                .foregroundStyle(Theme.textPrimary)
            
            Text(phaseText(for: selectedDate))
                .font(Font.custom("Sniglet-Regular", size: 14))
                .foregroundStyle(Theme.accentPink)
            
            Text(insight)
                .font(Font.custom("Sniglet-Regular", size: 15))
                .foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(Theme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
}

extension CalendarView {
    
    var logButton: some View {
        Button {
            showLogSheet = true
        } label: {
            Text("Log Period")
                .font(Font.custom("Sniglet-ExtraBold", size: 16))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Theme.accentGradient)
                .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .sheet(isPresented: $showLogSheet) {
            LogPeriodView(selectedDate: selectedDate)
        }
    }
}

extension CalendarView {
    
    func generateDays() -> [Date?] {
        let calendar = Calendar.current
        
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in range {
            let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
            days.append(date)
        }
        
        return days
    }
    
    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: date)
    }
}

extension CalendarView {
    
    func dayColor(for date: Date) -> Color {
        if isPeriodDay(date) {
            return .red
        } else {
            return Theme.textMuted.opacity(0.4)
        }
    }
    
    func isPeriodDay(_ date: Date) -> Bool {
        for log in logs {
            let start = log.startDate
            let duration = log.periodLength
            
            let diff = Calendar.current.dateComponents([.day], from: start, to: date).day ?? 0
            
            if diff >= 0 && diff < duration {
                return true
            }
        }
        return false
    }
    
    func phaseText(for date: Date) -> String {
        if isPeriodDay(date) {
            return "Menstrual Phase"
        } else {
            return "Normal Day"
        }
    }
}

extension CalendarView {
    
    func loadInsight() {
        let key = insightKey(for: selectedDate)
        
        if let saved = UserDefaults.standard.string(forKey: key) {
            insight = saved
        } else {
            insight = "No insight for this day yet 🌸"
        }
    }
    
    func insightKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "daily_insight_\(formatter.string(from: date))"
    }
}

struct LogPeriodView: View {
    
    var selectedDate: Date
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Log Period")
                .font(.title2.bold())
            
            Text("Start Date: \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
            
            Button("Save") {
                // Save logic (SwiftData insert)
                dismiss()
            }
        }
        .padding()
    }
}

//
//  CalendarView 2.swift
//  BlushAI
//
//  Created by Bhoomi on 28/04/26.
//


import SwiftUI
import SwiftData

struct CalendarView: View {
    
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date = Date()
    
    @State private var insight: String = "Tap a date to see your insight 🌸"
    @State private var showLogSheet = false
    
    @Query(sort: \CycleLog.startDate, order: .reverse)
    var logs: [CycleLog]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    header
                    calendarGrid
                    selectedDayCard
                    logButton
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
            }
            .background(Theme.backgroundGradient.ignoresSafeArea())
            .onChange(of: selectedDate) { _ in loadInsight() }
            .onAppear { loadInsight() }
        }
        .font(.custom("Sniglet-Regular", size: 14))
        .onChange(of: logs.count) { newValue in
            print("📊 Logs updated. Count:", newValue)
        }
    }
}

extension CalendarView {
    
    var header: some View {
        HStack {
            Button {
                currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
            } label: {
                Image(systemName: "chevron.left")
                    .padding(8)
                    .contentShape(Rectangle())
            }
            
            Spacer()
            
            Text(monthYearString(from: currentMonth))
                .font(.custom("Sniglet-ExtraBold", size: 20))
            
            Spacer()
            
            Button {
                currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
            } label: {
                Image(systemName: "chevron.right")
                    .padding(8)
                    .contentShape(Rectangle())
            }
        }
        .foregroundStyle(Theme.textPrimary)
    }
}

extension CalendarView {
    
    var calendarGrid: some View {
        let days = generateDays()
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                if let date = date {
                    dayCell(for: date)
                } else {
                    Color.clear.frame(height: 44)
                }
            }
        }
    }
    
    func dayCell(for date: Date) -> some View {
        let calendar = Calendar.current
        
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let isPast = calendar.startOfDay(for: date) <= calendar.startOfDay(for: Date())
        
        let type = CycleEngine.dayType(for: date, logs: logs)

        print("📅 Checking date:", date, "Type:", type, "Logs count:", logs.count)
        
        return VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .foregroundStyle(isSelected ? .white : Theme.textPrimary)
            
            Circle()
                .fill(CycleEngine.color(for: type))
                .frame(width: 6, height: 6)
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(
            ZStack {
                if isSelected {
                    Theme.accentGradient
                } else {
                    backgroundColor(for: type, isToday: isToday)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .opacity(isPast ? 1 : 0.4)
        .onTapGesture {
            if isPast {
                selectedDate = date
            }
        }
    }
    
    func backgroundColor(for type: DayType, isToday: Bool) -> Color {
        switch type {
        case .period:
            return Color.red.opacity(0.2)
        case .fertile:
            return Color.purple.opacity(0.15)
        case .ovulation:
            return Color.blue.opacity(0.25)
        case .normal:
            return isToday ? Theme.accentPink.opacity(0.2) : .clear
        }
    }
}

extension CalendarView {
    
    var selectedDayCard: some View {
        let calendar = Calendar.current
        let isPast = calendar.startOfDay(for: selectedDate) <= calendar.startOfDay(for: Date())
        
        let type = CycleEngine.dayType(for: selectedDate, logs: logs)
        
        return VStack(alignment: .leading, spacing: 10) {
            
            Text(dateString(selectedDate))
                .font(.custom("Sniglet-ExtraBold", size: 18))
            
            Text(CycleEngine.phaseText(for: type))
                .foregroundStyle(Theme.accentPink)
            
            if isPast {
                Text(insight)
                    .foregroundStyle(Theme.textSecondary)
                
                Text(moodForDate(selectedDate))
                    .font(.custom("Sniglet-Regular", size: 13))
                    .foregroundStyle(Theme.textSecondary)
                
                Button("View Journal") {}
                    .font(.custom("Sniglet-Regular", size: 12))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.white)
                    .clipShape(Capsule())
                
            } else {
                Text("Future prediction based on your cycle")
                    .foregroundStyle(Theme.textMuted)
            }
        }
        .padding(18)
        .background(Theme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}

extension CalendarView {
    
    var logButton: some View {
        Button {
            showLogSheet = true
        } label: {
            Text("Log Period")
                .font(.custom("Sniglet-ExtraBold", size: 16))
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
        
        let weekday = calendar.component(.weekday, from: startOfMonth)
        let shift = (weekday - calendar.firstWeekday + 7) % 7
        
        var days: [Date?] = Array(repeating: nil, count: shift)
        
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
    
    func loadInsight() {
        let key = insightKey(for: selectedDate)
        insight = UserDefaults.standard.string(forKey: key) ?? "No insight for this day yet 🌸"
    }
    
    func insightKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "daily_insight_\(formatter.string(from: date))"
    }
    
    func moodForDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = "mood_\(formatter.string(from: date))"
        
        if UserDefaults.standard.bool(forKey: key) {
            return UserDefaults.standard.string(forKey: "\(key)_emoji") ?? "😊"
        }
        return "No mood logged"
    }
}

struct LogPeriodView: View {
    
    var selectedDate: Date
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    
    @Query(sort: \CycleLog.startDate, order: .reverse)
    var logs: [CycleLog]
    
    @State private var periodLength: Int = 5
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Log Period")
                .font(.title2.bold())
            
            Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                .font(.headline)
            
            Stepper("Length: \(periodLength) days", value: $periodLength, in: 2...10)
            
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
    }
    
    func save() {
        print("🟡 SAVE TAPPED")
        print("Selected date:", selectedDate)
        print("Existing logs count BEFORE:", logs.count)
        
        // Check duplicate
        if logs.contains(where: {
            Calendar.current.isDate($0.startDate, inSameDayAs: selectedDate)
        }) {
            print("⚠️ Duplicate log detected. Not saving.")
            dismiss()
            return
        }
        
        let newLog = CycleLog(
            startDate: selectedDate,
            cycleLength: logs.first?.cycleLength ?? 28,
            painLevel: 4,
            moodScore: 7,
            stressScore: 5,
            sleepHours: 7,
            flowLevel: 2,
            periodLength: periodLength
        )
        
        print("🟢 Creating new log:")
        print("Start:", newLog.startDate)
        print("Cycle length:", newLog.cycleLength)
        print("Period length:", newLog.periodLength)
        
        context.insert(newLog)
        
        do {
            try context.save()
            print("✅ SAVE SUCCESS")
            
            // DEBUG FETCH AFTER SAVE
            let descriptor = FetchDescriptor<CycleLog>()
            let allLogs = try context.fetch(descriptor)
            print("📦 Total logs AFTER save:", allLogs.count)
            
            for log in allLogs {
                print("➡️ Log:", log.startDate)
            }
            
            dismiss()
            
        } catch {
            print("❌ Failed to save:", error)
        }
    }
}

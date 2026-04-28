import SwiftUI
import SwiftData

struct CalendarView: View {
    
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date = Date()
    
    @State private var insight: String = "Tap a date to see your insight 🌸"
    @State private var showLogSheet = false
    @State private var showDailyLogSheet = false

    // ✅ FIXED QUERY
    @Query(sort: \DailyLog.date, order: .reverse)
    var dailyLogs: [DailyLog]
    
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
    }
}

// MARK: - HEADER
extension CalendarView {
    
    var header: some View {
        HStack {
            Button {
                currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
            } label: {
                Image(systemName: "chevron.left")
                    .padding(8)
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
            }
        }
        .foregroundStyle(Theme.textPrimary)
    }
}

// MARK: - CALENDAR GRID
extension CalendarView {
    
    var calendarGrid: some View {
        let days = generateDays()
        
        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        
        return VStack(spacing: 8) {
            
            // ✅ WEEKDAY HEADER (separate grid = no breaking)
            LazyVGrid(columns: columns, spacing: 10) {
                let days = ["S","M","T","W","T","F","S"]
                ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                    Text(day)
                        .font(.custom("Sniglet-ExtraBold", size: 13))
                        .foregroundStyle(Theme.textPrimary.opacity(0.7))
                        .frame(maxWidth: .infinity)
                }
            }
            
            // ✅ ACTUAL CALENDAR GRID
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        dayCell(for: date)
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
        }
    }
    
    func dayCell(for date: Date) -> some View {
        let calendar = Calendar.current
        
        let normalizedDate = calendar.startOfDay(for: date)
        let isSelected = calendar.isDate(normalizedDate, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(normalizedDate)
        let isPast = normalizedDate <= calendar.startOfDay(for: Date())
        
        let latestLog = logs.first
        let type = latestLog.map {
            CycleEngine.dayType(for: normalizedDate, log: $0)
        } ?? .normal
        
        let todayLog = dailyLogs.first {
            Calendar.current.isDate($0.date, inSameDayAs: normalizedDate)
        }

        let hasDailyLog = todayLog != nil
        
        return VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: normalizedDate))")
                .foregroundStyle(isSelected ? .white : Theme.textPrimary)
            
            ZStack {
                Circle()
                    .fill(CycleEngine.color(for: type))
                    .frame(width: 6, height: 6)
                
                if hasDailyLog {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 3, height: 3)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(
            ZStack {
                if isSelected {
                    Theme.accentGradient
                } else {
                    backgroundColor(for: type, isToday: isToday)
                }
                
                if hasDailyLog {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .opacity(isPast ? 1 : 0.4)
        .onTapGesture {
            if isPast {
                selectedDate = normalizedDate
            }
        }
    }
}

// MARK: - SELECTED DAY CARD
extension CalendarView {
    
    var selectedDayCard: some View {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: selectedDate)
        let isPast = normalizedDate <= calendar.startOfDay(for: Date())
        
        let latestLog = logs.first
        let type = latestLog.map {
            CycleEngine.dayType(for: normalizedDate, log: $0)
        } ?? .normal
        
        return VStack(alignment: .leading, spacing: 10) {
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(dateString(normalizedDate))
                    .font(.custom("Sniglet-ExtraBold", size: 18))
                
                if let nextDate = predictedNextPeriodDate() {
                    
                    let days = Calendar.current.dateComponents(
                        [.day],
                        from: normalizedDate,
                        to: nextDate
                    ).day ?? 0
                    
                    Text(
                        days <= 0
                        ? "Period expected soon"
                        : "Next period in \(days) days"
                    )
                    .font(.custom("Sniglet-Regular", size: 12))
                    .foregroundStyle(Theme.textSecondary)
                    
                } else {
                    Text("Not enough data yet")
                        .font(.custom("Sniglet-Regular", size: 12))
                        .foregroundStyle(.secondary)
                }
            }
                .font(.custom("Sniglet-ExtraBold", size: 18))
            
            Text(CycleEngine.phaseText(for: type))
                .foregroundStyle(Theme.accentPink)
            
            if isPast {
                Text(insight)
                    .foregroundStyle(Theme.textSecondary)
                
                let todayLog = dailyLogs.first {
                    Calendar.current.isDate($0.date, inSameDayAs: normalizedDate)
                }

                if let log = todayLog
                    {
                    
                    VStack(spacing: 14) {
                        
                        HStack {
                            Text("Your Day 💗")
                                .font(.custom("Sniglet-ExtraBold", size: 18))
                            Spacer()
                        }
                        
                        HStack(spacing: 5) {
                            statCard(title: "Mood", value: log.mood, emoji: "😊", color: .pink)
                            statCard(title: "Pain", value: log.pain, emoji: "😣", color: .red)
                            statCard(title: "Energy", value: log.energy, emoji: "⚡️", color: .purple)
                        }
                        
                        HStack(spacing: 5) {
                            statCard(title: "Sleep", value: Int(log.sleep), emoji: "😴", color: .blue)
                            statCard(title: "Stress", value: log.stress, emoji: "😵‍💫", color: .orange)
                        }
                    }
                    .padding(14)
                    .background(.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                } else {
                    
                    // 👇 EMPTY STATE (IMPORTANT UX)
                    VStack(spacing: 10) {
                        Text("No check-in yet 🌸")
                            .font(.custom("Sniglet-Regular", size: 13))
                            .foregroundStyle(.secondary)
                        
                        Text("Tap below to log how you're feeling today")
                            .font(.custom("Sniglet-Regular", size: 11))
                            .foregroundStyle(.secondary.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Button {
                    showDailyLogSheet = true
                } label: {
                    Text(buttonText(for: type))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Theme.accentGradient)
                        .clipShape(Capsule())
                }
                
            } else {
                Text("Future prediction based on your cycle")
                    .foregroundStyle(Theme.textMuted)
            }
        }
        .padding(18)
        .background(Theme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .sheet(isPresented: $showDailyLogSheet) {
            DailyLogView(
                selectedDate: Calendar.current.startOfDay(for: selectedDate)
            )
        }
    }
}

// MARK: - LOG BUTTON
extension CalendarView {
    
    var logButton: some View {
        Button {
            showLogSheet = true
        } label: {
            Text("Log Period")
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

// MARK: - HELPERS
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
    
    func predictedNextPeriodDate() -> Date? {
        CyclePredictionEngine.shared.nextPeriodDate(from: logs)
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
    
    func buttonText(for type: DayType) -> String {
        switch type {
        case .period: return "Log Symptoms 🩸"
        case .fertile: return "Log Feelings 🌿"
        case .ovulation: return "Log Ovulation ✨"
        case .normal: return "Daily Check-in 💗"
        }
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
    
    func loadInsight() {
        let key = insightKey(for: selectedDate)
        insight = UserDefaults.standard.string(forKey: key) ?? "No insight for this day yet 🌸"
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
        
        if logs.contains(where: {
            Calendar.current.isDate($0.startDate, inSameDayAs: selectedDate)
        }) {
            print("⚠️ Duplicate log")
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
        
        context.insert(newLog)
        
        do {
            try context.save()
            print("✅ Saved period log")
            dismiss()
        } catch {
            print("❌ Error:", error)
        }
    }
}

func statCard(title: String, value: Int, emoji: String, color: Color) -> some View {
    VStack(spacing: 6) {
        
        Text(emoji)
            .font(.system(size: 18))
        
        Text("\(value)")
            .font(.custom("Sniglet-Regular", size: 16))
        
        Text(title)
            .font(.custom("Sniglet-Regular", size: 11))
            .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 10)
    .background(color.opacity(0.12))
    .clipShape(RoundedRectangle(cornerRadius: 12))
}

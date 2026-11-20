import Foundation
import SwiftData

@Model
class Habit {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var createdAt: Date
    var completions: [Date]
    var bestStreak: Int
    
    init(name: String, icon: String = "flame.fill", colorHex: String = "#6366F1") {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.createdAt = Date()
        self.completions = []
        self.bestStreak = 0
    }
    
    func progress(on date: Date = .now, calendar: Calendar = .current) -> HabitProgress {
        let firstDay = calendar.startOfDay(for: createdAt)
        let today = calendar.startOfDay(for: date)
        let days = Set(completions.map { calendar.startOfDay(for: $0) }.filter {
            $0 >= firstDay && $0 <= today
        })
        let elapsed = max((calendar.dateComponents([.day], from: firstDay, to: today).day ?? 0) + 1, 1)
        var run = 0
        var best = 0
        var previous: Date?

        for day in days.sorted() {
            let next = previous.flatMap { calendar.date(byAdding: .day, value: 1, to: $0) }
            run = next == day ? run + 1 : 1
            best = max(best, run)
            previous = day
        }

        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)
        let isCurrent = previous != nil && (previous == today || previous == yesterday)
        return HabitProgress(
            completedDays: days,
            isCompletedToday: days.contains(today),
            currentStreak: isCurrent ? run : 0,
            bestStreak: best,
            completionRate: Double(days.count) / Double(elapsed)
        )
    }

    @discardableResult
    func toggleToday(on date: Date = .now, calendar: Calendar = .current) -> Bool {
        let didComplete = !completions.contains { calendar.isDate($0, inSameDayAs: date) }
        if didComplete {
            completions.append(date)
        } else {
            completions.removeAll { calendar.isDate($0, inSameDayAs: date) }
        }
        bestStreak = progress(on: date, calendar: calendar).bestStreak
        return didComplete
    }
}

struct HabitProgress {
    let completedDays: Set<Date>
    let isCompletedToday: Bool
    let currentStreak: Int
    let bestStreak: Int
    let completionRate: Double

    var milestone: Int? {
        let milestones = [7, 14, 30, 60, 100, 365]
        return milestones.first { $0 == currentStreak }
    }
}

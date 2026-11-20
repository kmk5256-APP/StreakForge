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
    
    var currentStreak: Int {
        let calendar = Calendar.current
        let sorted = completions.map { calendar.startOfDay(for: $0) }.sorted(by: >)
        guard !sorted.isEmpty else { return 0 }
        
        var streak = 0
        var expected = calendar.startOfDay(for: Date())
        
        for date in sorted {
            if date == expected {
                streak += 1
                expected = calendar.date(byAdding: .day, value: -1, to: expected)!
            } else if date < expected {
                break
            }
        }
        return streak
    }
    
    var isCompletedToday: Bool {
        completions.contains { Calendar.current.isDateInToday($0) }
    }
    
    var completionRate: Double {
        let days = max(Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 1, 1)
        return Double(completions.count) / Double(days)
    }
    
    func toggleToday() {
        let calendar = Calendar.current
        if let index = completions.firstIndex(where: { calendar.isDateInToday($0) }) {
            completions.remove(at: index)
        } else {
            completions.append(Date())
        }
        bestStreak = max(bestStreak, currentStreak)
    }
    
    var milestone: Int? {
        let milestones = [7, 14, 30, 60, 100, 365]
        return milestones.first { $0 == currentStreak }
    }
}

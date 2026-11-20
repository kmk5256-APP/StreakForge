import Foundation
import SwiftData

@Model
class Habit {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var frequency: String // "daily" or "weekly"
    var createdAt: Date
    var completions: [Date]
    
    init(name: String, icon: String = "star.fill", colorHex: String = "#6366F1", frequency: String = "daily") {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.frequency = frequency
        self.createdAt = Date()
        self.completions = []
    }
    
    var currentStreak: Int {
        let calendar = Calendar.current
        let sorted = completions.sorted(by: >)
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        for date in sorted {
            let day = calendar.startOfDay(for: date)
            if day == checkDate {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)! 
            } else if day < checkDate {
                break
            }
        }
        return streak
    }
    
    var isCompletedToday: Bool {
        let calendar = Calendar.current
        return completions.contains { calendar.isDateInToday($0) }
    }
    
    func toggleToday() {
        let calendar = Calendar.current
        if let index = completions.firstIndex(where: { calendar.isDateInToday($0) }) {
            completions.remove(at: index)
        } else {
            completions.append(Date())
        }
    }
}

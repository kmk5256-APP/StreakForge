import Foundation
import XCTest
@testable import StreakForge

final class HabitProgressTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        return calendar
    }

    func testStreakContinuesThroughYesterdayAcrossDaylightSavingChange() {
        let habit = makeHabit()
        habit.completions = [day(7), day(8), day(9)]

        let progress = habit.progress(on: day(10), calendar: calendar)
        XCTAssertEqual(progress.currentStreak, 3)
        XCTAssertEqual(progress.bestStreak, 3)
        XCTAssertFalse(progress.isCompletedToday)
    }

    func testMissedDayBreaksCurrentStreakButPreservesBest() {
        let habit = makeHabit()
        habit.completions = [day(6), day(7), day(8), day(11)]

        XCTAssertEqual(habit.progress(on: day(10), calendar: calendar).currentStreak, 0)
        let progress = habit.progress(on: day(11), calendar: calendar)
        XCTAssertEqual(progress.currentStreak, 1)
        XCTAssertEqual(progress.bestStreak, 3)
    }

    func testCompletionRateCountsCalendarDaysAndIgnoresDuplicateAndFutureLogs() {
        let habit = makeHabit(started: 8)
        habit.completions = [day(7), day(8), day(8, hour: 23), day(9), day(11)]
        let progress = habit.progress(on: day(10), calendar: calendar)

        XCTAssertEqual(progress.completedDays.count, 2)
        XCTAssertEqual(progress.completionRate, 2.0 / 3.0, accuracy: 0.0001)
    }

    func testCanCompleteAndUndoOnTheDayAHabitIsCreated() {
        let habit = makeHabit(started: 8)
        XCTAssertTrue(habit.toggleToday(on: day(8), calendar: calendar))
        XCTAssertEqual(habit.progress(on: day(8), calendar: calendar).completionRate, 1)
        XCTAssertEqual(habit.progress(on: day(8), calendar: calendar).bestStreak, 1)

        XCTAssertFalse(habit.toggleToday(on: day(8, hour: 23), calendar: calendar))
        XCTAssertEqual(habit.progress(on: day(8), calendar: calendar).bestStreak, 0)
        XCTAssertTrue(habit.completions.isEmpty)
    }

    func testSevenDayMilestoneUsesUniqueCompletionDays() {
        let habit = makeHabit(started: 5)
        habit.completions = (5...10).map { day($0) } + [day(10, hour: 23)]

        XCTAssertNil(habit.progress(on: day(11), calendar: calendar).milestone)
        XCTAssertTrue(habit.toggleToday(on: day(11), calendar: calendar))
        XCTAssertEqual(habit.progress(on: day(11), calendar: calendar).milestone, 7)
    }

    private func makeHabit(started: Int = 5) -> Habit {
        let habit = Habit(name: "Practice piano")
        habit.createdAt = day(started)
        return habit
    }

    private func day(_ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 3, day: day, hour: hour))!
    }
}

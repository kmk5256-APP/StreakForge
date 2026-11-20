import XCTest

final class StreakForgeJourneyTests: XCTestCase {
    func testCreateCompleteUndoEditRelaunchAndDeleteHabit() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
        let suffix = UUID().uuidString.prefix(5)
        let name = "Read 10 pages \(suffix)"
        let renamed = "Read 20 pages \(suffix)"

        addHabit(name, in: app)
        let complete = app.buttons["Complete \(name)"]
        XCTAssertTrue(complete.waitForExistence(timeout: 5))
        complete.tap()

        let undo = app.buttons["Undo completion for \(name)"]
        XCTAssertTrue(undo.waitForExistence(timeout: 5))
        undo.tap()
        XCTAssertTrue(complete.waitForExistence(timeout: 5))
        complete.tap()

        app.staticTexts[name].tap()
        let options = app.buttons["habit.menu"]
        XCTAssertTrue(options.waitForExistence(timeout: 5))
        options.tap()
        app.buttons["Edit"].tap()

        let field = app.textFields["habit.name"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: name.count))
        field.typeText(renamed)
        app.buttons["habit.save"].tap()
        XCTAssertTrue(app.staticTexts[renamed].waitForExistence(timeout: 5))

        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["Undo completion for \(renamed)"].waitForExistence(timeout: 5))
        app.staticTexts[renamed].tap()
        options.tap()
        app.buttons["Delete"].tap()
        let confirm = app.alerts["Delete Habit?"]
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        confirm.buttons["Delete"].tap()
        XCTAssertTrue(app.navigationBars["StreakForge"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts[renamed].exists)
    }

    func testListingScreenshots() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
        let habits = ["Practice piano", "Read 10 pages", "Morning walk"]
        for name in habits where !app.staticTexts[name].exists {
            addHabit(name, in: app)
        }
        for name in habits.suffix(2) {
            let button = app.buttons["Complete \(name)"]
            if button.exists { button.tap() }
        }
        capture("StreakForge-Habits")
        app.staticTexts["Morning walk"].tap()
        XCTAssertTrue(app.navigationBars["Details"].waitForExistence(timeout: 5))
        capture("StreakForge-Details")

        func capture(_ name: String) {
            let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
            screenshot.name = name
            screenshot.lifetime = .keepAlways
            add(screenshot)
        }
    }

    private func addHabit(_ name: String, in app: XCUIApplication) {
        app.buttons["habit.add"].tap()
        let field = app.textFields["habit.name"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["habit.save"].isEnabled)
        field.tap()
        field.typeText(name)
        app.buttons["habit.save"].tap()
        XCTAssertTrue(app.staticTexts[name].waitForExistence(timeout: 5))
    }
}

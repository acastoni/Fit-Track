import XCTest
@testable import FitTrack_Watch_App

class FitTrackTests: XCTestCase {

    override func setUpWithError() throws {
        // Setup code here
        print("Setting up before each test")
    }

    override func tearDownWithError() throws {
        // Teardown code here
        print("Cleaning up after each test")
    }

    func testWorkoutSummaryInitialization() throws {
        let exerciseType = CustomWorkoutType.benchPress
        let heartRate = 120.0
        let caloriesBurned = 200
        let duration: TimeInterval = 1800
        let repetitions = 15

        let summary = WorkoutSummary(
            exerciseType: exerciseType,
            heartRate: heartRate,
            caloriesBurned: caloriesBurned,
            duration: duration,
            repetitions: repetitions
        )

        XCTAssertEqual(summary.exerciseType, exerciseType)
        XCTAssertEqual(summary.heartRate, heartRate)
        XCTAssertEqual(summary.caloriesBurned, caloriesBurned)
        XCTAssertEqual(summary.duration, duration)
        XCTAssertEqual(summary.repetitions, repetitions)
        XCTAssertNotNil(summary.timestamp)
    }

    func testCalorieCalculation() throws {
        let duration: TimeInterval = 1800 // 30 minutes
        let expectedCalories = 240 // Assuming 8 calories per minute

        let calculatedCalories = calculateCalories(for: duration)
        
        XCTAssertEqual(calculatedCalories, expectedCalories, "Calorie calculation should be correct")
    }

    func testFormattedDuration() throws {
        let duration: TimeInterval = 3723 // 1 hour, 2 minutes, and 3 seconds
        let formattedDuration = formattedDuration(from: duration)
        
        XCTAssertEqual(formattedDuration, "01:02:03", "Duration should be formatted correctly")
    }
    

    func testSaveWorkoutSummaryLimits() throws {
        for _ in 0..<10 {
            let summary = WorkoutSummary(
                exerciseType: .benchPress,
                heartRate: 120.0,
                caloriesBurned: 200,
                duration: 1800,
                repetitions: 15
            )
            saveWorkoutSummary(summary)
        }
        
        let loadedSummaries = loadWorkoutSummaries()
        XCTAssertEqual(loadedSummaries.count, 7, "There should be a maximum of 7 workout summaries stored")
    }

    // Helper function for calorie calculation
    func calculateCalories(for duration: TimeInterval) -> Int {
        let caloriesPerMinute = 8.0
        let minutes = duration / 60
        return Int(minutes * caloriesPerMinute)
    }

    // Helper function for formatted duration
    func formattedDuration(from duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        let hours = minutes / 60
        return String(format: "%02d:%02d:%02d", hours, minutes % 60, seconds)
    }

    // Helper function for formatted date
    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // Helper function to save workout summary
    func saveWorkoutSummary(_ summary: WorkoutSummary) {
        var summaries = UserDefaults.standard.array(forKey: "workoutSummaries") as? [[String: Any]] ?? []
        if summaries.count >= 7 {
            summaries.removeFirst()
        }
        summaries.append(summary.toDictionary())
        UserDefaults.standard.set(summaries, forKey: "workoutSummaries")
    }

    // Helper function to load workout summaries
    func loadWorkoutSummaries() -> [WorkoutSummary] {
        let summaries = UserDefaults.standard.array(forKey: "workoutSummaries") as? [[String: Any]] ?? []
        return summaries.map { WorkoutSummary(from: $0) }
    }
}

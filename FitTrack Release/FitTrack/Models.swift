import Foundation

struct WorkoutSession {
    var exerciseType: ExerciseType
    var startTime: Date
    var endTime: Date
    var repetitions: Int
}

struct HeartRateData {
    var timestamp: Date
    var heartRate: Double
}

enum ExerciseType: String {
    case benchPress = "Bench Press"
    case pullUp = "Pull Up"
    case general = "General Exercise"
}

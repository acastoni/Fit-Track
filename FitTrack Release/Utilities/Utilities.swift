import Foundation

public func calculateCalories(duration: TimeInterval, caloriesPerMinute: Double = 8.0) -> Int {
    let minutes = duration / 60
    return Int(minutes * caloriesPerMinute)
}

public func formattedDuration(from duration: TimeInterval) -> String {
    let minutes = Int(duration) / 60
    let seconds = Int(duration) % 60
    let hours = minutes / 60
    return String(format: "%02d:%02d:%02d", hours, minutes % 60, seconds)
}

public func formattedDate(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

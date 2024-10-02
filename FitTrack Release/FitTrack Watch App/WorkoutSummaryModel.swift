//
//  WorkoutSummaryModel.swift
//  FitTrack
//
//  Created by Anthony Castillo 
//

import Foundation

public struct WorkoutSummary {
    var exerciseType: CustomWorkoutType
    var heartRate: Double
    var caloriesBurned: Int
    var duration: TimeInterval
    var repetitions: Int
    var timestamp: Date

    init(exerciseType: CustomWorkoutType, heartRate: Double, caloriesBurned: Int, duration: TimeInterval, repetitions: Int) {
        self.exerciseType = exerciseType
        self.heartRate = heartRate
        self.caloriesBurned = caloriesBurned
        self.duration = duration
        self.repetitions = repetitions
        self.timestamp = Date()
    }
}

public extension WorkoutSummary {
    init(from dictionary: [String: Any]) {
        let exerciseTypeRawValue = dictionary["exerciseType"] as! String
        self.exerciseType = CustomWorkoutType(rawValue: exerciseTypeRawValue) ?? .general
        self.heartRate = dictionary["heartRate"] as! Double
        self.caloriesBurned = dictionary["caloriesBurned"] as! Int
        self.duration = dictionary["duration"] as! TimeInterval
        self.repetitions = dictionary["repetitions"] as! Int
        self.timestamp = dictionary["timestamp"] as! Date
    }

    func toDictionary() -> [String: Any] {
        return [
            "exerciseType": exerciseType.rawValue,
            "heartRate": heartRate,
            "caloriesBurned": caloriesBurned,
            "duration": duration,
            "repetitions": repetitions,
            "timestamp": timestamp
        ]
    }
}

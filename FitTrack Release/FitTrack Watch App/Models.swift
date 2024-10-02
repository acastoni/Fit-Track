//
//  Models.swift
//  FitTrack
//
//  Created by Anthony Castillo
//

import Foundation
import HealthKit

    public enum CustomWorkoutType: String, CaseIterable, Identifiable {
        case benchPress = "Bench Press"
        case pullUps = "Pull-Ups"
        case general = "General"
        
        public var id: String { self.rawValue }
        
        var hkWorkoutActivityType: HKWorkoutActivityType {
            switch self {
            case .benchPress, .pullUps:
                return .other
            case .general:
                return .other
            }
        }
    }

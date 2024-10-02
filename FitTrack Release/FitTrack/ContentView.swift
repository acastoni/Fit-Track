import SwiftUI
import HealthKit

enum CustomWorkoutType: String, CaseIterable, Identifiable {
    case benchPress = "Bench Press"
    case pullUps = "Pull-Ups"
    case general = "General"
    
    var id: String { self.rawValue }
    
    var hkWorkoutActivityType: HKWorkoutActivityType {
        switch self {
        case .benchPress, .pullUps:
            return .other
        case .general:
            return .other
        }
    }
}

struct ContentView: View {
    @State private var selectedWorkoutType: CustomWorkoutType = .general
    @State private var workoutSession: HKWorkoutSession?
    @State private var isWorkoutActive = false
    @State private var heartRate: Double = 0

    var body: some View {
        VStack {
            if isWorkoutActive {
                Text("Heart Rate: \(heartRate, specifier: "%.1f") bpm")
                Button("End Workout") {
                    endWorkout()
                }
            } else {
                Picker("Select Workout", selection: $selectedWorkoutType) {
                    ForEach(CustomWorkoutType.allCases) { workoutType in
                        Text(workoutType.rawValue).tag(workoutType)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Button("Start Workout") {
                    startWorkout()
                }
            }
        }
        .onAppear {
            HealthKitManager.shared.requestAuthorization { success, error in
                if !success {
                    // Handle error
                }
            }
        }
    }
    
    private func startWorkout() {
        HealthKitManager.shared.startWorkoutSession(activityType: selectedWorkoutType.hkWorkoutActivityType, locationType: .indoor) { session, error in
            if let session = session {
                self.workoutSession = session
                self.isWorkoutActive = true
                HealthKitManager.shared.startHeartRateUpdates { sample in
                    let heartRateUnit = HKUnit(from: "count/min")
                    DispatchQueue.main.async {
                        self.heartRate = sample.quantity.doubleValue(for: heartRateUnit)
                    }
                }
            } else {
                // Handle error
            }
        }
    }
    
    private func endWorkout() {
        if let session = workoutSession {
            session.end()
            self.isWorkoutActive = false
        }
    }
}

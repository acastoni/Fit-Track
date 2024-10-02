//
//  WorkoutView.Swift
//  FitTrack
//
//  Created by Anthony Castillo
//

import SwiftUI
import HealthKit
import CoreMotion

public struct WorkoutView: View {
    public var exerciseType: CustomWorkoutType
    @Binding public var isWorkoutStarted: Bool
    public var onEnd: (WorkoutSummary) -> Void

    @ObservedObject private var healthKitManager = HealthKitManager.shared
    @ObservedObject private var sensorLogManager = SensorLogManager()
    private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var caloriesBurned: Int = 0
    @State private var duration: TimeInterval = 0
    @State private var repetitions: Int = 0
    @State private var isPaused: Bool = false
    @State private var isGyroscopeAvailable: Bool = true
    @State private var gyroscopeErrorMessage: String?
    
    @State private var lastGyrY: Double = 0.0
    @State private var lastGyrZ: Double = 0.0
    @State private var isRepStartDetected: Bool = false
    @State private var showOptions: Bool = false
    @State private var arrowBounce: Bool = false

    public init(exerciseType: CustomWorkoutType, isWorkoutStarted: Binding<Bool>, onEnd: @escaping (WorkoutSummary) -> Void) {
        self.exerciseType = exerciseType
        self._isWorkoutStarted = isWorkoutStarted
        self.onEnd = onEnd
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(exerciseType.rawValue)
                .font(.headline)
                .foregroundColor(.white)

            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("\(healthKitManager.heartRate, specifier: "%.1f") bpm")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .font(.system(size: 30))

                Spacer()
            }

            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("\(caloriesBurned) cal")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .font(.system(size: 30))

                Spacer()
            }

            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                Text("\(formattedDuration())")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .font(.system(size: 30))
                Spacer()
            }

            if exerciseType != .general {
                HStack {
                    Image(systemName: "repeat")
                        .foregroundColor(.green)
                    Text("\(repetitions)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .font(.system(size: 30))

                    Spacer()
                }
            }
            
            if showOptions {
                HStack {
                    Button(action: togglePause) {
                        Text(isPaused ? "🔄" : "⏸️")
                            .font(.system(size: 30))
                            .padding()
                    }
                    .buttonStyle(PlainButtonStyle())
                    Button(action: endWorkout) {
                        Text("❌")
                            .font(.system(size: 30))
                            .padding()
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            if let errorMessage = gyroscopeErrorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
            }

        }
        .padding()
        .onAppear(perform: startWorkout)
        .onReceive(timer) { _ in
            if !isPaused {
                duration += 1
                updateCaloriesBurned()
                countRepetitions()
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .offset(y: arrowBounce ? -10 : 0)
                        .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true))
                        .onAppear {
                            arrowBounce = true
                        }
                        .onTapGesture {
                            showOptions = true
                        }
                }
            }
        )
    }

    private func startWorkout() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                print("HealthKit authorization success.")
                healthKitManager.startWorkoutSession(activityType: exerciseType.hkWorkoutActivityType, locationType: .indoor) { success, error in
                    if success {
                        print("Workout session started.")
                        healthKitManager.startHeartRateUpdates()
                    } else if let error = error {
                        print("Error starting workout session: \(error.localizedDescription)")
                    }
                }
            } else if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            }
        }

        if exerciseType != .general {
            sensorLogManager.startUpdate(50.0)
        }
    }

    private func countRepetitions() {
        let thresholdY = 0.2
        let thresholdZ = 0.2
        
        switch exerciseType {
        case .benchPress:
            if abs(sensorLogManager.gyrY - lastGyrY) > thresholdY && !isRepStartDetected {
                isRepStartDetected = true
            } else if isRepStartDetected && abs(sensorLogManager.gyrY) < thresholdY {
                repetitions += 1
                isRepStartDetected = false
                print("Bench Press Repetition counted. Total: \(repetitions)")
            }
            lastGyrY = sensorLogManager.gyrY

        case .pullUps:
            if abs(sensorLogManager.gyrZ - lastGyrZ) > thresholdZ && !isRepStartDetected {
                isRepStartDetected = true
            } else if isRepStartDetected && abs(sensorLogManager.gyrZ) < thresholdZ {
                repetitions += 1
                isRepStartDetected = false
                print("Pull Up Repetition counted. Total: \(repetitions)")
            }
            lastGyrZ = sensorLogManager.gyrZ

        default:
            break
        }
    }

    private func updateCaloriesBurned() {
        let caloriesPerMinute = 8.0 
        let minutes = duration / 60
        caloriesBurned = Int(minutes * caloriesPerMinute)
        print("Calories burned: \(caloriesBurned)")
    }

    private func formattedDuration() -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func endWorkout() {
        print("Attempting to end workout")
        timer.upstream.connect().cancel()
        print("Timer stopped")
        sensorLogManager.stopUpdate()
        print("Sensor updates stopped")
        healthKitManager.endWorkoutSession()
        print("HealthKit workout session ended")
        
        let summary = WorkoutSummary(exerciseType: exerciseType, heartRate: healthKitManager.heartRate, caloriesBurned: caloriesBurned, duration: duration, repetitions: repetitions)
        saveWorkoutSummary(summary)
        print("Workout summary saved")
        
        isWorkoutStarted = false
        print("Workout state updated")
        
        onEnd(summary)
        print("onEnd closure called")
    }

    private func togglePause() {
        isPaused.toggle()
    }

    private func saveWorkoutSummary(_ summary: WorkoutSummary) {
        var summaries = UserDefaults.standard.array(forKey: "workoutSummaries") as? [[String: Any]] ?? []
        if summaries.count >= 7 {
            summaries.removeFirst()
        }
        summaries.append(summary.toDictionary())
        UserDefaults.standard.set(summaries, forKey: "workoutSummaries")
    }

    private func loadWorkoutSummaries() -> [WorkoutSummary] {
        let summaries = UserDefaults.standard.array(forKey: "workoutSummaries") as? [[String: Any]] ?? []
        return summaries.map { WorkoutSummary(from: $0) }
    }
}

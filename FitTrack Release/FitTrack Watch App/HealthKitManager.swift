//
//  WorkoutSummaryModel.swift
//  FitTrack
//
//  Created by Anthony Castillo
//

import HealthKit

class HealthKitManager: NSObject, ObservableObject {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()

    private var workoutSession: HKWorkoutSession?
    private var heartRateQuery: HKQuery?

    @Published var heartRate: Double = 0
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let readTypes: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]
        let shareTypes: Set<HKSampleType> = [
            HKObjectType.workoutType()
        ]

        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { success, error in
            print("Authorization requested. Success: \(success), Error: \(String(describing: error))")
            completion(success, error)
        }
    }

    func startWorkoutSession(activityType: HKWorkoutActivityType, locationType: HKWorkoutSessionLocationType, completion: @escaping (Bool, Error?) -> Void) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = activityType
        configuration.locationType = locationType
        
        do {
            workoutSession = try HKWorkoutSession(configuration: configuration)
            workoutSession?.delegate = self
            
            healthStore.start(workoutSession!)
            print("Workout session started.")
            startHeartRateUpdates()
            completion(true, nil)
        } catch {
            print("Failed to start workout session: \(error)")
            completion(false, error)
        }
    }

    func endWorkoutSession() {
        workoutSession?.end()
        print("Workout session ended.")
        if let heartRateQuery = heartRateQuery {
            healthStore.stop(heartRateQuery)
            print("Heart rate updates stopped.")
        }
    }

    func startHeartRateUpdates() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            print("Heart rate type is unavailable.")
            return
        }
        
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] _, samples, _, _, error in
            if let error = error {
                print("Error during heart rate updates: \(error.localizedDescription)")
                return
            }
            self?.processHeartRateSamples(samples)
        }

        query.updateHandler = { [weak self] _, samples, _, _, error in
            if let error = error {
                print("Error updating heart rate samples: \(error.localizedDescription)")
                return
            }
            self?.processHeartRateSamples(samples)
        }

        healthStore.execute(query)
        self.heartRateQuery = query
        print("Heart rate updates started.")
    }
    
    private func processHeartRateSamples(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {
            print("No heart rate samples received.")
            return
        }
        
        guard let sample = heartRateSamples.first else {
            print("No heart rate samples found.")
            return
        }
        let heartRateUnit = HKUnit(from: "count/min")
        let heartRate = sample.quantity.doubleValue(for: heartRateUnit)
        DispatchQueue.main.async {
            self.heartRate = heartRate
            print("Heart rate updated: \(heartRate) bpm")
        }
    }
}

extension HealthKitManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("Workout session state changed from \(fromState) to \(toState)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed with error: \(error.localizedDescription)")
    }
}

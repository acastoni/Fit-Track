import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    private var queryAnchor: HKQueryAnchor?
    private var workoutSession: HKWorkoutSession?

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let readTypes: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKSeriesType.workoutRoute(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]
        let shareTypes: Set<HKSampleType> = [
            HKObjectType.workoutType()
        ]

        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes, completion: completion)
    }

    func startWorkoutSession(activityType: HKWorkoutActivityType, locationType: HKWorkoutSessionLocationType, completion: @escaping (Bool, Error?) -> Void) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = activityType
        configuration.locationType = locationType
        
        do {
            if #available(iOS 15.0, *) {
                workoutSession = try HKWorkoutSession(configuration: configuration)
            } else {
                workoutSession = try HKWorkoutSession(activityType: activityType, locationType: locationType)
            }
            workoutSession?.delegate = self
            
            healthStore.start(workoutSession!)
            completion(true, nil)
        } catch {
            completion(false, error)
        }
    }

    func endWorkoutSession() {
        workoutSession?.end()
    }

    func startHeartRateUpdates(completion: @escaping (HKQuantitySample) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: queryAnchor, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, newAnchor, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            self.queryAnchor = newAnchor
            samples?.forEach { sample in
                if let quantitySample = sample as? HKQuantitySample {
                    completion(quantitySample)
                }
            }
        }

        query.updateHandler = { (query, samples, deletedObjects, newAnchor, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            self.queryAnchor = newAnchor
            samples?.forEach { sample in
                if let quantitySample = sample as? HKQuantitySample {
                    completion(quantitySample)
                }
            }
        }

        healthStore.execute(query)
    }
}

extension HealthKitManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        // Handle state changes
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        // Handle errors
    }
}

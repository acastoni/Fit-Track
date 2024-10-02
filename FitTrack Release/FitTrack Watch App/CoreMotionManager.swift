////
////  CoreMotionManager.swift
////  FitTrack
////
////  Created by Anthony Castillo
////
//

//Unused, SensorLogManager used instead.


//import CoreMotion
//import Foundation
//import UIKit
//
//class MotionManager {
//    static let shared = MotionManager()
//    let motionManager = CMMotionManager()
//
//    func requestAuthorization(completion: @escaping (Bool) -> Void) {
//        if CMMotionActivityManager.isActivityAvailable() {
//            print("Motion Activity is available.")
//            completion(true)
//        } else {
//            print("Motion Activity is not available.")
//            completion(false)
//        }
//    }
//
//    func startGyroscopeUpdates(completion: @escaping (Result<CMGyroData, Error>) -> Void) {
//        do {
//            if motionManager.isGyroAvailable {
//                motionManager.gyroUpdateInterval = 0.1
//                motionManager.startGyroUpdates(to: .main) { (data, error) in
//                    if let error = error {
//                        completion(.failure(error))
//                        print("Gyro Error: \(error.localizedDescription)")
//                        return
//                    }
//                    if let data = data {
//                        print("Gyro Data: \(data.rotationRate)")
//                        completion(.success(data))
//                    }
//                }
//            } else {
//                let gyroError = NSError(domain: "com.example.FitTrack", code: 1, userInfo: [NSLocalizedDescriptionKey: "Gyroscope not available."])
//                throw gyroError
//            }
//        } catch let error {
//            completion(.failure(error))
//            print("Gyroscope Error: \(error.localizedDescription)")
//        }
//    }
//
//    func stopGyroscopeUpdates() {
//        motionManager.stopGyroUpdates()
//    }
//}

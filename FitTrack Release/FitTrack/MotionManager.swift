import CoreMotion

class MotionManager {
    static let shared = MotionManager()
    let motionManager = CMMotionManager()

    func startGyroscopeUpdates(completion: @escaping (CMGyroData) -> Void) {
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 0.1
            motionManager.startGyroUpdates(to: .main) { (data, error) in
                if let data = data {
                    completion(data)
                }
            }
        }
    }

    func stopGyroscopeUpdates() {
        motionManager.stopGyroUpdates()
    }
}

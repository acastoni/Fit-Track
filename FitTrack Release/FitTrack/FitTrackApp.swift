import SwiftUI
import HealthKit

@main
struct FitTrackApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    let healthStore = HKHealthStore()

    func applicationDidFinishLaunching(_ application: UIApplication) {
        let readTypes: Set = [HKObjectType.quantityType(forIdentifier: .heartRate)!]
        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            if success {
                print("HealthKit authorization granted!")
            } else {
                print("HealthKit authorization denied!")
            }
        }
    }
}

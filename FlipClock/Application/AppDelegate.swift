import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // migration
        if UserDefaults.standard.bool(forKey: "didSave") {
            let daysSince = UserDefaults.standard.integer(forKey: "CounterViewModel.daysSince")
            let digits = UserDefaults.standard.integer(forKey: "CounterViewModel.digits")
            let description = UserDefaults.standard.string(forKey: "CounterViewModel.description") ?? "Days since last accident"
            let baseValue = UserDefaults.standard.integer(forKey: "CounterViewModel.base")
            let base = Base(rawValue: baseValue) ?? .dec
            let speedRawValue = UserDefaults.standard.integer(forKey: "CounterViewModel.animationSpeed")
            let animationSpeed = AnimationTime(rawValue: speedRawValue) ?? .long
            
            UserDefaults.group.set(animationSpeed.rawValue, forKey: "CounterViewModel.animationSpeed")
            UserDefaults.group.set(base.rawValue, forKey: "CounterViewModel.base")
            UserDefaults.group.set(daysSince, forKey: "CounterViewModel.daysSince")
            UserDefaults.group.set(digits, forKey: "CounterViewModel.digits")
            UserDefaults.group.set(description, forKey: "CounterViewModel.description")
            UserDefaults.group.set(true, forKey: "didSave")
            
            UserDefaults.standard.removeObject(forKey: "didSave")
            UserDefaults.standard.removeObject(forKey: "CounterViewModel.animationSpeed")
            UserDefaults.standard.removeObject(forKey: "CounterViewModel.base")
            UserDefaults.standard.removeObject(forKey: "CounterViewModel.daysSince")
            UserDefaults.standard.removeObject(forKey: "CounterViewModel.digits")
            UserDefaults.standard.removeObject(forKey: "CounterViewModel.description")
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}

in app delegate



import UIKit
import CapacitorPushNotifications
import Capacitor
import Firebase
import FirebaseMessaging
import UserNotifications
import CapacitorLocalNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        //remote Notifications
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (isGranted, err) in
                    if err != nil {
                        //Something bad happend
                    } else {
                        UNUserNotificationCenter.current().delegate = self
                        Messaging.messaging().delegate = self
                        
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                }
            } else {
                // Fallback on earlier versions
            }
            
            if #available(iOS 10, *) {
                UNUserNotificationCenter.current().requestAuthorization(options: [.badge,.sound,.alert], completionHandler: { (granted, error) in
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                })
            }else{
                let notificationSettings = UIUserNotificationSettings(types: [.badge,.sound,.alert], categories: nil)
                UIApplication.shared.registerUserNotificationSettings(notificationSettings)
                UIApplication.shared.registerForRemoteNotifications()
            }
        
        if let lang = KeyChain.load(key: "keyLang"){
            let currentLang = KeyChain.NSDATAtoString(data: lang)
            let userDefault = UserDefaults(suiteName: "group.spl-shared")
            userDefault?.set(currentLang, forKey: "selectedLanguage")
        } else {
            let userDefault = UserDefaults(suiteName: "group.spl-shared")
            userDefault?.set("en", forKey: "selectedLanguage")
            
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Called when the app was launched with a url. Feel free to add additional processing here,
        // but if you want the App API to support tracking app url opens, make sure to keep this call
        return ApplicationDelegateProxy.shared.application(app, open: url, options: options)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // Called when the app was launched with an activity, including Universal Links.
        // Feel free to add additional processing here, but if you want the App API to support
        // tracking app url opens, make sure to keep this call
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "appLaunchBySiriShortcuts"), object: userActivity, userInfo: userActivity.userInfo))
        return ApplicationDelegateProxy.shared.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        
        if let token  = Messaging.messaging().fcmToken {
            print("88888888: \(token)")
            NotificationCenter.default.post(name: .capacitorDidRegisterForRemoteNotifications, object: token)
            Messaging.messaging().subscribe(toTopic: "all_users_ios_PROD")
        }else{
            print("failed to recieve token")
        }
        
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NotificationCenter.default.post(name: .capacitorDidFailToRegisterForRemoteNotifications, object: error)
    }
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
//        return [[.badge, .banner, .sound]]
//    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//
//        return completionHandler([[.badge, .alert, .sound]])
//    }
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
//        print("Mohamed")
//    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if application.applicationState == .active {
            let userDefualt = UserDefaults.standard
            var currentLang = "ar"
            guard let userInfo2 = userInfo as NSDictionary? as? [String: Any] else {return}
            if let titleAr = userInfo2["titleAr"] as? String,
               let bodyAr = userInfo2["bodyAr"] as? String,
               let titleEn = userInfo2["titleEn"] as? String,
               let bodyEn = userInfo2["bodyEn"] as? String,
               let notificationCounter = userInfo2["notificationCounter"] as? String{
                // MARK:- Check if the Current Language is AR Or EN
                //                let currentLang = userDefualt.string(forKey: "keyLang")
                if let userDefault = UserDefaults(suiteName: "group.spl-shared") {
                    guard let lang = KeyChain.load(key: "keyLang") else {return}
                    currentLang = KeyChain.NSDATAtoString(data: lang)
                    userDefault.set(currentLang, forKey: "selectedLanguage")
                    var savedValue = userDefault.string(forKey: "notificationCounter")
                    print("notificationCounter:savedValue: ", savedValue);
                    print("notificationCounter: ", notificationCounter)
                    if Int(notificationCounter) ?? 0 > (Int(savedValue ?? "") ?? 0){
                        userDefault.set(notificationCounter, forKey: "notificationCounter")
                    }else{
                        return
                    }
                }
                
                let content = UNMutableNotificationContent()
                let soundName = UNNotificationSoundName("Confirmation_Kalimba_4.caf")
                let sound = UNNotificationSound(named: soundName)
                content.sound = sound
                if currentLang.contains("ar") {
                    content.title = titleAr
                    content.body = bodyAr
                } else {
                    content.title = titleEn
                    content.body = bodyEn
                }

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier:"SPL-Notification", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error adding notification request: \(error.localizedDescription)")
                        completionHandler(.failed)
                        return
                    }
                    completionHandler(.newData)
                }
            }
        }
        
    }
    
//    func userNotificationCenter(
//        _ center: UNUserNotificationCenter,
//        didReceive response: UNNotificationResponse,
//        withCompletionHandler completionHandler: @escaping () -> Void
//    ){
//            // MARK:- Check if the Current Language is AR Or EN
////                let currentLang = userDefualt.string(forKey: "keyLang")
//
//            guard let lang = KeyChain.load(key: "keyLang") else {return}
//            let currentLang = KeyChain.NSDATAtoString(data: lang)
//
//
//            let content = UNMutableNotificationContent()
//            let soundName = UNNotificationSoundName("Confirmation_Kalimba_4.caf")
//            let sound = UNNotificationSound(named: soundName)
//            content.sound = sound
////            if currentLang.contains("ar") {
////                content.title = titleAr
////                content.body = bodyAr
////            } else {
//                content.title = "titleEn"
//                content.body = "bodyEn"
////            }
//
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//            let request = UNNotificationRequest(identifier:"SPL-Notification", content: content, trigger: trigger)
//            UNUserNotificationCenter.current().add(request) { error in
//                if let error = error {
//                    print("Error adding notification request: \(error.localizedDescription)")
//                    completionHandler()
//                    return
//                }
//                completionHandler()
//            }
//        completionHandler()
//    }
 
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let tokenDict = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
          name: Notification.Name("FCMToken"),
          object: nil,
          userInfo: tokenDict)
      }
    
}



extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 or later devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Receive notification in the foreground \(userInfo)")
        let pref = UserDefaults.init(suiteName: "group.id.gits.notifserviceextension")
        pref?.set(userInfo, forKey: "NOTIF_DATA")
//        guard let vc = UIApplication.shared.windows.first?.rootViewController as? ViewController else { return }
//        vc.handleNotifData()
        completionHandler([.alert, .badge, .sound])
    }
    
}


//
//  NotificationService.swift
//  AppNotificationService
//
//  Created by Mostafa Aboghida on 06/07/2023.
//

import UserNotifications
import FirebaseMessaging

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    
    private var appLanguage: String {
        if let userDefault = UserDefaults(suiteName: "group.spl-shared") {
            if let currentLang = userDefault.string(forKey: "selectedLanguage") {
                return currentLang
            }
        } else {
            return "ar"
        }
        return "ar"
    }

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            
//            guard let lang = KeyChain.load(key: "keyLang") else {return}
//            let currentLang = KeyChain.NSDATAtoString(data: lang)
//            guard let userInfo2 = bestAttemptContent.userInfo as NSDictionary? as? [String: Any] else {
//
//                return
//            }
            if let titleAr = bestAttemptContent.userInfo["titleAr"] as? String,
               let bodyAr = bestAttemptContent.userInfo["bodyAr"] as? String,
               let titleEn = bestAttemptContent.userInfo["titleEn"] as? String,
               let bodyEn = bestAttemptContent.userInfo["bodyEn"] as? String,
               let notificationCounter = bestAttemptContent.userInfo["notificationCounter"] as? String {
//                bestAttemptContent.title = "\(titleEn)"
//                bestAttemptContent.body = bodyEn
                debugPrint("notificationCounter: ", notificationCounter)
                print("notificationCounter: ", notificationCounter)
//                if let userDefault = UserDefaults(suiteName: "group.spl-shared") {
//                    userDefault.set(notificationCounter, forKey: "notificationCounter")
//                }
                
                if appLanguage.contains("ar") {
                    bestAttemptContent.title = "\(titleAr)"
                    bestAttemptContent.body = bodyAr
                    
                } else {
                    bestAttemptContent.title = "\(titleEn)"
                    bestAttemptContent.body = bodyEn
                }
                
            }
            contentHandler(bestAttemptContent)
        }
        
//        self.contentHandler = contentHandler
//        bestAttemptContent = request.content
//          .mutableCopy() as? UNMutableNotificationContent
//        guard let bestAttemptContent = bestAttemptContent else { return }
//        FIRMessagingExtensionHelper().populateNotificationContent(
//          bestAttemptContent,
//          withContentHandler: contentHandler)

    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}

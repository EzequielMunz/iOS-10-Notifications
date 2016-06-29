//
//  NotificationsManager.swift
//  Siri+Notifications
//
//  Created by Ezequiel Munz on 27/6/16.
//  Copyright © 2016 Ezequiel Munz. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

class NotificationsManager : NSObject, UNUserNotificationCenterDelegate {
    
    static let sharedInstance : NotificationsManager = NotificationsManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization([.alert, .badge, .sound]) { success, error in
            if error != nil {
                print(error)
            }
        }
    }
    
    // MARK: UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        switch response.actionIdentifier {
        case "Action":
            print("Action triggered")
        default:
            break
        }
        NotificationCenter.default().post(name: "NotificationsUpdate" as NSNotification.Name, object: nil)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        let alert : UIAlertController = UIAlertController(title: "New notification", message: "New notification test on iOS 10", preferredStyle: .alert)
        let cancelAction : UIAlertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        (UIApplication.shared().delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
        NotificationCenter.default().post(name: "NotificationsUpdate" as NSNotification.Name, object: nil)
    }
    
    // MARK: Schedule local notifications
    
    func scheduleLocalNotification(timeInterval : Double) {
        let action : UNNotificationAction = UNNotificationAction(identifier: "Action", title: "Got it!!!", options: .destructive)
        let category : UNNotificationCategory = UNNotificationCategory(identifier: "Category", actions: [action], minimalActions: [action], intentIdentifiers: [], options: [.customDismissAction])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        let content : UNMutableNotificationContent = UNMutableNotificationContent()
        content.title = "New notification"
        content.body = "New notification test on iOS 10"
        
        let trigger : UNTimeIntervalNotificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let requestIdentifier : String = "Custom notification request"
        let request : UNNotificationRequest = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                NotificationCenter.default().post(name: "NotificationsUpdate" as NSNotification.Name, object: nil)
            }
        }
    }
    
    // MARK: Get pending notification requests
    
    func requestPendingNotifications(completionHandler : ([Date]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests() { pendingNotifications in
            var pendingNotificationsDates : [Date] = []
            for notification in pendingNotifications {
                guard
                    let trigger = notification.trigger as? UNTimeIntervalNotificationTrigger,
                    let date = trigger.nextTriggerDate()
                    else { break }
                pendingNotificationsDates.append(date)
                completionHandler(pendingNotificationsDates)
            }
        }
    }
    
    // MARK: Get delivered notifications
    
    func requestDeliveredNotifications(completionHandler : ([Date]) -> Void) {
        UNUserNotificationCenter.current().getDeliveredNotifications() { deliveredNotifications in
            var deliveredNotificationsDates : [Date] = []
            for notification in deliveredNotifications {
                deliveredNotificationsDates.append(notification.date)
            }
            completionHandler(deliveredNotificationsDates)
        }
    }
}


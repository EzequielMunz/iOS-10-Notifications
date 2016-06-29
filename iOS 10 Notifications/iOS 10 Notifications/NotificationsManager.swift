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
    private var counter : Int = 0
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization([.alert, .badge, .sound]) { success, error in
            if error != nil {
                print(error)
            }
        }
    }
    
    func reset() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
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
        content.badge = counter
        
        let trigger : UNTimeIntervalNotificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        // The request identifier must be unique. If you create a new notification request with the same identifier that one pending notification, it will be overwritten with the new one. If you wanna trigger multiple notifications, the request identifier must be different on each case.
        let requestIdentifier : String = "Custom notification request \(counter)"
        let request : UNNotificationRequest = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                NotificationCenter.default().post(name: "NotificationsUpdate" as NSNotification.Name, object: nil)
                self.counter += 1
            }
        }
    }
    
    // MARK: Get pending notification requests
    // Pending notification requests are the request that are created, but not triggered yet.
    func requestPendingNotifications(completionHandler : ([Date]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests() { pendingNotifications in
            var pendingNotificationsDates : [Date] = []
            for notification in pendingNotifications {
                guard
                    let trigger = notification.trigger as? UNTimeIntervalNotificationTrigger,
                    let date = trigger.nextTriggerDate()
                    else { break }
                pendingNotificationsDates.append(date)
            }
            completionHandler(pendingNotificationsDates)
            print("Count Pending: \(pendingNotifications.count)")
        }
    }
    
    // MARK: Get delivered notifications
    // The delivered notifications are the ones that the user didn't read yet. If the notification is already opened, it will not appear on the delivered notifications list.
    func requestDeliveredNotifications(completionHandler : ([Date]) -> Void) {
        UNUserNotificationCenter.current().getDeliveredNotifications() { deliveredNotifications in
            var deliveredNotificationsDates : [Date] = []
            for notification in deliveredNotifications {
                deliveredNotificationsDates.append(notification.date)
            }
            completionHandler(deliveredNotificationsDates)
            print("Count Delivered: \(deliveredNotifications.count)")
        }
    }
}


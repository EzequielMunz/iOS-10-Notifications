//
//  ViewController.swift
//  iOS 10 Notifications
//
//  Created by eze on 6/29/16.
//  Copyright © 2016 Globant. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    var pendingNotifications : [Date] = []
    var deliveredNotifications : [Date] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updateTimeLabel()
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default().addObserver(self, selector: #selector(ViewController.updateTableView), name: "NotificationsUpdate", object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default().removeObserver(self)
    }
    
    // UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return pendingNotifications.count
        case 1:
            return deliveredNotifications.count
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : NotificationsCell = tableView.dequeueReusableCell(withIdentifier: "NotificationsCell") as! NotificationsCell
        var notificationDate : Date?
        switch indexPath.section {
        case 0:
            notificationDate = pendingNotifications[indexPath.row]
        case 1:
            notificationDate = deliveredNotifications[indexPath.row]
        default:
            break
        }
        
        if let validDate = notificationDate {
            let formatter : DateFormatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy hh:mm:ss"
            cell.dateLabel.text = formatter.string(from: validDate)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Pending notifications"
        }
        else {
            return "Delivered notifications"
        }
    }
    
    // MARK: Helpers
    
    func updateTimeLabel() {
        timeLabel.text = "\(Int(slider.value)) Sec"
    }
    
    func updateTableView() {
        let pendingUpdateCompletion : ([Date]) -> Void = { dates in
            self.pendingNotifications = dates
            self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        }
        
        let deliveredUpdateCompletion : ([Date]) -> Void = { dates in
            self.deliveredNotifications = dates
            self.tableView.reloadSections(IndexSet(integer: 1), with: .fade)
        }
        
        NotificationsManager.sharedInstance.requestPendingNotifications(completionHandler: pendingUpdateCompletion)
        NotificationsManager.sharedInstance.requestDeliveredNotifications(completionHandler: deliveredUpdateCompletion)
    }
    
    // MARK: Actions

    @IBAction func scheduleNotification(_ sender: AnyObject) {
        NotificationsManager.sharedInstance.scheduleLocalNotification(timeInterval: Double(slider.value))
    }

    @IBAction func didSelectTimeInterval(_ sender: AnyObject) {
        updateTimeLabel()
    }
}


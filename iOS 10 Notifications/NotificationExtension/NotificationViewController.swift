//
//  NotificationViewController.swift
//  NotificationExtension
//
//  Created by eze on 6/29/16.
//  Copyright © 2016 Globant. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension, UITableViewDataSource {

    @IBOutlet var label: UILabel?
    @IBOutlet var tableView : UITableView?
    private var counter : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
        
        tableView?.dataSource = self
    }
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = notification.request.content.body
    }

    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = "Test #\(counter)"
        counter += 1
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Section 1"
        }
        else {
            return "Section 2"
        }
    }

}

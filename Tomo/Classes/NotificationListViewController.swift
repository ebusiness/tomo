//
//  NotificationListViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/09/04.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//


import UIKit

class NotificationListViewController: MyAccountBaseController {
    
    private var notifications:[NotificationEntity]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        self.registerForNotifications()
    }
}

extension NotificationListViewController {
    
// MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NotificationCell
        cell.notification = self.notifications![indexPath.row]
        return cell
    }
    
// MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! NotificationCell
        cell.didSelect(self)
    }
}

extension NotificationListViewController {
    
    private func loadData() {
        var params = Dictionary<String, AnyObject>()
        
        if let oldestNotifications = self.notifications?.last {
            params["before"] = oldestNotifications.createDate.timeIntervalSince1970
        }
        
        AlamofireController.request(.GET, "/notifications", parameters: params, success: { result in
            let loadNotifications:[NotificationEntity]? = NotificationEntity.collection(result)
            if let notifications = self.notifications {
                self.notifications = notifications + (loadNotifications ?? [])
            } else {
                self.notifications = loadNotifications
            }
            self.appendRows(loadNotifications?.count ?? 0)
        }) { err in
            
        }
    }
    
    private func appendRows(rows: Int) {
        let notificationsCount = self.notifications?.count ?? 0
        let firstIndex = notificationsCount - rows
        let lastIndex = notificationsCount
        
        var indexPathes = [NSIndexPath]()
        
        for index in firstIndex..<lastIndex {
            indexPathes.push(NSIndexPath(forRow: index, inSection: 0))
        }
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(indexPathes, withRowAnimation: .Fade)
        tableView.endUpdates()
        
    }
    
// MARK: NSNotificationCenter
    
    private func registerForNotifications() {
        ListenerEvent.FriendInvited.addObserver(self, selector: Selector("receiveFriendInvited:"))
        ListenerEvent.FriendAccepted.addObserver(self, selector: Selector("receiveFriendAccepted:"))
        ListenerEvent.FriendRefused.addObserver(self, selector: Selector("receiveFriendRefused:"))
    }
}



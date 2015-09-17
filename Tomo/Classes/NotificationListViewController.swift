//
//  NotificationListViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/09/04.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//


import UIKit

class NotificationListViewController: MyAccountBaseController {
    
    private let loadTriggerHeight = CGFloat(88.0)
    
    private var notifications:[NotificationEntity]?
    private var isLoading = false
    private var isExhausted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        self.registerForNotifications()
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        super.scrollViewDidScroll(scrollView)
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (contentHeight - UIScreen.mainScreen().bounds.height - loadTriggerHeight) < offsetY {
            loadData()
        }
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
        
        // skip if already in loading
        if isLoading || isExhausted {
            return
        }
        
        isLoading = true
        
        var params = Dictionary<String, AnyObject>()
        
        if let oldestNotifications = self.notifications?.last {
            params["before"] = oldestNotifications.createDate.timeIntervalSince1970
        }
        
        AlamofireController.request(.GET, "/notifications", parameters: params, success: { result in
            
            me.notifications = 0
            self.navigationController?.tabBarItem.badgeValue = nil
            
            let loadNotifications:[NotificationEntity]? = NotificationEntity.collection(result)
            if let notifications = self.notifications {
                self.notifications = notifications + (loadNotifications ?? [])
            } else {
                self.notifications = loadNotifications
            }
            self.appendRows(loadNotifications?.count ?? 0)
            self.isLoading = false
            
        }) { err in
            
            self.isLoading = false
            self.isExhausted = true
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
}

// MARK: NSNotificationCenter

extension NotificationListViewController {

    private func registerForNotifications() {
        ListenerEvent.Any.addObserver(self, selector: Selector("receiveAny:"))
    }
    
    func receiveAny(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let remoteNotification = NotificationEntity(userInfo)
            
            if let type = ListenerEvent(rawValue: remoteNotification.type) {
                if type == .FriendInvited || type == .Message { //receive it by friendlistviewcontroller
                    return
                }
            }
            
            if let notifications = self.notifications {
                self.notifications!.insert(remoteNotification, atIndex: 0)
            } else {
                self.notifications = [remoteNotification]
            }
            gcd.sync(.Main) {
                self.tableView.beginUpdates()
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Fade)
                self.tableView.endUpdates()
            }
        }
    }
}



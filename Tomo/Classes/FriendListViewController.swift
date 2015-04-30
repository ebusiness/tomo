//
//  FriendListViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/09.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

enum FriendListDisplayMode {
    case Chat, List
}

class FriendListViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    var friendInvitedNotifications = [Notification]()
    var users = [User]()

    var displayMode = FriendListDisplayMode.Chat
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if displayMode != .Chat {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if displayMode == .Chat {
            loadData()
            
            ApiController.unconfirmedNotification { (error) -> Void in
                ApiController.getFriends { (error) -> Void in
//                    if error == nil {
                        self.loadData()
                        self.tableView.reloadData()
//                    }
                }
            }
        }
    }

    func loadData() {
        users = DBController.friends()
        friendInvitedNotifications = DBController.unconfirmedNotification(type: .FriendInvited)
    }
}

extension FriendListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && displayMode == .Chat {
            return 1
        }
        
        if section == 1 {
            return users.count
        }

        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44
        }
        
        return 60
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("NewCell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        }
        
        let friend = users[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCell
        
        cell.friend = friend
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            performSegueWithIdentifier("SegueNewNotification", sender: nil)
        }
        
        if indexPath.section == 1 {
            let friend = users[indexPath.row]
            
            if displayMode == .Chat {
                let vc = Util.createViewControllerWithIdentifier(nil, storyboardName: "Message") as! MessageViewController

                vc.friend = friend
                
                navigationController?.pushViewController(vc, animated: true)
            }

            if displayMode == .List {
                let vc = Util.createViewControllerWithIdentifier("AccountEditViewController", storyboardName: "Account") as! AccountEditViewController
                vc.user = friend
                vc.readOnlyMode = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }

    }

}


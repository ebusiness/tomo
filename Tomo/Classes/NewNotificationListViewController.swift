//
//  NewNotificationListViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/23.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class NewNotificationListViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    var friendInvitedNotifications = [Notification]()
    var invitedUsers = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()

        friendInvitedNotifications = DBController.unconfirmedNotification(type: .FriendInvited)
        invitedUsers = DBController.invitedUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NewNotificationListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return friendInvitedNotifications.count
        }
        
        if section == 1 {
            return invitedUsers.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 94
        }
        
        return 60
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("FriendInvitedCell", forIndexPath: indexPath) as! FriendInvitedCell
            cell.friendInvitedNotification = friendInvitedNotifications[indexPath.row]
            cell.delegate = self
            
            return cell
        }
        
        let user = invitedUsers[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCell
        
        cell.friend = user
        
        return cell
    }
    
}


// MARK: - FriendInvitedCellDelegate

extension NewNotificationListViewController: FriendInvitedCellDelegate {
    
    func friendInvitedCellAllowed(cell: FriendInvitedCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            friendInvitedNotifications.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        
        ApiController.approveFriendInvite(cell.friendInvitedNotification.id!, done: { (error) -> Void in
        })
    }
}

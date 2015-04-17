//
//  NotificationLsitViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class NotificationListViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var notificationType: NotificationType!
    var notifications = [UnconfirmedNotification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
        
        ApiController.unconfirmedNotification { (error) -> Void in
            println("[done]\(error)")
            self.updateUI()
        }
        
        // Do any additional setup after loading the view.
    }

    func updateUI() {
//        if notificationType == NotificationType.Invited {
//            notifications = DBController.myUser().invited.array as! [User]
//            tableView.reloadData()
//            return
//        }
        
        notifications = DBController.unconfirmedNotification(type: notificationType)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(sender: AnyObject) {
        close()
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

extension NotificationListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendInvitedCell", forIndexPath: indexPath) as! FriendInvitedCell
        cell.friendInvitedNotification = notifications[indexPath.row]
        
        return cell
    }
    
    
}

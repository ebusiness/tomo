//
//  FriendListViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/09.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

enum NextView: Int {
    case UserDetailFriend, UserDetail, Chat, Posts, AddFriend, UserDetailInvited
}

class FriendListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var friendInvitedNotifications = [Notification]()
    var invitedUsers = [User]()
    var users = [User]()
    
    var nextView: NextView!

    var fromSearch = false
    
    func friendAtIndexPath(indexPath: NSIndexPath) -> User {
        var friend: User
        
        if indexPath.section == 1 {
            friend = invitedUsers[indexPath.row]
        } else {
            friend = users[indexPath.row]
        }
        
        return friend
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //from search
        if users.count > 0 {
            fromSearch = true
            self.navigationItem.rightBarButtonItem = nil
            return
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !fromSearch {
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
        invitedUsers = DBController.invitedUsers()
        friendInvitedNotifications = DBController.unconfirmedNotification(type: .FriendInvited)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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

extension FriendListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int
        
        switch section {
        case 0:
            count = friendInvitedNotifications.count
        case 1:
            count = invitedUsers.count
        case 2:
            count = users.count
        default:
            count = 0
        }
        
        return count
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
        
        let friend = friendAtIndexPath(indexPath)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCell
        
        cell.friend = friend
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            return
        }
        
        let friend = friendAtIndexPath(indexPath)
        
        if !fromSearch && !DBController.isInvitedUser(friend) {
            let vc = Util.createViewControllerWithIdentifier(nil, storyboardName: "Message") as! MessageViewController

            vc.friend = friend
            
            navigationController?.pushViewController(vc, animated: true)
        }
        
//        if nextView == .Posts {
//            let vc = Util.createViewControllerWithIdentifier("NewsfeedViewController", storyboardName: "Newsfeed") as! NewsfeedViewController
//            vc.user = friend
//            navigationController?.pushViewController(vc, animated: true)
//        }
        
        if fromSearch && !DBController.isInvitedUser(friend) && friend.id != DBController.myUser().id {
            ApiController.invite(friend.id!, done: { (error) -> Void in
                if error == nil {
                    Util.showSuccess("友達追加リクエストを送信しました。")
                    self.tableView.reloadData()

                    
                    //追加要求済み表示
//                    self.users = DBController.users()
//                    self.tableView.reloadData()
                }
            })
        }

    }

}

// MARK: - FriendInvitedCellDelegate

extension FriendListViewController: FriendInvitedCellDelegate {
    
    func friendInvitedCellAllowed(cell: FriendInvitedCell) {
        ApiController.approveFriendInvite(cell.friendInvitedNotification.id!, done: { (error) -> Void in
            if error == nil {
                self.loadData()
                self.tableView.reloadData()
            }
        })
    }
}

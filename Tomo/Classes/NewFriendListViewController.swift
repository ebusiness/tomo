//
//  NewFriendListViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class NewFriendListViewController: BaseTableViewController {
    
    @IBOutlet weak var addFriendButton: UIButton!
    
    var friendInvitedNotifications = [Notification]()
    var users:[UserEntity]? {
        didSet{
            self.tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Util.changeImageColorForButton(addFriendButton,color: UIColor.whiteColor())
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateBadgeNumber"), name: kNotificationGotNewMessage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("becomeActive"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        self.getFriends()
        
        updateBadgeNumber()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ApiController.unconfirmedNotification { (error) -> Void in
            ApiController.getMyInfo({ (error) -> Void in
                ApiController.getFriends { (error) -> Void in
                    ApiController.getMessage({ (error) -> Void in
                        self.updateBadgeNumber()
                    })
                }
            })
        }
        
    }
    
    override func setupMapping() {
        
        let userMapping = RKObjectMapping(forClass: UserEntity.self)
        userMapping.addAttributeMappingsFromDictionary([
            "_id": "id",
            "tomoid": "tomoid",
            "nickName": "nickName",
            "gender": "gender",
            "photo_ref": "photo",
            "cover_ref": "cover",
            "bioText": "bio",
            "firstName": "firstName",
            "lastName": "lastName",
            "birthDay": "birthDay",
            "telNo": "telNo",
            "address": "address",
            ])
        
        let responseDescriptorUserInfo = RKResponseDescriptor(mapping: userMapping, method: .GET, pathPattern: "/connections/friends", keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        self.manager.addResponseDescriptor(responseDescriptorUserInfo)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return friendInvitedNotifications.count
        }
        
        if section == 1 {
            return self.users?.count ?? 0
        }
        
        return 0
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("InvitationCell", forIndexPath: indexPath) as! NewInvitationCell
            cell.friendInvitedNotification = friendInvitedNotifications[indexPath.row]
            cell.delegate = self
            
            cell.setupDisplay()
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! NewFriendCell
            
            cell.user = self.users?[indexPath.row]
            
            cell.setupDisplay()
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            
            let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
            
//            vc.user = friendInvitedNotifications[indexPath.row].from
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.section == 1 {
        
            let friend = self.users![indexPath.row]
            
            DBController.makeAllMessageRead(friend.id)
//            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? RecentlyFriendCell {
//                cell.clearBadge()
//            }
            (self.navigationController?.tabBarController as? TabBarController)?.updateBadgeNumber()
            
            let vc = MessageViewController()
            vc.hidesBottomBarWhenPushed = true
            
//            vc.friend = friend
            
            navigationController?.pushViewController(vc, animated: true)
            
        }
    
    }
    
    func getFriends(){
        
        self.manager.getObjectsAtPath("/connections/friends", parameters: nil, success: { (_, results) -> Void in
            
            if let friends = results.array() as? [UserEntity] {
                
                self.users = friends.sorted({if let uid1 = $0.id, let uid2 = $1.id {
                    let message1 = DBController.lastMessage(uid1)
                    let message2 = DBController.lastMessage(uid2)
                    if message1 == nil && message2 == nil {
                        return true
                    }
                    
                    return message1?.createDate?.timeIntervalSinceNow > message2?.createDate?.timeIntervalSinceNow
                    }
                    
                    return false
                })
            }
            
        }, failure: nil)
    }
    
    func updateBadgeNumber() {
        self.getFriends()
        friendInvitedNotifications = DBController.unconfirmedNotification(type: .FriendInvited)
        tableView.reloadData()
        
        (navigationController?.tabBarController as? TabBarController)?.updateBadgeNumber()
    }
    
    func becomeActive() {
        ApiController.getMessage({ (error) -> Void in
            self.updateBadgeNumber()
        })
    }

}

// MARK: - FriendInvitationCellDelegate

extension NewFriendListViewController: FriendInvitationCellDelegate {
    
    func friendInvitationAccept(cell: NewInvitationCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            friendInvitedNotifications.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        ApiController.friendInvite(cell.friendInvitedNotification!.id!,isApproved: true, done: { (error) -> Void in
            self.updateBadgeNumber()
        })
    }
    
    func friendInvitationDeclined(cell: NewInvitationCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            friendInvitedNotifications.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        ApiController.friendInvite(cell.friendInvitedNotification!.id!,isApproved:false, done: { (error) -> Void in
            self.updateBadgeNumber()
        })
    }
}

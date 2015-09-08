//
//  FriendListSendRequestController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//


import UIKit

class FriendListSendRequestController: MyAccountBaseController {
    
    @IBOutlet weak var addFriendButton: UIButton!
    
    let emptyView = Util.createViewWithNibName("EmptyFriends")
    
    var invitedUsers:[UserEntity]?{
        didSet{
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Util.changeImageColorForButton(addFriendButton,color: UIColor.whiteColor())
        
        self.tableView.backgroundView = self.emptyView

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        Util.showHUD()
        self.manager.getObjectsAtPath("/invitations", parameters: nil, success: { (operation, result) -> Void in
            
            Util.dismissHUD()
            if let result = result.array() as? [UserEntity] {
                self.invitedUsers = result
                self.tableView.backgroundView = nil
            }
            
            }) { (operation, error) -> Void in
                self.tableView.backgroundView = self.emptyView
        }
    }
    
    override func setupMapping() {
        
        let userMapping = RKObjectMapping(forClass: UserEntity.self)
        userMapping.addAttributeMappingsFromDictionary([
            "_id": "id",
            "nickName": "nickName",
            "gender": "gender",
            "photo_ref": "photo",
            "cover_ref": "cover",
            "bio": "bio",
            "firstName": "firstName",
            "lastName": "lastName",
            "birthDay": "birthDay",
            "telNo": "telNo",
            "address": "address",
            ])
        // edit user
        let responseDescriptor = RKResponseDescriptor(mapping: userMapping, method: .GET, pathPattern: "/invitations", keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        self.manager.addResponseDescriptor(responseDescriptor)
    }
    
    @IBAction func searchFriend(sender: AnyObject) {
        let vc = Util.createViewControllerWithIdentifier("SearchFriend", storyboardName: "Chat")
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
}

extension FriendListSendRequestController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitedUsers?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let user = invitedUsers?[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! RequestFriendCell
        cell.user = user
        
        return cell
    }
}

extension FriendListSendRequestController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
        vc.user = invitedUsers?[indexPath.row]
        
        self.navigationController?.pushViewController(vc, animated: true)

    }
}



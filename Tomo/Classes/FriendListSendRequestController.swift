//
//  FriendListSendRequestController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//


import UIKit

class FriendListSendRequestController: MyAccountBaseController {
    
    var invitedUsers:[UserEntity]?{
        didSet{
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.manager.getObjectsAtPath("/mobile/user/invited", parameters: nil, success: { (operation, result) -> Void in
            
            if let result = result.array() as? [UserEntity] {
                self.invitedUsers = result
            }
            
        }) { (operation, error) -> Void in

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
        // edit user
        let responseDescriptor = RKResponseDescriptor(mapping: userMapping, method: .GET, pathPattern: "/mobile/user/invited", keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        self.manager.addResponseDescriptor(responseDescriptor)
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



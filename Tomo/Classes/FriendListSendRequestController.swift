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
        
        AlamofireController.request(.GET, "/invitations", success: { result in
            if let result:[UserEntity] = UserEntity.collection(result) {
                self.invitedUsers = result
                self.tableView.backgroundView = nil
            }
        }) { _ in
            self.tableView.backgroundView = self.emptyView
        }
    }
    
    @IBAction func searchFriend(sender: AnyObject) {
        let vc = Util.createViewControllerWithIdentifier("SearchFriend", storyboardName: "Contacts")
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
}
// MARK: - UITableViewDataSource
extension FriendListSendRequestController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitedUsers?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let user = invitedUsers?[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! RequestFriendCell
        cell.user = user
        
        return cell
    }
}
// MARK: - UITableViewDelegate
extension FriendListSendRequestController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
        vc.user = invitedUsers?[indexPath.row]
        
        self.navigationController?.pushViewController(vc, animated: true)

    }
}



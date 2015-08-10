//
//  ProfileViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ProfileViewController: ProfileBaseController {

    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var birthDayLabel: UILabel!
    
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var deleteFriendButton: UIButton!
    @IBOutlet weak var sendMessageCell: UITableViewCell!
    
    @IBOutlet weak var invitedView: UIView!
    @IBOutlet weak var heightOfInvitedView: NSLayoutConstraint!
    
    var invitedId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let friends = me.friends where friends.contains(self.user.id) {
            
            self.getUserInfo()
        
        } else {
            
            var param = Dictionary<String, String>()
            param["type"] = "friend-invited"
            param["_from"] = self.user.id
            Manager.sharedInstance.request(.GET, kAPIBaseURLString + "/notifications/unconfirmed", parameters: param)
                .responseJSON { (_, res, data, _) -> Void in
                    
                    if let arr = data as? NSArray ,dict = arr[0] as? Dictionary<String, AnyObject> , id = dict["_id"] as? String {
                        self.invitedId = id
                    }
                    self.getUserInfo()
            }
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
        
        let responseDescriptorUserInfo = RKResponseDescriptor(mapping: userMapping, method: .GET, pathPattern: "/users/:id", keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        self.manager.addResponseDescriptor(responseDescriptorUserInfo)
    }
    
    @IBAction func Approved(sender: UIButton) {
        
        inviteAction(true)
    }
    
    @IBAction func Declined(sender: UIButton) {
        
        inviteAction(false)
    }
    
    @IBAction func deleteFriend(sender: UIButton) {
        
        Util.alert(self, title: "删除好友", message: "确定删除该好友么?", action: { (_) -> Void in
            var param = Dictionary<String, String>()
            param["id"] = self.user.id
            
            Manager.sharedInstance.request(.PATCH, kAPIBaseURLString + "/connections/break", parameters: param)
                .responseJSON { (_, _, _, error) -> Void in
                    
                    if let error = error {
                        
                    } else {
                        me.friends?.remove(self.user.id)
                        Util.showSuccess("已删除好友")
                    }
                    self.updateUI()
            }
        })
        
    }
    
    @IBAction func addFriend(sender: UIButton) {
        
        Util.showHUD()
        
        var param = Dictionary<String, String>()
        param["id"] = self.user.id
        
        Manager.sharedInstance.request(.PATCH, kAPIBaseURLString + "/connections/invite", parameters: param)
            .responseJSON { (_, _, _, _) -> Void in
                
                if me.invited == nil {
                    me.invited = []
                }
                me.invited?.append(self.user.id)
                Util.showSuccess("已发送交友请求")
                self.updateUI()
        }
        
    }
    
    @IBAction func sendMessage(sender: UIButton) {
        
        let vc = MessageViewController()
        vc.hidesBottomBarWhenPushed = true
        
        vc.friend = self.user
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}

extension ProfileViewController {
    
    func getUserInfo(){
        
        Util.showHUD()
        self.manager.getObject(nil, path: "/users/\(self.user.id)", parameters: nil, success: { (operation, result) -> Void in
            if let result = result.firstObject as? UserEntity {
                
                self.user = result
                self.updateUI()
                
            }
            Util.dismissHUD()
            
        }, failure: nil)
    }
    
    func updateUI() {
        
        fullNameLabel.text = user?.fullName()
        
        genderLabel.text = user?.gender
        
        //        birthDayLabel.text = user?.birthDay.
        
        addressLabel.text = user?.address
        
        self.addFriendButton.hidden = true
        self.deleteFriendButton.hidden = true
        self.sendMessageCell.hidden = true
        self.invitedView.hidden = true
        
        if let friends = me.friends where friends.contains(self.user.id) {
            
            self.deleteFriendButton.hidden = false
            self.sendMessageCell.hidden = false
            
        } else {
            
            if let id = self.invitedId {
                
                self.invitedView.hidden = false
                
                self.heightOfInvitedView.constant = 44
                self.changeHeaderView(height:284)
                
            } else if let invited = me.invited where invited.contains(self.user.id) {
                //invited
            } else if user.id != me.id {
                self.addFriendButton.hidden = false
            }
            
        }

    }
    
    func inviteAction(isApproved:Bool){
        
        if let id = self.invitedId {
            
            Util.showHUD()
            var param = Dictionary<String, String>()
            param["result"] = isApproved ? "approved" : "declined"
            
            
            Manager.sharedInstance.request(.PATCH, kAPIBaseURLString + "/notifications/\(id)", parameters: param)
                .responseJSON { (_, _, _, _) -> Void in
                    
                    if isApproved {
                        Util.showSuccess("已同意添加好友")
                        
                        if me.friends == nil {
                            me.friends = []
                        }
                        me.friends?.append(self.user.id)
                    } else {
                        Util.showSuccess("已拒绝添加好友")
                    }
                    
                    self.heightOfInvitedView.constant = 0
                    self.changeHeaderView(height:240,done: { () -> () in
                        
                        self.invitedId = nil
                        self.updateUI()
                    })
            }
            
        }
        
    }
}

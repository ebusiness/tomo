//
//  ProfileBaseController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ProfileBaseController: BaseTableViewController {
    
    var user:UserEntity!
    
    // MARK: - segue for profile header
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let vc = segue.destinationViewController as? ProfileHeaderViewController {
            
            vc.user = self.user
            if let parent = segue.sourceViewController as? ProfileViewController {
                self.getUserInfo({ (id) -> () in
                    vc.user = self.user
                    parent.invitedId = id
                })
            }
            
            self.whenShowNavigationBar = { (OffsetY)->() in
                
                self.setNavigationBarBackgroundImage(vc.coverImageView.image)
                
            }
            self.whenHideNavigationBar = { (OffsetY)->() in
                
                vc.photoImageView.constraints().map { (constraint:AnyObject) -> () in
                    
                    if let constraint = constraint as? NSLayoutConstraint
                        where constraint.firstAttribute == .Width || constraint.firstAttribute == .Height
                    {
                        var constant = (1 - (OffsetY / self.headerHeight) ) * 100 //speed
                        if constant > 100 { constant = 100 }
                        else if constant < 60 { constant = 60 }
                        constraint.constant = constant
                        
                        vc.photoImageView.layer.cornerRadius = constant / 2
                    }
                }
                vc.photoImageView.superview?.constraints().map { (constraint:AnyObject) -> () in
                    
                    if let constraint = constraint as? NSLayoutConstraint
                        where constraint.firstAttribute == .CenterY
                    {
                        var constant = OffsetY / self.headerHeight * 100 //speed
                        if constant > 40 { constant = 40 }
                        else if constant < 0 { constant = 0 }
                        constraint.constant = constant
                    }
                    
                }
                
                //                let alpha = OffsetY / self.headerHeight
                self.setNavigationBarBackgroundImage(nil)
                
            }

            
        } else if let vc = segue.destinationViewController as? ProfileBaseController {
            vc.user = self.user
        }
        
    }
    
    override func setupMapping() {
        
        let userMapping = RKObjectMapping(forClass: UserEntity.self)
        userMapping.addAttributeMappingsFromDictionary([
            "_id": "id",
            "nickName": "nickName",
            "firstName": "firstName",
            "lastName": "lastName",
            "photo_ref": "photo",
            "cover_ref": "cover",
            "birthDay": "birthDay",
            "gender": "gender",
            "telNo": "telNo",
            "address": "address",
            "bio": "bio",
            ])
        
        let responseDescriptorUserInfo = RKResponseDescriptor(mapping: userMapping, method: .GET, pathPattern: "/users/:id", keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        self.manager.addResponseDescriptor(responseDescriptorUserInfo)
    }
}

extension ProfileBaseController {
    
    func getUserInfo(done: ((String?)->()) ){
        
        Util.showHUD()
        
        self.manager.getObject(nil, path: "/users/\(self.user.id)", parameters: nil, success: { (operation, result) -> Void in
            if let result = result.firstObject as? UserEntity {
                self.user = result
                
                if let friends = me.friends where friends.contains(self.user.id) {
                    self.updateUI()
                } else {
                    var param = Dictionary<String, String>()
                    param["type"] = "friend-invited"
                    param["_from"] = self.user.id
                    Manager.sharedInstance.request(.GET, kAPIBaseURLString + "/notifications/unconfirmed", parameters: param).responseJSON { (_, res, data, _) -> Void in
                        if let arr = data as? NSArray ,dict = arr[0] as? Dictionary<String, AnyObject> , id = dict["_id"] as? String {
                            done(id)
                        } else {
                            done(nil)
                        }
                        self.updateUI()
                    }
                }
            }
            
            }, failure: nil)
    }
    
    func updateUI() {
        Util.dismissHUD()
    }
}
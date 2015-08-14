//
//  RegViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/01.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class RegViewController: BaseViewController {
    
    @IBOutlet weak var testSegment: UISegmentedControl!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var buttonView: UIView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        testSegment.hidden = true
        buttonView.hidden = true
        
        loginButton.layer.borderColor = UIColor.whiteColor().CGColor
        loginButton.layer.borderWidth = 1
        loginButton.layer.cornerRadius = 2
        
        if Defaults["openid"].string != nil {
            
            Util.showHUD()
            
            OpenidController.instance.wxCheckAuth(
                
                success: { (res) -> () in
                    let tab = Util.createViewControllerWithIdentifier(nil, storyboardName: "Tab")
                    Util.changeRootViewController(from: self, to: tab)
                },
                failure: { (errCode, errMessage) -> () in
                    
                    self.buttonView.hidden = false
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.buttonView.alpha = 1
                    })
            })
            
        } else {
            buttonView.hidden = false
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    @IBAction func login_wechat(sender: AnyObject) {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.buttonView.alpha = 0
        }) { (_) -> Void in
            self.buttonView.hidden = true
        }
        
        OpenidController.instance.wxCheckAuth(
            success: { (result) -> () in
                self.changeRootToTab()
            },
            failure: { (errCode, errMessage) -> () in
                
                println(errCode)
                println(errMessage)
            })
    }
    
    private func changeRootToTab(){
        Util.dismissHUD()
        let tab = Util.createViewControllerWithIdentifier(nil, storyboardName: "Tab")
        Util.changeRootViewController(from: self, to: tab)
    }

}

// MARK: - TestUser Login

extension RegViewController {
    
    @IBAction func testLogin(sender: UISegmentedControl) {
        
        var param = Dictionary<String, String>()
        
        switch testSegment.selectedSegmentIndex
        {
        case 0:
            param["id"] = "55a319577b6eb5a66e91edaa"
        case 1:
            param["id"] = "55a31bc959a1af7373c1d099"
        case 2:
            param["id"] = "55a31c7759a1af7373c1d09e"
        case 3:
            param["id"] = "55a31d0a59a1af7373c1d0a3"
        case 4:
            param["id"] = "55a31dcb59a1af7373c1d0a8"
        case 5:
            param["id"] = "55c86fd3a96768e7609cdf25"
        case 6:
            param["id"] = "55c870e3a96768e7609cdf2a"
        default:
            break;
        }
        
        let tomo_test_login = kAPIBaseURLString + "/mobile/user/testLogin"
        
        Manager.sharedInstance.request(.GET, tomo_test_login, parameters: param, encoding: ParameterEncoding.URL)
            .responseJSON { (_, res, JSON, _) in
                
                let result = JSON as! Dictionary<String, AnyObject>
                
                if let id = result["id"] as? String,
                    nickName = result["nickName"] as? String{
                        me.id = id
                        me.nickName = nickName
                        
                        me.tomoid = result["tomoid"] as? String
                        me.gender = result["gender"] as? String
                        me.photo = result["photo_ref"] as? String
                        me.cover = result["cover_ref"] as? String
                        me.bio = result["bioText"] as? String
                        me.firstName = result["firstName"] as? String
                        me.lastName = result["lastName"] as? String
                        
                        if let dateString = result["birthDay"] as? String {
                            me.birthDay = dateString.toDate(format: "yyyy-MM-dd't'HH:mm:ss.SSSZ")
                        }
                        
                        me.friends = result["friends"] as? [String]
                        me.invited = result["invited"] as? [String]
                        
                        me.telNo = result["telNo"] as? String
                        me.address = result["address"] as? String
                        
                        var invitations = [NotificationEntity]()
                        
                        if let friendInvitations = result["friendInvitations"] as? Array<AnyObject> {
                            
                            for obj in friendInvitations {
                                
                                if let invitationRaw = obj as? Dictionary<String, AnyObject> {
                                    
                                    let notification = NotificationEntity()
                                    notification.id = invitationRaw["_id"] as? String
                                    
                                    if let dateString = result["createDate"] as? String {
                                        notification.createDate = dateString.toDate(format: "yyyy-MM-dd't'HH:mm:ss.SSSZ")
                                    }
                                    
                                    if let fromRaw = invitationRaw["_from"] as? Dictionary<String, String> {
                                        
                                        let from = UserEntity()
                                        from.id = fromRaw["_id"]
                                        from.photo = fromRaw["photo_ref"]
                                        from.nickName = fromRaw["nickName"]
                                        
                                        notification.from = from
                                    }
                                    
                                    invitations.push(notification)
                                }
                            }
                        }
                        
                        me.friendInvitations = invitations
                        
                        var messages = [MessageEntity]()
                        
                        if let newMessages = result["newMessages"] as? Array<AnyObject> {
                            
                            for obj in newMessages {
                                
                                if let messageRaw = obj as? Dictionary<String, String> {
                                    
                                    let message = MessageEntity()
                                    message.id = messageRaw["_id"]
                                    message.createDate = messageRaw["createDate"]?.toDate(format: "yyyy-MM-dd't'HH:mm:ss.SSSZ")
                                    
                                    let from = UserEntity()
                                    from.id = messageRaw["_from"]
                                    
                                    message.from = from
                                    
                                    messages.push(message)
                                }
                            }
                        }
                        
                        me.newMessages = messages
                }
                
                self.changeRootToTab()
        }
        
    }
}

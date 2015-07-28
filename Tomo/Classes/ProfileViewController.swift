//
//  ProfileViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ProfileViewController: ProfileBaseController {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthDayLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var addFriendCell: UITableViewCell!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if DBController.isFriend(user) {
            statusLabel.text = "发送消息"
        } else if DBController.isInvitedUser(user) {
            statusLabel.text = "已发送交友请求"
            self.addFriendCell.userInteractionEnabled = false
        } else if user.id == Defaults["myId"].string {
            addFriendCell.hidden = true
        } else {
            statusLabel.text = "添加好友"
        }
        
        ApiController.getUserInfo(user.id!, done: { (error) -> Void in
            if error == nil {
                self.updateUI()
            }
        })
        
    }
    
    func updateUI() {
    
        fullNameLabel.text = user?.fullName()
        
        genderLabel.text = user?.genderText()
        
//        birthDayLabel.text = user?.birthDay.
        
        addressLabel.text = user?.address

    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if cell == addFriendCell {
            
            if DBController.isFriend(user) {
                
                let vc = MessageViewController()
                vc.hidesBottomBarWhenPushed = true
                
                vc.friend = user
                
                navigationController?.pushViewController(vc, animated: true)
                return
            }
            
            if DBController.isInvitedUser(user) {
                return
            }
            
            if user.id == Defaults["myId"].string {
                return
            }
            
            statusLabel.text = "处理中..."
            ApiController.invite(user.id!, done: { (error) -> Void in
                if error == nil {
                    self.statusLabel.text = "已发送交友请求"
                    self.addFriendCell.shake({ () -> Void in
                        self.addFriendCell.userInteractionEnabled = false
                    })
                    Util.showSuccess("已发送交友请求")
                }
            })
            
            
        }
    }

}

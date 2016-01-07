//
//  MyAccountViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class MyAccountViewController: MyAccountBaseController {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthDayLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var notificationCell: UITableViewCell!
    var user: UserEntity!
    var notificationCellAccessoryView: UIView?
    let badgeView: UILabel! = {
        let label = UILabel(frame: CGRectMake(0, 0, 20, 20))
        label.backgroundColor = UIColor.redColor()
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(12)
        label.textAlignment = .Center
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerForNotifications()
        self.notificationCellAccessoryView = notificationCell.accessoryView
        
//        badgeLabel.layer.cornerRadius = badgeLabel.frame.size.height / 2
        Util.changeImageColorForButton(editButton,color: UIColor.whiteColor())

        self.updateUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if me.notifications > 0 {
            badgeView.text = String(me.notifications)
            notificationCell.accessoryView = badgeView
        } else {
            notificationCell.accessoryView = self.notificationCellAccessoryView
        }
    }

    @IBAction func logoutTapped(sender: UIButton) {
        Util.alert(self, title: "退出账号", message: "真的要退出当前的账号吗？") { _ in
            
            Router.Signout().response { _ in
                Defaults.remove("openid")
                Defaults.remove("deviceToken")
                
                Defaults.remove("email")
                Defaults.remove("password")
                
                me = UserEntity()
                let main = Util.createViewControllerWithIdentifier(nil, storyboardName: "Main")
                Util.changeRootViewController(from: self, to: main)
            }
            
        }
    }

    // MARK: - Navigation

    @IBAction func profileDidFinishEdit(segue: UIStoryboardSegue) {
        self.updateUI()
    }
}

extension MyAccountViewController {
    
    private func updateUI() {
        user = me
        
        if nil != user.firstName && nil != user.lastName {
            fullNameLabel.text = user.fullName()
        }
        
        if let gender = user.gender {
            genderLabel.text = gender
        }
        
        if let birthDay = user.birthDay {
            birthDayLabel.text = birthDay.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle)
        }
        
        if let address = user.address {
            addressLabel.text = address
        }
        
    }
}

// MARK: NSNotificationCenter

extension MyAccountViewController {
    
    private func registerForNotifications() {
        ListenerEvent.Any.addObserver(self, selector: Selector("receiveAny:"))
    }
    
    func receiveAny(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        let remoteNotification = NotificationEntity(userInfo)
        
        if let type = ListenerEvent(rawValue: remoteNotification.type) {
            if type == .FriendInvited || type == .Message { //receive it by friendlistviewcontroller
                return
            }
        }
        if me.notifications > 0 {
            gcd.sync(.Main) {
                self.badgeView.text = String(me.notifications)
                self.notificationCell.accessoryView = self.badgeView
            }
        }
    }
}


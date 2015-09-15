//
//  SettingViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class SettingViewController: MyAccountBaseController {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthDayLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var notificationCell: UITableViewCell!
    var user: UserEntity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        badgeLabel.layer.cornerRadius = badgeLabel.frame.size.height / 2
        Util.changeImageColorForButton(editButton,color: UIColor.whiteColor())
        
        self.updateUI()
    }

    @IBAction func logoutTapped(sender: UIButton) {
        Util.alert(self, title: "退出账号", message: "真的要退出当前的账号吗？", action: { (_) -> Void in
            
            AlamofireController.request(.GET, "/signout")
            
            Defaults.remove("openid")
            Defaults.remove("deviceToken")
            
            Defaults.remove("email")
            Defaults.remove("password")
            
            me = UserEntity()
            let main = Util.createViewControllerWithIdentifier(nil, storyboardName: "Main")
            Util.changeRootViewController(from: self, to: main)
        })
    }

    // MARK: - Navigation

    @IBAction func profileDidFinishEdit(segue: UIStoryboardSegue) {
        self.updateUI()
    }
}

extension SettingViewController {
    
    private func updateUI() {
        user = me
        
        if let firstName = user.firstName, lastName = user.lastName {
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


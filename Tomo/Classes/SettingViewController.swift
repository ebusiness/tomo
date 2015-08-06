//
//  SettingViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class SettingViewController: MyAccountBaseController {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthDayLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var logoutCell: UITableViewCell!
    
    var user: UserEntity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Util.changeImageColorForButton(editButton,color: UIColor.whiteColor())        
        
        self.updateUI()
    }
    
    func updateUI() {
        user = me
        
        fullNameLabel.text = user?.fullName()
        genderLabel.text = user?.gender
        birthDayLabel.text = user?.birthDay?.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle)
        addressLabel.text = user?.address

    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if cell == logoutCell {
            
            Util.alert(self, title: "退出账号", message: "真的要退出当前的账号吗？", action: { (_) -> Void in
                DBController.clearDBForLogout()
                
                Defaults.remove("openid")
                me = UserEntity()
                let main = Util.createViewControllerWithIdentifier(nil, storyboardName: "Main")
                Util.changeRootViewController(from: self, to: main)
            })
            
        }
    }

    // MARK: - Navigation

    @IBAction func profileDidFinishEdit(segue: UIStoryboardSegue) {
        self.updateUI()
    }

}

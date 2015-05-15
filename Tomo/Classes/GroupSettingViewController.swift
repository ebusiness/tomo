//
//  GroupSettingViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/05/15.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class GroupSettingViewController: BaseTableViewController {

    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var stickySwitch: UISwitch!
    
    var group: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        notificationSwitch.setOn(group.shouldNotification, animated: false)
        stickySwitch.setOn(group.isSticky?.boolValue ?? false, animated: false)
    }

    @IBAction func switchValueChanged(sender: UISwitch) {
        ApiController.announceGroup(group.id!, onoff: sender.on ? "1" : "0") { (error) -> Void in
            
        }
    }
    
    @IBAction func leaveGroupBtnTapped(sender: AnyObject) {
        ApiController.leaveGroup(group.id!, done: { (error) -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        })
    }
    
    @IBAction func stickySwitchValueChanged(sender: UISwitch) {
        ApiController.stickyGroup(group.id!, onoff: sender.on ? "1" : "0", done: { (error) -> Void in
        })
    }
}

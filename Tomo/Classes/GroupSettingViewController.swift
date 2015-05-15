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
    
    var group: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
}

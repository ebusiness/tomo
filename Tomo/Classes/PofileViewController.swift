//
//  PofileViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class PofileViewController: ProfileBaseController {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthDayLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var logoutCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        
        if cell == logoutCell {
            
            let alertController = UIAlertController(title: "退出账号", message: "真的要退出当前的账号吗？", preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            let logoutAction = UIAlertAction(title: "退出", style: .Destructive, handler: {(_) -> () in
                DBController.clearDBForLogout();
                let main = Util.createViewControllerWithIdentifier(nil, storyboardName: "Main")
                Util.changeRootViewController(from: self, to: main)
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(logoutAction)
            
            presentViewController(alertController, animated: true, completion: nil)
            
        }
    }

}

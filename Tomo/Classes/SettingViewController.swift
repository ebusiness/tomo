//
//  SettingViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/05/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class SettingViewController: BaseTableViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var badgeBackView: UIView!
    
    @IBOutlet weak var announcementsCell: UITableViewCell!
    @IBOutlet weak var myPostsCell: UITableViewCell!
    @IBOutlet weak var logoutCell: UITableViewCell!
    
    var badgeView: JSBadgeView!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userImage.layer.cornerRadius = userImage.bounds.width / 2
        
        badgeView = JSBadgeView(parentView: badgeBackView, alignment: .Center)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()

        ApiController.getMyInfo({ (error) -> Void in
            if error == nil {
                self.updateUI()
            }
        })
    }
    
    func updateUI() {
        user = DBController.myUser()

        nameLabel.text = user?.fullName()

        if let url = user?.photo_ref {
            userImage.sd_setImageWithURL(NSURL(string: url), placeholderImage: DefaultAvatarImage)
        }

        if let id = user?.tomoid {
            idLabel.text = "ID: " + id
        }
        
        let count = DBController.unreadAnnouncementsCount()
        
        if count > 0 {
            badgeView.badgeText = String(count)
            badgeView.hidden = false
        } else {
            badgeView.hidden = true
        }
        
        (self.navigationController?.tabBarController as? TabBarController)?.updateBadgeNumber()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if cell == myPostsCell {
            let vc = Util.createViewControllerWithIdentifier("NewsfeedViewController", storyboardName: "Newsfeed") as! NewsfeedViewController
            vc.user = user
            vc.displayMode = .Account

            navigationController?.pushViewController(vc, animated: true)
        }
        
        if cell == logoutCell {
            let acvc = Util.createViewControllerWithIdentifier("AlertConfirmView", storyboardName: "ActionSheet") as! AlertConfirmViewController
            
            acvc.show(self, content: "ログアウトしますか？", action: { () -> () in
                DBController.clearDBForLogout();
                
                let main = Util.createViewControllerWithIdentifier(nil, storyboardName: "Main")
                
                Util.changeRootViewController(from: self, to: main)
            })
        }
    }
}

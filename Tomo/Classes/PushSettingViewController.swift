//
//  PushSettingViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/10/13.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class PushSettingViewController: MyAccountBaseController {
    
    @IBOutlet weak var pushSwitch: UISwitch!
    
    /// Switch
    @IBOutlet weak var switchAnnouncement: UISwitch!
    @IBOutlet weak var switchMessage: UISwitch!
    @IBOutlet weak var switchGroupMessage: UISwitch!
    @IBOutlet weak var switchFriendInvited: UISwitch!
    @IBOutlet weak var switchFriendAccepted: UISwitch!
    @IBOutlet weak var switchFriendRefused: UISwitch!
    @IBOutlet weak var switchFriendBreak: UISwitch!
    @IBOutlet weak var switchPostNew: UISwitch!
    @IBOutlet weak var switchPostCommented: UISwitch!
    @IBOutlet weak var switchPostLiked: UISwitch!
    @IBOutlet weak var switchPostBookmarked: UISwitch!
    @IBOutlet weak var switchGroupJoined: UISwitch!
    
    /// push setting
    var allowNotification = false {
        didSet {
            if oldValue != allowNotification {
                self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
                self.scrollViewDidScroll(self.tableView)
                if Defaults["deviceToken"].string == nil && allowNotification {
                    Util.setupPush()
                }
            }
        }
    }
    
    var pushSettingProperty: UserEntity.PushSetting! {
        didSet {
            if oldValue != pushSettingProperty {
                switchAnnouncement.on = pushSettingProperty.announcement
                switchMessage.on = pushSettingProperty.message
                switchGroupMessage.on = pushSettingProperty.groupMessage
                switchFriendInvited.on = pushSettingProperty.friendInvited
                switchFriendAccepted.on = pushSettingProperty.friendAccepted
                switchFriendRefused.on = pushSettingProperty.friendRefused
                switchFriendBreak.on = pushSettingProperty.friendBreak
                switchPostNew.on = pushSettingProperty.postNew
                switchPostCommented.on = pushSettingProperty.postCommented
                switchPostLiked.on = pushSettingProperty.postLiked
                switchPostBookmarked.on = pushSettingProperty.postBookmarked
                switchGroupJoined.on = pushSettingProperty.groupJoined
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pushSettingProperty = me.pushSetting
        self.becomeActive()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        var params = Dictionary<String,AnyObject>()
        params["announcement"] = switchAnnouncement.on
        params["message"] = switchMessage.on
        params["groupMessage"] = switchGroupMessage.on
        params["friendInvited"] = switchFriendInvited.on
        params["friendAccepted"] = switchFriendAccepted.on
        params["friendRefused"] = switchFriendRefused.on
        params["friendBreak"] = switchFriendBreak.on
        params["postNew"] = switchPostNew.on
        params["postCommented"] = switchPostCommented.on
        params["postLiked"] = switchPostLiked.on
        params["postBookmarked"] = switchPostBookmarked.on
        params["groupJoined"] = switchGroupJoined.on
        
        var parameters: Dictionary<String,AnyObject> = ["pushSetting": params]
        if !allowNotification {
            parameters["removeDevice"] = true
            Defaults.remove("deviceToken")
        }
        
        AlamofireController.request(.PATCH, "/me", parameters: parameters, hideHUD: true, success: { result in
            me.pushSetting = UserEntity.PushSetting(JSON(result)["pushSetting"])
        }) { err in
        }
        
    }
    
    @IBAction func openSystemSettings(sender: UISwitch) {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }
    
}

extension PushSettingViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && !allowNotification {
            return 0
        } else {
            return super.tableView(self.tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 && !allowNotification {
            return nil
        } else {
            return super.tableView(self.tableView, titleForHeaderInSection: section)
        }
    }
}


extension PushSettingViewController {
    
    override func becomeActive() {
        super.becomeActive()
        let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        allowNotification = settings.types != UIUserNotificationType.None
        
        pushSwitch.setOn(allowNotification, animated: false)
    }
    
}
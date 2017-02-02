//
//  PushSettingViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/10/13.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation
import SwiftyJSON

final class PushSettingViewController: UITableViewController {

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
    @IBOutlet weak var switchGroupLeft: UISwitch!

    let pushSettingSection = 0
    let messageSection = 1
    let friendSection = 2
    let postSection = 3
    let groupSection = 4

    /// push setting
    var allowNotification = false {
        didSet {
            if oldValue != allowNotification {
                self.tableView.beginUpdates()
                self.tableView.reloadSections([messageSection], with: .automatic)
                self.tableView.reloadSections([friendSection], with: .automatic)
                self.tableView.reloadSections([postSection], with: .automatic)
                self.tableView.reloadSections([groupSection], with: .automatic)
                self.tableView.endUpdates()
//                self.scrollViewDidScroll(self.tableView)
                if UserDefaults.standard.string(forKey: "deviceToken") == nil && allowNotification {
                    Util.setupPush()
                }
            }
        }
    }

    var pushSettingProperty: Account.PushSetting! {
        didSet {
            if oldValue != pushSettingProperty {
                switchAnnouncement.isOn = pushSettingProperty.announcement
                switchMessage.isOn = pushSettingProperty.message
                switchGroupMessage.isOn = pushSettingProperty.groupMessage
                switchFriendInvited.isOn = pushSettingProperty.friendInvited
                switchFriendAccepted.isOn = pushSettingProperty.friendAccepted
                switchFriendRefused.isOn = pushSettingProperty.friendRefused
                switchFriendBreak.isOn = pushSettingProperty.friendBreak
                switchPostNew.isOn = pushSettingProperty.postNew
                switchPostCommented.isOn = pushSettingProperty.postCommented
                switchPostLiked.isOn = pushSettingProperty.postLiked
                switchPostBookmarked.isOn = pushSettingProperty.postBookmarked
                switchGroupJoined.isOn = pushSettingProperty.groupJoined
                switchGroupLeft.isOn = pushSettingProperty.groupLeft
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        pushSettingProperty = me.pushSetting
        self.becomeActive()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        let pushSetting = Account.PushSetting()

        pushSetting.announcement = switchAnnouncement.isOn
        pushSetting.message = switchMessage.isOn
        pushSetting.groupMessage = switchGroupMessage.isOn
        pushSetting.friendInvited = switchFriendInvited.isOn
        pushSetting.friendAccepted = switchFriendAccepted.isOn
        pushSetting.friendRefused = switchFriendRefused.isOn
        pushSetting.friendBreak = switchFriendBreak.isOn
        pushSetting.postNew = switchPostNew.isOn
        pushSetting.postCommented = switchPostCommented.isOn
        pushSetting.postLiked = switchPostLiked.isOn
        pushSetting.postBookmarked = switchPostBookmarked.isOn
        pushSetting.groupJoined = switchGroupJoined.isOn
        pushSetting.groupLeft = switchGroupLeft.isOn

        var parameters = Router.Setting.MeParameter()

        if me.pushSetting != pushSetting {
            parameters.pushSetting = pushSetting
        }

        if !allowNotification {
            parameters.removeDevice = "1"
            UserDefaults.standard.removeObject(forKey: "deviceToken")
        }

        guard parameters.getParameters() != nil else { return }

        Router.Setting.UpdateUserInfo(parameters: parameters).response {
            if $0.result.isFailure { return }
            me.pushSetting = Account.PushSetting($0.result.value!["pushSetting"])
        }

    }

    @IBAction func openSystemSettings(_ sender: UISwitch) {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(url!)
    }

}

extension PushSettingViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section != pushSettingSection && !allowNotification {
            return 0
        }

        return super.tableView(self.tableView, numberOfRowsInSection: section)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section != pushSettingSection && !allowNotification {
            return nil
        }

        return super.tableView(self.tableView, titleForHeaderInSection: section)
    }
}

extension PushSettingViewController {

    func becomeActive() {

        let settings = UIApplication.shared.currentUserNotificationSettings!
        allowNotification = settings.types != .none

        pushSwitch.setOn(allowNotification, animated: false)
    }

}

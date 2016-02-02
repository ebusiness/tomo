//
//  ContactsNavigationController.swift
//  Tomo
//
//  Created by ebuser on 2016/02/01.
//  Copyright © 2016年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ContactsNavigationController: UINavigationController {

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)

        // attach event observer when init, so they start to work as TabController initiated. do this in viewDidLoad will be too late.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTabBarItemBadge", name: "didRefuseInvitation", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTabBarItemBadge", name: "didAcceptInvitation", object: me)

        // this event is emit from notificaton center, must switch to main thread to make visual effect (update badge)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTabBarItemBadgeOnMainThread", name: "didReceiveFriendInvitation", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTabBarItemBadgeOnMainThread", name: "didReceiveMessage", object: me)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func updateTabBarItemBadge() {

        self.tabBarItem.badgeValue = self.calculateBadge()
    }

    func updateTabBarItemBadgeOnMainThread() {

        gcd.sync(.Main) {
            self.tabBarItem.badgeValue = self.calculateBadge()
        }
    }

    private func calculateBadge() -> String?{

        if me.newMessages.count + me.friendInvitations.count > 0 {
            return String(me.newMessages.count + me.friendInvitations.count)
        } else {
            return nil
        }
    }
}

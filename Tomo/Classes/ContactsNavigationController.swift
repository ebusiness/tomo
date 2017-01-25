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
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsNavigationController.updateTabBarItemBadge), name: NSNotification.Name(rawValue: "didRefuseInvitation"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsNavigationController.updateTabBarItemBadge), name: NSNotification.Name(rawValue: "didAcceptInvitation"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsNavigationController.updateTabBarItemBadge), name: NSNotification.Name(rawValue: "didFinishGroupChat"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsNavigationController.updateTabBarItemBadge), name: NSNotification.Name(rawValue: "didFinishChat"), object: me)

        // this event is emit from notificaton center, must switch to main thread to make visual effect (update badge)
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsNavigationController.updateTabBarItemBadgeOnMainThread), name: NSNotification.Name(rawValue: "didReceiveFriendInvitation"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsNavigationController.updateTabBarItemBadgeOnMainThread), name: NSNotification.Name(rawValue: "didReceiveMessage"), object: me)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func updateTabBarItemBadge() {

        self.tabBarItem.badgeValue = self.calculateBadge()
    }

    func updateTabBarItemBadgeOnMainThread() {

        gcd.sync(.main) {
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

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

        let notificationCenter = NotificationCenter.default

        let selector = #selector(ContactsNavigationController.updateTabBarItemBadge)
        let selectorOnMainThread = #selector(ContactsNavigationController.updateTabBarItemBadgeOnMainThread)

        // attach event observer when init, so they start to work as TabController initiated. do this in viewDidLoad will be too late.
        notificationCenter.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: "didRefuseInvitation"), object: me)
        notificationCenter.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: "didAcceptInvitation"), object: me)
        notificationCenter.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: "didFinishGroupChat"), object: me)
        notificationCenter.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: "didFinishChat"), object: me)

        // this event is emit from notificaton center, must switch to main thread to make visual effect (update badge)
        let didReceiveFriendInvitation = NSNotification.Name(rawValue: "didReceiveFriendInvitation")
        let didReceiveMessage = NSNotification.Name(rawValue: "didReceiveMessage")

        notificationCenter.addObserver(self, selector: selectorOnMainThread, name: didReceiveFriendInvitation, object: me)
        notificationCenter.addObserver(self, selector: selectorOnMainThread, name: didReceiveMessage, object: me)
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

        if me.newMessages.isEmpty && me.friendInvitations.isEmpty {
            return nil
        } else {
            return String(me.newMessages.count + me.friendInvitations.count)
        }
    }
}

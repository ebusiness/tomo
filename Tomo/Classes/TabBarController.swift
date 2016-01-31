//
//  TabBarController.swift
//  spot
//
//  Created by 張志華 on 2015/02/04.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

enum TabItem: Int {

    case Home

    case Contacts

    case Chat

    case Group

    case Setting

    var viewController: UIViewController {

        let storyBoardName: String
        let barButtonImage: UIImage
        let barButtonBadge: String?
        let barButtonTitle: String

        switch self {

        case .Home:
            storyBoardName = "Home"
            barButtonImage = UIImage(named: "home")!
            barButtonBadge = nil
            barButtonTitle = "动态"

        case .Contacts:
            storyBoardName = "Contacts"
            barButtonImage = UIImage(named: "address_book")!
            barButtonTitle = "通讯录"

            if me.friendInvitations.count > 0 {
                barButtonBadge = String(me.friendInvitations.count)
            } else {
                barButtonBadge = nil
            }

        case .Chat:
            storyBoardName = "Chat"
            barButtonImage = UIImage(named: "speech_bubble")!
            barButtonTitle = "聊天"

            if me.newMessages.count > 0 {
                barButtonBadge = String(me.newMessages.count)
            } else {
                barButtonBadge = nil
            }

        case .Group:
            storyBoardName = "Group"
            barButtonImage = UIImage(named: "group")!
            barButtonBadge = nil
            barButtonTitle = "群组"

        case .Setting:
            storyBoardName = "Setting"
            barButtonImage = UIImage(named: "user_male_circle")!
            barButtonTitle = "群组"

            if me.notifications > 0 {
                barButtonBadge = String(me.notifications)
            } else {
                barButtonBadge = nil
            }
        }

        let viewController = UIStoryboard(name: storyBoardName, bundle: nil).instantiateInitialViewController()!
        viewController.tabBarItem = UITabBarItem(title: barButtonTitle, image: barButtonImage, selectedImage: barButtonImage)
        viewController.tabBarItem.badgeValue = barButtonBadge

        return viewController
    }
}

final class TabBarController: UITabBarController {

    var notificationBar: NotificationView!
    var topConstraint: NSLayoutConstraint!

    override func viewDidLoad() {

        super.viewDidLoad()

        self.viewControllers = [
            TabItem.Home.viewController,
            TabItem.Contacts.viewController,
            TabItem.Chat.viewController,
            TabItem.Group.viewController,
            TabItem.Setting.viewController
        ]

        self.initiateNotificationBar()

        self.registerForNotification()

        SocketController.connect()

        Util.setupPush()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        URLSchemesController.sharedInstance.runTask()
        RemoteNotification.sharedInstance.runTask()
    }

    deinit {
        SocketController.disconnect()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: - Internal methods

extension TabBarController {

    private func initiateNotificationBar() {

        self.notificationBar = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil)[0] as! NotificationView
        self.notificationBar.delegate = self

        self.view.addSubview(self.notificationBar)

        let leadingConstraint = NSLayoutConstraint(item: self.notificationBar,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: .Leading,
            multiplier: 1,
            constant: 0)

        let trailingConstraint = NSLayoutConstraint(item: self.notificationBar,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: .Trailing,
            multiplier: 1,
            constant: 0)

        self.topConstraint = NSLayoutConstraint(item: self.notificationBar,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: .Top,
            multiplier: 1,
            constant: -64)

        let heightContraint = NSLayoutConstraint(item: self.notificationBar,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1,
            constant: 64)

        self.view.addConstraints([leadingConstraint, trailingConstraint, topConstraint])
        self.notificationBar.translatesAutoresizingMaskIntoConstraints = false
        self.notificationBar.addConstraint(heightContraint)
    }

    private func registerForNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveFriendInvitation:", name: ListenerEvent.FriendInvited.rawValue, object: nil)
    }

    private func openToggleNotificationBar() {
        gcd.sync(.Main) {
            self.topConstraint.constant = 0
            UIView.animateWithDuration(TomoConst.Duration.Short, animations: {
                self.view.layoutIfNeeded()
            }, completion: { finished in
                gcd.async(.Default, delay: TomoConst.Timeout.Mini) {
                    self.closeNotificationBar()
                }
            })
        }
    }

    func closeNotificationBar() {
        gcd.sync(.Main) {
            self.topConstraint.constant = -64
            UIView.animateWithDuration(TomoConst.Duration.Short){
                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - Notification Handler

extension TabBarController {

    func didReceiveFriendInvitation(notification: NSNotification) {
        self.notificationBar.notification = NotificationEntity(notification.userInfo!)
        self.openToggleNotificationBar()
    }
}
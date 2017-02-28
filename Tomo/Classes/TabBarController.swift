//
//  TabBarController.swift
//  Tomo
//
//  Created by 張志華 on 2015/02/04.
//  Copyright © 2015 e-business. All rights reserved.
//

import UIKit

enum TabItem: Int {

    case Home

    case Chat

    case Group

    case Map

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

        case .Chat:
            storyBoardName = "Chat"
            barButtonImage = UIImage(named: "speech_bubble")!
            barButtonTitle = "聊天"

            if !me.newMessages.isEmpty && !me.friendInvitations.isEmpty {
                barButtonBadge = String(me.newMessages.count + me.friendInvitations.count)
            } else {
                barButtonBadge = nil
            }

        case .Group:
            storyBoardName = "Group"
            barButtonImage = UIImage(named: "group")!
            barButtonBadge = nil
            barButtonTitle = "群组"

        case .Map:
            storyBoardName = "Map"
            barButtonImage = UIImage(named: "globe")!
            barButtonBadge = nil
            barButtonTitle = "地图"

        case .Setting:
            storyBoardName = "Setting"
            barButtonImage = UIImage(named: "user_male_circle")!
            barButtonTitle = "我"

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
            TabItem.Chat.viewController,
            TabItem.Group.viewController,
            TabItem.Map.viewController,
            TabItem.Setting.viewController
        ]

        self.initiateNotificationBar()

        self.registerForNotification()

        SocketController.connect()

        Util.setupPush()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        URLSchemesController.sharedInstance.runTask()
        RemoteNotification.sharedInstance.runTask()
    }

    deinit {
        SocketController.disconnect()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Internal methods

extension TabBarController {

    fileprivate func initiateNotificationBar() {

        self.notificationBar = Bundle.main.loadNibNamed("NotificationView", owner: nil, options: nil)?.first as? NotificationView
        self.notificationBar.delegate = self

        self.view.addSubview(self.notificationBar)

        let leadingConstraint = NSLayoutConstraint(item: self.notificationBar,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self.view,
            attribute: .leading,
            multiplier: 1,
            constant: 0)

        let trailingConstraint = NSLayoutConstraint(item: self.notificationBar,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self.view,
            attribute: .trailing,
            multiplier: 1,
            constant: 0)

        self.topConstraint = NSLayoutConstraint(item: self.notificationBar,
            attribute: .top,
            relatedBy: .equal,
            toItem: self.view,
            attribute: .top,
            multiplier: 1,
            constant: -64)

        let heightContraint = NSLayoutConstraint(item: self.notificationBar,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 64)

        self.view.addConstraints([leadingConstraint, trailingConstraint, topConstraint])
        self.notificationBar.translatesAutoresizingMaskIntoConstraints = false
        self.notificationBar.addConstraint(heightContraint)
    }

    fileprivate func registerForNotification() {

        NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.didReceiveNotification(_:)), name: ListenerEvent.FriendInvited.notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.didReceiveNotification(_:)), name: ListenerEvent.FriendAccepted.notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.didReceiveNotification(_:)), name: ListenerEvent.FriendRefused.notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.didReceiveNotification(_:)), name: ListenerEvent.FriendBreak.notificationName, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.didReceiveNotification(_:)), name: ListenerEvent.PostNew.notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.didReceiveNotification(_:)), name: ListenerEvent.PostLiked.notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.didReceiveNotification(_:)), name: ListenerEvent.PostCommented.notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.didReceiveNotification(_:)), name: ListenerEvent.PostBookmarked.notificationName, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.didReceiveNotification(_:)), name: ListenerEvent.GroupJoined.notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.didReceiveNotification(_:)), name: ListenerEvent.GroupLeft.notificationName, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.didReceiveMessage(_:)), name: ListenerEvent.Message.notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.didReceiveGroupMessage(_:)), name: ListenerEvent.GroupMessage.notificationName, object: nil)
    }

    fileprivate func openNotificationBar() {

        self.view.bringSubview(toFront: self.notificationBar)
        self.topConstraint.constant = 0
        UIView.animate(withDuration: TomoConst.Duration.Short, animations: {
            self.view.layoutIfNeeded()
            }, completion: { finished in
                gcd.async(.default, delay: TomoConst.Timeout.Mini) {
                    self.closeNotificationBar()
                }
        })
    }

    func closeNotificationBar() {
        gcd.sync(.main) {
            self.topConstraint.constant = -64
            UIView.animate(withDuration: TomoConst.Duration.Short) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - Notification Handler

extension TabBarController {

    func didReceiveNotification(_ notification: NSNotification) {

        gcd.sync(.main) {
            self.notificationBar.notification = NotificationEntity(notification.userInfo!)
            self.openNotificationBar()
        }
    }

    func didReceiveMessage(_ notification: NSNotification) {

        gcd.sync(.main) {
            self.notificationBar.notification = NotificationEntity(notification.userInfo!)

            // if received normal message in chat view controller, don't show notification bar
            let topViewController = self.selectedViewController?.childViewControllers.last
            if topViewController is ChatViewController {
                return
            }

            self.openNotificationBar()
        }
    }

    func didReceiveGroupMessage(_ notification: NSNotification) {

        gcd.sync(.main) {
            self.notificationBar.notification = NotificationEntity(notification.userInfo!)

            // if received group message in group chat view controller, don't show notification bar
            let topViewController = self.selectedViewController?.childViewControllers.last
            if topViewController is ChatViewController {
                return
            }

            self.openNotificationBar()
        }
    }
}

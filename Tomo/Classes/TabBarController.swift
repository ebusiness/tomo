//
//  TabBarController.swift
//  Tomo
//
//  Created by 張志華 on 2015/02/04.
//  Copyright © 2015 e-business. All rights reserved.
//

import UIKit

final class TabBarController: UITabBarController {

    @IBOutlet fileprivate var notificationBar: NotificationView!
    var topConstraint: NSLayoutConstraint!

    override func viewDidLoad() {

        super.viewDidLoad()

        self.initiateNotificationBar()

        self.registerForNotification()

        SocketController.connect()

        Util.setupPush()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        URLSchemesController.shared.runTask()
        RemoteNotification.shared.runTask()
    }

    deinit {
        SocketController.disconnect()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Internal methods

extension TabBarController {

    fileprivate func initiateNotificationBar() {

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
            }, completion: { _ in
                DispatchQueue.default.async(delay: TomoConst.Timeout.Mini) {
                    self.closeNotificationBar()
                }
        })
    }

    func closeNotificationBar() {
        DispatchQueue.main.sync {
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

        DispatchQueue.main.sync {
            self.notificationBar.notification = NotificationEntity(notification.userInfo!)
            self.openNotificationBar()
        }
    }

    func didReceiveMessage(_ notification: NSNotification) {

        DispatchQueue.main.sync {
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

        DispatchQueue.main.sync {
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

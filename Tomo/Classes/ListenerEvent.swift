//
//  ListenerEvent.swift
//  Tomo
//
//  Created by starboychina on 2015/09/07.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

private var observers = [String:AnyObject]()

enum ListenerEvent: String {

    case Announcement   = "new-announcement"
    
    case Message        = "message-new"

    case GroupMessage   = "message-group"
    
    case FriendAccepted = "friend-accepted"

    case FriendRefused  = "friend-refused"

    case FriendInvited  = "friend-invited"

    case FriendBreak    = "friend-break"
    
    case PostNew        = "post-new"

    case PostLiked      = "post-liked"

    case PostCommented  = "post-commented"

    case PostBookmarked = "post-bookmarked"
    
    case GroupJoined    = "group-joined"

    case GroupLeft      = "group-left"
    
    case Any = "any"

    func relayToNoticationCenter(userInfo: [NSObject : AnyObject]) {
        NSNotificationCenter.defaultCenter().postNotificationName(self.rawValue, object: nil, userInfo: userInfo)
    }

    func getNotificationName() -> String {
        return "tomoNotification-" + self.rawValue
    }
//    
//    func receive(userInfo: [NSObject : AnyObject]){
//        
//        if let tabBarController = UIApplication.sharedApplication().keyWindow?.rootViewController as? TabBarController {
//            self.resolve(tabBarController, userInfo: userInfo)
//        }
//    }

    func addObserver(observer: AnyObject, selector aSelector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: aSelector, name: self.getNotificationName(), object: nil)
    }
    
    func addObserver(observer: UIViewController, usingBlock block: (NSNotification!) -> Void){
        
        if let observer: AnyObject = observers[observer.description] {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
        
        observers[observer.description] = NSNotificationCenter.defaultCenter().addObserverForName(self.getNotificationName(), object: nil, queue: nil, usingBlock: block )
        
    }
}

extension ListenerEvent {
    
//    private func resolve(tabBarController: TabBarController, userInfo: [NSObject : AnyObject]) {
//        
//        switch self {
//            
//        case .Announcement:
//            
//            break
//            
//        case .GroupMessage:
//            break
//        case .Message:
//            
//            self.receiveMessage(tabBarController, userInfo: userInfo)
//            
//        case .FriendInvited:
//            
//            self.receiveInvited(userInfo)
//            
//        case .FriendAccepted, .FriendRefused, .FriendBreak:
//            
//            self.receiveFriendRelationship(userInfo)
//            fallthrough
//            
//        case .GroupJoined:
//            
//            fallthrough
//            
//        case .PostNew, .PostLiked, .PostCommented, .PostBookmarked:
//            
//            self.receiveOtherNotification()
//            
//        default:
//            break
//        }
//        
//        let notification = NotificationEntity(userInfo)
//        self.showNotificationIfNeeded(tabBarController, notification: notification)
//        
//        self.postNotification(userInfo)
//
//    }

//    private func showNotificationIfNeeded(tabBarController: TabBarController, notification: NotificationEntity) {
//        
//        if self == .GroupMessage || self == .Message {
//            
//            let lastViewController: AnyObject? = tabBarController.selectedViewController?.childViewControllers.last
//            
//            if let messageViewController = lastViewController as? MessageViewController {
//                
//                if notification.from.id == messageViewController.friend.id {
//                    return
//                }
//            } else if let groupChatViewController = lastViewController as? GroupChatViewController {
//                
//                if notification.targetId == groupChatViewController.group.id {
//                    return
//                }
//            }
//        }
//        
//        gcd.sync(.Main) {
////            tabBarController.updateBadgeNumber()
//
//            let notificationView = self.getNotificationView()
//            notificationView.notification = notification
//            let topConstraint: AnyObject? = notificationView.superview!.constraints.find { $0.firstAttribute == .Top && $0.firstItem is NotificationView }
//            
//            if let topConstraint = topConstraint as? NSLayoutConstraint {
//                topConstraint.constant = 0
//                
//                UIView.animateWithDuration(0.2, animations: { () -> Void in
//                    if let superview = notificationView.superview {
//                        superview.layoutIfNeeded()
//                    }
//                })
//            }
//        }
//    }
//    
//    private func getNotificationView() -> NotificationView {
//        
//        let window = UIApplication.sharedApplication().keyWindow!
//        if let lastView = window.subviews.last as? NotificationView {
//            window.bringSubviewToFront(lastView)
//            return lastView
//        } else {
//            let notificationView = Util.createViewWithNibName("NotificationView") as! NotificationView
//            notificationView.translatesAutoresizingMaskIntoConstraints = false
//            let views = ["notificationView":notificationView]
//            window.addSubview(notificationView)
//            window.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[notificationView]|", options: [], metrics: nil, views: views))
//            window.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(-64)-[notificationView(==64)]", options: [], metrics: nil, views: views))
//            window.layoutIfNeeded()
//            notificationView.layoutIfNeeded()
//            
//            return notificationView
//        }
//    }
//    
//    private func postNotification(userInfo: [NSObject : AnyObject]) {
//        
//        NSNotificationCenter.defaultCenter().postNotificationName(self.getNotificationName(), object: nil, userInfo: userInfo)
//        if self != .Any {
//            NSNotificationCenter.defaultCenter().postNotificationName(ListenerEvent.Any.getNotificationName(), object: nil, userInfo: userInfo)
//        }
//    }
}

// MARK: - receive for [me]

extension ListenerEvent {

//    private func receiveMessage(tabBarController: TabBarController, userInfo: [NSObject : AnyObject]) {
//        let message = MessageEntity(userInfo)
//        
//        let lastViewController: AnyObject? = tabBarController.selectedViewController?.childViewControllers.last
//        
//        if let messageViewController = lastViewController as? MessageViewController {
//            
//            if message.from.id == messageViewController.friend.id {
//                return
//            }
//        } else if let groupChatViewController = lastViewController as? GroupChatViewController {
//            
//            if message.group == groupChatViewController.group.id {
//                return
//            }
//        }
//        
//        message.to = me
//        me.newMessages.insert(message, atIndex: 0)
//    }
//    
//    private func receiveInvited(userInfo: [NSObject : AnyObject]){
//        
//        let invitation = NotificationEntity(userInfo)
//        invitation.id = invitation.targetId
//        
//        if !me.friendInvitations.contains({ $0.from.id == invitation.from.id }) {
//            me.friendInvitations.insert(invitation, atIndex: 0)
//        }
//    }
//    
//    private func receiveFriendRelationship(userInfo: [NSObject : AnyObject]) {
//        
//        let notification = NotificationEntity(userInfo)
//        
//        if self == .FriendAccepted {
//            
//            me.addFriend(notification.from)
//            
//        } else if self == .FriendRefused {
//            
//            me.invitations?.remove(notification.from.id)
//            
//        } else if self == .FriendBreak {
//            
//        }
//    }
//    
//    private func receiveOtherNotification() {
//        
//        me.notifications = me.notifications + 1
//    }
}
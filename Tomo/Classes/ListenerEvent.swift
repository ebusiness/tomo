//
//  ListenerEvent.swift
//  Tomo
//
//  Created by starboychina on 2015/09/07.
//  Copyright © 2015 e-business. All rights reserved.
//

private var observers = [String: Any]()

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

    case any = "any"

    var notificationName: NSNotification.Name {
        return NSNotification.Name(rawValue: "tomoNotification-" + self.rawValue)
    }

    func relayToNoticationCenter(_ userInfo: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: self.notificationName, object: nil, userInfo: userInfo)
    }

    func addObserver(observer: Any, selector aSelector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: aSelector, name: self.notificationName, object: nil)
    }

    func addObserver(observer: UIViewController, usingBlock block: @escaping (NSNotification!) -> Void){

        if let observer: Any = observers[observer.description] {
            NotificationCenter.default.removeObserver(observer)
        }
//        observers[observer.description] = NotificationCenter.default.addObserver(name: self.notificationName, object: nil, queue: nil, usingBlock: block )

    }
}

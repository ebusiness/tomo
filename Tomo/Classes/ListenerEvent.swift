//
//  ListenerEvent.swift
//  Tomo
//
//  Created by starboychina on 2015/09/07.
//  Copyright © 2015 e-business. All rights reserved.
//

private var observers = [String: Any]()

enum ListenerEvent: String {

    case announcement   = "new-announcement"

    case message        = "message-new"

    case groupMessage   = "message-group"

    case friendAccepted = "friend-accepted"

    case friendRefused  = "friend-refused"

    case friendInvited  = "friend-invited"

    case friendBreak    = "friend-break"

    case postNew        = "post-new"

    case postLiked      = "post-liked"

    case postCommented  = "post-commented"

    case postBookmarked = "post-bookmarked"

    case groupJoined    = "group-joined"

    case groupLeft      = "group-left"

    case any = "any"

    var notificationName: NSNotification.Name {
        return NSNotification.Name(rawValue: "tomoNotification-" + self.rawValue)
    }

    func post(userInfo: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: self.notificationName, object: nil, userInfo: userInfo)
    }

    func addObserver(observer: Any, selector aSelector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: aSelector, name: self.notificationName, object: nil)
    }

    func addObserver(observer: UIViewController, usingBlock block: @escaping (NSNotification!) -> Void) {

        if let observer: Any = observers[observer.description] {
            NotificationCenter.default.removeObserver(observer)
        }
//        observers[observer.description] = NotificationCenter.default.addObserver(name: self.notificationName, object: nil, queue: nil, usingBlock: block )

    }
}

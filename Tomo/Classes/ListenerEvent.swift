//
//  ListenerEvent.swift
//  Tomo
//
//  Created by starboychina on 2015/09/07.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

private var observers = [String:AnyObject]()

enum ListenerEvent: String {
    case Announcement = "new-announcement"
    case Message = "message-new"
    case FriendAccepted = "friend-accepted"
    case FriendRefused = "friend-refused"
    case FriendInvited = "friend-invited"
    case FriendBreak = "friend-break"
    
    case PostNew = "post-new"
    case PostLiked = "post-liked"
    case PostCommented = "post-commented"
    case PostBookmarked = "post-bookmarked"
    
    case Any = "any"
    
    func getNotificationName() -> String{
        return "tomoNotification-" + self.rawValue
    }
    
    func receive(data:[NSObject : AnyObject]){
        // TODO - Should add new message into me.newMessage
        // TODO - Should add friend-approved into me.friends
        NSNotificationCenter.defaultCenter().postNotificationName(self.getNotificationName(), object: nil, userInfo: data)
        if self != .Any {
            NSNotificationCenter.defaultCenter().postNotificationName(ListenerEvent.Any.getNotificationName(), object: nil, userInfo: data)
        }
        Util.showLocalNotificationGotSocketEvent(self, data: data)
    }
    
    
    func addObserver(observer: AnyObject, selector aSelector: Selector){
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: aSelector, name: self.getNotificationName(), object: nil)
    }
    
    func addObserver(observer: UIViewController, usingBlock block: (NSNotification!) -> Void){
        
        if let observer: AnyObject = observers[observer.description] {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
        
        observers[observer.description] = NSNotificationCenter.defaultCenter().addObserverForName(self.getNotificationName(), object: nil, queue: nil, usingBlock: block )
        
    }
}

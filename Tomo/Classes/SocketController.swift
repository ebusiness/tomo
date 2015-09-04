//
//  SocketController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/27.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

enum SocketEvent: String {
    case Announcement = "new-announcement"
    case Message = "message-new"
    case FriendApproved = "friend-approved"
    case FriendDeclined = "friend-declined"
    case FriendInvited = "friend-invited"
    case FriendBreak = "friend-break"
    
    case PostNew = "post-new"
    case PostLiked = "post-liked"
    case PostCommented = "post-commented"
    case PostBookmarked = "post-bookmarked"
    
    case CommentReplied = "comment-replied"
    
    
    func getNotificationName() -> String{
        return "tomoNotification-" + self.rawValue
    }
    
    func receive(data:[NSObject : AnyObject]){
        // TODO - Should add new message into me.newMessage
        // TODO - Should add friend-approved into me.friends
        NSNotificationCenter.defaultCenter().postNotificationName(self.getNotificationName(), object: nil, userInfo: data)
        Util.showLocalNotificationGotSocketEvent(self, data: data)
    }
}

final class SocketController {
    
    private var socket: SocketIOClient!
    private var observers = [String:AnyObject]()
    
    class var sharedInstance : SocketController {
        struct Static {
            static let instance : SocketController = SocketController()
        }
        return Static.instance
    }
    
    private init() {
//        socket = AZSocketIO(host: "192.168.11.90", andPort: SocketPort, secure: false)
        
//        socket.eventRecievedBlock = { (name, data) -> Void in
//            gcd.async(.Default, closure: { () -> () in
//                
//                if let event = SocketEvent(rawValue: name), data = data as? NSArray, result = data[0] as? [NSObject : AnyObject] {
//                        
//                    event.receive(result)
//                }
//            })
//        }
        socket = SocketIOClient(socketURL: kAPIBaseURLString)
        
        socket.onAny { (event) -> Void in
            println("WWWWWWWWWWWWWWWWWWW")
            println(event.event)
            println(event.items)
            println("WWWWWWWWWWWWWWWWWWW")
            gcd.async(.Default, closure: { () -> () in
                
                if let socketEvent = SocketEvent(rawValue: event.event), data = event.items, result = data[0] as? [NSObject : AnyObject] {
                    
                    socketEvent.receive(result)
                }
            })
        }
    }
    
    class func connect() {
        
//        sharedInstance.socket.connectWithSuccess({ () -> Void in
//            println("connectWithSuccess")
//        }, andFailure: { (error) -> Void in
//                println(error)
//        })
        
        sharedInstance.socket.connect()
        
    }
    
    class func disconnect() {
        sharedInstance.socket.close(fast: false)
    }
}

extension SocketController {
    
    func addObserverForEvent(observer: AnyObject, selector aSelector: Selector, event aEvent: SocketEvent){
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: aSelector, name: aEvent.getNotificationName(), object: nil)
    }
    
    
    func addObserverForEvent(observer: UIViewController, event: SocketEvent, usingBlock block: (NSNotification!) -> Void){
        
        if let observer: AnyObject = observers[observer.description] {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
        
        observers[observer.description] = NSNotificationCenter.defaultCenter().addObserverForName(event.getNotificationName(), object: nil, queue: nil, usingBlock: block )
        
    }
}

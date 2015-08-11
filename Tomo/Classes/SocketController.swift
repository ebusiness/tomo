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
    
    func getNotificationName() -> String{
        return "kNotification-" + self.rawValue
    }
}

let kNotificationGotNewMessage = "kNotificationGotNewMessage"
let kNotificationGotNewAnnouncement = "kNotificationGotNewAnnouncement"

final class SocketController {
    
    class var sharedInstance : SocketController {
        struct Static {
            static let instance : SocketController = SocketController()
        }
        return Static.instance
    }
    
    private var socket: AZSocketIO!
    private var observers = [String:AnyObject]()
    
    private init() {
        socket = AZSocketIO(host: "tomo.e-business.co.jp", andPort: SocketPort, secure: false)
        
        socket.eventRecievedBlock = { (name, data) -> Void in
            if let event = SocketEvent(rawValue: name) {
                
                gcd.async(.Default, closure: { () -> () in
                    let data = data as? [NSObject : AnyObject]
                    NSNotificationCenter.defaultCenter().postNotificationName(event.getNotificationName(), object: nil, userInfo: data)
                    Util.showLocalNotificationGotSocketEvent(event)
                })
            }
        }
        
        socket.connectWithSuccess({ () -> Void in
            println("connectWithSuccess")
        }, andFailure: { (error) -> Void in
            println(error)
        })
        
    }
    func addObserverForEvent(observer: AnyObject, selector aSelector: Selector, event aEvent: SocketEvent){
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: aSelector, name: aEvent.getNotificationName(), object: nil)
    }
    
    
    func addObserverForEvent(observer: UIViewController, event: SocketEvent, usingBlock block: (NSNotification!) -> Void){

        if let observer: AnyObject = observers[observer.description] {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
        
        observers[observer.description] = NSNotificationCenter.defaultCenter().addObserverForName(event.getNotificationName(), object: nil, queue: nil, usingBlock: block )
        
    }
    
    class func stop() {
        sharedInstance.socket.disconnect()
    }
}

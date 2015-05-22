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
}

let kNotificationGotNewMessage = "kNotificationGotNewMessage"
let kNotificationGotNewAnnouncement = "kNotificationGotNewAnnouncement"

class SocketController {
    
    private static let instance = SocketController()
    private var socket:AZSocketIO!
    
    private init() {
        socket = AZSocketIO(host: "tomo.e-business.co.jp", andPort: SocketPort, secure: false)
    }
    
    private func setup() {
        socket.eventRecievedBlock = { (name, data) -> Void in
            if let event = SocketEvent(rawValue: name) {
                self.dealWithEvent(event)
            }
        }
        
        socket.connectWithSuccess({ () -> Void in
            println("connectWithSuccess")
            }, andFailure: { (error) -> Void in
                println(error)
        })
    }
    
    class func start() {
        instance.setup()
    }
    
    class func stop() {
        instance.socket.disconnect()
    }
    
    private func dealWithEvent(event: SocketEvent) {
        switch event {
        case .Announcement:
            ApiController.getAnnouncements({ (error) -> Void in
                if error == nil {
                    //post notification
                    NSNotificationCenter.defaultCenter().postNotificationName(kNotificationGotNewAnnouncement, object: nil)
                    Util.showLocalNotificationGotSocketEvent(event)
                }
            })
            
        case .Message:
            ApiController.getMessage({ (error) -> Void in
                if error == nil {
                    //post notification
                    NSNotificationCenter.defaultCenter().postNotificationName(kNotificationGotNewMessage, object: nil)
                    Util.showLocalNotificationGotSocketEvent(event)
                }
            })
            
        default:
            println("todo")
        }
    }
}

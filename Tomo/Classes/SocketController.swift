//
//  SocketController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/27.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

enum SocketEvent:String{
    case Announcement = "new-announcement"
    case Message = "message-new"
    case FriendApproved = "friend-approved"
    case FriendDeclined = "friend-declined"
    
}

class SocketController {
    
    private static let instance = SocketController()
    private var socket:AZSocketIO!
    
    private init() {
        socket = AZSocketIO(host: "tomo.e-business.co.jp", andPort: SocketPort, secure: false)
    }
    
    private func setup() {
        socket.eventRecievedBlock = { (name, data) -> Void in
            
            if name == "message-new" {
                /*
                let array = data as! NSArray
                
                for dic in array {
                ChatController.addChat(dic as! NSDictionary)
                }
                
                ChatController.save(done: { () -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName("GotNewMessage", object: nil)
                })*/
                
                ApiController.getMessage({ (error) -> Void in
                    if error == nil {
                        //post notification
                        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationGotNewMessage, object: nil)
                        Util.showGotMessageLocalNotification()
                    }
                })
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
}

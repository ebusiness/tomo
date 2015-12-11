//
//  SocketController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/27.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit
import SocketIO

final class SocketController {
    
    private var socket: SocketIOClient!
    
    class var sharedInstance : SocketController {
        struct Static {
            static let instance : SocketController = SocketController()
        }
        return Static.instance
    }

    private init() {}
    
    class func connect() {
        gcd.async(.Default) { () -> () in
            if self.sharedInstance.socket == nil {
                self.sharedInstance.socket = SocketIOClient(socketURL: TomoConfig.Api.Url)
                self.sharedInstance.socket.onAny { (event) -> Void in
                    if let socketEvent = ListenerEvent(rawValue: event.event), data = event.items, result = data[0] as? [NSObject : AnyObject] {
                        gcd.async(.High) { () -> () in
                            socketEvent.receive(result)
                        }
                    }
                }
            }
            
            self.sharedInstance.socket.connect()
        }
    }
    
    class func disconnect() {
        gcd.async(.High) { () -> () in
            self.sharedInstance.socket.close()
        }
    }
}

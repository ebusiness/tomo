//
//  SocketController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/27.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import SocketIO

final class SocketController {
    
    private var socket: SocketIOClient!
    
    static let sharedInstance: SocketController = SocketController()

    private init() {

        self.socket = SocketIOClient(socketURL: TomoConfig.Api.UrlString)
        self.socket.onAny {

            guard let data = $0.items else {return}
            guard let result = data[0] as? [NSObject : AnyObject] else {return}
            guard let socketEvent = ListenerEvent(rawValue: $0.event) else {return}

            gcd.async(.High) { () -> () in
                socketEvent.receive(result)
            }
        }
    }
    
    class func connect() {
        self.sharedInstance.socket.connect()
    }

    class func disconnect() {
        self.sharedInstance.socket.close()
    }
}

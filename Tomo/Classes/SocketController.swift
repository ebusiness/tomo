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

        self.socket = SocketIOClient(socketURL: TomoConfig.Api.Url)
        self.socket.onAny {

            guard let items = $0.items, !items.isEmpty else {return}
            guard let result = items[0] as? [NSObject : Any] else {return}
            guard let socketEvent = ListenerEvent(rawValue: $0.event) else {return}

            gcd.async(.high) { () -> () in
                socketEvent.relayToNoticationCenter(result)
            }
        }
    }

    class func connect() {
        self.sharedInstance.socket.connect()
    }

    class func disconnect() {
        self.sharedInstance.socket.disconnect()
    }
}

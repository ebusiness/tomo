//
//  RemoteNotification.swift
//  Tomo
//
//  Created by starboychina on 2015/09/07.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation
import SwiftyJSON

class RemoteNotification {

    var taskUserInfo: [NSObject : Any]?
    var constraints = [Any]()

    static let sharedInstance : RemoteNotification = RemoteNotification()

    private init() {}

    func receiveRemoteNotification(_ userInfo: [AnyHashable : Any]) {
        gcd.async(.default) {
            if UIApplication.shared.keyWindow?.rootViewController is TabBarController{

                let type = JSON(userInfo)["type"].stringValue

                if let event = ListenerEvent(rawValue: type) {
                    event.relayToNoticationCenter(userInfo)
                }
            } else {
                self.taskUserInfo = userInfo as [NSObject : Any]?
            }
        }
    }

    func runTask(){
        guard let userInfo = self.taskUserInfo else { return }
        self.taskUserInfo = nil
        receiveRemoteNotification(userInfo)
    }
}

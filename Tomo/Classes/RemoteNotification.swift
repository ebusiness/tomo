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
    
    var taskUserInfo: [NSObject : AnyObject]?
    var constraints = [AnyObject]()
    
    static let sharedInstance : RemoteNotification = RemoteNotification()

    private init() {}
    
    func receiveRemoteNotification(userInfo: [NSObject : AnyObject]) {
        gcd.async(.Default) {
            if UIApplication.sharedApplication().keyWindow?.rootViewController is TabBarController{
                
                let type = JSON(userInfo)["type"].stringValue
                
                if let event = ListenerEvent(rawValue: type) {
                    event.receive(userInfo)
                }
            } else {
                self.taskUserInfo = userInfo
            }
        }
    }
    
    func runTask(){
        if let userInfo = self.taskUserInfo {
            self.taskUserInfo = nil
            receiveRemoteNotification(userInfo)
        }
    }
}

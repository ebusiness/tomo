//
//  SettingRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/15.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

// MARK: - user setting
extension Router {
    
    struct Setting {
        class Device: NSObject, APIRoute {
            let path = "/device"
            let method = RouteMethod.POST
            
            let os: String, model: String, version: String
            let token: String
            
            init(deviceToken: NSData) {
                
                self.token = String(deviceToken.description.characters.filter {!"<> ".characters.contains($0)})
                
                let device = UIDevice.currentDevice()
                self.os = device.systemName
                self.model = device.model
                self.version = device.systemVersion
            }
        }
        
        class Updater: NSObject, APIRoute {
            let path = "/me"
            let method = RouteMethod.PATCH
            
            var nickName: String?,
            firstName: String?,
            lastName: String?,
            telNo: String?,
            address: String?,
            bio: String?,
            gender: String?,
            photo: String?,
            cover: String?,
            birthDay: NSDate?
            
            var removeDevice: String?, pushSetting: UserEntity.PushSetting?
            
        }
        
        class Notification: NSObject, APIRoute {
            let path = "/notifications"
            
            var before: String?
        }
    }
    
}
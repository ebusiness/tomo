//
//  SettingRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/15.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

// MARK: - user setting
extension Router {
    
    enum Setting: APIRoute {
        case UpdateDevice(deviceToken: NSData)
        case UpdateUserInfo(parameters: MeParameter)
        case FindNotification(before: NSTimeInterval?)
        
        var path: String {
            switch self{
            case UpdateDevice: return "/device"
            case UpdateUserInfo: return "/me"
            case FindNotification: return "/notifications"
            }
        }
        
        var method: RouteMethod {
            switch self{
            case UpdateDevice: return .POST
            case UpdateUserInfo: return .PATCH
            case FindNotification: return .GET
            }
        }
        
        var parameters: [String: AnyObject]? {
            switch self{
            case let UpdateDevice(deviceToken):
                let token = String(deviceToken.description.characters.filter {!"<> ".characters.contains($0)})
                let device = UIDevice.currentDevice()
                return [
                    "token": token,
                    "os": device.systemName,
                    "model": device.model,
                    "version": device.systemVersion,
                ]
            case let UpdateUserInfo(parameters):
                return parameters.getParameters()
            case let FindNotification(before):
                guard let before = before else { return nil }
                return ["before": String(before)]
            }
        }
    }
    
}

extension Router.Setting {
    
    struct MeParameter {
        var nickName: String?,
        firstName: String?,
        lastName: String?,
        telNo: String?,
        address: String?,
        bio: String?,
        gender: String?,
        photo: String?,
        cover: String?,
        birthDay: NSDate?,
        primaryStation: String?
        
        var removeDevice: String?, pushSetting: Account.PushSetting?
        
        init(){}
        
        func getParameters() -> [String: AnyObject]? {
            
            var parameters = [String: AnyObject]()
            
            if let nickName = nickName {
                parameters["nickName"] = nickName
            }
            if let firstName = firstName {
                parameters["firstName"] = firstName
            }
            if let lastName = lastName {
                parameters["lastName"] = lastName
            }
            if let telNo = telNo {
                parameters["telNo"] = telNo
            }
            if let address = address {
                parameters["address"] = address
            }
            if let address = address {
                parameters["address"] = address
            }
            if let bio = bio {
                parameters["bio"] = bio
            }
            if let gender = gender {
                parameters["gender"] = gender
            }
            if let photo = photo {
                parameters["photo"] = photo
            }
            if let cover = cover {
                parameters["cover"] = cover
            }
            if let birthDay = birthDay {
                parameters["birthDay"] = birthDay
            }
            if let photo = photo {
                parameters["photo"] = photo
            }
            if let primaryStation = primaryStation {
                parameters["primaryStation"] = primaryStation
            }
            if let removeDevice = removeDevice {
                parameters["removeDevice"] = removeDevice
            }
            
            
            if let pushSetting = pushSetting {
                parameters["pushSetting"] = [
                    "announcement": pushSetting.announcement,
                    "message": pushSetting.message,
                    "groupMessage": pushSetting.groupMessage,
                    "friendInvited": pushSetting.friendInvited,
                    "friendAccepted": pushSetting.friendAccepted,
                    "friendRefused": pushSetting.friendRefused,
                    "friendBreak": pushSetting.friendBreak,
                    "postNew": pushSetting.postNew,
                    "postCommented": pushSetting.postCommented,
                    "postLiked": pushSetting.postLiked,
                    "postBookmarked": pushSetting.postBookmarked,
                    "groupJoined": pushSetting.groupJoined,
                    "groupLeft": pushSetting.groupLeft,
                ]
            }
            if parameters.count > 0 {
                return parameters
            } else {
                return nil
            }
        }
    }

}
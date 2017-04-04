//
//  SettingRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/15.
//  Copyright © 2015 e-business. All rights reserved.
//

// MARK: - user setting
extension Router {

    enum Setting: APIRoute {
        case updateDevice(deviceToken: Data)
        case updateUserInfo(parameters: MeParameter)
        case findNotification(before: TimeInterval?)

        var path: String {
            switch self {
            case .updateDevice: return "/device"
            case .updateUserInfo: return "/me"
            case .findNotification: return "/notifications"
            }
        }

        var method: RouteMethod {
            switch self {
            case .updateDevice: return .POST
            case .updateUserInfo: return .PATCH
            case .findNotification: return .GET
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case let .updateDevice(deviceToken):
                let token = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
                let device = UIDevice.current
                return [
                    "token": token,
                    "os": device.systemName,
                    "model": device.model,
                    "version": device.systemVersion
                ]
            case let .updateUserInfo(parameters):
                return parameters.getParameters()
            case let .findNotification(before):
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
        birthDay: Date?,
        primaryGroup: String?

        var removeDevice: String?, pushSetting: Account.PushSetting?

        init() {}

        func getParameters() -> [String: Any]? {

            var parameters = [String: Any]()

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
            if let primaryGroup = primaryGroup {
                parameters["primaryGroup"] = primaryGroup
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
                    "groupLeft": pushSetting.groupLeft
                ]
            }
            if !parameters.isEmpty {
                return parameters
            } else {
                return nil
            }
        }
    }

}

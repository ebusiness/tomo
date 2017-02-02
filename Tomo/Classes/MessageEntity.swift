//
//  MessageEntity.swift
//  Tomo
//
//  Created by ebuser on 2015/08/05.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation
import SwiftyJSON

class MessageEntity: Entity {

    var id: String!

    var to: UserEntity!

    var from: UserEntity!

    var type = MessageType.text

    var group: GroupEntity?

    var content: String!

    var createDate: Date!

    override init() {
        super.init()
    }

    required init(_ json: JSON) {
        super.init()
        if let id = json.string { //id only
            self.id = id
            return
        }
        self.id = json["_id"].string ?? json["id"].stringValue
        self.to = UserEntity(json["to"])
        self.from = UserEntity(json["from"])
        if let type = MessageType(rawValue: json["messagetype"].string ?? json["type"].stringValue) {
            self.type = type
        }

        if !(json["group"].object is NSNull) {
            self.group = GroupEntity(json["group"])
        }
        self.content = json["content"].string ?? json["aps"]["alert"].stringValue
        self.createDate = json["createDate"].stringValue.toDate(format: TomoConfig.Date.Format)

    }
}

public enum MessageType: String {
    case voice, photo, video, text

    func remotePath(_ name: String) -> String {
        switch self {
        case .photo:
            return "/messages/images/\(name)"
        case .voice:
            return "/messages/voices/\(name)"
        case .video:
            return "/messages/videos/\(name)"
        default:
            return "/messages/other/\(name)"
        }
    }
    func fullPath(name: String) -> String {
        let remote = remotePath(name)
        return "\(TomoConfig.AWS.S3.Url)/\(TomoConfig.AWS.S3.Bucket)\(remote)"
    }

}

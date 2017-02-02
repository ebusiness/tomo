//
//  NotificationEntity.swift
//  Tomo
//
//  Created by ebuser on 2015/08/05.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation
import SwiftyJSON

class NotificationEntity: Entity {

    var id: String!

    var from: UserEntity!

    var type: String!

    var message: String!

    var targetId: String!

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
        self.from = UserEntity(json["from"])
        self.type = json["type"].stringValue

        if let createDate = json["createDate"].string {
            self.createDate = createDate.toDate(format: TomoConfig.Date.Format)
        } else {
            self.createDate = Date()
        }

        self.message = json["aps"]["alert"].stringValue
        self.targetId = json["targetId"].stringValue
    }
}

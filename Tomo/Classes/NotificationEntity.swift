//
//  NotificationEntity.swift
//  Tomo
//
//  Created by ebuser on 2015/08/05.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class NotificationEntity: NSObject {
    
    var id: String!
    
    var from: UserEntity!
    
    var type: String!
    
    var message: String!
    
    var targetId: String!
    
    var createDate: NSDate!
    
    override init() {
        super.init()
    }
    
    convenience init(_ respunse: AnyObject) {
        self.init(JSON(respunse))
    }
    
    init(_ json: JSON) {
        super.init()
        self.id = json["_id"].stringValue
        self.from = UserEntity(json["from"].object)
        self.type = json["type"].stringValue
        self.createDate = json["createDate"].stringValue.toDate(format: kDateFormat)
        
        self.message = json["aps"]["alert"].stringValue
        
        if let event = ListenerEvent(rawValue: self.type) {
            switch event {
                //User
            case .FriendInvited, .FriendApproved:
                self.targetId = self.from.id
                //Post
            case .PostNew, .PostCommented:
                self.targetId = json["targetId"].stringValue
                //Message
            case .Message:
                self.targetId = json["targetId"].stringValue
            default:
                break
            }
        }
    }
}
//
//  MessageEntity.swift
//  Tomo
//
//  Created by ebuser on 2015/08/05.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class MessageEntity: Entity {
    
    var id: String!
    
    var to: UserEntity!
    
    var from: UserEntity!
    
    var content: String!
    
    var opened: Bool!
    
    var createDate: NSDate!
    
    override init() {
        super.init()
    }
    
    required init(_ json: JSON) {
        super.init()
        self.id = json["id"].stringValue
        self.to = UserEntity(json["to"])
        self.from = UserEntity(json["from"])
        self.content = json["content"].stringValue
        self.opened = json["opened"].boolValue
        self.createDate = json["createDate"].stringValue.toDate(format: kDateFormat)
        
    }
}
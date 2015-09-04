//
//  MessageEntity.swift
//  Tomo
//
//  Created by ebuser on 2015/08/05.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class MessageEntity: NSObject {
    
    var id: String!
    
    var to: UserEntity!
    
    var from: UserEntity!
    
    var content: String!
    
    var opened: Bool!
    
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
        self.to = UserEntity(json["to"].object)
        self.from = UserEntity(json["from"].object)
        self.content = json["content"].stringValue
        self.opened = json["opened"].boolValue
        self.createDate = json["createDate"].stringValue.toDate(format: kDateFormat)
        
    }
}
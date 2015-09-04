//
//  InvitationEntity.swift
//  Tomo
//
//  Created by starboychina on 2015/09/04.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class InvitationEntity: NSObject {
    
    var id: String!
    
    var type: String!
    
    var to: UserEntity!
    
    var from: UserEntity!
    
    var result: String!
    
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
        self.type = json["type"].stringValue
        self.to = UserEntity(json["to"].object)
        self.from = UserEntity(json["from"].object)
        self.result = json["result"].stringValue
        self.createDate = json["createDate"].stringValue.toDate(format: kDateFormat)
        
    }
}

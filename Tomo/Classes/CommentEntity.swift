//
//  CommentEntity.swift
//  Tomo
//
//  Created by ebuser on 2015/08/05.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation
import SwiftyJSON

class CommentEntity: Entity {
    
    var id: String!
    
    var owner: UserEntity!
    
    var content: String!
    
    var createDate: NSDate!
    
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
        self.owner = UserEntity(json["owner"])
        self.content = json["content"].stringValue
        self.createDate = json["createDate"].stringValue.toDate(kDateFormat)
        
    }
}
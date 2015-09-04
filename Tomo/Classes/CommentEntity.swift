//
//  CommentEntity.swift
//  Tomo
//
//  Created by ebuser on 2015/08/05.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class CommentEntity: NSObject {
    
    var id: String!
    
    var owner: UserEntity!
    
    var content: String!
    
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
        self.owner = UserEntity(json["owner"].object)
        self.content = json["content"].stringValue
        self.createDate = json["createDate"].stringValue.toDate(format: kDateFormat)
        
    }
}
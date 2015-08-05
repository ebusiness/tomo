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
    
    var replyTo: String?
    
    var content: String!

    var like: [String]?
    
    var createDate: NSDate!
    
}
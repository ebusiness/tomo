//
//  PostEntity.swift
//  Tomo
//
//  Created by ebuser on 2015/07/30.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class PostEntity: NSObject {
    
    var id: String!
    
    var owner: UserEntity!
    
    var content: String!
    
    var images: [String]?
    
    var like: [String]?
    
    var comments: [CommentEntity]?
    
    var coordinate: [Double]?
    
    var createDate: NSDate!
    
//    override init() {
//        super.init()
//    }
}
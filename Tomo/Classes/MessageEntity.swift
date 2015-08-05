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
    
    var from: UserEntity!
    
    var content: String!
    
    var isOpened: Bool!
    
    var createDate: NSDate!
    
}
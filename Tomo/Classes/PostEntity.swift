//
//  PostEntity.swift
//  Tomo
//
//  Created by ebuser on 2015/07/30.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class PostEntity: Entity {
    
    var id: String!
    
    var owner: UserEntity!
    
    var content: String!
    
    var images: [String]?
    
    var like: [String]?
    
    var comments: [CommentEntity]?
    
    var coordinate: [Double]?
    
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
        
        self.images = json["images"].arrayObject as? [String]        
        self.like = json["like"].arrayObject as? [String]
        
        if let postComments = json["comments"].array {
            self.comments = []
            postComments.map { (commentJson) -> () in
                var comment = CommentEntity(commentJson)
                self.comments!.append(comment)
            }
        }
        
        self.coordinate = json["coordinate"].arrayObject as? [Double]
        self.createDate = json["createDate"].stringValue.toDate(format: kDateFormat)
        
        
    }
}
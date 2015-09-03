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
        
        if let imagesArray = json["images"].array {
            self.images = []
            imagesArray.map { (image) -> () in
                self.images!.append(image.stringValue)
            }
        }
        
        self.like = json["like"].arrayObject as? [String]
        
        if let postComments = json["comments"].array {
            self.comments = []
            postComments.map { (commentJson) -> () in
                var comment = CommentEntity(commentJson.object)
                self.comments!.append(comment)
            }
        }
        
        self.coordinate = json["coordinate"].arrayObject as? [Double]
        self.createDate = json["createDate"].stringValue.toDate(format: "yyyy-MM-dd't'HH:mm:ss.SSSZ")
        
        
    }
}
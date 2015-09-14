//
//  GroupEntity.swift
//  Tomo
//
//  Created by ebuser on 2015/09/14.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class GroupEntity: Entity {
    
    var id: String!
    
    var owner: UserEntity!
    
    var type: String!
    
    var name: String!
    
    var cover: String?
    
    var introduction: String?
    
    var coordinate: [Double]?
    
    var address: String?
    
    var members: [UserEntity]?
    
    var posts: [PostEntity]?
    
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
        
        self.type = json["type"].stringValue
        
        self.name = json["name"].stringValue
        
        self.cover = json["cover_ref"].stringValue
        
        self.introduction = json["introduction"].stringValue
        
        self.coordinate = json["coordinate"].arrayObject as? [Double]
        
        self.address = json["address"].stringValue
        
        if let members = json["members"].array {
            self.members = []
            members.map { (memberJson) -> () in
                var member = UserEntity(memberJson)
                self.members!.append(member)
            }
        }
        
        if let posts = json["posts"].array {
            self.posts = []
            posts.map { (postJson) -> () in
                var post = PostEntity(postJson)
                self.posts!.append(post)
            }
        }
        
        self.createDate = json["createDate"].stringValue.toDate(format: kDateFormat)
        
        
    }
}

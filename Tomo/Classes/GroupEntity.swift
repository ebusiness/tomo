//
//  GroupEntity.swift
//  Tomo
//
//  Created by ebuser on 2015/09/14.
//  Copyright © 2015 e-business. All rights reserved.
//

import Foundation
import SwiftyJSON

class GroupEntity: Entity {

    var id: String!

    var owner: UserEntity!

    var type: String!

    var name: String!

    var cover: String!

    var introduction: String?

    var coordinate: [Double]?

    var address: String?

    var pref: String?

    var members: [UserEntity]?

    var posts: [PostEntity]?

    var createDate: Date!

    var lastMessage: MessageEntity? {
        didSet {

        }
    }

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

        self.cover = json["cover_ref"].string ?? json["cover"].string

        self.introduction = json["introduction"].stringValue

        self.coordinate = json["coordinate"].arrayObject as? [Double]

        self.address = json["address"].stringValue

        self.pref = json["pref"].stringValue

        if let members = json["members"].array {
            self.members = []
            members.forEach { memberJson in
                let member = UserEntity(memberJson)
                self.members!.append(member)
            }
        }

        if let posts = json["posts"].array {
            self.posts = []
            posts.forEach { postJson in
                let post = PostEntity(postJson)
                self.posts!.append(post)
            }
        }

        self.createDate = json["createDate"].stringValue.toDate(format: TomoConfig.Date.Format)

        if !( json["lastMessage"].object is NSNull ) {
            self.lastMessage = MessageEntity(json["lastMessage"])
        }

    }
}
// MARK: - group
extension GroupEntity {
    func addMember(user: UserEntity) {
        self.members = self.members ?? []
        self.members!.append(user)
    }
    func removeMember(user: UserEntity) {
        self.members = self.members?.filter { $0.id != user.id }
    }
}

//
//  UserEntity.swift
//  Tomo
//
//  Created by ebuser on 2015/07/30.
//  Copyright © 2015 e-business. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserEntity: Entity {

    var id: String!

    var nickName: String!

    var gender: String?

    var photo: String?

    var cover: String?

    var bio: String?

    var firstName: String?

    var lastName: String?

    var birthDay: Date?

    var address: String?

    var projects: [UserProject]?

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

        self.nickName = json["nickName"].stringValue

        self.gender = json["gender"].string

        self.photo = json["photo_ref"].string ?? json["photo"].string

        self.cover = json["cover_ref"].string ?? json["cover"].string

        self.bio = json["bio"].string

        self.firstName = json["firstName"].string

        self.lastName = json["lastName"].string

        if let birthDay = json["birthDay"].string {
            self.birthDay = birthDay.toDate(format: TomoConfig.Date.Format)
        }

        self.address = json["address"].string

        if !( json["groups"].object is NSNull ) {
            self.projects = json["groups"].arrayObject as? [UserProject]
        }

        if !( json["lastMessage"].object is NSNull ) {
            self.lastMessage = MessageEntity(json["lastMessage"])
        }
    }
}

extension UserEntity {

    func fullName() -> String {
        let fName = firstName ?? ""
        let lName = lastName ?? ""
        return "\(lName) \(fName) "
    }
}

class UserProject: Entity {

    var isPrimary: Bool!

    var joinDate: Date?

    var leaveDate: Date?

    var project: GroupEntity!

    init(project: GroupEntity) {
        
        self.isPrimary = true
        self.project = project

        super.init()
    }

    required init(_ json: JSON) {

        super.init()

        isPrimary = json["isPrimary"].boolValue

        if let joinDate = json["joinDate"].string {
            self.joinDate = joinDate.toDate(format: TomoConfig.Date.Format)
        }

        if let leaveDate = json["leaveDate"].string {
            self.leaveDate = leaveDate.toDate(format: TomoConfig.Date.Format)
        }

        project = GroupEntity(json["group"])

    }
}

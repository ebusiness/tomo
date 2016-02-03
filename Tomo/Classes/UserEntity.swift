//
//  UserEntity.swift
//  Tomo
//
//  Created by ebuser on 2015/07/30.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
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
    
    var birthDay: NSDate?
    
    var address: String?

    var primaryStation: GroupEntity?
    
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
            self.birthDay = birthDay.toDate(TomoConfig.Date.Format)
        }
        
        self.address = json["address"].string
        
        if !( json["primaryStation"].object is NSNull ) {
            self.primaryStation = GroupEntity(json["primaryStation"])
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
// MARK: - station
//extension UserEntity {
//    func addStation(stationId: String) {
//        if stationId.length > 0 {
//            self.stations = self.stations ?? []
//            self.stations!.append(stationId)
//        }
//    }
//}

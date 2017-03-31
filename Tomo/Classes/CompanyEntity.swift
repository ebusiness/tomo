//
//  CompanyEntity.swift
//  Tomo
//
//  Created by starboychina on 2017/03/31.
//  Copyright © 2017  e-business. All rights reserved.
//

import Foundation
import SwiftyJSON

class CompanyEntity: Entity {

    var id: String!

    var owner: UserEntity!

    var type: String!

    var name: String!

    var homepage: String?

    var coordinate: [Double]?

    var address: String?

    var createDate: Date!

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

        self.homepage = json["homepage"].stringValue

        self.coordinate = json["coordinate"].arrayObject as? [Double]

        self.address = json["address"].stringValue

        self.createDate = json["createDate"].stringValue.toDate(format: TomoConfig.Date.Format)
    }
}

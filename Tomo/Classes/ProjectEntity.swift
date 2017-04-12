//
//  ProjectEntity.swift
//  Tomo
//
//  Created by 李超逸 on 2017/4/7.
//  Copyright © 2017年  e-business. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProjectEntity: Entity {

    var id: String

    var name: String

    var coordinate: [Double]?

    var members = [Any]()

    required init(_ json: JSON) {

        id = json["id"].stringValue

        name = json["name"].stringValue

        coordinate = json["coordinate"].arrayObject as? [Double]

        super.init()

    }
}

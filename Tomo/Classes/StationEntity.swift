//
//  StationEntity.swift
//  Tomo
//
//  Created by ebuser on 2015/09/24.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class StationEntity: Entity {
    
    var id: String!
    
    var name: String!
    
    var line: String!
    
    var address: String?
    
    var coordinate: [Double]?
    
    var color: String?
    
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
        
        self.name = json["name"].stringValue
        
        self.line = json["line"].stringValue
        
        self.address = json["address"].stringValue
        
        self.coordinate = json["coordinate"].arrayObject as? [Double]
        
        self.color = json["color"].stringValue
        
    }
}
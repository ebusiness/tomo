//
//  PostEntity.swift
//  Tomo
//
//  Created by ebuser on 2015/07/30.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class PostEntity: NSObject, MKAnnotation {
    
    var id: String!
    
    var owner: UserEntity!
    
    var content: String!
    
    var createDate: NSDate!
    
    var coordinateRawValue: [Double]?
    
    var coordinate: CLLocationCoordinate2D {
        if let lat = coordinateRawValue?.get(0), long = coordinateRawValue?.get(1) {
            return CLLocationCoordinate2DMake(lat, long)
        } else {
            return CLLocationCoordinate2DMake(33, 133)
        }
    }
    
    override init() {
        super.init()
    }
}
//
//  StationAnnotation.swift
//  Tomo
//
//  Created by ebuser on 2015/09/30.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class StationAnnotation: AggregatableAnnotation {
    
    var station: StationEntity!
    
    override var title: String {
        return station.name
    }
    
    override var subtitle: String {
        return station.line
    }
}

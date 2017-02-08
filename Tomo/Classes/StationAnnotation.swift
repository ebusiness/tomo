//
//  StationAnnotation.swift
//  Tomo
//
//  Created by ebuser on 2015/09/30.
//  Copyright © 2015 e-business. All rights reserved.
//

import Foundation

class StationAnnotation: AggregatableAnnotation {

    var station: GroupEntity!

    override var title: String {
        return station.name
    }

    override var subtitle: String {
        return station.name
    }
}

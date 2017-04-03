//
//  AggregatableAnnotation.swift
//  Tomo
//
//  Created by ebuser on 2015/09/30.
//  Copyright © 2015 e-business. All rights reserved.
//

import Foundation

class AggregatableAnnotation: NSObject, MKAnnotation {

    var containedAnnotations = [AggregatableAnnotation]()

    var clusterAnnotation: AggregatableAnnotation?

    dynamic var coordinate: CLLocationCoordinate2D

    override init() {
        self.coordinate = CLLocationCoordinate2DMake(TomoConst.Geo.Tokyo.Latitude, TomoConst.Geo.Tokyo.Longitude)
        super.init()
    }

    var title: String? {
        return ""
    }

    var subtitle: String? {
        return ""
    }
}

//
//  AggregatableAnnotation.swift
//  Tomo
//
//  Created by ebuser on 2015/09/30.
//  Copyright © 2015 e-business. All rights reserved.
//

import Foundation

class AggregatableAnnotation: NSObject, MKAnnotation {

    var containedAnnotations: Array<AggregatableAnnotation>?

    var clusterAnnotation: AggregatableAnnotation?

    dynamic var coordinate: CLLocationCoordinate2D

    override init() {
        self.coordinate = CLLocationCoordinate2DMake(33, 133)
        super.init()
    }

    var title: String? {
        return ""
    }

    var subtitle: String? {
        return ""
    }
}

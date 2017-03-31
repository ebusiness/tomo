//
//  CompanyAnnotation.swift
//  Tomo
//
//  Created by starboychina on 2017/03/31.
//  Copyright © 2017  e-business. All rights reserved.
//

import Foundation

class CompanyAnnotation: AggregatableAnnotation {

    var entity: CompanyEntity! {
        didSet {
            guard let coord = self.entity.coordinate else { return }
            self.coordinate = CLLocationCoordinate2DMake(coord[0], coord[1])
        }
    }

    override var title: String {
        return entity.name
    }

    override var subtitle: String {
        return entity.name
    }
}

//
//  ProjectAnnotation.swift
//  Tomo
//
//  Created by 李超逸 on 2017/4/7.
//  Copyright © 2017年  e-business. All rights reserved.
//

import Foundation

class ProjectAnnotation: AggregatableAnnotation {

    var project: ProjectEntity

    override var title: String? {
        return project.name
    }

    override var subtitle: String? {
        return ""
    }

    init(project: ProjectEntity) {
        self.project = project

        super.init()

        if let coord = project.coordinate {
            self.coordinate = CLLocationCoordinate2DMake(coord[0], coord[1])
        }
    }
}

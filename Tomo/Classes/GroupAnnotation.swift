//
//  GroupAnnotation.swift
//  Tomo
//
//  Created by ebuser on 2015/09/29.
//  Copyright © 2015 e-business. All rights reserved.
//

import Foundation

class GroupAnnotation: AggregatableAnnotation {

    var group: GroupEntity!

    override var title: String {
        return group.name
    }

    override var subtitle: String {
        if let introduction = group.introduction {
            return introduction
        } else {
            return ""
        }
    }
}

//
//  UserAnnotation.swift
//  Tomo
//
//  Created by ebuser on 2016/01/07.
//  Copyright © 2016 e-business. All rights reserved.
//

import Foundation

class UserAnnotation: AggregatableAnnotation {

    var user: UserEntity!

    override var title: String {
        return user.nickName
    }

    override var subtitle: String {
        return user.nickName
    }
}

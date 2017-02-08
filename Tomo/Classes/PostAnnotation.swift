//
//  PostAnnotation.swift
//  Tomo
//
//  Created by ebuser on 2015/08/03.
//  Copyright © 2015 e-business. All rights reserved.
//

import Foundation

class PostAnnotation: AggregatableAnnotation {

    var post: PostEntity!

    override var title: String {
        return post.owner.nickName
    }

    override var subtitle: String {
        return post.content
    }
}

//
//  PostAnnotation.swift
//  Tomo
//
//  Created by ebuser on 2015/08/03.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
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

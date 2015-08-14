//
//  PostAnnotation.swift
//  Tomo
//
//  Created by ebuser on 2015/08/03.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class PostAnnotation: NSObject, MKAnnotation {
    
    var post: PostEntity!
    
    var containedAnnotations: Array<PostAnnotation>?
    
    var clusterAnnotation: PostAnnotation?
    
    dynamic var coordinate: CLLocationCoordinate2D

    var title: String {
        return post.owner.nickName
    }
    
    var subtitle: String {
        return post.content
    }
    
    override init() {
        self.coordinate = CLLocationCoordinate2DMake(33, 133)
        super.init()
    }
}

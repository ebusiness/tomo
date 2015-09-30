//
//  PostAnnotationView.swift
//  Tomo
//
//  Created by ebuser on 2015/07/29.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class PostAnnotationView: AggregatableAnnotationView {
    
    override func setupAnnotationImage() {
        let annotation = self.annotation as! PostAnnotation
        imageView.sd_setImageWithURL(NSURL(string:  annotation.post.owner.photo!), placeholderImage: DefaultAvatarImage)
    }
}

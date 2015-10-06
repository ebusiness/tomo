//
//  ICYPostImageCell.swift
//  Tomo
//
//  Created by eagle on 15/10/6.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ICYPostImageCell: ICYPostCell {
    
    override var post: PostEntity? {
        didSet {
            if let post = post {
                super.post = post
            } else {
                super.post = nil
            }
        }
    }
}

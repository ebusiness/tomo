//
//  PostAnnotationView.swift
//  Tomo
//
//  Created by ebuser on 2015/07/29.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class PostAnnotationView: AggregatableAnnotationView {
    
    var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(annotation: MKAnnotation!, reuseIdentifier: String!) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = Util.UIColorFromRGB(NavigationBarColorHex, alpha: 1).CGColor
        imageView.layer.cornerRadius = imageView.frame.width / 2
        addSubview(imageView)
        
        numberBadge.frame = CGRect(x: 25, y: 0, width: 20, height: 20)
        numberBadge.layer.cornerRadius = numberBadge.frame.width / 2
    }
    
    override func setupDisplay() {
        super.setupDisplay()
        
        if let annotation = self.annotation as? PostAnnotation {
            imageView.sd_setImageWithURL(NSURL(string:  annotation.post.owner.photo!), placeholderImage: DefaultAvatarImage)
        }
    }

}

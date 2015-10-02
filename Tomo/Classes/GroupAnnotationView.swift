//
//  GroupAnnotationView.swift
//  Tomo
//
//  Created by ebuser on 2015/09/29.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class GroupAnnotationView: AggregatableAnnotationView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(annotation: MKAnnotation!, reuseIdentifier: String!) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.canShowCallout = false
        
        frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = Palette.Red.getPrimaryColor().CGColor
        imageView.layer.cornerRadius = 5
        addSubview(imageView)
        
        numberBadge = UILabel(frame: CGRect(x: 25, y: -6, width: 20, height: 20))
        numberBadge.textColor = UIColor.whiteColor()
        numberBadge.textAlignment = NSTextAlignment.Center
        numberBadge.font = UIFont.systemFontOfSize(12)
        numberBadge.clipsToBounds = true
        numberBadge.layer.borderWidth = 1
        numberBadge.layer.borderColor = UIColor.whiteColor().CGColor
        numberBadge.layer.cornerRadius = numberBadge.frame.width / 2
        numberBadge.backgroundColor = UIColor.redColor()
    }
    
    override func setupAnnotationImage() {
        let annotation = self.annotation as! GroupAnnotation
        imageView.sd_setImageWithURL(NSURL(string: annotation.group.cover!), placeholderImage: DefaultGroupImage)
    }
}

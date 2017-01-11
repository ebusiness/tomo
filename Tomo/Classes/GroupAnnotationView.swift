//
//  GroupAnnotationView.swift
//  Tomo
//
//  Created by ebuser on 2015/09/29.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class GroupAnnotationView: AggregatableAnnotationView {
    
    var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(annotation: MKAnnotation!, reuseIdentifier: String!) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = Palette.Red.primaryColor.cgColor
        imageView.layer.cornerRadius = 5
        addSubview(imageView)
        
        numberBadge.frame = CGRect(x: 28, y: -8, width: 20, height: 20)
        numberBadge.layer.cornerRadius = numberBadge.frame.width / 2
    }
    
    override func setupDisplay() {
        
        super.setupDisplay()
        
        let annotation = self.annotation as! GroupAnnotation
        imageView.sd_setImage(with: URL(string: annotation.group.cover!), placeholderImage: DefaultGroupImage)
    }

}

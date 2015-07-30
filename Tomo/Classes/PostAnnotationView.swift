//
//  PostAnnotationView.swift
//  Tomo
//
//  Created by ebuser on 2015/07/29.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class PostAnnotationView: MKAnnotationView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    


    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init!(annotation: MKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        let post = annotation as! PostEntity
        
        frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        clipsToBounds = true
        contentMode = UIViewContentMode.ScaleAspectFill
        
        layer.cornerRadius = frame.width / 2
        layer.borderWidth = 1
        layer.borderColor = UIColor.orangeColor().CGColor
        
        var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        imageView.sd_setImageWithURL(NSURL(string:  post.owner.photo!), placeholderImage: UIImage(named: "avatar"))
        
        addSubview(imageView)
        
    }

}

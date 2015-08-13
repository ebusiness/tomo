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
    
    var imageView: UIImageView!
    var contentLabel: UILabel!
    var numberBadge: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(annotation: MKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        let postAnnotation = annotation as! PostAnnotation
        
        frame = CGRect(x: 0, y: 0, width: 60, height: 60)

        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.sd_setImageWithURL(NSURL(string:  postAnnotation.post.owner.photo!), placeholderImage: UIImage(named: "avatar"))
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = Util.UIColorFromRGB(NavigationBarColorHex, alpha: 1).CGColor
        imageView.layer.cornerRadius = imageView.frame.width / 2
        addSubview(imageView)
        
        numberBadge = UILabel(frame: CGRect(x: 45, y: 0, width: 20, height: 20))
        numberBadge.textColor = UIColor.whiteColor()
        numberBadge.textAlignment = NSTextAlignment.Center
        numberBadge.font = UIFont.systemFontOfSize(12)
        numberBadge.layer.cornerRadius = 10
        numberBadge.layer.borderWidth = 1
        numberBadge.layer.borderColor = UIColor.whiteColor().CGColor
        numberBadge.clipsToBounds = true
        numberBadge.backgroundColor = UIColor.redColor()
        
        updateBadge()
    }
    
    func updateBadge() {
        
        let postAnnotation = annotation as! PostAnnotation
        
        if let containedAnnotations = postAnnotation.containedAnnotations {
            
            if containedAnnotations.count > 0 {
                numberBadge.text = "\(containedAnnotations.count + 1)"
                addSubview(numberBadge)
            } else {
                numberBadge.removeFromSuperview()
            }
        }
    }

}

//
//  PostAnnotationView.swift
//  Tomo
//
//  Created by ebuser on 2015/07/29.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class PostAnnotationView: MKAnnotationView {
    
    var imageView: UIImageView!
    var numberBadge: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(annotation: MKAnnotation!, reuseIdentifier: String!) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.canShowCallout = true
        
        let postAnnotation = annotation as! PostAnnotation
        
        frame = CGRect(x: 0, y: 0, width: 40, height: 40)

        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.sd_setImageWithURL(NSURL(string:  postAnnotation.post.owner.photo!), placeholderImage: UIImage(named: "avatar"))
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = Util.UIColorFromRGB(NavigationBarColorHex, alpha: 1).CGColor
        imageView.layer.cornerRadius = imageView.frame.width / 2
        addSubview(imageView)
        
        numberBadge = UILabel(frame: CGRect(x: 25, y: 0, width: 20, height: 20))
        numberBadge.textColor = UIColor.whiteColor()
        numberBadge.textAlignment = NSTextAlignment.Center
        numberBadge.font = UIFont.systemFontOfSize(12)
        numberBadge.clipsToBounds = true
        numberBadge.layer.borderWidth = 1
        numberBadge.layer.borderColor = UIColor.whiteColor().CGColor
        numberBadge.layer.cornerRadius = 10
        numberBadge.backgroundColor = UIColor.redColor()
        
        updateBadge()
    }
    
    func setupDisplay() {
        let postAnnotation = annotation as! PostAnnotation
        imageView.sd_setImageWithURL(NSURL(string:  postAnnotation.post.owner.photo!), placeholderImage: UIImage(named: "avatar"))
    }
    
    func updateBadge() {
        
        let postAnnotation = annotation as! PostAnnotation
        
        if let containedAnnotations = postAnnotation.containedAnnotations {
            
            let count = containedAnnotations.count
            
            if count > 0 {
                numberBadge.text = "\(count + 1)"
                addSubview(numberBadge)
            } else {
                numberBadge.removeFromSuperview()
            }
        }
    }
    
    func updateScale() {
        
        let postAnnotation = annotation as! PostAnnotation
        
        if let containedAnnotations = postAnnotation.containedAnnotations {
            
            let count = containedAnnotations.count
            var exRate = CGFloat(1)
            
            switch count {
            case 1..<10:
                exRate = CGFloat(1.3)
            case 10..<20:
                exRate = CGFloat(1.5)
            case 20..<30:
                exRate = CGFloat(1.7)
            case 30..<40:
                exRate = CGFloat(1.9)
            case 40..<Int.max:
                exRate = CGFloat(2.1)
            default:
                exRate = 1
            }
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.transform = CGAffineTransformMakeScale(exRate, exRate)
            })
        }
    }

}

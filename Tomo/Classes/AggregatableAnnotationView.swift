//
//  AggregatableAnnotationView.swift
//  Tomo
//
//  Created by ebuser on 2015/09/30.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class AggregatableAnnotationView: MKAnnotationView {
    
    var numberBadge: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(annotation: MKAnnotation!, reuseIdentifier: String!) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.canShowCallout = false
        
        numberBadge = UILabel()
        numberBadge.textColor = UIColor.whiteColor()
        numberBadge.textAlignment = NSTextAlignment.Center
        numberBadge.font = UIFont.systemFontOfSize(10)
        numberBadge.clipsToBounds = true
        numberBadge.layer.borderWidth = 1
        numberBadge.layer.borderColor = UIColor.whiteColor().CGColor
        numberBadge.backgroundColor = UIColor.redColor()
    }
    
    func setupDisplay() {
        guard
            let annotation = self.annotation as? AggregatableAnnotation,
            containedAnnotations = annotation.containedAnnotations
            else { return }
        
        let count = containedAnnotations.count
        var exRate = CGFloat(1)
        
        if count > 0 {
            numberBadge.text = "\(count + 1)"
            addSubview(numberBadge)
        } else {
            numberBadge.removeFromSuperview()
        }
        
        switch count {
        case 1..<10:
            exRate = CGFloat(1.2)
        case 10..<20:
            exRate = CGFloat(1.4)
        case 20..<30:
            exRate = CGFloat(1.6)
        case 30..<40:
            exRate = CGFloat(1.8)
        case 40..<Int.max:
            exRate = CGFloat(2.0)
        default:
            exRate = 1
        }
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(exRate, exRate)
        })
    }
    
}
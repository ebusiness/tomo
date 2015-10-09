//
//  StationAnnotationView.swift
//  Tomo
//
//  Created by ebuser on 2015/09/30.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class StationAnnotationView: AggregatableAnnotationView {
    
    var nameLabel: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(annotation: MKAnnotation!, reuseIdentifier: String!) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        
        nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.textAlignment = NSTextAlignment.Center
        nameLabel.font = UIFont.systemFontOfSize(11)
        nameLabel.numberOfLines = 0
        nameLabel.clipsToBounds = true
        nameLabel.layer.borderWidth = 1
        nameLabel.layer.borderColor = Palette.Green.getPrimaryColor().CGColor
        nameLabel.layer.cornerRadius = 5
        
        addSubview(nameLabel)
        
        numberBadge.frame = CGRect(x: 28, y: -8, width: 15, height: 15)
        numberBadge.layer.cornerRadius = numberBadge.frame.width / 2
    }
    
    override func setupDisplay() {
        
        let annotation = self.annotation as! GroupAnnotation
        
        var count = annotation.group.posts!.count
        
        if let containedAnnotations = annotation.containedAnnotations {
            
            count = containedAnnotations.reduce(count, combine: { (initCount, containedAnnotation) -> Int in
                let containedAnnotation = containedAnnotation as! GroupAnnotation
                return initCount + containedAnnotation.group.posts!.count
            })
        }
        
        var exRate = CGFloat(1)
        
        if count > 0 {
            numberBadge.text = "\(count)"
            addSubview(numberBadge)
        } else {
            numberBadge.removeFromSuperview()
        }
        
        switch count {
        case 1..<10:
            exRate = CGFloat(1.0)
        case 10..<20:
            exRate = CGFloat(1.1)
        case 20..<30:
            exRate = CGFloat(1.3)
        case 30..<40:
            exRate = CGFloat(1.5)
        case 40..<Int.max:
            exRate = CGFloat(1.7)
        default:
            exRate = 1
        }
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(exRate, exRate)
        })

        nameLabel.text = annotation.group.name
        
        if let station = annotation.group.station, color = station.color {
            nameLabel.backgroundColor = Util.colorWithHexString(color)
        }
    }
}

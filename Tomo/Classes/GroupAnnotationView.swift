//
//  GroupAnnotationView.swift
//  Tomo
//
//  Created by ebuser on 2015/09/29.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class GroupAnnotationView: AggregatableAnnotationView, UIPageViewControllerDataSource {
    
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
        imageView.layer.borderColor = Palette.Red.getPrimaryColor().CGColor
        imageView.layer.cornerRadius = 5
        addSubview(imageView)
        
        numberBadge.frame = CGRect(x: 28, y: -8, width: 20, height: 20)
        numberBadge.layer.cornerRadius = numberBadge.frame.width / 2
    }
    
    override func setupDisplay() {
        
        super.setupDisplay()
        
        let annotation = self.annotation as! GroupAnnotation
        imageView.sd_setImageWithURL(NSURL(string: annotation.group.cover!), placeholderImage: DefaultGroupImage)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let currentGroup = (viewController as! GroupCallOutViewController).groupAnnotation
        let annotation = self.annotation as! GroupAnnotation
        
        if let containedAnnotations = annotation.containedAnnotations {
            
            if containedAnnotations.count == 0 {
                return nil
            }
            
            let callOutViewController = GroupCallOutViewController(nibName: "GroupCallOutView", bundle: nil)
            
            if let index = containedAnnotations.indexOf(currentGroup) {
                
                if index < containedAnnotations.count - 1 {
                    callOutViewController.groupAnnotation = containedAnnotations.get(index + 1) as! GroupAnnotation
                } else {
                    callOutViewController.groupAnnotation = annotation
                }
                
            } else {
                callOutViewController.groupAnnotation = containedAnnotations.first as! GroupAnnotation
            }
            
            return callOutViewController
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let currentGroup = (viewController as! GroupCallOutViewController).groupAnnotation
        let annotation = self.annotation as! GroupAnnotation
        
        if let containedAnnotations = annotation.containedAnnotations {
            
            if containedAnnotations.count == 0 {
                return nil
            }
            
            let callOutViewController = GroupCallOutViewController(nibName: "GroupCallOutView", bundle: nil)
            
            if let index = containedAnnotations.indexOf(currentGroup) {
                
                if index == 0 {
                    callOutViewController.groupAnnotation = annotation
                } else {
                    callOutViewController.groupAnnotation = annotation.containedAnnotations?.get(index - 1) as! GroupAnnotation
                }
                return callOutViewController
                
            } else {
                callOutViewController.groupAnnotation = containedAnnotations.last as! GroupAnnotation
            }
            
            return callOutViewController
        }
        
        return nil
    }
}

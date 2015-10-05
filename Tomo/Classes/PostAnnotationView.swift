//
//  PostAnnotationView.swift
//  Tomo
//
//  Created by ebuser on 2015/07/29.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class PostAnnotationView: AggregatableAnnotationView, UIPageViewControllerDataSource {
    
    var imageView: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
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
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let currentPost = (viewController as! PostCallOutViewController).postAnnotation
        let annotation = self.annotation as! PostAnnotation
        
        if let containedAnnotations = annotation.containedAnnotations {
            
            if containedAnnotations.count == 0 {
                return nil
            }
            
            let callOutViewController = PostCallOutViewController(nibName: "PostCallOutView", bundle: nil)
            
            if let index = find(containedAnnotations, currentPost) {
                
                if index < containedAnnotations.count - 1 {
                    callOutViewController.postAnnotation = containedAnnotations.get(index + 1) as! PostAnnotation
                } else {
                    callOutViewController.postAnnotation = annotation
                }
                
            } else {
                callOutViewController.postAnnotation = containedAnnotations.first as! PostAnnotation
            }

            return callOutViewController
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let currentPost = (viewController as! PostCallOutViewController).postAnnotation
        let annotation = self.annotation as! PostAnnotation
        
        if let containedAnnotations = annotation.containedAnnotations {
            
            if containedAnnotations.count == 0 {
                return nil
            }
            
            let callOutViewController = PostCallOutViewController(nibName: "PostCallOutView", bundle: nil)
            
            if let index = find(containedAnnotations, currentPost) {
                
                if index == 0 {
                    callOutViewController.postAnnotation = annotation
                } else {
                    callOutViewController.postAnnotation = annotation.containedAnnotations?.get(index - 1) as! PostAnnotation
                }
                return callOutViewController
                
            } else {
                callOutViewController.postAnnotation = containedAnnotations.last as! PostAnnotation
            }
            
            return callOutViewController
        }
        
        return nil
    }
    
//    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
//        
//        let annotation = self.annotation as! AggregatableAnnotation
//        
//        if let containedAnnotations = annotation.containedAnnotations {
//            return containedAnnotations.count + 1
//        } else {
//            return 1
//        }
//    }
//    
//    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
//        
//        let page = pageViewController.viewControllers[0] as! PostCallOutViewController
//        let postAnnotation = page.postAnnotation
//        
//        let annotation = self.annotation as! AggregatableAnnotation
//        
//        if let containedAnnotations = annotation.containedAnnotations {
//            
//            if let index = find(containedAnnotations, postAnnotation) {
//                return index
//            } else {
//                return 0
//            }
//        } else {
//            return 0
//        }
//    }
}

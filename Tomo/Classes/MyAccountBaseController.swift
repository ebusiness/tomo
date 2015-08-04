//
//  MyAccountBaseController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class MyAccountBaseController: BaseTableViewController {
    
    // MARK: - segue for profile header
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let vc = segue.destinationViewController as? MyAccountHeaderViewController{
            
            self.whenShowNavigationBar = { (OffsetY)->() in
                
                self.setNavigationBarBackgroundImage(vc.coverImageView.image)
                
            }
            self.whenHideNavigationBar = { (OffsetY)->() in
                
                vc.photoImageView.constraints().map { (constraint:AnyObject) -> () in
                    
                    if let constraint = constraint as? NSLayoutConstraint
                        where constraint.firstAttribute == .Width || constraint.firstAttribute == .Height
                    {
                        var constant = (1 - (OffsetY / self.headerHeight) ) * 100 //speed
                        if constant > 100 { constant = 100 }
                        else if constant < 60 { constant = 60 }
                        constraint.constant = constant
                        
                        vc.photoImageView.layer.cornerRadius = constant / 2
                    }
                }
                vc.photoImageView.superview?.constraints().map { (constraint:AnyObject) -> () in
                    
                    if let constraint = constraint as? NSLayoutConstraint
                        where constraint.firstAttribute == .CenterY
                    {
                        var constant = OffsetY / self.headerHeight * 100 //speed
                        if constant > 40 { constant = 40 }
                        else if constant < 0 { constant = 0 }
                        constraint.constant = constant
                    }

                }

//                let alpha = OffsetY / self.headerHeight
                self.setNavigationBarBackgroundImage(nil)
                
            }
        }
        
    }
}
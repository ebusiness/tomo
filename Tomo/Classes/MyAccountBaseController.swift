//
//  MyAccountBaseController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class MyAccountBaseController: BaseTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let resizeHeaderHeight:CGFloat = UIScreen.mainScreen().bounds.size.height * 0.618 + 80
        self.headerHeight = resizeHeaderHeight - 80 - 64
        self.changeHeaderView(height: resizeHeaderHeight, done: nil)
    }
    
    // MARK: - segue for profile header
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc = segue.destinationViewController as? MyAccountHeaderViewController else { return }
        
        if let childvcs = self.navigationController?.childViewControllers where childvcs.count > 1 {
            vc.photoImageViewTapped = { (sender)->() in
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
        self.whenShowNavigationBar = { (OffsetY)->() in
            self.setNavigationBarBackgroundImage(vc.coverImageView.image)
        }
        
        let maxHeight: CGFloat = 100
        let speed: CGFloat = 0.5 * maxHeight / (UIScreen.mainScreen().bounds.size.height * 0.618 - 64) //{ return 0.5 * maxHeight / self.headerHeight }
        var photoImageViewConstraints: Dictionary<NSLayoutAttribute, NSLayoutConstraint>?
        
        self.whenHideNavigationBar = { (OffsetY)->() in
            
            if let photoImageView = vc.photoImageView where photoImageViewConstraints == nil {
                photoImageViewConstraints = self.getConstraint(photoImageView)
            }
            
            var constant = OffsetY * speed
            if constant > 40 { constant = 40 }
            else if constant < 0 { constant = 0 }
            
            photoImageViewConstraints?[.CenterY]?.constant = constant
            
            var wh = maxHeight - constant
            if wh > maxHeight { wh = maxHeight }
            //                else if wh < 60 { wh = 60 }
            photoImageViewConstraints?[.Width]?.constant = wh
            photoImageViewConstraints?[.Height]?.constant = wh
            
            vc.photoImageView.layer.cornerRadius = wh / 2
            
            //                let alpha = OffsetY / self.headerHeight
            self.setNavigationBarBackgroundImage(nil)
        }
        
    }
}

// MARK: - private

extension MyAccountBaseController {

    private func getConstraint(photoImageView: UIView) -> Dictionary<NSLayoutAttribute, NSLayoutConstraint>? {
        var constraints = Dictionary<NSLayoutAttribute, NSLayoutConstraint>()
        constraints[.Width] = photoImageView.constraints.find { $0.firstAttribute == .Width }
        constraints[.Height] = photoImageView.constraints.find { $0.firstAttribute == .Height }
        constraints[.CenterY] = photoImageView.superview?.constraints.find { $0.firstAttribute == .CenterY }
        return constraints
    }
}
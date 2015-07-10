//
//  PostToolBarView.swift
//  Tomo
//
//  Created by starboychina on 2015/07/03.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

@objc protocol PostToolBarDelegate {
    optional func cameraOnClick()
    optional func groupOnClick()
    optional func stationOnClick()
}

class PostToolBarView:UIView {
    
    @IBOutlet weak var cameraButton: UIButton!
    
    var delegate:PostToolBarDelegate?
    
    override func awakeFromNib() {
        
        for subview in self.subviews {
            if let btn = subview as? UIButton,image = btn.backgroundImageForState(.Normal) {
                let color = Util.UIColorFromRGB(0xFF007AFF, alpha: 1)
                let image = Util.coloredImage( image, color: color)
                btn.setBackgroundImage(image, forState: .Normal)
            }
        }
    }
    
    @IBAction func cameraOnClick(sender: AnyObject) {
        self.delegate?.cameraOnClick?()
    }
    
    @IBAction func groupOnClick(sender: AnyObject) {
        self.delegate?.groupOnClick?()
    }
    
    @IBAction func stationOnClick(sender: AnyObject) {
        self.delegate?.stationOnClick?()
    }
}

extension PostToolBarView {
    
    func addToSuperView(view :UIView,attr:NSLayoutAttribute){
        view.addSubview(self)
        
        if attr == .Top {
            view.addConstraint(NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0))
        } else {
            view.addConstraint(NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0))
        }
        view.addConstraint(NSLayoutConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))
        
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 44))
        
        
        
    }
}
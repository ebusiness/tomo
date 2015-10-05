//
//  ICYTagButton.swift
//  Tomo
//
//  Created by eagle on 15/10/5.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ICYTagButton: UIButton {
    
    static let font = UIFont.systemFontOfSize(UIFont.systemFontSize())
    
    class func defaultSize(string: String) -> CGSize {
        let size = string.boundingRectWithSize(CGSize(width: 5000, height: 30), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil).size
        return size
    }
    
    var tagString: String? {
        didSet {
            setTitle(tagString, forState: UIControlState.Normal)
        }
    }
    
    var tagClicked: ((tagString: String) ->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTarget(self, action: "buttonClicked", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func buttonClicked() {
        if let tagString = tagString {
            tagClicked?(tagString: tagString)
        }
    }
}

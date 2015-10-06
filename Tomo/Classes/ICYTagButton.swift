//
//  ICYTagButton.swift
//  Tomo
//
//  Created by eagle on 15/10/5.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ICYTagButton: UIButton {
    
    static let font = UIFont.systemFontOfSize(13)
    
    class func defaultSize(string: String) -> CGSize {
        let size = string.boundingRectWithSize(CGSize(width: 5000, height: 24), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil).size
        let expandedSize = CGSizeMake(size.width + 14.0, 24.0)
        return expandedSize
    }
    
    var tagString: String? {
        didSet {
            setTitle(tagString == nil ? nil : " " + tagString! + " ",
                forState: UIControlState.Normal)
        }
    }
    
    var tagClicked: ((tagString: String) ->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addTarget(self, action: "buttonClicked", forControlEvents: UIControlEvents.TouchUpInside)
        backgroundColor = UIColor.whiteColor()
        setTitleColor(Palette.Blue.getPrimaryColor(), forState: UIControlState.Normal)
        layer.cornerRadius = 3.0
        layer.borderColor = Palette.Blue.getPrimaryColor().CGColor
        layer.borderWidth = 1.0
    }
    
    func buttonClicked() {
        if let tagString = tagString {
            tagClicked?(tagString: tagString)
        }
    }
}

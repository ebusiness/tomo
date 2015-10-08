//
//  ICYTagButton.swift
//  Tomo
//
//  Created by eagle on 15/10/5.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ICYTagButton: UIButton {
    
    static let font = UIFont.systemFontOfSize(12)
    
    class func defaultSize(string: String) -> CGSize {
        let size = string.boundingRectWithSize(CGSize(width: 5000, height: 24), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil).size
        let expandedSize = CGSizeMake(size.width + 16.0, size.height + 8.0)
        return expandedSize
    }
    
    /// TOMO Tag!
    var tomoTag: TomoTag? {
        didSet {
            if let tag = tomoTag {
                switch tag.type {
                case .Group:
                    let group = tag.content as! GroupEntity
                    setTitle(group.name, forState: UIControlState.Normal)
                    let size = ICYTagButton.defaultSize(group.name)
                    widthConstraint.constant = size.width
                    heightConstraint.constant = size.height
                }
            } else {
                setTitle(nil, forState: UIControlState.Normal)
            }
        }
    }
    
    typealias tagClickActionType = ((tomoTag: TomoTag) ->())
    
    private var tagClicked: tagClickActionType?
    
    private var widthConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
    
    func setTagClickAction(action: tagClickActionType?) {
        tagClicked = action
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addTarget(self, action: "buttonClicked", forControlEvents: UIControlEvents.TouchUpInside)
        backgroundColor = UIColor.whiteColor()
        setTitleColor(Palette.Blue.getPrimaryColor(), forState: UIControlState.Normal)
        layer.cornerRadius = 3.0
        layer.borderColor = Palette.Blue.getPrimaryColor().CGColor
        layer.borderWidth = 1.0
        
        widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 20.0)
        heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 24.0)
        addConstraints([widthConstraint, heightConstraint])
    }
    
    func buttonClicked() {
        if let tomoTag = tomoTag {
            tagClicked?(tomoTag: tomoTag)
        }
    }
}



class TomoTag {
    enum TomoTagType {
        case Group
    }
    var type: TomoTagType
    var content: AnyObject
    init(content: AnyObject) {
        if let transd = content as? GroupEntity {
            type = .Group
            self.content = transd
        } else {
            fatalError("TAG must init with GroupEntity!")
        }
    }
}

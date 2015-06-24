//
//  tagUIController.swift
//  Tomo
//
//  Created by starboychina on 2015/06/22.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class tagUIController {
    enum tagSize: Int {
        case small,normal
    }
    class var tagColor_normal:UIColor { return  UIColor(red:0.12, green:0.55, blue:0.84, alpha:1) }
    class var innerTagColor_normal:UIColor { return   UIColor(white: 1, alpha: 0.3) }
    class var tagColor_highlight:UIColor { return  UIColor.blueColor() }
    class var innerTagColor_highlight:UIColor { return UIColor.redColor() }
    
    class func serTagView(size:tagSize){
        switch size {
        case .small:
            AMTagView.appearance().tagLength = 5
            AMTagView.appearance().textPadding = 9
            AMTagView.appearance().radius = 2
            AMTagView.appearance().textFont = UIFont(name: "Futura", size: 10)
            break
        case .normal:
            AMTagView.appearance().tagLength = 10
            AMTagView.appearance().textPadding = 14
            AMTagView.appearance().radius = 4
            AMTagView.appearance().textFont = UIFont(name: "Futura", size: 14)
            break
        default:
            break
        }
        AMTagView.appearance().tagColor = tagColor_normal
        AMTagView.appearance().innerTagColor = innerTagColor_normal
    }
}

extension AMTagView{
    func selected(isSelected:Bool){
        if isSelected {
            self.tag = 1
            self.innerTagColor = tagUIController.innerTagColor_highlight
            self.tagColor = tagUIController.tagColor_highlight
        }else{
            self.tag = 0
            self.tagColor = tagUIController.tagColor_normal
            self.innerTagColor = tagUIController.innerTagColor_normal
        }
    }
    func changeStatus(){
        self.selected(self.tag == 0)
    }
}
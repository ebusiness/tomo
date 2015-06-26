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
    class var color_normal:UIColor { return Util.UIColorFromRGB(0x475477, alpha: 0.7) }
    class var color_selected:UIColor { return Util.UIColorFromRGB(0x8FA8EE, alpha: 1) }
    class var color_unselected:UIColor { return UIColor.whiteColor()}
    
    class func serTagView(size:tagSize){
        AMTagView.appearance().textColor = color_normal
        AMTagView.appearance().tagColor = color_normal
        AMTagView.appearance().innerTagColor = color_unselected
        AMTagView.appearance().tagLength = 0
        AMTagView.appearance().textPadding = 7
        AMTagView.appearance().innerTagPadding = 1
        AMTagView.appearance().radius = 2
        var fontSize:CGFloat = size == .small ? 10 : 12
//        switch size {
//        case .small:
//            fontSize = 10
//            break
//        case .normal:
//            break
//        default:
//            break
//        }
        AMTagView.appearance().textFont = UIFont(name: "Helvetica", size: fontSize)
    }
}

extension AMTagView{
    func selected(isSelected:Bool){
        if isSelected {
            self.tag = 1
            self.tagColor = tagUIController.color_selected
            self.innerTagColor = UIColor.clearColor()
        }else{
            self.tag = 0
            self.tagColor = tagUIController.color_normal
            self.innerTagColor = tagUIController.color_unselected
        }
    }
    func changeStatus(){
        self.selected(self.tag == 0)
    }
}
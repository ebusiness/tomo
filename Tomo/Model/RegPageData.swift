//
//  RegPageData.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/01.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class RegPageData: NSObject {
   
    var imageName: String!
    var iconName: String?
    var textA: String?
    var textB: String?
    
    init(dic: NSDictionary) {
        self.imageName = dic["imageName"] as String
        self.iconName = dic["iconName"] as? String
        self.textA = dic["textA"] as? String
        self.textB = dic["textB"] as? String
    }
}

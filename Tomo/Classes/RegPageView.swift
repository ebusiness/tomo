//
//  RegPageView.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/01.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class RegPageView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelA: UILabel!
    @IBOutlet weak var labelB: UILabel!

    var regPageData: RegPageData! {
        didSet {
            if let iconName = regPageData.iconName {
                imageView.image = UIImage(named: iconName)
            }
            
            labelA.text = regPageData.textA
            labelB.text = regPageData.textB
        }
    }

}

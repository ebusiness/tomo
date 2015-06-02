//
//  CommonSwitch.swift
//  Tomo
//
//  Created by starboychina on 2015/06/02.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class CommonSwitch: UISwitch {
    typealias Handler = () -> ()
    var whenOn:Handler?
    var whenOff:Handler?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("switchFlipped"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        self.switchFlipped()
        self.addTarget(self, action: Selector("switchFlipped"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func switchFlipped(){
        //println(self.on)
        if self.on {
            self.whenOn?()
        }else{
            self.whenOff?()
        }
    }
}
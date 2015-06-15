//
//  TagSettingController.swift
//  Tomo
//
//  Created by starboychina on 2015/06/15.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class TagSettingController: UIViewController {
    
    var submitHandler:(() -> ())?
    
    // create instance of our custom transition manager
    let transitionManager = TransitionManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.transitioningDelegate = transitionManager
        
    }
    
    @IBAction func submit(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.submitHandler?()
        })
    }
    
}


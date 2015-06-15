//
//  TagListController.swift
//  Tomo
//
//  Created by starboychina on 2015/06/15.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class TagListController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!

    override func viewDidLoad() {
        closeButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
    }

    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }

    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
}

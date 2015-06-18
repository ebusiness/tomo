//
//  TagSettingController.swift
//  Tomo
//
//  Created by starboychina on 2015/06/15.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class TagSettingController: UIViewController,UIViewControllerTransitioningDelegate {
    
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

    
    var center :CGPoint!
    @IBAction func tappedBtn(sender: AnyObject) {
        center = (sender as! UIButton).superview?.center        
        self.performSegueWithIdentifier("taglist", sender: sender)
    }
    
    let transition = BubbleTransition()
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? TagListController {
            controller.transitioningDelegate = self
            controller.modalPresentationStyle = .Custom
            if let tag = sender?.tag {
                controller.sendertag = tag
            }
        }
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    override func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Present
        transition.startingPoint = center
        transition.bubbleColor = UIColor.whiteColor()// self.view.backgroundColor!
        return transition
    }
    
    override func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Dismiss
        transition.startingPoint = center
        transition.bubbleColor = UIColor.whiteColor()// self.view.backgroundColor!
        return transition
    }
}


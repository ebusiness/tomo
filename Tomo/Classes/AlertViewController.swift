//
//  AlertViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/05/19.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//


import UIKit

class AlertOKViewController: BaseViewController {//AlertView
    
    @IBOutlet weak var content: UILabel!
    
    var contentTemp: String = ""
    
    var okAction: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.content.text = contentTemp
        self.content.sizeToFit()
        self.formSheetController.presentedFormSheetSize = CGSizeMake(300, 30 + 20 + 44 + 30 + self.content.frame.size.height );
    }
    
    func show(vc:UIViewController,content:String,action:(() -> ())? = { () -> () in }){
        contentTemp = content
        self.okAction = action
        Util.showActionSheet(vc, vc: self,style:MZFormSheetTransitionStyle.SlideFromBottom)
    }
    
    @IBAction func confirmTappen(sender: AnyObject) {
        self.dismiss(true)
        self.okAction?()
    }
    func dismiss(animated: Bool) {
        self.mz_dismissFormSheetControllerAnimated(animated, completionHandler: { (formSheet) -> Void in
            
        })
    }
}
/*
let acvc = Util.createViewControllerWithIdentifier("AlertView", storyboardName: "ActionSheet") as! AlertOKViewController

acvc.show(self, content: "content？", action: { () -> () in
    println("okokok")
})
acvc.show(self, content: "content？")
*/
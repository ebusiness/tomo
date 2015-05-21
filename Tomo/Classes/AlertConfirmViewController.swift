//
//  AlertConfirmViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/05/19.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//


import UIKit

class AlertConfirmViewController: BaseViewController {//AlertConfirmView
    
    @IBOutlet weak var content: UILabel!
    
    var contentTemp: String = ""
    
    var confirmAction: (() -> ())!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.content.text = contentTemp
        self.content.sizeToFit()
        self.formSheetController.presentedFormSheetSize = CGSizeMake(300, 30 + 20 + 44 + 30 + self.content.frame.size.height );
    }
    
    func show(vc:UIViewController,content:String,action:(() -> ())){
        contentTemp = content
        self.confirmAction = action
        Util.showActionSheet(vc, vc: self,style:MZFormSheetTransitionStyle.SlideFromBottom)
    }
    
    @IBAction func closeTappen(sender: AnyObject) {
        self.dismiss(true)
    }
    
    @IBAction func confirmTappen(sender: AnyObject) {
        self.dismiss(true)
        self.confirmAction()
    }
    func dismiss(animated: Bool) {
        self.mz_dismissFormSheetControllerAnimated(animated, completionHandler: { (formSheet) -> Void in
            
        })
    }
}
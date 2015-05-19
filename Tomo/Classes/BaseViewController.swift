//
//  BaseViewController.swift
//  spot
//
//  Created by 張志華 on 2015/02/04.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        println("[\(String.fromCString(object_getClassName(self))!)][\(__LINE__)][\(__FUNCTION__)]")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        println("[\(String.fromCString(object_getClassName(self))!)][\(__LINE__)][\(__FUNCTION__)]")
        
        #if DEBUG
            Util.showInfo("メモリー不足")
        #endif
    }
    
    func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    deinit {
        println("[\(String.fromCString(object_getClassName(self))!)][\(__LINE__)][\(__FUNCTION__)]")
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
extension BaseViewController {
    //ActionSheet
    func showActionSheet(vc: UIViewController,style:MZFormSheetTransitionStyle = MZFormSheetTransitionStyle.DropDown){
        let formSheet = MZFormSheetController(viewController: vc)
        //formSheet.presentedFormSheetSize = CGSizeMake(300, 298);
        formSheet.transitionStyle = style;
        formSheet.shadowRadius = 2.0;
        formSheet.shadowOpacity = 0.3;
        formSheet.shouldDismissOnBackgroundViewTap = true;
        formSheet.shouldCenterVertically = true;
        formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppears.MoveToTopInset;
        formSheet.landscapeTopInset = 50;
        formSheet.portraitTopInset = 100;
        
        formSheet.shouldDismissOnBackgroundViewTap = true;
        
        
        self.mz_presentFormSheetController(formSheet, animated: true) { (s) -> Void in
            
        }
    }
}
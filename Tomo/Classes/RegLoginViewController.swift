//
//  RegLoginViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/02.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class RegLoginViewController: BaseViewController {

    @IBOutlet weak var mailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let mailSpacerView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        mailTF.leftViewMode = .Always
        mailTF.leftView = mailSpacerView
        
        let passwordSpacerView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        passwordTF.leftViewMode = .Always
        passwordTF.leftView = passwordSpacerView
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        mailTF.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Action
    
    @IBAction func close(sender: AnyObject) {
        mailTF.resignFirstResponder()
        passwordTF.resignFirstResponder()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func login(sender: AnyObject) {
        SVProgressHUD.showWithMaskType(.Clear)
        
        ApiController.login(email: mailTF.text, password: passwordTF.text) { (error) -> Void in
            assert(NSThread.currentThread().isMainThread, "not main thread")
            
            if let error = error {
                Util.showError(error)
                return
            }
            
            println("OK")
            SVProgressHUD.dismiss()
            
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let newsfeed = Util.createViewControllerWithIdentifier(nil, storyboardName: "Newsfeed")
            
            UIView.transitionWithView(appDelegate.window!, duration: 0.4, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.dismissViewControllerAnimated(false, completion: { () -> Void in
                    appDelegate.window!.rootViewController = newsfeed
                })
//                self.dismissViewControllerAnimated(false, completion: nil)
                
                
                }, completion: nil)
            
//            self.dismissViewControllerAnimated(false, completion: { () -> Void in
            
            
//                let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
//                let newsfeed = Util.createViewControllerWithIdentifier(nil, storyboardName: "Newsfeed")
//                
//                UIView.transitionWithView(appDelegate.window!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
//                    appDelegate.window!.rootViewController = newsfeed
//
//                }, completion: nil)
//            })
//            
//            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
//            let newsfeed = Util.createViewControllerWithIdentifier(nil, storyboardName: "Newsfeed")
//            
//            UIView.transitionWithView(appDelegate.window!, duration: 4.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
//                appDelegate.window!.rootViewController = newsfeed
//                
//                }, completion: nil)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UITextFieldDelegate

extension RegLoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == mailTF {
            passwordTF.becomeFirstResponder()
        }
        
        if textField == passwordTF {
            login(textField)
        }
        
        return true
    }
}


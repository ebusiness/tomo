//
//  TextFieldInputViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/20.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class TextFieldInputViewController: UITableViewController {

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action
    
    @IBAction func save(sender: AnyObject) {
//        let str = nameTF.text.trimmed()
//        if str.length == 0 {
//            SVProgressHUD.showInfoWithStatus("入力エラー")
//            return
//        }
//        
//        if str != user.displayName {
//            user.displayName = str
//            UserController.saveUserAndWait(user)
//            XMPPManager.updateUser(user)
//            ParseController.updateUser(user, done: nil)
//        }
//        
//        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
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

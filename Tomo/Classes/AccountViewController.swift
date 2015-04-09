//
//  AccountViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/08.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {

    var editVC: AccountEditViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "SegueEditVC" {
//            editVC = segue.destinationViewController as? AccountEditViewController
//            editVC?.user = DBController.myUser()
//        }
    }

}

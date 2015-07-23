//
//  MyAccountBaseController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class MyAccountBaseController: BaseTableViewController {
    
    // MARK: - segue for pofile header
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let vc = segue.destinationViewController as? MyAccountHeaderViewController{
            vc.user = DBController.myUser()
        }
        
    }
}
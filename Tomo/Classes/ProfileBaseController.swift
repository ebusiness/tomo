//
//  ProfileBaseController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ProfileBaseController: BaseTableViewController {
    
    var user:User!
    
    // MARK: - segue for pofile header
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let vc = segue.destinationViewController as? ProfileHeaderViewController {
            vc.user = self.user
        } else if let vc = segue.destinationViewController as? ProfileBaseController {
            vc.user = self.user
        }
        
    }
}
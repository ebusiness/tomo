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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer.delegate = self
        
    }
    // MARK: - segue for pofile header
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let vc = segue.destinationViewController as? ProfileHeaderViewController {
            vc.user = self.user
        } else if let vc = segue.destinationViewController as? ProfileBaseController {
            vc.user = self.user
        }
        
    }
}

extension ProfileBaseController : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer.self)
    }
}
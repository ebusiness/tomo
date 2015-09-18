//
//  GroupDetailViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/09/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class GroupDetailViewController: BaseTableViewController {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var joinButton: UIButton!
    
    var group: GroupEntity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - Internal Methods

extension GroupDetailViewController {
    
    private func updateUI() {
        self.title = group.name
        self.coverImageView.sd_setImageWithURL(NSURL(string: group.cover), placeholderImage: DefaultGroupImage)
    }
}

// MARK: - Actions

extension GroupDetailViewController {
    
    @IBAction func joinGroup(sender: UIButton) {
        
        sender.userInteractionEnabled = false
        AlamofireController.request(.PATCH, "/groups/\(self.group.id)/join", success: { _ in
            
        }) { err in
            sender.userInteractionEnabled = true
        }
    }
}

// MARK: - Navigation

extension GroupDetailViewController {
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
}

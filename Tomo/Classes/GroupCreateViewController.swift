//
//  GroupCreateViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/09/11.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class GroupCreateViewController: BaseTableViewController {

    @IBOutlet var groupNameTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var stationTextField: UITextField!
    @IBOutlet var introductionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

// MARK: - Actions

extension GroupCreateViewController {
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func create(sender: AnyObject) {
        
        var param = Dictionary<String, AnyObject>()
        
        param["name"] = self.groupNameTextField.text
        param["introduction"] = self.introductionTextField.text
        param["address"] = self.addressTextField.text
        param["station"] = self.stationTextField.text
        
        AlamofireController.request(.POST, "/groups", parameters: param, encoding: .JSON, success: { group in
            self.performSegueWithIdentifier("groupCreated", sender: group)
        }) { err in
            
        }
    }
}


// MARK: - UITableView DataSorce

extension GroupCreateViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        if section == 0 {
            return 4
        } else if section == 1 {
            return 1
        } else {
            return 0
        }
    }
}

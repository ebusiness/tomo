//
//  PickerTableViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/08/04.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class PickerTableViewController: BaseTableViewController {
    
    var pickerData:[String]!
    var selected:String?
    var didSelected: ((selected:String) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.alwaysShowNavigationBar = true
    }
}


extension PickerTableViewController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pickerData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let label = self.pickerData[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.accessoryType = .None
        if self.selected == label {
            cell.accessoryType = .Checkmark
        }
        cell.textLabel?.text = label
        return cell
    }
}

extension PickerTableViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.selected = self.pickerData[indexPath.row]
        self.tableView.reloadData()
        
        self.didSelected(selected: self.pickerData[indexPath.row])
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
}
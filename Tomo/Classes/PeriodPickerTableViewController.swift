//
//  PeriodPickerTableViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/10/06.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

enum Duration: String {
    case today = "today"
    case thisWeek = "thisWeek"
    case thisMonth = "thisMonth"
}

protocol DurationPickerTableViewControllerDelegate {
    func durationPicker(didSelectWith duration: Duration)
}

class DurationPickerTableViewController: UITableViewController {
    
    var delegate: DurationPickerTableViewControllerDelegate?

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var duration: Duration
        
        switch indexPath.item {
        case 0:
            duration = .today
        case 1:
            duration = .thisWeek
        case 2:
            duration = .thisMonth
        default:
            duration = .today
        }
        
        delegate?.durationPicker(didSelectWith: duration)
        dismissViewControllerAnimated(true, completion: nil)
    }

}

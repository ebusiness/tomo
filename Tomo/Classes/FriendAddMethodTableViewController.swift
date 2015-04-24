//
//  FriendAddMethodTableViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/22.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class FriendAddMethodTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SegueSearchInput" {
            let indexPath = tableView.indexPathForCell((sender as? UITableViewCell)!)!
            let vc = segue.destinationViewController as! SearchInputViewController
            vc.searchType = SearchType.searchTypes[indexPath.row]
        }
    }
    
    // MARK: - UITableView
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let vc = Util.createViewControllerWithIdentifier("StationSelectViewController", storyboardName: "Account") as! StationSelectViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

}

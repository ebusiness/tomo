//
//  FriendAddMethodTableViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/22.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class FriendAddMethodTableViewController: BaseTableViewController {

    @IBOutlet weak var tomoidCell: UITableViewCell!
    @IBOutlet weak var stationCell: UITableViewCell!
    @IBOutlet weak var discoverCell: UITableViewCell!
    
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
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if  cell == stationCell {
            let vc = StationTableViewController()
            vc.displayMode = .FriendAddSelect
            self.navigationController?.pushViewController(vc, animated: true)
        }else if cell == discoverCell {
            Util.showHUD()
            ApiController.getUsers({ (users, error) -> Void in
                Util.dismissHUD()
                if let users = users {
                    let vc = Util.createViewControllerWithIdentifier("FriendListViewController", storyboardName: "Chat") as! FriendListViewController
                    vc.displayMode = .SearchResult
                    vc.users = users
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    //没有匹配的人.....
                }
            })
        }
    }

}

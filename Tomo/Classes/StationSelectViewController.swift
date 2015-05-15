//
//  StationSelectViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/23.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class StationSelectViewController: StationTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        ApiController.getStations { (error) -> Void in
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        Util.dismissHUD()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StationCell", forIndexPath: indexPath) as! UITableViewCell
        
        let station = frc.objectAtIndexPath(indexPath) as! Station
        
        cell.textLabel?.text = station.name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let station = frc.objectAtIndexPath(indexPath) as! Station
        
        Util.showHUD(maskType: .None)
        
        ApiController.getUsers(key: SearchType.Station.searchKey(), value: station.name!, done: { (users, error) -> Void in
            if let users = users {
                if users.count > 0 {
                    let vc = Util.createViewControllerWithIdentifier("FriendListViewController", storyboardName: "Chat") as! FriendListViewController
                    vc.displayMode = .SearchResult
                    vc.users = users
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                }
            }
            
            Util.showInfo("見つかりませんでした。")
        })

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

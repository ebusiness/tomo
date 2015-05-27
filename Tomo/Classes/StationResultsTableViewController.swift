//
//  StationResultsTableViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/05/27.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class StationResultsTableViewController: BaseTableViewController {

    var stations = [Station]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "StationCell")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StationCell", forIndexPath: indexPath) as! UITableViewCell
        
        let station = stations[indexPath.row]
        
        cell.textLabel?.text = station.name
        
        //        if selectedIndex == indexPath {
        //            cell.accessoryType = .Checkmark
        //        } else {
        //            cell.accessoryType = .None
        //        }
        
        return cell
    }

}

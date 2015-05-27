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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("StationCell") as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "StationCell")
        }
        
        let station = stations[indexPath.row]
        
        cell!.textLabel?.text = station.name
        cell!.detailTextLabel?.text = station.pref_name
        
        cell!.detailTextLabel?.textColor = UIColor.lightGrayColor()
        
        return cell!
    }

}

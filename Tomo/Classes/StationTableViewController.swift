//
//  StationTableViewController.swift
//  spot
//
//  Created by 張志華 on 2015/03/06.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

enum StationTableDisplayMode {
    case Account, SearchCondition, SelectionOnly
}

class StationTableViewController: BaseTableViewController {
    
    var displayMode = StationTableDisplayMode.Account
    
    var stations = [Station]()
    var selectedStation: Station?

    var resultVC: StationResultsTableViewController!
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if displayMode == .SelectionOnly {
            return
        }
        
        resultVC = StationResultsTableViewController()
        searchController = UISearchController(searchResultsController: resultVC)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        
        resultVC.tableView.delegate = self
        
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        definesPresentationContext = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if displayMode == .SelectionOnly {
            return
        }
        
        ApiController.getStationsHot { (result, error) -> Void in
            if let result = result {
                self.stations = result
                self.tableView.reloadData()
            }
        }
    }
    
}

// MARK: - UITableView

extension StationTableViewController: UITableViewDataSource, UITableViewDelegate {
  
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        selectedStation = tableView == self.tableView ? stations[indexPath.row] : resultVC.stations[indexPath.row]

        if displayMode == .Account || displayMode == .SelectionOnly {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell?
            cell?.accessoryType = .Checkmark
            
            gcd.async(.Main, delay: 0.3) { () -> () in
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
        if displayMode == .SearchCondition {
            Util.showHUD(maskType: .None)
    
            ApiController.getUsers(key: SearchType.Station.searchKey(), value: selectedStation!.name!, done: { (users, error) -> Void in
                if let users = users {
                    if users.count > 0 {
                        let vc = Util.createViewControllerWithIdentifier("FriendListViewController", storyboardName: "Chat") as! FriendListViewController
                        vc.displayMode = .SearchResult
                        vc.users = users
                        
                        Util.dismissHUD()
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                        return
                    }
                }
                
                Util.showInfo("見つかりませんでした。")
            })
        }
    }
}

// MARK: - UISearchBarDelegate

extension StationTableViewController: UISearchBarDelegate {
    
    
}

// MARK: - UISearchControllerDelegate

extension StationTableViewController: UISearchControllerDelegate {
    
}

// MARK: - UISearchResultsUpdating

extension StationTableViewController: UISearchResultsUpdating {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        var searchText = searchController.searchBar.text
        searchText = searchText.trimmed()
        
        if searchText.length > 0 {
            ApiController.getStations(name: ".*\(searchText).*", done: { (result, error) -> Void in
                if let result = result {
                    self.resultVC.stations = result
                    self.resultVC.tableView.reloadData()
                }
            })
        }
    }
}



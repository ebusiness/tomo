//
//  StationTableViewController.swift
//  spot
//
//  Created by 張志華 on 2015/03/06.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

enum StationTableDisplayMode {
    case Account //account edit
    case FriendAddSelect //search condition of friend add, go to FriendList after click
    case MyStationOnly //used by adding new post, no searchbar, back after click
    case SingleSelection //userd by adding new group, back after click
}

class StationTableViewController: BaseTableViewController {
    
    var displayMode = StationTableDisplayMode.Account
    
    var stations = [Station]()
    var hotStations = [Station]()
    var myStations = [Station]()
    var selectedStations = [Station]()

    var selectedStation: Station?
    
    var resultVC: StationResultsTableViewController!
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myStations = DBController.myStations()
        selectedStations = myStations
        
        if displayMode == .MyStationOnly {
            stations = myStations
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
        
        if displayMode == .MyStationOnly {
            return
        }
        
        ApiController.getStationsHot { (result, error) -> Void in
            if let result = result {
                self.hotStations = result
                self.updateUI()
            }
        }
    }
 
    private func mergeStations() {
        stations = selectedStations.union(myStations)
        stations = stations.union(hotStations)
    }
    
    private func updateUI() {
        mergeStations()
        tableView.reloadData()
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

        if displayMode == .Account {
            if selectedStations.contains(station) {
                cell!.accessoryType = .Checkmark
            } else {
                cell!.accessoryType = .None
            }
        }
        
        if hotStations.contains(station) {
            cell!.imageView!.image = UIImage(named: "hot-icon")
        } else {
            cell!.imageView!.image = nil
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        selectedStation = tableView == self.tableView ? stations[indexPath.row] : resultVC.stations[indexPath.row]
        let cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell?

        if displayMode == .MyStationOnly || displayMode == .SingleSelection {
            cell?.accessoryType = .Checkmark
            
            gcd.async(.Main, delay: 0.3) { () -> () in
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
        if displayMode == .FriendAddSelect {
            Util.showHUD(maskType: .None)
    
            ApiController.getUsers(key: SearchType.Station.searchKey(), value: selectedStation!.id!, done: { (users, error) -> Void in
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
        
        if displayMode == .Account {
            if selectedStations.contains(selectedStation!) {
                cell!.accessoryType = .None
                selectedStations.remove(selectedStation!)
            } else {
                cell!.accessoryType = .Checkmark
                selectedStations.insert(selectedStation!, atIndex: 0)
            }
            
            if tableView != self.tableView {
                searchController.active = false
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension StationTableViewController: UISearchBarDelegate {
    
}

// MARK: - UISearchControllerDelegate

extension StationTableViewController: UISearchControllerDelegate {
    
    func didDismissSearchController(searchController: UISearchController) {
        updateUI()
    }
    
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
                    self.resultVC.selectedStations = self.selectedStations
                    self.resultVC.tableView.reloadData()
                }
            })
        }
    }
}



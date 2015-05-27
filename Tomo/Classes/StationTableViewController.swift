//
//  StationTableViewController.swift
//  spot
//
//  Created by 張志華 on 2015/03/06.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

class StationTableViewController: BaseTableViewController {
    
    var stations = [Station]()
    var selectedStation: Station?

    var resultVC: StationResultsTableViewController!
    var searchController: UISearchController!
    
//    var selectedIndex: NSIndexPath? {
//        get {
//            if let selectedStation = selectedStation {
//                return frc.indexPathForObject(selectedStation)
//            }
//            
//            return nil
//        }
//        
//        set(newValue) {
//            if let newValue = newValue {
//                selectedStation = frc.objectAtIndexPath(newValue) as? Station
//            }
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "StationCell")
//        frc = DBController.stations()
//        frc.delegate = self
//        
//        scrollToSelectStation()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ApiController.getStationsHot { (result, error) -> Void in
            if let result = result {
                self.stations = result
                self.tableView.reloadData()
            }
        }
    }
//    func scrollToSelectStation() {
//        if let selectedStation = selectedStation, selectedIndex = selectedIndex {
//            tableView.scrollToRowAtIndexPath(selectedIndex, atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
//        }
//    }

}

// MARK: - UITableView

extension StationTableViewController: UITableViewDataSource, UITableViewDelegate {
  
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        selectedStation = tableView == self.tableView ? stations[indexPath.row] : resultVC.stations[indexPath.row]

        let cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell?
        cell?.accessoryType = .Checkmark
        
        gcd.async(.Main, delay: 0.3) { () -> () in
            self.navigationController?.popViewControllerAnimated(true)
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



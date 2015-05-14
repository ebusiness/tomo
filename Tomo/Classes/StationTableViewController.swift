//
//  StationTableViewController.swift
//  spot
//
//  Created by 張志華 on 2015/03/06.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

class StationTableViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var frc: NSFetchedResultsController!

    var count: Int! {
        return frc.fetchedObjects?.count ?? 0
    }
    
    var selectedStation: Station?

    var selectedIndex: NSIndexPath? {
        get {
            if let selectedStation = selectedStation {
                return frc.indexPathForObject(selectedStation)
            }
            
            return nil
        }
        
        set(newValue) {
            if let newValue = newValue {
                selectedStation = frc.objectAtIndexPath(newValue) as? Station
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        frc = DBController.stations()
        frc.delegate = self
        
        scrollToSelectStation()
    }
    
    func scrollToSelectStation() {
        if let selectedStation = selectedStation, selectedIndex = selectedIndex {
            tableView.scrollToRowAtIndexPath(selectedIndex, atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
        }
    }

}

// MARK: - UITableView

extension StationTableViewController: UITableViewDataSource, UITableViewDelegate {
  
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StationCell", forIndexPath: indexPath) as! UITableViewCell
        
        let station = frc.objectAtIndexPath(indexPath) as! Station
        
        cell.textLabel?.text = station.name
        
        if selectedIndex == indexPath {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let station = frc.objectAtIndexPath(indexPath) as! Station
        
        if let selectedIndex = selectedIndex {
            let cell = tableView.cellForRowAtIndexPath(selectedIndex) as UITableViewCell?
            cell?.accessoryType = .None
        }
        
        selectedIndex = indexPath
        let cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell?
        cell?.accessoryType = .Checkmark
        
        gcd.async(.Main, delay: 0.3) { () -> () in
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension StationTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
}


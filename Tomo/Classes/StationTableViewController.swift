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

    var count: Int {
        return (frc.sections as! [NSFetchedResultsSectionInfo])[0].numberOfObjects
    }
    
    var user: User!
    
    var selectedIndex: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        frc = DBController.stations()
        frc.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollToMyStation()
        
        ApiController.getStations { (error) -> Void in
            if self.selectedIndex == nil {
                self.scrollToMyStation()
            }
        }
    }
    
    func scrollToMyStation() {
        if let name = user.nearestSt {
            if let station = DBController.stationByName(name) {
                selectedIndex = frc.indexPathForObject(station)
                
                tableView.scrollToRowAtIndexPath(selectedIndex!, atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let selectedIndex = selectedIndex {
            let station = frc.objectAtIndexPath(selectedIndex) as! Station
            user.nearestSt = station.name
        } else {
            user.nearestSt = nil
        }
        
        DBController.save()
        ApiController.editUser(user, done: { (error) -> Void in
            
        })
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
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension StationTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
}


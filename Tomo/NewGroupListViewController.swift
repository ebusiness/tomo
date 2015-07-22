//
//  NewGroupListViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/16.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class NewGroupListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var frc: NSFetchedResultsController!

    override func viewDidLoad() {
        super.viewDidLoad()

        frc = DBController.groups(nil, onlyMe: false)
        frc.delegate = self
        
        var error: NSError?
        
        if !frc.performFetch(&error) {
            println("!frc.performFetch(&error)")
        }
        
        ApiController.getGroups { (error) -> Void in
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configCell(cell: GroupCell?, indexPath: NSIndexPath) {
        if let cell = cell {
            let group = frc.objectAtIndexPath(indexPath) as! Group
            cell.group = group
//            cell.delegate = self
        }
    }

}

// MARK: - Navigation
extension NewGroupListViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "GroupDetail" {
            
            let groupDetailController = segue.destinationViewController as! NewGroupDetailViewController
            
            groupDetailController.group = sender as? Group
        }
    }
}

// MARK: - Table view data source

extension NewGroupListViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var sections = frc.sections as! [NSFetchedResultsSectionInfo]
        
        if sections.count > 0 {
            return sections[0].numberOfObjects
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NewGroupCell", forIndexPath: indexPath) as! NewGroupCell
        
        cell.group = frc.objectAtIndexPath(indexPath) as! Group
        cell.setupDisplay()
        
        return cell
    }
}

extension NewGroupListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 132
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let group = frc.objectAtIndexPath(indexPath) as! Group
        performSegueWithIdentifier("GroupDetail", sender: group)
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate

extension NewGroupListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move:
            println("move")
        case .Update:
            println("update")
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        case .Update:
            if let indexPath = indexPath {
                configCell(tableView.cellForRowAtIndexPath(indexPath) as? GroupCell, indexPath: indexPath)
            }
        case .Move:
            if let indexPath = indexPath, newIndexPath = newIndexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
        //        tableView.reloadData()
    }
}

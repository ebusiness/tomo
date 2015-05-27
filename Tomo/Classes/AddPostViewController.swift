//
//  AddPostViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/06.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class AddPostViewController: BaseTableViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var image: UIImage! {
        get {
            return UIImage(contentsOfFile: imagePath)
        }
    }
    
    var imagePath: String!
    
    var content: String?
    
    var selectedIndexPath = NSIndexPath(forRow: 0, inSection: 1)
    let groupIndexPath = NSIndexPath(forRow: 1, inSection: 1)
    let stationIndexPath = NSIndexPath(forRow: 2, inSection: 1)
    
    var groupListVC: GroupListViewController?
    var stationListVC: StationTableViewController?
    
    var selectedGroup: Group?
    var selectedStation: Station?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
        
        self.navigationItem.rightBarButtonItem?.enabled = false
    }
    
    func setTitleOfCellAtIndexPath(indexPath: NSIndexPath, title: String?) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! RadioButtonCell
        cell.titleLabel.text = title
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let groupListVC = groupListVC, selectedGroup = groupListVC.selectedGroup {
            checkRowAtIndexPath(groupIndexPath)
            setTitleOfCellAtIndexPath(groupIndexPath, title: selectedGroup.name)
            setTitleOfCellAtIndexPath(stationIndexPath, title: nil)
            
            self.selectedGroup = selectedGroup
            self.selectedStation = nil
            
            self.groupListVC = nil
            
            return
        }
        
        if let stationListVC = stationListVC, selectedStation = stationListVC.selectedStation {
            checkRowAtIndexPath(stationIndexPath)
            setTitleOfCellAtIndexPath(stationIndexPath, title: selectedStation.name)
            setTitleOfCellAtIndexPath(groupIndexPath, title: nil)
            
            self.selectedStation = selectedStation
            self.selectedGroup = nil
            
            self.stationListVC = nil
            
            return
        }
        
        setTitleOfCellAtIndexPath(groupIndexPath, title: nil)
        setTitleOfCellAtIndexPath(stationIndexPath, title: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                checkRowAtIndexPath(indexPath)
                
                setTitleOfCellAtIndexPath(groupIndexPath, title: nil)
                setTitleOfCellAtIndexPath(stationIndexPath, title: nil)
                
                selectedGroup = nil
                selectedStation = nil
            }
            
            //group
            if indexPath.row == 1 {
                groupListVC = Util.createViewControllerWithIdentifier("GroupListViewController", storyboardName: "Group") as? GroupListViewController
                groupListVC!.showMyGroupOnly = true
                groupListVC!.selectedGroup = selectedGroup
                
                navigationController?.pushViewController(groupListVC!, animated: true)
            }
            
            //station
            if indexPath.row == 2 {
                stationListVC = StationTableViewController()
                stationListVC?.stations = DBController.myUser()?.stations.array as! [Station]
                stationListVC?.displayMode = .SelectionOnly
                
                navigationController?.pushViewController(stationListVC!, animated: true)
            }
        }
    }
    
    func checkRowAtIndexPath(indexPath: NSIndexPath) {
        if indexPath == selectedIndexPath {
            return
        }
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! RadioButtonCell
        cell.check()
        
        let preSelectedCell = tableView.cellForRowAtIndexPath(selectedIndexPath) as! RadioButtonCell
        preSelectedCell.unCheck()
        
        selectedIndexPath = indexPath
    }
    
    // MARK: - Action
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func send(sender: AnyObject) {
        let name = NSUUID().UUIDString
        
        let remotePath = Constants.postPath(fileName: name)
        
        S3Controller.uploadFile(name: name, localPath: imagePath, remotePath: remotePath, done: { (error) -> Void in
            println(error)
            println("done")
            
            if error == nil {
                ApiController.addPost([name], sizes: [self.image.size], content: self.textView.text, groupId: self.selectedGroup?.id, stationId: self.selectedStation?.id, done: { (error) -> Void in
                    println(error)
                })
            }
        })
        
        self.dismissViewControllerAnimated(true, completion: nil)
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

extension AddPostViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        if content == nil || content!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        content = textView.text
        
        if content != nil && content!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            self.navigationItem.rightBarButtonItem?.enabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
    }
}

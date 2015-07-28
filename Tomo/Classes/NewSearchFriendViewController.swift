//
//  NewSearchFriendViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class NewSearchFriendViewController: BaseTableViewController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var closeButton: UIButton!
    
    var result = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Util.changeImageColorForButton(closeButton,color: UIColor.whiteColor())

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("resultCell", forIndexPath: indexPath) as! UITableViewCell
        var user = result[indexPath.row]
        
        cell.textLabel?.text = user.nickName
        
        if let photo_ref = user.photo_ref {
            cell.imageView?.sd_setImageWithURL(NSURL(string: photo_ref), placeholderImage: DefaultAvatarImage)
 
            cell.imageView?.layer.cornerRadius = cell.imageView!.layer.bounds.width / 2
            cell.imageView?.layer.masksToBounds = true
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
        vc.user = result[indexPath.row]
//        vc.readOnlyMode = true
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension NewSearchFriendViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        if searchBar.text.length > 0 {
            
            ApiController.getUsers(key: "tomoid", value: searchBar.text, done: { (users, error) -> Void in
                
                if let users = users {
                    if users.count > 0 {
                        self.result = users
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    
}

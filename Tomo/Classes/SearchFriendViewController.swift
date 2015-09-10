//
//  SearchFriendViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class SearchFriendViewController: BaseTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var closeButton: UIButton!
    
    var result:[UserEntity]?{
        didSet{
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Util.changeImageColorForButton(closeButton,color: UIColor.whiteColor())
        self.searchBar.becomeFirstResponder()
    }

    @IBAction func close(sender: AnyObject) {
        self.view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - Table view data source

extension SearchFriendViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.result?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchFriendCell", forIndexPath: indexPath) as! SearchFriendCell
        var user = self.result![indexPath.row]
        
        cell.user = self.result![indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
        vc.user = self.result![indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension SearchFriendViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        if searchBar.text.trimmed().length > 0 {
            
            self.searchBar.resignFirstResponder()
            var param = Dictionary<String, String>()
            param["nickName"] = ".*?\(searchBar.text).*"
            
            AlamofireController.request(.GET, "/users", parameters: param, success: { results in
                
                self.result = UserEntity.collection(results)
                
            }) { err in
                
            }
        }
    }
    
}

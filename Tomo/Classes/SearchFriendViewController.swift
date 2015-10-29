//
//  SearchFriendViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class SearchFriendViewController: BaseTableViewController {
    
    
    var result:[UserEntity]?{
        didSet{
            if let count = result?.count where count != 0 {
                tableView.backgroundView = nil
            } else {
                tableView.backgroundView = UINib(nibName: "EmptyStationResult", bundle: nil).instantiateWithOwner(nil, options: nil).first as? UIView
            }
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchBar = UISearchBar()
        searchBar.placeholder = "输入昵称搜索"
        searchBar.tintColor = Util.colorWithHexString("007AFF")
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        searchBar.becomeFirstResponder()
        
        self.alwaysShowNavigationBar = true
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
  
        cell.user = self.result![indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.navigationItem.titleView?.endEditing(true)
        let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
        vc.user = self.result![indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension SearchFriendViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        if let text = searchBar.text where text.trimmed().length > 0 {
            
            self.navigationItem.titleView?.endEditing(true)
            var param = Dictionary<String, String>()
            param["nickName"] = ".*?\(searchBar.text).*"
            
            AlamofireController.request(.GET, "/users", parameters: param, success: { results in
                
                self.result = UserEntity.collection(results)
                
                }){ _ in
                    self.result = nil
            }
        }
    }
    
}

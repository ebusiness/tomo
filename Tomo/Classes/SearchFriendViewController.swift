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
    
    override func setupMapping() {
        
        let userMapping = RKObjectMapping(forClass: UserEntity.self)
        userMapping.addAttributeMappingsFromDictionary([
            "_id": "id",
            "tomoid": "tomoid",
            "nickName": "nickName",
            "gender": "gender",
            "photo_ref": "photo",
            "cover_ref": "cover",
            "bio": "bio",
            "firstName": "firstName",
            "lastName": "lastName",
            "birthDay": "birthDay",
            "telNo": "telNo",
            "address": "address",
            ])
        
        let responseDescriptor = RKResponseDescriptor(mapping: userMapping, method: .GET, pathPattern: "/users", keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        self.manager.addResponseDescriptor(responseDescriptor)
        
    }

    // MARK: - Table view data source

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

    @IBAction func close(sender: AnyObject) {
        self.view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension SearchFriendViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        if searchBar.text.trimmed().length > 0 {
            
            self.searchBar.resignFirstResponder()
            Util.showHUD()
            var param = Dictionary<String, String>()
            param["nickName"] = ".*?\(searchBar.text).*"
            
            self.manager.getObjectsAtPath("/users", parameters: param, success: { (_, results) -> Void in
                Util.dismissHUD()
                if let users = results.array() as? [UserEntity] {
                    self.result = users
                }
                
            }, failure: nil)
        }
    }
    
}

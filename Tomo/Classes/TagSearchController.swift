//
//  TagSearchController.swift
//  Tomo
//
//  Created by starboychina on 2015/06/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//


import UIKit

class TagSearchController: BaseViewController {
    var tagtype = ""
    var resultVC: TagSearchResultsViewController = Util.createViewControllerWithIdentifier("TagSearchResultsViewController", storyboardName: "Setting") as! TagSearchResultsViewController
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        resultVC = Util.createViewControllerWithIdentifier("TagSearchResultsViewController", storyboardName: "Setting") as! TagSearchResultsViewController
        searchController = UISearchController(searchResultsController: resultVC)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        
        var v = UIView(frame: CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height))
        v.addSubview(searchController.searchBar)
        self.view.addSubview(v)
        
        self.view.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5)
        
        //resultVC.tableView.delegate = StationResultsTableViewController.self()
        
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.setShowsCancelButton(true, animated: true)
        
        definesPresentationContext = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        searchController.active = true
        ApiController.getStationsHot { (result, error) -> Void in
            if let result = result {
            }
        }
    }
    override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        resultVC.dismissViewControllerAnimated(true, completion: completion)
        super.dismissViewControllerAnimated(flag, completion: completion)
        searchController.searchBar.text = ""
    }
}


// MARK: - UISearchBarDelegate

extension TagSearchController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
}

// MARK: - UISearchControllerDelegate

extension TagSearchController: UISearchControllerDelegate {
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
}

// MARK: - UISearchResultsUpdating

extension TagSearchController: UISearchResultsUpdating {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        var searchText = searchController.searchBar.text
        searchText = searchText.trimmed()
        
        if searchText.length > 0 {
            resultVC.tagListView.removeAllTags()
            resultVC.tagListView.addTag(searchText)
            ApiController.getTags(tagtype, name: ".*\(searchText).*", done: { (result, error) -> Void in
                if let result = result {
                    for tag in result {
                        if tag.name != searchText {
                            self.resultVC.tagListView.addTag(tag.name)
                        }
                    }
                    
                }
            })
        }
    }
}


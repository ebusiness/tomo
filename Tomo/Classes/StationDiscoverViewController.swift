//
//  StationDiscoverViewController.swift
//  Tomo
//
//  Created by eagle on 15/9/25.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class StationDiscoverViewController: UIViewController {
    
    private var tlocation: CLLocation?
    var location: CLLocation {
        get {
            return tlocation ?? CLLocation(latitude: 35.6833, longitude: 139.6833)
        }
        set {
            tlocation = newValue.copy() as? CLLocation
        }
    }
    
    var loading = false
    var page = 0
    
    let searchBar = UISearchBar()
    var searchText: String?
    
    @IBOutlet var collectionView: UICollectionView!
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    var groups: [GroupEntity]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        collectionView.registerNib(UINib(nibName: "StationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "identifier")
        
        loadInitData()
        navigationController?.navigationBar.barStyle = .Black
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchBar.placeholder = "搜索车站名称"
    }
}

// MARK: - Actions
extension StationDiscoverViewController {
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension StationDiscoverViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups?.count ?? 0
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("identifier", forIndexPath: indexPath) as! StationCollectionViewCell
        if let group = groups?[indexPath.row] {
            cell.group = group
        }
        cell.setupDisplay()
        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (screenWidth - 2.0) / 2.0
        let height = width / 3.0 * 4.0
        return CGSizeMake(width, height)
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let group = groups?[indexPath.row] else { return }
        
        let groupVC = Util.createViewControllerWithIdentifier("GroupDetailView", storyboardName: "Group") as! GroupDetailViewController
        groupVC.group = group
        self.navigationController?.pushViewController(groupVC, animated: true)
        
//        AlamofireController.request(.PATCH, "/groups/\(group.id)/join", parameters: nil, encoding: .URL, success: { (result) -> () in
//            gcd.async(.Default) {
//                let vgroup = GroupEntity(result)
//                me.addGroup(vgroup.id)
//                self.groups?.remove(group)
//                gcd.async(.Main) {
//                    self.collectionView.deleteItemsAtIndexPaths([indexPath])
//                }
//            }
//        })
    }
}

// MARK: - Network and data process
extension StationDiscoverViewController {
    private func loadInitData() {
        loading = true
        var parameters = Router.Group.FindParameters(category: .discover)
        parameters.page = page
        parameters.type = .station
        
        let coordinate = location.coordinate
        parameters.coordinate = [coordinate.longitude, coordinate.latitude]
        
        Router.Group.Find(parameters: parameters).response {
            if $0.result.isFailure {
                self.loading = false
                return
            }
            self.groups = GroupEntity.collection($0.result.value!)
            self.refresh()
            self.loading = false
            self.page = 1
        }
    }
    
    private func loadMoreData() {
        if loading {
            return
        }
        if groups == nil || groups?.count == 0 {
            return
        }
        loading = true
        var parameters = Router.Group.FindParameters(category: .discover)
        parameters.page = page
        parameters.type = .station
        
        let coordinate = location.coordinate
        parameters.coordinate = [coordinate.longitude, coordinate.latitude]
        
        if let searchText = searchText {
            parameters.name = searchText
        }
        
        Router.Group.Find(parameters: parameters).response {
            if $0.result.isFailure {
                self.loading = false
                return
            }
            
            if let groups: [GroupEntity] = GroupEntity.collection($0.result.value!) {
                self.groups?.appendContentsOf(groups)
                self.appendCells(groups.count)
                self.page++
            }
            self.loading = false
        }
    }
    
    private func refresh() {
        collectionView.reloadData()
        if let count = groups?.count where count != 0 {
            collectionView.backgroundView = nil
        } else {
            collectionView.backgroundView = UINib(nibName: "EmptyStationResult", bundle: nil).instantiateWithOwner(nil, options: nil).first as? UIView
        }
    }
    private func appendCells(count: Int) {
        guard let totalCount = groups?.count else { return }
        let startIndex = totalCount - count
        let endIndex = totalCount
        var indexPaths = [NSIndexPath]()
        for i in startIndex..<endIndex {
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            indexPaths.append(indexPath)
        }
        collectionView.insertItemsAtIndexPaths(indexPaths)
    }
}

extension StationDiscoverViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        self.searchText = text
        self.page = 1
        var parameters = Router.Group.FindParameters(category: .discover)
        parameters.type = .station
        
        let coordinate = location.coordinate
        parameters.coordinate = [coordinate.longitude, coordinate.latitude]
        parameters.name = text
        
        Router.Group.Find(parameters: parameters).response {
            self.groups = $0.result.isFailure ? nil : GroupEntity.collection($0.result.value!)
            self.refresh()
        }
    }
}

extension StationDiscoverViewController  {
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let contentHeight = scrollView.contentSize.height
        let contentOffset = scrollView.contentOffset.y
        let measuredOffset: CGFloat
        if screenHeight > contentHeight + scrollView.contentInset.top {
            measuredOffset = contentOffset + scrollView.contentInset.top
        } else {
            measuredOffset = contentOffset - (contentHeight - screenHeight)
        }
        if measuredOffset > 25 {
            loadMoreData()
        }
    }
}
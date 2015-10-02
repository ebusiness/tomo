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
    
    var stations: [StationEntity]?
    
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
        return stations?.count ?? 0
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("identifier", forIndexPath: indexPath) as! StationCollectionViewCell
        if let station = stations?[indexPath.row] {
            cell.station = station
        }
        cell.setupDisplay()
        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (screenWidth - 2.0) / 3.0
        let height = width / 4.0 * 3.0
        return CGSizeMake(width, height)
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let station = stations?[indexPath.row] {
            AlamofireController.request(.PATCH, "/me", parameters: ["$addToSet": ["stations":station.id]], encoding: .URL, success: { result in
                self.stations?.remove(station)
                me.stations = me.stations ?? []
                me.stations!.append(station.id)
                collectionView.deleteItemsAtIndexPaths([indexPath])
            }) { err in
                    
            }
            
        }
    }
}

// MARK: - Network and data process
extension StationDiscoverViewController {
    private func loadInitData() {
        loading = true
        var coordinate = location.coordinate
        let parameter: [String: AnyObject] = [
            "coordinate": [coordinate.latitude, coordinate.longitude],
        ]
        AlamofireController.request(.GET, "/stations",
            parameters: parameter, success: { (object) -> () in
                self.stations = StationEntity.collection(object)
                self.refresh()
                self.loading = false
                self.page = 1
            }) { (error) -> () in
                self.loading = false
        }
    }
    
    private func loadMoreData() {
        if loading {
            return
        }
        loading = true
        var coordinate = location.coordinate
        var parameter: [String: AnyObject] = [
            "coordinate": [coordinate.latitude, coordinate.longitude],
            "page": page
        ]
        if let searchText = searchText {
            parameter["name"] = searchText
        }
        AlamofireController.request(.GET, "/stations", parameters: parameter,
            success: { (object) -> () in
                if let stations: [StationEntity] = StationEntity.collection(object) {
                    self.stations?.extend(stations)
                    self.appendCells(stations.count)
                    self.page++
                }
                self.loading = false
            }, failure: {error in
                self.loading = false
            }
        )
    }
    
    private func refresh() {
        collectionView.reloadData()
        if let count = stations?.count where count != 0 {
            collectionView.backgroundView = nil
        } else {
            collectionView.backgroundView = UINib(nibName: "EmptyStationResult", bundle: nil).instantiateWithOwner(nil, options: nil).first as? UIView
        }
    }
    private func appendCells(count: Int) {
        if let totalCount = stations?.count {
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
}

extension StationDiscoverViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let text = searchBar.text
        searchText = searchBar.text
        AlamofireController.request(.GET, "/stations",
            parameters: ["name": text],
            success: { (object) -> () in
                self.stations = StationEntity.collection(object)
                self.refresh()
            }) { (error) -> () in
                self.stations = nil
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
//
//  StationDiscoverViewController.swift
//  Tomo
//
//  Created by eagle on 15/9/25.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class StationDiscoverViewController: UIViewController {
    
    var location: CLLocation?
    
    let searchBar = UISearchBar()
    
    @IBOutlet var collectionView: UICollectionView!
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    
    var stations: [StationEntity]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        collectionView.registerNib(UINib(nibName: "StationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "identifier")
        
        loadInitData()
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
            AlamofireController.request(.PATCH, "/me", parameters: ["$addToSet": ["stations":station.id]], encoding: .URL, success: { (result) -> () in
                self.stations?.remove(station)
                collectionView.deleteItemsAtIndexPaths([indexPath])
                }) { (err) -> () in
                    
            }
            
        }
    }
}

// MARK: - Network and data process
extension StationDiscoverViewController {
    private func loadInitData() {
        var coordinate: CLLocationCoordinate2D
        if let location = location {
            coordinate = location.coordinate
        } else {
            coordinate = CLLocationCoordinate2DMake(35.6833, 139.6833)
        }
        AlamofireController.request(.GET, "/stations?coordinate=\(coordinate.latitude)&coordinate=\(coordinate.longitude)",
            parameters: nil, encoding: ParameterEncoding.JSON, success: { (object) -> () in
                self.stations = StationEntity.collection(object)
                self.refresh()
            }) { (error) -> () in
                println(error)
        }
    }
    
    private func refresh() {
        collectionView.reloadData()
    }
}

extension StationDiscoverViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let text = searchBar.text
        AlamofireController.request(.GET, "/stations", parameters: ["name": text], success: { (object) -> () in
            self.stations = StationEntity.collection(object)
            self.refresh()
            }) { (error) -> () in
                self.stations = nil
                self.refresh()
        }
    }
}

/*
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
// Get the new view controller using segue.destinationViewController.
// Pass the selected object to the new view controller.
}
*/
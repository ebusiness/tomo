//
//  RecommendViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/10/26.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class RecommendViewController: UIViewController {
    
    @IBOutlet weak var recommendGroupCollectionView: UICollectionView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var maskView: UIView!
    
    private var annotation: GroupEntityAnnotation?

    private var myGroups = [GroupEntity]()
    
    private var myLocation: CLLocation?

    private let screenWidth = UIScreen.mainScreen().bounds.width
    
    private let itemSize: CGSize = {
        let height = UIScreen.mainScreen().bounds.height * 0.4 - 8
        let width = height / 4 * 3
        
        return CGSizeMake(width, height)
    }()
    
    private var recommendGroups: [GroupEntity]? {
        didSet {
            self.recommendGroupCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()

        LocationController.shareInstance.fetchWithCompletion { location in
            self.getRecommendInfo(location)
            self.myLocation = location
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}


extension RecommendViewController {

    private func getRecommendInfo(location: CLLocation?, forceRefresh: Bool = false) {
        
        var params = [
            "category": "discover",
            "type": "station",
            "page": 0
        ]

        if let location = location {
            params["coordinate"] = [location.coordinate.longitude, location.coordinate.latitude]
        } else {
            params["coordinate"] = TomoConst.Geo.CoordinateTokyo //
        }
        
        if nil == self.recommendGroups || forceRefresh {
            AlamofireController.request(.GET, "/groups", parameters: params, hideHUD: true, success: { stationData in
                self.recommendGroups = GroupEntity.collection(stationData)
            })
        }
    }
    
    private func joinGroup(indexPath: NSIndexPath) {
        
        let group = self.recommendGroups![indexPath.item]
        
        let successHandler: (AnyObject)->() = { _ in
            let removeGroup = self.recommendGroups!.removeAtIndex(indexPath.item)
            me.addGroup(removeGroup.id)
            self.myGroups.append(removeGroup)
        }
        
        AlamofireController.request(.PATCH, "/groups/\(group.id)/join", success: successHandler)
    }
    
    private func searchGroup(keyword: String) {
        let successHandler: (AnyObject)->() = {
            object in
            self.recommendGroups = GroupEntity.collection(object)
        }
        var parameter: [String: AnyObject] = [
        "name": keyword,
        "page": 0,
        "type": "station",
        "category": "discover"
        ]
        if let location = myLocation {
            parameter["coordinate"] = [location.coordinate.longitude, location.coordinate.latitude]
        }
        AlamofireController.request(.GET, "/groups", parameters: parameter, success: successHandler)
    }
    
    private func selectGroup(group: GroupEntity) {
        guard let latitude = group.coordinate?[1], longitude = group.coordinate?[0] else {
            return
        }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let adjustedCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude + 0.007, longitude: coordinate.longitude)
        let region = MKCoordinateRegion(center: adjustedCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.023, longitudeDelta: 0.023))
        mapView.setRegion(region, animated: true)
        
        if let annotation = annotation {
            mapView.removeAnnotation(annotation)
        }
        
        annotation = GroupEntityAnnotation(group: group)
        mapView.addAnnotation(annotation!)
    }

}


extension RecommendViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendGroups?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("defaultCell", forIndexPath: indexPath) as! StationRecommendCollectionViewCell

        let group = recommendGroups![indexPath.item]

        cell.coverImageView.sd_setImageWithURL(NSURL(string: group.cover), placeholderImage: TomoConst.Image.DefaultGroup)
        cell.nameLabel.text = group.name

        return cell
    }
}

extension RecommendViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        if let group = recommendGroups?[indexPath.row] {
            selectGroup(group)
            if maskView != nil {
                maskView.removeFromSuperview()
            }
        }
    }

}

extension RecommendViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return itemSize
    }
}

extension RecommendViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let text = searchBar.text where text.length > 0 else {
            return
        }
        searchGroup(text)
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchBar.text, let location = myLocation where text.length == 0 {
            getRecommendInfo(location, forceRefresh: true)
        }
    }
}

extension RecommendViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? GroupEntityAnnotation else {
            return nil
        }
        let annotationView = GroupEntityAnnotationView(annotation: annotation, reuseIdentifier: "identifier")
        annotationView.groupDescriptionLabel.text = annotation.group.name
        annotationView.groupDescriptionLabel.sizeToFit()
        return annotationView
    }
}

class GroupEntityAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        if let latitude = group.coordinate?[1], longitude = group.coordinate?[0] {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            return CLLocationCoordinate2D(latitude: 35.6833, longitude: 139.6833)
        }
    }
    var group: GroupEntity
    init(group: GroupEntity) {
        self.group = group
    }
}

class GroupEntityAnnotationView: MKAnnotationView {
    
    var groupDescriptionLabel: UILabel
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        groupDescriptionLabel = UILabel()
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        addSubview(groupDescriptionLabel)
    }
    
    override init(frame: CGRect) {
        groupDescriptionLabel = UILabel()
        super.init(frame: frame)
        addSubview(groupDescriptionLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

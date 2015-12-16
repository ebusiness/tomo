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

    private var myGroups = [GroupEntity]()
    
    private var myLocation: CLLocation?

    private var currentAnnotationView: MKAnnotationView?

//    lazy private var stationPopover: GroupCallOutViewController = {
//
//        let vc = GroupCallOutViewController()
//        vc.loadView()
//        vc.modalPresentationStyle = .Popover
//        vc.presentationController?.delegate = self
//
//        return vc
//    }()
//    
    private let itemSize: CGSize = {
        let height = UIScreen.mainScreen().bounds.height * 0.3 - 8
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

        var params: [String : AnyObject] = [
            "category": "discover",
            "type": "station",
            "name": keyword,
            "page": 0
        ]

        if let location = myLocation {
            params["coordinate"] = [location.coordinate.longitude, location.coordinate.latitude]
        }

        AlamofireController.request(.GET, "/groups", parameters: params, success: successHandler)
    }
    
    private func selectGroup(group: GroupEntity) {

        guard let latitude = group.coordinate?[1], longitude = group.coordinate?[0] else {
            return
        }

        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        let unit = MKMetersPerMapPointAtLatitude(latitude)

        let point = MKMapPointForCoordinate(coordinate)
        let origin = MKMapPoint(x: point.x - 1500/unit, y: point.y - 2100/unit)
        let rect = MKMapRect(origin: origin, size: MKMapSize(width: 3000/unit, height: 3000/unit))

        self.mapView.setVisibleMapRect(rect, animated: true)
        
        self.mapView.removeAnnotations(self.mapView.annotations)

        let annotation = GroupAnnotation()
        annotation.group = group
        if let lon = group.coordinate?.get(0), lat = group.coordinate?.get(1) {
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }

        self.mapView.addAnnotation(annotation)
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

        self.dismissViewControllerAnimated(true, completion: nil)

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

extension RecommendViewController: UIAdaptivePresentationControllerDelegate {
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .None
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

        guard let annotation = annotation as? GroupAnnotation else {
            return nil
        }

        var stationAnnotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier("identifier")

        if stationAnnotationView == nil {
            stationAnnotationView = StationAnnotationView(annotation: annotation, reuseIdentifier: "identifier")
        } else {
            stationAnnotationView?.annotation = annotation
        }

        (stationAnnotationView as! StationAnnotationView).setupDisplay()

        self.currentAnnotationView = stationAnnotationView

        return stationAnnotationView
    }

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {

        if let annotationView = self.currentAnnotationView {

            let vc = Util.createViewControllerWithIdentifier("GroupPopoverViewController", storyboardName: "Main") as! GroupPopoverViewController

            vc.modalPresentationStyle = .Popover
            vc.presentationController?.delegate = self

            vc.groupAnnotation = annotationView.annotation as! GroupAnnotation

            self.presentViewController(vc, animated: true, completion: nil)

            if let pop = vc.popoverPresentationController {
                pop.passthroughViews = [self.view]
                pop.permittedArrowDirections = .Down
                pop.sourceView = (self.currentAnnotationView as? UIView)
                pop.sourceRect = (self.currentAnnotationView as? UIView)!.bounds
            }
        }
    }
}

class StationRecommendCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var coverImageView: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 5
        self.contentView.clipsToBounds = true
    }
    
}

class GroupPopoverViewController: UIViewController {

    var groupAnnotation: GroupAnnotation! {
        didSet {
            if self.isViewLoaded() {
                self.setupDisplay()
            }
        }
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDisplay()
    }

    @IBAction func joinButtonTapped(sender: AnyObject) {

    }

    func setupDisplay() {
        if let group = groupAnnotation.group {
            self.nameLabel.text = group.name
            self.coverImageView.sd_setImageWithURL(NSURL(string: group.cover), placeholderImage: TomoConst.Image.DefaultGroup)
        }
    }
}

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
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var currentAnnotationView: MKAnnotationView?
    private var currentSelectedIndexPath: NSIndexPath?
    
    var exitAction: (()->())?

    private let itemSize: CGSize = {
        let height = UIScreen.mainScreen().bounds.height * 0.3 - 8
        let width = height / 4 * 3
        return CGSizeMake(width, height)
    }()

    private var recommendGroups: [GroupEntity]? {
        didSet {

            let firstItemIndex = NSIndexPath(forItem: 0, inSection: 0)
            var removeIndex: [NSIndexPath] = []
            var insertIndex: [NSIndexPath] = []

            if let oldValue = oldValue {
                for _ in oldValue {
                    removeIndex.append(NSIndexPath(forItem: removeIndex.count, inSection: 0))
                }
            }
            if let primaryStation = me.primaryStation {
                self.recommendGroups?.insert(primaryStation, atIndex: 0)
            }
            if let newValue = self.recommendGroups {
                for _ in newValue {
                    insertIndex.append(NSIndexPath(forItem: insertIndex.count, inSection: 0))
                }
            }

            self.recommendGroupCollectionView.performBatchUpdates({ _ in
                self.recommendGroupCollectionView.deleteItemsAtIndexPaths(removeIndex)
                self.recommendGroupCollectionView.insertItemsAtIndexPaths(insertIndex)
                }) { _ in
                    self.recommendGroupCollectionView.scrollToItemAtIndexPath(firstItemIndex, atScrollPosition: .Left, animated: true)
            }
        }
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        
        if let primaryStation = me.primaryStation {
            self.maskView.alpha = 0
            self.selectGroup(primaryStation)
        }
        LocationController.shareInstance.doActionWithLocation {
            self.getRecommendInfo($0)
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}

// MARK: - interal methodes

extension RecommendViewController {

    private func getRecommendInfo(location: CLLocation?) {

        var parameters = Router.Group.FindParameters(category: .discover)
        parameters.type = .station

        if let location = location {
            parameters.coordinate = [location.coordinate.longitude, location.coordinate.latitude]
        } else {
            parameters.coordinate = TomoConst.Geo.CoordinateTokyo
        }

        self.activityIndicator.startAnimating()

        Router.Group.Find(parameters: parameters).response {

            self.activityIndicator.stopAnimating()

            if $0.result.isFailure { return }
            self.recommendGroups = GroupEntity.collection($0.result.value!)
        }
    }

    @IBAction func searchButtonTapped(sender: AnyObject) {
        
        if let presentedViewController = self.presentedViewController {
            presentedViewController.dismissViewControllerAnimated(true, completion: nil)
        }

        UIView.animateWithDuration(TomoConst.Duration.Short, animations: {
            self.searchBarBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
            }) { _ in
                self.searchBar.becomeFirstResponder()
        }
    }

    @IBAction func exitButtonTapped(sender: AnyObject) {
        if let exitAction = exitAction {
            exitAction()
            return
        }
        Router.Signout().response { _ in

            Defaults.remove("openid")
            Defaults.remove("deviceToken")

            Defaults.remove("email")
            Defaults.remove("password")

            me = nil
            let main = Util.createViewControllerWithIdentifier(nil, storyboardName: "Main")
            Util.changeRootViewController(from: self, to: main)

        }
    }
}

// MARK: - UICollectionViewDataSource

extension RecommendViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recommendGroups?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("defaultCell", forIndexPath: indexPath) as! GroupRecommendCollectionViewCell

        let group = self.recommendGroups![indexPath.item]

        cell.coverImageView.sd_setImageWithURL(NSURL(string: group.cover), placeholderImage: TomoConst.Image.DefaultGroup)
        cell.nameLabel.text = group.name

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension RecommendViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        guard self.currentSelectedIndexPath != indexPath else { return }
        guard let group = recommendGroups?[indexPath.row] else { return }

        self.currentSelectedIndexPath = indexPath
        
        if let presentedViewController = self.presentedViewController {
            presentedViewController.dismissViewControllerAnimated(true, completion: nil)
        }

        self.selectGroup(group)
        
        guard self.maskView.alpha > 0 else { return }
        
        UIView.animateWithDuration(TomoConst.Duration.Short, animations: {
            self.maskView.alpha = 0
        })
    }

    private func selectGroup(group: GroupEntity) {
        guard let latitude = group.coordinate?[1] else { return }
        guard let longitude = group.coordinate?[0] else { return }

        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        let unit = MKMetersPerMapPointAtLatitude(latitude)

        let point = MKMapPointForCoordinate(coordinate)
        let origin = MKMapPoint(x: point.x - 1500/unit, y: point.y - 2100/unit)
        let rect = MKMapRect(origin: origin, size: MKMapSize(width: 3000/unit, height: 3000/unit))

        self.mapView.setVisibleMapRect(rect, animated: true)

        let annotation = GroupAnnotation()
        annotation.group = group
        annotation.coordinate = coordinate

        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(annotation)
    }
}

// MARK: - MKMapViewDelegate

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

        guard let annotationView = self.currentAnnotationView else { return }
        
        let vc = Util.createViewControllerWithIdentifier("GroupPopoverViewController", storyboardName: "Main") as! GroupPopoverViewController
        
        vc.modalPresentationStyle = .Popover
        vc.presentationController?.delegate = self
        
        vc.groupAnnotation = annotationView.annotation as! GroupAnnotation

        self.presentViewController(vc, animated: true, completion: nil)
        
        if let pop = vc.popoverPresentationController {
            pop.passthroughViews = [self.view]
            pop.permittedArrowDirections = .Down
            pop.sourceView = annotationView
            pop.sourceRect = annotationView.bounds
        }

    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        self.mapView(mapView, regionDidChangeAnimated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension RecommendViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return itemSize
    }
}

// MARK: - UISearchBarDelegate

extension RecommendViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {

        self.hideSearchBar()

        guard let text = searchBar.text where text.length > 0 else { return }

        LocationController.shareInstance.doActionWithLocation {
            self.currentSelectedIndexPath = nil
            self.searchGroupWith(text, location: $0)
        }
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {

        self.hideSearchBar()

        guard let text = searchBar.text where text.length == 0 else { return }

        LocationController.shareInstance.doActionWithLocation {
            self.currentSelectedIndexPath = nil
            self.getRecommendInfo($0)
        }
    }

    private func hideSearchBar() {

        self.searchBar.resignFirstResponder()

        UIView.animateWithDuration(TomoConst.Duration.Short, animations: {
            self.searchBarBottomConstraint.constant = -TomoConst.UI.NavigationBarHeight
            self.view.layoutIfNeeded()
        })
    }

    private func searchGroupWith(keyword: String, location: CLLocation?) {

        var parameters = Router.Group.FindParameters(category: .discover)
        parameters.type = .station
        parameters.name = keyword

        if let location = location {
            parameters.coordinate = [location.coordinate.longitude, location.coordinate.latitude]
        } else {
            parameters.coordinate = TomoConst.Geo.CoordinateTokyo
        }

        self.activityIndicator.startAnimating()

        Router.Group.Find(parameters: parameters).response {

            self.activityIndicator.stopAnimating()

            guard $0.result.isSuccess else {
                let alert = UIAlertController(title: "没有找到相关的结果", message: "请试着用其他关键字检索一下吧", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "好", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            self.recommendGroups = GroupEntity.collection($0.result.value!)
        }
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension RecommendViewController: UIAdaptivePresentationControllerDelegate {
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .None
    }
}

// MARK: - GroupRecommendCollectionViewCell

final class GroupRecommendCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var coverImageView: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 5
        self.contentView.clipsToBounds = true
    }

}

// MARK: - GroupPopoverViewController

final class GroupPopoverViewController: UIViewController {

    var groupAnnotation: GroupAnnotation! {
        didSet {
            if self.isViewLoaded() {
                self.setupDisplay()
            }
        }
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var joinButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDisplay()
    }

    @IBAction func joinButtonTapped(sender: AnyObject) {
        
        guard let delegate = UIApplication.sharedApplication().delegate else { return }
        guard let window = delegate.window else { return }
        guard let rootViewController = window?.rootViewController else { return }

        Router.Group.Join(id: groupAnnotation.group.id).response {

            guard $0.result.isSuccess else { return }
            me.primaryStation = self.groupAnnotation.group

            var param = Router.Setting.MeParameter()
            param.primaryStation = self.groupAnnotation.group.id

            Router.Setting.UpdateUserInfo(parameters: param).response {

                guard $0.result.isSuccess else { return }
                
                
                if let rvc = self.presentationController?.delegate as? RecommendViewController
                    ,exitAction = rvc.exitAction {
                        me.primaryStation = self.groupAnnotation.group
                        self.dismissViewControllerAnimated(true) { _ in
                            exitAction()
                        }
                        return
                }
                let tab = Util.createViewControllerWithIdentifier(nil, storyboardName: "Tab")
                Util.changeRootViewController(from: rootViewController, to: tab)
            }
        }
    }
    
    private func setupDisplay() {
        
        self.joinButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.joinButton.layer.borderWidth = 1
        self.joinButton.layer.cornerRadius = 2
        
        guard let group = groupAnnotation.group else { return }
        self.nameLabel.text = group.name
        self.introLabel.text = group.introduction
        self.coverImageView.sd_setImageWithURL(NSURL(string: group.cover), placeholderImage: TomoConst.Image.DefaultGroup)
        
        guard let me = me else { return }
        
        if group.id == me.primaryStation?.id {
            self.joinButton.hidden = true
        } else {
            self.joinButton.hidden = false
            self.joinButton.setTitle("设置为当前现场", forState: .Normal)
        }
    }
}

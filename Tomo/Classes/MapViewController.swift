//
//  MapViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/16.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

enum InterfaceMode: Int {
    case HotStation
    case MyStation
    case FriendsMap
}

final class MapViewController: UIViewController {

    var mode = InterfaceMode.FriendsMap

    let PostAnnotationViewIdentifier = "PostAnnotationView"
    let GroupAnnotationViewIdentifier = "GroupAnnotationView"
    let StationAnnotationViewIdentifier = "StationAnnotationView"
    let UserAnnotationViewIdentifier = "UserAnnotationView"

    var allAnnotationMapView: MKMapView!

    var contents = [AnyObject]()

    var lastLoadDate: NSDate?

    var annotationsForTable: [AggregatableAnnotation]?

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTopConstrian: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstranit: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.allAnnotationMapView = MKMapView(frame: CGRectZero)

        self.loadContents()

        self.navigationController?.navigationBarHidden = true
    }

    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }

    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}

// MARK: Action

extension MapViewController {

    @IBAction func changeMode(sender: AnyObject) {

        self.hideTableView()

        let segmentControl = sender as! UISegmentedControl

        segmentControl.enabled = false

        switch segmentControl.selectedSegmentIndex {
        case 0:
            self.mode = .HotStation
            self.loadContents()
        case 1:
            self.mode = .MyStation
            self.loadContents()
        case 2:
            self.mode = .FriendsMap
            self.loadContents()
        default :
            return
        }
    }

    @IBAction func mapViewTapped(sender: AnyObject) {
        self.hideTableView()
    }
}

// MARK: MapView Delegate

extension MapViewController: MKMapViewDelegate {

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

        if mapView != self.mapView {
            return nil
        }

        if let annotation = annotation as? PostAnnotation {

            var annotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier(PostAnnotationViewIdentifier)

            if annotationView == nil {
                annotationView = PostAnnotationView(annotation: annotation, reuseIdentifier: PostAnnotationViewIdentifier)
            } else {
                annotationView!.annotation = annotation
            }
            (annotationView as! PostAnnotationView).setupDisplay()

            return annotationView

        } else if let annotation = annotation as? GroupAnnotation {

            if annotation.group.type == "station" {

                var annotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier(StationAnnotationViewIdentifier)

                if annotationView == nil {
                    annotationView = StationAnnotationView(annotation: annotation, reuseIdentifier: StationAnnotationViewIdentifier)
                } else {
                    annotationView!.annotation = annotation
                }
                (annotationView as! StationAnnotationView).setupDisplay()

                return annotationView

            } else {

                var annotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier(GroupAnnotationViewIdentifier)

                if annotationView == nil {
                    annotationView = GroupAnnotationView(annotation: annotation, reuseIdentifier: GroupAnnotationViewIdentifier)
                } else {
                    annotationView!.annotation = annotation
                }
                (annotationView as! GroupAnnotationView).setupDisplay()

                return annotationView
            }

        } else if let annotation = annotation as? UserAnnotation {

            var annotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier(UserAnnotationViewIdentifier)

            if annotationView == nil {
                annotationView = UserAnnotationView(annotation: annotation, reuseIdentifier: UserAnnotationViewIdentifier)
            } else {
                annotationView!.annotation = annotation
            }
            
            (annotationView as! UserAnnotationView).setupDisplay()

            return annotationView

        } else {
            return nil
        }
    }

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.updateVisibleAnnotations()
    }

    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {

        for view in views {

            if let annotation = view.annotation as? AggregatableAnnotation {

                if (annotation.clusterAnnotation != nil) {

                    // animate the annotation from it's old container's coordinate, to its actual coordinate
                    let actualCoordinate = annotation.coordinate
                    let containerCoordinate = annotation.clusterAnnotation!.coordinate

                    // since it's displayed on the map, it is no longer contained by another annotation,
                    // (We couldn't reset this in -updateVisibleAnnotations because we needed the reference to it here
                    // to get the containerCoordinate)
                    annotation.clusterAnnotation = nil

                    annotation.coordinate = containerCoordinate

                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        annotation.coordinate = actualCoordinate
                    })
                }
            }

            if let view = view as? AggregatableAnnotationView {
                view.setupDisplay()
            }
        }
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {

        mapView.deselectAnnotation(view.annotation, animated: true)

        if let view = view as? StationAnnotationView {

            let groupAnnotation = view.annotation as! GroupAnnotation

            if groupAnnotation.containedAnnotations?.count == 0 {

                let pvc = Util.createViewControllerWithIdentifier("GroupDetailView", storyboardName: "Group") as! GroupDetailViewController
                pvc.group = groupAnnotation.group

                self.navigationController?.pushViewController(pvc, animated: true)

            } else {

                self.annotationsForTable = groupAnnotation.containedAnnotations
                self.annotationsForTable?.push(groupAnnotation)

                self.tableView.reloadData()

                if self.tableView.contentSize.height > UIScreen.mainScreen().bounds.height * 2/5 {
                    self.tableViewHeightConstranit.constant = UIScreen.mainScreen().bounds.height * 2/5
                } else {
                    self.tableViewHeightConstranit.constant = self.tableView.contentSize.height
                }

                UIView.animateWithDuration(TomoConst.Duration.Short, animations: {
                    self.tableViewTopConstrian.constant = self.tableViewHeightConstranit.constant
                    self.view.layoutIfNeeded()
                })
            }

        } else if let view = view as? UserAnnotationView {

            let userAnnotation = view.annotation as! UserAnnotation

            if userAnnotation.containedAnnotations?.count == 0 {

                let pvc = Util.createViewControllerWithIdentifier("UserPostsView", storyboardName: "Profile") as! UserPostsViewController
                pvc.user = userAnnotation.user

                self.navigationController?.pushViewController(pvc, animated: true)

            } else {

                self.annotationsForTable = userAnnotation.containedAnnotations
                self.annotationsForTable?.push(userAnnotation)

                self.tableView.reloadData()

                if self.tableView.contentSize.height > UIScreen.mainScreen().bounds.height * 2/5 {
                    self.tableViewHeightConstranit.constant = UIScreen.mainScreen().bounds.height * 2/5
                } else {
                    self.tableViewHeightConstranit.constant = self.tableView.contentSize.height
                }

                UIView.animateWithDuration(TomoConst.Duration.Short, animations: {
                    self.tableViewTopConstrian.constant = self.tableViewHeightConstranit.constant
                    self.view.layoutIfNeeded()
                })
            }
        }

    }
}

extension MapViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.annotationsForTable?.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {


        if let userAnnotation = self.annotationsForTable![indexPath.item] as? UserAnnotation {

            let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! UserCell
            cell.user = userAnnotation.user
            cell.setupDisplay()
            return cell

        } else if let groupAnnotation = self.annotationsForTable![indexPath.item] as? GroupAnnotation {

            let cell = tableView.dequeueReusableCellWithIdentifier("GroupCell", forIndexPath: indexPath) as! GroupCell
            cell.group = groupAnnotation.group
            cell.setupDisplay()
            return cell

        } else {
            return UITableViewCell()
        }

    }

}

extension MapViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if let userAnnotation = self.annotationsForTable![indexPath.item] as? UserAnnotation {
            let pvc = Util.createViewControllerWithIdentifier("UserPostsView", storyboardName: "Profile") as! UserPostsViewController
            pvc.user = userAnnotation.user
            self.navigationController?.pushViewController(pvc, animated: true)
        }

        if let groupAnnotation = self.annotationsForTable![indexPath.item] as? GroupAnnotation {
            let pvc = Util.createViewControllerWithIdentifier("GroupDetailView", storyboardName: "Group") as! GroupDetailViewController
            pvc.group = groupAnnotation.group
            self.navigationController?.pushViewController(pvc, animated: true)
        }
    }
}

// MARK: Internal Methods

extension MapViewController {

    private func hideTableView() {
        UIView.animateWithDuration(TomoConst.Duration.Short, animations: {
            self.tableViewTopConstrian.constant = 0
            self.view.layoutIfNeeded()
        })
    }

    private func loadContents() {

        func findGroups(parameters: Router.Group.MapParameters) {
            Router.Group.Map(parameters: parameters).response {
                if $0.result.isFailure {
                    self.segmentedControl.enabled = true
                    return
                }

                guard let groups:[GroupEntity] = GroupEntity.collection($0.result.value!) else { return }

                let annotations = groups.map { group -> GroupAnnotation in
                    let annotation = GroupAnnotation()
                    annotation.group = group
                    if let lon = group.coordinate?.get(0), lat = group.coordinate?.get(1) {
                        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    }
                    return annotation
                }
                self.allAnnotationMapView.addAnnotations(annotations)
                self.adjustRegion(self.allAnnotationMapView.annotations)
                self.updateVisibleAnnotations()
                self.lastLoadDate = NSDate()

                self.segmentedControl.enabled = true
            }
        }

        func findFriends() {
            Router.User.Map.response {
                if $0.result.isFailure {
                    self.segmentedControl.enabled = true
                    return
                }

                guard let users:[UserEntity] = UserEntity.collection($0.result.value!) else { return }

                let annotations = users.map { user -> UserAnnotation in
                    let annotation = UserAnnotation()
                    annotation.user = user
                    if let station = user.primaryStation {
                        if let lon = station.coordinate?.get(0), lat = station.coordinate?.get(1) {
                            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        }
                    }
                    return annotation
                }
                self.allAnnotationMapView.addAnnotations(annotations)
                self.adjustRegion(self.allAnnotationMapView.annotations)
                self.updateVisibleAnnotations()
                self.lastLoadDate = NSDate()

                self.segmentedControl.enabled = true
            }
        }

        self.allAnnotationMapView.removeAnnotations(self.allAnnotationMapView.annotations)
        self.mapView.removeAnnotations(self.mapView.annotations)

        var parameters = Router.Group.MapParameters(category: .all)
        parameters.type = .station

        switch self.mode {
        case .HotStation:
            parameters.hasMembers = true
            findGroups(parameters)
        case .MyStation:
            parameters.category = .mine
            findGroups(parameters)
        case .FriendsMap:
            findFriends()
        }

    }

    private func getCurrentBox() -> [Double] {

        let visibleRect = mapView.visibleMapRect

        let left = MKMapRectGetMinX(visibleRect)
        let right = MKMapRectGetMaxX(visibleRect)
        let top = MKMapRectGetMinY(visibleRect)
        let bottom = MKMapRectGetMaxY(visibleRect)

        let leftBottom = MKCoordinateForMapPoint(MKMapPoint(x: left, y: bottom))
        let rightTop = MKCoordinateForMapPoint(MKMapPoint(x: right, y: top))

        // println("[\(leftBottom.latitude),\(leftBottom.longitude)],[\(rightTop.latitude),\(rightTop.longitude)]")

        return [leftBottom.latitude, leftBottom.longitude, rightTop.latitude, rightTop.longitude]
    }

    private func updateVisibleAnnotations() {

        // This value to controls the number of off screen annotations are displayed.
        // A bigger number means more annotations, less chance of seeing annotation views pop in but decreased performance.
        // A smaller number means fewer annotations, more chance of seeing annotation views pop in but better performance.
        let marginFactor = 1.0;

        // Adjust this roughly based on the dimensions of your annotations views.
        // Bigger numbers more aggressively coalesce annotations (fewer annotations displayed but better performance).
        // Numbers too small result in overlapping annotations views and too many annotations on screen.
        let bucketSize = 120.0;

        // find all the annotations in the visible area + a wide margin to avoid popping annotation views in and out while panning the map.
        let visibleMapRect = mapView.visibleMapRect
        let adjustedVisibleMapRect = MKMapRectInset(visibleMapRect, -marginFactor * visibleMapRect.size.width, -marginFactor * visibleMapRect.size.height)

        // determine how wide each bucket will be, as a MKMapRect square
        let leftCoordinate = mapView.convertPoint(CGPointZero, toCoordinateFromView: mapView)
        let rightCoordinate = mapView.convertPoint(CGPointMake(CGFloat(bucketSize), CGFloat(0.0)), toCoordinateFromView: mapView)

        // determine how wide each bucket will be, as a MKMapRect square
        let gridSize = MKMapPointForCoordinate(rightCoordinate).x - MKMapPointForCoordinate(leftCoordinate).x
        var gridMapRect = MKMapRectMake(0, 0, gridSize, gridSize)

        // condense annotations, with a padding of two squares, around the visibleMapRect
        let startX = floor(MKMapRectGetMinX(adjustedVisibleMapRect) / gridSize) * gridSize
        let startY = floor(MKMapRectGetMinY(adjustedVisibleMapRect) / gridSize) * gridSize
        let endX = floor(MKMapRectGetMaxX(adjustedVisibleMapRect) / gridSize) * gridSize
        let endY = floor(MKMapRectGetMaxY(adjustedVisibleMapRect) / gridSize) * gridSize

        // for each square in our grid, pick one annotation to show
        gridMapRect.origin.y = startY
        while (MKMapRectGetMinY(gridMapRect) <= endY) {

            gridMapRect.origin.x = startX
            while (MKMapRectGetMinX(gridMapRect) <= endX) {

                let allAnnotationsInBucket = allAnnotationMapView.annotationsInMapRect(gridMapRect)
                let visibleAnnotationsInBucket = mapView.annotationsInMapRect(gridMapRect)

                var allAnnotations = Array(allAnnotationsInBucket) as! [AggregatableAnnotation]

                if let annotationForGrid = annotationInGrid(gridMapRect, usingAnnotations: allAnnotations) as? AggregatableAnnotation {

                    allAnnotations.remove(annotationForGrid)

                    // give the annotationForGrid a reference to all the annotations it will represent
                    annotationForGrid.containedAnnotations = allAnnotations

                    mapView.addAnnotation(annotationForGrid)

                    if let view = mapView.viewForAnnotation(annotationForGrid) as? AggregatableAnnotationView {
                        view.setupDisplay()
                    }

                    for annotation in allAnnotations {

                        // give all the other annotations a reference to the one which is representing them
                        annotation.clusterAnnotation = annotationForGrid
                        annotation.containedAnnotations = nil

                        // remove annotations which we've decided to cluster
                        if visibleAnnotationsInBucket.contains(annotation) {

                            let actualCoordinate = annotation.coordinate

                            UIView.animateWithDuration(0.3, animations: { () -> Void in
                                annotation.coordinate = annotation.clusterAnnotation!.coordinate
                                }, completion: { [unowned self, annotation, actualCoordinate](finished) -> Void in
                                    annotation.coordinate = actualCoordinate
                                    self.mapView.removeAnnotation(annotation)
                                })

                        }
                    }
                }

                gridMapRect.origin.x += gridSize
            }

            gridMapRect.origin.y += gridSize
        }
    }

    private func adjustRegion(annotations: [AnyObject]) {

        if annotations.count > 0 {

            let horizontalSortedAnnotations = annotations.sort { (obj1, obj2) -> Bool in

                let mapPoint1 = MKMapPointForCoordinate((obj1 as! MKAnnotation).coordinate)
                let mapPoint2 = MKMapPointForCoordinate((obj2 as! MKAnnotation).coordinate)

                if mapPoint1.x < mapPoint2.x {
                    return true
                } else {
                    return false
                }
            }

            let verticalSortedAnnotations = annotations.sort { (obj1, obj2) -> Bool in

                let mapPoint1 = MKMapPointForCoordinate((obj1 as! MKAnnotation).coordinate)
                let mapPoint2 = MKMapPointForCoordinate((obj2 as! MKAnnotation).coordinate)

                if mapPoint1.y < mapPoint2.y {
                    return true
                } else {
                    return false
                }
            }

            let leftMostAnnotationPoint = MKMapPointForCoordinate((horizontalSortedAnnotations.first as! MKAnnotation).coordinate)
            let rightMostAnnotationPoint = MKMapPointForCoordinate((horizontalSortedAnnotations.last as! MKAnnotation).coordinate)
            let topMostAnnotationPoint = MKMapPointForCoordinate((verticalSortedAnnotations.first as! MKAnnotation).coordinate)
            let bottomMostAnnotationPoint = MKMapPointForCoordinate((verticalSortedAnnotations.last as! MKAnnotation).coordinate)

            let targetRect = MKMapRect(origin: MKMapPoint(x: leftMostAnnotationPoint.x, y: topMostAnnotationPoint.y), size: MKMapSize(width: rightMostAnnotationPoint.x - leftMostAnnotationPoint.x, height: bottomMostAnnotationPoint.y - topMostAnnotationPoint.y))

            let adjustRect = self.mapView.mapRectThatFits(targetRect, edgePadding: UIEdgeInsets(top: 120, left: 80, bottom: 120, right: 80))
            let adjustRegion = MKCoordinateRegionForMapRect(adjustRect)

            self.mapView.setRegion(adjustRegion, animated: true)

        } else {
            return
        }
    }

    private func annotationInGrid(gridMapRect: MKMapRect, usingAnnotations annotations: Array<NSObject>) -> NSObject? {

        // first, see if one of the annotations we were already showing is in this mapRect
        let visibleAnnotationsInBucket = mapView.annotationsInMapRect(gridMapRect)

        for annotation in annotations {
            if visibleAnnotationsInBucket.contains(annotation) {
                return annotation
            }
        }

        // otherwise, sort the annotations based on their distance from the center of the grid square,
        // then choose the one closest to the center to show
        let centerMapPoint = MKMapPoint(x: MKMapRectGetMidX(gridMapRect), y: MKMapRectGetMidY(gridMapRect))
        let sortedAnnotations = annotations.sort { (obj1, obj2) -> Bool in

            let mapPoint1 = MKMapPointForCoordinate((obj1 as! MKAnnotation).coordinate)
            let mapPoint2 = MKMapPointForCoordinate((obj2 as! MKAnnotation).coordinate)
            
            let distance1 = MKMetersBetweenMapPoints(mapPoint1, centerMapPoint)
            let distance2 = MKMetersBetweenMapPoints(mapPoint2, centerMapPoint)
            
            if distance1 < distance2 {
                return true
            } else {
                return false
            }
        }

//        // if there is an annotation stard for a friend, choose it show
//        if let groupAnnotations = sortedAnnotations as? [StationAnnotation] {
//
//            if let groups = me.groups {
//
//                let temp = groupAnnotations.find {
//                    return groups.contains($0.station.id)
//                }
//                
//                if let groupAnnotation = temp {
//                    return groupAnnotation
//                }
//            }
//        }
//
//        // if there is an annotation stard for a friend, choose it show
//        if let userAnnotations = sortedAnnotations as? [UserAnnotation] {
//
//            if let friends = me.friends {
//                if let friendAnnotation = userAnnotations.find({ friends.contains($0.user.id) }) {
//                    return friendAnnotation
//                }
//            }
//        }

        return sortedAnnotations.first
    }

}

class UserCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var stationLabel: UILabel!

    var user: UserEntity!

    func setupDisplay() {

        if let photo = user.photo {
            avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: DefaultAvatarImage)
        }

        userNameLabel.text = user.nickName
        bioLabel.text = user.bio
        stationLabel.text = "\(user.primaryStation!.name)"
    }

}

class GroupCell: UITableViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var memberLabel: UILabel!

    var group: GroupEntity!

    func setupDisplay() {

        if let cover = group.cover {
            coverImageView.sd_setImageWithURL(NSURL(string: cover), placeholderImage: DefaultGroupImage)
        }

        nameLabel.text = group.name
        introLabel.text = group.introduction
        memberLabel.text = "\(group.members!.count)个成员"
    }
    
}

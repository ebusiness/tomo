//
//  MapViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/16.
//  Copyright © 2015 e-business. All rights reserved.
//

import UIKit

enum InterfaceMode: Int {
    case project
    case si
    case end
}

final class MapViewController: UIViewController {

    var mode = InterfaceMode.project

    let identifier = "annotationView"

    var allAnnotationMapView: MKMapView!

    var contents = [Any]()

    var lastLoadDate: Date?

    var annotationsForTable: [AggregatableAnnotation]?

    @IBOutlet weak fileprivate var mapView: MKMapView!
    @IBOutlet weak fileprivate var segmentedControl: UISegmentedControl!
    @IBOutlet weak fileprivate var tableView: UITableView!
    @IBOutlet weak fileprivate var tableViewTopConstrian: NSLayoutConstraint!
    @IBOutlet weak fileprivate var tableViewHeightConstranit: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.allAnnotationMapView = MKMapView(frame: CGRect.zero)

        self.loadContents()

        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}

// MARK: Action

extension MapViewController {

    @IBAction func changeMode(_ sender: Any) {

        self.hideTableView()

        let segmentControl = sender as? UISegmentedControl

        segmentControl?.isEnabled = false

        switch segmentControl!.selectedSegmentIndex {
        case 0:
            self.mode = .project
            self.loadContents()
        case 1:
            self.mode = .si
            self.loadContents()
        case 2:
            self.mode = .end
            self.loadContents()
        default:
            return
        }
    }

    @IBAction func mapViewTapped(_ sender: Any) {
        self.hideTableView()
    }
}

// MARK: MapView Delegate

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if mapView != self.mapView {
            return nil
        }

        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if let annotationView = annotationView as? AggregatableAnnotationView {
            annotationView.annotation = annotation
            annotationView.setupDisplay()
        } else {
            annotationView = AggregatableAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        return annotationView
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.updateVisibleAnnotations()
    }

    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {

        views.forEach { view in

            guard let view = view as? AggregatableAnnotationView else { return }

            view.setupDisplay()

            guard let annotation = view.annotation as? AggregatableAnnotation else { return }
            guard let clusterAnnotation = annotation.clusterAnnotation else { return }

            // animate the annotation from it's old container's coordinate, to its actual coordinate
            let actualCoordinate = annotation.coordinate
            let containerCoordinate = clusterAnnotation.coordinate

            // since it's displayed on the map, it is no longer contained by another annotation,
            // (We couldn't reset this in -updateVisibleAnnotations because we needed the reference to it here
            // to get the containerCoordinate)
            annotation.clusterAnnotation = nil

            annotation.coordinate = containerCoordinate

            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                annotation.coordinate = actualCoordinate
            })

        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        mapView.deselectAnnotation(view.annotation, animated: true)
        guard let view = view as? AggregatableAnnotationView else { return }
        guard let annotation = view.annotation as? AggregatableAnnotation else { return }

        if annotation.containedAnnotations.isEmpty {
            // group
//            let pvc = Util.createViewController(storyboardName: "Group", id: "GroupDetailView") as? GroupDetailViewController
//            pvc!.group = groupAnnotation!.group
//
//            self.navigationController?.pushViewController(pvc!, animated: true)
            // company
            // user
//            let pvc = Util.createViewController(storyboardName: "Profile", id: "UserPostsView") as? UserPostsViewController
//            pvc!.user = userAnnotation!.user
        } else {
            self.annotationsForTable = annotation.containedAnnotations
            self.annotationsForTable?.append(annotation)

            self.tableView.reloadData()

            if self.tableView.contentSize.height > UIScreen.main.bounds.height * 2 / 5 {
                self.tableViewHeightConstranit.constant = UIScreen.main.bounds.height * 2 / 5
            } else {
                self.tableViewHeightConstranit.constant = self.tableView.contentSize.height
            }

            UIView.animate(withDuration: TomoConst.Duration.Short, animations: {
                self.tableViewTopConstrian.constant = self.tableViewHeightConstranit.constant
                self.view.layoutIfNeeded()
            })
        }
    }
}

// MARK: Contents

extension MapViewController {

    fileprivate func loadContents() {

        self.allAnnotationMapView.removeAnnotations(self.allAnnotationMapView.annotations)
        self.mapView.removeAnnotations(self.mapView.annotations)

        switch self.mode {
        case .project:
            var parameters = Router.Group.MapParameters(category: .all)
            parameters.type = .station
            parameters.hasMembers = true
            findGroups(parameters: parameters)
        case .si:
            let parameters = Router.Company.Parameters(type: .si)
            self.findCompanies(parameters: parameters)
        case .end:
            let parameters = Router.Company.Parameters(type: .end)
            self.findCompanies(parameters: parameters)
        }
    }

    private func findCompanies(parameters: Router.Company.Parameters) {
        Router.Company.find(parameters: parameters).response {
            if $0.result.isFailure {
                self.segmentedControl.isEnabled = true
                return
            }

            guard let companies: [CompanyEntity] = CompanyEntity.collection($0.result.value!) else { return }

            let annotations = companies.map { company -> CompanyAnnotation in
                let annotation = CompanyAnnotation()
                annotation.entity = company
                return annotation
            }
            self.addAnnotations(annotations)
        }
    }

    private func findGroups(parameters: Router.Group.MapParameters) {
        Router.Group.Map(parameters: parameters).response {
            if $0.result.isFailure {
                self.segmentedControl.isEnabled = true
                return
            }

            guard let groups: [GroupEntity] = GroupEntity.collection($0.result.value!) else { return }

            let annotations = groups.map { group -> GroupAnnotation in
                let annotation = GroupAnnotation()
                annotation.group = group
                return annotation
            }
            self.addAnnotations(annotations)
        }
    }

    private func findFriends() {
        Router.User.Map.response {
            if $0.result.isFailure {
                self.segmentedControl.isEnabled = true
                return
            }

            guard let users: [UserEntity] = UserEntity.collection($0.result.value!) else { return }

            let annotations = users.map { user -> UserAnnotation in
                let annotation = UserAnnotation()
                annotation.user = user
                if let station = user.primaryGroup {
                    if let lon = station.coordinate?[1], let lat = station.coordinate?[0] {
                        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    }
                }
                return annotation
            }
            self.addAnnotations(annotations)
        }
    }

    private func addAnnotations(_ annotations: [MKAnnotation]) {
        self.allAnnotationMapView.addAnnotations(annotations)
        self.adjustRegion(annotations: self.allAnnotationMapView.annotations)
        self.updateVisibleAnnotations()
        self.lastLoadDate = Date()

        self.segmentedControl.isEnabled = true
    }
}

// MARK: Internal Methods

extension MapViewController {

    fileprivate func hideTableView() {
        UIView.animate(withDuration: TomoConst.Duration.Short, animations: {
            self.tableViewTopConstrian.constant = 0
            self.view.layoutIfNeeded()
        })
    }

    fileprivate func updateVisibleAnnotations() {

        // This value to controls the number of off screen annotations are displayed.
        // A bigger number means more annotations, less chance of seeing annotation views pop in but decreased performance.
        // A smaller number means fewer annotations, more chance of seeing annotation views pop in but better performance.
        let marginFactor = 1.0

        // Adjust this roughly based on the dimensions of your annotations views.
        // Bigger numbers more aggressively coalesce annotations (fewer annotations displayed but better performance).
        // Numbers too small result in overlapping annotations views and too many annotations on screen.
        let bucketSize = 120.0

        // find all the annotations in the visible area + a wide margin to avoid popping annotation views in and out while panning the map.
        let visibleMapRect = mapView.visibleMapRect
        let adjustedVisibleMapRect = MKMapRectInset(visibleMapRect, -marginFactor * visibleMapRect.size.width, -marginFactor * visibleMapRect.size.height)

        // determine how wide each bucket will be, as a MKMapRect square
        let leftCoordinate = mapView.convert(CGPoint.zero, toCoordinateFrom: mapView)
        let rightCoordinate = mapView.convert(CGPoint(x: CGFloat(bucketSize), y: CGFloat(0.0)), toCoordinateFrom: mapView)

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

                let allAnnotationsInBucket = allAnnotationMapView.annotations(in: gridMapRect)
                let visibleAnnotationsInBucket = mapView.annotations(in: gridMapRect)

                var allAnnotations = Array(allAnnotationsInBucket) as? [AggregatableAnnotation]

                if let annotationForGrid = self.annotation(inGrid: gridMapRect, annotations: allAnnotations!) as? AggregatableAnnotation {

                    allAnnotations!.remove(annotationForGrid)

                    // give the annotationForGrid a reference to all the annotations it will represent
                    annotationForGrid.containedAnnotations = allAnnotations!

                    mapView.addAnnotation(annotationForGrid)

                    if let view = mapView.view(for: annotationForGrid) as? AggregatableAnnotationView {
                        view.setupDisplay()
                    }

                    for annotation in allAnnotations! {

                        // give all the other annotations a reference to the one which is representing them
                        annotation.clusterAnnotation = annotationForGrid
                        annotation.containedAnnotations = [AggregatableAnnotation]()

                        // remove annotations which we've decided to cluster
                        if visibleAnnotationsInBucket.contains(annotation) {

                            let actualCoordinate = annotation.coordinate

                            UIView.animate(withDuration: 0.3, animations: { () -> Void in
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

    fileprivate func adjustRegion(annotations: [MKAnnotation]) {

        guard !annotations.isEmpty else {
            return
        }

        let mapPoints = annotations.map {
            MKMapPointForCoordinate($0.coordinate)
        }

        let horizontalSortedPoints = mapPoints.sorted { $0.x < $1.x }
        let verticalSortedPoints = mapPoints.sorted { $0.y < $1.y }

        let leftPoint = horizontalSortedPoints.first!
        let rightPoint = horizontalSortedPoints.last!
        let topPoint = verticalSortedPoints.first!
        let bottomPoint = verticalSortedPoints.last!

        let mapRect = MKMapRect(origin: MKMapPoint(x: leftPoint.x, y: topPoint.y),
                                   size: MKMapSize(width: rightPoint.x - leftPoint.x,
                                                   height: bottomPoint.y - topPoint.y))
        let edgePadding = UIEdgeInsets(top: 120, left: 80, bottom: 120, right: 80)

        let adjustRect = self.mapView.mapRectThatFits(mapRect, edgePadding: edgePadding)
        let adjustRegion = MKCoordinateRegionForMapRect(adjustRect)

        self.mapView.setRegion(adjustRegion, animated: true)

    }

    fileprivate func annotation(inGrid: MKMapRect, annotations: [AnyHashable]) -> AnyHashable? {

        // first, see if one of the annotations we were already showing is in this mapRect
        let visibleAnnotationsInBucket = mapView.annotations(in: inGrid)

        for annotation in annotations {
            if visibleAnnotationsInBucket.contains(annotation) {
                return annotation
            }
        }

        // otherwise, sort the annotations based on their distance from the center of the grid square,
        // then choose the one closest to the center to show
        let centerMapPoint = MKMapPoint(x: MKMapRectGetMidX(inGrid), y: MKMapRectGetMidY(inGrid))
        let sortedAnnotations = annotations.sorted { (obj1, obj2) -> Bool in

            let mapPoint1 = MKMapPointForCoordinate((obj1 as? MKAnnotation)!.coordinate)
            let mapPoint2 = MKMapPointForCoordinate((obj2 as? MKAnnotation)!.coordinate)

            let distance1 = MKMetersBetweenMapPoints(mapPoint1, centerMapPoint)
            let distance2 = MKMetersBetweenMapPoints(mapPoint2, centerMapPoint)

            if distance1 < distance2 {
                return true
            } else {
                return false
            }
        }

        return sortedAnnotations.first
    }
}

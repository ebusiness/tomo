//
//  ProjectSearchViewController.swift
//  Tomo
//
//  Created by 李超逸 on 2017/4/5.
//  Copyright © 2017年  e-business. All rights reserved.
//

import Foundation

final class ProjectSearchViewController: UIViewController {

    @IBOutlet fileprivate weak var mapView: MKMapView!
    @IBOutlet fileprivate weak var searchTextField: UITextField!
    @IBOutlet fileprivate weak var searchCancelButton: UIButton!
    @IBOutlet fileprivate weak var searchHereButton: UIButton!

    fileprivate var tapOnMapGuesture: UITapGestureRecognizer?
    fileprivate var dragOnMapGuesture: UIPanGestureRecognizer?

    fileprivate var searchHereButtonDisappearTimer: Timer?
    fileprivate var userDragToShowSearhButton = false

    let annotationViewIdentifier = "annotationViewIdentifier"

    var annotationHolder = [String: ProjectAnnotation]()
    var lastQueryAnnotations: [ProjectAnnotation]?
    var mapSpanOld: Double?

    override func viewDidLoad() {
        super.viewDidLoad()

        mapInit()
        searchBarInit()
    }

    @IBAction func searchCancelTapped(_ sender: UIButton) {
        searchTextField.text = nil
        sender.isHidden = true
    }
    @IBAction func searchTextChanged(_ sender: UITextField) {
        searchCancelButton.isHidden = !sender.hasText
    }
    @IBAction func searchHereTapped(_ sender: UIButton) {
        searchHereButtonFadeout()
        searchProjectsInVision()
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - internal methods

extension ProjectSearchViewController {
    fileprivate func mapInit() {

        centerUserLocation()

        dragOnMapGuesture = UIPanGestureRecognizer(target: self, action: #selector(dragOnMap(_:)))
        dragOnMapGuesture?.delegate = self
        mapView.addGestureRecognizer(dragOnMapGuesture!)

    }

    fileprivate func searchBarInit() {
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: searchTextField.frame.size.height))
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: searchTextField.frame.size.height))

        searchTextField.leftViewMode = .always
        searchTextField.rightViewMode = .always

        searchTextField.leftView = leftView
        searchTextField.rightView = rightView
    }

    fileprivate func centerUserLocation() {
        LocationController.shareInstance.doActionWithLocation { location in

            let noLocation = CLLocationCoordinate2D()
            let viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 600, 600)
            self.mapView.setRegion(viewRegion, animated: false)

            var center: CLLocationCoordinate2D!

            if let location = location {
                center = CLLocationCoordinate2D(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude)
            } else {
                center = CLLocationCoordinate2D(
                    latitude: TomoConst.Geo.Tokyo.Latitude,
                    longitude: TomoConst.Geo.Tokyo.Longitude)
            }

            self.mapView.setCenter(center, animated: false)

            self.searchProjectsInVision()

        }
    }

    fileprivate func searchProjectsInVision() {

        let visibleMapRect = mapView.visibleMapRect

        let nwMapPoint = MKMapPointMake(MKMapRectGetMinX(visibleMapRect), MKMapRectGetMaxY(visibleMapRect))
        let seMapPoint = MKMapPointMake(MKMapRectGetMaxX(visibleMapRect), MKMapRectGetMinY(visibleMapRect))
        let nwCoord = MKCoordinateForMapPoint(nwMapPoint)
        let seCoord = MKCoordinateForMapPoint(seMapPoint)

        var parameters = Router.Project.FindParameters()
        parameters.box = [nwCoord.latitude, nwCoord.longitude, seCoord.latitude, seCoord.longitude]

        Router.Project.find(parameters: parameters).response { dataResponse in

            if dataResponse.result.isFailure {
                // 404: No result
                if dataResponse.response?.statusCode == TomoConst.NetResponseCode.NoData {
                    let alert = UIAlertController(title: nil,
                                                  message: "在此区域内没有找到相关项目。",
                                                  preferredStyle: .alert)

                    let cancelAction = UIAlertAction(title: "确定",
                                                     style: .cancel)

                    alert.addAction(cancelAction)
                    self.present(alert, animated: true)
                }
                return
            } else {
                // Data Exist
                guard let projects: [ProjectEntity] = ProjectEntity.collection(dataResponse.result.value!)
                    else { return }

                self.lastQueryAnnotations = projects.map { project -> ProjectAnnotation in
                    if let annotation = self.annotationHolder[project.id] {
                        return annotation
                    } else {
                        return ProjectAnnotation(project: project)
                    }
                }
                self.holdAnnotations(self.lastQueryAnnotations!)
                self.mapView.updateVisibleAnnotations(candidateAnnotations: self.lastQueryAnnotations!)
            }
        }

    }

    func lockMap() {
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        addTapOnMapGuesture()
    }

    func unlockMap() {
        removeTapOnMapGuesture()
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
    }

    fileprivate func addTapOnMapGuesture() {
        tapOnMapGuesture = UITapGestureRecognizer(target: self, action: #selector(tapOnMap(_:)))
        mapView.addGestureRecognizer(tapOnMapGuesture!)
    }

    fileprivate func removeTapOnMapGuesture() {
        if let tapOnMapGuesture = tapOnMapGuesture {
            mapView.removeGestureRecognizer(tapOnMapGuesture)
        }
        tapOnMapGuesture = nil
    }

    @objc
    fileprivate func tapOnMap(_ sender: UIGestureRecognizer) {
        unlockMap()
        searchTextField.resignFirstResponder()
    }

    @objc
    fileprivate func searchHereButtonFadein() {

        self.searchHereButton.isHidden = false
        UIView.animate(withDuration: TomoConst.Duration.Short, animations: {
            self.searchHereButton.alpha = 1
        })
        self.searchHereButtonDisappearTimer?.invalidate()
        self.searchHereButtonDisappearTimer = nil
        userDragToShowSearhButton = false

    }

    fileprivate func searchHereButtonFadeout() {
        UIView.animate(withDuration: TomoConst.Duration.Medium, animations: {
            self.searchHereButton.alpha = 0
        }, completion: { _ in
            self.searchHereButton.isHidden = true
        })
    }

    @objc
    fileprivate func dragOnMap(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            userDragToShowSearhButton = true
        }
    }

}

// MARK: - UITextFieldDelegate
extension ProjectSearchViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        lockMap()
    }

}

// MARK: - MKMapViewDelegate
extension ProjectSearchViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if searchHereButton.isHidden && userDragToShowSearhButton {
            searchHereButtonDisappearTimer = Timer.scheduledTimer(timeInterval: TomoConst.Duration.Medium,
                                                                  target: self,
                                                                  selector: #selector(searchHereButtonFadein),
                                                                  userInfo: nil,
                                                                  repeats: false)
        }

        if let mapSpanOld = mapSpanOld, let lastQueryAnnotations = lastQueryAnnotations {
            let mapSpanNew = mapView.visibleMapRect.size.width
            let diff = Swift.abs(mapSpanOld - mapSpanNew)
            if diff > 1e-5 {
                mapView.updateVisibleAnnotations(candidateAnnotations: lastQueryAnnotations)
            }
        }

        if mapSpanOld == nil {
            mapSpanOld = mapView.visibleMapRect.size.width
        }
    }

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        searchHereButtonDisappearTimer?.invalidate()
        searchHereButtonDisappearTimer = nil
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        return nil
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationViewIdentifier)
//
//        if let annotationView = annotationView as? AggregatableAnnotationView {
//            annotationView.annotation = annotation
//            annotationView.setupDisplay()
//        } else {
//            annotationView = AggregatableAnnotationView(annotation: annotation,
//                                                        reuseIdentifier: annotationViewIdentifier)
//        }
//
//        return annotationView
    }

    func holdAnnotations(_ annotations: [ProjectAnnotation]) {
        annotations.forEach { annotation in
            if !self.annotationHolder.keys.contains(annotation.project.id) {
                self.annotationHolder[annotation.project.id] = annotation
            }
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ProjectSearchViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == dragOnMapGuesture {
            return true
        }
        return false
    }
}

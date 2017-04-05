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

    fileprivate var tapOnMapGuesture: UITapGestureRecognizer?

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
}

// MARK: - internal methods

extension ProjectSearchViewController {
    fileprivate func mapInit() {

        centerUserLocation(isInit: true)

    }

    fileprivate func searchBarInit() {
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: searchTextField.frame.size.height))
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: searchTextField.frame.size.height))

        searchTextField.leftViewMode = .always
        searchTextField.rightViewMode = .always

        searchTextField.leftView = leftView
        searchTextField.rightView = rightView
    }

    fileprivate func centerUserLocation(isInit: Bool = false) {
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

            if isInit {
                self.searchProjectsNearby()
            }

        }
    }

    fileprivate func searchProjectsNearby() {

        let visibleMapRect = mapView.visibleMapRect

        let neMapPoint = MKMapPointMake(MKMapRectGetMaxX(visibleMapRect), visibleMapRect.origin.y)
        let swMapPoint = MKMapPointMake(visibleMapRect.origin.x, MKMapRectGetMaxY(visibleMapRect))
        let neCoord = MKCoordinateForMapPoint(neMapPoint)
        let swCoord = MKCoordinateForMapPoint(swMapPoint)

        var parameters = Router.Group.FindParameters(category: .all)
        parameters.type = .station
        parameters.box = [neCoord.latitude, neCoord.longitude, swCoord.latitude, swCoord.longitude]

        Router.Group.find(parameters: parameters).response {

            if $0.result.isFailure { return }
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

}

// MARK: - UITextFieldDelegate
extension ProjectSearchViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        lockMap()
    }

}

//
//  ClustrMapViewController.swift
//  Clustr
//
//  Created by Wei Lin on 10/17/15.
//  Copyright © 2015 Wei Lin.Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire

class ClustrMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    private struct Constants {
        static let DestinationRegionRadius:CLLocationDistance = 500
        static let RegionRadius:CLLocationDistance = 1000
    }

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
//    var mapDidFinishedLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = CLLocationDistance(10)
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        mapView.delegate = self
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(manager.location!.coordinate)
        print(mapView.region.span.latitudeDelta)
        centerMapViewOnLocation(manager.location!)
        let id = UIDevice.currentDevice().identifierForVendor?.UUIDString
        pingServer(Double((manager.location?.coordinate.latitude)!), latitude: Double((manager.location?.coordinate.latitude)!), deviceToken: id!)
    }
    
    func mapViewWillStartRenderingMap(mapView: MKMapView) {
        print(mapView.subviews.count)
        if mapView.subviews.count > 1 {
            mapView.subviews.last?.removeFromSuperview()
        }
    }
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        while mapView.subviews.count > 1 {
            mapView.subviews.last?.removeFromSuperview()
        }
    }
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        let topLeftCorner = convertPointToMap(CGPointZero)
        let botRightCorner = convertPointToMap(CGPoint(x: mapView.bounds.maxX, y: mapView.bounds.maxY))
        getMap(Double(topLeftCorner.latitude), topLeftCornerLong: Double(topLeftCorner.latitude), botRightCornerLat: Double(botRightCorner.latitude), botRightCornerLong: Double(botRightCorner.latitude))
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let topLeftCorner = convertPointToMap(CGPointZero)
        let botRightCorner = convertPointToMap(CGPoint(x: mapView.bounds.maxX, y: mapView.bounds.maxY))
        getMap(Double(topLeftCorner.latitude), topLeftCornerLong: Double(topLeftCorner.latitude), botRightCornerLat: Double(botRightCorner.latitude), botRightCornerLong: Double(botRightCorner.latitude))
    }
    
    @IBAction func panMapView(sender: UIPanGestureRecognizer) {
        while mapView.subviews.count > 1 {
            mapView.subviews.last?.removeFromSuperview()
        }
    }
    
    func centerMapViewOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, Constants.RegionRadius, Constants.RegionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
//        mapDidFinishedLoading = true
    }
    
    
    func convertPointToMap(point: CGPoint)-> CLLocationCoordinate2D {
        return mapView.convertPoint(point, toCoordinateFromView: mapView)
    }
    
    func pingServer(longitude: Double, latitude: Double, deviceToken: String) -> Void {
        Alamofire.request(.GET, "http://52.88.179.215/ping", parameters: ["latitude" : latitude, "longitude" : longitude, "device_token" : deviceToken])
            .responseJSON { response in
        }
    }

    func getMap(topLeftCornerLat: Double, topLeftCornerLong: Double, botRightCornerLat: Double, botRightCornerLong: Double) {
        Alamofire.request(.GET, "http://52.88.179.215/get_map", parameters: ["corner_tl_lat" : topLeftCornerLat, "corner_tl_long" : topLeftCornerLong, "corner_br_lat" : botRightCornerLat, "corner_br_long" : botRightCornerLong])
            .responseJSON { response in
            }
    }

    
    func drawHeatMap(locations:[CLLocation], weights:[Int]) {
//        mapView.subviews.last?.removeFromSuperview()
        let heatImage = LFHeatMap.heatMapForMapView(mapView, boost: 1.0, locations: locations, weights: weights)
        let image = UIImageView(image: heatImage)
        mapView.addSubview(image)
    }
}

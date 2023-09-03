////
////  LocationManager.swift
////  ObjectDetection-CoreML
////
////  Created by 정서연 on 2023/08/29.
////  Copyright © 2023 tucan9389. All rights reserved.
////
//
//import Foundation
//import CoreLocation
//import MapKit
//
//class LocationManager: NSObject, CLLocationManagerDelegate {
//    private var locationManager: CLLocationManager?
//    var mapView: MKMapView?
//
//    init(mapView: MKMapView) {
//        super.init()
//        self.mapView = mapView
//        setupLocationManager()
//    }
//
//    func setupLocationManager() {
//        locationManager = CLLocationManager()
//        locationManager?.requestWhenInUseAuthorization()
//        locationManager?.delegate = self
//        locationManager?.allowsBackgroundLocationUpdates = true
//    }
//
//    func startUpdatingLocation() {
//        locationManager?.startUpdatingLocation()
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.last {
//            print("Lat: \(location.coordinate.latitude) \nLng: \(location.coordinate.longitude)")
//
//            // Update the map view's
//        }}
//
//}

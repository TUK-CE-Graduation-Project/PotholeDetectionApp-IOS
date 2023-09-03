//
//  MapViewController.swift
//  ObjectDetection-CoreML
//
//  Created by 정서연 on 2023/09/03.
//  Copyright © 2023 tucan9389. All rights reserved.
//



import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    let mapView = MapViewUI()
    let locationManager = CLLocationManager()
    let sesacCoordinate = CLLocationCoordinate2D(latitude: 37.51818789942772, longitude: 126.88541765534976)    /// 시작 위치
    
    override func loadView() {
        view = mapView
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        
        mapView.map.setRegion(MKCoordinateRegion(center: sesacCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
        
        
        mapView.map.delegate = self
        
        locationManager.delegate = self
                
        buttonActions()
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
           guard !annotation.isKind(of: MKUserLocation.self) else {
    
               return nil
           }

           var annotationView = self.mapView.map.dequeueReusableAnnotationView(withIdentifier: "Custom")
           
           if annotationView == nil {
               annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Custom")
               annotationView?.canShowCallout = true
               
               
               let miniButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
               miniButton.setImage(UIImage(systemName: "person"), for: .normal)
               miniButton.tintColor = .blue
               annotationView?.rightCalloutAccessoryView = miniButton
               
           } else {
               annotationView?.annotation = annotation
           }
           
           annotationView?.image = UIImage(named: "Circle")
                      
           return annotationView
       }
       
    @objc func findMyLocation() {
           
        guard locationManager.location != nil else{
            checkUserLocationServicesAuthorization()
            return
        }
           
        mapView.map.showsUserLocation = true
           
        mapView.map.setUserTrackingMode(.follow, animated: true)
    }
    
    @objc func nextButtonTapped() {
        // 다음 뷰 컨트롤러의 인스턴스 생성
        let nextViewController = ObjectDetectingViewController()

        let navigationController = UINavigationController(rootViewController: nextViewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)

    }

       
       //권한 설정을 위한 코드들
       
       func checkCurrentLocationAuthorization(authorizationStatus: CLAuthorizationStatus) {
           switch authorizationStatus {
           case .notDetermined:
               locationManager.requestWhenInUseAuthorization()
               locationManager.startUpdatingLocation()
           case .restricted:
               print("restricted")
               goSetting()
           case .denied:
               print("denided")
               goSetting()
           case .authorizedAlways:
               print("always")
           case .authorizedWhenInUse:
               print("wheninuse")
               locationManager.startUpdatingLocation()
           @unknown default:
               print("unknown")
           }
           if #available(iOS 14.0, *) {
               let accuracyState = locationManager.accuracyAuthorization
               switch accuracyState {
               case .fullAccuracy:
                   print("full")
               case .reducedAccuracy:
                   print("reduced")
               @unknown default:
                   print("Unknown")
               }
           }
       }
       
       func goSetting() {
           
           let alert = UIAlertController(title: "위치권한 요청", message: "위치 권한이 필요합니다.", preferredStyle: .alert)
           let settingAction = UIAlertAction(title: "설정", style: .default) { action in
               guard let url = URL(string: UIApplication.openSettingsURLString) else { return }

               if UIApplication.shared.canOpenURL(url) {
                   UIApplication.shared.open(url)
               }
           }
           let cancelAction = UIAlertAction(title: "취소", style: .cancel) { UIAlertAction in
               
           }
           
           alert.addAction(settingAction)
           alert.addAction(cancelAction)
           
           present(alert, animated: true, completion: nil)
       }
       
       func checkUserLocationServicesAuthorization() {
           let authorizationStatus: CLAuthorizationStatus
           if #available(iOS 14, *) {
               authorizationStatus = locationManager.authorizationStatus
           } else {
               authorizationStatus = CLLocationManager.authorizationStatus()
           }
           
           if CLLocationManager.locationServicesEnabled() {
               checkCurrentLocationAuthorization(authorizationStatus: authorizationStatus)
           }
       }
       
       func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
           print(#function)
           checkUserLocationServicesAuthorization()
       }

       func buttonActions() {
           mapView.myLocationButton.addTarget(self, action: #selector(findMyLocation), for: .touchUpInside)
           mapView.startDrivingButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
       }
}

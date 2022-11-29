//
//  HomeViewController.swift
//  desafio_mobile
//
//  Created by Johnny Camacho on 28/11/22.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseAnalytics

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        return locationManager
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
    }
}

// MARK: - Private functions
extension HomeViewController {
    
    private func updateMap(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
    }
    
    private func updateMap(_ location: CLLocation) {
        updateMap(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
}

// MARK: - LocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            Analytics.logEvent("permission_location", parameters: [
                "granted": true,
                "authorization_status": locationManager.authorizationStatus.rawValue
            ])
            
            locationManager.startUpdatingLocation()
        case .restricted, .denied:
            Analytics.logEvent("permission_location", parameters: [
                "granted": false,
                "authorization_status": locationManager.authorizationStatus.rawValue
            ])
            
            presentAlert(withMessage: "To use the app we need your location.")
            break
        case .notDetermined:
            Analytics.logEvent("request_permission_location", parameters: nil)
            
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            fatalError()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        let latitude = location.coordinate.latitude.description
        let longitude = location.coordinate.longitude.description
        
        Analytics.logEvent("location", parameters: [
            "latitude": latitude,
            "longitude": longitude
        ])
        
        if let user = AuthService.shared.getCurrentUser() {
            FirestoreService.shared.updateUserLocation(userUid: user.uid, latitude: latitude, longitude: longitude)
            CoredataService.shared.updateUserLocation(userUid: user.uid, latitude: latitude, longitude: longitude)
        }
        
        updateMap(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .locationUnknown {
            return
        }
        
        presentAlert(withError: error)
    }
}

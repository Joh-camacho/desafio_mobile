//
//  HomeViewModel.swift
//  desafio_mobile
//
//  Created by Johnny Camacho on 29/11/22.
//

import Foundation
import CoreLocation
import FirebaseAnalytics

protocol HomeViewDelegate: AnyObject {
    
    func locationService(didUpdateLocation location: CLLocation)
    func locationService(didFailToUpdateLocationWith error: Error)
    
}

class HomeViewModel: NSObject {
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        return locationManager
    }()
    
    weak var delegate: HomeViewDelegate?
    
    func loadLastLocation() {
        guard let user = AuthService.shared.getCurrentUser() else { return }
        
        FirestoreService.shared.getUserInfo(userUid: user.uid) { [weak self] response in
            guard let self = self else { return }
            
            switch response {
            case .success(let data):
                let lastLatitude = data["last_latitude"] as? Double
                let lastLongitude = data["last_longitude"] as? Double
                
                guard let lastLatitude = lastLatitude, let lastLongitude = lastLongitude else {
                    return
                }
                
                let location = CLLocation(latitude: lastLatitude, longitude: lastLongitude)
                
                self.delegate?.locationService(didUpdateLocation: location)
            case .failure(let error):
                self.delegate?.locationService(didFailToUpdateLocationWith: error)
            }
        }
    }
    
    func requestCurrentLocation() {
        locationManager.delegate = self
    }
}

// MARK: - LocationManagerDelegate
extension HomeViewModel: CLLocationManagerDelegate {
    
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
            
            delegate?.locationService(didFailToUpdateLocationWith: CLError(.denied))
            break
        case .notDetermined:
            Analytics.logEvent("request_permission_location", parameters: nil)
            
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            delegate?.locationService(didFailToUpdateLocationWith: CLError(.historicalLocationError))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        Analytics.logEvent("location", parameters: [
            "latitude": latitude,
            "longitude": longitude
        ])
        
        if let user = AuthService.shared.getCurrentUser() {
            FirestoreService.shared.updateUserLocation(userUid: user.uid, latitude: latitude, longitude: longitude)
            CoredataService.shared.updateUserLocation(userUid: user.uid, latitude: latitude, longitude: longitude)
        }
        
        delegate?.locationService(didUpdateLocation: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .locationUnknown {
            return
        }
        
        delegate?.locationService(didFailToUpdateLocationWith: error)
    }
}

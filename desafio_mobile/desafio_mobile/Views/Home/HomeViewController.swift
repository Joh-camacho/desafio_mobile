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
    
    private let viewModel: HomeViewModel
    
    // MARK: - Init
    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle screen
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        viewModel.requestLocation()
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

// MARK: - HomeViewDelegate
extension HomeViewController: HomeViewDelegate {
    
    func locationService(didUpdateLocation location: CLLocation) {
        updateMap(location)
    }
    
    func locationService(didFailToUpdateLocationWith error: Error) {
        presentAlert(withError: error)
    }
}

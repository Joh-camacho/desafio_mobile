//
//  HomeViewController.swift
//  desafio_mobile
//
//  Created by Johnny Camacho on 28/11/22.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseAuth

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
        viewModel.loadLastLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.requestCurrentLocation()
    }
}

// MARK: - IBActions
extension HomeViewController {
    
    @IBAction func logoutButtonTouched() {
        do {
            try Auth.auth().signOut()
            
            presentLogin()
        } catch {
            presentAlert(withError: error)
        }
    }
}

// MARK: - Private functions
extension HomeViewController {
    
    private func presentLogin() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        
        present(loginVC, animated: true)
    }
    
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
        guard let error = error as? CLError, error.code == .denied else {
            presentAlert(withError: error)
            return
        }
        
        presentAlert(withMessage: "To use the app we need your location.")
    }
}

//
//  HomeViewModelTests.swift
//  desafio_mobileTests
//
//  Created by Johnny Camacho on 29/11/22.
//

import XCTest
import FirebaseFirestore
import CoreLocation
@testable import desafio_mobile

final class HomeViewModelTests: XCTestCase, HomeViewDelegate {
    
    class PersistenceServiceMock: PersistenceProtocol {
        
        var lastLatitude: Double = -22.903539
        var lastLongitude: Double = -43.209587
        
        var isMeanToFailure = false
        
        func createUser(email: String, userUid uid: String) { }
        func updateUserLocation(userUid uid: String, latitude: Double, longitude: Double) { }
        
        func getUserInfo(userUid uid: String, completion: @escaping completionHandler) {
            if !isMeanToFailure {
                let mockUser = DMUser(uid: uid, email: "", lastLatitude: lastLatitude, lastLongitute: lastLongitude)
                
                completion(.success(mockUser))
            } else {
                completion(.failure(FirestoreErrorCode(.notFound)))
            }
        }
    }
    
    var sut: HomeViewModel!
    var persistenceService: PersistenceServiceMock!
    var locationManager: CLLocationManager!
    
    var expectation: XCTestExpectation!
    var location: CLLocation?
    var error: Error?

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        persistenceService = PersistenceServiceMock()
        locationManager = CLLocationManager()
        
        sut = HomeViewModel(persistenceService: persistenceService, locationManager: locationManager)
        sut.delegate = self
    }

    override func tearDownWithError() throws {
        sut = nil
        persistenceService = nil
        locationManager = nil
        
        expectation = nil
        location = nil
        error = nil
        
        try super.tearDownWithError()
    }
    
    func testValidLoadLastLocation() {
        expectation = expectation(description: "Valid load last location")
        sut.loadLastLocation()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertNotNil(location)
    }
    
    func testLastLocationHasNoSaved() {
        let expectedError = CLError(.locationUnknown)
        
        expectation = expectation(description: "Last location has no saved")
        
        persistenceService.lastLatitude = 0.0
        persistenceService.lastLongitude = 0.0
        
        sut.loadLastLocation()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertNotNil(error)
        XCTAssertEqual(error! as? CLError, expectedError)
    }
    
    func testInvalidLoadLastLocation() {
        let expectedError = FirestoreErrorCode(.notFound)
        
        persistenceService.isMeanToFailure = true
        
        expectation = expectation(description: "Invalid load last location")
        sut.loadLastLocation()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertNotNil(error)
        XCTAssertEqual(error! as? FirestoreErrorCode, expectedError)
    }
    
    func locationService(didUpdateLocation location: CLLocation) {
        self.location = location
        
        expectation?.fulfill()
    }
    
    func locationService(didFailToUpdateLocationWith error: Error) {
        self.error = error
        
        expectation?.fulfill()
    }
}

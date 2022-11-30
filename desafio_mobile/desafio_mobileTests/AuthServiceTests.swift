//
//  AuthServiceTests.swift
//  desafio_mobileTests
//
//  Created by Johnny Camacho on 29/11/22.
//

import XCTest
import FirebaseAuth
@testable import desafio_mobile

final class AuthServiceTests: XCTestCase {
    
    class AuthRequestMock: AuthRequest {
        var triggerError: AuthErrorCode?
        
        func signIn(with email: String, password: String, completion: completionHandler) {
            if let triggerError = triggerError {
                completion?(nil, triggerError)
            } else {
                completion?(nil, nil)
            }
        }
        
        func createUser(with email: String, password: String, completion: completionHandler) {
            if let triggerError = triggerError {
                completion?(nil, triggerError)
            } else {
                completion?(nil, nil)
            }
        }
    }
    
    var sut: AuthServiceProtocol!
    var mock: AuthRequestMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mock = AuthRequestMock()
        sut = AuthService(authRequest: mock)
    }

    override func tearDownWithError() throws {
        sut = nil
        mock = nil
        
        try super.tearDownWithError()
    }
    
    func testLoginNotReturnData() {
        let expectation = expectation(description: "Returning mocked data nil")
        let email = "test@test.com"
        let password = "12345678"
        let expectedError = AuthErrorCode(.internalError)
        
        sut.loginUser(email: email, password: password) { result in
            switch result {
            case .success:
                XCTFail("This was not supposed to happen.")
            case .failure(let error):
                XCTAssertNotNil(error)
                XCTAssertEqual(expectedError, error as? AuthErrorCode)
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testLoginEmailInvalid() {
        let expectation = expectation(description: "Returning trigger a error")
        let email = "testtest.com"
        let password = "12345678"
        let expectedError = AuthErrorCode(.invalidEmail)
        
        mock.triggerError = expectedError
        
        sut.loginUser(email: email, password: password) { result in
            switch result {
            case .success:
                XCTFail("This was not supposed to happen.")
            case .failure(let error):
                XCTAssertNotNil(error)
                XCTAssertEqual(expectedError, error as? AuthErrorCode)
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testRegisterNotReturnData() {
        let expectation = expectation(description: "Returning mocked data nil")
        let email = "test@test.com"
        let password = "12345678"
        let expectedError = AuthErrorCode(.internalError)
        
        sut.registerUser(email: email, password: password) { result in
            switch result {
            case .success:
                XCTFail("This was not supposed to happen.")
            case .failure(let error):
                XCTAssertNotNil(error)
                XCTAssertEqual(expectedError, error as? AuthErrorCode)
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testRegisterEmailInvalid() {
        let expectation = expectation(description: "Returning trigger a error")
        let email = "testtest.com"
        let password = "12345678"
        let expectedError = AuthErrorCode(.invalidEmail)
        
        mock.triggerError = expectedError
        
        sut.registerUser(email: email, password: password) { result in
            switch result {
            case .success:
                XCTFail("This was not supposed to happen.")
            case .failure(let error):
                XCTAssertNotNil(error)
                XCTAssertEqual(expectedError, error as? AuthErrorCode)
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5)
    }
}

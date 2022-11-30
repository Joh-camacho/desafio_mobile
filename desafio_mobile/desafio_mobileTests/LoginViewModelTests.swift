//
//  LoginViewModelTests.swift
//  desafio_mobileTests
//
//  Created by Johnny Camacho on 29/11/22.
//

import XCTest
import FirebaseAuth
@testable import desafio_mobile

final class LoginViewModelTests: XCTestCase, LoginViewDelegate {
    
    class AuthServiceMock: AuthServiceProtocol {
        
        var isMeanToFailure = false
        
        func loginUser(email: String, password: String, completion: @escaping completionHandler) {
            if !isMeanToFailure {
                completion(.success(AuthService.getCurrentUser()!))
            } else {
                completion(.failure(AuthErrorCode(.internalError)))
            }
        }
        
        func registerUser(email: String, password: String, completion: @escaping completionHandler) {
            if !isMeanToFailure {
                completion(.success(AuthService.getCurrentUser()!))
            } else {
                completion(.failure(AuthErrorCode(.internalError)))
            }
        }
    }
    
    var sut: LoginViewModel!
    var authService: AuthServiceMock!
    
    var expectation: XCTestExpectation!
    var user: User?
    var error: Error?

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        authService = AuthServiceMock()
        
        sut = LoginViewModel(authService: authService)
        sut.delegate = self
    }

    override func tearDownWithError() throws {
        sut = nil
        authService = nil
        
        expectation = nil
        user = nil
        error = nil
        
        try super.tearDownWithError()
    }

    func testValidUserLogin() throws {
        let email = "user@test.com"
        let password = "123456789"
        
        expectation = expectation(description: "Valid User login")
        sut.loginUser(email: email, password: password)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertNotNil(user)
    }
    
    func testInvalidEmailUserLogin() throws {
        let email = "usertest.com"
        let password = "12345678"
        let expectedError = AuthValidationError.invalidEmail
        
        expectation = expectation(description: "Invalid email user login")
        sut.loginUser(email: email, password: password)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertNotNil(error)
        XCTAssertEqual(error! as? AuthValidationError, expectedError)
    }
    
    func testUserLoginWithError() throws {
        let email = "user@test.com"
        let password = "12345678"
        let expectedError = AuthErrorCode(.internalError)
        
        authService.isMeanToFailure = true
        
        expectation = expectation(description: "Invalid login user")
        sut.loginUser(email: email, password: password)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertNotNil(error)
        XCTAssertEqual(error! as? AuthErrorCode, expectedError)
    }
    
    func testValidUserRegister() throws {
        let email = "user@test.com"
        let password = "123456789"
        
        expectation = expectation(description: "Valid User register")
        sut.registerUser(email: email, password: password)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertNotNil(user)
    }
    
    func testInvalidEmailUserRegister() throws {
        let email = "usertest.com"
        let password = "12345678"
        let expectedError = AuthValidationError.invalidEmail
        
        expectation = expectation(description: "Invalid email user register")
        sut.registerUser(email: email, password: password)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertNotNil(error)
        XCTAssertEqual(error! as? AuthValidationError, expectedError)
    }
    
    func testUserRegisterWithError() throws {
        let email = "user@test.com"
        let password = "12345678"
        let expectedError = AuthErrorCode(.internalError)
        
        authService.isMeanToFailure = true
        
        expectation = expectation(description: "Invalid register user")
        sut.registerUser(email: email, password: password)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertNotNil(error)
        XCTAssertEqual(error! as? AuthErrorCode, expectedError)
    }

    func authService(didAuthenticate user: User) {
        self.user = user
        
        expectation?.fulfill()
    }
    
    func authService(didFailToAuthorizeWith error: Error) {
        self.error = error
        
        expectation?.fulfill()
    }
}

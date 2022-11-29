//
//  AuthValidationTests.swift
//  desafio_mobileTests
//
//  Created by Johnny Camacho on 29/11/22.
//

import XCTest
@testable import desafio_mobile

final class AuthValidationTests: XCTestCase {
    
    var sut: AuthValidation!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sut = AuthValidation()
    }

    override func tearDownWithError() throws {
        sut = nil
        
        try super.tearDownWithError()
    }
    
    func testPasswordNil() throws {
        let password: String? = nil
        let expectedError: AuthValidationError = .nilValue
        
        XCTAssertThrowsError(try sut.validatePassword(password)) { error in
            XCTAssertTrue(error is AuthValidationError, "Unexpected error type: \(type(of: error))")
            XCTAssertEqual(error as? AuthValidationError, expectedError)
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
    }

    func testPasswordTooShort() throws {
        let password = "1"
        let expectedError: AuthValidationError = .passwordTooShort
        
        XCTAssertThrowsError(try sut.validatePassword(password)) { error in
            XCTAssertTrue(error is AuthValidationError, "Unexpected error type: \(type(of: error))")
            XCTAssertEqual(error as? AuthValidationError, expectedError)
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
    }
    
    func testPasswordTooLong() throws {
        let password = "aaaaaaaaaaaaaaaaaaaa"
        let expectedError: AuthValidationError = .passwordTooLong
        
        XCTAssertThrowsError(try sut.validatePassword(password)) { error in
            XCTAssertTrue(error is AuthValidationError, "Unexpected error type: \(type(of: error))")
            XCTAssertEqual(error as? AuthValidationError, expectedError)
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
    }
    
    func testNameEventValid() throws {
        let password = "12345678"
        
        do {
            let validatePassword = try sut.validatePassword(password)
            
            XCTAssertEqual(validatePassword, password)
        } catch {
            XCTFail("Password is not invalid.")
        }
    }
    
    func testEmailNil() throws {
        let email: String? = nil
        let expectedError: AuthValidationError = .nilValue
        
        XCTAssertThrowsError(try sut.validateEmail(email)) { error in
            XCTAssertTrue(error is AuthValidationError, "Unexpected error type: \(type(of: error))")
            XCTAssertEqual(error as? AuthValidationError, expectedError)
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
    }
    
    func testInvalidEmailWithoutAtSymbol() throws {
        let email = "testgmail.com"
        let expectedError: AuthValidationError = .invalidEmail
        
        XCTAssertThrowsError(try sut.validateEmail(email)) { error in
            XCTAssertTrue(error is AuthValidationError, "Unexpected error type: \(type(of: error))")
            XCTAssertEqual(error as? AuthValidationError, expectedError)
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
    }
    
    func testInvalidEmailWithoutSuffix() throws {
        let email = "@gmail.com"
        let expectedError: AuthValidationError = .invalidEmail
        
        XCTAssertThrowsError(try sut.validateEmail(email)) { error in
            XCTAssertTrue(error is AuthValidationError, "Unexpected error type: \(type(of: error))")
            XCTAssertEqual(error as? AuthValidationError, expectedError)
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
    }
    
    func testInvalidEmailWithoutPreffix() throws {
        let email = "test@"
        let expectedError: AuthValidationError = .invalidEmail
        
        XCTAssertThrowsError(try sut.validateEmail(email)) { error in
            XCTAssertTrue(error is AuthValidationError, "Unexpected error type: \(type(of: error))")
            XCTAssertEqual(error as? AuthValidationError, expectedError)
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
    }
    
    func testInvalidEmailWithoutDot() throws {
        let email = "test@gmailcom"
        let expectedError: AuthValidationError = .invalidEmail
        
        XCTAssertThrowsError(try sut.validateEmail(email)) { error in
            XCTAssertTrue(error is AuthValidationError, "Unexpected error type: \(type(of: error))")
            XCTAssertEqual(error as? AuthValidationError, expectedError)
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
    }
    
    func testInvalidEmailWithoutDomain() throws {
        let email = "test@gmail"
        let expectedError: AuthValidationError = .invalidEmail
        
        XCTAssertThrowsError(try sut.validateEmail(email)) { error in
            XCTAssertTrue(error is AuthValidationError, "Unexpected error type: \(type(of: error))")
            XCTAssertEqual(error as? AuthValidationError, expectedError)
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
    }
    
    func testValidEmail() throws {
        let email = "test@gmail.com"
        
        do {
            let validateEmail = try sut.validateEmail(email)
            
            XCTAssertEqual(validateEmail, email)
        } catch {
            XCTFail("Email is not invalid.")
        }
    }
}

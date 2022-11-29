//
//  LoginValidation.swift
//  desafio_mobile
//
//  Created by Johnny Camacho on 29/11/22.
//

import Foundation

enum AuthValidationError: LocalizedError {
    case nilValue
    case invalidEmail
    case passwordTooShort
    case passwordTooLong
    
    var errorDescription: String? {
        switch self {
        case .nilValue:
            return "Value empty"
        case .invalidEmail:
            return "Email invalid"
        case .passwordTooShort:
            return "Password has 8 or less characters"
        case .passwordTooLong:
            return "Password has 20 o more characters"
        }
    }
}

struct AuthValidation {
    
    func validatePassword(_ password: String?) throws -> String {
        guard let password = password else { throw AuthValidationError.nilValue }
        guard !password.isEmpty else { throw AuthValidationError.nilValue }
        guard password.count >= 8 else { throw AuthValidationError.passwordTooShort }
        guard password.count < 20 else { throw AuthValidationError.passwordTooLong }
        
        return password
    }
    
    func validateEmail(_ email: String?) throws -> String {
        guard let email = email else { throw AuthValidationError.nilValue }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        guard emailPred.evaluate(with: email) else { throw AuthValidationError.invalidEmail }
        
        return email
    }
}

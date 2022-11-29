//
//  LoginViewModel.swift
//  desafio_mobile
//
//  Created by Johnny Camacho on 29/11/22.
//

import Foundation
import FirebaseAuth

protocol LoginViewDelegate: AnyObject {
    
    func authService(didAuthenticate user: User)
    func authService(didFailToAuthorizeWith error: Error)
    
}

class LoginViewModel {
    
    private let authValidation: AuthValidation
    
    weak var delegate: LoginViewDelegate?
    
    init(
        authValidation: AuthValidation = AuthValidation()
    ) {
        self.authValidation = authValidation
    }
    
    func loginUser(email: String?, password: String?) {
        do {
            let email = try authValidation.validateEmail(email)
            let password = try authValidation.validatePassword(password)
            
            AuthService.shared.loginUser(email: email, password: password) { [weak self] response in
                guard let self = self else { return }
                
                switch response {
                case .success(let user):
                    self.delegate?.authService(didAuthenticate: user)
                case .failure(let error):
                    self.delegate?.authService(didFailToAuthorizeWith: error)
                }
            }
        } catch {
            delegate?.authService(didFailToAuthorizeWith: error)
        }
    }
    
    func registerUser(email: String?, password: String?) {
        do {
            let email = try authValidation.validateEmail(email)
            let password = try authValidation.validatePassword(password)
            
            AuthService.shared.registerUser(email: email, password: password) { [weak self] response in
                guard let self = self else { return }
                
                switch response {
                case .success(let user):
                    self.delegate?.authService(didAuthenticate: user)
                case .failure(let error):
                    self.delegate?.authService(didFailToAuthorizeWith: error)
                }
            }
        } catch {
            delegate?.authService(didFailToAuthorizeWith: error)
        }
    }
}

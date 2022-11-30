//
//  LoginViewModel.swift
//  desafio_mobile
//
//  Created by Johnny Camacho on 29/11/22.
//

import Foundation
import FirebaseAnalytics
import FirebaseAuth

protocol LoginViewDelegate: AnyObject {
    
    func authService(didAuthenticate user: User)
    func authService(didFailToAuthorizeWith error: Error)
    
}

class LoginViewModel {
    
    private let authValidation: AuthValidation
    private let authService: AuthServiceProtocol
    
    weak var delegate: LoginViewDelegate?
    
    init(
        authValidation: AuthValidation = AuthValidation(),
        authService: AuthServiceProtocol = AuthService()
    ) {
        self.authValidation = authValidation
        self.authService = authService
    }
    
    func loginUser(email: String?, password: String?) {
        do {
            let email = try authValidation.validateEmail(email)
            let password = try authValidation.validatePassword(password)
            
            authService.loginUser(email: email, password: password) { [weak self] response in
                guard let self = self else { return }
                
                switch response {
                case .success(let user):
                    Analytics.logEvent(AnalyticsEventLogin, parameters: [AnalyticsParameterSuccess: true])
                    
                    if !CoredataService.shared.hasUser(userUid: user.uid) {
                        CoredataService.shared.createUser(email: email, userUid: user.uid)
                    }
                    
                    self.delegate?.authService(didAuthenticate: user)
                case .failure(let error):
                    Analytics.logEvent(AnalyticsEventLogin, parameters: [
                        AnalyticsParameterSuccess: false,
                        "error": error.localizedDescription
                    ])
                    
                    self.delegate?.authService(didFailToAuthorizeWith: error)
                }
            }
        } catch {
            Analytics.logEvent(AnalyticsEventLogin, parameters: [
                AnalyticsParameterSuccess: false,
                "error": error.localizedDescription
            ])
            
            delegate?.authService(didFailToAuthorizeWith: error)
        }
    }
    
    func registerUser(email: String?, password: String?) {
        do {
            let email = try authValidation.validateEmail(email)
            let password = try authValidation.validatePassword(password)
            
            authService.registerUser(email: email, password: password) { [weak self] response in
                guard let self = self else { return }
                
                switch response {
                case .success(let user):
                    Analytics.logEvent(AnalyticsEventSignUp, parameters: [AnalyticsParameterSuccess: true])
                    
                    FirestoreService.shared.createUser(email: email, userUid: user.uid)
                    CoredataService.shared.createUser(email: email, userUid: user.uid)
                    
                    self.delegate?.authService(didAuthenticate: user)
                case .failure(let error):
                    Analytics.logEvent(AnalyticsEventSignUp, parameters: [
                        AnalyticsParameterSuccess: false,
                        "error": error.localizedDescription
                    ])
                    
                    self.delegate?.authService(didFailToAuthorizeWith: error)
                }
            }
        } catch {
            Analytics.logEvent(AnalyticsEventSignUp, parameters: [
                AnalyticsParameterSuccess: false,
                "error": error.localizedDescription
            ])
            
            delegate?.authService(didFailToAuthorizeWith: error)
        }
    }
}

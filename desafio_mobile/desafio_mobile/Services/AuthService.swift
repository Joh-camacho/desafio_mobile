//
//  AuthService.swift
//  desafio_mobile
//
//  Created by Johnny Camacho on 29/11/22.
//

import FirebaseAuth

protocol AuthRequest {
    
    typealias completionHandler = ((AuthDataResult?, Error?) -> Void)?
    
    func signIn(with email: String, password: String, completion: completionHandler)
    func createUser(with email: String, password: String, completion: completionHandler)
    
}

protocol AuthServiceProtocol {
    
    typealias completionHandler = (Result<User, Error>) -> Void
    
    func loginUser(email: String, password: String, completion: @escaping completionHandler)
    func registerUser(email: String, password: String, completion: @escaping completionHandler)
    
}

struct AuthService: AuthServiceProtocol {
    
    private let authRequest: AuthRequest
    
    init(authRequest: AuthRequest = Auth.auth()) {
        self.authRequest = authRequest
    }
    
    func loginUser(email: String, password: String, completion: @escaping completionHandler) {
        authRequest.signIn(with: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let result = result else {
                completion(.failure(AuthErrorCode(.internalError)))
                return
            }
            
            completion(.success(result.user))
        }
    }
    
    func registerUser(email: String, password: String, completion: @escaping completionHandler) {
        authRequest.createUser(with: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let result = result else {
                completion(.failure(AuthErrorCode(.internalError)))
                return
            }
            
            completion(.success(result.user))
        }
    }
    
    static func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
}

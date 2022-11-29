//
//  AuthService.swift
//  desafio_mobile
//
//  Created by Johnny Camacho on 29/11/22.
//

import FirebaseAuth

struct AuthService {
    
    typealias completionHandler = (Result<User, Error>) -> Void
    
    static let shared = AuthService()
    
    private init() { }
    
    func loginUser(email: String, password: String, completion: @escaping completionHandler) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
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
}

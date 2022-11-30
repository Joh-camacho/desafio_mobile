//
//  Auth+Extension.swift
//  desafio_mobile
//
//  Created by Johnny Camacho on 29/11/22.
//

import FirebaseAuth

extension Auth: AuthRequest {
    
    func signIn(with email: String, password: String, completion: completionHandler) {
        return signIn(withEmail: email, password: password, completion: completion)
    }
    
    func createUser(with email: String, password: String, completion: completionHandler) {
        return createUser(withEmail: email, password: password, completion: completion)
    }
}

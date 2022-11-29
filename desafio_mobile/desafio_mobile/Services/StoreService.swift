//
//  StoreService.swift
//  desafio_mobile
//
//  Created by Johnny Camacho on 29/11/22.
//

import FirebaseFirestore
import FirebaseAuth

struct StoreService {
    
    static let shared = StoreService()
    
    private let db = Firestore.firestore()
    private let collection = "users"
    
    private init() { }
    
    func createUser(email: String, userUid uid: String) {
        let document = db.collection(collection).document(uid)
        
        document.setData([
            "email": email
        ])
    }
    
    func updateUserLocation(userUid uid: String, latitude: String, longitude: String) {
        let document = db.collection(collection).document(uid)
        
        document.updateData([
            "last_latitude": latitude,
            "last_longitude": longitude
        ])
    }
}

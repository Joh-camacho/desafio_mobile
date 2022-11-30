//
//  PersistenceService.swift
//  desafio_mobile
//
//  Created by Johnny Camacho on 29/11/22.
//

import FirebaseFirestore
import FirebaseAuth
import CoreData

protocol PersistenceProtocol {
    
    typealias completionHandler = (Result<DMUser, Error>) -> Void
    
    func createUser(email: String, userUid uid: String)
    func updateUserLocation(userUid uid: String, latitude: Double, longitude: Double)
    func getUserInfo(userUid uid: String, completion: @escaping completionHandler)
    
}

struct FirestoreService: PersistenceProtocol {
    
    static let shared = FirestoreService()
    
    private let db = Firestore.firestore()
    private let collection = "users"
    
    private init() { }
    
    func createUser(email: String, userUid uid: String) {
        let document = db.collection(collection).document(uid)
        
        document.setData([
            "email": email
        ])
    }
    
    func updateUserLocation(userUid uid: String, latitude: Double, longitude: Double) {
        let document = db.collection(collection).document(uid)
        
        document.updateData([
            "last_latitude": latitude,
            "last_longitude": longitude
        ])
    }
    
    func getUserInfo(userUid uid: String, completion: @escaping completionHandler) {
        let document = db.collection(collection).document(uid)
        
        document.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                completion(.failure(FirestoreErrorCode(.notFound)))
                return
            }
            
            let dmUser = parseUser(userUid: uid, document: document)
            
            completion(.success(dmUser))
        }
    }
    
    private func parseUser(userUid uid: String, document: DocumentSnapshot) -> DMUser {
        let email = document["email"] as? String ?? ""
        let lastLatitude = document["last_latitude"] as? Double ?? 0.0
        let lastLongitude = document["last_longitude"] as? Double ?? 0.0
        
        return DMUser(uid: uid, email: email, lastLatitude: lastLatitude, lastLongitute: lastLongitude)
    }
}

struct CoredataService: PersistenceProtocol {
    
    static let shared = CoredataService()
    
    private let container: NSPersistentContainer
    
    private init() {
        let container = NSPersistentContainer(name: "desafio_mobile")
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        self.container = container
    }
    
    func createUser(email: String, userUid uid: String) {
        let user = CDUser(context: container.viewContext)
        user.id = uid
        user.email = email
        
        saveContext()
    }
    
    func updateUserLocation(userUid uid: String, latitude: Double, longitude: Double) {
        do {
            let fetch = CDUser.fetchRequest()
            let users = try container.viewContext.fetch(fetch)
            
            guard let user = users.first(where: { $0.id == uid }) else {
                return
            }
            
            user.last_latitude = latitude
            user.last_longitude = longitude
            
            saveContext()
        } catch {
            fatalError("CoreData error on fetchRequest.")
        }
    }
    
    func getUserInfo(userUid uid: String, completion: @escaping (Result<DMUser, Error>) -> Void) {
        guard let user = getUser(userUid: uid) else {
            completion(.failure(FirestoreErrorCode(.notFound)))
            return
        }
        
        let dmUser = parseUser(userUid: uid, cdUser: user)
        
        completion(.success(dmUser))
    }
    
    func getUser(userUid uid: String) -> CDUser? {
        do {
            let fetch = CDUser.fetchRequest()
            let users = try container.viewContext.fetch(fetch)
            
            return users.first(where: { $0.id == uid })
        } catch {
            fatalError("CoreData error on fetchRequest.")
        }
    }
    
    func hasUser(userUid uid: String) -> Bool {
        return getUser(userUid: uid) != nil
    }
    
    private func saveContext() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private func parseUser(userUid uid: String, cdUser: CDUser) -> DMUser {
        let email = cdUser.email ?? ""
        let lastLatitude = cdUser.last_latitude
        let lastLongitude = cdUser.last_longitude
        
        return DMUser(uid: uid, email: email, lastLatitude: lastLatitude, lastLongitute: lastLongitude)
    }
}

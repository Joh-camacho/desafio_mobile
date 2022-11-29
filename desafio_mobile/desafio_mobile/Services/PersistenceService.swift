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
    
    func createUser(email: String, userUid uid: String)
    func updateUserLocation(userUid uid: String, latitude: Double, longitude: Double)
    
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
                fatalError("User not created.")
            }
            
            user.last_latitude = latitude
            user.last_longitude = longitude
            
            saveContext()
        } catch {
            fatalError("CoreData error on fetchRequest.")
        }
    }
    
    func hasUser(userUid uid: String) -> Bool {
        do {
            let fetch = CDUser.fetchRequest()
            let users = try container.viewContext.fetch(fetch)
            
            return users.first(where: { $0.id == uid }) != nil
        } catch {
            fatalError("CoreData error on fetchRequest.")
        }
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
}

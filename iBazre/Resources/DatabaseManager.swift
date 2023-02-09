//
//  DatabaseManager.swift
//  iBazre
//
//  Created by Levan Charuashvili on 21.01.23.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager{
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
     
}

extension DatabaseManager {
    public func emailExsistCheck(with email:String, completion: @escaping ((Bool) -> Void)){
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    public func insertUser(with user:User){
        database.child(user.safeEmail).setValue([
            "username":user.username,
            "pfp":user.profilePictureURL
        ])
    }
}



struct User{
    let username:String
    let emailAdress:String
    var profilePictureURL:String
    
    var safeEmail:String {
        var safeEmail = emailAdress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

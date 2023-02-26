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
     
    static func safeEmail(email:String) -> String{
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
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
    
    public func insertUser(with user:User, completion: @escaping (Bool) -> Void){
        database.child(user.safeEmail).setValue([
            "username":user.username,
            "pfp":user.profilePictureURL
        ]) { error, _ in
            guard error == nil else {
                print("failed to write data")
                completion(false)
                return
            }
            self.database.child("users").observeSingleEvent(of: .value) { snapshot in
                if var usersCollection = snapshot.value as? [[String:String]] {
                    let newElement = [
                        "name":user.username,
                        "mail":user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    self.database.child("users").setValue(usersCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                    }
                }else {
                    let newCollection: [[String:String]] = [
                        [
                            "name":user.username,
                            "mail":user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                    }
                }
            }
            completion(true)
        }
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String:String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String:String]] else {
                completion(.failure(DatabaseError.FailedToFetch))
                return
            }
            completion(.success(value))
        }
    }
    public enum DatabaseError:Error {
        case FailedToFetch
    }
    
}

// MARK: - sending messages

extension DatabaseManager {
    ///creates new conversation with target email and first message
    public func createNewConversation(name:String, with otherUserEmail:String,firstMessage:Message, completion:@escaping(Bool) -> Void){
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }

        let safeEmail = DatabaseManager.safeEmail(email: currentEmail)
        let ref  = database.child(safeEmail)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard var userNode = snapshot.value as? [String:Any] else {
                completion(false)
                print("user not found --------------")
                return
            }
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            var message = ""
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let newConversationData:[String:Any] = [
                "id":conversationId,
                "other_user_email": otherUserEmail,
                "latest_message":[
                    "name":name,
                    "date":dateString,
                    "message":message,
                    "is_read":false
                ]
            ]
            if var conversations = userNode["conversations"] as? [[String:Any]] {
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode) { [ weak self ] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                }
                    self?.finishCreatingConversation(name:name,conversationId: conversationId, firstMessage: firstMessage, completion: completion)
                }
            }else {
                userNode["conversations"] = newConversationData
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name:name ,conversationId: conversationId, firstMessage: firstMessage, completion: completion)
                }
            }
        }
    }
    private func finishCreatingConversation(name:String,conversationId:String, firstMessage:Message, completion: @escaping (Bool) -> Void){
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        var message = ""
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        

        
        let collectionMessage:[String:Any] = [
            "name":name,
            "id":firstMessage.messageId,
            "type":firstMessage.kind.messageKindString,
            "content":message,
            "date":dateString,
            "sender_email":currentUserEmail,
            "is_read":false
        ]
        let value:[String:Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        database.child("\(conversationId)").setValue(value) { error, _ in
            guard error == nil else {
                return
            }
            completion(true)
        }
    }
    
    /// fetches and returns conversation with email from database
    public func getAllConversations(with email:String, completion: @escaping(Result<String,Error>) ->Void){
        
    }
    /// fetches all messages for given conversation
    public func getAllMessagesForConversation(with id:String,completion:@escaping(Result<String,Error>) -> Void){
        
    }
    /// sends message to target conversation
    public func sendMessage(to conversation:String,message:Message, completion:@escaping(Bool) -> Void){
        
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

//
//  DatabaseManager.swift
//  iBazre
//
//  Created by Levan Charuashvili on 21.01.23.
//

import Foundation
import FirebaseDatabase
struct Conversation:Codable {
    let id: String
    let latestMessage: LatestMessage
    let name: String
    let otherUserEmail: String
}
struct LatestMessage:Codable {
    let date: String
    let isRead: Bool
    let message: String
}

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
            var message:String = ""
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
                "name":name,
                "latest_message":[
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
    
//    public func getAllConversations(with email: String, completion: @escaping(Result<[Conversation], Error>) -> Void) {
//        database.child("\(email)/conversations").observeSingleEvent(of: .value) { snapshot in
//            guard let conversations = snapshot.value as? [[String: Any]] else {
//                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse conversations"])
//                completion(.failure(error))
//                return
//            }
//
//            var result: [Conversation] = []
//
//            for conversationData in conversations {
//                guard let conversationId = conversationData["id"] as? String,
//                      let latestMessageData = conversationData["latest_message"] as? [String: Any],
//                      let name = conversationData["name"] as? String,
//                      let otherUserEmail = conversationData["other_user_email"] as? String else {
//                    continue
//                }
//
//                guard let date = latestMessageData["date"] as? String,
//                      let isRead = latestMessageData["is_read"] as? Int,
//                      let message = latestMessageData["message"] as? String else {
//                    continue
//                }
//
//                let latestMessageObject = LatestMessage(date: date, isRead: false, message: message)
//                let conversation = Conversation(id: conversationId, latestMessage: latestMessageObject, name: name, otherUserEmail: otherUserEmail)
//                result.append(conversation)
//            }
//            print("result: -\(result)")
//            completion(.success(result))
//        }
//    }
    
    /// fetches and returns conversation with email from database
//    public func getAllConversations(with email: String, completion: @escaping(Result<[Conversation], Error>) -> Void) {
//        database.child("\(email)/conversations").observeSingleEvent(of: .value) { snapshot in
//            guard let value = snapshot.value as? [[String: Any]] else {
//                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse conversations"])
//                completion(.failure(error))
//                print(snapshot.value)
//                return
//
//            }
//            let conversations: [Conversation] = value.compactMap { dictionary in
//                guard let conversationId = dictionary["id"] as? String,
//                      let latestMessage = dictionary["latest_message"] as? [String: Any],
//                      let message = latestMessage["message"] as? String,
//                      let date = latestMessage["date"] as? String,
//                      let isRead = latestMessage["is_read"] as? Int,
//                      let name = dictionary["name"] as? String,
//                      let otherUserEmail = dictionary["other_user_email"] as? String else {
//                    print("Failed to parse conversation: \(dictionary)")
//                    return nil
//                }
//
//                let latestMessageObject = LatestMessage(date: date, isRead: isRead, message: message)
//                return Conversation(id: conversationId, latestMessage: latestMessageObject, name: name, otherUserEmail: otherUserEmail)
//            }
//
//            completion(.success(conversations))
//        }
//    }
    
    public func getConversation(with email: String, completion: @escaping(Result<Conversation, Error>) -> Void) {
        database.child("\(email)/conversations").observeSingleEvent(of: .value) { snapshot in
//            guard let value = snapshot.value as? [String:Any] else {
//                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:"failedtoparse"])))
//
//                return
//            }
//            do {
//                let decoder = JSONDecoder()
//                let data = try decoder.decode(value)
//            }
//
//        }
        //database.child("\(email)/conversations").getData(completion: <#T##(Error?, DataSnapshot?) -> Void#>)
            let value = snapshot.value as? NSDictionary
            let name = value?["name"] as? String ?? ""
            let id = value?["id"] as? String ?? ""
            let otherUserEmail = value?["other_user_email"] as? String ?? ""
            let lateMessage = value?["latest_message"] as? [String:Any]
            let date = lateMessage?["date"] as? String ?? ""
            let isRead = lateMessage?["is_read"] as? Bool ?? true
            let message = lateMessage?["message"] as? String ?? ""
            
            let latestMessage = LatestMessage(date: date, isRead: isRead, message: message)
            let conversations = Conversation(id: id, latestMessage: latestMessage, name: name, otherUserEmail: otherUserEmail)
            completion(.success(conversations))
            
        }
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

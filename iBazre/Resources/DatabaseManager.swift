//
//  DatabaseManager.swift
//  iBazre
//
//  Created by Levan Charuashvili on 21.01.23.
//

import Foundation
import FirebaseDatabase
import FirebaseFirestore
import MessageKit


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
    
    static func unSafeEmail(safeEmail:String) -> String {
        var modifiedEmail = safeEmail.replacingOccurrences(of: "-", with: ".", range: nil)
        if let range = modifiedEmail.range(of: ".", options: .literal) {
            modifiedEmail.replaceSubrange(range, with: "@")
        }
        return modifiedEmail
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
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
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
            let recipient_newConversationData:[String:Any] = [
                "id":conversationId,
                "other_user_email": safeEmail,
                "name":"self",
                "latest_message":[
                    "date":dateString,
                    "message":message,
                    "is_read":false
                ]
            ]
            
            self?.database.child("\(otherUserEmail)/messages").observeSingleEvent(of: .value) { [weak self] dasnapshot in
                if var conversation = dasnapshot.value as? [[String:Any]] {
                    conversation.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/messages").setValue(conversation)
                } else {
                    self?.database.child("\(otherUserEmail)/messages").setValue([recipient_newConversationData])
                }
            }
            
            if var conversations = userNode["messages"] as? [[String:Any]] {
                conversations.append(newConversationData)
                userNode["messages"] = conversations
                ref.setValue(userNode) { [ weak self ] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                }
                    self?.finishCreatingConversation(name:name,conversationId: conversationId, firstMessage: firstMessage, completion: completion)
                }
            }else {
                userNode["messages"] = newConversationData
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
    

    
    public func getConversation(with email: String, completion: @escaping(Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/messages").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseError.FailedToFetch))
                return
            }
            print(value)
            let messages:[Conversation] = value.compactMap { dict in
                
                guard let name = dict["name"] as? String,
                      let id = dict["id"] as? String,
                      let otherUserEmail = dict["other_user_email"] as? String,
                      let lateMessage = dict["latest_message"] as? [String:Any],
                        let date = lateMessage["date"] as? String,
                        let isRead = lateMessage["is_read"] as? Bool,
                        let message = lateMessage["message"] as? String else {
                        return nil
                    }
                
                let latestMessage = LatestMessage(date: date, isRead: isRead, message: message)
                
                let conversation = Conversation(id: id, latestMessage: latestMessage, name: name, otherUserEmail: otherUserEmail)
                print("mcooonvo:\(conversation)")
                return conversation
            }
            completion(.success(messages))
        }
    }
    
    struct Meessage: Codable {
        var content: String
        var date: String
        var id: String
        var isRead: Bool
        var name: String
        var senderEmail: String
        var type: String
        
        enum CodingKeys: String, CodingKey {
            case content
            case date
            case id
            case isRead = "is_read"
            case name
            case senderEmail = "sender_email"
            case type
        }
    }


    /// fetches all messages for given conversation
    public func getAllMessagesForConversation(with id:String, completion:@escaping (Result<[Message], Error>) -> Void){

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm:ss a z"
        print("id \(id)")
        database.child("\(id)/messages").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseError.FailedToFetch))
                return
            }
            let messages:[Message] = value.compactMap { dictionary in
                guard let id = dictionary["id"] as? String,
                    let content = dictionary["content"] as? String,
                    let dateString = dictionary["date"] as? String,
                    let date = ChatViewController.dateFormatter.date(from: dateString),
                    let isRead = dictionary["is_read"] as? Bool,
                    let name = dictionary["name"] as? String,
                    let senderEmail = dictionary["sender_email"] as? String,
                    let type = dictionary["type"] as? String else {
                        return nil
                    }
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                
                let message = Message(sender: sender, messageId: id, sentDate: date, kind: .text(content))
                print("message Id:\(message)")
                return message
            }
            completion(.success(messages))
            
        }

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

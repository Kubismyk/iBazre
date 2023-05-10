//
//  ChatViewController.swift
//  iBazre
//
//  Created by Levan Charuashvili on 01.02.23.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import AVFoundation

struct Message:MessageType {
    public var sender: SenderType
    
    public var messageId: String
    
    public var sentDate: Date
    
    public var kind: MessageKind
    
    
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .custom(_):
            return "custom"
        case .linkPreview(_):
            return "link_preview"
        }
    }
}

struct Sender:SenderType {
    public var photoURL: String
    
    public var senderId: String
    
    public var displayName: String
    
    
}

class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public var isNewConversation = false
    public let conversationId: String?
    public var isOtherEmail:String
    
    private var messages = [Message]()
    
    private var selfSender:Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(email: email)
        return Sender(photoURL: "",
               senderId: safeEmail,
               displayName: "me")
    }
    
    
    init(with email:String, id:String){
        self.isOtherEmail = email
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
        if let conversationIdd = conversationId {
            listenForMessages(id: conversationIdd)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        self.title = DatabaseManager.unSafeEmail(safeEmail: isOtherEmail)
        messageInputBar.inputTextView.becomeFirstResponder()
        self.messagesCollectionView.reloadData()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), landscapeImagePhone: UIImage(systemName: "chevron.backward"), style: .done, target: self, action: #selector(dismissSelf))
        }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    @objc func dismissSelf(){
        self.dismiss(animated: true)
    }
    
    private func listenForMessages(id: String){
        DatabaseManager.shared.getAllMessagesForConversation(with: id) { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadData()
                }
            case .failure(let error):
                print("error fetching messages for conversation: \(error)")
            }
        }
    }
    
}

    
extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let selfSender = self.selfSender,
            let messageId = createMessageId() else {
                return
        }
        print("Sending:\(text)")
        //send message
        if isNewConversation{
            let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
            DatabaseManager.shared.createNewConversation(name:self.navigationItem.title ?? "User",with: isOtherEmail, firstMessage: message) { success in
                if success {
                    print("message sent successfully")
                }else {
                    print("message cannot be sent")
                }
            }
        }else {
            
        }
    }
    private func createMessageId() -> String? {
        // date, otheremail, email,randomint
        let dateString = Self.dateFormatter.string(from: Date())
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                return nil
        }
        let safeCurrentEmail = DatabaseManager.safeEmail(email: currentEmail)
        let newIdentifier = "\(isOtherEmail)_\(safeCurrentEmail)_\(dateString)"
        print("created: \(newIdentifier)")
        return newIdentifier
    }
    
}



extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    var currentSender: SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("self sender is nil")
        return Sender(photoURL: "", senderId: "123", displayName: "")
    }
    
    func cureentSender() -> SenderType {
        return selfSender!
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}

//
//  ChatViewController.swift
//  iBazre
//
//  Created by Levan Charuashvili on 01.02.23.
//

import UIKit
import MessageKit

struct Message:MessageType {
    var sender: SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKind
    
    
}
struct Sender:SenderType {
    var photoURL: String
    
    var senderId: String
    
    var displayName: String
    
    
}

class ChatViewController: MessagesViewController {
    
    
    private var messages = [Message]()
    
    private var selfSender = Sender(photoURL: "", senderId: "", displayName: "JOe Rogan")

    override func viewDidLoad() {
        super.viewDidLoad()
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello World Message")))
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Lorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem Ipsum")))
        //view.backgroundColor = .white
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        self.messagesCollectionView.reloadData()
        self.title = "John Moore"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), landscapeImagePhone: UIImage(systemName: "chevron.backward"), style: .done, target: self, action: #selector(dismissSelf))
        }
    
    @objc func dismissSelf(){
        self.dismiss(animated: true)
    }
}

    




extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    var currentSender: SenderType {
        return selfSender
    }
    
    func cureentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}

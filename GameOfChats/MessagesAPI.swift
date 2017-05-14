//
//  MessagesAPI.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 14/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation
import FirebaseDatabase

enum MessagesError: Error{
    case failedToParseData
}

protocol MessageAPIProtocol {
    func observeMessages(ofUser uid: String, onReceive: @escaping (_ message: ChatMessage) -> Void)
}

class MessagesAPI: MessageAPIProtocol{
    
    func observeMessages(ofUser uid: String, onReceive: @escaping (_ message: ChatMessage) -> Void){
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages")
        let messagesRef = FIRDatabase.database().reference().child("messages")
            
        userMessagesRef.child(uid).observe(.childAdded, with: { (snapshot) in
            userMessagesRef.child(uid).child(snapshot.key).queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
                messagesRef.child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let dict = snapshot.value as? [String : AnyObject] else { return }
                    guard let message = ChatMessage.from(dict: dict) else { return }
                    onReceive(message)
                }, withCancel: nil)
            }, withCancel: nil)
        }, withCancel: nil)
    }
}

//
//  ChatLogViewController.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 01/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ChatLogViewController: UICollectionViewController{
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.placeholder = "Enter Message.."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var sendButton: UIButton = {
        let sendButton = UIButton(type: .system)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        return sendButton
    }()
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        title = user.name
        view.addSubview(containerView)
        setupInputComponents()
    }
    
    var messages = [ChatMessage]()
    
    func observeMessages(){
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observeSingleEvent(of: .childAdded, with: { (snapshot) in
            guard let dict = snapshot.value as? [String : AnyObject] else { return }
            guard let message = ChatMessage.from(dict: dict) else { return }
            self.messages.append(message)
        }, withCancel: nil)
    }
    
    func setupInputComponents(){
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        containerView.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -8).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        containerView.addSubview(inputTextField)
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorView = UIView()
        containerView.addSubview(separatorView)
        separatorView.backgroundColor = .lightGray
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    func handleSend(){
        guard let text = inputTextField.text else { return }
        guard let currentUser = FIRAuth.auth()?.currentUser else { return }
        
        let ref = FIRDatabase.database().reference().child("messages")
        let newMessageRef = ref.childByAutoId()
        
        let toID = user.id
        let fromID = currentUser.uid
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let message = ChatMessage(text: text,
                                  toID: toID,
                                  fromID: fromID,
                                  timestamp: timestamp)
        newMessageRef.setValue(message.getValue())
        inputTextField.text = nil
    }
}

struct ChatMessage {
    let text: String
    let toID: String
    let fromID: String
    let timestamp: Int
    
    static func from(dict: [String : AnyObject]) -> ChatMessage?{
        guard let text = dict["text"] as? String else { return nil }
        guard let toID = dict["toID"] as? String else { return nil }
        guard let fromID = dict["fromID"] as? String else { return nil }
        guard let timestamp = dict["timestamp"] as? Int else { return nil }
        return ChatMessage(text: text,
                           toID: toID,
                           fromID: fromID,
                           timestamp: timestamp)
    }
    
    func getValue() -> [String : Any]{
        return ["text" : text,
                "toID": toID,
                "fromID" : fromID,
                "timestamp" : timestamp]
    }
}

extension ChatLogViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}

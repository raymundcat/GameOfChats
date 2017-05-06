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

class ChatLogViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
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
    
    private let cellID = "cellID"
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 58, 0)
        collectionView?.backgroundColor = .white
        
        title = user.name
        view.addSubview(containerView)
        setupInputComponents()
        observeMessages()
    }
    
    var messages = [ChatMessage]()
    
    func observeMessages(){
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages")
        let messagesRef = FIRDatabase.database().reference().child("messages")
        userMessagesRef.child(user.id).observe(.childAdded, with: { (snapshot) in
            messagesRef.child(snapshot.key).observe(.value, with: { (snapshot) in
                guard let dict = snapshot.value as? [String : AnyObject] else { return }
                guard let message = ChatMessage.from(dict: dict) else { return }
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    self.collectionView?.scrollToItem(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                }
            }, withCancel: nil)
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
        
        let messagesRef = FIRDatabase.database().reference().child("messages")
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages")
        let newMessageRef = messagesRef.childByAutoId()
        
        let toID = user.id
        let fromID = currentUser.uid
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let message = ChatMessage(text: text,
                                  toID: toID,
                                  fromID: fromID,
                                  timestamp: timestamp)
        newMessageRef.setValue(message.getValue()) { (error, ref) in
            guard error == nil else { return }
            userMessagesRef.child(message.fromID).updateChildValues([ref.key : 1])
            userMessagesRef.child(message.toID).updateChildValues([ref.key : 1])
        }
        
        inputTextField.text = nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.row]
        guard let currentUserID = FIRAuth.auth()?.currentUser?.uid,
            let partnerID = message.getChatPartner(ofUser: currentUserID) else { return cell }
        
        let messageType: MessageCellType = message.fromID == partnerID ? .partnerUser : .currentUser
        cell.layoutCell(withMessage: message, type: messageType)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = messages[indexPath.row].text
        return CGSize(width: collectionView.frame.width, height: estimateHeight(ofText: text, forMaxWidth: 200).height + 30)
    }
    
    private func estimateHeight(ofText text: String, forMaxWidth maxWidth: CGFloat) -> CGRect{
        let maxSize = CGSize(width: maxWidth, height: 2000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: maxSize, options: options, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
}

extension ChatLogViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}

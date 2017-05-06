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
import Anchorage

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
        textField.keyboardType = .default
        return textField
    }()
    
    lazy var sendButton: UIButton = {
        let sendButton = UIButton(type: .system)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        return sendButton
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var partnerUser: User!
    
    fileprivate let cellID = "cellID"
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
        collectionView?.backgroundColor = .white
        collectionView?.keyboardDismissMode = .interactive
        
        title = partnerUser.name
        observeMessages()
        setupInputComponents()
    }
    
    var messages = [ChatMessage]()
    
    func observeMessages(){
        guard let userID = FIRAuth.auth()?.currentUser?.uid else { return }
        let messagesRef = FIRDatabase.database().reference().child("messages")
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages")
        userMessagesRef.child(userID).child(partnerUser.id).observe(.childAdded, with: { (snapshot) in
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
        containerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        
        containerView.addSubview(sendButton)
        sendButton.rightAnchor == containerView.rightAnchor
        sendButton.centerYAnchor == containerView.centerYAnchor
        sendButton.widthAnchor == 50
        sendButton.heightAnchor == containerView.heightAnchor
        
        containerView.addSubview(inputTextField)
        inputTextField.leftAnchor == containerView.leftAnchor + 8
        inputTextField.rightAnchor == sendButton.leftAnchor
        inputTextField.centerYAnchor == containerView.centerYAnchor
        inputTextField.heightAnchor == containerView.heightAnchor
        
        containerView.addSubview(separatorView)
        separatorView.leftAnchor == containerView.leftAnchor
        separatorView.rightAnchor == containerView.rightAnchor
        separatorView.topAnchor == containerView.topAnchor
        separatorView.heightAnchor == 0.5
    }
    
    func handleSend(){
        guard let text = inputTextField.text else { return }
        guard let currentUser = FIRAuth.auth()?.currentUser else { return }
        
        let messagesRef = FIRDatabase.database().reference().child("messages")
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages")
        let newMessageRef = messagesRef.childByAutoId()
        
        let toID = partnerUser.id
        let fromID = currentUser.uid
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let message = ChatMessage(text: text,
                                  toID: toID,
                                  fromID: fromID,
                                  timestamp: timestamp)
        newMessageRef.setValue(message.getValue()) { (error, ref) in
            guard error == nil else { return }
            userMessagesRef.child(message.fromID).child(toID).updateChildValues([ref.key : 1])
            userMessagesRef.child(message.toID).child(fromID).updateChildValues([ref.key : 1])
        }
        
        inputTextField.text = nil
    }
}

//MARK: Input accessory views

extension ChatLogViewController{
    
    override var canBecomeFirstResponder: Bool{
        get{
            return true
        }
    }
    
    override var inputAccessoryView: UIView?{
        get{
            return containerView
        }
    }
}

//MARK: CollectionView Delegates

extension ChatLogViewController{
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
        let width = UIScreen.main.bounds.width
        let height = estimateHeight(ofText: text, forMaxWidth: 200).height + 30
        return CGSize(width: width, height: height)
    }
    
    private func estimateHeight(ofText text: String, forMaxWidth maxWidth: CGFloat) -> CGRect{
        let maxSize = CGSize(width: maxWidth, height: 2000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: maxSize, options: options, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.endEditing(true)
    }
}

//MARK: Textfield Delegates

extension ChatLogViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}

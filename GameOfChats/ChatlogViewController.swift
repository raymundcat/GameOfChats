//
//  ChatLogViewController.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 01/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import Anchorage
import RxSwift
import RxCocoa

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
    
    lazy var uploadButton: UIButton = {
        let sendButton = UIButton(type: .system)
        sendButton.addTarget(self, action: #selector(handlePickImage), for: .touchUpInside)
        sendButton.setTitle("Upload", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        return sendButton
    }()
    
    lazy var sendButton: UIButton = {
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        return sendButton
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let disposeBag = DisposeBag()
    var input: ChatlogInput?{
        didSet{
            guard let input = input else { return }
            inputTextField.rx.text.asObservable()
                .bind(to: input.messageText)
                .addDisposableTo(disposeBag)
        }
    }
    
    var output: ChatlogOutput?{
        didSet{
            output?.currentMessages.asObservable()
                .throttle(1, scheduler: MainScheduler.instance)
                .subscribe({ (event) in
                    guard let messages = event.element else { return }
                    self.messages = messages
                    self.collectionView?.reloadData()
            }).addDisposableTo(disposeBag)
        }
    }
    
    fileprivate let cellID = "cellID"
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
        collectionView?.backgroundColor = .white
        collectionView?.keyboardDismissMode = .interactive
        setupInputComponents()
        input?.viewDidLoad.onNext(true)
    }
    
    var messages = [ChatMessage]()
    
    func setupInputComponents(){
        containerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        
        containerView.addSubview(uploadButton)
        containerView.addSubview(sendButton)
        containerView.addSubview(inputTextField)
        
        uploadButton.leftAnchor == containerView.leftAnchor + 8
        uploadButton.centerYAnchor == containerView.centerYAnchor
        uploadButton.widthAnchor == 50
        uploadButton.heightAnchor == containerView.heightAnchor
        
        inputTextField.leftAnchor == uploadButton.rightAnchor + 8
        inputTextField.rightAnchor == sendButton.leftAnchor
        inputTextField.centerYAnchor == containerView.centerYAnchor
        inputTextField.heightAnchor == containerView.heightAnchor
        
        sendButton.rightAnchor == containerView.rightAnchor
        sendButton.centerYAnchor == containerView.centerYAnchor
        sendButton.widthAnchor == 50
        sendButton.heightAnchor == containerView.heightAnchor
        
        containerView.addSubview(separatorView)
        separatorView.leftAnchor == containerView.leftAnchor
        separatorView.rightAnchor == containerView.rightAnchor
        separatorView.topAnchor == containerView.topAnchor
        separatorView.heightAnchor == 0.5
    }
    
    func handleSend(){
        input?.sendMessage.onNext(true)
    }
    
    func handlePickImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func uploadImage(image: UIImage){
//        let randName = UUID().uuidString
//        let ref = FIRStorage.storage().reference().child("message_images").child(randName)
//        guard let jpegImage = UIImageJPEGRepresentation(image, 0.3) else { return }
//        ref.put(jpegImage, metadata: nil) { (metaData, error) in
//            if error != nil{
//                return
//            }
//        }
    }
}

extension ChatLogViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = getImage(fromPickerViewInfo: info){
            uploadImage(image: image)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
//        guard let currentUserID = FIRAuth.auth()?.currentUser?.uid,
//            let partnerID = message.getChatPartner(ofUser: currentUserID) else { return cell }
//        
//        let messageType: MessageCellType = message.fromID == partnerID ? .partnerUser : .currentUser
        cell.layoutCell(withMessage: message, type: .currentUser)
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
        input?.sendMessage.onNext(true)
        return true
    }
}

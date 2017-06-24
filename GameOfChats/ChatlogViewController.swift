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
import IGListKit

class ChatLogViewController: BaseViewController, UICollectionViewDelegateFlowLayout{
    
    fileprivate let cellID = "cellID"
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: self.cellID)
        collectionView.backgroundColor = .white
        collectionView.keyboardDismissMode = .interactive
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsetsMake(66, 0, 16, 0)
        
        return collectionView
    }()
    
    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
        adapter.collectionView = self.collectionView
        adapter.dataSource = self
        return adapter
    }()
    
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
    
    var messages = [ChatMessageViewModel]()
    
    private let disposeBag = DisposeBag()
    var input: ChatlogInput?{
        didSet{
            guard let input = input else { return }
            
            rxViewDidLoad.bind(to: input.viewDidLoad)
                .addDisposableTo(disposeBag)
            
            sendButton.rx.tap
                .bind(to: input.sendMessage)
                .addDisposableTo(disposeBag)
            
            inputTextField.rx.text.asObservable()
                .bind(to: input.messageText)
                .addDisposableTo(disposeBag)
            
            inputTextField.rx.controlEvent(UIControlEvents.editingDidEnd)
                .asObservable()
                .bind(to: input.sendMessage)
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
                    self.collectionView.reloadData()
                    self.adapter.performUpdates(animated: true, completion: nil)
            }).addDisposableTo(disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.edgeAnchors == view.edgeAnchors
        
        keyboardHeight().observeOn(MainScheduler.instance)
        .subscribe { (event) in
            guard let keyboardHeight = event.element else { return }
            var inset = UIEdgeInsetsMake(74, 0, 16, 0)
            inset.bottom = inset.bottom + keyboardHeight
            self.collectionView.contentInset = inset
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                guard let `self` = self else { return }
                self.view.layoutIfNeeded()
            })
        }.addDisposableTo(disposeBag)
        
        containerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        containerView.addSubview(sendButton)
        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor == containerView.leftAnchor + 8
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

func estimateHeight(ofText text: String, forMaxWidth maxWidth: CGFloat) -> CGRect{
    let maxSize = CGSize(width: maxWidth, height: 2000)
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    return NSString(string: text).boundingRect(with: maxSize, options: options, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 16)], context: nil)
}

//MARK: Textfield Delegates

extension ChatLogViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

//MARK: IGDiffable

extension ChatMessageViewModel: Equatable {
    static public func ==(lhs: ChatMessageViewModel, rhs: ChatMessageViewModel) -> Bool {
        return lhs.id == rhs.id
    }
}

extension ChatMessageViewModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return NSString(string: id);
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let messageObject = object as? ChatMessageViewModel else { return false }
        return id == messageObject.id
    }
}

extension ChatLogViewController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return messages
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return ChatLogSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        let emptyView = UIView()
        return emptyView
    }
}

class ChatLogSectionController: ListSectionController {
    
    var message: ChatMessageViewModel?

    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let estimateRect = estimateHeight(ofText: message?.text ?? "", forMaxWidth: 110)
        let size = CGSize(width: screenWidth, height: estimateRect.height + 20)
        print(size, estimateRect)
        return size
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let message = message,
            let cell = collectionContext?.dequeueReusableCell(of: ChatMessageCell.self, for: self, at: index) as? ChatMessageCell else { return ChatMessageCell() }
        cell.layoutCell(withMessage: message)
        return cell
    }
    
    override func didUpdate(to object: Any) {
        guard let messageObject = object as? ChatMessageViewModel else { return }
        message = messageObject
    }
}

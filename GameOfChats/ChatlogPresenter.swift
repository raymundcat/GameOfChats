//
//  ChatLogPresenter.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 15/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation
import RxSwift

struct ChatMessageViewModel {
    let text: String
    let userImage: UIImage?
    let type: MessageCellType
}

protocol ChatlogInput {
    var viewDidLoad: PublishSubject<()> { get }
    var sendMessage: PublishSubject<()> { get }
    var messageText: Variable<String?> { get }
}

protocol ChatlogOutput {
    var partnerUser: Variable<User?> { get }
    var currentMessages: Variable<[ChatMessageViewModel]> { get }
    var shouldClose: PublishSubject<Bool> { get }
}

class ChatlogPresenter: ChatlogInput, ChatlogOutput{
    
    let viewDidLoad = PublishSubject<()>()
    let sendMessage = PublishSubject<()>()
    let messageText = Variable<String?>("")
    
    let partnerUser = Variable<User?>(nil)
    let currentMessages = Variable<[ChatMessageViewModel]>([])
    let shouldClose = PublishSubject<Bool>()
    
    private let messagesAPI: MessagesAPI
    private let disposeBag = DisposeBag()
    private let currentUID: String
    private let partnerUID: String
    
    init(users: PartnerUsers, messagesAPI: MessagesAPI) {
        currentUID = users.0
        partnerUID = users.1
        
        self.messagesAPI = messagesAPI
        
        viewDidLoad.subscribe { (event) in
            self.messagesAPI.observeMessages(ofUser: self.currentUID, withPartner: self.partnerUID, onReceive: { (message) in
                self.currentMessages.value
                    .append(ChatMessageViewModel(text: message.text,
                                                 userImage: nil,
                                                 type: message.fromID == self.currentUID ? .currentUser : .partnerUser))
            })
        }.addDisposableTo(disposeBag)
        
        sendMessage
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe { (event) in
                guard let messageText = self.messageText.value else { return }
                let timestamp = Int(NSDate().timeIntervalSince1970)
                let message = ChatMessage(text: messageText,
                                      toID: self.partnerUID,
                                      fromID: self.currentUID,
                                      timestamp: timestamp)
                self.messagesAPI.send(message: message)
        }.addDisposableTo(disposeBag)
    }
}



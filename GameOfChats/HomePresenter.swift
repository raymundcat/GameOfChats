//
//  HomePresenter.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 14/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation
import RxSwift

protocol HomeInput {
    var viewDidLoad: PublishSubject<Bool> { get }
    var openMessages: PublishSubject<ChatMessage> { get }
    var openUsers: PublishSubject<Bool> { get }
    var logOut: PublishSubject<Bool> { get }
}

protocol HomeOutput {
    var currentMessages: Variable<[ChatMessage]> { get }
    var currentUser: Variable<User?> { get }
    var shouldOpenMessagesForUser: PublishSubject<String> { get }
    var shouldOpenUsers: PublishSubject<Bool> { get }
    var shouldLogOut: PublishSubject<Bool> { get }
}

class HomePresenter: HomeInput, HomeOutput{
    
    let viewDidLoad = PublishSubject<Bool>()
    let openMessages = PublishSubject<ChatMessage>()
    let openUsers = PublishSubject<Bool>()
    let logOut = PublishSubject<Bool>()
    
    let currentMessages = Variable<[ChatMessage]>([])
    let currentUser = Variable<User?>(nil)
    let shouldOpenMessagesForUser = PublishSubject<String>()
    let shouldOpenUsers = PublishSubject<Bool>()
    let shouldLogOut = PublishSubject<Bool>()
    
    private let authAPI : AuthAPIProtocol
    private let messagesAPI: MessageAPIProtocol
    private var messagesDict = Variable<[String : ChatMessage]>([:])
    private let disposeBag = DisposeBag()
    
    init(authAPI : AuthAPIProtocol, messagesAPI: MessageAPIProtocol) {
        self.authAPI = authAPI
        self.messagesAPI = messagesAPI
        
        viewDidLoad.subscribe { _ in
            self.handleViewDidLoad()
        }.addDisposableTo(disposeBag)
        
        logOut.subscribe({ _ in
            self.handleLogout()
        }).addDisposableTo(disposeBag)
        
        openMessages
            .subscribe({ event in
            guard let message = event.element else { return }
            guard let userID = self.currentUser.value?.id else { return }
            guard let partnerID = message.getChatPartner(ofUser: userID) else { return }
            self.shouldOpenMessagesForUser.onNext(partnerID)
        }).addDisposableTo(disposeBag)
        
        openUsers.subscribe({ _ in
            self.shouldOpenUsers.onNext(true)
        }).addDisposableTo(disposeBag)
        
        currentUser.asObservable()
        .subscribe { (event) in
            guard let element = event.element, let user = element else { return }
            self.handleObserveMessages(ofUser: user.id)
        }.addDisposableTo(disposeBag)
        
        messagesDict.asObservable()
            .throttle(1, scheduler: MainScheduler.instance)
            .subscribe { (event) in
                guard let dict = event.element else { return }
                let array = Array(dict.values)
                self.currentMessages.value = array
        }.addDisposableTo(disposeBag)
    }
    
    private func handleObserveMessages(ofUser uid: String){
        messagesAPI.observeMessages(ofUser: uid, onReceive: { message in
            guard let currentUser = self.currentUser.value else { return }
            guard let partnerID = message.getChatPartner(ofUser: currentUser.id) else { return }
            self.messagesDict.value[partnerID] = message
        })
    }
    
    private func handleViewDidLoad(){
        authAPI.getCurrentUser().then { user -> Void in
            self.currentMessages.value = []
            self.currentUser.value = user
        }.catch { (error) in
            self.handleLogout()
        }
    }
    
    private func handleLogout(){
        authAPI.logout().then{ () -> Void in
            self.shouldLogOut.onNext(true)
        }.catch { (error) in
            //handle error
        }
    }
}

//
//  ChatLogFlowController.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 15/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation
import RxSwift

typealias PartnerUsers = (String, String)

class ChatlogFlowController: FlowController {
    
    private let disposeBag = DisposeBag()
    private var viewController: ChatLogViewController?
    private var presenter: ChatlogPresenter?
    private let config: FlowConfig
    private var partners: PartnerUsers = ("", "")
    
    required init(config: FlowConfig) {
        self.config = config
        self.setup()
    }
    
    convenience init(config: FlowConfig, partnerUsers: PartnerUsers){
        self.init(config: config)
        self.partners = partnerUsers
        self.setup()
    }
    
    func setup(){
        presenter = ChatlogPresenter(users: partners, messagesAPI: MessagesAPI())
        
        viewController = ChatLogViewController(collectionViewLayout: UICollectionViewFlowLayout())
        viewController?.input = presenter
        viewController?.output = presenter
    }
    
    func start() {
        presenter?.shouldClose.subscribe { (_) in
            self.config.navigationController?.popViewController(animated: true)
        }.addDisposableTo(disposeBag)
        
        config.navigationController?.pushViewController(viewController!, animated: true)
    }
}

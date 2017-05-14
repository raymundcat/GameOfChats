//
//  HomeViewController.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 24/04/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import RxSwift

class HomeViewController: UITableViewController {
    
    let disposeBag = DisposeBag()
    var homeInput: HomeInput?
    var homeOutput: HomeOutput?{
        didSet{
            homeOutput?.currentMessages.asObservable()
                .throttle(1, scheduler: MainScheduler.instance)
                .subscribe({ (event) in
                guard let messages = event.element else { return }
                self.messages = messages
                self.tableView.reloadData()
            }).addDisposableTo(disposeBag)
        }
    }
    
    let cellID = "cellID"
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UserMessageCell.self, forCellReuseIdentifier: cellID)
        homeInput?.viewDidLoad.onNext(true)
    }
    
    var messages: [ChatMessage] = [ChatMessage]()
}

extension Dictionary where Key == String, Value == ChatMessage{
    func getSortedMessages() -> [ChatMessage] {
        let array = Array(values)
        return array.sorted{ $0.0.timestamp > $0.1.timestamp }
    }
}

extension HomeViewController{
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? UserMessageCell else { return UITableViewCell() }
        cell.message = messages[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        homeInput?.openMessages.onNext(messages[indexPath.row])
    }
}

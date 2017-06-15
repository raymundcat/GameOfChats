//
//  HomeViewController.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 24/04/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Anchorage

class HomeViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    var homeInput: HomeInput?{
        didSet{
            guard let homeInput = homeInput else { return }
            rxViewDidLoad.bind(to: homeInput.viewDidLoad)
            .addDisposableTo(disposeBag)
            
            tableView.rx.itemSelected
            .subscribe({ event in
                guard let row = event.element?.row else { return }
                homeInput.openMessages.onNext(self.messages[row])
            }).addDisposableTo(disposeBag)
        }
    }
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
    
    fileprivate let cellID = "cellID"
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserMessageCell.self, forCellReuseIdentifier: self.cellID)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func setupTableView(){
        view.addSubview(tableView)
        tableView.edgeAnchors == view.edgeAnchors
    }
    
    fileprivate var messages: [UserMessageViewModel] = [UserMessageViewModel]()
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? UserMessageCell else { return UITableViewCell() }
        cell.message = messages[indexPath.row]
        return cell
    }
}

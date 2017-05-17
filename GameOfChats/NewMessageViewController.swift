//
//  NewMessageViewController.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 29/04/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Anchorage
import RxSwift

class NewMessageViewController: BaseViewController{
    
    var users: [User] = [User]()
    
    fileprivate let cellID = "cellID"
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserCell.self, forCellReuseIdentifier: self.cellID)
        return tableView
    }()
    
    private let disposeBag = DisposeBag()
    var input: NewMessageInput? {
        didSet {
            guard let input = input else { return }
            rxViewDidLoad.bind(to: input.viewDidLoad)
                .addDisposableTo(disposeBag)
            tableView.rx.itemSelected.subscribe({ event in
                guard let row = event.element?.row else { return }
                input.didSelectUser.onNext(self.users[row].id)
            }).addDisposableTo(disposeBag)
        }
    }
    
    var output: NewMessageOutput? {
        didSet {
            guard let output = output else { return }
            output.users.asObservable().subscribe { (event) in
                guard let users = event.element else { return }
                self.users = users
                self.tableView.reloadData()
            }.addDisposableTo(disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func setupTableView(){
        view.addSubview(tableView)
        tableView.edgeAnchors == view.edgeAnchors
    }
}

extension NewMessageViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? UserCell else {
            return UITableViewCell()
        }
        cell.user = users[indexPath.row]
        return cell
    }
}

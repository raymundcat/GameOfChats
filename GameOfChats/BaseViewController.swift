//
//  BaseViewController.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 17/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import RxSwift

protocol ReactiveViewController {
    var rxViewDidLoad: PublishSubject<()> { get }
}

class BaseViewController: UIViewController, ReactiveViewController {
    
    let rxViewDidLoad = PublishSubject<()>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rxViewDidLoad.onNext(())
    }
}

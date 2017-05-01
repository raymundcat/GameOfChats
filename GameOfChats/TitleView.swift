//
//  TitleView.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 02/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit

class TitleView: UIView{
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupImageView(){
        imageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setupNameLabel(){
        nameLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
    }
    
    func setupContainerView(){
        containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(nameLabel)
        setupContainerView()
        setupImageView()
        setupNameLabel()
    }
    
    var user: User?{
        didSet{
            guard let user = user else { return }
            if let stringUrl = user.imgURL, let url = URL(string: stringUrl) {
                imageView.loadCachedImage(fromURL: url, withPlaceHolder: #imageLiteral(resourceName: "winter-logo"))
            }
            nameLabel.text = user.name
        }
    }
}

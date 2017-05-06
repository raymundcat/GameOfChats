//
//  ChatMessageCell.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 05/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import Anchorage
import FirebaseDatabase

class ChatMessageCell: UICollectionViewCell {
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    lazy var bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .heroBlue
        imageView.layer.masksToBounds = true
        imageView.isHidden = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(imageView)
        bubbleView.addSubview(textLabel)
        
        imageView.leftAnchor == self.leftAnchor + 8
        imageView.widthAnchor == 30
        imageView.heightAnchor == imageView.widthAnchor
        imageView.layer.cornerRadius = 15
        
        bubbleView.topAnchor == self.topAnchor
        bubbleView.bottomAnchor == self.bottomAnchor
        bubbleView.widthAnchor <= 220
        bubbleView.widthAnchor >= 60
        rightBubbleAnchor = bubbleView.rightAnchor == self.rightAnchor - 8
        leftBubbleAnchor = bubbleView.leftAnchor == imageView.rightAnchor + 8
        
        textLabel.edgeAnchors == bubbleView.edgeAnchors + 10
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("")
    }
    
    private var leftBubbleAnchor: NSLayoutConstraint!
    private var rightBubbleAnchor: NSLayoutConstraint!
    
    func layoutCell(withMessage message: ChatMessage, type: MessageCellType){
        
        textLabel.text = message.text
        
        if let cachedUser = userChache.getUser(withID: message.fromID){
            guard let imgURL = cachedUser.imgURL, let url = URL(string: imgURL) else { return }
            self.imageView.loadCachedImage(fromURL: url, withPlaceHolder: nil)
        }else{
            FIRDatabase.database().reference().child("users").child(message.fromID).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dict = snapshot.value as? [String : AnyObject] else { return }
                guard let user = User.from(dict: dict, withID: snapshot.key) else { return }
                userChache.save(user: user)
                guard let url = user.imgURL else { return }
                guard let imgURL = URL(string: url) else { return }
                self.imageView.loadCachedImage(fromURL: imgURL, withPlaceHolder: nil)
            }, withCancel: nil)
        }
        
        switch type {
        case .currentUser:
            imageView.isHidden = true
            bubbleView.backgroundColor = .heroBlue
            textLabel.textColor = .white
            
            leftBubbleAnchor.isActive = false
            rightBubbleAnchor.isActive = true
            break
        case .partnerUser:
            imageView.isHidden = false
            bubbleView.backgroundColor = .lightGray
            textLabel.textColor = .black
            
            rightBubbleAnchor.isActive = false
            leftBubbleAnchor.isActive = true
            break
        }
    }
}

enum MessageCellType{
    case currentUser, partnerUser
}

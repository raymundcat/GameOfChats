//
//  ChatMessageCell.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 05/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import Anchorage

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
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(imageView)
        bubbleView.addSubview(textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("")
    }
    
    private var leftBubbleAnchor: NSLayoutConstraint?
    private var rightBubbleAnchor: NSLayoutConstraint?
    
    func layoutCell(withMessage message: ChatMessage, type: MessageCellType){
        
        textLabel.text = message.text
        imageView.leftAnchor == self.leftAnchor + 8
        imageView.widthAnchor == 40
        imageView.heightAnchor == imageView.widthAnchor
        imageView.layer.cornerRadius = 20
        
        bubbleView.topAnchor == self.topAnchor
        bubbleView.bottomAnchor == self.bottomAnchor
        bubbleView.widthAnchor <= 220
        bubbleView.widthAnchor >= 60
        
        textLabel.edgeAnchors == bubbleView.edgeAnchors + 10
        
        switch type {
        case .currentUser:
            imageView.isHidden = true
            bubbleView.backgroundColor = .heroBlue
            textLabel.textColor = .white
            
            leftBubbleAnchor?.isActive = false
            rightBubbleAnchor = bubbleView.rightAnchor == self.rightAnchor - 8 ~ .high
            break
        case .partnerUser:
            imageView.isHidden = false
            bubbleView.backgroundColor = .lightGray
            textLabel.textColor = .black
            
            rightBubbleAnchor?.isActive = false
            leftBubbleAnchor = bubbleView.leftAnchor == imageView.rightAnchor + 8 ~ .high
            break
        }
    }
}

enum MessageCellType{
    case currentUser, partnerUser
}

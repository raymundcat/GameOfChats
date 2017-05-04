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
        label.textAlignment = .right
        label.numberOfLines = 0
        return label
    }()
    
    lazy var bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .heroBlue
        return view
    }()
    
    var message: ChatMessage?{
        didSet{
            guard let message = message else { return }
            textLabel.text = message.text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .gray
        
        addSubview(bubbleView)
        bubbleView.topAnchor == self.topAnchor + 3
        bubbleView.bottomAnchor == self.bottomAnchor - 3
        bubbleView.rightAnchor == self.rightAnchor - 6
        bubbleView.widthAnchor <= 200
        
        bubbleView.addSubview(textLabel)
        textLabel.edgeAnchors == bubbleView.edgeAnchors + 8
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("")
    }
}

//
//  ChatMessage.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 02/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation

struct ChatMessage {
    
    let id: String
    let text: String
    let toID: String
    let fromID: String
    let timestamp: Int
    
    static func from(dict: [String : AnyObject], withKey key: String) -> ChatMessage?{
        guard let text = dict["text"] as? String else { return nil }
        guard let toID = dict["toID"] as? String else { return nil }
        guard let fromID = dict["fromID"] as? String else { return nil }
        guard let timestamp = dict["timestamp"] as? Int else { return nil }
        return ChatMessage(id: key,
                           text: text,
                           toID: toID,
                           fromID: fromID,
                           timestamp: timestamp)
    }
    
    func getValue() -> [String : Any]{
        return ["text" : text,
                "toID": toID,
                "fromID" : fromID,
                "timestamp" : timestamp]
    }
    
    func getChatPartner(ofUser userID: String) -> String?{
        if toID == userID {
            return fromID
        }else if fromID == userID {
            return toID
        }
        return nil
    }
}

extension Dictionary where Key == String, Value == ChatMessage{
    func getSortedMessages() -> [ChatMessage] {
        let array = Array(values)
        return array.sorted{ $0.0.timestamp > $0.1.timestamp }
    }
}

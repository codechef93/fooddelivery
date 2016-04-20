//
//  Channel.swift
//  Aditi
//
//  Created by macbook on 05/05/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import Foundation
import FirebaseFirestore
import MessageKit

enum MemberType : String, Codable {
    case customer = "CUSTOMER"
    case admin = "ADMIN"
    case driver = "DRIVER"
    
}

struct Member : Codable , SenderType {
    let id , name : String
    let type : MemberType
    
    init(document : [String:Any]){
        id = document["id"] as! String
        name = document["name"] as! String
        type = MemberType.init(rawValue: document["type"] as! String)!
    }
    
    var senderId: String {
        return id
    }
    
    var displayName: String {
        return name
    }
}

enum MsgType: String, Codable {
    case text = "1"
    case image = "2"
    case firstMsg = "10"
}

struct Message : MessageType {
    var sender: SenderType {
        return User.shared!
    }
    
    var messageId: String {
        return id
    }
    
    var sentDate: Date {
        return date.dateValue()
    }
    
    var kind: MessageKind {
        return .text(message)
    }
    
    let channelId, id, message, senderID, senderName : String
    let msgType : MsgType
    let date : Timestamp
    
    init(document : [String:Any]) {
        self.channelId  = document["channelId"] as! String
        self.id         = document["id"] as! String
        self.message    = document["message"] as! String
        self.msgType    = MsgType.init(rawValue: document["msgType"] as! String)!
        self.senderID   = document["senderId"] as! String
        self.senderName = document["senderName"] as! String
        self.date       = document["date"] as! Timestamp
    }
}

struct Channel {
    let id : String
    let active, read : Bool
    let member : Member
    var admin : Member?
    let message : Message
    
    init(document : [String:Any]) {
        self.id         = document["id"] as! String
        self.active         = document["active"] as! Bool
        self.read         = document["read"] as! Bool
        self.member =  Member(document: document["member"] as! [String:Any])
        if let admin = document["admin"] as? [String:Any] {
            self.admin =  Member(document:  admin)
        }
        self.message = Message(document: document["message"] as! [String:Any])
    }
}

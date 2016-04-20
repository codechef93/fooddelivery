//
//  File.swift
//  Aditi
//
//  Created by macbook on 05/05/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

protocol ChatViewModelDelegate : class {
    func addMessages(msgs : [Message])
}

class ChatViewModel : NSObject {
    let channelId : String!
    weak var delegate : ChatViewModelDelegate!
    var listener : ListenerRegistration?
  
    init(delegate : ChatViewModelDelegate, channelId: String) {
        self.delegate = delegate
        self.channelId = channelId
        super.init()
    }
    
    func observeMessages(){
        listener = messagesCol
            .whereField("channelId", isEqualTo: channelId!)
            .order(by: "date", descending: false)
            .addSnapshotListener { [weak self] (querySnap, err) in
            guard let snap = querySnap else {
                print("No messages in this channel")
                return
            }
            var add = true
            var newMsgs = [Message]()
            snap.documentChanges.forEach { diff in
                if diff.document.metadata.hasPendingWrites {
                    add = false
                    return
                }
                let data = diff.document.data()
                if (diff.type == .added) {
                    let msg = Message(document: data)
                    newMsgs.append(msg)
                }
                if (diff.type == .modified) {
                    let msg = Message(document: data)
                    newMsgs.append(msg)
                }
            }
            if add {
                self?.delegate.addMessages(msgs: newMsgs)
            }
        }
    }
    
    func sendMessage(message : String) {
        if AppDelegate.noInternet() {return}
        let msgId = messagesCol.document().documentID
        let msg = ["id" : msgId ,
        "date": FieldValue.serverTimestamp(),
        "message" : message,
        "channelId" : channelId!,
        "senderId" : User.shared!.id,
        "senderName" : User.shared!.name,
        "msgType" : MsgType.text.rawValue,
        "senderType" : ChatViewModel.msgSenderType()] as [String : Any]
        
        let msgRef = messagesCol.document(msgId)
        let channelRef = channelsCol.document(channelId!)
        let batch = db.batch()
        
        batch.setData(msg, forDocument: msgRef)
        
        #if Admin
        batch.updateData(["message" : msg, "read":true], forDocument: channelRef)
        #else
        batch.updateData(["message" : msg, "read":false], forDocument: channelRef)
        #endif
        
        UIApplication.showLoader()
        batch.commit{ (err) in
            if let e = err {
                UIApplication.showError(message: e.localizedDescription, delay: 1)
            }
        }
    }
    
   static func msgSenderType() -> String{
        #if Admin
        return "ADMIN"
        #elseif User
        return "CUSTOMER"
        #else
        return "DRIVER"
        #endif
    }
    
    deinit {
        listener?.remove()
    }
}

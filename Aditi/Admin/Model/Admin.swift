//
//  Admin.swift
//  AditiAdmin
//
//  Created by macbook on 23/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import UIKit

class Admin : Codable {
    static var shared : Admin?
    
    var createdAt : Timestamp
    var online : Bool
    var name : String
    var phone : String
    var platform : String
    var token : String?
    var id : String
    var email : String
    var lastSeen : Timestamp?
    
    var seen : String? {
        if let time = lastSeen {
            return "最後上線日期 \(time.dateValue().toStringwith(format: "dd/MM/yyyy hh:mm a"))"
        }
        return nil
    }
    
    lazy var ref = db.collection(Constants.getUserCollection()).document(id)

    init(document : [String:Any]) {
        self.createdAt = document["createdAt"] as! Timestamp
        self.online = document["online"] as! Bool
        self.name = document["name"] as! String
        self.phone = document["phone"] as! String
        self.platform = document["platform"] as! String
        self.token = document["token"] as? String
        self.id = document["id"] as! String
        self.email = document["email"] as! String
        self.lastSeen = document["lastSeen"] as? Timestamp
    }
    func toggleOnline(online : Bool, completion: ((_ err: Error?) -> Void)? ){
        ref.updateData(["online":online, "lastSeen":FieldValue.serverTimestamp()], completion: completion)
    }
    func logout(){
        Admin.shared?.toggleOnline(online: false, completion: nil)
        try? Auth.auth().signOut()
        Admin.shared = nil
        Router.login()
    }
//    func setupDisconnectRef(){
//        DatabaseRef userStatus =
//        FirebaseDatabase.getInstance().getReference("users/<user_id>/status");
//        userStatus.onDisconnect.setValue("offline");
//        userStatus.setValue("online");
//    }
}

//
//  User.swift
//  AditiUser
//
//  Created by macbook on 26/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import MessageKit

class User : Codable {
    static var shared : User?{
        get {
            if let user = UserDefaults.standard.decode(for: User.self, using: "User") {
                return user
            }
            return nil
        }
        set(user) {
            UserDefaults.standard.encode(for: user, using: "User")
        }
    }
    
    var createdAt : Timestamp
    var online : Bool
    var name : String
    var phone : String
    var platform : String
    var token : String?
    var id : String
    var email : String
    var lastSeen : Timestamp?
    
    var address: String?
    var city: String?
    var region: String?
    var area : String?
    var level : String?
    #if User || Internal
    var notifications : Bool
    #endif
    
    #if Admin
    var superAdmin : Bool? = false
    
    var can_admins : Bool? = false
    var can_category : Bool? = false
    var can_product : Bool? = false
    var can_chat : Bool? = false
    var can_order : Bool? = false
    var can_coupon : Bool? = false
    var can_content : Bool? = false
    var can_drivers : Bool? = false
    var can_city : Bool? = false
    var can_fcm : Bool? = false
    #endif
    
//    #if Internal
//    var cities : [String:String]? {
//        get {
//            if let cities = UserDefaults.standard.decode(for: [String:String].self, using: "cities") {
//                return cities
//            }
//            return nil
//        }
//        set(cities) {
//            UserDefaults.standard.encode(for: cities, using: "cities")
//        }
//    }
//    
    var impInfo : ImpInfo? {
        get {
            if let imp_info = UserDefaults.standard.decode(for: ImpInfo.self, using: "imp_info") {
                return imp_info
            }
            return nil
        }
        set(imp_info) {
            UserDefaults.standard.encode(for: imp_info, using: "imp_info")
        }
    }
//    #endif
    
    
    var seen : String? {
        if let time = lastSeen {
            return "最後上線日期 \(time.dateValue().toStringwith(format: "dd/MM/yyyy hh:mm a"))"
        }
        return nil
    }
    var postBody : [String:Any] {
        var dict = [String:Any]()
        dict = self.dictionary!
        dict["createdAt"] = self.createdAt.dateValue().toStringUTCwith(format: DateFormats.postFormat)
        if let lastSeen = lastSeen {
            dict["lastSeen"] = lastSeen.dateValue().toStringUTCwith(format: DateFormats.postFormat)
        }
        return dict
    }
    var firestoreBody : [String:Any] {
        var dict = [String:Any]()
        dict = self.dictionary!
        dict["createdAt"] = createdAt
        if let lastSeen = lastSeen {
            dict["lastSeen"] = lastSeen
        }
        return dict
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
        self.address = document["address"] as? String
        self.city = document["city"] as? String
        self.region = document["region"] as? String
        self.area = document["area"] as? String
        self.level = document["level"] as? String
        #if User || Internal
        self.notifications = document["notifications"] as! Bool
        #endif
        
        #if Admin
        self.superAdmin = document["superAdmin"] as? Bool ?? false
        
        self.can_admins = document["can_admins"] as? Bool ?? false
        self.can_category = document["can_category"] as? Bool ?? false
        self.can_product = document["can_product"] as? Bool ?? false
        self.can_chat = document["can_chat"] as? Bool ?? false
        self.can_order = document["can_order"] as? Bool ?? false
        self.can_coupon = document["can_coupon"] as? Bool ?? false
        self.can_content = document["can_content"] as? Bool ?? false
        self.can_drivers = document["can_drivers"] as? Bool ?? false
        self.can_city = document["can_city"] as? Bool ?? false
        self.can_fcm = document["can_fcm"] as? Bool ?? false
        #endif
    }
    func toggleOnline(online : Bool, completion: ((_ err: Error?) -> Void)? ){
        if online == false {
            ref.updateData(["online":online, "fcmToken":FieldValue.delete(),  "lastSeen":FieldValue.serverTimestamp()], completion: completion)
        }else{
            ref.updateData(["online":online, "lastSeen":FieldValue.serverTimestamp()], completion: completion)
        }
    }
    func toggleNotifications(notifications : Bool, completion: ((_ err: Error?) -> Void)? ){
        ref.updateData(["notifications":notifications], completion: completion)
    }
    func updatePermission(permission : [String : Any], completion: ((_ err: Error?) -> Void)? ){
        ref.updateData(permission, completion: completion)
    }
    
    func logout(){
        if AppDelegate.noInternet() {return}
        User.shared?.toggleOnline(online: false, completion: nil)
        try? Auth.auth().signOut()
        User.shared = nil
        #if User
        UserTabbarController.shared = nil
        #endif
        Cart.shared.clear()
        Router.logout()
    }
    func updateData(data: [String:Any]){
        if let address = data["address"] as? String{
            self.address = address
        }
        if let city = data["city"] as? String{
            self.city = city
        }
        if let region = data["region"] as? String{
            self.region = region
        }
        if let area = data["area"] as? String{
            self.area = area
        }
        if let level = data["level"] as? String{
            self.level = level
        }
        User.shared = self
    }
    func updateFcm(fcm : String){
        if let token = self.token, token == fcm { return }
        let data = ["token" : fcm]
        ref.updateData(data) { [weak self] (err) in
            if let e = err {
                print("Error updating fcm : \(e.localizedDescription)")
            }else{
                self?.updateData(data: data)
            }
        }
    }
}
extension User : SenderType {
    var senderId: String {
        return id
    }
    var displayName: String {
        return name
    }
}

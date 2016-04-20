//
//  Coupon.swift
//  Aditi
//
//  Created by macbook on 25/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

struct Coupon :  Codable {
   
    var createdAt : Timestamp
    var updatedAt : Timestamp
    var id : String
    var enable : Bool
    var title : String
    var desc : String?
    var code : String
    var fixed : Bool?
    var from : Timestamp
    var to : Timestamp
    var discount : String
    var usedBy: [String]?
    
    static func data(title : String,
                     desc : String?,
                     id: String,
                     discount : String,
                     fixed : Bool?,
                     to : Date,
                     from : Date,
                     code : String) -> [String:Any]{
        return [
            "createdAt" : FieldValue.serverTimestamp(),
            "updatedAt" : FieldValue.serverTimestamp(),
            "id" : id,
            "enable" : true,
            "title" : title,
            "desc" : desc ?? "",
            "discount" : discount,
            "to" : Timestamp(date: to),
            "from" : Timestamp(date: from),
            "code" : code,
            "fixed" : fixed ?? ""
            ] as [String : Any]
    }
    var postBody : [String:Any] {
        var dict = dictionary!
        dict["createdAt"] = createdAt.dateValue().toStringUTCwith(format: DateFormats.postFormat)
        dict["updatedAt"] = updatedAt.dateValue().toStringUTCwith(format: DateFormats.postFormat)
        dict["from"] = from.dateValue().toStringUTCwith(format: DateFormats.postFormat)
        dict["to"] = to.dateValue().toStringUTCwith(format: DateFormats.postFormat)
        return dict
    }
}

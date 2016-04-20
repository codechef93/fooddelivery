//
//  Category.swift
//  Aditi
//
//  Created by macbook on 25/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import Foundation
import FirebaseFirestore
import CodableFirebase
import UIKit

struct Category : Codable, Equatable {
    var id: String
    var image: String
    var title: String
    var createdAt : Timestamp
    var updatedAt : Timestamp
    var enable : Bool
    var desc : String?
    var cities: [CityItem]? = [CityItem]()
    
    init(document : [String:Any], docId: String) { // temp init not used anywhere, just to make codable
        id = docId
        image = document["image"] as! String
        title = document["title"] as! String
        desc = document["desc"] as? String
        createdAt = document["createdAt"] as! Timestamp
        updatedAt = document["updatedAt"] as! Timestamp
        enable = document["enable"] as! Bool
    }
  
    static func data(title : String, desc : String?, imgUrl : String, id: String, cities : [CityItem]?) -> [String:Any]{
        return [
            "createdAt" : FieldValue.serverTimestamp(),
            "updatedAt" : FieldValue.serverTimestamp(),
            "id" : id,
            "enable" : true,
            "title" : title,
            "image" : imgUrl,
            "desc" : desc ?? "",
            "cities" : cities == nil ? [CityItem]().map({$0.postBody}) : cities!.map({$0.postBody})
            ] as [String : Any]
    }
}

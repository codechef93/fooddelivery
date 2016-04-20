//
//  Product.swift
//  Aditi
//
//  Created by macbook on 25/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import Foundation
import FirebaseFirestore


struct Product : Codable, Equatable {
    var createdAt : Timestamp
    var updatedAt : Timestamp
    var id : String
    var enable : Bool
    var image : String
    var title : String
    var desc : String?
    var price : String
    var discount : String?
    var catId : String
    var stock : String
    
    var totalAmount : String {
        let newPrice = Int(price) == nil ? 0 : Int(price)!
        if let discount = self.discount , discount != "0" , let d = Int(discount){
            let discountAmount = (d * newPrice) / 100
            return "\(newPrice - discountAmount)"
        }
        return price
    }
    
    var discountAttrString : NSAttributedString? {
        let newPrice = Int(price) == nil ? 0 : Int(price)!
        if let discount = self.discount , discount != "0" {
            return NSAttributedString(string: "$\(newPrice)", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red, NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.strikethroughColor: UIColor.red])
        }
        return nil
    }
    
    init(document : [String:Any], docId: String) { // temp init not used anywhere, just to make codable
        id = docId
        image = document["image"] as! String
        title = document["title"] as! String
        desc = document["desc"] as? String
        createdAt = document["createdAt"] as! Timestamp
        updatedAt = document["updatedAt"] as! Timestamp
        enable = document["enable"] as! Bool
        price = document["price"] as! String
        discount = document["discount"] as? String
        catId = document["catId"] as! String
        stock = document["stock"] as! String
    }
    
    static func data(title : String, desc : String?, imgUrl : String, id: String, discount : String?, price : String, catId : String, stock : String) -> [String:Any]{
        return [
            "createdAt" : FieldValue.serverTimestamp(),
            "updatedAt" : FieldValue.serverTimestamp(),
            "id" : id,
            "enable" : true,
            "title" : title,
            "image" : imgUrl,
            "desc" : desc ?? "",
            "discount" : discount ?? "0",
            "price" : price,
            "catId" : catId,
            "stock" : stock
            ] as [String : Any]
    }
    
    var postBody : [String:Any] {
        var dict = [String:Any]()
        dict = self.dictionary!
        dict["createdAt"] = self.createdAt.dateValue().toStringUTCwith(format: DateFormats.postFormat)
        dict["updatedAt"] = self.updatedAt.dateValue().toStringUTCwith(format: DateFormats.postFormat)
        return dict
    }
}


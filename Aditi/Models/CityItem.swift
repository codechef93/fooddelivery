
import Foundation
import FirebaseFirestore
import CodableFirebase
import UIKit

struct CityItem : Codable, Equatable {
    var parent_city: String?
    var name: String?
    var city_code: String?
    
    init(document : [String:Any]) { // temp init not used anywhere, just to make codable
        parent_city = document["parent_city"] as? String
        name = document["name"] as? String
        city_code = document["city_code"] as? String
    }
  
    static func data(parent_city : String, name : String, city_code : String ) -> [String:Any]{
        return [
            "parent_city" : parent_city,
            "name" : name,
            "city_code" : city_code
            ] as [String : Any]
    }
    
    var postBody : [String:Any]{
        var dict = [String:Any]()
        dict["parent_city"] = parent_city ?? ""
        dict["name"] = name ?? ""
        dict["city_code"] = city_code ?? ""
        return dict
    }
}

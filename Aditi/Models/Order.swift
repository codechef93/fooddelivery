//
//  Order.swift
//  Aditi
//
//  Created by macbook on 03/05/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import Foundation
import FirebaseFirestore
import CodableFirebase

enum OrderStatus : Int, Codable, CaseIterable{
    case new
    case inprogress
    case completed
    
    var title : String {
        if self == .new { return "新訂單" }
        if self == .inprogress { return "處理中" }
        return "已完成"
    }
}

struct Order : Codable {
    let id  : String
    let date : Timestamp
    let customer  : User
    let total    : String
    let subTotal  : String
    let createdAt : Timestamp
    let products  : [CartItem]
    let updatedAt : Timestamp?
    let status : OrderStatus
    let driver : User?
    let token : String?
    let chargeId : String?
    var order_date: UInt64?
    var cod : Bool?
    var title : String {
        return self.products.map({ return $0.product.title + ", " }).joined().trimmingCharacters(in: .whitespaces)
    }
    
    var cellTitle : String {
        
        var city_code = customer.city == nil ? "" : customer.city
        var region_code = customer.region == nil ? "" : customer.region
        var area_code = customer.area == nil ? "" : customer.area
    

        let impInfo = User.shared?.impInfo
        if (impInfo != nil)
        {
            let cities_level1 = impInfo!.cities_level1
            if let first_item = cities_level1.first(where: {$0.name! == city_code}) {
                city_code = first_item.city_code
            }
            let cities_level2 = impInfo!.cities_level2
            if let first_item = cities_level2.first(where: {$0.name! == region_code}) {
                region_code = first_item.city_code
            }
            let cities_level3 = impInfo!.cities_level3
            if let first_item = cities_level3.first(where: {$0.name! == area_code}) {
                area_code = first_item.city_code
            }
        }

        city_code = city_code?.uppercased()
        region_code = region_code?.uppercased()
        area_code = area_code?.uppercased()

        let id = customer.id
        let startIndex = id.index(id.startIndex, offsetBy: id.count - 4)
        let idHash =  id[startIndex..<id.endIndex]//.uppercased()
        
        if (order_date != nil)
        {
            let timeVal = Date(timeIntervalSince1970: Double(order_date! / 1000))
            let day = timeVal.toStringwith(format: "dd")
            let hour = timeVal.toStringwith(format: "hh")
            let minute = timeVal.toStringwith(format: "mm")
            return "#\(city_code!)-\(region_code!)-\(area_code!)-" + "\(day)\(hour)\(minute)-\(idHash)"
                .replacingOccurrences(of: "/", with: "")
        }
        else
        {
            let timeVal = createdAt.dateValue()
            let day = timeVal.toStringwith(format: "dd")
            let hour = timeVal.toStringwith(format: "hh")
            let minute = timeVal.toStringwith(format: "mm")
            return "#\(city_code!)-\(region_code!)-\(area_code!)-" + "\(day)\(hour)\(minute)-\(idHash)"
            .replacingOccurrences(of: "/", with: "")
        }
        
    }
    
    var itemsQty: String {
        var qty = 0
        products.forEach { (item) in
           qty += item.quantity
        }
        return "\(qty) 產品"
    }
}

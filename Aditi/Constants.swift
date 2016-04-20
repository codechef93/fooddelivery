//
//  Constants.swift
//  AditiAdmin
//
//  Created by macbook on 13/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

let db = Firestore.firestore()
let channelsCol     = db.collection("Channels")
let adminsCol       = db.collection("Admins")
let customersCol    = db.collection("Customers")
let productsCol     = db.collection("Products")
let couponsCol      = db.collection("Coupons")
let driversCol      = db.collection("Drivers")
let contentsCol     = db.collection("Contents")
let ordersCol       = db.collection("Orders")
let categoriesCol   = db.collection("Categories")
let messagesCol     = db.collection("Messages")
let noticesCol     = db.collection("PushMessages")

struct Constants {
    static let goldenColor = #colorLiteral(red: 0.8392156863, green: 0.6784313725, blue: 0.1529411765, alpha: 1)
    static let navBarColor = #colorLiteral(red: 0.231372549, green: 0.231372549, blue: 0.231372549, alpha: 1)
    
    static func getUserCollection() -> String {
        #if Admin
        return "Admins"
        #elseif Internal
        return "Drivers"
        #else
        return "Customers"
        #endif
    }
    
    static let imgPlaceholder = UIImage(named: "imgPlaceholder")!
    static let stripePbKey = "pk_live_51H4n5DHyiKZJiqafblk0FL6j9SyZVfIIYscHKB01RbuXQ6URwq0zMu4KdrPej813rOnzfmqcRGJvolspqE2cwaAS00UlhlJ33u"
//    static let stripePbKey = "pk_test_51H4n5DHyiKZJiqafHGDgM6JNwKlPA6qyon5XWIBN9irxXS2YXdgLeQnZigdw4vIvOwZn4nnjwn40xPY2MJPV3PpR00X4FAzoGx"
}

struct DateFormats {
    static let onlyDate = "dd/MM/yyyy"
    static let dateAndTime = "dd/MM/yyyy hh:mm a"
    static let onlyTime = "hh:mm a"
    static let postFormat = "MMM dd, yyyy hh:mm:ss a"
}

struct Errors {
    static let phoneErr             = "invalid_phone_number"
    static let invalidPhoneErr      = "invalid_phone_number"
    static let policyErr   = "please_accept_agreement"
    static let usernameErr = "enter_name"
    static let emailErr    = "enter_email"
    
    static let invalidTitleErr   = "enter_title"
    static let pickImage         = "select_image"
    static let invalidImage      = "select_image"
    static let invalidPrice      = "enter_price"
    static let invalidStock      = "enter_stock_count"
    static let selectCategory    = "select_category"
    static let invalidCoupon     = "invalid_coupon"
    static let invalidDiscount   = "enter_discount_value"
    static let toDate            = "to_date"
    static let fromDate          = "from_date"
    static let invalidDates      = "invalid_date_range"
    static let invalidUsername   = "invalid_username"
    static let invalidAddress    = "invalid_address"
    static let invalidCityName   = "enter_city_name"
    static let invalidCityCide   = "enter_city_code"
    static let cityExists        = "city_already_exists"
    
    static let invalidDeliveryTime = "delivery_dt"
    static let invalidCode = "invalid_coupon"
    static let noAddress = "please_provide_address"
    static let noCity = "update_city"
    static let noChatsFound = "active_chat"
    static let invalidDriverNumber = "invalid_phone_number"
    
    static let userNotFound = "no_user_registered_with_this_number"
    static let noInternet   = "no_internet"
    static let invalidOtp   = "invalid_code"
    static let userDeleted  = "userDeleted"
}

struct Messages {
    static let categoryAdded    = "categoryAdded"
    static let categoryUpdated  = "categoryUpdated"
    
    static let productAdded     = "productAdded"
    static let productUpdated   = "productUpdated"
    
    static let profileUpdated = "profileUpdated"
    
    static let addedToCart = "addedToCart"
    static let removedFromCart = "removedFromCart"
    
    static let infoUpdated = "infoUpdated"
    static let orderCreated = "orderCreated"
    static let orderAccepted = "orderAccepted"
    static let orderCompleted = "orderCompleted"
    
    static let bannerUpdated   = "bannerUpdated"
    static let bannerRemoved   = "bannerRemoved"
    
    static let sessionEnded   = "sessionEnded"
    static let adminDel    = "adminDel"
    static let driverDel   = "driverDel"
}

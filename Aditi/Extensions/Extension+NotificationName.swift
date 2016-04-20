//
//  Extension+NotificationName.swift
//  AditiAdmin
//
//  Created by macbook on 29/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let productsLoaded = Notification.Name.init("productsLoaded")
    static let cartUpdated = Notification.Name.init("cartUpdated")
    static let contentUpdated = Notification.Name.init("contentUpdated")
    static let internet = Notification.Name.init("internet")
}

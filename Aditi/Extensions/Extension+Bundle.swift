//
//  Extension+Bundle.swift
//  Aditi
//
//  Created by macbook on 23/05/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import Foundation
import UIKit
extension Bundle {
    static func appName() -> String {
        guard let dictionary = Bundle.main.infoDictionary else {
            return ""
        }
        if let version : String = dictionary["CFBundleName"] as? String {
            return version
        } else {
            return ""
        }
    }
}

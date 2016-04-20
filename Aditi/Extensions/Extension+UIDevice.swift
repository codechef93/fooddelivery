//
//  Extension+UIDevice.swift
//  AditiAdmin
//
//  Created by macbook on 31/05/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import Foundation
import UIKit
extension UIDevice {
    var hasNotch: Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                print("iPhone X/XS/11 Pro")
                return true
            case 2688:
                print("iPhone XS Max/11 Pro Max")
                return true
            case 1792:
                print("iPhone XR/ 11 ")
                return true
            default:
                print("Unknown")
                return false
            }
        }
        return false
    }
}

//
//  Extension+UIImage+Snap.swift
//  SmartFlow
//
//  Created by macbook on 08/04/2020.
//  Copyright © 2020 InvisionSolutions. All rights reserved.
//

import Foundation
import UIKit
extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}

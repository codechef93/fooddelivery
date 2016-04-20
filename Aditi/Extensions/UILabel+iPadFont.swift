//
//  UILabel+iPadFont.swift
//  SmartFlow
//
//  Created by macbook on 19/03/2020.
//  Copyright © 2020 InvisionSolutions. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    func setiPadFont(add : CGFloat = 4){
        let name = self.font.familyName
        let size = self.font.pointSize
        self.font = UIFont(name: name, size: size + add)
    }
}

extension UITextField {
    func setiPadFont(add : CGFloat = 4){
        if let name = self.font?.familyName,
            let size = self.font?.pointSize{
            self.font = UIFont(name: name, size: size + add)
        }
    }
}

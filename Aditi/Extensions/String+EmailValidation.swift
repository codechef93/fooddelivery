//
//  String+EmailValidation.swift
//  SmartFlow
//
//  Created by macbook on 16/03/2020.
//  Copyright © 2020 InvisionSolutions. All rights reserved.
//

import Foundation

extension String {
    
    func isValidEmail() -> Bool {
        let emailRegex = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
        if (self.range(of: emailRegex, options: .regularExpression) == nil){
            return false
        }
        return true
    }
    
    
}

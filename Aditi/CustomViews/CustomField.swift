//
//  CustomField.swift
//  AditiAdmin
//
//  Created by macbook on 23/05/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

class CustomField: UITextField {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 4
    }
    

}

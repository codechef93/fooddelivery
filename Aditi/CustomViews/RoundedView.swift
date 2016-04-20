//
//  RoundedView.swift
//  Aditi
//
//  Created by macbook on 13/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

class RoundedView: UIView {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = 16
        clipsToBounds = true
        
    }
    

}
class CapsuleView: UIView {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = frame.size.height / 2
        clipsToBounds = true
        layer.borderWidth = 0.5
        layer.borderColor =  UIColor.lightGray.cgColor
    }
    

}

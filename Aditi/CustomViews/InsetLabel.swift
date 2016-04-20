//
//  InsetLabel.swift
//  AditiUser
//
//  Created by macbook on 27/05/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

class InsetLabel: UILabel {

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect)
//        let insets = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
//        super.drawText(in: rect.inset(by: insets))
    }
}


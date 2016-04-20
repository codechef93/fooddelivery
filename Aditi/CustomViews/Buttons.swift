//
//  WhiteBgButton.swift
//  AditiAdmin
//
//  Created by macbook on 13/04/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

class WhiteBgButton: UIButton {
    
    override func awakeFromNib() {
        layer.cornerRadius = frame.size.height * 0.5
        setTitleColor(Constants.goldenColor, for: .normal)
        backgroundColor = .white
    }
    
}

class AppColorBgButton: UIButton {
    
    override func awakeFromNib() {
        layer.cornerRadius = frame.size.height * 0.5
        setTitleColor(.white, for: .normal)
        backgroundColor = Constants.goldenColor
    }
    
}

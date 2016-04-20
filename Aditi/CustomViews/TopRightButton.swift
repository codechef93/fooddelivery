//
//  TopRightButton.swift
//  伴百味
//
//  Created by Shezu on 21/03/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit

class TopRightButton: UIButton {
    
    override func awakeFromNib() {
        layer.cornerRadius = frame.size.height * 0.5
        layer.borderColor = #colorLiteral(red: 0.6705882353, green: 0.6352941176, blue: 0.4941176471, alpha: 1)
        layer.borderWidth = 1
    }

}

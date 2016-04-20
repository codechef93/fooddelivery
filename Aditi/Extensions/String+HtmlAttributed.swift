//
//  String+HtmlAttributed.swift
//  SmartFlow
//
//  Created by macbook on 17/03/2020.
//  Copyright © 2020 InvisionSolutions. All rights reserved.
//

import Foundation
import UIKit
extension String {
    var attributed: NSMutableAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            let attrStr = try NSMutableAttributedString(data: data,
                                                 options: [.documentType: NSMutableAttributedString.DocumentType.html,
                                                           .characterEncoding: String.Encoding.utf8.rawValue],
                                                 documentAttributes: nil)
            let attributes : [NSAttributedString.Key: Any] = [
                .font : UIFont.poppinsMedium(size: 11),
                .foregroundColor : UIColor.lightGrayManate
            ]
            attrStr.addAttributes(attributes, range: NSRange(location: 0, length: attrStr.length - 1))
            return attrStr
        } catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
    }
}

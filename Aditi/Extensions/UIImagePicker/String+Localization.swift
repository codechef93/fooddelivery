//
//  String+Localization.swift
//  ImagePicker
//
//  Created by Ilker Baltaci on 11.06.18.
//

import Foundation


@objc extension NSString {
    
    var localized: String {
        return (self as String).localized
    }
    
    @objc func isEmpty() -> Bool {
        return (self as String).isEmpty
    }
}

extension String {
    func localized(params: String...) -> String {
        let localized = NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
        return localized
    }
}

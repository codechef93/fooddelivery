//
//  String+DateFormatter.swift
//  share-food
//
//  Created by Invision-040 on 3/15/19.
//  Copyright © 2019 Invision-040. All rights reserved.
//

import Foundation

extension String {
    var getTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        guard let dated = dateFormatter.date(from: self) else { return "" }
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: dated)
    }
    
    var getDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        guard let dated = dateFormatter.date(from: self) else { return "" }
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: dated)
    }
    
    var getDateTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        guard let dated = dateFormatter.date(from: self) else { return "" }
        dateFormatter.dateFormat = "MMM d, h:mm a" // "EEEE, MMM d, h:mm a"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: dated)
    }
}

extension String {
    func removeDecimal() -> String {
        if let decimalIndex = self.firstIndex(of: "."){
            return String(self[startIndex..<decimalIndex])
        }
        return self
    }
}

extension String {
    
    func hideNumberIfAny() -> String{
        let expressions = ["\\d{4}-\\d{7}",         //0336-3243339
                           "\\d{11}",               //03363243339
                           "\\+\\d{12}",            //+923363243339
                           "\\d{4}-\\d{3}-\\d{4}"   //0336-324-3339
        ]
        var string = self
        expressions.forEach{ regex in
            if let range = string.range(of: regex, options: .regularExpression){
                let beginIndex = string.index(range.lowerBound, offsetBy: 2)
                let textAtRange = String(string[beginIndex..<range.upperBound])
                print(textAtRange)
                string = string.replacingOccurrences(of: textAtRange, with: String(repeating: "*", count: textAtRange.count))
                print(string)
            }
        }
        return string
    }
    
}
extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
    var getIndex : Int? {
        if let index = Int(digits) {
            return index - 1
        }
        return nil
    }
}

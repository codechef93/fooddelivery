//
//  Extension+UserDefaults.swift
//  share-food
//
//  Created by Invision on 24/09/2019.
//  Copyright © 2019 Invision-040. All rights reserved.
//

import Foundation
extension UserDefaults {
    func decode<T : Codable>(for type: T.Type, using key : String) -> T? {
        guard let data = UserDefaults.standard.object(forKey: key) as? Data else { return nil }
        return try? PropertyListDecoder().decode(type, from: data)
    }
    
    func encode<T : Codable>(for type: T?, using key : String) {
        let encodedData = try? PropertyListEncoder().encode(type)
        UserDefaults.standard.set(encodedData, forKey: key)
        UserDefaults.standard.synchronize()
    }
     
    func rememberMe() -> Bool {
        return UserDefaults.standard.value(forKey: "RememberMe") as? Bool ?? false
    }
}

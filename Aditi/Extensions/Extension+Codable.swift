//
//  Extension+Codable.swift
//  share-food
//
//  Created by Invision-040 on 3/5/19.
//  Copyright © 2019 Invision-040. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil}
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap({ $0 as? [String: Any] })
    }
}

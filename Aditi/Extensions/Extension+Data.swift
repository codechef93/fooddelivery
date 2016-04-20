//
//  Extension+Data.swift
//  SmartFlow
//
//  Created by macbook on 31/03/2020.
//  Copyright © 2020 InvisionSolutions. All rights reserved.
//

import Foundation

extension Data {
    private static let mimeTypeSignatures: [UInt8 : String] = [
        0xFF : "image/jpeg",
        0x89 : "image/png",
        0x47 : "image/gif",
        0x49 : "image/tiff",
        0x4D : "image/tiff",
        0x25 : "application/pdf",
        0xD0 : "application/vnd",
        0x46 : "text/plain",
        ]
    
    var mimeType: String {
        var c: UInt8 = 0
        copyBytes(to: &c, count: 1)
        return Data.mimeTypeSignatures[c] ?? "application/octet-stream"
    }
    var ext: String {
        return mimeType.components(separatedBy: "/").last ?? "jpeg"
    }
    
    var sizeInString : String {
        let byteCount = self.count
        let bcf = ByteCountFormatter()
//        bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(byteCount))
        return string
    }
}

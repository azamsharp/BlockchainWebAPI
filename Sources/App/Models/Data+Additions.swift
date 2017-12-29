//
//  Data+Additions.swift
//  Blockchain
//
//  Created by Mohammad Azam on 12/21/17.
//  Copyright © 2017 Mohammad Azam. All rights reserved.
//

import Foundation
import CommonCrypto

extension Data {
   
    func sha256() -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(self.count), &hash)
        }
        return Data(bytes: hash)
    }
    
    func sha256AsString() -> String {
        
        let data = sha256()
        return String(data: data, encoding: .utf8)!
    }
    
    
    
}

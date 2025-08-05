//
//  ImageUploadResponse.swift
//  SCIMBO
//
//  Created by Sachtech on 03/09/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import Foundation

struct ImageUploadResponse: JsonDeserilizer {
    
    var errNum:Int = 0
    var message: String = ""
    
    mutating func deserilize(values: Dictionary<String, Any>?) {
        errNum = Int(values?["errNum"] as? String ?? "") ?? 99
        message = values?["message"] as? String ?? ""
    }
}

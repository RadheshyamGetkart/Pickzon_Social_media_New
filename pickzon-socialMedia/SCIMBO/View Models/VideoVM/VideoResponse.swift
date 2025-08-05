//
//  VideoResponse.swift
//  SCIMBO
//
//  Created by SachTech on 22/12/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import Foundation

struct VideoResponse: JsonDeserilizer {
    
    var errNum: Int = 0
    var message: String = ""
    
    mutating func deserilize(values: Dictionary<String, Any>?) {
        errNum = Int(values?["errNum"] as? String ?? "") ?? 0
        message = values?["message"] as? String ?? ""
    }
}

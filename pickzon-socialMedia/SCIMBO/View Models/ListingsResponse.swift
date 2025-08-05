//
//  SearchResponse.swift
//  Camo
//
//  Created by SachTech on 07/03/20.
//  Copyright © 2020 SachTech. All rights reserved.
//

import Foundation

struct ListingsResponse: JsonDeserilizer {
    
    var length: Int = 0
    var totalPages: Int = 0
    var errNum: Int = 0
    var message: String = ""

    mutating func deserilize(values: Dictionary<String, Any>?) {
        errNum = Int(values?["errNum"] as? String ?? "") ?? 0
        message = values?["message"] as? String ?? ""
        length = Int(values?["length"] as? String ?? "0") ?? 0
        totalPages = (values?["totalPages"] as? Int ?? 0)
    }
}

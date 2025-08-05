//
//  VideoRequest.swift
//  SCIMBO
//
//  Created by SachTech on 22/12/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import Foundation

struct VideoRequest: JsonSerilizer {
    
    var url: String = ""
    
    func serilize() -> Dictionary<String, Any> {
        return [
            "url": url
        ]
    }
}

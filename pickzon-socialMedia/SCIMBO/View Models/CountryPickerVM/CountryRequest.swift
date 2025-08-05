//
//  CountryRequest.swift
//  Susen Dating App
//
//  Created by Sachtech on 06/11/19.
//  Copyright © 2019 Sachtech. All rights reserved.
//

import Foundation
struct CountryRequest:JsonSerilizer {
    
    var apiKey: String = ""
    
    func serilize() -> Dictionary<String, Any> {
        return [
            "API_KEY": apiKey
        ]
    }
}

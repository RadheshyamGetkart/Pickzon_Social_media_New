//
//  CountryResponse.swift
//  Susen Dating App
//
//  Created by Sachtech on 06/11/19.
//  Copyright © 2019 Sachtech. All rights reserved.
//

import Foundation

struct CountryResponse: JsonDeserilizer {
    
    var status: Bool = false
    var message: String = ""
    var baseUrl: String = ""
    var countries = [Countries]()
    
    mutating func deserilize(values: Dictionary<String, Any>?) {
        status = values?["Status"] as? Bool ?? false
        message = values?["Message"] as? String ?? ""
        baseUrl = values?["base_url"] as? String ?? ""
        
        if let countryList = values?["data"] as? NSArray{
            for item in countryList{
                var country = Countries.init()
                country.deserilize(values: item as? Dictionary<String,Any>)
                countries.append(country)
            }
        }
    }
}
struct Countries: JsonDeserilizer{
    var id : String = ""
    var name: String = ""
    var abbrev: String = ""
    var phoneCode: String = ""
    var flag: String = ""
    
    mutating func deserilize(values: Dictionary<String, Any>?) {
        id = values?["id"] as? String ?? ""
        name = values?["name"] as? String ?? ""
        abbrev = values?["sortname"] as? String ?? ""
        phoneCode = values?["phonecode"] as? String ?? ""
        flag = values?["flag"] as? String ?? ""
    }
}

//
//  JsonSerilizer.swift
//  Coravida
//
//  Created by Sachtech on 09/04/19.
//  Copyright © 2019 Chanpreet Singh. All rights reserved.
//

import Foundation

protocol JsonSerilizer{
    func serilize() -> Dictionary<String,Any>
}


extension Dictionary where Key == String {

    func toJsonString() -> String{

        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [])
        return String(data: jsonData!, encoding: .utf8) ?? ""

    }
    func toJsonObject() -> Any{

        let jsonData = (try? JSONSerialization.data(withJSONObject: self, options: []))!
        let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: [])
        return jsonObject
    }
}

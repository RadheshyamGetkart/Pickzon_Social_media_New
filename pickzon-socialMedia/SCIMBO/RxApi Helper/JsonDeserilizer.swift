//
//  JsonDeserilizer.swift
//  Coravida
//
//  Created by Sachtech on 09/04/19.
//  Copyright © 2019 Chanpreet Singh. All rights reserved.
//

import Foundation

protocol JsonDeserilizer {
    init()
    mutating func deserilize(values : Dictionary<String,Any>?)
}

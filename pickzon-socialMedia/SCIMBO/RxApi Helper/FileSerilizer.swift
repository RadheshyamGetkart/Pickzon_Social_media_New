//
//  FileSerilizer.swift
//  Coravida
//
//  Created by Sachtech on 09/04/19.
//  Copyright © 2019 Chanpreet Singh. All rights reserved.
//

import Foundation
import UIKit

protocol FileSerilizer {
    func file() -> (String,Data)
}

struct CommonRequest:JsonSerilizer {
    
    func serilize() -> Dictionary<String, Any> {
        return [:]
    }
}

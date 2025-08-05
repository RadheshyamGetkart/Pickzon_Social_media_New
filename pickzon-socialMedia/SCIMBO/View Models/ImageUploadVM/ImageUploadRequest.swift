//
//  ImageUploadRequest.swift
//  SCIMBO
//
//  Created by Sachtech on 03/09/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import Foundation
import UIKit

struct ImageUploadRequest: JsonSerilizer, FileSerilizer{
  
    var data: Data = Data()
    
    func serilize() -> Dictionary<String, Any> {
        return [:]
    }
    
    func file() -> (String, Data) {
        return ("picture", data)
    }
}

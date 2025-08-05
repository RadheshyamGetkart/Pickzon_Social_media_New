//
//  LocalErrors.swift
//  Camo
//
//  Created by SachTech on 20/02/20.
//  Copyright © 2020 SachTech. All rights reserved.
//

import Foundation

struct LocalErrors {

    let kErrorDomain = "PhotoEditorErrorDomain"
    let kErrorCode = 100

    static let shared = LocalErrors()

    func errorWithDescription(_ desc:String)->NSError{
        return NSError(domain: kErrorDomain, code: kErrorCode, userInfo: [kCFErrorLocalizedDescriptionKey as String:desc])
    }
}

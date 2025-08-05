//
//  Validator.swift
//  Coravida
//
//  Created by Sachtech on 09/04/19.
//  Copyright © 2019 Chanpreet Singh. All rights reserved.
//

import Foundation

extension String{
    
    
    func isValidName() -> Bool {
        let alphaNumericRegEx = #"[a-zA-Z\s]"#
        let predicate = NSPredicate(format:"SELF MATCHES %@", alphaNumericRegEx)
        return predicate.evaluate(with: self)
    }
    
    
    var isValidEmail: Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    
    var isAlphanumeric: Bool {
        return range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    var isValidPassword: Bool{
        //Password must be of minimum 5 characters at least 1 Alphabet and 1 Number
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d$@$!%*#?&]{5,}$"
        let passTest = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return passTest.evaluate(with: self)
    }
    
    
    var containsSpecialCharacter: Bool {
        let regex = ".*[^A-Za-z0-9].*"
        let testString = NSPredicate(format:"SELF MATCHES %@", regex)
        return testString.evaluate(with: self)
    }
    
    var isValidNameWithNumber: Bool {
        let alphaNumericRegEx = "[a-zA-Z0-9]"
        let predicate = NSPredicate(format:"SELF MATCHES %@", alphaNumericRegEx)
        return predicate.evaluate(with: self)
    }
    
    var isPanCardValid: Bool {
        let alphaNumericRegEx = "[A-Z]{5}[0-9]{4}[A-Z]{1}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", alphaNumericRegEx)
        return predicate.evaluate(with: self)
    }
    
    
    var isIfscCodeValid: Bool {
        //            let alphaNumericRegEx = "^[A-Z]{4}0[A-Z0-9]{6}$"
        
        let alphaNumericRegEx = "^[a-zA-Z0-9]{11}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", alphaNumericRegEx)
        return predicate.evaluate(with: self)
    }
    
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}

protocol Validator: AnyObject {
    func isValid() -> Bool
    func errorReason() -> (String,ValidatorKeys)
}

enum ValidatorKeys {
    case kEmail
    case kPassword
    case kUsername
    case kNewPass
    case kConfirmPass
    case kUnknown
}

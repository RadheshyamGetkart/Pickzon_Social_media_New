//
//  String.swift
//
//  Created by Rahul Tiwari on 3/5/20.
//  Copyright © 2020 CASPERON. All rights reserved.

import UIKit
import TextAttributes

public extension NSAttributedString {
    
    func heightWithConstrainedWidth(_ width: CGFloat) -> CGFloat {
        let boundingSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesLineFragmentOrigin
        let size = boundingRect(with: boundingSize, options: options, context: nil)
        return ceil(size.height)
    }
}

public extension String {
    
    func attributedComment() -> NSAttributedString {
        let attrs = TextAttributes()
            .font(UIFont.defaultFont(size: 13))
            .foregroundColor(UIColor.white)
            .alignment(.left)
            .lineSpacing(1)
            .dictionary
        return NSAttributedString(string: self, attributes: attrs)
    }
    
    func attributedCommentWithDarkGray() -> NSAttributedString {
        let attrs = TextAttributes()
            .font(UIFont.defaultFont(size: 13))
            .foregroundColor(UIColor.darkGray)
            .alignment(.left)
            .lineSpacing(1)
            .dictionary
        return NSAttributedString(string: self, attributes: attrs)
    }
    
    static func random(_ length: Int = 4) -> String {
        let base = "abcdefghijklmnopqrstuvwxyz"
        var randomString: String = ""
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
    
}

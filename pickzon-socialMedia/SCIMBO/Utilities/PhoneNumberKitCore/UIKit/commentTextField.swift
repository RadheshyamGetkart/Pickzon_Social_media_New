//
//  commentTextField.swift
//  SCIMBO
//
//  Created by Rahul Tiwari on 3/9/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import UIKit

@IBDesignable
class commentTextField: UITextField {
    
    @IBInspectable var insetX: CGFloat = 0
    @IBInspectable var insetY: CGFloat = 0
    
    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX , dy: insetY)
    }
    
    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX , dy: insetY)
    }
}

//
//  UIView.swift
///
//  Created by Rahul Tiwari on 3/5/20.
//  Copyright © 2020 CASPERON. All rights reserved.

import UIKit

extension UIView {
    
    var scale: CGFloat {
        set(value) {
            transform = CGAffineTransform(scaleX: value, y: value)
        }
        get {
            return 0
        }
    }
}

//
//  UIFont.swift
//
//  Created by Rahul Tiwari on 3/5/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import UIKit

extension UIFont {
    
    static func defaultFont(size: CGFloat) -> UIFont {
        return UIFont(name: UIFont.defaultFontName(), size: size)!
    }
    
    static func defaultFontName() -> String {
        return "Roboto-Regular"
    }
    
    
}

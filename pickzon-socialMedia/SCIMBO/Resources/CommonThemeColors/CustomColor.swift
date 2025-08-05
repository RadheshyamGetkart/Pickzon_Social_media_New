//
//  CustomColor.swift
//
//
//  Created by CASPERON on 19/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit

class CustomColor: NSObject {
    static let sharedInstance=CustomColor()
//    let themeColor = Themes.sharedInstance.UIColorFromHex(0x7ABC3B)
    let themeColor = Themes.sharedInstance.UIColorFromHex(0x19B754)
    
    
    let alertColor = UIColor(red:0.00, green:0.66, blue:0.90, alpha:1.0)
    let alertColorForJss:UInt32 = 0x7ABC3B
    let bottomBorderColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
    let SecondrythemeColor = UIColor(red: 211/255.0, green: 210/255.0, blue: 205/255.0, alpha: 1)
    let lightgrayColor = UIColor(red: 227/255.0, green: 227/255.0, blue: 227/255.0, alpha: 1)
    let lightgraySecColor = UIColor(red: 127/255.0, green: 127/255.0, blue: 127/255.0, alpha: 1)
    let lightBlueColor = UIColor(red: 0/255.0, green: 102/255.0, blue: 204/255.0, alpha: 1)
    
    
     let BGColor = Themes.sharedInstance.UIColorFromHex(0xEEEEEE)
    
    let newThemeColor = Themes.sharedInstance.colorWithHexString(hex: "#007aff") //Themes.sharedInstance.UIColorFromHex(0x19B754) //Themes.sharedInstance.colorWithHexString(hex: "#0000FF")
    
}

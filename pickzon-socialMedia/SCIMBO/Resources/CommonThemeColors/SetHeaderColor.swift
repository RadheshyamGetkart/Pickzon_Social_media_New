//
//  SetHeaderColor.swift
//
//
//  Created by CASPERON on 19/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit

class SetHeaderColor: UIView {
    
    required init(coder aDecoder:NSCoder){
        super.init(coder: aDecoder)!
//        self.backgroundColor = CustomColor.sharedInstance.themeColor
        
        self.backgroundColor = Themes.sharedInstance.colorWithHexString(hex: "#007BFF") 

    }
    
     

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

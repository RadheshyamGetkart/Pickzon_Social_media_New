//
//  AlertView.swift
//  Bitrus App
//
//  Created by Rohit Bisht on 31/05/19.
//  Copyright © 2019 Radheshyam Yadav. All rights reserved.
//

import UIKit

typealias alertCompletionBlock = (String?, NSInteger?) -> ()

class AlertView: NSObject {
    static var sharedManager = AlertView()
    var isAlertViewShowing = false
    func presentAlertWith(title : NSString, msg: NSString, buttonTitles:NSArray, onController:UIViewController, dismissBlock:@escaping alertCompletionBlock) {
        
        if msg.isKind(of: NSString.self  as AnyClass) {
            
            let buttonTitle = buttonTitles.firstObject
            
            if (buttonTitle == nil) {
                return
            }
            let alertController = UIAlertController.init(title: title as String, message: msg as String, preferredStyle:.alert)
            
            for index in 0..<buttonTitles.count  {
                let alertAction = UIAlertAction.init(title: buttonTitles.object(at: index) as? String, style:.default) { (action) in
                    dismissBlock(action.title,index)
                }
                alertController.addAction(alertAction)
            }
            onController.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func displayMessage(title : String, msg : String, controller : UIViewController) -> Void {
        
        presentAlertWith(title: title as NSString, msg: msg as NSString, buttonTitles: ["OK"], onController: controller) { (selectedStr, index) in
            
        }
    }
    
    func displayMessageWithAlert(title : String, msg : String) -> Void {
        
        if isAlertViewShowing == false{
            let alert = UIAlertView(title: title, message: msg, delegate: self, cancelButtonTitle: "Ok")
            alert.show()
            isAlertViewShowing = true
            
        }
       
    }
    
 
    
}


extension AlertView:UIAlertViewDelegate{
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        self.isAlertViewShowing = false
    }
    
}

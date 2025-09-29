//
//  WelcomeVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 29/09/25.
//  Copyright © 2025 Pickzon Inc. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {

    @IBOutlet weak var btnIAgree:UIButton!
    @IBOutlet weak var btnTermsAndPrivacy:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        btnTermsAndPrivacy.layer.cornerRadius = 8.0
        btnTermsAndPrivacy.clipsToBounds = true
        // Do any additional setup after loading the view.
        
        // Create an attributed string for the button title
        let attributedString = NSMutableAttributedString(string: "Terms and Privacy Policy")
        
        // Define the attributes, including the underline style
        let underlineAttributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.label // Optional: set text color
        ]
        
        // Apply the attributes to the entire string
        attributedString.addAttributes(underlineAttributes, range: NSRange(location: 0, length: attributedString.length))
        
        // Set the attributed title for the button
        btnTermsAndPrivacy.setAttributedTitle(attributedString, for: .normal)
    }
    
//MARK: UIButton Action Methods
    
    @IBAction func termsCondition(_ sender : UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController:PrivacyPolicyViewController = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
        viewController.strTitle = "Privacy Policy"
        viewController.strURl = Constant.sharedinstance.privacyURL
        self.pushView(viewController, animated: true)
    }
    
    @IBAction func agreeTermsCondition(_ sender : UIButton){
        
        self.navigationController?.popViewController(animated: false)
    }

}

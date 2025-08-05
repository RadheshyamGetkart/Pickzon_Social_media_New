//
//  PopupVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/7/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class PopupVC: UIViewController {

    @IBOutlet weak var lblMessage:UILabel!
    @IBOutlet weak var btnDone:UIButtonX!
    @IBOutlet weak var imgVwEmogi:UIImageView!
    @IBOutlet weak var bgVw:UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        // Do any additional setup after loading the view.
        self.lblMessage.text = "This post does not meet Pickzon \n Ad guidelines."
    }
    


    //MARK: UIButton action methods
    @IBAction func doneBtnAction(_ sender : UIButton){
        
        self.dismissView(animated: true)
    }

}

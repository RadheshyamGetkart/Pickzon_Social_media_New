//
//  ReedemVirtualPassVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 25/07/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class ReedemVirtualPassVC: UIViewController {
    
    
    @IBOutlet weak var btnClose:UIButton!
    @IBOutlet weak var btnSubmit:UIButton!
    @IBOutlet weak var btnVerify:UIButton!
    @IBOutlet weak var btnClickHereForVip:UIButton!
    @IBOutlet weak var lblTopTitle:UILabel!
    @IBOutlet weak var lblSecondTitle:UILabel!
    @IBOutlet weak var lblPickzonId:UILabel!
    @IBOutlet weak var imgVwProfile:UIImageView!
    @IBOutlet weak var imgVwPass:UIImageView!
    @IBOutlet weak var bgVwUser:UIView!
    @IBOutlet weak var txtFdPickzonId:UITextField!

    
    //MARK: UIButton Action Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor =  UIColor.black.withAlphaComponent(0.6)
        txtFdPickzonId.setAttributedPlaceHolder(text: "Enetr PickZon Id", color: .lightGray)
       // bgVwUser.isHidden = true
        btnClose.setImageTintColor(.darkGray)
        btnSubmit.layer.cornerRadius = 5.0
        btnSubmit.clipsToBounds = true
    }
    
    //MARK: UIButton Action Methods
    
    @IBAction func verifyBtnActionMethod(_ sender : UIButton){
        
    }
    
    @IBAction func submitBtnActionMethod(_ sender : UIButton){
        
    }
    
    
    @IBAction func closeBtnActionMethod(_ sender : UIButton){
        
        self.dismissView(animated: true)
    }
    
    @IBAction func clickForVIPAndRegularPassBtnActionMethod(_ sender : UIButton){
        
        
    }
}

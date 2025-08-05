//
//  PasswordCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 9/11/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class PasswordCell: UITableViewCell {
    @IBOutlet weak var txtPassword:SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var txtConfirmPassword:SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var bgView:UIView!
    
    @IBOutlet weak var btnShowHidePassword:UIButton!
    @IBOutlet weak var btnShowHideConfirmPassword:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        txtPassword.textContentType = .newPassword
        txtPassword.textContentType = .password
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func showHidePasswordAction(){
        
//        if btnShowHidePassword.currentImage == UIImage(named: "eye-5 1") {
//            btnShowHidePassword.setImage(UIImage(named: "eye-4 1"), for: .normal)
//            txtPassword.isSecureTextEntry = false
//        }else {
//            btnShowHidePassword.setImage(UIImage(named: "eye-5 1"), for: .normal)
//            txtPassword.isSecureTextEntry = true
//        }
//        
        
        if btnShowHidePassword.currentImage == PZImages.showEye {
            btnShowHidePassword.setImage(PZImages.hideEye, for: .normal)
            txtPassword.isSecureTextEntry = true
        }else {
            btnShowHidePassword.setImage(PZImages.showEye, for: .normal)
            txtPassword.isSecureTextEntry = false
        }
        
    }
    @IBAction func showHideConfirmPasswordAction(){
        
//        if btnShowHideConfirmPassword.currentImage == UIImage(named: "eye-5 1") {
//            btnShowHideConfirmPassword.setImage(UIImage(named: "eye-4 1"), for: .normal)
//            txtConfirmPassword.isSecureTextEntry = false
//        }else {
//            btnShowHideConfirmPassword.setImage(UIImage(named: "eye-5 1"), for: .normal)
//            txtConfirmPassword.isSecureTextEntry = true
//        }
        
        if btnShowHideConfirmPassword.currentImage == PZImages.showEye {
            btnShowHideConfirmPassword.setImage(PZImages.hideEye, for: .normal)
            txtConfirmPassword.isSecureTextEntry = true
        }else {
            btnShowHideConfirmPassword.setImage(PZImages.showEye, for: .normal)
            txtConfirmPassword.isSecureTextEntry = false
        }
    }
    
}

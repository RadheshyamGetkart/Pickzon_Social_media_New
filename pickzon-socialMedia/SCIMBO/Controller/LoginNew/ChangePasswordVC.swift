//
//  ChangePasswordVC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 9/18/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController {
    
    
    @IBOutlet weak var viewEmail:UIViewX!
    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var viewOtp:UIView!
    @IBOutlet weak var txtOTP: UITextField!
    
    @IBOutlet weak var viewOldPassword:UIView!
    @IBOutlet weak var txtOldPassword: UITextField!
    @IBOutlet weak var btnShowHideOldPassword:UIButton!
    
    @IBOutlet weak var viewPassword:UIView!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnShowHidePassword:UIButton!
    
    @IBOutlet weak var viewConfirmPassword:UIView!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnShowHideConfirmPassword:UIButton!
    @IBOutlet weak var btnChangePassword:CustomButton!
    
    @IBOutlet weak var lblOldPassword:UILabel!
    @IBOutlet weak var lblNewPassword:UILabel!
    @IBOutlet weak var lblConfirmPassword:UILabel!
   
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!

    @IBOutlet weak var cnstrntTopStackVw:NSLayoutConstraint!

    var country_Code = String()
    var uid = ""
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        btnChangePassword.backgroundColor = Themes.sharedInstance.colorWithHexString(hex: "007BFF")
        viewEmail.isHidden = true
        viewOtp.isHidden = true
        viewOldPassword.isHidden = true
        viewPassword.isHidden = true
        viewConfirmPassword.isHidden = true
        btnChangePassword.isHidden = true
        
        
        if Settings.sharedInstance.isEmailVerified == 0 {
            viewEmail.isHidden = false
        }else if Settings.sharedInstance.isEmailVerified == 1 && Settings.sharedInstance.isPassword == 1 {
            viewOldPassword.isHidden = false
            viewPassword.isHidden = false
            viewConfirmPassword.isHidden = false
            btnChangePassword.isHidden = false
        }else {
            viewPassword.isHidden = false
            viewConfirmPassword.isHidden = false
            btnChangePassword.isHidden = false
        }
    
        self.lblOldPassword.setAttributedPlaceHolder(frstText: "Old Password", color: UIColor.label, secondText: "*", secondColor: UIColor.red)
        self.lblNewPassword.setAttributedPlaceHolder(frstText: "New Password", color: UIColor.label, secondText: "*", secondColor: UIColor.red)
        self.lblConfirmPassword.setAttributedPlaceHolder(frstText: "Confirm Password", color: UIColor.label, secondText: "*", secondColor: UIColor.red)
        
        self.txtOldPassword.addLeftPadding()
        self.txtPassword.addLeftPadding()
        self.txtConfirmPassword.addLeftPadding()
        self.txtEmail.addLeftPadding()
        self.txtOTP.addLeftPadding()

        self.txtOldPassword.attributedPlaceholder = getTextfromVerifiedAndString(name: "Old Password", imageName: "chat_lock")
        self.txtPassword.attributedPlaceholder = getTextfromVerifiedAndString(name: "New Password", imageName: "chat_lock")

        self.txtConfirmPassword.attributedPlaceholder = getTextfromVerifiedAndString(name: "Confirm New Password", imageName: "chat_lock")

    }
    
    
    func getTextfromVerifiedAndString(name:String, color:UIColor = .lightGray,imageName:String, fontSize:CGFloat = 15) -> NSMutableAttributedString {
        
        
        let nameAttr = NSMutableAttributedString(string: name, attributes:[
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: UIFont(name:"Roboto-Regular", size: fontSize)!])
        
        let attachment:NSTextAttachment = NSTextAttachment()
        attachment.bounds = CGRect(x: 0, y: -1.0, width: 15, height: 15)
        attachment.image = UIImage(named: imageName)
        let attachmentString:NSMutableAttributedString = NSMutableAttributedString(attachment: attachment)
        
        attachmentString.append(NSMutableAttributedString(string: " "))
        attachmentString.append(nameAttr)
        
        return attachmentString
        
    }
    
    
    //MARK: UIButton Action Methods
    @IBAction func backButtonAction()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showHideOldPasswordAction(){

        if btnShowHideOldPassword.currentImage == PZImages.showEye {
            btnShowHideOldPassword.setImage(PZImages.hideEye, for: .normal)
            txtOldPassword.isSecureTextEntry = true
        }else {
            btnShowHideOldPassword.setImage(PZImages.showEye, for: .normal)
            txtOldPassword.isSecureTextEntry = false
        }
        
    }
    
    @IBAction func showHidePasswordAction(){

        if btnShowHidePassword.currentImage == PZImages.showEye {
            btnShowHidePassword.setImage(PZImages.hideEye, for: .normal)
            txtPassword.isSecureTextEntry = true
        }else {
            btnShowHidePassword.setImage(PZImages.showEye, for: .normal)
            txtPassword.isSecureTextEntry = false
        }
    }
    @IBAction func showHideConfirmPasswordAction(){
        
        if btnShowHideConfirmPassword.currentImage == PZImages.showEye {
            btnShowHideConfirmPassword.setImage(PZImages.hideEye, for: .normal)
            txtConfirmPassword.isSecureTextEntry = true
        }else {
            btnShowHideConfirmPassword.setImage(PZImages.showEye, for: .normal)
            txtConfirmPassword.isSecureTextEntry = false
        }
    }
    
    
    @IBAction func sendOTPAction(_ sender:UIButton) {
        view.endEditing(true)
            
        if (txtEmail.text?.length ?? 0) > 0 {
            txtEmail.text = txtEmail.text?.trimmingCharacters(in: .whitespaces)
        }
        
        if  txtEmail.text?.length == 0 {
            self.view.makeToast(message: "Email cannot be left blank" , duration: 3, position: HRToastActivityPositionDefault)
        }else if txtEmail.text?.isValidEmail == false {
            self.view.makeToast(message: "Please enter valid email id" , duration: 3, position: HRToastActivityPositionDefault)
        }else {
            
            var param:NSDictionary = [:]
            param = ["mobileNumber":"", "countryCode":"", "email":"\((txtEmail.text ?? ""))", "otpHashcode":"",  "type":1,  "deviceId":"\(Themes.sharedInstance.getDeviceUUIDString())", "OS":"ios", "modelName":"\(UIDevice.current.model)"]
            
            Themes.sharedInstance.activityView(View: self.view)
            
            
            URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.authSendOTPUrl, param: param) { (responseObject, error) -> () in
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                //self.NextButton.isUserInteractionEnabled = true
                if(error != nil)
                {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    
                    print(error ?? "defaultValue")
                    
                }
                else{
                    print(responseObject ?? "response")
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int ?? 0
                    let message = result["message"]
                    
                    if status == 1{
                        let payload = result["payload"] as? NSDictionary ?? [:]
                        self.uid = payload["uid"] as? String ?? ""
                        
                        self.viewOtp.isHidden = false
                        self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)
                    }else{
                        self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)
                        
                    }
                    
                }
            }
        }
    }
    
    @IBAction func verifyOTPAction(_ sender:UIButton) {
        view.endEditing(true)
        
        
        var param:NSDictionary = [:]
        param = ["mobileNumber":"", "countryCode":"", "otp":"\(txtOTP.text ?? "")", "email":"\(txtEmail.text ?? "")",  "type":1, "uid":"\(uid)", "deviceId":"\(Themes.sharedInstance.getDeviceUUIDString())", "OS":"ios", "modelName":"\(UIDevice.current.model)"]
        
        Themes.sharedInstance.activityView(View: self.view)
        
        
        
        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.authVerifyOTPUrl, param: param) { (responseObject, error) -> () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            //self.NextButton.isUserInteractionEnabled = true
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                
                print(error ?? "defaultValue")
                
            }
            else{
                print(responseObject ?? "response")
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    
                    
                    let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { alert -> Void in
                        self.viewEmail.isHidden = true
                        self.viewOtp.isHidden = true
                        if Settings.sharedInstance.isPassword == 1 {
                            self.viewOldPassword.isHidden = false
                            self.viewPassword.isHidden = false
                            self.viewConfirmPassword.isHidden = false

                        }else {
                            
                            self.viewPassword.isHidden = false
                            self.viewConfirmPassword.isHidden = false
                        }
                        self.btnChangePassword.isHidden = false
                        
                    })
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }else{
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
                
            }
        }
    }
    
    @IBAction func changePasswordAction(_ sender:UIButton) {
        self.view.endEditing(true)
        if Settings.sharedInstance.isPassword == 1 && (txtOldPassword.text?.length ?? 0) > 0 {
            txtOldPassword.text = txtOldPassword.text?.trimmingCharacters(in: .whitespaces)
        }
        
        if (txtPassword.text?.length ?? 0) > 0 {
            txtPassword.text = txtPassword.text?.trimmingCharacters(in: .whitespaces)
        }
        if (txtConfirmPassword.text?.length ?? 0) > 0 {
            txtConfirmPassword.text = txtConfirmPassword.text?.trimmingCharacters(in: .whitespaces)
        }
        
        if Settings.sharedInstance.isPassword == 1 && (txtOldPassword.text?.length ?? 0) == 0 {
            self.view.makeToast(message: "Please enter old password" , duration: 3, position: HRToastActivityPositionDefault)
        }else if (txtPassword.text ?? "").length == 0 {
            self.view.makeToast(message: "Please enter password" , duration: 3, position: HRToastActivityPositionDefault)
        }else if (txtPassword.text ?? "") != (txtConfirmPassword.text ?? "") {
            self.view.makeToast(message: "Password  and confirm password does not match" , duration: 3, position: HRToastActivityPositionDefault)
        }else if (txtPassword.text ?? "").isValidPassword == false {
            self.view.makeToast(message: "Password must be of minimum 5 characters at least 1 Alphabet and 1 Number" , duration: 3, position: HRToastActivityPositionDefault)
        }else if (txtOldPassword.text ?? "") == (txtPassword.text ?? "") {
            self.view.makeToast(message: "Old password  and new password cannot be same" , duration: 3, position: HRToastActivityPositionDefault)
        }else {
            
            var param:NSDictionary = [:]
            
            if Settings.sharedInstance.isPassword == 1 {
                param = ["oldPassword":"\(txtOldPassword.text ?? "")", "newPassword":"\(txtPassword.text ?? "")", "type" : 1]
            }else {
                param = ["oldPassword":"", "newPassword":"\(txtPassword.text ?? "")", "type" : 0]
            }
            
            Themes.sharedInstance.activityView(View: self.view)
            
            
            
            URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.changePasswordURL,  param: param) { (responseObject, error) -> () in
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                //self.NextButton.isUserInteractionEnabled = true
                if(error != nil)
                {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    
                    print(error ?? "defaultValue")
                    
                }
                else{
                    print(responseObject ?? "response")
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int ?? 0
                    let message = result["message"] as? String ?? ""
                    
                    if status == 1{
                        
                        let alert:UIAlertController=UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
                        {_ in
                            self.navigationController?.popViewController(animated: true)
                        }
                        alert.addAction(action)
                        self.presentView(alert, animated: true, completion: nil)
                        
                    }else{
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                        
                    }
                    
                }
            }
        }
    }
    
    
    
}

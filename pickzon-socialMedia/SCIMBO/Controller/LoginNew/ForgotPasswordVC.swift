//
//  ForgotPasswordVC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 9/11/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var lblCountrycode: UILabel!
    
    @IBOutlet weak var viewEmail:UIViewX!
    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var viewMobile:UIView!
    @IBOutlet weak var viewMCountryCode:UIView!
    @IBOutlet weak var txtMobile: UITextField!
    
    @IBOutlet weak var viewOtp:UIView!
    @IBOutlet weak var txtOTP: UITextField!
    
    @IBOutlet weak var viewPassword:UIView!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnShowHidePassword:UIButton!
    
    @IBOutlet weak var viewConfirmPassword:UIView!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnShowHideConfirmPassword:UIButton!
    
    @IBOutlet weak var btnShowHideEmail:UIButton!
    @IBOutlet weak var segmentControl:UISegmentedControl!
    
    @IBOutlet weak var btnUpdatePassword:CustomButton!
    
    var country_Code = String()
    
    var isEmail = false
    var uid = ""
    
    @IBOutlet weak var btnSendOtp: UIButton!
    @IBOutlet weak var lblTimer:UILabel!
    var seconds:Int = 0
    var timer:Timer = Timer()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        viewMCountryCode.layer.borderColor = UIColor.lightGray.cgColor
        viewMCountryCode.layer.borderWidth = 0.5
        viewMCountryCode.layer.cornerRadius = 5.0
        viewMCountryCode.clipsToBounds = true
        
        Themes.sharedInstance.setCountryCode(self.lblCountrycode, nil)
        country_Code = self.lblCountrycode.text!
        btnUpdatePassword.backgroundColor = Themes.sharedInstance.colorWithHexString(hex: "007BFF")
        txtMobile.addTarget(self, action: #selector(textFiedDidChange(_:)), for: .editingChanged)
        
    }
    
   
    
    @objc func updateTimerLabel(){
        if(seconds == 0)
        {
            timer.invalidate()
            btnSendOtp.isUserInteractionEnabled = true
            self.btnSendOtp.setTitleColor(UIColor.systemBlue, for:.normal)
            lblTimer.text = "0"
            lblTimer.isHidden = true

        }
        else
        {
            lblTimer.text = "\(seconds)"
        }
        seconds -= 1
    }
    
    
    
    
    @objc func textFiedDidChange(_ sender: Any) {
        var prefix = self.country_Code
        if  txtMobile.text!.hasPrefix(prefix) == true {
            if txtMobile.text!.length > prefix.length {
                txtMobile.text  = String(txtMobile.text!.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }else {
            prefix =  prefix.hasPrefix("+") ? String(prefix.dropFirst(1)): prefix
            if  txtMobile.text!.hasPrefix(prefix) == true {
                if txtMobile.text!.length > prefix.length {
                    txtMobile.text  = String(txtMobile.text!.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
        }
    }
    
    
    //MARK: UIBUtton Action Methods
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        self.view.endEditing(true)
        txtEmail.text = ""
        txtMobile.text = ""
        
        if sender.selectedSegmentIndex == 0 {
            self.viewEmail.isHidden = true
            self.viewMobile.isHidden = false
            isEmail = false
            
        } else if sender.selectedSegmentIndex == 1 {
            self.viewEmail.isHidden = false
            self.viewMobile.isHidden = true
            isEmail = true
        }
        
        txtOTP.text = ""
        viewOtp.isHidden = true
        viewPassword.isHidden = true
        viewConfirmPassword.isHidden = true
    }
    
    @IBAction func backButtonAction()
    {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func showHidePasswordAction(){
        
        if btnShowHidePassword.currentImage == UIImage(named: "eye-5 1") {
            btnShowHidePassword.setImage(UIImage(named: "eye-4 1"), for: .normal)
            txtPassword.isSecureTextEntry = false
        }else {
            btnShowHidePassword.setImage(UIImage(named: "eye-5 1"), for: .normal)
            txtPassword.isSecureTextEntry = true
        }
    }
    @IBAction func showHideConfirmPasswordAction(){
        
        if btnShowHideConfirmPassword.currentImage == UIImage(named: "eye-5 1") {
            btnShowHideConfirmPassword.setImage(UIImage(named: "eye-4 1"), for: .normal)
            txtConfirmPassword.isSecureTextEntry = false
        }else {
            btnShowHideConfirmPassword.setImage(UIImage(named: "eye-5 1"), for: .normal)
            txtConfirmPassword.isSecureTextEntry = true
        }
    }
    
        // Do any additional setup after loading the view.
    @IBAction func showHideEmailBtnAction(_ sender:UIButton) {
        self.view.endEditing(true)

        if viewEmail.isHidden == false {
            isEmail = false
            viewEmail.isHidden = true
            viewMobile.isHidden = false
            txtEmail.text = ""
            btnShowHideEmail.setTitle("Use email instead of mobile number", for: .normal)
        }else {
            isEmail = true
            viewEmail.isHidden = false
            viewMobile.isHidden = true
            btnShowHideEmail.setTitle("Use mobile number instead of email", for: .normal)
            
        }
        txtOTP.text = ""
        viewOtp.isHidden = true
        viewPassword.isHidden = true
        viewConfirmPassword.isHidden = true
    }
    
    @IBAction func sendOTPAction(_ sender:UIButton) {
        self.view.endEditing(true)

    
            while (txtMobile.text?.hasPrefix("0"))! {
                txtMobile.text = txtMobile.text?.substring(from: 1)
            }
    
            if (txtMobile.text?.hasPrefix("+"))! {
                txtMobile.text = txtMobile.text?.substring(from: country_Code.length)
            }
        
        if (txtEmail.text?.length ?? 0) > 0 {
            txtEmail.text = txtEmail.text?.trimmingCharacters(in: .whitespaces)
        }
    
            print(txtMobile.text)
        print(txtEmail.text)
        
        if isEmail == false && txtMobile.text?.length == 0 {
            self.view.makeToast(message: "Mobile number cannot be left blank" , duration: 3, position: HRToastActivityPositionDefault)
        }else if isEmail == true && txtEmail.text?.length == 0 {
            self.view.makeToast(message: "Email cannot be left blank" , duration: 3, position: HRToastActivityPositionDefault)
        }else if isEmail == true && txtEmail.text?.isValidEmail == false {
            self.view.makeToast(message: "Please enter valid email id" , duration: 3, position: HRToastActivityPositionDefault)
        }else {
            
            var type = 1
            var username = ""
            if isEmail == true {
                type = 1
                username = txtEmail.text ?? ""
            }else {
                type = 0
                username = country_Code + (txtMobile.text ?? "")
            }
            var param:NSDictionary = [:]
            param = ["username":"\(username)",  "type":type, "otpHashcode":"", "deviceId":"\(Themes.sharedInstance.getDeviceUUIDString())", "OS":"ios", "modelName":"\(UIDevice.current.model)"]
            
            Themes.sharedInstance.activityView(View: self.view)
            
            
            
            URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.sendForgetOtpURL, param: param) { (responseObject, error) -> () in
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
                        
                        let securityAuthToken = payload["securityAuthToken"] as? String ?? ""
                        if securityAuthToken.length > 0 {
                            Themes.sharedInstance.saveSecurityAuthToken(securityAuthToken: securityAuthToken)
                        }
                        
                        self.viewOtp.isHidden = false
                        self.viewPassword.isHidden = true
                        self.viewConfirmPassword.isHidden = true
                        self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)
                        
                        if type == 0 {
                            
                           
                            
                            self.btnSendOtp.setTitle("Resend OTP", for: .normal)
                            self.btnSendOtp.setTitleColor(UIColor.lightGray, for:.normal)
                            self.btnSendOtp.isUserInteractionEnabled = false
                            self.seconds = 60
                            self.lblTimer.isHidden = false
                            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:  #selector(self.updateTimerLabel), userInfo: nil, repeats: true)
                        }
                    }else{
                        self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)
                        
                    }
                    
                }
            }
        }
        }
    
    @IBAction func verifyOTPAction(_ sender:UIButton) {
        self.view.endEditing(true)

    var type = 1
    var username = ""
    if isEmail == true {
        type = 1
        username = txtEmail.text ?? ""
    }else {
        type = 0
        username = country_Code + (txtMobile.text ?? "")
    }
    var param:NSDictionary = [:]
        param = ["username":"\(username)", "otp":"\(txtOTP.text ?? "")", "type":type, "uid":"\(uid)", "deviceId":"\(Themes.sharedInstance.getDeviceUUIDString())", "OS":"ios", "modelName":"\(UIDevice.current.model)"]

        Themes.sharedInstance.activityView(View: self.view)



        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.verifyForgetOtpURL, param: param) { (responseObject, error) -> () in
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
                             
                             let securityAuthToken = payload["securityAuthToken"] as? String ?? ""
                             if securityAuthToken.length > 0 {
                                 Themes.sharedInstance.saveSecurityAuthToken(securityAuthToken: securityAuthToken)
                             }
                             
                             self.lblTimer.isHidden = true
                             self.viewEmail.isHidden = true
                             self.viewMobile.isHidden = true
                             self.viewOtp.isHidden = true
                             
                             self.btnShowHideEmail.isHidden = true
                             self.segmentControl.isHidden = true
                             
                             self.viewPassword.isHidden = false
                             self.viewConfirmPassword.isHidden = false
                             self.btnUpdatePassword.isHidden = false

                             
                             self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)

                         }else{
                             self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)

                         }

                     }
        }
    }
    
    
        @IBAction func updatePasswordAction(_ sender:UIButton) {
            self.view.endEditing(true)

            if (txtPassword.text?.length ?? 0) > 0 {
                txtPassword.text = txtPassword.text?.trimmingCharacters(in: .whitespaces)
            }
            if (txtConfirmPassword.text?.length ?? 0) > 0 {
                txtConfirmPassword.text = txtConfirmPassword.text?.trimmingCharacters(in: .whitespaces)
            }
            
            if (txtPassword.text ?? "").length == 0 {
                self.view.makeToast(message: "Please enter password" , duration: 3, position: HRToastActivityPositionDefault)
            }else if (txtPassword.text ?? "") != (txtConfirmPassword.text ?? "") {
                self.view.makeToast(message: "Password  and confirm password does not match" , duration: 3, position: HRToastActivityPositionDefault)
            }else if (txtPassword.text ?? "").isValidPassword == false {
                self.view.makeToast(message: "Password must be of minimum 5 characters at least 1 Alphabet and 1 Number" , duration: 3, position: HRToastActivityPositionDefault)
            }else {
                
                var param:NSDictionary = [:]
                param = ["password":"\(txtPassword.text ?? "")"]
                
                Themes.sharedInstance.activityView(View: self.view)
                
                
                
                URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.createNewPasswordURL, param: param) { (responseObject, error) -> () in
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
                            let cameraAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
                            {_ in
                                self.navigationController?.popViewController(animated: true)
                            }
                            alert.addAction(cameraAction)
                            self.presentView(alert, animated: true, completion: nil)
                            
                        }else{
                            self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                            
                        }
                        
                    }
                }
            }
        }
        
        @IBAction func countrycodeBtnAction(_ sender:UIButton) {
            let  country = MICountryPicker()
            country.delegate = self
            country.showCallingCodes = true
            if let navigator = self.navigationController
            {
                navigator.pushViewController(country, animated: true)
            }
        }
        
    }

    extension ForgotPasswordVC: MICountryPickerDelegate,UITextFieldDelegate {
        
        func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String) {
            //picker.navigationController?.popViewController(animated: true)
            //picker.navigationController?.isNavigationBarHidden = true
        }
        
        func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String,countryFlagImage:UIImage){
            lblCountrycode.text = "\(dialCode)"
            country_Code = dialCode
            Themes.sharedInstance.saveMobileCode(dialCode)
            
            picker.navigationController?.popViewController(animated: true)
            picker.navigationController?.isNavigationBarHidden = true
        }
        
    }


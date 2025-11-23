//
//  CodeVerificationVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 19/08/25.
//  Copyright © 2025 Pickzon Inc. All rights reserved.
//

import UIKit

class CodeVerificationVC: UIViewController {

    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var btnVerifyOtp:UIButton!
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var btnResendOtp: UIButton!
    @IBOutlet weak var lblMessage:UILabel!
    @IBOutlet var otpFeilds: [UITextField]!
    @IBOutlet weak var bgViewSuccessPopup:UIView!

    var isEmail = true
    var emailOrMobile = ""
    var uid = ""
    var isFromSignup = false
    var mobile = ""
    var countryCode = ""
    var randomNumber:Int64 = 0
    var emailId = ""
    private var countdownTimer = Timer()
    private  var counter = 60

    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        btnVerifyOtp.setBackgroundColor(CustomColor.sharedInstance.newThemeColor, forState: .normal)
        btnVerifyOtp.layer.cornerRadius = 20.0
        btnVerifyOtp.clipsToBounds = true
        
        bgViewSuccessPopup.isHidden = true
        bgViewSuccessPopup.backgroundColor = UIColor.label.withAlphaComponent(0.5)
        
//        otpFeilds[0].delegate = self
//        otpFeilds[1].delegate = self
//        otpFeilds[2].delegate = self
//        otpFeilds[3].delegate = self
//        otpFeilds[0].becomeFirstResponder()
        
      
        
        otpFeilds.forEach {
            $0.textContentType = .oneTimeCode
            $0.keyboardType = .numberPad
            $0.delegate = self
            $0.borderStyle = .none   // very important
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.lightGray.cgColor
            $0.layer.cornerRadius = 18
            $0.clipsToBounds = true
        }
      //  otpFeilds[0].becomeFirstResponder()

        let str = isEmail ? "email" : "mobile"
        lblMessage.text = "We have sent an OTP code to your \(str) \(emailOrMobile). Enter the code below."

        btnResendOtp.isUserInteractionEnabled = false
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countdownTimer.invalidate()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cnstrntHtNavBar.constant = self.getNavBarHt
    }
    //MARK: UIButton Methods

    @IBAction func backBtnAction(_ sender : UIButton){
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func verifyOTPBtnAction(_ sender : UIButton){
        self.view.endEditing(true)
        let otp = otpFeilds[0].text!+otpFeilds[1].text!+otpFeilds[2].text!+otpFeilds[3].text!
        
        if otp.count < 4{
            Themes.sharedInstance.ShowNotification("Please enter correct OTP number", false)
        }else {
            if isFromSignup{
                //is from signup
                self.callVerifyMobileEmailOTPAPI()
            }else{
                //Forgot password
                callforgotPasswordMobileEmailVerifyApi()
            }
        }
    }
    
    
    @IBAction func resendOTPBtnAction(_ sender : UIButton){
        self.view.endEditing(true)
        
        if isFromSignup{
            //is from signup
            self.hashingCreatorApi()
        }else{
            //Forgot password
            sendOtpForgotPassword()
        }
    }
    
    
//    @IBAction func textChangedAction(_ sender: UITextFieldX) {
//        
//        if let otpCode = sender.text{
//            otpFeilds[0].text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 0)])
//            otpFeilds[1].text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 1)])
//            otpFeilds[2].text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 2)])
//            otpFeilds[3].text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 3)])
//        }
//    }
//    
    
    @IBAction func textChangedAction(_ sender: UITextFieldX) {
        guard let otpCode = sender.text else { return }

        // Ensure input has at least 4 characters
        if otpCode.count >= 4 {
            for (index, field) in otpFeilds.enumerated() where index < 4 {
                let char = otpCode[otpCode.index(otpCode.startIndex, offsetBy: index)]
                field.text = String(char)
            }
        } else {
            // Clear fields when input is less than expected
            for (index, field) in otpFeilds.enumerated() {
                if index < otpCode.count {
                    let char = otpCode[otpCode.index(otpCode.startIndex, offsetBy: index)]
                    field.text = String(char)
                } else {
                    field.text = ""
                }
            }
        }
    }

    
    @objc func updateTime() {
        
        if counter > 0{
            btnResendOtp.setTitle("you can resend code in \(counter) sec", for: .normal)
            counter -= 1
        }else{
            countdownTimer.invalidate()
            btnResendOtp.isUserInteractionEnabled = true
            counter = 60
            btnResendOtp.setTitle("Resend OTP", for: .normal)
        }
    }
    
  
    //MARK: Api Methods
    
    func sendOtpForgotPassword(){
        
        let type =  ( isEmail == true) ?  1 : 0
        let username = emailOrMobile
        
        let param:NSDictionary  = ["username":"\(username)",  "type":type, "otpHashcode":"", "deviceId":"\(Themes.sharedInstance.getDeviceUUIDString())", "OS":"ios", "modelName":"\(UIDevice.current.model)"]
        
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
                 
                    self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)
                    
                    self.btnResendOtp.isUserInteractionEnabled = false
                    self.counter = 60
                    self.countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
                    
                    
                }else{
                    self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)
                    
                }
                
            }
        }
    }
    
    
    func callforgotPasswordMobileEmailVerifyApi(){
        //is from forgot password
       
        let type =  ( isEmail == true) ?  1 : 0
        let username = emailOrMobile
        let otp =  otpFeilds[0].text!+otpFeilds[1].text!+otpFeilds[2].text!+otpFeilds[3].text!
        let param:NSDictionary  = ["username":"\(username)", "otp":otp, "type":type, "uid":"\(uid)", "deviceId":"\(Themes.sharedInstance.getDeviceUUIDString())", "OS":"ios", "modelName":"\(UIDevice.current.model)"]
        
        Themes.sharedInstance.activityView(View: self.view)
                
        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.verifyForgetOtpURL, param: param) { (responseObject, error) -> () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            //self.NextButton.isUserInteractionEnabled = true
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                
                print(error ?? "defaultValue")
                
            } else{
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
                    
                    
                    let changePasswordVC = StoryBoard.prelogin.instantiateViewController(withIdentifier:"CreateNewPasswordVC" ) as! CreateNewPasswordVC
                    self.navigationController?.pushViewController(changePasswordVC, animated: true)
                    
                    /*
                     self.lblTimer.isHidden = true
                     self.viewEmail.isHidden = true
                     self.viewMobile.isHidden = true
                     self.viewOtp.isHidden = true
                     self.btnShowHideEmail.isHidden = true
                     self.segmentControl.isHidden = true
                     self.viewPassword.isHidden = false
                     self.viewConfirmPassword.isHidden = false
                     self.btnUpdatePassword.isHidden = false
                     */
                    
                    self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)
                    
                }else{
                    self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)
                    
                }
                
            }
        }
    }
    
    func  callVerifyMobileEmailOTPAPI(){
        
        let otp =   otpFeilds[0].text!+otpFeilds[1].text!+otpFeilds[2].text!+otpFeilds[3].text!

        let param:NSDictionary = ["otp":otp, "email":self.emailId, "countryCode":self.countryCode,"mobileNumber":self.mobile, "randomNumber":self.randomNumber]
        
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.verifyEmailMobileOtp, param: param) { (responseObject, error) -> () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                
                print(error ?? "defaultValue")
                
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int64
                let message = result["message"]
                
                    if status == 1{
                     
                        let  payload = result["payload"] as? NSDictionary ?? NSDictionary()
                        
                        let securityAuthToken = payload["securityAuthToken"] as? String ?? ""
                        if securityAuthToken.length > 0 {
                            Themes.sharedInstance.saveSecurityAuthToken(securityAuthToken: securityAuthToken)
                        }
                        self.randomNumber = payload["randomNumber"] as? Int64 ?? 0
                        
                        
                        self.bgViewSuccessPopup.isHidden = false

                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                            self.bgViewSuccessPopup.isHidden = true
                            let profileVC = StoryBoard.prelogin.instantiateViewController(withIdentifier:"ProfileInfoID" ) as! ProfileInfoViewController
                            profileVC.randomNumber = self.randomNumber
                            profileVC.countryCode = self.countryCode
                            profileVC.mobileNumber = self.mobile
                            profileVC.isEmailMobileVerified = true
                            profileVC.user_info.setValue(self.emailId, forKey: "email")
                            self.pushView(profileVC, animated: true)
                        })
                        
                       
                        
                    }else{
                        self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        }
    
    func hashingCreatorApi(){
        
        let dictParams:NSDictionary = ["deviceId" : "\(Themes.sharedInstance.getDeviceUUIDString())","OS" : "ios","modelName" : "\(UIDevice.current.model)","manufacturerId" : [17, 3, 52,64, 92, 87, 22], "version":"\(Themes.sharedInstance.osVersion)"]
        
        let url = "\(Constant.sharedinstance.hashingCreator)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        URLhandler.sharedinstance.makePostAPICall(url: url, param: dictParams, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int64 ?? 0
                let message = result["message"]
                if status == 1{
                    if let payload = result["payload"] as? Dictionary<String,Any> {
                        let securityAuthToken = payload["securityAuthToken"] as? String ?? ""
                        if securityAuthToken.length > 0 {
                            Themes.sharedInstance.saveSecurityAuthToken(securityAuthToken: securityAuthToken)
                        }
                        self.randomNumber = payload["randomNumber"] as? Int64 ?? 0
                    }
                    self.callsendEmailMobileOtpAPI()
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    func callsendEmailMobileOtpAPI (){
       
        let param:NSDictionary = ["email":"\(self.emailId)",  "countryCode":countryCode,"mobileNumber":"\(mobile)", "randomNumber": self.randomNumber, "otpHashcode":""]
        
        Themes.sharedInstance.activityView(View: self.view)
                
        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.sendEmailMobileOtpURL, param: param) { (responseObject, error) -> () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            //self.NextButton.isUserInteractionEnabled = true
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                
                print(error ?? "defaultValue")
                
            }else{
                print(responseObject ?? "response")
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
                
                if status == 1{
                    let payload = result["payload"] as? NSDictionary ?? [:]
                    
                   /* let otpStatus = payload["otpStatus"] as? Int ?? 0
                    if otpStatus == 0 {
                        self.isFirebaseUsed = false
                    }else {
                        self.isFirebaseUsed = true
                    }*/
                    
                    let securityAuthToken = payload["securityAuthToken"] as? String ?? ""
                    if securityAuthToken.length > 0 {
                        Themes.sharedInstance.saveSecurityAuthToken(securityAuthToken: securityAuthToken)
                    }
                    self.randomNumber = payload["randomNumber"] as? Int64 ?? 0
                    self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)
                    self.btnResendOtp.isUserInteractionEnabled = false
                    self.counter = 60
                    self.countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
                }else{
                    self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)
                    
                }
            }
        }
    }
}


extension CodeVerificationVC:UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            updateBorder(for: textField, isEditing: true)
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            updateBorder(for: textField, isEditing: false)
        }
        
        private func updateBorder(for textField: UITextField, isEditing: Bool) {
            textField.layer.borderColor = isEditing ?
            CustomColor.sharedInstance.newThemeColor.cgColor : UIColor.lightGray.cgColor
            textField.layer.borderWidth = 1.0
            textField.clipsToBounds = true
            textField.layer.masksToBounds = true
        }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (string.count == 1){
            if textField == otpFeilds[0] {
                otpFeilds[1].becomeFirstResponder()
            } else if textField == otpFeilds[1] {
                otpFeilds[2].becomeFirstResponder()
            }else if textField == otpFeilds[2] {
                otpFeilds[3].becomeFirstResponder()
            }else  if textField == otpFeilds[3] {
                //  if isFirebaseUsed == true {
                //    otpFeilds[4].becomeFirstResponder()
                //   }else {
                otpFeilds[3].resignFirstResponder()
                // }
            }
//            else if textField == otpFeilds[4] {
//                otpFeilds[5].becomeFirstResponder()
//            }else if textField == otpFeilds[5] {
//                otpFeilds[5].resignFirstResponder()
//            }
            textField.text? = string
            return false
        }else{
            if textField == otpFeilds[0] {
                otpFeilds[0].becomeFirstResponder()
            }else if textField == otpFeilds[1] {
                otpFeilds[0].becomeFirstResponder()
            }else if textField == otpFeilds[2] {
                otpFeilds[1].becomeFirstResponder()
            }else  if textField == otpFeilds[3] {
                otpFeilds[2].becomeFirstResponder()
            }
//            else  if textField == otpFeilds[4] {
//                otpFeilds[3].becomeFirstResponder()
//            }else  if textField == otpFeilds[5] {
//                otpFeilds[4].becomeFirstResponder()
//            }
            textField.text? = string
            return false
        }
    }
    
}

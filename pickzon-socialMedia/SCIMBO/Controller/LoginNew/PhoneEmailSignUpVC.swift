//
//  PhoneEmailSignUpVC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 4/25/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class PhoneEmailSignUpVC: UIViewController {

    @IBOutlet weak var lblCountrycode: UILabel!
    @IBOutlet weak var viewEmail:UIView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var viewMobile:UIView!
    @IBOutlet weak var viewMCountryCode:UIView!
    @IBOutlet weak var txtMobile: UITextField!
    @IBOutlet weak var segmentControl:UISegmentedControl!
    @IBOutlet weak var btnSendOtp: UIButton!
    @IBOutlet weak var bgViewSegmentControl:UIView!
    @IBOutlet weak var imgVwDDIcon:UIImageView!

    var country_Code = String()
    var isEmail = false
    var randomNumber: Int64 = 0
    var isFirebaseUsed = false
   
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
       // viewEmail.layer.borderColor = UIColor.label.cgColor
       // viewEmail.layer.borderWidth = 0.5
        viewEmail.backgroundColor = CustomColor.sharedInstance.txtFdBgColor
        viewEmail.layer.cornerRadius = 20.0
        viewEmail.clipsToBounds = true
        
//        viewMobile.layer.borderColor = UIColor.label.cgColor
//        viewMobile.layer.borderWidth = 0.5
        viewMobile.backgroundColor = CustomColor.sharedInstance.txtFdBgColor
        viewMobile.layer.cornerRadius = 20.0
        viewMobile.clipsToBounds = true
        imgVwDDIcon.setImageColor(color: .black)

        Themes.sharedInstance.setCountryCode(self.lblCountrycode, nil)
        country_Code = self.lblCountrycode.text!

        btnSendOtp.backgroundColor = CustomColor.sharedInstance.newThemeColor
        btnSendOtp.layer.cornerRadius = 20.0
        btnSendOtp.clipsToBounds = true

        txtMobile.addTarget(self, action: #selector(textFiedDidChange(_:)), for: .editingChanged)
        
        
        segmentControl.backgroundColor = CustomColor.sharedInstance.txtFdBgColor
        segmentControl.selectedSegmentTintColor = CustomColor.sharedInstance.newThemeColor
        bgViewSegmentControl.layer.borderColor = CustomColor.sharedInstance.txtFdBgColor.cgColor
        bgViewSegmentControl.layer.cornerRadius = bgViewSegmentControl.bounds.height / 2.0
        bgViewSegmentControl.clipsToBounds = true
        segmentControl.applyCapsuleStyle()
    
        txtEmail.setAttributedPlaceHolder(text: "Enter Email", color: .lightGray)
        txtMobile.setAttributedPlaceHolder(text: "Your Mobile Number", color: .lightGray)
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
    }
    
    
    @IBAction func backButtonAction()
    {
        self.navigationController?.popViewController(animated: true)
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
                        self.callsendEmailMobileOtpAPI()
                    }
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
        // Do any additional setup after loading the view.
    @IBAction func sendOTPAction() {
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
                
        if isEmail == false && txtMobile.text?.length == 0 {
            self.view.makeToast(message: "Mobile number cannot be left blank" , duration: 3, position: HRToastActivityPositionDefault)
        }else if isEmail == true && txtEmail.text?.length == 0 {
            self.view.makeToast(message: "Email cannot be left blank" , duration: 3, position: HRToastActivityPositionDefault)
        }else if isEmail == true && txtEmail.text?.isValidEmail == false {
            self.view.makeToast(message: "Please enter valid email id" , duration: 3, position: HRToastActivityPositionDefault)
        }else {
            self.hashingCreatorApi()
        }
        
    }
    
    func callsendEmailMobileOtpAPI (){
        
        let param:NSDictionary = ["email":"\(txtEmail.text ?? "")",  "countryCode":country_Code,"mobileNumber":"\(txtMobile.text ?? "")", "randomNumber": self.randomNumber, "otpHashcode":""]
        
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
                    
                    let otpStatus = payload["otpStatus"] as? Int ?? 0
                    if otpStatus == 0 {
                        self.isFirebaseUsed = false
                    }else {
                        self.isFirebaseUsed = true
                    }
                    
                    let securityAuthToken = payload["securityAuthToken"] as? String ?? ""
                    if securityAuthToken.length > 0 {
                        Themes.sharedInstance.saveSecurityAuthToken(securityAuthToken: securityAuthToken)
                    }
                    
                    self.randomNumber = payload["randomNumber"] as? Int64 ?? 0
                    
                    self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)
                    self.navigateToVerifyOTPVC()
                }else{
                    self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)
                }
                
            }
        }
    
    }
    
    func navigateToVerifyOTPVC() {
        if isEmail == false  {
            Themes.sharedInstance.saveMobileCode(self.country_Code)
        }
        
     /*   let otpVC = StoryBoard.prelogin.instantiateViewController(withIdentifier: "OTPViewController") as!  OTPViewController
        //otpVC.mssidn_No = "\(self.country_Code)\(self.MobileTextField.text!)"
        //otpVC.User_id =  self.signUp.user_Id
        
        /*otpVC.otpNo = self.signUp.code
        otpVC.profilePic =  self.signUp.profilePic
        otpVC.isFromProduction = true
        otpVC.Name=Themes.sharedInstance.CheckNullvalue(Passed_value: result["Name"])
        otpVC.status=Themes.sharedInstance.CheckNullvalue(Passed_value: result["Status"])*/
        
        otpVC.emailId = self.txtEmail.text!
        otpVC.PhNumber = self.txtMobile.text!
        otpVC.CountryCode = self.country_Code
        otpVC.isSignup = true
        otpVC.randomNumber = self.randomNumber
        otpVC.isFirebaseUsed = self.isFirebaseUsed
        self.pushView(otpVC, animated: true)
        
        */
        
        let otpVC = StoryBoard.prelogin.instantiateViewController(withIdentifier:"CodeVerificationVC" ) as! CodeVerificationVC
        otpVC.emailOrMobile =  ( isEmail == true ) ? self.txtEmail.text! : "\(self.country_Code)\(self.txtMobile.text!)"
        otpVC.emailId = self.txtEmail.text!
        otpVC.mobile = self.txtMobile.text!
        otpVC.countryCode = self.country_Code
        otpVC.isEmail = self.isEmail
        otpVC.isFromSignup = true
        otpVC.randomNumber = self.randomNumber
        self.pushView(otpVC, animated: true)

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

extension PhoneEmailSignUpVC: MICountryPickerDelegate,UITextFieldDelegate {
    
    func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String) {
        
    }
    
    func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String,countryFlagImage:UIImage){
        lblCountrycode.text = "\(dialCode)"
        country_Code = dialCode
        Themes.sharedInstance.saveMobileCode(dialCode)
        picker.navigationController?.popViewController(animated: true)
        picker.navigationController?.isNavigationBarHidden = true
    }
    
}

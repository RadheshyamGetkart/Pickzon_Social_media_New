//
//  VerifyEmailAndPhone.swift
//  SCIMBO
//
//  Created by gurmukh singh on 9/15/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//




import UIKit

protocol VerifyEmailPhoneDelegate {
    func verifyEmailPhoneSuccess(isEmail:Bool, strEmailPhone:String)
}

class VerifyEmailAndPhone: UIViewController {

    @IBOutlet weak var lblCountrycode: UILabel!
    
    @IBOutlet weak var lblUpdate: UILabel!
    
    @IBOutlet weak var viewEmail:UIViewX!
    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var viewOldMobile:UIView!
    @IBOutlet weak var txtOldMobile: UITextField!
    
    @IBOutlet weak var viewMobile:UIView!
    @IBOutlet weak var txtMobile: UITextField!
    
    @IBOutlet weak var viewOtp:UIView!
    @IBOutlet weak var txtOTP: UITextField!
    
    
    
    
    
    var country_Code = String()
    var isPrefixCountryCodeRemoved = false
    var isEmail = true
    var uid = ""
    var delegateVerifyEmailPhone:VerifyEmailPhoneDelegate!
    
    @IBOutlet weak var btnSendOtp: UIButton!
    @IBOutlet weak var lblTimer:UILabel!
    var seconds:Int = 0
    var timer:Timer = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Themes.sharedInstance.setCountryCode(self.lblCountrycode, nil)
        country_Code = self.lblCountrycode.text!
        
        if isEmail == true {
            viewEmail.isHidden = false
            viewOldMobile.isHidden = true
            viewMobile.isHidden = true
            lblUpdate.text = "Verify Email"
        }else {
            if Themes.sharedInstance.GetMyPhonenumber() != "" {
                viewOldMobile.isHidden = false
                txtOldMobile.text = Themes.sharedInstance.GetMyPhonenumber()
                lblUpdate.text = "Change Mobile Number"
            }else {
                viewOldMobile.isHidden = true
                lblUpdate.text = "Verify Mobile Number"
            }
            viewEmail.isHidden = true
            viewMobile.isHidden = false
        }
        viewOtp.isHidden = true
        
        txtMobile.addTarget(self, action: #selector(textFiedDidChange(_:)), for: .editingChanged)
        
    }
    
    @objc func textFiedDidChange(_ sender: Any) {
        if isPrefixCountryCodeRemoved == false {
            var prefix = self.country_Code
            print("prefix : ",prefix)
            if  txtMobile.text!.hasPrefix(prefix) == true {
                if txtMobile.text!.length > prefix.length {
                    txtMobile.text  = String(txtMobile.text!.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }else {
                
                prefix =  prefix.hasPrefix("+") ? String(prefix.dropFirst(1)): prefix
                print("prefix : ",prefix)
                if  txtMobile.text!.hasPrefix(prefix) == true {
                    if txtMobile.text!.length > prefix.length {
                        txtMobile.text  = String(txtMobile.text!.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
            }
            
            isPrefixCountryCodeRemoved = true
        }
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
    
    
    
    @IBAction func backButtonAction()
    {
        self.navigationController?.popViewController(animated: true)
    }

    
    
    @IBAction func sendOTPAction(_ sender:UIButton) {
        view.endEditing(true)
    
            while (txtMobile.text?.hasPrefix("0"))! {
                txtMobile.text = txtMobile.text?.substring(from: 1)
            }
    
            if (txtMobile.text?.hasPrefix("+"))! {
                txtMobile.text = txtMobile.text?.substring(from: country_Code.length)
            }
        
        if (txtEmail.text?.length ?? 0) > 0 {
            txtEmail.text = txtEmail.text?.trimmingCharacters(in: .whitespaces)
        }
    
        if (txtMobile.text?.length ?? 0) > 0 {
            txtMobile.text = txtMobile.text?.trimmingCharacters(in: .whitespaces)
        }
        

        
        
        if isEmail == true && txtEmail.text?.length == 0 {
            self.view.makeToast(message: "Email cannot be left blank" , duration: 3, position: HRToastActivityPositionDefault)
        }else if isEmail == true && txtEmail.text?.isValidEmail == false {
            self.view.makeToast(message: "Please enter valid email id" , duration: 3, position: HRToastActivityPositionDefault)
        }else if isEmail == false && txtMobile.text?.length == 0 {
            self.view.makeToast(message: "Mobile cannot be left blank" , duration: 3, position: HRToastActivityPositionDefault)
        }else if isEmail == false && txtMobile.text?.isPhoneNumber == false {
            self.view.makeToast(message: "Please enter valid mobile number" , duration: 3, position: HRToastActivityPositionDefault)
        }else  if Themes.sharedInstance.GetMyPhonenumber() != "" &&  Themes.sharedInstance.GetMyPhonenumber() ==  "\(country_Code)\((txtMobile.text ?? ""))"{
            self.view.makeToast(message: "old mobile number and new mobile number cannot be same" , duration: 3, position: HRToastActivityPositionDefault)
        }else {
            
            var type = 1
            
            if isEmail == true {
                type = 1
            }else {
                type = 0
            }
            var param:NSDictionary = [:]
            param = ["mobileNumber":"\((txtMobile.text ?? ""))", "countryCode":"\(country_Code)", "email":"\((txtEmail.text ?? ""))", "otpHashcode":"",  "type":type,  "deviceId":"\(Themes.sharedInstance.getDeviceUUIDString())", "OS":"ios", "modelName":"\(UIDevice.current.model)"]
            
            Themes.sharedInstance.activityView(View: self.view)
            
            
            
            URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.authSendOTPUrl, param: param) { (responseObject, error) -> () in
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
                        self.uid = payload["uid"] as? String ?? ""
                        
                        
                        self.viewOtp.isHidden = false
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
        view.endEditing(true)

    var type = 1
        
    if isEmail == true {
        type = 1
    }else {
        type = 0
    }
    var param:NSDictionary = [:]
        param = ["mobileNumber":"\(txtMobile.text ?? "")", "countryCode":"\(country_Code)", "otp":"\(txtOTP.text ?? "")", "email":"\(txtEmail.text ?? "")",  "type":type, "uid":"\(uid)", "deviceId":"\(Themes.sharedInstance.getDeviceUUIDString())", "OS":"ios", "modelName":"\(UIDevice.current.model)"]

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
                             
                             self.lblTimer.isHidden = true
                             
                             if self.isEmail == true {
                                 self.delegateVerifyEmailPhone?.verifyEmailPhoneSuccess(isEmail: self.isEmail, strEmailPhone:self.txtEmail.text ?? "")
                             }else {
                                 self.delegateVerifyEmailPhone?.verifyEmailPhoneSuccess(isEmail: self.isEmail, strEmailPhone: self.country_Code + "\(self.txtMobile.text ?? "")")
                             }
                             let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
                             
                             let okAction = UIAlertAction(title: "OK", style: .default, handler: { alert -> Void in
                                 
                                 self.navigationController?.popViewController(animated: true)
                             })
                             alertController.addAction(okAction)
                             self.present(alertController, animated: true, completion: nil)
                            

                         }else{
                             self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)

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

    extension VerifyEmailAndPhone: MICountryPickerDelegate,UITextFieldDelegate {
        
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



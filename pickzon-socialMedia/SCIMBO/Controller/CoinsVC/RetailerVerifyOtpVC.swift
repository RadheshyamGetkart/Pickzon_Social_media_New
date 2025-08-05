//
//  RetailerVerifyOtpVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 12/28/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class RetailerVerifyOtpVC: UIViewController {

    @IBOutlet weak var cnstrntHtNavbar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnConfirm:UIButton!
    @IBOutlet weak var txtFdPass1:UITextField!
    @IBOutlet weak var txtFdPass2:UITextField!
    @IBOutlet weak var txtFdPass3:UITextField!
    @IBOutlet weak var txtFdPass4:UITextField!
    @IBOutlet weak var lblMessage:UILabel!
        
    @IBOutlet weak var bgViewSuccess:UIView!
    @IBOutlet weak var lblSuccessMsg:UILabel!
    var uid = ""
    var coins = ""
    var userId = ""

    var mobileNo = ""
    var emailId = ""

    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        cnstrntHtNavbar.constant = self.getNavBarHt
        bgViewSuccess.isHidden = true
        
        txtFdPass1.layer.cornerRadius = 10.0
        txtFdPass1.layer.borderWidth = 1.0
        txtFdPass1.layer.borderColor = UIColor.darkGray.cgColor
        txtFdPass1.clipsToBounds = true
        
        txtFdPass2.layer.cornerRadius = 10.0
        txtFdPass2.layer.borderWidth = 1.0
        txtFdPass2.layer.borderColor = UIColor.darkGray.cgColor
        txtFdPass2.clipsToBounds = true
        
        txtFdPass3.layer.cornerRadius = 10.0
        txtFdPass3.layer.borderWidth = 1.0
        txtFdPass3.layer.borderColor = UIColor.darkGray.cgColor
        txtFdPass3.clipsToBounds = true
        
        txtFdPass4.layer.cornerRadius = 10.0
        txtFdPass4.layer.borderWidth = 1.0
        txtFdPass4.layer.borderColor = UIColor.darkGray.cgColor
        txtFdPass4.clipsToBounds = true
        
        lblSuccessMsg.text = "Congratulations!\n You have been successfully transferred cheer coins"
        
       
        if emailId.count > 0 && mobileNo.count > 0 {
            lblMessage.text = "We have sent you an OTP to your registered email (\(getMaskedEmailId(email:emailId))) and mobile number (\( maskedMobileNoWithStar(mobile:mobileNo))). Verify the OTP received and click on confirm."
            
        }else if emailId.count > 0 && mobileNo.count == 0{
            
            
            lblMessage.text = "We have sent you an OTP to your registered email (\(getMaskedEmailId(email:emailId))). Verify the OTP received and click on confirm."

        }else if emailId.count == 0 && mobileNo.count > 0{
            lblMessage.text = "We have sent you an OTP to your registered mobile number (\( maskedMobileNoWithStar(mobile:mobileNo))). Verify the OTP received and click on confirm."
        }
    }
    
    //MARK: Other Helpful Methods
    func getMaskedEmailId(email:String)->String{
        if email.count <  11 {
            return email
        }
        let atSign = email.firstIndex(of: "@") ?? email.endIndex
        var lastLetterInx =  email.index(email.index(before:atSign), offsetBy: -1)
        var inx =   email.startIndex
        var result = ""
        while(true) {
            if (inx >= lastLetterInx) {
                result.append(String(email[lastLetterInx...]))
                break;
            }

            if (inx > email.index(after: email.startIndex)) {
                result.append("*")
            } else {
                result.append(email[inx])
            }

            inx = email.index(after:inx)
        }
        return result
    }
    
    
    func maskedMobileNoWithStar(mobile:String)->String{
        if mobile.count < 5{
            return mobile
        }
        let conditionIndex = mobile.count - 4
        let maskedMobNo = String(mobile.enumerated().map { (index, element) -> Character in
            return index < conditionIndex ? "*" : element
        })
        return maskedMobNo
    }
   
    
    //MARK: UIBUtton Action Methods
    @IBAction func backButtonAction(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmButtonAction(_ sender : UIButton){
        
        self.view.endEditing(true)
        let otp = txtFdPass1.text!+txtFdPass2.text!+txtFdPass3.text!+txtFdPass4.text!
        if otp.count < 4{
            Themes.sharedInstance.ShowNotification("Please enter correct OTP number", false)
        }else {
            self.verifyOtpApi()
        }

    }
    
    
    @IBAction func doneSuccessButtonAction(_ sender : UIButton){
        
        
        for controller in self.navigationController?.viewControllers ?? [] {
            
            if controller is WalletVC{
                self.navigationController?.popToViewController(controller, animated: true)
                break
            }
        }

    }

    
    //MARK: Api Methods
    func verifyOtpApi(){
        Themes.sharedInstance.activityView(View: self.view)
        let params = NSMutableDictionary()
        
        let otp = txtFdPass1.text!+txtFdPass2.text!+txtFdPass3.text!+txtFdPass4.text!

        params.setValue(otp, forKey: "otp")
        params.setValue(uid, forKey: "uid")
    
        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.verify_otp_transfer_coin, param: params) { (responseObject, error) ->  () in
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1 {
                    
                    
                    self.transferCoinsApi()
//                    DispatchQueue.main.async {
//                        AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["Ok"], onController: self){ title, index in
//                            self.navigationController?.popViewController(animated: true)
//                        }
//                    }
                    
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        }
    }
    
    func transferCoinsApi(){
        Themes.sharedInstance.activityView(View: self.view)
        let params = NSMutableDictionary()
        
        params.setValue(userId, forKey: "userId")
        params.setValue(coins, forKey: "coins")
        
        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.agency_send_cheer_coins, param: params) { (responseObject, error) ->  () in
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1 {
                    
                    DispatchQueue.main.async {
                        self.bgViewSuccess.isHidden = false
                    }
                    
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        }
    }
    
}


extension RetailerVerifyOtpVC:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

         if (string.count == 1){
                  if textField == txtFdPass1 {
                      txtFdPass2.becomeFirstResponder()
                  } else if textField == txtFdPass2 {
                      txtFdPass3.becomeFirstResponder()
                  }else if textField == txtFdPass3 {
                      txtFdPass4.becomeFirstResponder()
                  }else  if textField == txtFdPass4 {
                      txtFdPass4.resignFirstResponder()
                  }
                  textField.text? = string
                  return false
              }else{
                  if textField == txtFdPass1 {
                      txtFdPass1.becomeFirstResponder()
                  }else if textField == txtFdPass2 {
                      txtFdPass1.becomeFirstResponder()
                  }else if textField == txtFdPass3 {
                      txtFdPass2.becomeFirstResponder()
                  }else  if textField == txtFdPass4 {
                      txtFdPass3.becomeFirstResponder()
                  }
                  textField.text? = string
                  return false
              }
    }
  
}




//
//  CreateNewPasswordVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 19/08/25.
//  Copyright © 2025 Pickzon Inc. All rights reserved.
//

import UIKit

class CreateNewPasswordVC: UIViewController {
    
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var btnContinue:UIButton!
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var txtFdPassword:UITextField!
    @IBOutlet weak var txtFdConfirmPassword:UITextField!
    @IBOutlet weak var btnShowHidePassword:UIButton!
    @IBOutlet weak var btnShowHideConfirmPassword:UIButton!
    @IBOutlet weak var viewPassword:UIView!
    @IBOutlet weak var viewConfirmPassword:UIView!
 
    @IBOutlet weak var bgViewSuccessPopup:UIView!
    private var isPasswordHide = true
    private var isConfirmPasswordHide = true
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        btnContinue.setBackgroundColor(CustomColor.sharedInstance.newThemeColor, forState: .normal)
        btnContinue.layer.cornerRadius = 20.0
        btnContinue.clipsToBounds = true
        bgViewSuccessPopup.isHidden = true
        bgViewSuccessPopup.backgroundColor = UIColor.label.withAlphaComponent(0.5)
       
        viewPassword.backgroundColor = CustomColor.sharedInstance.txtFdBgColor
        viewPassword.layer.cornerRadius = 20.0
        viewPassword.clipsToBounds = true
        viewConfirmPassword.backgroundColor = CustomColor.sharedInstance.txtFdBgColor
        viewConfirmPassword.layer.cornerRadius = 20.0
        viewConfirmPassword.clipsToBounds = true
        
        btnShowHidePassword.setImage(PZImages.hideEye, for: .normal)
        btnShowHideConfirmPassword.setImage(PZImages.hideEye, for: .normal)
        
        btnShowHidePassword.setImageTintColor(.black)
        btnShowHideConfirmPassword.setImageTintColor(.black)
    }
    
    
    //MARK: UIButton Methods

    @IBAction func backBtnAction(_ sender : UIButton){
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func continueBtnAction(_ sender : UIButton){
        changePasswordApi()
        
    }
    
    @IBAction func showHidePasswordAction(){
        
        if isPasswordHide == true {
            btnShowHidePassword.setImage(PZImages.hideEye, for: .normal)
            txtFdPassword.isSecureTextEntry = true
            isPasswordHide = false
            
        }else {
            btnShowHidePassword.setImage(PZImages.showEye, for: .normal)
            txtFdPassword.isSecureTextEntry = false
            isPasswordHide = true

        }
        btnShowHidePassword.setImageTintColor(.black)

    }
    
    @IBAction func showHideConfirmPasswordAction(){
        
        if isConfirmPasswordHide == true {
            btnShowHideConfirmPassword.setImage(PZImages.hideEye, for: .normal)
            txtFdConfirmPassword.isSecureTextEntry = true
            isConfirmPasswordHide = false
        }else {
            btnShowHideConfirmPassword.setImage(PZImages.showEye, for: .normal)
            txtFdConfirmPassword.isSecureTextEntry = false
            isConfirmPasswordHide = true
        }
        
        btnShowHideConfirmPassword.setImageTintColor(.black)
    }
    
    //MARK: Api Methods
    func changePasswordApi(){
      
        if (txtFdPassword.text?.length ?? 0) > 0 {
            txtFdPassword.text = txtFdPassword.text?.trimmingCharacters(in: .whitespaces)
        }
        if (txtFdConfirmPassword.text?.length ?? 0) > 0 {
            txtFdConfirmPassword.text = txtFdConfirmPassword.text?.trimmingCharacters(in: .whitespaces)
        }
        
        if (txtFdPassword.text ?? "").length == 0 {
            self.view.makeToast(message: "Please enter password" , duration: 3, position: HRToastActivityPositionDefault)
        }else if (txtFdPassword.text ?? "") != (txtFdConfirmPassword.text ?? "") {
            self.view.makeToast(message: "Password  and confirm password does not match" , duration: 3, position: HRToastActivityPositionDefault)
        }else if (txtFdPassword.text ?? "").isValidPassword == false {
            self.view.makeToast(message: "Password must be of minimum 5 characters at least 1 Alphabet and 1 Number" , duration: 3, position: HRToastActivityPositionDefault)
        }else {
            
            let param:NSDictionary = ["password":"\(txtFdPassword.text ?? "")"]
            
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
                        
                        self.bgViewSuccessPopup.isHidden = false

                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                            self.bgViewSuccessPopup.isHidden = true
                            self.navigationController?.popToRootViewController(animated: true)
                        })
                    
//                        let alert:UIAlertController=UIAlertController(title: nil, message: message, preferredStyle: .alert)
//                        let cameraAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
//                        {_ in
//                            self.navigationController?.popViewController(animated: true)
//                        }
//                        alert.addAction(cameraAction)
//                        self.presentView(alert, animated: true, completion: nil)
                        
                    }else{
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                        
                    }
                    
                }
            }
        }
    }
}

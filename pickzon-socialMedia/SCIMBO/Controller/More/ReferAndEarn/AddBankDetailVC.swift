//
//  AddBankDetailVC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 4/13/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit
import IQKeyboardManager

class AddBankDetailVC: UIViewController {

    @IBOutlet weak var scrScrollView:UIScrollView!
    
    @IBOutlet weak var viewBank:UIView!
    @IBOutlet weak var viewPaypal:UIView!
    @IBOutlet weak var viewUPI:UIView!
    
    @IBOutlet weak var btnBankSelected:UIButton!
    @IBOutlet weak var btnPayPalSelected:UIButton!
    @IBOutlet weak var btnUPISelected:UIButton!
    
    @IBOutlet weak var btnConfirm:UIButton!
    
    @IBOutlet weak var txtBankName:UITextField!
    @IBOutlet weak var txtAccountNumber:UITextField!
    @IBOutlet weak var txtConfirmAccountNo:UITextField!
    @IBOutlet weak var txtIFSCCode:UITextField!
    @IBOutlet weak var txtSwiftCode:UITextField!
    @IBOutlet weak var txtAccountHolderName:UITextField!
    
    @IBOutlet weak var txtPayPalID:UITextField!
    @IBOutlet weak var txtUPIID:UITextField!
    
    var name = "", accountNumber = "", ifsc = "", swiftCode = ""
    var bankName = ""
    var paymentType = 1 //1 for bank, 2 for Paypal, 3 for Upi
    var paymentValue = ""
    var amount:Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnConfirm.layer.cornerRadius = 5.0
        
        
        self.addViewFormatting(viewToFormat: viewBank)
        self.addViewFormatting(viewToFormat: viewPaypal)
        self.addViewFormatting(viewToFormat: viewUPI)
        if paymentType == 1 {
            txtBankName.text = name
            txtAccountNumber.text = accountNumber
            txtConfirmAccountNo.text = accountNumber
            txtIFSCCode.text = ifsc
            txtSwiftCode.text = swiftCode
            txtAccountHolderName.text = name
            self.bankViewSelected()
        }else if paymentType == 2 {
            self.txtPayPalID.text = paymentValue
            self.payPalViewSelected()
            
        }else if paymentType == 3 {
            self.txtUPIID.text = paymentValue
            self.upiViewSelected()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrScrollView.contentSize = CGSize(width: self.view.frame.width, height: 700)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        super.viewWillDisappear(animated)
    }
    
    

    //MARK: Button Action Methods
       @IBAction func backButtonAction(){
            self.navigationController?.popViewController(animated: true)
        }
    
    func addViewFormatting(viewToFormat:UIView) {
        viewToFormat.layer.cornerRadius = 5.0
        viewToFormat.layer.borderWidth = 1.5
        viewToFormat.layer.shadowColor = UIColor.lightGray.cgColor
        viewToFormat.layer.shadowOffset = CGSize(width: 2, height: 2)
        viewToFormat.layer.shadowOpacity = 0.7
        viewToFormat.layer.shadowRadius = 5.0
    }
    @IBAction func bankViewSelected() {
        viewBank.layer.borderColor = UIColor.systemBlue.cgColor
        viewPaypal.layer.borderColor = UIColor.lightGray.cgColor
        viewUPI.layer.borderColor = UIColor.lightGray.cgColor
        btnBankSelected.setImage(UIImage(named: "switchOn"), for: .normal)
        btnPayPalSelected.setImage(UIImage(named: "switchOff"), for: .normal)
        btnUPISelected.setImage(UIImage(named: "switchOff"), for: .normal)
        paymentType = 1 //1 for Bank, 2 for Paypal, 3 for UPIID
    }
    
    @IBAction func payPalViewSelected() {
        viewBank.layer.borderColor = UIColor.lightGray.cgColor
        viewPaypal.layer.borderColor = UIColor.systemBlue.cgColor
        viewUPI.layer.borderColor = UIColor.lightGray.cgColor
        
        btnBankSelected.setImage(UIImage(named: "switchOff"), for: .normal)
        btnPayPalSelected.setImage(UIImage(named: "switchOn"), for: .normal)
        btnUPISelected.setImage(UIImage(named: "switchOff"), for: .normal)
        paymentType = 2 //1 for Bank, 2 for Paypal, 3 for UPIID
    }
    
    @IBAction func upiViewSelected() {
        viewBank.layer.borderColor = UIColor.lightGray.cgColor
        viewPaypal.layer.borderColor = UIColor.lightGray.cgColor
        viewUPI.layer.borderColor = UIColor.systemBlue.cgColor
        
        btnBankSelected.setImage(UIImage(named: "switchOff"), for: .normal)
        btnPayPalSelected.setImage(UIImage(named: "switchOff"), for: .normal)
        btnUPISelected.setImage(UIImage(named: "switchOn"), for: .normal)
        
        paymentType = 3 //1 for Bank, 2 for Paypal, 3 for UPIID
    }
    
    func showSuccessAlert(){
        let viewAlert = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        viewAlert.backgroundColor = UIColor.white
        viewAlert.alpha = 0.8
        
        let height = self.view.frame.width - 100
        let viewAlertCenter = UIView(frame: CGRect(x: 50, y: (self.view.frame.height / 2 - height/2), width: height, height: height))
        viewAlertCenter.backgroundColor = UIColor.white
        let imgView = UIImageView(frame: CGRect(x: (height / 2 - 108), y: 20, width: 216, height: 179))
        imgView.image = UIImage(named: "successful")
        viewAlertCenter.addSubview(imgView)
        
        let btnSuccess = UIButton(frame: CGRect(x: 0, y: viewAlertCenter.frame.height - 60, width: viewAlertCenter.frame.width, height: 60))
        btnSuccess.setTitle("Withdrawal Request Submitted", for: .normal)
        btnSuccess.titleLabel?.textColor = UIColor.white
        btnSuccess.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btnSuccess.titleLabel?.numberOfLines = 0
        btnSuccess.backgroundColor = UIColor.blue
        btnSuccess.addTarget(self, action: #selector(self.handleTap(_:)), for: .touchUpInside)
        viewAlertCenter.addSubview(btnSuccess)
        
        viewAlertCenter.layer.cornerRadius = 10.0
        viewAlertCenter.layer.borderColor = UIColor.lightGray.cgColor
        viewAlertCenter.layer.borderWidth = 1.0
        viewAlertCenter.layer.shadowColor = UIColor.black.cgColor
        viewAlertCenter.layer.shadowOffset = CGSize(width: 2, height: 2)
        viewAlertCenter.layer.shadowOpacity = 0.7
        viewAlertCenter.layer.shadowRadius = 5.0
        viewAlertCenter.clipsToBounds = true
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        viewAlert.addGestureRecognizer(tap)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        viewAlertCenter.addGestureRecognizer(tap1)
        
        
        self.view.addSubview(viewAlert)
        self.view.addSubview(viewAlertCenter)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func requestRedeemCoin(){
        let url = Constant.sharedinstance.requestRedeemCoin
        var isValid = false
        if paymentType == 1 {
            
            if txtBankName.text?.trimmingCharacters(in: .whitespaces).isEmpty == true{
                Themes.sharedInstance.ShowNotification("Bank name field cannot be empty", false)
            }else if txtAccountNumber.text?.trimmingCharacters(in: .whitespaces).isEmpty == true{
                Themes.sharedInstance.ShowNotification("Bank account field cannot be empty", false)
            }else if txtConfirmAccountNo.text?.trimmingCharacters(in: .whitespaces).isEmpty == true{
                Themes.sharedInstance.ShowNotification("Confirm account number field cannot be empty", false)
            }else if txtAccountNumber.text != txtConfirmAccountNo.text {
                Themes.sharedInstance.ShowNotification("Bank account and Confirm Account field did not match", false)
            }else if txtIFSCCode.text?.trimmingCharacters(in: .whitespaces).isEmpty == true{
                Themes.sharedInstance.ShowNotification("IFSC code field cannot be empty", false)
            }else if txtAccountHolderName.text?.trimmingCharacters(in: .whitespaces).isEmpty == true{
                Themes.sharedInstance.ShowNotification("Account holder's name field cannot be empty", false)
            }else {
                name = txtAccountHolderName.text ?? ""
                accountNumber = txtAccountNumber.text ?? ""
                ifsc = txtIFSCCode.text ?? ""
                swiftCode = txtSwiftCode.text ?? ""
                paymentValue = ""
                bankName = txtBankName.text ?? ""
                isValid = true
            }
            
            
        }else  if paymentType == 2 {
            if txtPayPalID.text?.trimmingCharacters(in: .whitespaces).isEmpty == true{
                Themes.sharedInstance.ShowNotification("PayPal ID field cannot be empty", false)
            }else {
            isValid = true
            paymentValue = txtPayPalID.text ?? ""
            }
        }else  if paymentType == 3 {
            if txtUPIID.text?.trimmingCharacters(in: .whitespaces).isEmpty == true{
                Themes.sharedInstance.ShowNotification("UPI ID field cannot be empty", false)
            }else {
            isValid = true
            paymentValue = txtUPIID.text ?? ""
            }
        }
        
        if isValid == false {
            return
        }
        
        var param:NSDictionary = [:]
        
        if paymentType == 1 {
            param = ["name":name,  "accountNumber":accountNumber, "ifsc": ifsc, "swiftCode":swiftCode, "paymentType":paymentType, "paymentValue":paymentValue, "amount":amount, "bankName":bankName]
        }else if paymentType == 2 || paymentType == 3{
            param = ["name":"",  "accountNumber":"", "ifsc": "", "swiftCode":"", "paymentType":paymentType, "paymentValue":paymentValue, "amount":amount]
        }
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeCall(url: url as String, param: param, completionHandler: {(responseObject, error) ->  () in
                   Themes.sharedInstance.RemoveactivityView(View: self.view)
                   if(error != nil)
                   {
                       self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                   }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
                let message = result["message"]
                if status == 1{
                    
                    self.showSuccessAlert()
                    /*AlertView.sharedManager.presentAlertWith(title: "", msg: "Withdrawl request submitted successfully.", buttonTitles: ["OK"], onController: self) { title, index in
                        self.navigationController?.popViewController(animated: true)
                    }*/
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    
}


extension AddBankDetailVC:UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtBankName || textField == txtAccountNumber || textField == txtConfirmAccountNo  || textField == txtIFSCCode || textField == txtSwiftCode || textField == txtAccountHolderName{
            self.bankViewSelected()
        }else if textField == txtPayPalID {
            self.payPalViewSelected()
        }else if textField == txtUPIID{
            self.upiViewSelected()
        }
        return true
    }
}

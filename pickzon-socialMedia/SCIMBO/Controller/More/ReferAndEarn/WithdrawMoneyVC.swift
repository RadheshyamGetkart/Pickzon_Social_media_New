//
//  WithdrawMoneyVC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 4/13/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit

class WithdrawMoneyVC: UIViewController {

    @IBOutlet weak var btnAddAccount:UIButton!
    @IBOutlet weak var btnConfirmWithdraw:UIButton!
    @IBOutlet weak var viewPrimaryBank: UIView!
    
    var name = "", accountNumber = "", ifsc = "", swiftCode = ""
    var paymentType = 1 //1 for bank, 2 for Paypal, 3 for Upi
    var paymentValue = 0, amount = 0
    
    override func viewDidLoad(){
        super.viewDidLoad()

        btnAddAccount.layer.cornerRadius = 5.0
        btnAddAccount.backgroundColor = UIColor(red: 217.0/255.0, green:  217.0/255.0, blue:  217.0/255.0, alpha: 1.0)
        btnAddAccount.setTitleColor(UIColor.systemBlue, for: .normal)
        btnAddAccount.tintColor = UIColor.systemBlue
        
        btnConfirmWithdraw.layer.cornerRadius = 5.0
        
        viewPrimaryBank.layer.cornerRadius = 5.0
        viewPrimaryBank.layer.borderColor = UIColor.blue.cgColor
        viewPrimaryBank.layer.borderWidth = 1.0
        
    }
    

//MARK: Button Action Methods
   @IBAction func backButtonAction(){
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func AddAccountButtonAction(){
        let vc: AddBankDetailVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "AddBankDetailVC") as! AddBankDetailVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func confirmWithdraw() {
        self.checkCoinRedeem()
    }
    
    func checkCoinRedeem(){
        let url = Constant.sharedinstance.checkCoinRedeem
         let param:NSDictionary = [:]
        URLhandler.sharedinstance.makeGetCall(url: url as String, param: param, completionHandler: {(responseObject, error) ->  () in
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
                    self.requestRedeemCoin()
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    func requestRedeemCoin(){
        let url = Constant.sharedinstance.requestRedeemCoin
        let param:NSDictionary = ["name":name,  "accountNumber":accountNumber, "ifsc": ifsc, "swiftCode":swiftCode, "paymentType":paymentType, "paymentValue":paymentValue, "amount":amount]
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
                    
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
}

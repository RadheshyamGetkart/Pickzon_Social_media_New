//
//  WithdrawVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/20/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import Photos

class WithdrawVC: UIViewController {
   
    @IBOutlet weak var cnstrntHtNavbar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnWithdraw: UIButton!
    @IBOutlet weak var txtFdCoin: UITextField!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAccountNo: UILabel!
    @IBOutlet weak var lblConvertedAmt: UILabel!
    @IBOutlet weak var lblLimitTitle: UILabel!
    @IBOutlet weak var lblAvailableCoin: UILabel! 

   // var isChecked = true
    var accountInfo = WithdrawCoinModel(respDict: [:])
    var imageBank:UIImage?
    
    //MARK: Controller life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavbar.constant = self.getNavBarHt
        btnWithdraw.layer.cornerRadius = 5.0
        btnWithdraw.clipsToBounds = true
        tblView.register(UINib(nibName: "AccountInfoTblCell", bundle: nil), forCellReuseIdentifier: "AccountInfoTblCell")
        updateData()
    }
    
    func updateData(){
        lblName.text = accountInfo.acccountHolderName
        lblAccountNo.text = accountInfo.accountNo
        lblLimitTitle.text = "Minimum \(accountInfo.withdrawalLimit) coins can be withdrawal."
        lblAvailableCoin.text = "\(accountInfo.availableGiftCoin)"
    }
    
    //MARK: Common Button Actions
    @IBAction func backButonAction(_ sender:UIButton){
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
        
    @IBAction func editBankButonAction(_ sender:UIButton){
        self.view.endEditing(true)
        let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "AccountInfoVC") as! AccountInfoVC
        vc.accountInfo = accountInfo
        vc.isEdit = true
        vc.callBack = { (objWithdraw: WithdrawCoinModel,_ img:UIImage?) in
            self.accountInfo = objWithdraw
            self.imageBank = img
            self.updateData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func withdrawButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if (Int(txtFdCoin.text!) ?? 0 == 0 || Int(txtFdCoin.text!) ?? 0 < 0) {
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Please enter valid coins.")
            
        }else if  Int(txtFdCoin.text!) ?? 0 < accountInfo.withdrawalLimit{
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "You cannot withdraw coins less than limit.")
            
        }else if  Int(txtFdCoin.text!) ?? 0 > accountInfo.availableGiftCoin{
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "You have no sufficient available coins.")
            
        }else{
            if imageBank != nil {
                uploadImage(image: imageBank!)
            }else{
                withdrawCoinsApi(accReferenceImage: accountInfo.accReferenceImage)
                
            }
        }
    }
    
    //MARK: API Methods
    
    func uploadImage(image:UIImage){
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.uploadImageWithParameters(profileImg:image, imageName: "accReferenceImage", url: Constant.sharedinstance.coin_get_acc_reference_url, params: [:])
        { response in
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)
           // let message = response["message"] as? String ?? ""
            let status = response["status"] as? Int16 ?? 0
            
            
            if status == 1 {
                if let payload = response["payload"] as? NSDictionary {
                    
                    if let accReferenceImage = payload["accReferenceImage"] as? String {
                        self.withdrawCoinsApi(accReferenceImage:accReferenceImage)
                    }
                }
            }
        }
    }
    
    
    func withdrawCoinsApi(accReferenceImage:String){
        
        let bank:[String : Any] = ["name":accountInfo.acccountHolderName,"bankName":accountInfo.bankName,"accountNumber":accountInfo.accountNo,"ifsc":accountInfo.ifscCode,"panCard":accountInfo.panNumber,"accReferenceImage":accReferenceImage]
        
        let params:[String : Any] = ["coins":txtFdCoin.text!,"paymentType":"bank","bank":bank,"isPanCard":accountInfo.isPancardSaved,"isAccNum":accountInfo.isBankSaved]
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeCall(url: Constant.sharedinstance.coin_withdraw_request, param: params as NSDictionary) {(responseObject, error) ->  () in
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
                        let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WithdrawalSuccessVC") as! WithdrawalSuccessVC
                        vc.message = message
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }else{
                    
                    AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["Ok"], onController: self) { title, index in
                        
                    }
                    
                }
            }
        }
    }
}

extension WithdrawVC:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let previousText:NSString = textField.text! as NSString
        let updatedText = previousText.replacingCharacters(in: range, with: string)
        //        if let enteredVal = Int(updatedText){
        //            if enteredVal < accountInfo.withdrawalLimit{
        //                return false
        //            }
        //        }
        //        if updatedText.length > 5 {
        //            return false
        //        }
        
        if updatedText.hasPrefix("0"){
            return false
        }
        
        if string.isEmpty {
            return true
        }
        
        let alphaNumericRegEx = "^[0-9]"
        let predicate = NSPredicate(format:"SELF MATCHES %@", alphaNumericRegEx)
        return predicate.evaluate(with: string)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}




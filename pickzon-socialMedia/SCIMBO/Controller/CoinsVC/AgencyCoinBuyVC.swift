//
//  AgencyCoinBuyVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 4/15/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

protocol AgencyCoinBuyDelegate{
    
    func boughtCoinByRetailer()
}

class AgencyCoinBuyVC: UIViewController {

    @IBOutlet weak var txtFdTransctionId:UITextField!
    @IBOutlet weak var btnClose:UIButtonX!
    @IBOutlet weak var btnDone:UIButtonX!
    @IBOutlet weak var bgVwTransaction:UIViewX!
    @IBOutlet weak var bgVwSuccessTransaction:UIViewX!
    
    @IBOutlet weak var lblTitleSuccess:UILabel!
    @IBOutlet weak var lblSubTitleSuccess:UILabel!
    var obj = CoinOfferModel(respDict: [:])
    var delegate:AgencyCoinBuyDelegate?
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        btnClose.setImageTintColor(.gray)
        txtFdTransctionId.layer.cornerRadius = 5.0
        txtFdTransctionId.layer.borderWidth = 1.0
        txtFdTransctionId.layer.borderColor = UIColor.lightGray.cgColor
        txtFdTransctionId.clipsToBounds = true
        txtFdTransctionId.addLeftPadding()
        txtFdTransctionId.setAttributedPlaceHolder(text: "Transaction id...", color: .lightGray)
        btnDone.layer.cornerRadius = 5.0
        btnDone.clipsToBounds = true
        bgVwSuccessTransaction.isHidden = true

    }
    
    

    //MARK: UIButton Action Methods
    
    @IBAction func closeBtnAction(){
        
        self.dismissView(animated: true) {
            
        }
        
    }
    
    @IBAction func doneTransactionBtnAction(){
        self.view.endEditing(true)
        if txtFdTransctionId.text!.trim().count == 0{
            
        }else{
            submitOrderApi()
        }
    }
    
    @IBAction func successDoneTransactionBtnAction(){
        self.dismissView(animated: true) {
            self.delegate?.boughtCoinByRetailer()
        }
    }

    //MARK: Api Methods
    
    
    func submitOrderApi(){
        
        let params = ["agencyPlanId":obj._id,"transactionId":(txtFdTransctionId?.text ?? "")] as [String : Any]
        Themes.sharedInstance.activityView(View: self.view)
       
        URLhandler.sharedinstance.makeCall(url: Constant.sharedinstance.agency_coin_transfer, param:params as NSDictionary) {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                
                if status == 1 {
                    self.bgVwSuccessTransaction.isHidden = false

                }
            }
        }
    }

}

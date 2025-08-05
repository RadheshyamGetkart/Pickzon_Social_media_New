//
//  RetailerDashboardVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 8/28/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import IQKeyboardManager
import Kingfisher

class RetailerDashboardVC: UIViewController {
    
    
    @IBOutlet weak var cnstrntHtNavbar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnTransferCoins:UIButton!
    @IBOutlet weak var txtFdPickzonId:UITextField!
    @IBOutlet weak var txtFdCoin:UITextField!
    @IBOutlet weak var btnVerifyPickzonId:UIButton!
    

    @IBOutlet weak var userBgview:UIView!
    @IBOutlet weak var imgVwProfile:UIImageViewX!
    @IBOutlet weak var imgVwCelebrity:UIImageView!
    @IBOutlet weak var lblPickzonId:UILabel!
    @IBOutlet weak var lblName:UILabel!

    
    var userId = ""
    var isVerified = false
    var benefitsArray = [String]()
    
    //MARK: Controller Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavbar.constant = self.getNavBarHt
        tblView.register(UINib(nibName: "BenefitsTblCell", bundle: nil), forCellReuseIdentifier: "BenefitsTblCell")
        btnTransferCoins.layer.cornerRadius = 5.0
        btnTransferCoins.clipsToBounds = true
        getRetailerDetails()
        userBgview.isHidden = true
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }
    
    
    func updateVerifiedUser(){
        
    }
    //MARK: UIBUtton Action Methods
    @IBAction func transferBtnActionMethods(){
        
        if (isVerified == false) || (txtFdCoin.text?.trimmingLeadingAndTrailingSpaces().length ?? 0) < 0 {
            return
        }
        
         if let val =  Int(txtFdCoin.text ?? "0") {
            
            if  val <= 0 {
                return
            }
        }

        if (txtFdPickzonId.text?.trimmingLeadingAndTrailingSpaces().length ?? 0) < 5{
            Themes.sharedInstance.ShowNotification("Please enter valid pickzon Id.", true)
            
        }else if isVerified == false {
            Themes.sharedInstance.ShowNotification("Please verify pickzon Id.", false)
        }else if (txtFdCoin.text?.trimmingLeadingAndTrailingSpaces().length ?? 0) <= 0 {
            Themes.sharedInstance.ShowNotification("Please enter coins to transfer.", true)
            
        }else{
            
            AlertView.sharedManager.presentAlertWith(title: "PickZon", msg: "Do you want to transfer coins to \(txtFdPickzonId.text ?? "") ?" as NSString, buttonTitles: ["Cancel","Confirm"], onController: self) { title, index in
                
                if index == 1{
                    self.sendOtpApi()
                }
            }
        }
    }
    
    
    @IBAction func backBtnActionMethods(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func profileBtnAction(){
        let viewController:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        viewController.otherMsIsdn = userId
        self.navigationController?.pushView(viewController, animated: true)
    }
    
    @IBAction func verifyBtnActionMethods(){
        
        if (txtFdPickzonId.text?.trimmingLeadingAndTrailingSpaces().length ?? 0) < 5{
            Themes.sharedInstance.ShowNotification("Please enter valid pickzon Id.", true)
            
        }else{
            self.getUserIdFromPickzonId(pickzonId: txtFdPickzonId.text ?? "")
        }
    }
    
    //MARK: Api Methods
    
    
    func sendOtpApi(){
        Themes.sharedInstance.activityView(View: self.view)
       
        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.send_otp_transfer_coin, param: NSMutableDictionary()) { (responseObject, error) ->  () in
            
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
                    
                    if let payload = result["payload"] as? Dictionary<String,Any>{
                        
                        DispatchQueue.main.async {
                            
                            if let destVC = StoryBoard.coin.instantiateViewController(withIdentifier: "RetailerVerifyOtpVC") as? RetailerVerifyOtpVC{
                                destVC.mobileNo = payload["mobileNumber"] as? String ?? ""
                                destVC.emailId = payload["email"] as? String ?? ""
                                destVC.uid = payload["uid"] as? String ?? ""
                                destVC.coins = self.txtFdCoin.text ?? ""
                                destVC.userId = self.userId
                                self.navigationController?.pushViewController(destVC, animated: true)
                            }
                        }
                        
                    }
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
        params.setValue(txtFdCoin.text ?? "", forKey: "coins")
        
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
                        AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["Ok"], onController: self){ title, index in
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        }
    }
    
    
    func getUserIdFromPickzonId(pickzonId:String){
        
        Themes.sharedInstance.activityView(View: self.view)
        
        let params = NSMutableDictionary()
        let url:String = Constant.sharedinstance.getmsisdn + "?pickzonId=\(pickzonId)"
        
        URLhandler.sharedinstance.makeGetAPICall(url:url, param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                if let result = responseObject{
                    let status = result["status"] as? Int16 ?? 0
                    let message = result["message"] as? String ?? ""
                    if status == 1{
                        let payload = result["payload"] as? Dictionary<String, Any> ?? [:]
                        self.userId = payload["userId"] as? String ?? ""
                        let name = payload["name"] as? String ?? ""
                        let pickzonId = payload["pickzonId"] as? String ?? ""
                        let profilePic = payload["profilePic"] as? String ?? ""
                        let celebrity = payload["celebrity"] as? Int ?? 0

                        DispatchQueue.main.async {
                            self.userBgview.isHidden = false
                            
                            self.lblName.text = name
                            self.lblPickzonId.text = pickzonId
                            
                            self.imgVwProfile.kf.setImage(with: URL(string: profilePic), placeholder: PZImages.avatar , options: nil, progressBlock: nil, completionHandler: { response in  })
                            
                            switch celebrity{
                            case 1:
                                self.imgVwCelebrity.isHidden = false
                                self.imgVwCelebrity.image = PZImages.greenVerification
                                
                            case 4:
                                self.imgVwCelebrity.isHidden = false
                                self.imgVwCelebrity.image = PZImages.goldVerification
                            case 5:
                                self.imgVwCelebrity.isHidden = false
                                self.imgVwCelebrity.image = PZImages.blueVerification
                                
                            default:
                                self.imgVwCelebrity.isHidden = true
                            }
                            
                            
                            self.btnVerifyPickzonId.setImage(UIImage(named: "tick"), for: .normal)
                            self.btnVerifyPickzonId.setTitle("", for: .normal)
                            self.btnVerifyPickzonId.setImageTintColor(UIColor.systemGreen)
                            self.isVerified = true
                            self.txtFdPickzonId.isEnabled = false
                            if (self.txtFdCoin.text?.trimmingLeadingAndTrailingSpaces().length ?? 0) > 0{
                                self.btnTransferCoins.backgroundColor = .systemBlue
                            }else{
                                self.btnTransferCoins.backgroundColor = .darkGray
                            }
                        }
                    }else
                    {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        })
    }
    
    
    
    func getRetailerDetails(){
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeGetCall(url: Constant.sharedinstance.get_retailer_guidelines, param: [:]) {(responseObject, error) ->  () in
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                _ = result["message"]
                
                if status == 1 {
                    if let payload = result["payload"] as? Array<String> {
                        self.benefitsArray = payload
                        self.tblView.reloadData()
                    }
                    
                }
            }
        }
    }
}

extension RetailerDashboardVC:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    
    //MARK: UITableview Delegate & Datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return  UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if benefitsArray.count > 0{
            return benefitsArray.count + 1
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "BenefitsTblCell") as! BenefitsTblCell
        
        if indexPath.row == 0{
            
            cell.btnCheck.isHidden = false
            cell.lblTitle.isHidden =  true
            cell.btnCheck.setImage(nil, for: .normal)
            cell.btnCheck.setTitle("Guidelines", for: .normal)
            cell.btnCheck.contentHorizontalAlignment = .left
        }else{
            cell.btnCheck.isHidden =  false
            cell.lblTitle.isHidden =  false
            cell.btnCheck.contentHorizontalAlignment = .center
            cell.btnCheck.setImage(nil, for: .normal)
            cell.btnCheck.setTitle("•", for: .normal)
            cell.lblTitle.text =  benefitsArray[indexPath.row-1]
        }
        
        return cell
    }
    
    //MARK: UITextfield Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let previousText:NSString = textField.text! as NSString
        let updatedText = previousText.replacingCharacters(in: range, with: string)
        
        if textField == txtFdCoin{
            
            if string.isEmpty {
                return true
            }
            if !(updatedText.isNumeric && (updatedText.trim().count > 0)) || updatedText.hasPrefix("0"){
                return false
            }
            if isVerified == true && updatedText.length > 0{
                self.btnTransferCoins.backgroundColor = .systemBlue
            }else{
                self.btnTransferCoins.backgroundColor = .darkGray
            }
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == txtFdCoin{
            
            if isVerified == true && (textField.text?.trimmingLeadingAndTrailingSpaces().length ?? 0) > 0{
                self.btnTransferCoins.backgroundColor = .systemBlue
            }else{
                self.btnTransferCoins.backgroundColor = .darkGray
            }
        }
    }
    
}

//
//  AgencyOrderViewController.swift
//  SCIMBO
//
//  Created by gurmukh singh on 8/25/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit




class AgencyOrderViewController: UIViewController {
  
    
    @IBOutlet weak var cnstrntHtNavbar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    var objAgencyDetail: AgencyDetailModel!
    var objConiSelected :CoinOfferModel = CoinOfferModel(respDict: [:])
   
    @IBOutlet weak var btnContactAgency: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var bgViewPopup: UIView!
    @IBOutlet weak var lblHeadingPopup: UILabel!
    @IBOutlet weak var lblDetailPopup: UILabel!
    @IBOutlet weak var btnConfirmPopuup: UIButton!
    var selectedIndex = 0
    var objCoinDetail = CoinDetail(respDict: [:])
    
    //MARK: Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cnstrntHtNavbar.constant = self.getNavBarHt
        bgViewPopup.isHidden = true
        btnConfirmPopuup.layer.cornerRadius = 5.0
        btnConfirmPopuup.clipsToBounds = true

        btnContactAgency.layer.cornerRadius = 5.0
        btnContactAgency.clipsToBounds = true
        
        btnConfirm.layer.cornerRadius = 5.0
        btnConfirm.clipsToBounds = true
        
        tblView.register(UINib(nibName: "AgencyOrderDetailCell", bundle: nil), forCellReuseIdentifier: "AgencyOrderDetailCell")
        tblView.register(UINib(nibName: "AgencyPaymentOptionCell", bundle: nil), forCellReuseIdentifier: "AgencyPaymentOptionCell")
        
        tblView.register(UINib(nibName: "BenefitsTblCell", bundle: nil), forCellReuseIdentifier: "BenefitsTblCell")
        
        
        
        tblView.separatorColor = UIColor.clear
    }
    
    //MARK UIButton Action Methods
    @IBAction func backButonAction(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmBtnAction(_ sender: UIButton) {
        submitOrderApi()
    }
    
    @IBAction func contactAgencyBtnAction(_ sender: UIButton) {
        let strMsg = "Hi Agency, I want to purchase pickzon cheer coins. \nPrice: \(objCoinDetail.currencySymbol)\(objConiSelected.amount) \nCheer Coins (\(objConiSelected.coins)) \nMy Pickzon Id:- \(Themes.sharedInstance.getPickzonId())"
        if objAgencyDetail.businessPhone.length == 0 {
            let settingsVC:FeedChatVC = StoryBoard.chat.instantiateViewController(withIdentifier: "FeedChatVC") as! FeedChatVC
            settingsVC.toChat = objAgencyDetail.id
            settingsVC.fromName = objAgencyDetail.agencyName
            settingsVC.fullUrl = objAgencyDetail.profilePic
            settingsVC.pickzonId = objAgencyDetail.pickzonId
            settingsVC.strMsg = strMsg
            self.navigationController?.pushViewController(settingsVC, animated: true)
        }else {
            self.openWhatsapp()
        }
    }
    
    func openWhatsapp() {
        let strMsg = "Hi Agency, I want to purchase pickzon cheer coins. \nPrice: \(objCoinDetail.currencySymbol)\(objConiSelected.amount) \nCheer Coins (\(objConiSelected.coins)) \nMy Pickzon Id:- \(Themes.sharedInstance.getPickzonId())"
        
        let appURLString = "https://api.whatsapp.com/send?phone=\(objAgencyDetail.businessPhone)&text=\(strMsg)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let webURLString = "https://wa.me/\(objAgencyDetail.businessPhone)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let appURL = URL(string:appURLString)!
        let webURL = URL(string: webURLString)!
        
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.openURL(appURL)
        } else {
            UIApplication.shared.openURL(webURL)
        }
    }
    
    
    
    @IBAction func confirmPopupBtnAction(_ sender: UIButton) {
      
        self.bgViewPopup.isHidden = true

        if let VC = StoryBoard.coin.instantiateViewController(withIdentifier: "AgencyOrderPreviewVC") as? AgencyOrderPreviewVC{
            VC.objCoinDetail = objCoinDetail
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    
    @IBAction func closePopupBtnAction(_ sender: UIButton) {
        self.bgViewPopup.isHidden = true
        
    }
    
    //MARK: Api Methods
    
    func submitOrderApi(){
        Themes.sharedInstance.activityView(View: self.view)
        let params = NSMutableDictionary()
        
        params.setValue(objAgencyDetail.id, forKey: "agencyId")
        params.setValue(objConiSelected._id, forKey: "coinPlansOfferId")
        
        let paymentOption = NSMutableDictionary()
        
       
        if objAgencyDetail.arrAgencyPayDetails.count > 0{
            paymentOption.setValue(objAgencyDetail.arrAgencyPayDetails[selectedIndex].method, forKey: "method")
            paymentOption.setValue(objAgencyDetail.arrAgencyPayDetails[selectedIndex].referenceId, forKey: "referenceId")
        }else{
            paymentOption.setValue("", forKey: "method")
            paymentOption.setValue("", forKey: "referenceId")
        }
        
        params.setValue(paymentOption, forKey: "paymentOption")
        
        
        
        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.agency_coin_order, param: params) { (responseObject, error) ->  () in
            
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
                    
                    
                    if let payload = result["payload"] as? Dictionary<String,Any> {
                        
                        DispatchQueue.main.async {
                            self.lblHeadingPopup.text = message
                            self.lblDetailPopup.text = payload["message"] as? String ?? ""
                            self.bgViewPopup.isHidden = false
                        }
                        
                        self.objCoinDetail = CoinDetail(respDict: payload as NSDictionary)
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

extension AgencyOrderViewController: UITableViewDelegate, UITableViewDataSource {
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else {
            return (objAgencyDetail.arrAgencyPayDetails.count == 0) ? 0 : (objAgencyDetail.arrAgencyPayDetails.count + 1)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 147
        }else {
            if indexPath.row == 0 {
                return 40
            }else {
                return 118
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tblView.dequeueReusableCell(withIdentifier: "AgencyOrderDetailCell") as! AgencyOrderDetailCell
            cell.selectionStyle = .none
            //cell.lblPickZonId.text = objAgencyDetail.pickzonId
             
            cell.lblPickZonId.text = Themes.sharedInstance.getUserName()
            cell.lblCoinCount.text = "\(self.objConiSelected.coins)"
            cell.lblCoinAmount.text = "\(self.objConiSelected.currencySymbol) \(self.objConiSelected.amount)"
            cell.lblname.text =  self.objAgencyDetail.pickzonId
            
            return cell
        }else {
            if indexPath.row == 0 {
                let cell = tblView.dequeueReusableCell(withIdentifier: "BenefitsTblCell") as! BenefitsTblCell
                let title = "Payment Options"
                cell.btnCheck.isHidden = false
                cell.lblTitle.isHidden =  true
                cell.btnCheck.setImage(nil, for: .normal)
                cell.btnCheck.setTitle(title, for: .normal)
                cell.btnCheck.contentHorizontalAlignment = .left
                return cell
            }else {
                let cell = tblView.dequeueReusableCell(withIdentifier: "AgencyPaymentOptionCell") as! AgencyPaymentOptionCell
                cell.lblMethod.text = objAgencyDetail.arrAgencyPayDetails[indexPath.row - 1].method
                cell.lblReferenceID.text = objAgencyDetail.arrAgencyPayDetails[indexPath.row - 1].referenceId
                cell.imgLogo.kf.setImage(with: URL(string: objAgencyDetail.arrAgencyPayDetails[indexPath.row - 1].icon), options: nil, progressBlock: nil, completionHandler: { response in })
                cell.bgVw.layer.borderColor =  (selectedIndex == indexPath.row - 1) ? UIColor.black.cgColor : UIColor.white.cgColor
                cell.bgVw.layer.borderWidth = 0.5
                cell.imgVwCheck.isHidden = (selectedIndex == indexPath.row - 1) ? false : true
                cell.btnCopy.tag  = indexPath.row - 1
                cell.btnCopy.addTarget(self, action: #selector(copyUpiIdBtnAction(_ : )), for: .touchUpInside)
                
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row != 0 {
                self.selectedIndex = indexPath.row - 1
                self.tblView.reloadData()
            }
        }
    }
    
    //MARK: Selctor Methods
    
    @objc func copyUpiIdBtnAction(_ sender: UIButton) {
        UIPasteboard.general.string = objAgencyDetail.arrAgencyPayDetails[sender.tag].referenceId
        self.view.makeToast(message: "\(objAgencyDetail.arrAgencyPayDetails[sender.tag].referenceId) has been copied to clipboard.", duration: 3, position: HRToastActivityPositionDefault)
    }
}

//
//  ReferalsViewController.swift
//  SCIMBO
//
//  Created by gurmukh singh on 4/11/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDynamicLinks

class ReferalsViewController: UIViewController {
    
    @IBOutlet weak var tblReferals:UITableView!
    
    var arrCashHistory:Array<[String:AnyObject]> = Array()
    var arrCoinHistory:Array<[String:AnyObject]> = Array()
    var userInfo :[String:AnyObject]!
    
    var strReferralCode = ""
    var wallet:Int64 = 0
    var money:Double = 0
    var isCoinSelected = true
    var strCurrencySymbol = ""
    
    var accountNumber:Int64 = 0
    var ifsc = ""
    var name = ""
    var bankName = ""
    var swiftCode = ""
    var paymentType = 1 ////1 for bank, 2 for Paypal, 3 for Upi
    var paymentValue = ""
    var referralMessage = ""
    var invitationUrl:URL!
    var pageNumber:Int16 = 0
    var totalPage:Int16 = 0
    var isLoading = false
    
    //MARK:- ViewController life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblReferals.register(UINib(nibName: "ReferTVCell", bundle: nil), forCellReuseIdentifier: "ReferTVCell")
        tblReferals.register(UINib(nibName: "PayumentHistoryCell", bundle: nil), forCellReuseIdentifier: "PayumentHistoryCell")
        
        tblReferals.adjustTableStatusBarHeight()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getReferralHistory()
        
    }
    //MARK:- UIButton Actions
    @objc func btnBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func btnWalletAction() {
        self.checkCoinRedeem()
        
    }
    
    func fetchReferalLinkFirebase(){
        //guard let uid = Auth.auth().currentUser?.uid else { return }
        //let link = URL(string: "https://mygame.example.com/?invitedby=\(uid)")
        let link = URL(string: "https://pickzon.com/?invitedby=\(self.strReferralCode)")
        let referralLink = DynamicLinkComponents(link: link!, domainURIPrefix: "https://pickzon.com")

        referralLink?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.apps.pickzon")
        referralLink?.iOSParameters?.minimumAppVersion = "1.0"
        referralLink?.iOSParameters?.appStoreID = "1560097730"

        referralLink?.androidParameters = DynamicLinkAndroidParameters(packageName: "com.chat.pickzon")
        referralLink?.androidParameters?.minimumVersion = 1

        referralLink?.shorten { (shortURL, warnings, error) in
          if let error = error {
            print(error.localizedDescription)
            return
          }
            print("shortURL: ",shortURL)
          self.invitationUrl = shortURL
        }
    }
    
    
    func checkCoinRedeem(){
        let url = Constant.sharedinstance.checkCoinRedeem
         let param:NSDictionary = [:]
        Themes.sharedInstance.activityView(View: self.view)
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
                    let vc: AddBankDetailVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "AddBankDetailVC") as! AddBankDetailVC
                    vc.name = self.name
                    vc.bankName = self.bankName
                    if self.accountNumber == 0 {
                        vc.accountNumber = ""
                    }else {
                        vc.accountNumber = "\(self.accountNumber)"
                    }
                    vc.ifsc = self.ifsc
                    vc.swiftCode = self.swiftCode
                    vc.paymentType = self.paymentType //1 for bank, 2 for Paypal, 3 for Upi
                    vc.paymentValue = self.paymentValue
                    vc.amount = self.money
                    //vc.amount = 10
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                    
                    
                }
            }
        })
    }
    
    
    
    
    @objc func btnCoinSelectionAction() {
        isCoinSelected = true
        tblReferals.reloadData()
    }
    @objc  func btnCashSelectionAction() {
        isCoinSelected = false
        tblReferals.reloadData()
    }
    
    @objc func copyRefereralCodeToClipboard(){
        UIPasteboard.general.string = strReferralCode
        
        self.view.makeToast(message: "Referal Code: \(strReferralCode) has been copied to clipboard.", duration: 3, position: HRToastActivityPositionDefault)
    }
    
    @objc func shareBtnAction(){
        let appStoreLink = "Hey, Your friend just made Rs. 1000/- Join now and get a chance to earn a maximum joining bonus for free… Use this code during signup (Referal Code: \(strReferralCode)) to claim your bonus instantly.\nDownload PickZon app & stay entertained! \nIOS App: https://apps.apple.com/in/app/pickzon/id1560097730 \n Android App: https://play.google.com/store/apps/details?id=com.chat.pickzon"
        
        let objectsToShare = [appStoreLink]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.setValue("PickZon App", forKey: "subject")
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            if success == true {
                print("Success")
            }else {
                print("fail")
            }
        }
        //New Excluded Activities Code
        if #available(iOS 9.0, *) {
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print]
        } else {
            // Fallback on earlier versions
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print ]
        }
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @objc func howToEarnMoney() {
    
        
        let destVC:PrivacyPolicyViewController = StoryBoard.main.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
        destVC.strTitle = "How To Earn Money"
        destVC.strURl = Constant.sharedinstance.howToEarnURL
        self.navigationController?.pushView(destVC, animated: true)
        
    }
   //MARK:- API Implementation
    func getReferralHistory(){
        self.isLoading = true
        let url = Constant.sharedinstance.referralHistory + "?pageNumber=\(pageNumber)&pageLimit=25"
         let param:NSDictionary = [:]
        Themes.sharedInstance.activityView(View: self.view)
        URLhandler.sharedinstance.makeGetCall(url: url as String, param: param, completionHandler: {(responseObject, error) ->  () in
            self.isLoading = false
                   Themes.sharedInstance.RemoveactivityView(View: self.view)
                   if(error != nil)
                   {
                       self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                   } else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
                let message = result["message"]
                if status == 1{
                    let payload = result["payload"] as? Dictionary<String, Any> ?? [:]
                    if let array = payload["cashHistory"] as? Array<[String:AnyObject]>{
                        self.arrCashHistory.append(contentsOf: array)
                    }
                    
                    if let array = payload["coinHistory"] as? Array<[String:AnyObject]>{
                        self.arrCoinHistory.append(contentsOf: array)
                    }
                    self.referralMessage = payload["referralMessage"] as? String ?? ""
                    
                    if let walletInfo = payload["walletInfo"] as? Dictionary<String, AnyObject> {
                        
                        self.strReferralCode = walletInfo["referralCode"] as? String ?? ""
                        self.wallet = walletInfo["wallet"] as? Int64 ?? 0
                        self.money = walletInfo["money"] as? Double ?? 0.0
                        self.strCurrencySymbol = walletInfo["currency"] as? String ?? ""
                    }
                    
                    if let bankDetail = payload["bankDetail"] as? Dictionary<String, AnyObject> {
                        
                        self.accountNumber = bankDetail["accountNumber"] as? Int64 ?? 0
                        self.ifsc = bankDetail["ifsc"] as? String ?? ""
                        self.name = bankDetail["name"] as? String ?? ""
                        self.bankName = bankDetail["bankName"] as? String ?? ""
                        self.swiftCode = bankDetail["swiftCode"] as? String ?? ""
                        self.paymentType = bankDetail["paymentType"] as? Int ?? 1
                        self.paymentValue = bankDetail["paymentValue"] as? String ?? ""
                    }
                    
                    self.tblReferals.reloadData()
                    self.totalPage = result["totalPages"] as? Int16 ?? 0
                    if self.pageNumber < self.totalPage {
                        self.pageNumber = self.pageNumber + 1
                    }
                    
                    //self.fetchReferalLinkFirebase()
                    
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
     
    
}


extension ReferalsViewController:UITableViewDelegate, UITableViewDataSource {
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else {
            if isCoinSelected == true {
                return arrCoinHistory.count
            }else {
                return arrCashHistory.count
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReferTVCell") as! ReferTVCell
            cell.btnWallet.addTarget(self, action: #selector(self.btnWalletAction), for: .touchUpInside)
            cell.btnShare.addTarget(self, action: #selector(self.shareBtnAction), for: .touchUpInside)
            cell.btnShareImage.addTarget(self, action: #selector(self.shareBtnAction), for: .touchUpInside)
            
            cell.btnCoin.addTarget(self, action: #selector(self.btnCoinSelectionAction), for: .touchUpInside)
            cell.btnCash.addTarget(self, action: #selector(self.btnCashSelectionAction), for: .touchUpInside)
            cell.btnBack.addTarget(self, action: #selector(self.btnBackAction), for: .touchUpInside)
            
            cell.btnHowToEarn.addTarget(self, action: #selector(self.howToEarnMoney), for: .touchUpInside)
            
            cell.lblreferralMessage.text = self.referralMessage
            
            if isCoinSelected == true {
                cell.btnCoin.setTitleColor(UIColor.blue, for: .normal)
                cell.viewCoinSelection.backgroundColor = UIColor.blue
                cell.btnCash.setTitleColor(UIColor.darkGray, for: .normal)
                cell.viewCashSelection.backgroundColor = UIColor.white
            }else {
                cell.btnCash.setTitleColor(UIColor.darkGray, for: .normal)
                cell.viewCoinSelection.backgroundColor = UIColor.white
                cell.btnCash.setTitleColor(UIColor.blue, for: .normal)
                cell.viewCashSelection.backgroundColor = UIColor.blue
            }
            
            //cell.lblCurrencysymbol.text = "\(self.strCurrencySymbol)"
            cell.lblCurrenyValue.text = "\(self.wallet)"
            cell.lblTotalAmtValue.text = "\(self.strCurrencySymbol) \(self.money)"
            
            cell.lblReferalCode.text = self.strReferralCode
            cell.btnCopyReferalCode.addTarget(self, action: #selector(self.copyRefereralCodeToClipboard), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PayumentHistoryCell") as! PayumentHistoryCell
            cell.selectionStyle = .none
            if isCoinSelected == true {
                let obj =  arrCoinHistory[indexPath.row]
                cell.lblDate.text = obj["date"] as? String ?? ""
                
                cell.lblMessage.text = obj["message"] as? String ?? ""
                let type = obj["type"] as? Int64 ?? 0
                if type == 1 {
                    cell.lblAmt.text = "+ \(obj["amount"] as? Int64 ?? 0) "
                    cell.lblAmt.textColor = CustomColor.sharedInstance.themeColor
                }else {
                    cell.lblAmt.text = "- \(obj["amount"] as? Int64 ?? 0) "
                    cell.lblAmt.textColor = UIColor.red
                }
            }else {
                let obj =  arrCashHistory[indexPath.row]
                cell.lblDate.text = obj["date"] as? String ?? ""
                let  message = obj["message"] as? String ?? ""
                let transactionId = obj["transactionId"] as? String ?? ""
                let status = obj["status"] as? String  ?? ""
                if status.lowercased() == "pending" {
                    
                        
                        let attributedString1 = NSMutableAttributedString(string: "")
                        
                        let attrs1 = [NSAttributedString.Key.foregroundColor : UIColor.darkGray]
                        let attrs2 = [ NSAttributedString.Key.foregroundColor : UIColor.orange]
                        
                        if message.length > 0 {
                            let msgAttributedString = NSMutableAttributedString(string:(message + " "), attributes:attrs1)
                            attributedString1.append(msgAttributedString)
                        }
                        
                        let attributedString2 = NSMutableAttributedString(string:status.capitalized, attributes:attrs2)
                        attributedString1.append(attributedString2)
                        cell.lblMessage.attributedText = attributedString1
                        
                    
                }else if status.lowercased() == "success" {
                    
                    
                        let attributedString1 = NSMutableAttributedString(string: "")
                        
                        let attrs1 = [NSAttributedString.Key.foregroundColor : UIColor.darkGray]
                        let attrs2 = [ NSAttributedString.Key.foregroundColor : CustomColor.sharedInstance.themeColor]
                        
                        if message.length > 0 {
                            let msgAttributedString = NSMutableAttributedString(string:(message + " "), attributes:attrs1)
                            attributedString1.append(msgAttributedString)
                        }
                        if transactionId.length > 0 {
                            let transAttributedString = NSMutableAttributedString(string:("Transaction ID: " + transactionId + ", "), attributes:attrs1)
                            attributedString1.append(transAttributedString)
                        }
                    
                        let attributedString2 = NSMutableAttributedString(string:status.capitalized, attributes:attrs2)
                        attributedString1.append(attributedString2)
                        cell.lblMessage.attributedText = attributedString1
                        
                    
                   
                    
                }else {
                    let attributedString1 = NSMutableAttributedString(string: "")
                    let attrs1 = [NSAttributedString.Key.foregroundColor : UIColor.darkGray]
                    let attrs2 = [ NSAttributedString.Key.foregroundColor : UIColor.red]
                    
                    if message.length > 0 {
                        let msgAttributedString = NSMutableAttributedString(string:(message + ", "), attributes:attrs1)
                        attributedString1.append(msgAttributedString)
                    }
                    
                    let attributedString2 = NSMutableAttributedString(string:status.capitalized, attributes:attrs2)
                    attributedString1.append(attributedString2)
                    cell.lblMessage.attributedText = attributedString2
                }
                
                let type = obj["type"] as? Int64 ?? 0
                if type == 1 {
                    cell.lblAmt.text = "+ \(self.strCurrencySymbol) \(obj["amount"] as? Double ?? 0.0)"
                    cell.lblAmt.textColor = CustomColor.sharedInstance.themeColor
                }else {
                    cell.lblAmt.text = "- \(self.strCurrencySymbol) \(obj["amount"] as? Double ?? 0.0)"
                    cell.lblAmt.textColor = UIColor.red
                }
                
                
            }
            return cell
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
       
        if scrollView == tblReferals{
            
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
            {
                if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                    
                    self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
                    
                }else  if !isLoading {
                    if self.pageNumber < self.totalPage {
                        self.getReferralHistory()
                    }
                }
            }
        }
    }
    
    
    
    
    
}

extension UITableView{
    func adjustTableStatusBarHeight(){
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            statusBarHeight = {
                var heightToReturn: CGFloat = 0.0
                     for window in UIApplication.shared.windows {
                         if let height = window.windowScene?.statusBarManager?.statusBarFrame.height, height > heightToReturn {
                             heightToReturn = height
                         }
                     }
                return heightToReturn
            }()
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        
        let insets = UIEdgeInsets(top: statusBarHeight * -1, left: 0, bottom: 0, right: 0)
        self.contentInset = insets
        self.scrollIndicatorInsets = insets
    }
}

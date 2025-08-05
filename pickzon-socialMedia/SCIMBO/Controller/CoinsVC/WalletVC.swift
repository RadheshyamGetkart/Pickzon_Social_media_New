//
//  WalletVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/15/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import FittedSheets
import Razorpay
import StoreKit


protocol WalletDelegate{
    
 func coinupdateBalance()
    
}

class WalletVC: SwiftBaseViewController {
    
    var delegateWallet:WalletDelegate?
    @IBOutlet weak var cnstrntHtNavbar:NSLayoutConstraint!
    @IBOutlet weak var btnEarnings:UIButton!
    @IBOutlet weak var btnCheerCoins:UIButton!
    @IBOutlet weak var viewSeperator:UIView!
    @IBOutlet weak var tblView:UITableView!
    var isCheerSelected = true
    var isReadMoreSelected = false
    var coinOfferArray = [CoinOfferModel]()
    var giftedCoinsDollar = ""
    var premiumBenefits = [String]()
    var premiumKeyPoints = [String]()
    var monetizingKeyPoints = [String]()
    var cheerCoins = 0
    var giftedCoins = 0
    var exchangeLimit = 0
    var withdrawalLimit = 0
    var selectedIndex = 0
    var selectedObj = CoinOfferModel(respDict:[:])
    private var razorpay: RazorpayCheckout?
    var withdrawObj = WithdrawCoinModel(respDict: [:])
    var isGiftedCoinsTabOpen = false
    var pickzonAppLogo = ""
    
    var InAppReceipt = ""
    var paymentType = 0
    
    //Agency
    var coinOfferArrayAgency = [CoinOfferModel]()
   
    var objConiSelected :CoinOfferModel = CoinOfferModel(respDict: [:])
    var btnRechargeNowAgency:UIButton!
    
    var viewPopUpBack = UIView()
    
    //MARK: Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavbar.constant = self.getNavBarHt
        tblView.register(UINib(nibName: "CoinsHeaderTblCell", bundle: nil), forCellReuseIdentifier: "CoinsHeaderTblCell")
        tblView.register(UINib(nibName: "BenefitsTblCell", bundle: nil), forCellReuseIdentifier: "BenefitsTblCell")
        tblView.register(UINib(nibName: "CheerCoinTblCell", bundle: nil), forCellReuseIdentifier: "CheerCoinTblCell")
        tblView.register(UINib(nibName: "AgencyBtnCell", bundle: nil), forCellReuseIdentifier: "AgencyBtnCell")
        
        tblView.register(UINib(nibName: "GiftedCoinTblCell", bundle: nil), forCellReuseIdentifier: "GiftedCoinTblCell")
        
        
        if Settings.sharedInstance.isAgency == 1 {
            self.btnEarnings.isHidden = true
            self.viewSeperator.isHidden = true
            self.isCheerSelected = true
            self.btnCheerCoins.contentHorizontalAlignment = .left
            self.btnCheerCoins.setTitle(" Cheer Coins", for: .normal)
            

            coinAgencyRetailerPlanOffersListApi()
            
            
        }else{
            viewSeperator.frame =  CGRect(x: btnCheerCoins.frame.origin.x, y: btnCheerCoins.frame.origin.y+btnCheerCoins.frame.size.height, width: btnCheerCoins.frame.size.width, height: 2)
            
            if isGiftedCoinsTabOpen{
                self.commonHeaderButonAction(btnEarnings)
            }else{
                self.btnCheerCoins.setTitleColor(.label, for: .normal)
                self.btnEarnings.setTitleColor(.lightGray, for: .normal)
            }
            
            getPremiumBenefitsApi()
            coinPlanOffersListApi()
            getBankDetailsApi()
            getAgencyPlanOffersApi()
        }
        razorpay = RazorpayCheckout.initWithKey(Constant.sharedinstance.razorpay_api_key, andDelegate: self)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getAvailableCoinList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegateWallet?.coinupdateBalance()
    }
    
    //MARK: Common Button Actions
    @IBAction func backButonAction(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func commonHeaderButonAction(_ sender:UIButton){
        
        
        self.btnCheerCoins.setTitleColor(.lightGray, for: .normal)
        self.btnEarnings.setTitleColor(.lightGray, for: .normal)
        sender.setTitleColor(.label, for: .normal)
        
        
        UIView.animate(withDuration: 0.3, animations: {
            self.viewSeperator.frame =  CGRect(x: sender.frame.origin.x, y: sender.frame.origin.y+sender.frame.size.height, width: sender.frame.size.width, height: 2)
            self.viewSeperator.updateConstraints()
        })
        
        
        switch sender.tag{
        case 1000:
            isCheerSelected = false
            break
        case 1001:
            isCheerSelected = true
            break
            
        default:
            break
        }
        
        updateUI()
    }
    
    func updateUI(){
        self.tblView.reloadData()
    }
    
    //MARK: Appi Methods
    
    func getPremiumBenefitsApi(){
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeGetCall(url: Constant.sharedinstance.premiumBenefits, param: [:]) {(responseObject, error) ->  () in
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
            }
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                _ = result["message"]
                
                if status == 1 {
                    if let payloadDict = result["payload"] as? NSDictionary {
                        self.premiumBenefits = payloadDict["premiumBenefits"] as? Array<String> ?? []
                        self.premiumKeyPoints = payloadDict["premiumKeyPoints"] as? Array<String> ?? []
                        self.monetizingKeyPoints = payloadDict["monetizingKeyPoints"] as? Array<String> ?? []
                        self.tblView.reloadData()
                    }
                    
                }
            }
        }
    }
    
    func getBankDetailsApi(){
        
        URLhandler.sharedinstance.makeGetCall(url: Constant.sharedinstance.user_bank_details, param: [:]) {(responseObject, error) ->  () in
            
            if(error != nil){
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                //let message = result["message"] as? String ?? ""
                
                if status == 1 {
                    if let payload = result["payload"] as? Dictionary<String,Any> {
                        self.withdrawObj = WithdrawCoinModel(respDict: payload)
                    }
                    
                }
            }
        }
    }
    
    
    func getOrderIdApi(){
        
        let params = ["coinPlansOfferId":selectedObj._id]
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeCall(url: Constant.sharedinstance.coin_generate_coin_payment_order, param:params as NSDictionary) {(responseObject, error) ->  () in
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
            }
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                // let message = result["message"] as? String ?? ""
                
                if status == 1 {
                    if let payload = result["payload"] as? Dictionary<String,Any> {
                        self.selectedObj.coinOrderId = payload["coinOrderId"] as? String ?? ""
                        let orderId = payload["orderId"] as? String ?? ""
                        
                        //paymentType 0 for Razor Pay, 1 for inAppPurchase and 2 for CCAvenue
                        //For default payments we are using inAppPurchase Payment Gateway
                        self.paymentType = payload["paymentType"] as? Int ?? 1
                        if self.paymentType == 0 {
                            //Razor pay implementation
                            self.showPaymentForm(orderId:orderId)
                        }else {
                            //Apple In App Purchase
                            //self.paymentType == 1
                            self.IAPPaymentForm()
                        }
                    }
                    
                }
            }
        }
    }
    
    
    func coinPlanOffersListApi(){
        
        self.coinOfferArray.removeAll()
        self.tblView.reloadData()
        
        var countryCode = (SKPaymentQueue.default().storefront?.countryCode ?? "")
        
        if countryCode.length > 0 {
            countryCode = fetchCountryCountryCodeIOS2(countryCode).lowercased()
        }
        
        let url = Constant.sharedinstance.coinPlanOffersList + "?location=\(countryCode)"
        
        URLhandler.sharedinstance.makeGetCall(url: url, param: [:]) {(responseObject, error) ->  () in
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                // let message = result["message"] as? String ?? ""
                
                if status == 1 {
                    if let payload = result["payload"] as? Array<Any> {
                        
                        for dict in payload{
                            self.coinOfferArray.append(CoinOfferModel(respDict: dict as! Dictionary<String, Any>))
                        }
                        self.tblView.reloadData()
                    }
                    
                }
            }
        }
    }
    
    
    
   
    
    
    func coinAgencyRetailerPlanOffersListApi(){
        

        URLhandler.sharedinstance.makeGetCall(url: Constant.sharedinstance.agency_get_agency_plans, param: [:]) {(responseObject, error) ->  () in
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                // let message = result["message"] as? String ?? ""
                
                if status == 1 {
                    if let payload =  result["payload"] as? Dictionary<String,Any> {
                        self.coinOfferArrayAgency.removeAll()
                        
                        let agencyPlanOffer = payload["agencyPlanOffer"] as? Array<Any> ?? []
                        
                        for dict in agencyPlanOffer {
                            self.coinOfferArrayAgency.append(CoinOfferModel(respDict: dict as! Dictionary<String, Any>))
                        }
                        
//                        for dict in payload{
//                            self.coinOfferArray.append(CoinOfferModel(respDict: dict as! Dictionary<String, Any>))
//                        }
                        self.tblView.reloadData()
                    }
                    
                }
            }
        }
    }
    
    
    func getAgencyPlanOffersApi(){
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeGetCall(url: Constant.sharedinstance.agencyPlanOffersURL, param: [:]) {(responseObject, error) ->  () in
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
            }
            
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
                        let agencyPlanOffer = payload["agencyPlanOffer"] as? Array<Any> ?? []
                        
                        for dict in agencyPlanOffer {
                            self.coinOfferArrayAgency.append(CoinOfferModel(respDict: dict as! Dictionary<String, Any>))
                        }
                        
                        let agencyguidelines = payload["agencyguidelines"] as? Dictionary<String, Any> ?? [:]
                        let dictRecharge = agencyguidelines["recharge"] as? Dictionary<String, Any> ?? [:]
                        Themes.sharedInstance.arrRechargeList =  dictRecharge["list"] as? Array<String> ?? []
                        Themes.sharedInstance.strRechargeTitle = dictRecharge["title"] as? String ?? ""
                        
                        let dictTerms = agencyguidelines["terms"] as? Dictionary<String, Any> ?? [:]
                        Themes.sharedInstance.arrTermList =  dictTerms["list"] as? Array<String> ?? []
                        Themes.sharedInstance.strTermTitle = dictTerms["title"] as? String ?? ""
                        
                        self.tblView.reloadData()
                    }
                    
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        }
    }
    
    
    func getAvailableCoinList(){
        
        let urlStr = "\( Constant.sharedinstance.userCoinInfo)?type=1"
       
        URLhandler.sharedinstance.makeGetCall(url:urlStr, param: [:]) {(responseObject, error) ->  () in
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1 {
                    if let payload = result["payload"] as? Dictionary<String, Any> {
                        self.pickzonAppLogo = payload["pickzonAppLogo"] as? String ?? ""
                        self.cheerCoins = (payload["cheerCoins"] as? Int ?? 0)
                        self.giftedCoins = (payload["giftedCoins"] as? Int ?? 0)
                        self.exchangeLimit = payload["exchangeLimit"] as? Int ?? 0
                        self.withdrawalLimit = payload["withdrawalLimit"] as? Int ?? 0
                        self.giftedCoinsDollar = payload["giftedCoinsDollar"] as? String ?? ""
                        Constant.sharedinstance.razorpay_api_key =  payload["razorpayKey"] as? String ?? ""
                        self.razorpay = RazorpayCheckout.initWithKey(Constant.sharedinstance.razorpay_api_key, andDelegate: self)
                        self.tblView.reloadData()
                    }
                    
                }else{
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
    }
    
    
    func buyCoinsApi(paymentId:String){
        let paymentInfo = ["type":  1, "receipt": InAppReceipt] as [String : Any]
        
        let params:[String : Any] = ["coinPlansOfferId":selectedObj._id,"transactionId":paymentId,"amount":selectedObj.amount,"coinOrderId":selectedObj.coinOrderId, "paymentType":self.paymentType, "paymentInfo":paymentInfo]
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeCall(url: Constant.sharedinstance.coin_purchase_coins, param: params as NSDictionary) {(responseObject, error) ->  () in
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
            }
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1 {
                    self.getAvailableCoinList()
                    //MARK: Refreshing for offer first buy
                    self.coinPlanOffersListApi()
                }
                
                AlertView.sharedManager.displayMessageWithAlert(title: "", msg: message)
                //self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
            }
        }
    }
    
    
    
    
    func exchangeGiftCoinsApi(giftedCoins:String){
        
        let params:[String : Any] = ["giftedCoins":giftedCoins]
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeCall(url: Constant.sharedinstance.exchange_gift_coins_to_cheer_coins, param: params as NSDictionary) {(responseObject, error) ->  () in
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
            }
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1 {
                    if let payload = result["payload"] as? Dictionary<String, Any> {
                        self.giftedCoins = (payload["giftedCoins"] as? Int ?? 0)
                        self.cheerCoins = (payload["cheerCoins"] as? Int ?? 0)
                        self.tblView.reloadData()
                    }
                }
                
                AlertView.sharedManager.displayMessageWithAlert(title: "", msg:message)
                
            }
        }
    }
}

extension WalletVC:UITableViewDelegate,UITableViewDataSource{
    
    //MARK:UITableview Delegate & Datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if Settings.sharedInstance.isAgency == 1 {
            return  3 //2
        }
        
        if isCheerSelected == true{
                return 5
        }
       
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isCheerSelected == true && (section == 2 || section == 3) || (Settings.sharedInstance.isAgency == 1){
            return 100
        }else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 2  && Settings.sharedInstance.isAgency == 1 {
            
            let count = coinOfferArrayAgency.count
            let width = CGFloat(self.view.frame.size.width/3.0)
            let divide =  CGFloat(count/3) * width
            var  remainder = CGFloat(count % 3) * width
            if  (count % 3) > 0 && count % 3 < 3{
                remainder = width
            }else{
                remainder = 0
            }
            return  CGFloat(divide + remainder + 20)
        }
        
        if indexPath.section == 2 {
            
            let count = coinOfferArray.count
            let width = CGFloat(self.view.frame.size.width/3.0)
            let divide =  CGFloat(count/3) * width
            var  remainder = CGFloat(count % 3) * width
            if  (count % 3) > 0 && count % 3 < 3{
                remainder = width
            }else{
                remainder = 0
            }
            return  CGFloat(divide + remainder + 20)
        }else if indexPath.section == 4{
            if indexPath.row == 0 {
                let count = coinOfferArrayAgency.count
                let width = CGFloat((self.view.frame.size.width/3)/2 + 30)
                let divide =  CGFloat(count/3) * width
                var  remainder = CGFloat(count % 3) * width
                if  (count % 3) > 0 && count % 3 < 3{
                    remainder = width
                }else{
                    remainder = 0
                }
                return  CGFloat(divide + remainder + 20)
            }
        }
        
        return  UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Settings.sharedInstance.isAgency == 1 {
          
            return 1
        }
        
        if section == 0{
            return 1
        }else if section == 1{
            if isReadMoreSelected == false && isCheerSelected == true{
                return 0
            }else if isReadMoreSelected == true && isCheerSelected == true{
                return premiumBenefits.count + 1
            }
            
            return monetizingKeyPoints.count + 1
            
            
            //            return premiumKeyPoints.count + 1
        }else if section == 2{
            return 1
        }else if section == 3{
            if coinOfferArrayAgency.count == 0 {
                return 0
            }else {
                return 1
            }
        }else if section == 4{
            if coinOfferArrayAgency.count == 0 {
                return 0
            }else {
                return 1
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if Settings.sharedInstance.isAgency == 1 && indexPath.section == 1 {
            let cell = tblView.dequeueReusableCell(withIdentifier: "AgencyBtnCell") as! AgencyBtnCell
            cell.lblTitle.text = "Retailer Dashboard"
            cell.cnstrnt_topView.constant = 15
            
            return cell
            
        }else if  Settings.sharedInstance.isAgency == 1 && indexPath.section == 2 {
            //Buy coins by retailer
            let cell = tblView.dequeueReusableCell(withIdentifier: "CheerCoinTblCell") as! CheerCoinTblCell
            cell.isAgencyCell = false
            cell.coinOfferArray = coinOfferArrayAgency
            cell.lblTitle.text = (coinOfferArrayAgency.count > 0) ? "Buy Cheer Coins" : ""
            cell.collectioVwCheerCoin.reloadData()
            cell.delegate = self
            return cell
        }
        
        if indexPath.section == 0{
         
            
            if isCheerSelected{
                
                let cell = tblView.dequeueReusableCell(withIdentifier: "CoinsHeaderTblCell") as! CoinsHeaderTblCell
                cell.bgViewUpgradePremium.isHidden = true
                cell.imgVwBanner.image = UIImage(named: "rectanglePink")
                cell.btnWithdraw.isHidden = true
                //let imageName = isReadMoreSelected ? "down-arrow 1-3" : "right-arrow 1"
                //cell.btnReadMore.setImage(UIImage(named: imageName), for: .normal)
                //cell.bgViewUpgradePremium.isHidden = false
                cell.btnWithdraw.isHidden = true
                cell.lblTitleCoins.text = "Available Coins"
                if Settings.sharedInstance.isAgency == 1{
                    cell.btnHistory.setTitle("Transaction History", for: .normal)
                }else{
                    cell.btnHistory.setTitle("History", for: .normal)
                }
                cell.btnHistory.setTitleColor(Themes.sharedInstance.colorWithHexString(hex: "#e887b1"), for: .normal)
                cell.btnEarnHistory.isHidden = true
                cell.lblNumberOfCoins.text = "\(cheerCoins)"
                cell.imgVwCoin.image = UIImage(named: "coin1")
                
                cell.btnReadMore.addTarget(self, action: #selector(readMoreBtnAction(_ : )), for: .touchUpInside)
                cell.btnHistory.addTarget(self, action: #selector(historyBtnAction(_ : )), for: .touchUpInside)
                cell.btnWithdraw.addTarget(self, action: #selector(withdrawBtnAction(_ : )), for: .touchUpInside)
                cell.btnEarnHistory.addTarget(self, action: #selector(earnHistoryBtnAction(_ : )), for: .touchUpInside)
                
                return cell
            }else{
                
                let cell = tblView.dequeueReusableCell(withIdentifier: "GiftedCoinTblCell") as! GiftedCoinTblCell
                
                cell.btnExchangeForCheerCoin.addTarget(self, action: #selector(exchangeGiftedCoinsBtnAction(_ : )), for: .touchUpInside)
                cell.btnHistory.addTarget(self, action: #selector(historyGiftedCoinsBtnAction(_ : )), for: .touchUpInside)
                
                cell.btnWithdraw.addTarget(self, action: #selector(withdrawGiftedCoinsBtnAction(_ : )), for: .touchUpInside)
               // cell.lblCoinAndValue.text = " \(giftedCoins) = \(giftedCoinsDollar)"

                
                cell.lblCoinAndValue.setAttributedText(firstText: "\(giftedCoins) = ", firstcolor: .white, seconText: giftedCoinsDollar, secondColor: Themes.sharedInstance.colorWithHexString(hex: "FCD304") , firstFont:  UIFont(name: "Roboto-Medium", size: 20.0)!, secondFont:  UIFont(name: "Roboto-Medium", size: 20.0)!)
                
                
                return cell
            }
            
            
        }else if indexPath.section == 1{
            let cell = tblView.dequeueReusableCell(withIdentifier: "BenefitsTblCell") as! BenefitsTblCell
            
            if indexPath.row == 0{
                let title = isCheerSelected ? "Benefits:" : "Guidelines" //"Key Points for Premium users"
                cell.btnCheck.isHidden = false
                cell.lblTitle.isHidden =  true
                cell.btnCheck.setImage(nil, for: .normal)
                cell.btnCheck.setTitle(title, for: .normal)
                cell.btnCheck.contentHorizontalAlignment = .left
            }else{
                cell.btnCheck.isHidden =  false
                cell.lblTitle.isHidden =  false
                cell.btnCheck.contentHorizontalAlignment = .center
                
                if (isCheerSelected){
                    cell.btnCheck.setImage(UIImage(named: "tick"), for: .normal)
                    cell.btnCheck.setTitle("", for: .normal)
                    cell.btnCheck.setImageTintColor(.green)
                }else{
                    cell.btnCheck.setImage(nil, for: .normal)
                    cell.btnCheck.setTitle("•", for: .normal)
                }
                cell.lblTitle.text =  (isCheerSelected) ? premiumBenefits[indexPath.row-1] : monetizingKeyPoints[indexPath.row-1] //premiumKeyPoints[indexPath.row-1]
            }
            
            return cell
        }else if indexPath.section == 2{
            
            let cell = tblView.dequeueReusableCell(withIdentifier: "CheerCoinTblCell") as! CheerCoinTblCell
            cell.isAgencyCell = false
            cell.coinOfferArray = coinOfferArray
            if coinOfferArray.count == 0 {
                cell.lblTitle.text = ""
            }else {
                cell.lblTitle.text = "Buy Cheer Coins"
            }
            cell.collectioVwCheerCoin.reloadData()
            cell.delegate = self
            return cell
        }else if indexPath.section == 3{
            let cell = tblView.dequeueReusableCell(withIdentifier: "AgencyBtnCell") as! AgencyBtnCell
            cell.cnstrnt_topView.constant = 0
            cell.btnInfo.setImage(UIImage(named: "octicon_info-16"), for: .normal)
            return cell
        }else if indexPath.section == 4 {
            
            if indexPath.row == 0 {
                let cell = tblView.dequeueReusableCell(withIdentifier: "CheerCoinTblCell") as! CheerCoinTblCell
                cell.lblTitle.text = "Choose Package"
                cell.coinOfferArray = coinOfferArrayAgency
                cell.isAgencyCell = true
                cell.collectioVwCheerCoin.reloadData()
                cell.delegate = self
                return cell
            }
            
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if Settings.sharedInstance.isAgency == 1  && indexPath.section == 1{
            
            let vc = StoryBoard.coin.instantiateViewController(withIdentifier: "RetailerDashboardVC") as! RetailerDashboardVC
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if indexPath.section == 3{
            self.infoBtnAction()
        }/*else  if indexPath.section == 4  && indexPath.row == 1 {
          if objConiSelected._id != "" {
          let vc = StoryBoard.coin.instantiateViewController(withIdentifier: "AgencyListViewController") as! AgencyListViewController
          vc.objConiSelected = self.objConiSelected
          navigationController?.pushViewController(vc, animated: true)
          
          }
          }*/
    }
    
    
    //MARK: - Follow Btn Action
    @objc func readMoreBtnAction(_ sender : UIButton){
        isReadMoreSelected.toggle()
        self.tblView.reloadData()
    }
    
    
    @objc func historyBtnAction(_ sender : UIButton){
        
        if isCheerSelected{
            if Settings.sharedInstance.isAgency == 1{
                //Cheer Coin History
                let vc = StoryBoard.coin.instantiateViewController(withIdentifier: "AgencyTransactionHistoryVC") as! AgencyTransactionHistoryVC
                vc.historyType = .agencyTransferHistory
                navigationController?.pushViewController(vc, animated: true)
            }else{
                //Cheer Coin History
                let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "CoinHistoryVC") as! CoinHistoryVC
                vc.coinsTYpe = .cheerCoins
                navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            //Exchange
            
            if giftedCoins < exchangeLimit{
                AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "You need minimum \(exchangeLimit) gifted coins for exchange to cheer coins.")
            }else{
                let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "PanCardInfoVC") as! PanCardInfoVC
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                vc.delegate = self
                vc.isPanCardInfo = false
                vc.exchangeLimit = exchangeLimit
                vc.panNumber = self.withdrawObj.panNumber
                vc.giftedCoin = giftedCoins
                self.navigationController?.presentView(vc, animated: true)
            }
        }
    }
    
    
    @objc func withdrawBtnAction(_ sender : UIButton){
        
        if giftedCoins < withdrawalLimit{
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "You need minimum \(withdrawalLimit) gifted coins for withdraw.")
        }else{
            let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "PanCardInfoVC") as! PanCardInfoVC
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            vc.delegate = self
            vc.isPanCardInfo = true
            vc.panNumber = withdrawObj.panNumber
            self.navigationController?.presentView(vc, animated: true)
        }
    }
    
    @objc func earnHistoryBtnAction(_ sender : UIButton){
        
        let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "CoinHistoryVC") as! CoinHistoryVC
        vc.coinsTYpe = .giftCoins
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
   
    @objc func exchangeGiftedCoinsBtnAction(_ sender : UIButton){
        
        if giftedCoins < exchangeLimit{
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "You need minimum \(exchangeLimit) gifted coins for exchange to cheer coins.")
        }else{
            let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "PanCardInfoVC") as! PanCardInfoVC
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            vc.delegate = self
            vc.isPanCardInfo = false
            vc.exchangeLimit = exchangeLimit
            vc.panNumber = self.withdrawObj.panNumber
            vc.giftedCoin = giftedCoins
            self.navigationController?.presentView(vc, animated: true)
        }
    }

    
    @objc func historyGiftedCoinsBtnAction(_ sender : UIButton){
        
        let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "CoinHistoryVC") as! CoinHistoryVC
        vc.coinsTYpe = .giftCoins
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func withdrawGiftedCoinsBtnAction(_ sender : UIButton){
       
        if giftedCoins < withdrawalLimit{
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "You need minimum \(withdrawalLimit) gifted coins for withdraw.")
        }else{
            let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "PanCardInfoVC") as! PanCardInfoVC
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            vc.delegate = self
            vc.isPanCardInfo = true
            vc.panNumber = withdrawObj.panNumber
            self.navigationController?.presentView(vc, animated: true)
        }
        
    }
      
    
}


//MARK:- Razorpay Gateway
extension WalletVC: RazorpayProtocol, RazorpayPaymentCompletionProtocol,CheerCoinDelegate,PanCardDelegate,AgencyCoinBuyDelegate{
     
    //Afterr agency bought update
    func boughtCoinByRetailer(){
        
        self.getAgencyPlanOffersApi()
        self.coinAgencyRetailerPlanOffersListApi()
    }
    

    func selectedPanCard(card:String,isPanCardInfo:Bool,isPanCardSaved:Bool){
        if isPanCardInfo{
            //Pancard info
            let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "AccountInfoVC") as! AccountInfoVC
            self.withdrawObj.panNumber = card
            self.withdrawObj.withdrawalLimit = withdrawalLimit
            self.withdrawObj.isPancardSaved = isPanCardSaved
            self.withdrawObj.availableGiftCoin = giftedCoins
            vc.accountInfo = self.withdrawObj
            navigationController?.pushViewController(vc, animated: true)
        }else{
            //Exchange earned to cheer coins
            self.exchangeGiftCoinsApi(giftedCoins: card)
        }
    }
    
    func cheeredCoinBuyNow(obj:CoinOfferModel, isAgency:Bool){
        
        if  Settings.sharedInstance.isAgency == 1{
            //IS retailer
            if let destVC = StoryBoard.coin.instantiateViewController(withIdentifier: "AgencyCoinBuyVC") as? AgencyCoinBuyVC{
                destVC.modalPresentationStyle = .overCurrentContext
                destVC.obj = obj
                destVC.delegate = self
                self.navigationController?.presentView(destVC, animated: false, completion: {
                    
                })
            }
        }else{
            
            if isAgency == false {
                selectedObj = obj
                getOrderIdApi()
            }else {
                
                print("cheeredCoinBuyNow")
                if let index = coinOfferArrayAgency.firstIndex(where: {$0._id == obj._id}) {
                    objConiSelected = obj
                    objConiSelected.isSelected = true
                    coinOfferArrayAgency[index] = objConiSelected
                    for index1 in 0..<coinOfferArrayAgency.count {
                        if index1 == index {
                            coinOfferArrayAgency[index1].isSelected = true
                        }else {
                            coinOfferArrayAgency[index1].isSelected = false
                        }
                    }
                    
                }
                /*if obj._id != objConiSelected._id {
                 if let index = coinOfferArrayAgency.firstIndex(where: {$0._id == obj._id}) {
                 objConiSelected = obj
                 objConiSelected.isSelected = true
                 coinOfferArrayAgency[index] = objConiSelected
                 for index1 in 0..<coinOfferArrayAgency.count {
                 if index1 == index {
                 coinOfferArrayAgency[index1].isSelected = true
                 }else {
                 coinOfferArrayAgency[index1].isSelected = false
                 }
                 }
                 
                 }
                 }else {
                 objConiSelected = CoinOfferModel(respDict: [:])
                 for index1 in 0..<coinOfferArrayAgency.count {
                 coinOfferArrayAgency[index1].isSelected = false
                 }
                 }*/
                tblView.reloadData()
                
                if objConiSelected._id.length > 0 {
                    self.showPopupBuyCoinsAgency()
                }
            }
        }
    }
    
    func showPopupBuyCoinsAgency() {
        viewPopUpBack.frame = self.view.frame
        viewPopUpBack.backgroundColor = UIColor(r: 226.0/255.0, g: 226.0/255.0, b: 225.0/255.0, a: 0.5)
        
        
        let viewPopUp = UIView(frame: CGRect(x: (self.view.frame.width/2.0 - 295.0/2.0) , y: (self.view.frame.height / 2) - (295.0/2.0), width: 295.0, height: 273.0))
        viewPopUp.backgroundColor = UIColor.clear
        viewPopUp.layer.cornerRadius = 15.0
        viewPopUp.clipsToBounds = true
        
        let imgpopup = UIImageView(frame: CGRect(x: 0 , y: 0, width: viewPopUp.frame.size.width, height: viewPopUp.frame.size.height))
        imgpopup.image = UIImage(named: "coinPurchasePopup")
        imgpopup.contentMode = .scaleAspectFill
        viewPopUp.addSubview(imgpopup)
        
        let imgCoin = UIImageView(frame: CGRect(x: (viewPopUp.frame.width/2.0 - 75.0) , y: 20, width: 150.0, height: 114.0))
        imgCoin.image = UIImage(named: "coinStar")
        viewPopUp.addSubview(imgCoin)
        
        
        
        
        
        let lblCoin = UILabel(frame: CGRect(x: viewPopUp.frame.width/2 - 60, y: 173, width: 0, height:40.0 ))
        
        let strCoin = "\(objConiSelected.oldCoins)"
        let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.white ]
        let attrStrCoin = NSMutableAttributedString(string: strCoin, attributes: myAttribute)
        
        if objConiSelected.oldCoins < objConiSelected.coins {
            let strCoinExtra = " (+\(objConiSelected.coins - objConiSelected.oldCoins))"
            let myAttribute1 = [ NSAttributedString.Key.foregroundColor: UIColor.red ]
            let attrStrCoinExtra = NSMutableAttributedString(string: strCoinExtra, attributes: myAttribute1)
            attrStrCoin.append(attrStrCoinExtra)
        }
        
        // set attributed text on a UILabel
        lblCoin.attributedText = attrStrCoin
        lblCoin.textAlignment = .center
        lblCoin.font = UIFont.systemFont(ofSize: 25.0)
        
        var rect: CGRect = lblCoin.frame //get frame of label
        rect.size = (lblCoin.text?.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25.0)]))! //Calculate as per label font
        
        lblCoin.frame = CGRect(x: viewPopUp.frame.width/2 - rect.width/2, y: 173, width: rect.width, height:40.0 )
        
        viewPopUp.addSubview(lblCoin)
        
        if objConiSelected.discount > 0 {
            let imgdiscount = UIImageView(frame: CGRect(x: viewPopUp.frame.width/2 + lblCoin.frame.width/2 + 5, y: 170, width: 25.0, height:25.0 ))
            imgdiscount.image = UIImage(named: "discountWhite")
            viewPopUp.addSubview(imgdiscount)
            
            let lbldiscount = UILabel(frame: CGRect(x: viewPopUp.frame.width/2 + lblCoin.frame.width/2 + 5 + 2, y: 170 + 2, width: 20.0, height:20.0 ))
            lbldiscount.text = "\(objConiSelected.discount)%"
            lbldiscount.textAlignment = .center
            lbldiscount.textColor = .black
            lbldiscount.font = UIFont.systemFont(ofSize: 10.0)
            viewPopUp.addSubview(lbldiscount)
        }
        
        
        let btnBuy = UIButton(frame: CGRect(x: viewPopUp.frame.width/2 - 60, y: 223, width: 120, height: 30))
        btnBuy.setBackgroundColor(UIColor.white, forState: .normal)
        btnBuy.setTitle("\(objConiSelected.currencySymbol)\(objConiSelected.amount)", for: .normal)
        btnBuy.setTitleColor(.black, for: .normal)
        btnBuy.layer.cornerRadius = 5.0
        btnBuy.clipsToBounds = true
        btnBuy.addTarget(self, action: #selector(buyAgencyCoinAction), for: .touchUpInside)
        viewPopUp.addSubview(btnBuy)
        
        self.viewPopUpBack.addSubview(viewPopUp)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.viewPopUpBack.addGestureRecognizer(tap)
        
        self.view.addSubview(viewPopUpBack)
        
    }
    
    func removePopupView() {
        for view in viewPopUpBack.subviews {
            view.removeFromSuperview()
        }
        self.viewPopUpBack.removeFromSuperview()
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.removePopupView()
    }
    
    
    @objc func buyAgencyCoinAction() {
        self.removePopupView()
        
        let vc = StoryBoard.coin.instantiateViewController(withIdentifier: "AgencyListViewController") as! AgencyListViewController
        vc.objConiSelected = self.objConiSelected
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func infoBtnAction(){
        
        if #available(iOS 13.0, *) {
            let controller = StoryBoard.premium.instantiateViewController(identifier: "DescriptionPointsVC")
            as! DescriptionPointsVC
            controller.leaderboardType = .agencyCoinInfo
            let useInlineMode = view != nil
            controller.title = ""
            let nav = UINavigationController(rootViewController: controller)
            //            var fixedSize = 500
            //            if UIDevice().hasNotch{
            //                fixedSize = 480
            //            }
            let sheet = SheetViewController(
                controller: nav,
                sizes: [.percent(0.75),.intrinsic],
                options: SheetOptions(presentingViewCornerRadius : 0 , useInlineMode: useInlineMode))
            // addSheetEventLogging(to: sheet)
            sheet.allowGestureThroughOverlay = false
            sheet.cornerRadius = 20
            
            if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
                sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
            } else {
                (AppDelegate.sharedInstance.navigationController?.topViewController)?.present(sheet, animated: true, completion: nil)
            }
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    internal func showPaymentForm(orderId:String){
        let totalAmount = Double(selectedObj.amount) * 100
        
        let options: [String:Any] = [
            "amount": totalAmount, //This is in currency subunits. 100 = 100 paise= INR 1.
            "currency": selectedObj.currency,//We support more that 92 international currencies.
            "description": "Cheer mints",
            "image": "\(pickzonAppLogo)",
            "name": "Pickzon",
            "order_id":"\(orderId)",
            "prefill": [
                "contact": "\(Themes.sharedInstance.GetMyPhonenumber())",
                "email": ""
            ],
            "theme": [
                "color": "#007aff"
            ]
        ]
        razorpay?.open(options)
    }
    //"order_id":"\(Themes.sharedInstance.Getuser_id())_\(obj._id)_\(Date().timeIntervalSinceNow)",
    
    func onPaymentError(_ code: Int32, description str: String) {
        let alertController = UIAlertController(title: "FAILURE", message: str, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.presentView(alertController, animated: true)
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        
        print("payment_id ==== \(payment_id)")
        buyCoinsApi(paymentId:payment_id)
        
        //        let alertController = UIAlertController(title: "Success", message: payment_id, preferredStyle: .alert)
        //        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        //        alertController.addAction(cancelAction)
        //        self.presentView(alertController, animated: true)
        
    }
    
    
    //In App Purchase
    internal func IAPPaymentForm(){
        
        if selectedObj.productId.length > 0 {
            //you need to store all the usable IAP product Ids in an array
            let productIDs:Array<String> = [selectedObj.productId]
            var productsArray:Array<SKProduct> = Array()
            IAPHandler.shared.setProductIds(ids: productIDs)
            Themes.sharedInstance.activityView(View: self.view)
            
            IAPHandler.shared.fetchAvailableProducts { [weak self](products)   in
                DispatchQueue.main.async {
                    Themes.sharedInstance.RemoveactivityView(View: self!.view)
                }
                guard let sSelf = self else {return}
                
                
                productsArray = products
                if productsArray.count > 0 {
                    DispatchQueue.main.async {
                        Themes.sharedInstance.activityView(View: self!.view)
                    }
                    IAPHandler.shared.purchase(product: productsArray[0]) { (alert, product, transaction) in
                        DispatchQueue.main.async {
                            Themes.sharedInstance.RemoveactivityView(View: self!.view)
                        }
                        
                        if let tran = transaction, let prod = product {
                            //use transaction details and purchased product as you want
                            print("transaction: \(transaction)")
                            print("payment_id \(transaction?.transactionIdentifier ?? "")")
                            let payment_id = transaction?.transactionIdentifier ?? ""
                            self?.getInAppReceipt()
                            self?.buyCoinsApi(paymentId:payment_id)
                        }
                        //Show payment successfull messsage
                    }
                }
                
            }
        }
        
    }
    
    
    func getInAppReceipt() {
        // Get the receipt if it's available.
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
           FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            
            
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                print(receiptData)
                
                
                InAppReceipt = receiptData.base64EncodedString(options: [])
                
                print("InAppReceipt :\(InAppReceipt)")
                // Read receiptData.
            }
            catch { print("Couldn't read receipt data with error: " + error.localizedDescription) }
        }
    }
    
}






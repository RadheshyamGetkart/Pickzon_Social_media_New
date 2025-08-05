//
//  AgencyTransactionHistoryVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 8/29/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class AgencyTransactionHistoryVC: UIViewController {
   
    @IBOutlet weak var cnstrntHtNavbar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnPurchaseHistory:UIButton!
    @IBOutlet weak var btnTransferCoins:UIButton!
    @IBOutlet weak var viewSeperator:UIView!
    @IBOutlet weak var lblNavTitle:UILabel!

    var historyType:CoinHistoryType = .agencyTransferHistory
    var listArray = [Any]()
    var pageNumber = 1
    var totalPages = 0
    var isDataLoading = false
    var emptyView:EmptyList?
    var states : Array<Bool>!
    
    
    //MARK: Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavbar.constant = self.getNavBarHt
        emptyView = EmptyList(frame: CGRect(x: 0, y: -64, width: self.view.frame.size.width, height: tblView.frame.size.height))
        emptyView?.imageView?.image = UIImage(named: "pymntSuccessfull")
        self.tblView.addSubview(emptyView!)
        emptyView?.isHidden = true
        registerTableviewCell()
        viewSeperator.frame =  CGRect(x: btnTransferCoins.frame.origin.x, y: btnTransferCoins.frame.origin.y+btnTransferCoins.frame.size.height, width: btnTransferCoins.frame.size.width, height: 2)
        getCoinTransferHistoryApi()
    }
 
    
    func registerTableviewCell(){
        tblView.register(UINib(nibName: "CoinHistoryTblCell", bundle: nil), forCellReuseIdentifier: "CoinHistoryTblCell")
        tblView.register(UINib(nibName: "LoadMoreTblCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTblCell")
        tblView.register(UINib(nibName: "PurchaseHistTblCell", bundle: nil), forCellReuseIdentifier: "PurchaseHistTblCell")
    }
    
    //MARK: Common Button Actions
    @IBAction func backButonAction(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func commonHeaderButonAction(_ sender:UIButton){
        viewSeperator.frame =  CGRect(x: sender.frame.origin.x, y: sender.frame.origin.y+sender.frame.size.height, width: sender.frame.size.width, height: 2)

        switch sender.tag{
        case 1000:
            historyType = .agencyTransferHistory
            self.pageNumber = 1
            getCoinTransferHistoryApi()
            
            break
        case 1001:
            historyType = .purchaseCoinsHistory
            self.pageNumber = 1
            getCoinPurchaseHistoryApi()
            break
            
        default:
            break
        }
        
        //updateUI()
    }
    
    func updateUI(){
        self.tblView.reloadData()
    }
    
    
    
    //MARK: Appi Methods
    func getCoinTransferHistoryApi(){
        
        let params = [:] as [String : Any]
       
        if pageNumber == 1{
            self.listArray.removeAll()
            self.pageNumber = 1
            self.totalPages = 0
            self.tblView.reloadData()
        }
        self.isDataLoading = true
        //    type  : 1 -->> 1 agency purchase cheer coin ||  2 agency transfer cheer coin
        let url = Constant.sharedinstance.coin_get_purchase_coins_transaction_history + "?pageNumber=\(pageNumber)&type=2"
        if pageNumber == 1 {
            Themes.sharedInstance.activityView(View: self.view)
        }
        
        URLhandler.sharedinstance.makeGetCall(url: url, param: params as NSDictionary) {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)

            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                self.totalPages = result["totalPages"] as? Int ?? 0
                
                if status == 1 {
                    
                    if let payload = result["payload"] as? Array<Any>{
                        
                        for dict in payload{
                            self.listArray.append(CheerCoinModel(respDict: dict as! Dictionary<String, Any>))
                        }
                        self.states = [Bool](repeating: true, count: self.listArray.count)

                        self.tblView.reloadData()

                    }
                    self.isDataLoading = false

                    self.pageNumber = self.pageNumber + 1
                }else{
                    self.isDataLoading = false
                }
                
                DispatchQueue.main.async {
                    self.emptyView?.lblMsg?.text = message
                    self.emptyView?.isHidden = (self.listArray.count == 0) ? false :  true
                }
                
            }
        }
    }
    
    
    func getCoinPurchaseHistoryApi(){
        
        let params = [:] as [String : Any]
  
        if pageNumber == 1 {
            self.listArray.removeAll()
            self.pageNumber = 1
            self.totalPages = 0
            self.tblView.reloadData()
            Themes.sharedInstance.activityView(View: self.view)
        }
        self.isDataLoading = true

        let url = Constant.sharedinstance.coin_get_purchase_coins_transaction_history  + "?pageNumber=\(pageNumber)&type=1"
        
       
        URLhandler.sharedinstance.makeGetCall(url: url, param: params as NSDictionary) {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)

            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                self.totalPages = result["totalPages"] as? Int ?? 0
                
                if status == 1 {
                    
                    if let payload = result["payload"] as? Array<Any>{
                        
                        for dict in payload{
                        
                            self.listArray.append(CoinTransactionModel(respDict: dict as! Dictionary<String, Any>))
                        }
                        self.states = [Bool](repeating: true, count: self.listArray.count)
                        self.tblView.reloadData()
                    }
                    self.pageNumber = self.pageNumber + 1
                    self.isDataLoading = false

                }else{
                    self.isDataLoading = false

                }
                
                DispatchQueue.main.async {
                    self.emptyView?.lblMsg?.text = message
                    self.emptyView?.isHidden = (self.listArray.count == 0) ? false :  true
                }
            }
        }
    }

}


extension AgencyTransactionHistoryVC:UITableViewDelegate,UITableViewDataSource{
    
    //MARK: UITableview Delegate & Datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            if self.listArray.count > 15 && pageNumber < totalPages{
                return 1
            }
            return  0
        }
        return  listArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            //Loading cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreTblCell", for: indexPath) as! LoadMoreTblCell
            //cell.lblMessage.isHidden = true
            cell.activityIndicator.startAnimating()
            return cell
        }
        
        if historyType == .agencyTransferHistory {
            
            let cell = tblView.dequeueReusableCell(withIdentifier: "CoinHistoryTblCell") as! CoinHistoryTblCell

            if let obj =  listArray[indexPath.row] as? CheerCoinModel{
                
                cell.lblTransactionType.attributedText = convertAttributtedColorText(text: obj.title)

                cell.lblTransactionType.setLessLinkWith(lessLink: "Read less", attributes: [.foregroundColor:UIColor.red], position: .left)

                cell.lblTransactionType.numberOfLines = 4
                cell.lblTransactionType.delegate = self
                cell.lblTransactionType.shouldCollapse = true
                cell.lblTransactionType.textReplacementType = .word
                if states.count > indexPath.row{
                    cell.lblTransactionType.collapsed = self.states[indexPath.row]
                }
                
                cell.lblTransactionDate.text = obj.createdAt
                cell.lblReferenceNo.text = ""
                cell.imgVwCoin.isHidden = true
                cell.lblCoinValue.isHidden = true

                 if obj.coinsType  == 0 {
                    //Sent
                    cell.lblGiftCoinValue.text =  " – \(obj.coins)"
                    cell.lblGiftCoinValue.textColor = .systemRed
                    cell.imgVwType.image = UIImage(named: "sent")
                    cell.imgVwGiftCoin.image = UIImage(named: "coin1")

                }else if  obj.coinsType  == 1{
                    //Recieved
                    cell.lblGiftCoinValue.text = "+ \(obj.coins)"
                    cell.lblGiftCoinValue.textColor = .systemGreen
                    cell.imgVwType.image = UIImage(named: "received")
                    cell.imgVwGiftCoin.image = UIImage(named: "coin1")

                }else if obj.coinsType  == 2 {
                    //Exchange
                    cell.imgVwType.image = UIImage(named: "exchange")
                    cell.imgVwCoin.isHidden = false
                    cell.lblCoinValue.isHidden = false
                    cell.lblGiftCoinValue.text =  " – \(obj.exchangeCoins)"
                    cell.lblCoinValue.textColor = .systemGreen
                    cell.lblGiftCoinValue.textColor = .systemRed
                    cell.lblCoinValue.text =  " + \(obj.coins)"
                    cell.lblCoinValue.textColor = .systemGreen
                    cell.imgVwGiftCoin.image = UIImage(named: "gift_coin")

                }else if obj.coinsType == 3 {
                    //Withdraw
                    cell.lblGiftCoinValue.text =  " – \(obj.coins)"
                    cell.lblGiftCoinValue.textColor = .systemRed
                    cell.imgVwType.image = UIImage(named: "withdraw1")
                    cell.imgVwGiftCoin.image = UIImage(named: "gift_coin")
                    cell.lblReferenceNo.text = "Ref No. \(obj.referenceId)"
                }
            }

            return cell
            
            
        }else if historyType == .purchaseCoinsHistory {
           
            let cell = tblView.dequeueReusableCell(withIdentifier: "PurchaseHistTblCell") as! PurchaseHistTblCell
            
            if let obj =  listArray[indexPath.row] as? CoinTransactionModel{
                
                cell.lblTitle.text = obj.title
                cell.lblTransactionDate.text = obj.createdAt
                cell.lblCoinValue.text = "\(obj.coins)"
                cell.lblAmount.text =  "\(obj.currencySymbol) \(obj.amount)"
                cell.lblAmount.isHidden = true
                cell.lblTransactionId.text =  "Order ID. \(obj.transactionId)"

                // 0-failed, 1-Success, 2-pending, 3-created by admin
                if  obj.status  == 0{
                    cell.lblStatus.textColor = .systemRed
                    cell.lblStatus.text = "Failed"
                }else if obj.status  == 1 {
                    cell.lblStatus.text = "Success"
                    cell.lblStatus.textColor = .systemGreen
                }else if obj.status  == 2 {
                    cell.lblStatus.text = "Pending"
                    cell.lblStatus.textColor = .systemYellow
               
                }else if obj.status  == 3 {
                    cell.lblStatus.text = "Gifted by PickZon"
                    cell.lblStatus.textColor = .darkGray
                }
            }
            return cell
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //Call API befor the end of all records
        if indexPath.row == listArray.count-1  && listArray.count >= 15{
            if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                
                self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
                
            }else if !isDataLoading {
                isDataLoading = true
                if pageNumber <= totalPages {
                    
                    if historyType == .agencyTransferHistory {
                        getCoinTransferHistoryApi()
                        
                    }else{
                        getCoinPurchaseHistoryApi()
                    }
                }
            }
        }
    }
}



extension AgencyTransactionHistoryVC:ExpandableLabelDelegate{
    
    func convertAttributtedColorText(text:String) -> NSAttributedString{
        
        let  originalStr = text
        let myAttribute = [NSAttributedString.Key.font: UIFont(name: "Roboto-Regular", size: 16.0)!]
       
        let att = NSMutableAttributedString(string: originalStr, attributes: myAttribute)
        
        let detectorType: NSTextCheckingResult.CheckingType = [.link, .phoneNumber]
        
        
        let mentionPattern = "\\B@[A-Za-z0-9_.]+"
        let mentionRegex = try? NSRegularExpression(pattern: mentionPattern, options: [.caseInsensitive])
        let mentionMatches  = mentionRegex?.matches(in: originalStr, options: [], range: NSMakeRange(0, originalStr.utf16.count))
        
        for result in mentionMatches! {
            if let range1 = Range(result.range, in: originalStr) {
                let matchResult = originalStr[range1]
                
                if matchResult.count > 0  {
                    att.addAttributes([NSAttributedString.Key.foregroundColor:Themes.sharedInstance.tagAndLinkColor(),NSAttributedString.Key.font: UIFont(name: "Roboto-Regular", size: 16.0)!], range: result.range)
                }
               // print("result: \(matchResult), range: \(result.range)")
            }
        }
        
        
        let hashtagPattern = "#[^\\s!@#\\$%^&*()=+.\\/,\\[{\\]};:'\"?><]+" //"(^|\\s)#([A-Za-z_][A-Za-z0-9_]*)"
        let regex = try? NSRegularExpression(pattern: hashtagPattern, options: [.caseInsensitive])
        let matches  = regex?.matches(in: originalStr, options: [], range: NSMakeRange(0, originalStr.utf16.count))
        
        for result in matches! {
            if let range1 = Range(result.range, in: originalStr) {
                let matchResult = originalStr[range1]
                
                if matchResult.count > 0  {
                    att.addAttributes([NSAttributedString.Key.foregroundColor:Themes.sharedInstance.tagAndLinkColor(),NSAttributedString.Key.font: UIFont(name: "Roboto-Regular", size: 16.0)!], range: result.range)
                }
               // print("result: \(matchResult), range: \(result.range)")
            }
        }
        
        do {
            let detector = try NSDataDetector(types: detectorType.rawValue)
            let results = detector.matches(in: originalStr, options: [], range: NSRange(location: 0, length:
                                                                                            originalStr.utf16.count))
            for result in results {
                if let range1 = Range(result.range, in: originalStr) {
                    let matchResult = originalStr[range1]
                    
                    if matchResult.count > 0  {
                        att.addAttributes([NSAttributedString.Key.foregroundColor:Themes.sharedInstance.tagAndLinkColor(),NSAttributedString.Key.font: UIFont(name: "Roboto-Regular", size: 16.0)!], range: result.range)
                    }
                   // print("result: \(matchResult), range: \(result.range)")
                }
            }
        } catch {
            print("handle error")
        }
        return att
    }
    
    func numberTextClicked(_ label: ExpandableLabel, number: String) {
        
    }
    
    func hashTagTextClicked(_ label: ExpandableLabel, hashTag: String) {
        let destVc:WallPostViewVC = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
        destVc.controllerType = .hashTag
        destVc.hashTag = hashTag
        AppDelegate.sharedInstance.navigationController?.pushViewController(destVc, animated: true)
    }

    // MARK: ExpandableLabel Delegate
    func willExpandLabel(_ label: ExpandableLabel) {
        tblView.reloadData()
        tblView.beginUpdates()
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        let point = label.convert(CGPoint.zero, to: tblView)
        if let indexPath = tblView.indexPathForRow(at: point) as IndexPath? {
            if states.count > indexPath.row {
                states[indexPath.row] = false
            }
//            DispatchQueue.main.async { [weak self] in
//                self?.tblView.scrollToRow(at: indexPath, at: .none, animated: false)
//            }
        }
        tblView.endUpdates()
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        tblView.beginUpdates()
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        
        let point = label.convert(CGPoint.zero, to: tblView)
        if let indexPath = tblView.indexPathForRow(at: point) as IndexPath? {
            states[indexPath.row] = true
            DispatchQueue.main.async { [weak self] in
                self?.tblView.reloadRows(at: [indexPath], with: .none)
                // self?.tblFeeds.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
        tblView.endUpdates()
    }
    
    func urlTextClicked(_ label: ExpandableLabel,strURL:String) {
        let point = label.convert(CGPoint.zero, to: tblView)
        if let indexPath = tblView.indexPathForRow(at: point) as IndexPath? {
            let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
            vc.urlString = strURL
            AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func mentionTextClicked(_ label: ExpandableLabel,mentionText:String){
        print("mentionTextClicked \(mentionText)")
        let mentionString:String = mentionText
        self.getUserIdFromPickzonId(pickzonId: mentionString.replacingOccurrences(of: "@", with: ""))
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
                        DispatchQueue.main.async {
                            let viewController:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                            viewController.otherMsIsdn = payload["userId"] as? String ?? ""
                            self.navigationController?.pushView(viewController, animated: true)
                        }
                    }else
                    {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        })
    }

}

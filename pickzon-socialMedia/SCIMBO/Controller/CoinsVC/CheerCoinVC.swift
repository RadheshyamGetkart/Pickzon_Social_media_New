//
//  CheerCoinVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/16/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

protocol CoinUpDelegate: AnyObject{
    func cheerCoinClickedOnAvailableTokens()
}

class CheerCoinVC: UIViewController {
    @IBOutlet weak var tblView:UITableView!
    var totalCoins = 0
    var delegate:CoinUpDelegate?
   // var objWallPost:WallPostModel?
    var istoShow  = false
    
    var postId = ""
    var pickzonId = ""
    var type = 0
    var userId = ""
   
    //MARK: Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        getAvailableCoinList()
        let navLabel = UILabel()
        let navTitle = NSMutableAttributedString(string: "Cheer Coins for", attributes:[
            NSAttributedString.Key.foregroundColor: UIColor.label,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.light)])
        navTitle.append(NSMutableAttributedString(string: " @\(pickzonId)", attributes:[
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17.0),
            NSAttributedString.Key.foregroundColor: UIColor.label]))
        navLabel.attributedText = navTitle
        self.navigationItem.titleView = navLabel

        tblView.register(UINib(nibName: "CoinUpTblCell", bundle: nil), forCellReuseIdentifier: "CoinUpTblCell")
        if Themes.sharedInstance.cheerCoinList.count == 0 {
            getCheeredCoinLIst()
        }
        tblView.isScrollEnabled = false
        if #available(iOS 15.0, *) {
            tblView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        tblView.isScrollEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: API Methods
    func getCheeredCoinLIst(){
        
        URLhandler.sharedinstance.makeGetCall(url: Constant.sharedinstance.cheersCoinsList, param: [:]) {(responseObject, error) ->  () in
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]

                if status == 1 {
                    if let payload = result["payload"] as? Array<Any> {
                        
                        for dict in payload{
                            Themes.sharedInstance.cheerCoinList.append(CoinModel(respDict: dict as! Dictionary<String, Any>))
                        }
                        self.tblView.reloadData()
                    }
                        
                }
            }
        }
    }
    
    func getAvailableCoinList(){
        
        Themes.sharedInstance.showActivityViewTop(View: self.parent!.view, isTop: true)

        URLhandler.sharedinstance.makeGetCall(url: Constant.sharedinstance.userCoinInfo, param: [:]) {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.tblView)

            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let msg = result["message"] as? String ?? ""

                if status == 1 {
                    if let payload = result["payload"] as? Dictionary<String, Any> {
                        self.totalCoins = payload["cheerCoins"] as? Int ?? 0
                        self.istoShow = true
                        self.tblView.reloadData()

                        Constant.sharedinstance.razorpay_api_key =  payload["razorpayKey"] as? String ?? ""
                    }
                        
                }else{
                    self.view.makeToast(message: msg , duration: 3, position: HRToastActivityPositionDefault)

                }
            }
        }
    }
    
    func giveCoinToUserApi(obj:CoinModel){
        
//        let params = ["receiverUserId":objWallPost?.userInfo?.fromId ?? "","feedId":postId,"coins":obj.amount,"storyId":""]
        
        var postIdKey = "feedId"
        
        if type == 1{
            //for clip
            postIdKey = "clipId"
        }else if type == 2{
            //for story
            postIdKey = "storyId"
        }

        
        let params = ["receiverUserId":userId,postIdKey:postId,"coins":obj.amount]
        
        
        URLhandler.sharedinstance.makeCall(url: Constant.sharedinstance.give_coins_to_user, param: params as NSDictionary) {(responseObject, error) ->  () in
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1 {
                    /* if let payload = result["payload"] as? Dictionary<String, Any> {
                     
                     if self.sheetViewController?.options.useInlineMode == true {
                     self.sheetViewController?.attemptDismiss(animated: true)
                     } else {
                     self.dismiss(animated: true, completion: nil)
                     }
                     }
                     
                     if let addNewView = Bundle.main.loadNibNamed("CoinUpSuccessAlertView", owner: self, options: nil)?.first as? CoinUpSuccessAlertView {
                     
                     addNewView.initializeMethods(frame: self.parent?.view.frame ?? .zero,message: obj.label, icon: obj.icon)
                     
                     if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                     
                     UIView.animate(withDuration: 0.0, delay: 0.0, options: .transitionFlipFromLeft, animations: {
                     appDelegate.window?.addSubview(addNewView)
                     }, completion: nil)
                     }
                     }*/
                }
            }
        }
        
        dismissViewAndShowSuccessCoinUp(obj:obj)
    }
    
    
    func dismissViewAndShowSuccessCoinUp(obj:CoinModel){
        if !(URLhandler.sharedinstance.isConnectedToNetwork()){
            
            self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
            return
            
        }else{
            if self.sheetViewController?.options.useInlineMode == true {
                self.sheetViewController?.attemptDismiss(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            
            if let addNewView = Bundle.main.loadNibNamed("CoinUpSuccessAlertView", owner: self, options: nil)?.first as? CoinUpSuccessAlertView {
                
                addNewView.initializeMethods(frame: self.parent?.view.frame ?? .zero,message: obj.label, icon: obj.icon)
                
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                    
                    UIView.animate(withDuration: 0.0, delay: 0.0, options: .transitionFlipFromLeft, animations: {
                        appDelegate.window?.addSubview(addNewView)
                    }, completion: nil)
                }
            }
        }

    }
}


extension CheerCoinVC:UITableViewDelegate,UITableViewDataSource,CoinUpTblCellDelegate{
   
    //MARK: CoinUpTblCellDelegate  methods

    func coinGiven(obj: CoinModel, index: Int) {
        if totalCoins < Int(obj.amount) ?? 0{
            
            let msg1 = "You need \((Int(obj.amount) ?? 0)-totalCoins) coins to CoinUp \(obj.label)"
        
            AlertView.sharedManager.presentAlertWith(title: "", msg: msg1 as NSString , buttonTitles: ["Buy Cheer Coins","Cancel"], onController: AppDelegate.sharedInstance.navigationController!) { title, index in
                if index == 0{
                    self.delegate?.cheerCoinClickedOnAvailableTokens()
                    if self.sheetViewController?.options.useInlineMode == true {
                        self.sheetViewController?.attemptDismiss(animated: true)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
           
        }else{
            giveCoinToUserApi(obj:obj)

        }
    }
    
   


    
    
    //MARK: UITableview Delegate & Datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
     
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  250 //290
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "CoinUpTblCell") as! CoinUpTblCell
        cell.lblAvailableCoin.text = "\(totalCoins)"
        if istoShow == true {
            cell.cheerCoinList = Themes.sharedInstance.cheerCoinList
        }else{
            cell.cheerCoinList = [CoinModel]()
        }
        cell.collectionVwCoinUp.reloadData()
        cell.delegate = self
        cell.availableClick.addTarget(self, action:  #selector(availableTokenBtnAction(_ : )), for: .touchUpInside)
        
        return cell
    }
    
    //MARK: - Selector Btn Action
    @objc func availableTokenBtnAction(_ sender : UIButton){
        delegate?.cheerCoinClickedOnAvailableTokens()
        if self.sheetViewController?.options.useInlineMode == true {
            self.sheetViewController?.attemptDismiss(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

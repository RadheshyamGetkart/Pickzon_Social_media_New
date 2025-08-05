//
//  SendGiftVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 8/21/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class SendGiftVC: UIViewController {
    
    @IBOutlet weak var collectionVwNumber:UICollectionView!
    @IBOutlet weak var btnAvailableCoin:UIButton!
    @IBOutlet weak var btnRecharge:UIButton!
    @IBOutlet weak var btnSendGift:UIButton!
    @IBOutlet weak var tblView:UITableView!
    
    var coinOfferArray = [CoinOfferModel]()
    var delegate:CoinUpDelegate?
    var numbers = [1,9,99,199,999]
    var totalCoins = 0
    var istoShow = true
    var roomId = ""
    var pickzonId = ""
    private var selectedGiftIndex = 0
    private var selectedGiftTimes = 0

    //MARK: Controller Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSendGift.layer.cornerRadius = 5.0
        btnSendGift.clipsToBounds = true
        collectionVwNumber.layer.cornerRadius = 5.0
        collectionVwNumber.clipsToBounds = true
        let navLabel = UILabel()
//        let navTitle = NSMutableAttributedString(string: "Gift For \(pickzonId)", attributes:[
//            NSAttributedString.Key.foregroundColor: UIColor.white,
//            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.light)])
       
        let navTitle = NSMutableAttributedString(string: "Gift for", attributes:[
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.light)])
        navTitle.append(NSMutableAttributedString(string: " @\(pickzonId)", attributes:[
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17.0),
            NSAttributedString.Key.foregroundColor: CustomColor.sharedInstance.newThemeColor]))
        navLabel.attributedText = navTitle
        self.navigationItem.titleView = navLabel
        
        
        
        navLabel.attributedText = navTitle
        self.navigationItem.titleView = navLabel
        tblView.register(UINib(nibName: "GiftTblCell", bundle: nil), forCellReuseIdentifier: "GiftTblCell")
        self.view.backgroundColor = Themes.sharedInstance.colorWithHexString(hex: "020507")
       
        self.btnSendGift.isHidden = true

        getAvailableCoinList()
        
        if Themes.sharedInstance.giftCoinList.count == 0{
            getCheeredCoinLIst()
        }
        
        tblView.isScrollEnabled = false
        
    }
    
    //MARK: UIBUtton Action
    @IBAction func rechargeBtnAction(){
        self.delegate?.cheerCoinClickedOnAvailableTokens()
       if self.sheetViewController?.options.useInlineMode == true {
           self.sheetViewController?.attemptDismiss(animated: true)
       } else {
           self.dismiss(animated: true, completion: nil)
       }
    }
    
    @IBAction func sendGiftBtnAction(){
        
        if Themes.sharedInstance.giftCoinList.count > 0{
            
            let obj = Themes.sharedInstance.giftCoinList[selectedGiftIndex]
          
            if totalCoins < ((Int(obj.amount) ?? 0) * numbers[selectedGiftTimes]) {
                
                let msg1 = "You need \(((Int(obj.amount) ?? 0) * numbers[selectedGiftTimes])-totalCoins) coins to send gift \(obj.label)"
                
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
                
//                let param = [
//                    "authToken": Themes.sharedInstance.getAuthToken(),
//                    "roomId":roomId,
//                    "giftId":Themes.sharedInstance.giftCoinList[selectedGiftIndex].id,
//                    "giftTimes":"\(numbers[selectedGiftTimes])"
//                ] as [String : Any]
                
                let param = [
                    "authToken": Themes.sharedInstance.getAuthToken(),
                    "roomId":roomId,
                    "giftId":Themes.sharedInstance.giftCoinList[selectedGiftIndex].giftId,
                    "giftTimes":"\(numbers[selectedGiftTimes])"
                ] as [String : Any]
                SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_send_gift_pk  , param)
             
                if self.sheetViewController?.options.useInlineMode == true {
                    self.sheetViewController?.attemptDismiss(animated: true)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
 
    
    //MARK: API Methods
    func getCheeredCoinLIst(){
        
        let url = Constant.sharedinstance.cheersCoinsList + "?type=1"
        URLhandler.sharedinstance.makeGetCall(url: url, param: [:]) {(responseObject, error) ->  () in
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                //let message = result["message"] as? String ?? ""

                if status == 1 {
                    if let payload = result["payload"] as? Array<Any> {
                        
                        for dict in payload{
                            Themes.sharedInstance.giftCoinList.append(CoinModel(respDict: dict as! Dictionary<String, Any>))
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
                        self.btnAvailableCoin.setTitle("\(payload["cheerCoins"] as? Int ?? 0)" , for: .normal)
                        self.tblView.reloadData()
                        self.btnSendGift.isHidden = false
                        Constant.sharedinstance.razorpay_api_key =  payload["razorpayKey"] as? String ?? ""
                    }
                        
                }else{
                    self.view.makeToast(message: msg , duration: 3, position: HRToastActivityPositionDefault)

                }
            }
        }
    }
}

extension SendGiftVC:UITableViewDelegate,UITableViewDataSource,CoinUpTblCellDelegate{
   
  
  
    //MARK: CoinUpTblCellDelegate  methods
    func coinGiven(obj:CoinModel,index:Int){
                
        selectedGiftIndex = index
    }
    
    //MARK: UITableview Delegate & Datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
     
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  220 // 290
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "GiftTblCell") as! GiftTblCell
        cell.giftCoinList = Themes.sharedInstance.giftCoinList
        cell.collectionVw.reloadData()
        cell.delegate = self
     
        return cell
    }
    
}

extension SendGiftVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return numbers.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NumberCollectionCell", for: indexPath) as! NumberCollectionCell
        cell.lblTitle.text = "\(numbers[indexPath.item])"
        cell.lblTitle.layer.cornerRadius = 5.0
        cell.lblTitle.clipsToBounds = true
        if selectedGiftTimes == indexPath.item {
            cell.lblTitle.backgroundColor = .darkGray
        }else{
            cell.lblTitle.backgroundColor = .clear
        }
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedGiftTimes = indexPath.item
        self.collectionVwNumber.reloadData()
     
    }
    
    //MARK: - Follow Btn Action
        
}


class NumberCollectionCell:UICollectionViewCell{
    
    @IBOutlet weak var lblTitle:UILabel!
    
     override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

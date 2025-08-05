//
//  CreateBoostVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/3/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher
import FittedSheets

class CreateBoostVC: UIViewController {

    @IBOutlet weak var popupBgVw:UIView!
    @IBOutlet weak var lblPopupMsg:UILabel!
    @IBOutlet weak var imgVwPost:UIImageView!
    @IBOutlet weak var lblPostDate:UILabel!
    @IBOutlet weak var lblPayCoin:UILabel!
    @IBOutlet weak var btnPay:UIButton!
    @IBOutlet weak var lblTerms:UILabel!
    @IBOutlet weak var btnInfo:UIButton!
    @IBOutlet weak var tblView:UITableView!
   
    var availableCoin = 0
    var objWallpost:WallPostModel?
    var selectedIndex = -1
    var listArray = [BoostPlans]()
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        tblView.register(UINib(nibName: "BoostPackTblCell", bundle: nil), forCellReuseIdentifier: "BoostPackTblCell")
        getAvailablePlansApi()
        self.getAvailableCoinsApi()
        self.btnPay.setGradientColork(colorLeft: Themes.sharedInstance.colorWithHexString(hex: "18409E"), colorRight: Themes.sharedInstance.colorWithHexString(hex: "0866FF"), titleColor: .white, cornerRadious: 5.0, image: "", title: "Pay")  
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear CreateBoostVC")
    }
    
    
    func initialSetup(){
        btnInfo.setImageTintColor(.label)
        imgVwPost.layer.cornerRadius = 8.0
        imgVwPost.clipsToBounds = true
        btnPay.layer.cornerRadius = 8.0
        btnPay.clipsToBounds = true
        popupBgVw.isHidden = true
        
        let string = NSMutableAttributedString(string: "By continuing, you agree to the PickZon Boost Post Program and the Payment terms")// and Advertising Policy")
        string.setColorForText("By continuing, you agree to the", with: Themes.sharedInstance.colorWithHexString(hex: "#808080"))
        string.setColorForText("PickZon Boost Post Program and the Payment terms", with: UIColor.label)
     //   string.setColorForText("and", with: Themes.sharedInstance.colorWithHexString(hex: "#bfc9db"))
        //string.setColorForText("Advertising Policy", with: UIColor.label)
        
//        let diff = string.length - ("and Advertising Policy").length
//        let range1:NSRange = NSRange(location: diff, length: 3)
//        if  range1 != nil {
//            
//        string.addAttribute( NSAttributedString.Key.foregroundColor, value: Themes.sharedInstance.colorWithHexString(hex: "#808080"), range: range1)
//        }
        lblTerms.attributedText = string
        
        if let strUrl = objWallpost?.thumbUrlArray.first{
            self.imgVwPost.kf.setImage(with: URL(string: strUrl), placeholder: PZImages.dummyCover, options: [.processor(DownsamplingImageProcessor(size: self.imgVwPost.frame.size)),.scaleFactor(UIScreen.main.scale)], progressBlock: nil) { response in}
        }
        
        let dateFormatter =  DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        lblPostDate.text = "Posted on \(dateFormatter.string(from: objWallpost?.createdAt ?? Date()))"
    }
    
    
   
    //MARK: UIButton action methods
    
    @IBAction func infoBtnActionMethods(_ sender : UIButton){
      
        if #available(iOS 13.0, *) {
            let controller = StoryBoard.promote.instantiateViewController(identifier: "GuideLinesVC")
            as! GuideLinesVC
            controller.guidelinesType = .boost
            controller.title = ""
            let useInlineMode = view != nil
            let nav = UINavigationController(rootViewController: controller)
            let sheet = SheetViewController(
                controller: nav,
                sizes: [.percent(0.75),.intrinsic],
                options: SheetOptions(presentingViewCornerRadius : 0 , useInlineMode: useInlineMode))
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
    
    
    
  
    
    @IBAction func popupDoneBtnActionMethods(_ sender : UIButton){
        
        var isFound = false
        for controller in (AppDelegate.sharedInstance.navigationController!.viewControllers as Array).reversed() {
            
            if  controller.isKind(of: MoreSettingVC.self) || controller.isKind(of: WallPostViewVC.self) || controller.isKind(of: FeedsViewController.self)  {
                isFound = true
                AppDelegate.sharedInstance.navigationController?.popToViewController(controller, animated: false)
                break
            }
        }
        if isFound == false {
            AppDelegate.sharedInstance.navigationController?.popViewController(animated: true)
        }
    }
    
   
    @IBAction func payBtnActionMethods(_ sender : UIButton){
        if selectedIndex >= 0 {
            if   availableCoin >= listArray[selectedIndex].coins{
                boostPostApi()
            }else{
                let destVC:WalletVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
                destVC.delegateWallet = self
                AppDelegate.sharedInstance.navigationController?.pushViewController(destVC, animated: true)
            }
        }
    }

    
    //MARK: API Methods
    
    func boostPostApi(){
        
        let params = ["feedId":(objWallpost?.id ?? ""),"id":(listArray[selectedIndex].id)]
   
        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: true)
      
        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.boost_boost_post, param: params as NSDictionary) { (responseObject, error) ->  () in
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)

            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let msg = result["message"] as? String ?? ""

                if status == 1 {
                    self.popupBgVw.isHidden = false
                    self.lblPopupMsg.text = msg
                    
                    let objDict = ["feedId":(self.objWallpost?.id ?? ""), "boost":1] as [String : Any]
                    NotificationCenter.default.post(name: noti_Boosted, object: objDict)

                }else{
                    self.view.makeToast(message: msg , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
    }
    
    
    func getAvailablePlansApi(){
        
        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: true)

        URLhandler.sharedinstance.makeGetCall(url: Constant.sharedinstance.get_boost_plan_list, param: [:]) {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)

            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let msg = result["message"] as? String ?? ""

                if status == 1 {
                    if let payload = result["payload"] as? Dictionary<String,Any> {
                      
                        if let data = payload["data"] as? Array<Dictionary<String,Any>> {
                            
                            var index = 0
                            var isFound = false
                            for dict in data{
                                let obj = BoostPlans(respDict: dict)
                                
                                if obj.isRecommended == 2{
                                    self.selectedIndex = index
                                    self.lblPayCoin.text = "\(obj.coins)"
                                    isFound = true
                                }else if obj.isRecommended == 1 && isFound == false{
                                    self.selectedIndex = index
                                    self.lblPayCoin.text = "\(obj.coins)"
                                    isFound = true
                                }
                                self.listArray.append(obj)
                                index = index + 1
                            }
                            self.tblView.reloadData()
                            
                        }
                    }
                }else{
                    self.view.makeToast(message: msg , duration: 3, position: HRToastActivityPositionDefault)

                }
            }
        }
    }
    
    func getAvailableCoinsApi(){
        
        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: true)

        URLhandler.sharedinstance.makeGetCall(url: Constant.sharedinstance.userCoinInfo, param: [:]) {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)

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
                        self.availableCoin = payload["cheerCoins"] as? Int ?? 0
                        self.tblView.reloadData()
                    }
                        
                }else{
                    self.view.makeToast(message: msg , duration: 3, position: HRToastActivityPositionDefault)

                }
            }
        }
    }
}


extension  CreateBoostVC : UITableViewDelegate,UITableViewDataSource,WalletDelegate{
    
        
    func coinupdateBalance(){
        getAvailableCoinsApi()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return listArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if listArray.count ==  indexPath.row{
            return 65
        }
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoostPackTblCell", for: indexPath) as! BoostPackTblCell
        cell.bgView.layer.cornerRadius = 8.0
        cell.bgView.layer.borderColor = UIColor.systemBlue.cgColor
        cell.bgView.layer.borderWidth = 1.0
        cell.bgView.clipsToBounds = true
      
        if listArray.count ==  indexPath.row {
            
            cell.imgVwClipIcon.isHidden = true
            cell.lblVIewCount.isHidden = true
            cell.cnstrntLeadingClipImg.constant = -35
            cell.lblCoin.text = "\(availableCoin)"
            cell.lblTitle.text = "Ad Coin Balance"
            cell.lblRecommended.isHidden = true
            cell.lblCoin.textColor = ( self.availableCoin == 0 ) ? .red : .systemGreen
            cell.lblTitle.font = UIFont(name: "Roboto-Medium", size: 16.0)
        }else{
            cell.lblVIewCount.isHidden = false
            cell.cnstrntLeadingClipImg.constant = 10
            cell.lblTitle.text = listArray[indexPath.row].description
            cell.lblCoin.text = "\(listArray[indexPath.row].coins)"
            cell.lblVIewCount.text = "\(listArray[indexPath.row].views)+"
            cell.lblRecommended.isHidden =  (listArray[indexPath.row].isRecommended == 1) ? false : true
           
            /*
             You will get "isRecommended: 2" to show the "Special Offer" tag...
             isRecommended: 0   - Nothing to show
             isRecommended: 1   - Recommended to show
             isRecommended: 2   - Special Offer to show
             */
            if listArray[indexPath.row].isRecommended == 1 {
               
                cell.lblRecommended.isHidden = false
                cell.lblRecommended.text = "Recommended"
                cell.lblRecommended.backgroundColor = .systemBlue
                
            }else if listArray[indexPath.row].isRecommended == 2{
                cell.lblRecommended.isHidden = false
                cell.lblRecommended.text = "Special Offer"
                cell.lblRecommended.backgroundColor = Themes.sharedInstance.colorWithHexString(hex: "#148F00")

            }else{
                cell.lblRecommended.isHidden = true
            }
            
            cell.lblCoin.textColor = .label
            cell.lblTitle.font = UIFont(name: "Roboto-Regular", size: 16.0)
            cell.imgVwClipIcon.isHidden = false
        }
        
        cell.lblTitle.textColor = .label
        cell.lblVIewCount.textColor = .label
        cell.imgVwClipIcon.setImageColor(color: .label)
        if selectedIndex == indexPath.row{
            cell.bgView.backgroundColor = Themes.sharedInstance.colorWithHexString(hex: "#0866FF").withAlphaComponent(0.5)
        }else{
            cell.bgView.backgroundColor = .clear
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < listArray.count{
            selectedIndex = indexPath.row
            self.lblPayCoin.text = "\(listArray[selectedIndex].coins)"

            self.tblView.reloadData()
        }
    }
}



extension NSMutableAttributedString{
    func setColorForText(_ textToFind: String, with color: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
    }
}




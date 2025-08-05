//
//  PurchaseAvatarFrameVC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 4/22/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit


protocol PurchaseAvatarDelegate{
    func purchasedAvatarEntry(svgaUrl:String)
}

class PurchaseAvatarFrameVC: UIViewController {
    
    @IBOutlet weak var tblPlans:UITableView!
    @IBOutlet weak var collectionVw:UICollectionView!
    @IBOutlet weak var btnClose:UIButton!
    @IBOutlet weak var lblAvailableCoin:UILabel!
    @IBOutlet weak var profilePicVw:ImageWithSvgaFrame!
    @IBOutlet weak var cnstrntWidthPicVw:NSLayoutConstraint!
    @IBOutlet weak var cnstrntHeightPicVw:NSLayoutConstraint!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblDesc:UILabel!
    @IBOutlet weak var lblAvailablecoinDesc:UILabel!

    var selectedIndex = 0
    var availableCoin = 0
    var pickzonUser = PickzonUser(respdict: [:])
    var delegate:PurchaseAvatarDelegate?
    var isAvatarPurchase = true
    var svgaURL = ""
    var planArray = [Plans]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        collectionVw.backgroundView?.backgroundColor = .white
        collectionVw.backgroundColor = .white
        btnClose.setImageTintColor(.darkGray)
        collectionVw.register(UINib(nibName: "AvatarPlanCVCell", bundle: nil), forCellWithReuseIdentifier: "AvatarPlanCVCell")
        profilePicVw.initializeView()

        if isAvatarPurchase == true {
            profilePicVw.setImgView(profilePic:  pickzonUser.profilePic, remoteSVGAUrl:  svgaURL,changeValue: 17)

        }else{
            profilePicVw.setImgView(profilePic: "", remoteSVGAUrl:  svgaURL)
            profilePicVw.imgVwProfile?.isHidden = true
            cnstrntWidthPicVw.constant = 320
            profilePicVw.remoteSVGAPlayer?.frame = CGRect(x:  (profilePicVw.remoteSVGAPlayer?.frame.origin.x ?? 0)+20, y:  profilePicVw.remoteSVGAPlayer?.frame.origin.y ?? 0, width: 320, height:  profilePicVw.remoteSVGAPlayer?.frame.size.height ?? 0)
            profilePicVw.remoteSVGAPlayer?.contentMode = .scaleAspectFit
            
            let para = NSMutableParagraphStyle()
            para.lineBreakMode = .byTruncatingTail
            para.alignment = .left
            
            let shadow = NSShadow()
            shadow.shadowOffset = CGSize(width: 1.0, height: 1.0)
            shadow.shadowBlurRadius = 0.0
            shadow.shadowColor = UIColor.black
            
            let str = NSAttributedString(
                string: "\(pickzonUser.pickzonId)",
                attributes: [
                    .font: UIFont(name: "Amaranth-Bold", size: 40.0)!,
                    .foregroundColor: UIColor.white,.shadow:shadow,
                    .paragraphStyle: para,
                ])
            self.profilePicVw.remoteSVGAPlayer?.setAttributedText(str, forKey: "name")
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAvailableCoinsApi()
    }
   
    
    //MARK: UIButton Action Methods
    @IBAction func availableCoinBtnAction(sender:UIButton){
        let viewController:WalletVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
        viewController.isGiftedCoinsTabOpen = false
        self.navigationController?.pushView(viewController, animated: true)
    }
    
    @IBAction func purchaseCoinBtnAction(sender:UIButton){
        if planArray.count >= selectedIndex {
            let obj = planArray[selectedIndex]
            
            if obj.coins <= availableCoin{
                
                purchaseAvatrApi(planId: obj._id)
           
            }else{
                let viewController:WalletVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
                viewController.isGiftedCoinsTabOpen = false
                self.navigationController?.pushView(viewController, animated: true)
            }
        }
    }
    
    
    @IBAction func closeBtnAction(sender:UIButton){
        if self.sheetViewController?.options.useInlineMode == true {
            self.sheetViewController?.attemptDismiss(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
  
    //MARK: Api methods
    
    func purchaseAvatrApi(planId:String){
        let params = ["planId":planId]
        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: true)

        URLhandler.sharedinstance.makeCall(url: Constant.sharedinstance.buy_avatar, param: params as NSDictionary) {(responseObject, error) ->  () in
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
                  
                   /* AlertView.sharedManager.presentAlertWith(title: "", msg: msg as NSString, buttonTitles: ["OK"], onController: self, dismissBlock: {(title,index) in
                    */
                    self.delegate?.purchasedAvatarEntry(svgaUrl: self.svgaURL)
                    
                        if self.sheetViewController?.options.useInlineMode == true {
                            self.sheetViewController?.attemptDismiss(animated: true)
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                   // })
                        
                }else{
                    self.view.makeToast(message: msg , duration: 3, position: HRToastActivityPositionDefault)

                }
            }
        }
    }
    
    
    
    func checkAndUpdateColor(){
        
        if planArray.count > selectedIndex{
            
            if self.availableCoin == 0 || (planArray[selectedIndex].coins > availableCoin){
                self.lblAvailablecoinDesc.textColor = .red
            }else{
                self.lblAvailablecoinDesc.textColor = .systemGreen
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
                        self.lblAvailableCoin.text = "\(self.availableCoin)"
                       
                        self.checkAndUpdateColor()
                            
                            
                    }
                        
                }else{
                    self.view.makeToast(message: msg , duration: 3, position: HRToastActivityPositionDefault)

                }
            }
        }
    }
}


extension PurchaseAvatarFrameVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return   planArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarPlanCVCell", for: indexPath) as! AvatarPlanCVCell
        
        let obj = planArray[indexPath.item]
        let appendStr = obj.day > 1 ? "days" : "day"
        cell.lblDay.text = "\(obj.day) \(appendStr)"
        cell.lblCoin.text = "\(obj.coins)"
        
        if selectedIndex == indexPath.item{
            cell.bgVw.layer.borderColor = UIColor.link.cgColor
            cell.bgVw.layer.borderWidth = 2.0
            cell.imgVwNotch.isHidden = false
            cell.bgVw.layer.cornerRadius = 5.0
            cell.bgVw.clipsToBounds = true
            cell.bgVw.backgroundColor = Themes.sharedInstance.colorWithHexString(hex: "CCE4FF")
            
        }else{
            
            cell.imgVwNotch.isHidden = true
            cell.bgVw.layer.borderColor = UIColor.clear.cgColor
            cell.bgVw.backgroundColor = Themes.sharedInstance.colorWithHexString(hex: "F8F8FA")
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 100, height: 100 )
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.item
        collectionVw.reloadData()
        checkAndUpdateColor()
    }
}



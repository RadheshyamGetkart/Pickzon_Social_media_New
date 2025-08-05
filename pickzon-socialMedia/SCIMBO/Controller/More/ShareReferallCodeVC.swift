//
//  ShareReferallCodeVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 8/8/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class ShareReferallCodeVC: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblReferalCode: UILabel!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var btnHowCanEarn: UIButton!
    @IBOutlet weak var bgViewReferalCode:UIView!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnShare: UIButton!
    var howToEarnUrl = ""
    var strReferralCode = ""
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        bgViewReferalCode.addDashBorder(color: UIColor.white)
        btnShare.layer.cornerRadius = btnShare.frame.size.height/2.0
        btnShare.clipsToBounds = true
        btnShare.setImageTintColor(.darkGray)
        getDetailsApi()
        
    }
    
    //MARK: APi Methods
    func getDetailsApi(){
        
        let params = NSMutableDictionary()
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeGetCall(url:Constant.sharedinstance.get_referral_content, param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    
                    if let  payloadDict = result["payload"] as? NSDictionary {
                        
                        self.howToEarnUrl = payloadDict["howToEarnUrl"] as? String ?? ""
                        self.strReferralCode = payloadDict["referralCode"] as? String ?? ""
                        
                        DispatchQueue.main.async {
                            self.lblReferalCode.text = self.strReferralCode
                            self.lblTitle.text = payloadDict["title"] as? String ?? ""
                            self.lblSubTitle.text = payloadDict["subTitle"] as? String ?? ""
                            
                        }
                        
                        
                    }
                }else{
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        })
    }
    //MARK: - UIButton Action Methods
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareBtnAction(_ sender: UIButton){
        
        let appStoreLink = "Use this code during signup (Referal Code: \(strReferralCode)) to claim your bonus instantly.\nDownload PickZon app & stay entertained! \nhttps://www.pickzon.com/apps"
        
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
    
    
    @IBAction func scanQRCodeBtnAction(_ sender: UIButton) {
        let viewController:ShareQRCodeReferralVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "ShareQRCodeReferralVC") as! ShareQRCodeReferralVC
        viewController.referralCode = strReferralCode
        viewController.userId = Themes.sharedInstance.Getuser_id()
        self.navigationController?.pushView(viewController, animated: true)
    }
    
    @IBAction func copyReferalCodebTnAction(_ sender: UIButton) {
        UIPasteboard.general.string = strReferralCode
        self.view.makeToast(message: "Referal Code: \(strReferralCode) has been copied to clipboard.", duration: 3, position: HRToastActivityPositionDefault)
    }
    
    @IBAction func howToEarnbTnAction(_ sender: UIButton) {
        
        let destVC:PrivacyPolicyViewController = StoryBoard.main.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
        destVC.strTitle = "How To Earn Coins"
        destVC.strURl = howToEarnUrl
        self.navigationController?.pushView(destVC, animated: true)
        
    }
}


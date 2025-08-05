//
//  PrivacyTermsVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 3/20/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class PrivacyTermsVC: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var cnstrntHtNavBar: NSLayoutConstraint!
    var listArray = [String]()
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        self.tblView.register(UINib(nibName: "SettingTblCell", bundle: nil), forCellReuseIdentifier: "SettingTblCell")
        listArray = ["User Verification Policy","Privacy Policy","Terms & Conditions","FAQ"]   
    }

    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension PrivacyTermsVC:UITableViewDelegate,UITableViewDataSource{

    //MARK: UITableview Delegate & Datasource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
  
        return 55
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return listArray.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTblCell") as! SettingTblCell
        cell.cnstrntWidthImgVwIcon.constant = 0
        cell.lblTitle.text = listArray[indexPath.item]
        cell.btnSwitch.isHidden = true
        cell.btnBAck.isHidden = true
        cell.imgViewIcon.isHidden = true
      
        return cell
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let strTitle = listArray[indexPath.row]
        
           if strTitle == "Terms & Conditions" {
             
             let destVC:PrivacyPolicyViewController = StoryBoard.main.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
             destVC.strTitle = "Terms & Conditions"
             destVC.strURl = Constant.sharedinstance.termsURL
             print(Constant.sharedinstance.termsURL)
             self.navigationController?.pushView(destVC, animated: true)
             
             
             }else if strTitle == "Privacy Policy" {
             
             let destVC:PrivacyPolicyViewController = StoryBoard.main.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
             destVC.strTitle = "Terms and Privacy Policy"
             destVC.strURl = Constant.sharedinstance.privacyURL
             print(Constant.sharedinstance.privacyURL)
             self.navigationController?.pushView(destVC, animated: true)
             
             }else if strTitle == "User Verification Policy" {
             
             let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
             vc.urlString = Constant.sharedinstance.userGreenBadgePolicyURL
             self.navigationController?.pushViewController(vc, animated: true)
             
             }else if strTitle == "Page Verification Policy" {
             
             let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
             vc.urlString = Constant.sharedinstance.pageVerificationPolicyURL
             self.navigationController?.pushViewController(vc, animated: true)
             
             }else if strTitle == "FAQ" {
             
             let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
             vc.urlString = Constant.sharedinstance.faqURL
             self.navigationController?.pushViewController(vc, animated: true)
             }
            
        }
        
            
    func shareApp(){
        
//  let appStoreLink = "Download PickZon app & stay entertained! \nIOS App: https://apps.apple.com/in/app/pickzon/id1560097730 \n Android App: https://play.google.com/store/apps/details?id=com.chat.pickzon"
        
        let appStoreLink = "Download PickZon app & stay entertained! \n https://www.pickzon.com/apps"
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
    
}


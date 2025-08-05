//
//  MoreSettingVC.swift
//  SCIMBO
//
//  Created by Getkart on 03/07/21.
//  Copyright © 2021 GETKART. All rights reserved.
//https://www.kodeco.com/9009-requesting-app-ratings-and-reviews-tutorial-for-ios

import UIKit
import Kingfisher
import SwiftRater

class MoreSettingVC: UIViewController {
    
    @IBOutlet weak var btnBack:UIButtonX!
    @IBOutlet weak var settingTblView: UITableView!
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var cnstrntHtNavBar: NSLayoutConstraint!
    var objUser = PickzonUser(respdict: [:])

    var listArray = [String]()
    var listImgArray = [String]()
    private var isToRefreshApi = false
     
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        self.settingTblView.register(UINib(nibName: "SettingTblCell", bundle: nil), forCellReuseIdentifier: "SettingTblCell")
        listArray = ["My Wallet","Profile","Professional Dashboard","Create an Ad","Ads Dashboard","Notifications Settings","Dark Mode","Saved Posts","Share Profile","Blocked User List","Friend Request List","Privacy & Terms","Contact Us","Share App"]
        listImgArray = ["wallet1","mProfile","professionalDashboard","adIconBlack","adsDashboard","notiIcon","dark-mode","saveIcon","share_profile","blockUser","friendRequest","privacyTerms","contactus24*7","mShare"]
        lblVersion.text = "Version - \(Themes.sharedInstance.getAppVersion())"
        self.getUserInfoDetails()
    }
    
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       if Settings.sharedInstance.isAppRatingAvailable == 1{
            SwiftRater.check()
        }
    }
  
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isToRefreshApi{
            self.getUserInfoDetails()
        }
    }
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func postComment() {
        // do something ..

        SwiftRater.incrementSignificantUsageCount()
    }
    
    func rateButtonDidClick(sender: UIButton) {
        // do something ..
        SwiftRater.rateApp(host: self)
    }
    
    //MARK: Api Methods
    func getUserInfoDetails(){
        
        let url = "\(Constant.sharedinstance.showUserInfo)/\(Themes.sharedInstance.Getuser_id())"
        
        URLhandler.sharedinstance.makeGetCall(url: url, param: NSDictionary()) { [weak self] (responseObject, error) ->  () in
            self?.isToRefreshApi = false
            if(error != nil)
            {
                self?.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                self?.updateData(result: result)
            }
        }
    }
   
    func updateData(result:NSDictionary){
        
        let status = result["status"] as? Int ?? 0
        let message = result["message"] as? String ?? ""

        if status == 1 {
            if let payloadDict = result["payload"] as? NSDictionary {
                self.objUser = PickzonUser(respdict: payloadDict)
            }
                     
            if (self.objUser.usertype == 1) {
                self.listArray = ["My Wallet","Profile","Professional Dashboard","Create an Ad","Ads Dashboard","Notifications Settings","Dark Mode","Saved Posts","Share Profile","Blocked User List","Friend Request List","Privacy & Terms","Contact Us","Share App"]
                self.listImgArray = ["wallet1","mProfile","professionalDashboard","adIconBlack","adsDashboard","notiIcon","dark-mode","saveIcon","share_profile","blockUser","friendRequest","privacyTerms","contactus24*7","mShare"]
            }else{
                self.listArray = ["My Wallet","Profile","Professional Dashboard","Create an Ad","Ads Dashboard","Notifications Settings","Dark Mode","Saved Posts","Share Profile","Blocked User List","Privacy & Terms","Contact Us","Share App"]
                self.listImgArray = ["wallet1","mProfile","professionalDashboard","adIconBlack","adsDashboard","notiIcon","dark-mode","saveIcon","share_profile","blockUser","privacyTerms","contactus24*7","mShare"]
            }
            
            self.settingTblView.reloadData()
            if  self.objUser.profilePic.count > 0 && Themes.sharedInstance.Getuser_id() == self.objUser.id {
                let user_ID = Themes.sharedInstance.Getuser_id()
                let CheckUser:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString:user_ID as String?)
                if (!CheckUser){
               
                }else{
                    let UpdateDict:[String:Any]=["profilepic": self.objUser.profilePic, "mobilenumber":"\(self.objUser.mobileNo)"]
                    
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail , FetchString: user_ID, attribute:"user_id" , UpdationElements: UpdateDict as NSDictionary?)
                }
            }
            
                DBManager.shared.insertOrUpdateUSerDetail(userId: self.objUser.id, userObj: self.objUser)
                Themes.sharedInstance.savePickZonID(pickzonId: self.objUser.pickzonId)
            
            
        }
    }
   //MARK:  UIButtton Action Methods

    
    func navigateToViewController(section:Int, row:Int) {
      /*  let arroptions = arrMoreData[section]["options"] as? Array<String> ?? []
        let strTitle = arrMoreData[section]["title"] as? String ?? ""
        if arroptions.count == 0 {
            
             if strTitle == "Mall Settings"{
                
               
            }else if strTitle == "Settings"{
                
                let destVc:UIViewController = StoryBoard.main.instantiateViewController(withIdentifier: "FeedSettingVC") as! FeedSettingVC
                self.navigationController?.pushViewController(destVc, animated: true)
            }else if strTitle == "Notification Settings" {
                let destVc:NotificationSettingsVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "NotificationSettingsVC") as! NotificationSettingsVC
                self.navigationController?.pushViewController(destVc, animated: true)
            }else if strTitle == "Saved Posts"{
                
                let destVc:WallPostViewVC = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
                destVc.controllerType = .isFromSaved
                self.navigationController?.pushViewController(destVc, animated: true)
            }else if strTitle == "Contact Us"{
                
                let destVC:ContactUSViewController = StoryBoard.feeds.instantiateViewController(withIdentifier: "ContactUSViewController") as! ContactUSViewController
                self.navigationController?.pushView(destVC, animated: true)
            }else if strTitle == "Refer & Earn" {
               
                if  Themes.sharedInstance.getIsReferAvailable() as? Int ?? 0 == 1 {
                    let destVC:ReferalsViewController = StoryBoard.feeds.instantiateViewController(withIdentifier: "ReferalsViewController") as! ReferalsViewController
                    self.navigationController?.pushView(destVC, animated: true)
                }else if Themes.sharedInstance.getIsCoinReferAvailable() as? Int ?? 0 == 1 {
                    //Coin Refer available
                    let destVC:ShareReferallCodeVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "ShareReferallCodeVC") as! ShareReferallCodeVC
                    self.navigationController?.pushView(destVC, animated: true)
                }else {
                    shareApp()
                }
                
            }else if strTitle == "Share App" {
                    shareApp()
            } else if strTitle == "Jobs" {
                let destVc:UIViewController = StoryBoard.job.instantiateViewController(withIdentifier: "JobsHomeVC") as! JobsHomeVC
                self.navigationController?.pushViewController(destVc, animated: true)
            }
            
            
        }else {
            //To show the options for 0 th row in case of options avaialable
            if row == -1 {
                let btnOption = UIButton()
                btnOption.tag = section
                showDetail(sender: btnOption)
                
            }else  if strTitle == "Profile" {
                let subTitle = arroptions[row]
                if subTitle == "My Profile"{
                    let profileVC:UIViewController = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                    self.navigationController?.pushViewController(profileVC, animated: true)
                }else if subTitle == "Change Mobile Number"{
                    
                   /* let changeNoVC = StoryBoard.prelogin.instantiateViewController(withIdentifier:"ChangeNumberViewController" ) as! ChangeNumberViewController
                    self.pushView(changeNoVC, animated: true)
                    */
                    
                    let viewController:VerifyEmailAndPhone = StoryBoard.prelogin.instantiateViewController(withIdentifier: "VerifyEmailAndPhone") as! VerifyEmailAndPhone
                    viewController.isEmail = false
                    //viewController.delegateVerifyEmailPhone = self
                    self.navigationController?.pushView(viewController, animated: true)
                    
                }else if subTitle == "Change Password"{
                    let changeNoVC = StoryBoard.prelogin.instantiateViewController(withIdentifier:"ChangePasswordVC" ) as! ChangePasswordVC
                    self.pushView(changeNoVC, animated: true)
                } else if subTitle == "Verification Request" {
                let changeNoVC = StoryBoard.feeds.instantiateViewController(withIdentifier:"RequestVerificationViewController" ) as! RequestVerificationViewController
                
                self.pushView(changeNoVC, animated: true)
            }else if subTitle == "PickZon Web Login" {
                
                let mediaType:AVMediaType = AVMediaType.video;
                let avStatus:AVAuthorizationStatus=AVCaptureDevice.authorizationStatus(for: mediaType)
                
                if(avStatus == AVAuthorizationStatus.authorized)
                {
                    DispatchQueue.main.async {
                        let QrcodeVC = self.storyboard?.instantiateViewController(withIdentifier:"QrcodeViewControllerID" ) as! QrcodeViewController
                        self.pushView(QrcodeVC, animated: true)
                    }
                }else  if(avStatus == AVAuthorizationStatus.notDetermined) {
                    
                    AVCaptureDevice.requestAccess(for: mediaType, completionHandler: { (isGivenpermission
                                                                                        :Bool) in
                        
                        if(!isGivenpermission)
                        {
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }
                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                })
                            }
                        }
                        else
                        {
                            print("asda")
                            DispatchQueue.main.async {
                                let QrcodeVC = self.storyboard?.instantiateViewController(withIdentifier:"QrcodeViewControllerID" ) as! QrcodeViewController
                                self.pushView(QrcodeVC, animated: true)
                            }
                            
                            
                            
                        }
                    })
                    
                } else  if(avStatus == AVAuthorizationStatus.denied)
                {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        })
                    }
                }else if(avStatus == AVAuthorizationStatus.restricted)
                {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        })
                    }
                }
                
                
            }else if subTitle == "Delete Account"{
                self.deleteAccountButtonAction()
            }else if subTitle == "Logout"{
                self.logoutbuttonAction()
            }
                
            }else if strTitle == "Business Profile"{
                let subTitle = arroptions[row]
                if subTitle == "My Business Profile"{
                   
                }else if subTitle == "Create/Edit Business Profile" {
                    
                }
                
                
                
            } else if strTitle == "Groups"{
                
                let subTitle = arroptions[row]
                if subTitle == "Create Group"{
                    let destVc:UIViewController = StoryBoard.groups.instantiateViewController(withIdentifier: "CreateGroupVC") as! CreateGroupVC
                    self.navigationController?.pushViewController(destVc, animated: true)
                    
                }else  if subTitle == "My Groups" {
                let destVc:UIViewController = StoryBoard.groups.instantiateViewController(withIdentifier: "GroupListVC") as! GroupListVC
                self.navigationController?.pushViewController(destVc, animated: true)
                }
            }
            else  if strTitle == "Pages" {
                let subTitle = arroptions[row]
                if subTitle == "Create Page" {
                    let destVc:UIViewController = StoryBoard.page.instantiateViewController(withIdentifier: "CreateBusinessPageVC") as! CreateBusinessPageVC
                    self.navigationController?.pushViewController(destVc, animated: true)
                    
                    
                }else if subTitle == "My Pages" {
                    let destVc:BusinessPageListingVC = StoryBoard.page.instantiateViewController(withIdentifier: "BusinessPageListingVC") as! BusinessPageListingVC
                    destVc.isFromMore = true
                    self.navigationController?.pushViewController(destVc, animated: true)
                }
            }
            else  if strTitle == "Privacy & Terms" {
                let subTitle = arroptions[row]
                if subTitle == "Terms and Conditions" {
                    
                    let destVC:PrivacyPolicyViewController = StoryBoard.main.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
                    destVC.strTitle = "Terms and Conditions"
                    destVC.strURl = Constant.sharedinstance.termsURL
                    print(Constant.sharedinstance.termsURL)
                    self.navigationController?.pushView(destVC, animated: true)
                    
                    
                }else if subTitle == "Privacy Policy" {
                    
                    let destVC:PrivacyPolicyViewController = StoryBoard.main.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
                    destVC.strTitle = "Terms and Privacy Policy"
                    destVC.strURl = Constant.sharedinstance.privacyURL
                    print(Constant.sharedinstance.privacyURL)
                    self.navigationController?.pushView(destVC, animated: true)
                    
                }else if subTitle == "User Verification Policy" {
                    
                    let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
                    vc.urlString = Constant.sharedinstance.userGreenBadgePolicyURL
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }else if subTitle == "Page Verification Policy" {
                    
                    let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
                    vc.urlString = Constant.sharedinstance.pageVerificationPolicyURL
                    self.navigationController?.pushViewController(vc, animated: true)
               
                }else if subTitle == "FAQ" {
                    
                    let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
                    vc.urlString = Constant.sharedinstance.faqURL
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
        }
        */
    }
    
     func deleteAccountButtonAction(){
        
        let destVc:UIViewController = StoryBoard.feeds.instantiateViewController(withIdentifier: "DeleteAccountVC") as! DeleteAccountVC
        self.navigationController?.pushViewController(destVc, animated: true)
    }

     func logoutbuttonAction(){
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let msg = (Settings.sharedInstance.deviceLoggedCount > 1) ? "Logout from current device" : "Logout"
        let logout = UIAlertAction(title:msg , style: .default) { action in
            
            AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure you want to logout?", buttonTitles: ["Yes","No"], onController: self) { (title, index) in
                
                if index == 0 {
                    DBManager.shared.clearDB()
                    (UIApplication.shared.delegate as! AppDelegate).Logout()

                }
            }
        }
        let logoutFromAll = UIAlertAction(title: "Logout from all devices", style: .default) { action in
            
            AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure you want to logout from all devices?", buttonTitles: ["Yes","No"], onController: self) { (title, index) in
                
                if index == 0 {
                    self.logoutFromAllDevices()

                }
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.addAction(logout)
        if Settings.sharedInstance.deviceLoggedCount > 1{
            actionSheet.addAction(logoutFromAll)
        }
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
    }
    
    
    func logoutFromAllDevices(){
        
        let param = ["userId":Themes.sharedInstance.Getuser_id()] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_logout_from_all_device, param)
    }
    
    
}


extension MoreSettingVC:UITableViewDelegate,UITableViewDataSource{

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
        cell.lblTitle.text = listArray[indexPath.item]
        cell.imgViewIcon.image = UIImage(named: listImgArray[indexPath.item])
        cell.lblNew.isHidden = true
        
        if listArray[indexPath.item] == "Dark Mode"{
            cell.btnSwitch.isHidden = false
            cell.btnBAck.isHidden = true
            
            let enumVal = UserDefaults.standard.value(forKey: darkModeSettings) as? Int ?? 0
            if enumVal == 2{
                cell.btnSwitch.isOn = false
            }else{
                cell.btnSwitch.isOn = true
            }
            
        }else{
            cell.btnSwitch.isHidden = true
            cell.btnBAck.isHidden = false
        }
        
        if listArray[indexPath.item] == "Ads Dashboard" || listArray[indexPath.item] == "Create an Ad"{
            cell.lblNew.isHidden = false
            
        }

        
        if listArray[indexPath.item] == "Friend Request List"{
            cell.lblNotificationCount.isHidden = false
            let msg = (objUser.requestCount == 0) ?  "" : "\(objUser.requestCount)"
            cell.lblNotificationCount.text = msg

        }else{
            cell.lblNotificationCount.isHidden = true
        }

        cell.btnSwitch.addTarget(self, action: #selector(darkModeSwitchAction(_ :)), for: .valueChanged)
      //  ddCell.btnSwitch.isOn = (userObject.showName == 1) ? true : false
        
        return cell
        
    }
    //MARK: Selector methods
    @objc func  darkModeSwitchAction(_ sender: UISwitch) {
        var enumVal = UserDefaults.standard.value(forKey: darkModeSettings) as? Int ?? 3
        
        if sender.isOn {
            enumVal = 1
            UserDefaults.standard.setValue(enumVal, forKey: darkModeSettings)
            UserDefaults.standard.synchronize()
            AppDelegate.sharedInstance.window?.overrideUserInterfaceStyle = .dark

        }else{
            enumVal = 2
            UserDefaults.standard.setValue(enumVal, forKey: darkModeSettings)
            UserDefaults.standard.synchronize()
            AppDelegate.sharedInstance.window?.overrideUserInterfaceStyle = .light

        }
        
        self.settingTblView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let strTitle = listArray[indexPath.row]
        
        
         if strTitle == "My Wallet"
        {
            let viewController:WalletVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
            viewController.isGiftedCoinsTabOpen = true
            self.navigationController?.pushView(viewController, animated: true)
       
        }else if strTitle == "Professional Dashboard"{
            
            let viewController:ProfessionalDashboardVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "ProfessionalDashboardVC") as! ProfessionalDashboardVC
            self.navigationController?.pushView(viewController, animated: true)
            
        }else if strTitle == "Create an Ad"{
            let destVc:WallPostViewVC = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
            destVc.controllerType = .isFromPost
            self.pushView(destVc, animated: true)

        }else if strTitle == "Ads Dashboard"
        {
            let viewController:DashboardVC = StoryBoard.promote.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
            viewController.isNeedBackBtn = true
            self.pushView(viewController, animated: true)
       
        }else if strTitle == "Share Profile"{
            
            let viewController:ShareProfileVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "ShareProfileVC") as! ShareProfileVC
            viewController.pickzonId = objUser.pickzonId
            viewController.userId = objUser.id
            self.navigationController?.pushView(viewController, animated: true)
            
        } else if strTitle == "Friend Request List"{
            
           let viewController:SuggestionListVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "SuggestionListVC") as! SuggestionListVC
           viewController.isRequestSelected = true
           viewController.isContactSelected = false
           viewController.isSuggestedSelected = false
           self.navigationController?.pushView(viewController, animated: true)
            
            self.isToRefreshApi = true

            
           
      
        }else if strTitle == "Profile"{
            
            let destVc:UIViewController = StoryBoard.main.instantiateViewController(withIdentifier: "FeedSettingVC") as! FeedSettingVC
            self.navigationController?.pushViewController(destVc, animated: true)
        }else if strTitle == "Notifications Settings" {
            let destVc:NotificationSettingsVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "NotificationSettingsVC") as! NotificationSettingsVC
            self.navigationController?.pushViewController(destVc, animated: true)
        }else if strTitle == "Saved Posts"{
            
            let destVc:WallPostViewVC = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
            destVc.controllerType = .isFromSaved
            self.navigationController?.pushViewController(destVc, animated: true)
        }else if strTitle == "Contact Us"{
            
            let destVC:ContactUSViewController = StoryBoard.feeds.instantiateViewController(withIdentifier: "ContactUSViewController") as! ContactUSViewController
            self.navigationController?.pushView(destVC, animated: true)
        }else if strTitle == "Refer & Earn" {
            
            if  Themes.sharedInstance.getIsReferAvailable() as? Int ?? 0 == 1 {
                let destVC:ReferalsViewController = StoryBoard.feeds.instantiateViewController(withIdentifier: "ReferalsViewController") as! ReferalsViewController
                self.navigationController?.pushView(destVC, animated: true)
            }else if Themes.sharedInstance.getIsCoinReferAvailable() as? Int ?? 0 == 1 {
                //Coin Refer available
                let destVC:ShareReferallCodeVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "ShareReferallCodeVC") as! ShareReferallCodeVC
                self.navigationController?.pushView(destVC, animated: true)
            }else {
                shareApp()
            }
            
        }else if strTitle == "Share App" {
            shareApp()
        } else if strTitle == "Blocked User List" {
            let vc = StoryBoard.main.instantiateViewController(withIdentifier: "BlockedUserVC") as! BlockedUserVC
            self.pushView(vc, animated: true)
            
        }else if strTitle == "Privacy & Terms" {
            let destVC:PrivacyTermsVC = StoryBoard.main.instantiateViewController(withIdentifier: "PrivacyTermsVC") as! PrivacyTermsVC
            self.navigationController?.pushView(destVC, animated: true)

            
            /*  if subTitle == "Terms and Conditions" {
             
             let destVC:PrivacyPolicyViewController = StoryBoard.main.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
             destVC.strTitle = "Terms and Conditions"
             destVC.strURl = Constant.sharedinstance.termsURL
             print(Constant.sharedinstance.termsURL)
             self.navigationController?.pushView(destVC, animated: true)
             
             
             }else if subTitle == "Privacy Policy" {
             
             let destVC:PrivacyPolicyViewController = StoryBoard.main.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
             destVC.strTitle = "Terms and Privacy Policy"
             destVC.strURl = Constant.sharedinstance.privacyURL
             print(Constant.sharedinstance.privacyURL)
             self.navigationController?.pushView(destVC, animated: true)
             
             }else if subTitle == "User Verification Policy" {
             
             let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
             vc.urlString = Constant.sharedinstance.userGreenBadgePolicyURL
             self.navigationController?.pushViewController(vc, animated: true)
             
             }else if subTitle == "Page Verification Policy" {
             
             let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
             vc.urlString = Constant.sharedinstance.pageVerificationPolicyURL
             self.navigationController?.pushViewController(vc, animated: true)
             
             }else if subTitle == "FAQ" {
             
             let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
             vc.urlString = Constant.sharedinstance.faqURL
             self.navigationController?.pushViewController(vc, animated: true)
             }*/
            
        }else if strTitle == "Refer & Earn" {
            
            if  Themes.sharedInstance.getIsReferAvailable() as? Int ?? 0 == 1 {
                let destVC:ReferalsViewController = StoryBoard.feeds.instantiateViewController(withIdentifier: "ReferalsViewController") as! ReferalsViewController
                self.navigationController?.pushView(destVC, animated: true)
            }else if Themes.sharedInstance.getIsCoinReferAvailable() as? Int ?? 0 == 1 {
                //Coin Refer available
                let destVC:ShareReferallCodeVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "ShareReferallCodeVC") as! ShareReferallCodeVC
                self.navigationController?.pushView(destVC, animated: true)
            }else {
                shareApp()
            }
            
        }
        
        
        //self.navigateToViewController(section: indexPath.section, row: indexPath.row - 1)
    }
        
    func shareApp(){
        
//  let appStoreLink = "Download PickZon app & stay entertained! \nIOS App: https://apps.apple.com/in/app/pickzon/id1560097730 \n Android App: https://play.google.com/store/apps/details?id=com.chat.pickzon"
        
        let appStoreLink = "Download PickZon app & stay entertained! \n https://www.pickzon.com/apps"
        let objectsToShare = [appStoreLink, ActionExtensionBlockerItem()] as [Any]
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
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print]
        }
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
}



//MARK: UITableview Cell
class MoreOptionsTblCell: UITableViewCell {
    @IBOutlet weak  var lblOptionTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}



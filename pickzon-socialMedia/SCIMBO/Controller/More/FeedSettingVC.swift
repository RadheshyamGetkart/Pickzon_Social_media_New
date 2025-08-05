//
//  FeedSettingVC.swift
//  SCIMBO
//
//  Created by Getkart on 14/08/21.
//  Copyright © 2021 Radheshyam Yadav. All rights reserved.
// Getk2rt$2034

import UIKit
import AVFoundation

class FeedSettingVC: UIViewController {
    
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var tblView: UITableView!

    var profileArray = ["Edit Profile", "Verification Request","Change Password", "Change Mobile Number","Pickzon Web Login"]
    var autoPlayArray = ["On mobile data and Wi-Fi","On Wi-Fi only"]
    var listArray = ["Videos Start with Sound"]
    var contactSync = ["Contact sync"]
    var lastArray = ["Delete Account","Logout"]

    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        self.tblView.separatorStyle = .none
        self.tblView.register(UINib(nibName: "SettingTblCell", bundle: nil), forCellReuseIdentifier: "SettingTblCell")
        tblView.sectionHeaderHeight = 0
        tblView.sectionFooterHeight = 0
        tblView.sectionHeaderHeight = UITableView.automaticDimension
        tblView.estimatedSectionHeaderHeight = 0
        if #available(iOS 15.0, *) {
            tblView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Settings.sharedInstance.isLiveAllowed == 2 {
            profileArray = ["Edit Profile","Verification Request","Apply For Live Access","Change Password", "Change Mobile Number","Pickzon Web Login"]
            
        }else{
            profileArray = ["Edit Profile","Verification Request","Change Password", "Change Mobile Number","Pickzon Web Login"]
        }
        
        
        guard let realm = DBManager.openRealm() else {
            return
        }
        if let existingUser =  realm.object(ofType: DBUser.self, forPrimaryKey: Themes.sharedInstance.Getuser_id()) {
           
            if (existingUser.celebrity == 1 || existingUser.celebrity == 4 || existingUser.celebrity == 5 ) &&  !profileArray.contains("Download Badge Certificate"){
                
                profileArray.append("Download Badge Certificate")
            }
            
            if existingUser.mobileNo.count == 0{
                if  let index =  profileArray.firstIndex(of: "Change Mobile Number"){
                    profileArray.remove(at: index)
                }
            }
        }
        self.tblView.reloadData()
    }
    
    
    //MARK: UIBUttton Action Methods
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
   
    func logoutFromAllDevices(){
        
        let param = ["userId":Themes.sharedInstance.Getuser_id()] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_logout_from_all_device, param)
    }
}

extension FeedSettingVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return profileArray.count

        }else if section == 1{
            return autoPlayArray.count
        }else if section == 2{
            return listArray.count
        }else if section == 3{
            return contactSync.count
          
        }else {
            return lastArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
        
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 50
        }
        return -5
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return -5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        if section == 1{
            let cell = tblView.dequeueReusableCell(withIdentifier: "FeedSettingTblCellId")
            as! FeedSettingTblCell
            cell.switchOption.setOn(false, animated: false)
            cell.switchOption.onTintColor = UIColor.lightGray
            cell.switchOption.isHidden = false
            cell.btnCheckBox.isHidden = true
            cell.lblSeperator.isHidden = true
            let enumVal = UserDefaults.standard.value(forKey: autoPlaySettingType) as? Int ?? 0
            cell.lblTitle.font =  UIFont(name: "Roboto-Regular", size: 17.0)
            cell.lblTitle.text = "Auto-play videos"
            cell.switchOption.tag = 99
            if enumVal != FeedSettingEnum.neverAutoPlay.rawValue {
                cell.switchOption.setOn(true, animated: false)
            }else {
                cell.switchOption.setOn(false, animated: false)
            }
            cell.switchOption.addTarget(self, action: #selector(autoplayAction(_ : )), for: .valueChanged)
            return cell
        }else{
            return nil
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        if indexPath.section == 0 {
             let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTblCell") as! SettingTblCell
             cell.lblTitle.text = profileArray[indexPath.item]
             cell.cnstrntWidthImgVwIcon.constant = 0
             cell.btnSwitch.isHidden = false
             cell.btnBAck.isHidden =  true
            cell.btnSwitch.isHidden =  true
            
            if indexPath.row == 1 && (Settings.sharedInstance.isLiveAllowed == 2){
                cell.btnBAck.isHidden =  false
            }

             return cell
        }else  if indexPath.section == 1 {

            let cell = tblView.dequeueReusableCell(withIdentifier: "FeedSettingTblCellId") as! FeedSettingTblCell
            cell.switchOption.onTintColor = UIColor.lightGray
            cell.lblTitle.font =  UIFont(name: "Roboto-Regular", size: 15.0)
            cell.lblTitle.text = autoPlayArray[indexPath.row]
           // cell.leftConstraintTitle?.constant = 20
            let enumVal = UserDefaults.standard.value(forKey: autoPlaySettingType) as? Int ?? 0
            cell.btnCheckBox.setImage(UIImage(named: "unselectedRadio"), for: .normal)
            cell.btnCheckBox.isHidden = false
            cell.switchOption.isHidden = true
            cell.lblSeperator.isHidden = true // (indexPath.row == autoPlayArray.count - 1) ? false : true
            switch indexPath.row {
            case 0:
                if enumVal == 1 {
                    cell.btnCheckBox.setImage(UIImage(named: "selectedRadio"), for: .normal)
                }
                break
            case 1:
                if enumVal == 2 {
                    cell.btnCheckBox.setImage(UIImage(named: "selectedRadio"), for: .normal)
                }
                break
                
            case 2:
                if enumVal == 3 {
                    cell.btnCheckBox.setImage(UIImage(named: "selectedRadio"), for: .normal)
                }
                break
            default:
                break
            }
            cell.btnCheckBox.tag = 100 + indexPath.row
            cell.btnCheckBox.addTarget(self, action: #selector(autoPlayCheckBoxBtnAction(_ : )), for: .touchUpInside)
            return cell
        }else if indexPath.section == 2{
            let cell = tblView.dequeueReusableCell(withIdentifier: "FeedSettingTblCellId") as! FeedSettingTblCell
            cell.switchOption.onTintColor = UIColor.lightGray
            cell.lblTitle.font =  UIFont(name: "Roboto-Regular", size: 17.0)
          //  cell.leftConstraintTitle?.constant = 5
           // cell.lblTitle.font =  UIFont(name: "Roboto-Bold", size: 17.0)
            cell.switchOption.setOn(false, animated: false)
            cell.btnCheckBox.isHidden = true
            cell.switchOption.isHidden = false
            
            cell.lblTitle.text = listArray[indexPath.row]
            cell.lblSeperator.isHidden = true
            switch indexPath.row {
            case 0:
                if UserDefaults.standard.bool(forKey: videosStartWithSound) {
                    cell.switchOption.setOn(true, animated: false)
                }
                break
            default:
                break
            }
            cell.switchOption.tag = 30 + indexPath.row
            cell.switchOption.addTarget(self, action: #selector(checkBoxBtnAction(_ : )), for: .valueChanged)
            return cell
            
        }else if indexPath.section == 3{
            let cell = tblView.dequeueReusableCell(withIdentifier: "FeedSettingTblCellId") as! FeedSettingTblCell
            cell.switchOption.onTintColor = UIColor.lightGray
            cell.lblTitle.font =  UIFont(name: "Roboto-Regular", size: 17.0)
           // cell.leftConstraintTitle?.constant = 5
            cell.switchOption.setOn(false, animated: false)
            cell.btnCheckBox.isHidden = true
            cell.switchOption.isHidden = false
            cell.lblTitle.text = contactSync[indexPath.row]
            cell.lblSeperator.isHidden = true
            switch indexPath.row {
            case 0:
                if shouldContactSync() == true{
                    cell.switchOption.setOn(true, animated: false)
                }
                break
            default:
                break
            }
            cell.switchOption.tag = 20 + indexPath.row
            cell.switchOption.addTarget(self, action: #selector(contactSyncBtnAction(_ : )), for: .valueChanged)
            return cell
            
        }else if indexPath.section == 4 {
           
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTblCell") as! SettingTblCell
            cell.lblTitle.text = lastArray[indexPath.item]
            cell.cnstrntWidthImgVwIcon.constant = 0
            cell.btnSwitch.isHidden = false
            cell.btnBAck.isHidden = (indexPath.row == 0) ? false : true
            cell.btnSwitch.isHidden =  true

            return cell
            
        }
        
        
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            let strTitle = profileArray[indexPath.row]
            
            if strTitle == "Download Badge Certificate"{
                if let certificateBadgeVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "CertificateBadgeVC") as? CertificateBadgeVC{
                    self.pushView(certificateBadgeVC, animated: true)
                }
            }else if strTitle == "Apply For Live Access"{
                let changeNoVC = StoryBoard.main.instantiateViewController(withIdentifier:"RequestGoLiveVC" ) as! RequestGoLiveVC
                self.pushView(changeNoVC, animated: true)
           
            }else if strTitle == "Verification Request"{
                let changeNoVC = StoryBoard.feeds.instantiateViewController(withIdentifier:"RequestVerificationViewController" ) as! RequestVerificationViewController
                
                self.pushView(changeNoVC, animated: true)
                
            }else if strTitle == "Edit Profile"{
                let editProfileVC:ProfileEditVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "ProfileEditVC") as! ProfileEditVC
                //editProfileVC.pickzonUser = objUser
                //editProfileVC.delegate = self
                self.pushView(editProfileVC, animated: true)
                
            }else  if strTitle == "Change Password"{
                let changeNoVC = StoryBoard.prelogin.instantiateViewController(withIdentifier:"ChangePasswordVC" ) as! ChangePasswordVC
                self.pushView(changeNoVC, animated: true)
            }else  if strTitle == "Change Mobile Number"{
                let viewController:VerifyEmailAndPhone = StoryBoard.prelogin.instantiateViewController(withIdentifier: "VerifyEmailAndPhone") as! VerifyEmailAndPhone
                viewController.isEmail = false
                //viewController.delegateVerifyEmailPhone = self
                self.navigationController?.pushView(viewController, animated: true)
            }else  if strTitle == "Pickzon Web Login"{
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
                
                
            }
            
        }else  if indexPath.section == 4 {
            
            let strTitle = lastArray[indexPath.row]
            
            if strTitle == "Delete Account"{
                
                let destVc:UIViewController = StoryBoard.feeds.instantiateViewController(withIdentifier: "DeleteAccountVC") as! DeleteAccountVC
                self.navigationController?.pushViewController(destVc, animated: true)
                
            }else  if strTitle == "Logout"{
                
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
        }
    }
    
    //MARK: Selector Methods
    @objc func autoPlayCheckBoxBtnAction(_ sender:UIButton){
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tblView)
        let indexPath = self.tblView.indexPathForRow(at: buttonPosition)
        if indexPath?.section == 1 {
          //  let enumVal = UserDefaults.standard.value(forKey: autoPlaySettingType) as? Int ?? 0
            UserDefaults.standard.setValue(FeedSettingEnum.nothing.rawValue, forKey: autoPlaySettingType)
            
            switch sender.tag {
                
            case 100:
                
                UserDefaults.standard.setValue(FeedSettingEnum.onMobileDataAndWifi.rawValue, forKey: autoPlaySettingType)
                break
            case 101:
               
                UserDefaults.standard.setValue(FeedSettingEnum.wifiOnly.rawValue, forKey: autoPlaySettingType)
                break
                
            case 102:
                
                UserDefaults.standard.setValue(FeedSettingEnum.neverAutoPlay.rawValue, forKey: autoPlaySettingType)
                break
            default:
                break
            }
            UserDefaults.standard.synchronize()
            self.tblView.reloadData()
        }
    }
    
    @objc func darkModeCheckBoxBtnAction(_ sender:UIButton){
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tblView)
        let indexPath = self.tblView.indexPathForRow(at: buttonPosition)
        if indexPath?.section == 3 {
            var enumVal = UserDefaults.standard.value(forKey: darkModeSettings) as? Int ?? 3
            switch sender.tag {
                
            case 200:
                
                enumVal = 1
                UserDefaults.standard.setValue(enumVal, forKey: darkModeSettings)
                UserDefaults.standard.synchronize()
                AppDelegate.sharedInstance.window?.overrideUserInterfaceStyle = .dark
                break
            case 201:
                
                enumVal = 2
                UserDefaults.standard.setValue(enumVal, forKey: darkModeSettings)
                UserDefaults.standard.synchronize()
                AppDelegate.sharedInstance.window?.overrideUserInterfaceStyle = .light
                break
                
            case 202:
                
                enumVal = 3
                UserDefaults.standard.setValue(enumVal, forKey: darkModeSettings)
                UserDefaults.standard.synchronize()
                AppDelegate.sharedInstance.window?.overrideUserInterfaceStyle = .unspecified
                break
            default:
                break
            }
            
            self.tblView.reloadData()
        }
    }
    

    @objc func autoplayAction(_ sender:UIButton) {
            if sender.tag == 99 {
                let enumVal = UserDefaults.standard.value(forKey: autoPlaySettingType) as? Int ?? 0
                if enumVal == FeedSettingEnum.neverAutoPlay.rawValue {
                    UserDefaults.standard.setValue(FeedSettingEnum.onMobileDataAndWifi.rawValue, forKey: autoPlaySettingType)
                }else{
                    UserDefaults.standard.setValue(FeedSettingEnum.neverAutoPlay.rawValue, forKey: autoPlaySettingType)
                }
                self.tblView.reloadData()
            }
            
        }
           
        @objc func checkBoxBtnAction(_ sender:UISwitch){
            let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tblView)
            let indexPath = self.tblView.indexPathForRow(at: buttonPosition)
            if indexPath?.section == 2 {
                switch sender.tag {
                case 30:
                    
                    if UserDefaults.standard.bool(forKey: videosStartWithSound) {
                        UserDefaults.standard.setValue(false, forKey: videosStartWithSound)
                    }else{
                        UserDefaults.standard.setValue(true, forKey: videosStartWithSound)
                    }
                    break
                default:
                    break
                }
                
                self.tblView.reloadData()
            }
        }
        
        @objc func contactSyncBtnAction(_ sender:UISwitch){
            let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tblView)
            let indexPath = self.tblView.indexPathForRow(at: buttonPosition)
            if indexPath?.section == 3 {
                switch sender.tag {
                case 20:
                    if UserDefaults.standard.bool(forKey: contactSyncSettingsType) == true{
                        UserDefaults.standard.setValue(false, forKey: contactSyncSettingsType)
                    }else{
                        UserDefaults.standard.setValue(true, forKey: contactSyncSettingsType)
                    }
                    break
                default:
                    break
                }
                
                self.tblView.reloadData()
            }
        }
        
        
    
}


class FeedSettingTblCell:UITableViewCell{
    @IBOutlet weak var leftConstraintTitle: NSLayoutConstraint?
    @IBOutlet weak var lblSeperator: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnCheckBox:UIButton!
    @IBOutlet weak var switchOption: UISwitch!
    @IBOutlet weak var bgview: UIView!
    
}


class FeedSettingHeaderTblCell:UITableViewCell{
    @IBOutlet weak var lblTitle: UILabel!
}

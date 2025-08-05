//
//  ProfileEditVC.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 2/2/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import IQKeyboardManager
import MapKit
import GSImageViewerController
import SDWebImage
import RSKImageCropper
import Kingfisher
import SCIMBOEx
import NSFWDetector
import FittedSheets


protocol updatedProfileDelegate: AnyObject{
    
    func getUpdatedObject(user:UserModel)
}


class ProfileEditVC: UIViewController {
  
    var delegate:updatedProfileDelegate? = nil
    @IBOutlet weak var tblView:TPKeyboardAvoidingTableView!
    @IBOutlet weak var headerVw:UIView!
    @IBOutlet weak var footerView:UIView!
    @IBOutlet weak var profileSubBgView:UIViewX!
    @IBOutlet weak var switchBtnPrivate:UISwitch!
    @IBOutlet weak var txtViewDesc:IQTextView!
    @IBOutlet weak var lblAccountType:UILabel!
    @IBOutlet weak var btnPickzonId:UIButton!
  //@IBOutlet weak var profileImg_Btn: UIButton!
    @IBOutlet weak var imgVwCover: UIImageView!
    @IBOutlet weak var btnEditPickzonId: UIButton!
    @IBOutlet weak var btnProfileCamera: UIButton!
    @IBOutlet weak var btnCoverCamera: UIButton!
    @IBOutlet weak var profilePicView:ImageWithSvgaFrame!

    var titleArray:NSMutableArray? = nil
    var iconArray:NSMutableArray? = nil
    private var datePicker: UIDatePicker = UIDatePicker()
    var viewDatePicker : UIView = UIView()
    
    var userTypeArray:Array<String> = Array<String>()
    
    var categoryArray:Array<String> = Array<String>()
    
    var categoryIdArray:Array<String> = Array<String>()
    
    var userObject = UserModel(dict: [:])
    var picker = UIImagePickerController()
    var isCoverImage = false
    var imageUrl = ""
    var coverImage = ""
    let descCharLimit = 150
    var isChangedName = false
    var isChangeddDob = false
    var pickzonUser = PickzonUser(respdict: [:])
    var locationObj = LocationModal(locationDict: [:])
    var isCreatingNewPost = false

  
    //MARK: - Controller life cycle methods
    override func viewDidLoad() {
        print("UIViewController: ProfileEditVC")
        super.viewDidLoad()
        self.profilePicView.initializeView()
        switchBtnPrivate.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        btnEditPickzonId.setImageTintColor(UIColor.darkGray)
        titleArray = NSMutableArray(objects:"Full Name*","User Type*","Category*","Mobile*","Email*","Gender*","DOB*","Live In*","Website Url","Interest")
        iconArray = NSMutableArray(objects:"User","headlineIcon","Job","Mobile","Mail","Gender","DOB","Location","Web","Interest")

        txtViewDesc.textContainer.maximumNumberOfLines = 4
        txtViewDesc.layer.borderWidth = 1.0
        txtViewDesc.layer.borderColor = UIColor.lightGray.cgColor
        txtViewDesc.layer.cornerRadius = 10.0
        txtViewDesc.delegate = self
        if pickzonUser.pickzonId != "" {
            updateDetail()
        }else {
            self.getUserInfoDetails()
        }
        
        txtViewDesc.placeholder = "Description(\(descCharLimit) character limit)"
        txtViewDesc.contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 10, right: 5)
        getAllProfileCatoryApi()
        
        if Settings.sharedInstance.isPickzonIdChange == 0{
            self.btnEditPickzonId.isHidden = true
        }
        
//        if Settings.sharedInstance.isVerifiedUser == 1{
//            self.btnProfileCamera.isHidden = true
//        }
        
        if #available(iOS 15.0, *) {
            tblView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        profilePicView.remoteSVGAPlayer?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                           action:#selector(self.profilePicTapped(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        IQKeyboardManager.shared().isEnabled = false
//        IQKeyboardManager.shared().isEnableAutoToolbar = false
//        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
//        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        super.viewWillDisappear(animated)
    }
    
    deinit{
        self.delegate = nil
    }
    
    @IBAction func backBtnAction(_ sender: UIButton){
        self.delegate?.getUpdatedObject(user: userObject)
        
        self.delegate = nil
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateDetail(){
        
        userObject.dob = pickzonUser.dob
        userObject.isToSHowDob = pickzonUser.showDob
        userObject.isToShowMob = pickzonUser.showMobile
        userObject.isToShowEmail = pickzonUser.showEmail
        userObject.showName = pickzonUser.showName
        userObject.fullName = pickzonUser.name
        userObject.email = pickzonUser.email
        userObject.description = pickzonUser.description
        userObject.interest = pickzonUser.interest
        userObject.webLink = pickzonUser.website
        userObject.headline = pickzonUser.headline
        userObject.gender =  (pickzonUser.gender == "") ? "Male" : pickzonUser.gender
        userObject.location = pickzonUser.livesIn
        userObject.job = pickzonUser.jobProfile
        userObject.mobile = pickzonUser.mobileNo  //"\(Themes.sharedInstance.GetMyPhonenumber())"
        userObject.tiktokName = pickzonUser.pickzonId
        userObject.isEmailVerified = pickzonUser.isEmailVerified
        userObject.isMobileVerified = pickzonUser.isMobileVerified
        locationObj.locationName = pickzonUser.livesIn
        
        if pickzonUser.dob.length > 0 {
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat =  "yyyy-MM-dd" //"yyyy/MM/dd"
            let dateDOB =  dateFormatter1.date(from: pickzonUser.dob)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            userObject.dob = dateFormatter.string(from: dateDOB!)
        }
        self.switchBtnPrivate.setOn((pickzonUser.usertype == 0) ? false : true, animated: true)
        txtViewDesc.text = userObject.description
        btnPickzonId.setTitle( "@" + userObject.tiktokName, for: .normal)

        self.profilePicView.setImgView(profilePic: pickzonUser.profilePic, remoteSVGAUrl: pickzonUser.avatarSVGA,changeValue: (pickzonUser.profilePic.count == 0) ? 12 : 18)
        
        self.imgVwCover.kf.setImage(with:  URL(string: pickzonUser.coverImage), placeholder:  PZImages.defaultCover, options: nil, progressBlock: nil) { response in
        }
        
        self.tblView.reloadData()
    }
    
    
    
    func getUserInfoDetails(){

        let followmsisdn =   Themes.sharedInstance.Getuser_id()
        let param:NSDictionary =  [:]
        let url = "\(Constant.sharedinstance.showUserInfo)/\(followmsisdn)"
        
        URLhandler.sharedinstance.makeGetCall(url: url, param: param) {(responseObject, error) ->  () in
           
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]

                if status == 1 {
                    if let payloadDict = result["payload"] as? NSDictionary {
                        self.pickzonUser = PickzonUser(respdict: payloadDict)
                    }
                                        
                    if  self.pickzonUser.profilePic.count > 0 && Themes.sharedInstance.Getuser_id() == self.pickzonUser.id {
                        let user_ID = Themes.sharedInstance.Getuser_id()
                        let CheckUser:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString:user_ID as String?)
                        if (!CheckUser){
                       
                        }else{
                            let UpdateDict:[String:Any]=["profilepic": self.pickzonUser.profilePic,"mobilenumber":"\(self.pickzonUser.mobileNo)"]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail , FetchString: user_ID, attribute:"user_id" , UpdationElements: UpdateDict as NSDictionary?)
                        }
                    }
                    
                    self.updateDetail()
                   
                }else{
                        self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
    }
   
    
    //MARK: - UIButton Action Methods
    @IBAction func editPickzonIdBtnAction(_ sender: UIButton){
        openSheet()
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PickzonIdEditVC") as! PickzonIdEditVC
//            vc.pickzonId = userObject.tiktokName
//            vc.delegate = self
//            navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    func openSheet(){
        
        
        if #available(iOS 13.0, *) {
            let controller:EditPickzonIdVC = StoryBoard.main.instantiateViewController(identifier: "EditPickzonIdVC")
            as! EditPickzonIdVC
            controller.title = ""
            controller.pickzonId = userObject.tiktokName
            controller.delegate = self
            let useInlineMode = view != nil
            let nav = UINavigationController(rootViewController: controller)
            let percentVal = UIDevice().hasNotch ? 0.50 : 0.55
            let sheet = SheetViewController(
                controller: nav,
                sizes: [.percent(Float(percentVal)),.intrinsic],
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
    
   
  
    @IBAction func bannerCameraBtnAction(_ sender: UIButton){
        
        isCoverImage = true
       
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
           self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
        self.openGallary()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
        
    
    
    @objc func profilePicTapped(_ sender: UITapGestureRecognizer){
        profilePicBtnAction(self.btnProfileCamera)
    }
   
    @IBAction func profilePicBtnAction(_ sender: UIButton){
        
        isCoverImage = false
        let controller = UIStoryboard(name: "TableViewDemo", bundle: nil).instantiateInitialViewController()! as! TableViewDemo
        var percentage:Float = 0.30
        controller.listArray = ["Entry Style","Frame","Gallery","Camera"]
        controller.iconArray = ["entryStyle","crown1","galley1","cameraFill"]
        controller.videoIndex = 0
        controller.delegate = self
        controller.isToHideSeperator = false
        
        let useInlineMode = view != nil
        let sheet = SheetViewController(
            controller: controller,
            sizes: [.percent(percentage), .intrinsic],
            options: SheetOptions(useFullScreenMode:false, shrinkPresentingViewController:false, useInlineMode: useInlineMode))
        sheet.allowPullingPastMaxHeight = false
        if let view = view {
            sheet.animateIn(to: view, in: self)
        } else {
            self.present(sheet, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func submitBtnAction(_ sender: UIButton){
        self.view.endEditing(true)
        if  self.userObject.fullName.trim().count == 0 {
            self.view.makeToast(message: "Name field cannot be empty" , duration: 3, position: HRToastActivityPositionDefault)
        } else if  self.userObject.fullName.count > 50  || self.userObject.fullName.count < 3 {
            self.view.makeToast(message: "Name length must be greater than 3 and less than 50 characters" , duration: 3, position: HRToastActivityPositionDefault)
        }else if self.userObject.headline.count == 0  {
            self.view.makeToast(message: "Please select User Type" , duration: 3, position: HRToastActivityPositionDefault)
        }else if  self.userObject.job.count == 0 {
            self.view.makeToast(message: "Please select Category" , duration: 3, position: HRToastActivityPositionDefault)
        }else if userObject.email.trimmingCharacters(in: .whitespaces).isEmpty == true{
            
            Themes.sharedInstance.ShowNotification("Email field cannot be empty", false)
        } else if  userObject.email.isValidEmail == false {
            Themes.sharedInstance.ShowNotification("Invalid email", false)
        }else if userObject.dob.trimmingCharacters(in: .whitespaces).isEmpty == true{
            Themes.sharedInstance.ShowNotification("Date of birth field cannot be empty", false)
        }else if userObject.location.trimmingCharacters(in: .whitespaces).isEmpty == true{
            Themes.sharedInstance.ShowNotification("Lives In field cannot be empty", false)
        }else if userObject.webLink.count > 0 &&  !userObject.webLink.validateUrl(){
            Themes.sharedInstance.ShowNotification("Inavlid url", false)
//        }else if (profileImg_Btn.currentImage ==  UIImage(named: "avatar")){
        }else if (profilePicView.imgVwProfile?.currentImage ==  UIImage(named: "avatar")){

            Themes.sharedInstance.ShowNotification("Please upload profile picture.", false)
        }else {
            
            if (isChangedName || isChangeddDob) && (pickzonUser.celebrity == 1 || pickzonUser.celebrity == 4){
                
                AlertView.sharedManager.presentAlertWith(title: "Alert!", msg: (Settings.sharedInstance.profileUpdateConfigMsg.count > 0) ? Settings.sharedInstance.profileUpdateConfigMsg as NSString :  "Once your account is verified, if you change your “Profile Name” or “Date Of Birth”, the verification checkmark next to your profile will get removed and you can continue using PickZon as a normal user. After 24-48 hours of changing the details, the verification checkmark will be automatically retrieved and visible to all the audiences again.", buttonTitles: ["Cancel","Ok"], onController: self) { title, index in
                    if index == 1 {
                        self.updateUserProfileApi()
                    }
                }
            }else {
                self.updateUserProfileApi()
            }
        }
    }
    
    @IBAction func switchAction(_ sender: UISwitch) {
        
        if pickzonUser.isBoostedPost == 1 && (switchBtnPrivate.isOn){
                      
            let message = "Your post is boosted and by making your account private your boosted post will not be shown to the public."
            AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["Yes","No"], onController: self) { title, index in
                if index == 0 {
                    self.makeAccountAsPrivate()
                }else{
                    self.switchBtnPrivate.isOn.toggle()
                }
            }
        }else{
            
            
            let message = !(switchBtnPrivate.isOn) ? "Are you sure you want to make account public?" : "Are you sure you want to make account private?"
            AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["Yes","No"], onController: self) { title, index in
                if index == 0 {
                    self.makeAccountAsPrivate()
                }else{
                    self.switchBtnPrivate.isOn.toggle()
                }
            }
        }
    }

    //MARK: Api Methods
    func deleteProfileImage(){
        
        let params = NSMutableDictionary()
        params.setValue(Themes.sharedInstance.Getuser_id(), forKey: "userId")
        
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.deleteUserProfileImageURL, param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }
            else{
                
                let result = responseObject! as NSDictionary
                let errNo = result["errNum"] as? String ?? ""
                let message = result["message"] as? String ?? ""
                
                if errNo == "99"{
                    DispatchQueue.main.async {
                        self.profilePicView.imgVwProfile?.image = PZImages.avatar
                      //  self.profileImg_Btn.setBackgroundImage(UIImage(named: "avatar"), for: .normal)
                        AlertView.sharedManager.displayMessage(title: "PickZon", msg: message, controller: self)
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)}
                }
            }
        })
        
    }
    
    
    func makeAccountAsPrivate()  {
        
        let params = NSMutableDictionary()
        params.setValue("\(Themes.sharedInstance.GetMyPhonenumber())", forKey: "msisdn")
        
        params.setValue((switchBtnPrivate.isOn ? 1 : 0 ), forKey: "type")
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.changeUserTypeURL, param: params, completionHandler: {(responseObject, error) ->  () in
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
                    if let payload = result["payload"] as? NSDictionary{
                        Settings.sharedInstance.usertype = payload["userType"] as? Int ?? 0
                        self.userObject.userType = payload["userType"] as? Int ?? 0
                        self.delegate?.getUpdatedObject(user: self.userObject)

                    }
                DispatchQueue.main.async {
                    if self.isCreatingNewPost == true {
                        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                                self.navigationController?.popViewController(animated: true)
                            }))
                            self.present(alert, animated: true, completion: nil)
                    }else {
                        AlertView.sharedManager.displayMessage(title: "PickZon", msg: message, controller: self)
                    }
                    
                    
                    
                    }
                    
                    
                    
                }
                else
                {
                    DispatchQueue.main.async {
                        
                        self.switchBtnPrivate.isOn.toggle()
                        
                        
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                        
                    }
                }
            }
        })
        
    }
    
  
    func updateUserProfileApi(){
        
        let params = NSMutableDictionary()
        
        var dobSend = ""

        if userObject.dob.length > 0 {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let dt = dateFormatter.date(from: userObject.dob)
            
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "yyyy-MM-dd"
            dobSend =  dateFormatter1.string(from: dt!)
        }
        
        params.setValue("\(Themes.sharedInstance.GetMyPhonenumber())", forKey: "msisdn")
        params.setValue(userObject.fullName, forKey: "name")
        params.setValue(userObject.email, forKey: "email")
        params.setValue(userObject.gender, forKey: "gender")
        params.setValue(dobSend, forKey: "dob")
        params.setValue(userObject.job, forKey: "jobProfile")
        params.setValue(userObject.location, forKey: "livesIn")
        params.setValue(userObject.interest, forKey: "interest")
        params.setValue(txtViewDesc.text, forKey: "description")
        params.setValue(userObject.webLink, forKey: "website")
        
        params.setValue(userObject.isToSHowDob, forKey: "showDob")
        params.setValue(userObject.isToShowMob, forKey: "showMobile")
        params.setValue(userObject.isToShowEmail, forKey: "showEmail")
        params.setValue(userObject.showName, forKey: "showName")

       // params.setValue(imageUrl, forKey: "image")
        params.setValue(userObject.headline, forKey: "headline")

        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.editUserProfile, param: params, completionHandler: {(responseObject, error) ->  () in
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
                    
                    UserDefaults.standard.setValue(true, forKey: Constant.sharedinstance.isProfileInfoAvailable)
                    UserDefaults.standard.synchronize()
                    self.delegate?.getUpdatedObject(user: self.userObject)
                    AlertView.sharedManager.presentAlertWith(title: "PickZon", msg: message as NSString, buttonTitles: ["Ok"], onController: self, dismissBlock: { (title ,index) in
                        
                            self.navigationController?.popViewController(animated: true)
                    })
                }else{
                    
                    DispatchQueue.main.async {
                        
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)}
                }
            }
        })
        
    }
    
    func uploadImage(image:UIImage){
          
          Themes.sharedInstance.activityView(View: self.view)
          
        URLhandler.sharedinstance.uploadImageWithParameters(profileImg:image, imageName: (isCoverImage) ? "coverImage" : "images", url: Constant.sharedinstance.updateProfileImage, params: [:])
          { response in
              Themes.sharedInstance.RemoveactivityView(View: self.view)
              let message = response["message"] as? String ?? ""
               let status = response["status"] as? Int16 ?? 0
               
              
              if status == 1 {
                  let payload = response["payload"] as? NSDictionary ?? [:]
                  self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)

              
              /*
                  if  let profileImage = payload["profileImage"] as? String {
                   
                      self.imageUrl = profileImage
                      
                      var image_Url = Themes.sharedInstance.CheckNullvalue(Passed_value: profileImage)
                      if(image_Url.substring(to: 1) == ".")
                      {
                          image_Url.remove(at: image_Url.startIndex)
                          image_Url = ("\(ImgUrl)\(image_Url)")
                      }
                      //let imageUrl:String = ("\(ImgUrl)\(image_Url)")
                      let user_ID = Themes.sharedInstance.Getuser_id()
                      let CheckUser:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString:user_ID as String?)
                      if (!CheckUser){
                      }
                      else{
                          let UpdateDict:[String:Any]=["profilepic": image_Url]
                          DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail , FetchString: user_ID, attribute:"user_id" , UpdationElements: UpdateDict as NSDictionary?)
                      }
                                      
                  }
                  */
                  
              }
          }
      }
    
    func getAllProfileCatoryApi(){
        
        let params = NSMutableDictionary()
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeGetCall(url:Constant.sharedinstance.getProfileCategoryURL, param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }
            else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    
                    if let  payload  = result["payload"] as? Dictionary<String, Any>  {
                        if let arr = payload["profileCategory"] as? Array< Dictionary<String,Any> > {
                            for dict in arr {
                                self.categoryArray.append((dict as! Dictionary)["name"] ?? "")
                                self.categoryIdArray.append((dict as! Dictionary)["_id"] ?? "")
                            }
                        }
                        
                        
                        if let arr = payload["profileType"] as? Array< Dictionary<String,Any> > {
                            for dict in arr {
                                self.userTypeArray.append((dict as! Dictionary)["name"] ?? "")
                            }
                        }
                    }
                     
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        })
        
    }
}



extension ProfileEditVC:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate,PickzonIdDelegate,OptionDelegate{
  
    func selectedOption(index:Int,videoIndex:Int,title:String){
        
        
        if title == "Entry Style" {
            let vc =  StoryBoard.feeds.instantiateViewController(withIdentifier: "EntryStyleSelectionVC") as! EntryStyleSelectionVC
            vc.pickzonUser = self.pickzonUser
            self.navigationController?.pushViewController(vc, animated: true)
        }else if title == "Frame" {
            let vc =  StoryBoard.feeds.instantiateViewController(withIdentifier: "FrameSelectionVC") as! FrameSelectionVC
            vc.pickzonUser = self.pickzonUser
            vc.frameDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }else if title == "Gallery" {
            self.openGallary()
            
        }else if title == "Camera" {
            self.openCamera()
            
        }
        
    }
    

    func textViewDidBeginEditing(_ textView: UITextView) {
//        if (txtViewDesc.text.characters.count <= descCharLimit){
//            self.view.makeToast(message: "Maximum charactr limit is \(descCharLimit)" , duration: 1.5, position: HRToastActivityPositionDefault)
//        }
        txtViewDesc.becomeFirstResponder()
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
       
        return textView.text.count + (text.count - range.length) <= descCharLimit
    }
   
   
    func getPickzonId(pickzonId:String)
    {
        self.userObject.tiktokName = pickzonId
        self.btnPickzonId.setTitle("@" + pickzonId, for: .normal)
    }
    
    //MARK: UItableview Delegate and datasource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return titleArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
               
        if indexPath.row == 5{
            let genderCell = tableView.dequeueReusableCell(withIdentifier: "GenderTblCell") as! GenderTblCell
            genderCell.backgroundColor = UIColor.white
            genderCell.segmentedcontrol.layer.borderColor = UIColor.lightGray.cgColor
            genderCell.segmentedcontrol.layer.borderWidth = 1.0
            
            
            genderCell.segmentedcontrol.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
            genderCell.segmentedcontrol.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)
            genderCell.segmentedcontrol.addTarget(self, action: #selector(indexChanged(_:)), for: .valueChanged)
            
            if userObject.gender.lowercased() == "male"{
                genderCell.segmentedcontrol.selectedSegmentIndex = 0
            }else if userObject.gender.lowercased() == "female"{
                genderCell.segmentedcontrol.selectedSegmentIndex = 1

            }else if userObject.gender.lowercased() == "other" || userObject.gender.lowercased() == "others"{
                genderCell.segmentedcontrol.selectedSegmentIndex = 2
            }
            
            return genderCell
        }
        
        let ddCell = tableView.dequeueReusableCell(withIdentifier: "ProfileTblCell") as! ProfileTblCell

        ddCell.txtfield.placeholder = titleArray?[indexPath.row] as? String ?? ""
        ddCell.txtfield.iconImage = UIImage(named: iconArray?[indexPath.row] as? String ?? "")
        ddCell.btnSwitch.isHidden = true
        ddCell.ddImgVw.isHidden = true
        ddCell.txtfield.delegate = self
        ddCell.txtfield.addRightPadding()
        ddCell.txtfield.isUserInteractionEnabled = true
        ddCell.txtfield.tag = indexPath.row
        ddCell.txtfield.iconWidth = 20
        ddCell.backgroundColor = UIColor.white
        ddCell.txtfield.errorColor = UIColor.red
        ddCell.txtfield.isAllowCopyPaste = false

        switch indexPath.row{
            
//        case 0:
//            ddCell.txtfield.text = userObject.tiktokName
//            ddCell.txtfield.isUserInteractionEnabled = false
//            ddCell.txtfield.iconWidth = 0
//            break
        case 0:
            ddCell.txtfield.text = userObject.fullName
            ddCell.txtfield.autocapitalizationType = .words
            ddCell.btnSwitch.isHidden = false
            ddCell.btnSwitch.tag = 999
            ddCell.btnSwitch.addTarget(self, action: #selector(fullNameVisibleSwitchAction(_ :)), for: .valueChanged)
            ddCell.btnSwitch.isOn = (userObject.showName == 1) ? true : false
            
            break
        case 1:
            ddCell.txtfield.text = userObject.headline
            break
        case 2:
            ddCell.txtfield.text = userObject.job
            break
            
        case 3:
            ddCell.btnSwitch.tag = 1000

            ddCell.txtfield.text = userObject.mobile
           // ddCell.txtfield.isUserInteractionEnabled = false
            ddCell.btnSwitch.isHidden = false
            ddCell.btnSwitch.addTarget(self, action: #selector(mobileVisibleSwitchAction(_ :)), for: .valueChanged)
            ddCell.btnSwitch.isOn = (userObject.isToShowMob == 1) ? true : false
            break
        case 4:
            ddCell.btnSwitch.tag = 1001
            ddCell.txtfield.text = userObject.email
            ddCell.btnSwitch.isOn = (userObject.isToShowEmail == 1) ? true : false
            ddCell.btnSwitch.isHidden = false
            ddCell.btnSwitch.addTarget(self, action: #selector(emailVisibleSwitchAction(_ :)), for: .valueChanged)
           //ddCell.txtfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            break
        case 6:
            ddCell.btnSwitch.tag = 1002
            ddCell.txtfield.text = userObject.dob
            ddCell.btnSwitch.isHidden = true
            //ddCell.btnSwitch.addTarget(self, action: #selector(dobVisibleSwitchAction(_ :)), for: .valueChanged)
            //ddCell.btnSwitch.isOn = (userObject.isToSHowDob == 1) ? true : false
            break
//        case 5:
//            ddCell.ddImgVw.isHidden = false
//            ddCell.txtfield.text = userObject.job
//            break
        case 7:
            ddCell.txtfield.text = userObject.location
            break
        case 8:
            ddCell.txtfield.text = userObject.webLink
            ddCell.txtfield.isAllowCopyPaste = true

            break
        case 9:
            ddCell.txtfield.text = userObject.interest
            ddCell.txtfield.isAllowCopyPaste = true

            break
            
        default:
            break
        }
        
        return ddCell
    }
    
    //MARK: - UIButton Selector Methods
    @objc  func genderCommonBtnAction(_ sender : UIButton){
        
        switch sender.tag{
            
        case 100:
            userObject.gender = "Male"
            break
        case 101:
            userObject.gender = "Female"
            break
        case 102:
            userObject.gender = "Other"
            break
        default:
            break
        }
        self.tblView.reloadRows(at: [IndexPath(row: 5, section: 0)], with: .none)
    }
    
    
    @objc func indexChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            userObject.gender = "Male"
        } else if sender.selectedSegmentIndex == 1 {
            userObject.gender = "Female"
        } else if sender.selectedSegmentIndex == 2 {
            userObject.gender = "Others"
        }
        self.tblView.reloadRows(at: [IndexPath(row: 5, section: 0)], with: .none)

    }
    
    //MARK: - UISwitch Selector Methods
    
    
    @objc func  fullNameVisibleSwitchAction(_ sender: UISwitch) {
        
        if sender.tag == 999{
            
            let message = ( self.userObject.showName == 0) ? "Are you sure you want to make Name public?" : "Are you sure you want to make Name private?"
            AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["Yes","No"], onController: self) { title, index in
                if index == 0 {
                  //  self.userObject.isToShowName = 1
                    self.userObject.showName = ( self.userObject.showName == 0) ? 1 : 0
                }else{
                    self.userObject.showName = ( self.userObject.showName == 0) ? 0 : 1
                    sender.isOn = false
                    
                }
                self.tblView.reloadData()
            }
        }
    }
    
    @objc func  dobVisibleSwitchAction(_ sender: UISwitch) {
        if sender.tag == 1002{
            
        let message = ( self.userObject.isToSHowDob == 0) ? "Are you sure you want to make DOB public?" : "Are you sure you want to make DOB private?"
        AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["Yes","No"], onController: self) { title, index in
            if index == 0 {
              //  self.userObject.isToSHowDob = 1
                self.userObject.isToSHowDob = ( self.userObject.isToSHowDob == 0) ? 1 : 0
            }else{
                self.userObject.isToSHowDob = ( self.userObject.isToSHowDob == 0) ? 0 : 1

             //   sender.isOn = false
               
            }
            self.tblView.reloadData()

        }
        }
    }

    @objc func  emailVisibleSwitchAction(_ sender: UISwitch) {
        
        if sender.tag == 1001{

        let message = (self.userObject.isToShowEmail == 0) ? "Are you sure you want to make email public?" : "Are you sure you want to make email private?"
        AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["Yes","No"], onController: self) { title, index in
            if index == 0 {
                self.userObject.isToShowEmail = ( self.userObject.isToShowEmail == 0) ? 1 : 0
            }else{
                //sender.isOn = false
               // self.userObject.isToShowEmail = 0
                self.userObject.isToShowEmail = ( self.userObject.isToShowEmail == 0) ? 0 : 1
            }
            self.tblView.reloadData()
        }
        }
    }
    
    
    @objc func mobileVisibleSwitchAction(_ sender: UISwitch) {
        if sender.tag == 1000{

        let message = (self.userObject.isToShowMob == 0) ? "Are you sure you want to make mobile public?" : "Are you sure you want to make mobile private?"
        AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["Yes","No"], onController: self) { title, index in
            if index == 0 {
             //   self.userObject.isToShowMob = 1
                self.userObject.isToShowMob = ( self.userObject.isToShowMob == 0) ? 1 : 0
            }else{
               // sender.isOn = false
               // self.userObject.isToShowMob = 0
                self.userObject.isToShowMob = ( self.userObject.isToShowMob == 0) ? 0 : 1
            }
            self.tblView.reloadData()
        }
        }
    }
    
    
    //MARK: - UItextfield Delegate methods
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
      
       if (self.pickzonUser.celebrity == 1 || self.pickzonUser.celebrity == 4) && ( textField.tag == 0 || textField.tag == 6){
            return false
        }
        if textField.tag == 0{
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no
        }else if textField.tag == 3{
            self.userObject.mobile = self.userObject.mobile.trimmingCharacters(in: .whitespaces)
            if userObject.isMobileVerified == 0{
                let viewController:VerifyEmailAndPhone = StoryBoard.prelogin.instantiateViewController(withIdentifier: "VerifyEmailAndPhone") as! VerifyEmailAndPhone
                viewController.delegateVerifyEmailPhone = self
                viewController.isEmail = false
                self.navigationController?.pushView(viewController, animated: true)
            }else {
                
//                let changeNoVC = StoryBoard.prelogin.instantiateViewController(withIdentifier:"ChangeNumberViewController" ) as! ChangeNumberViewController
//                self.pushView(changeNoVC, animated: true)
                
                let viewController:VerifyEmailAndPhone = StoryBoard.prelogin.instantiateViewController(withIdentifier: "VerifyEmailAndPhone") as! VerifyEmailAndPhone
                viewController.isEmail = false
                viewController.delegateVerifyEmailPhone = self
                self.navigationController?.pushView(viewController, animated: true)
            }
            
            return false
            
        }else if textField.tag == 4{
            if userObject.isEmailVerified == 1 {
                return false
            }else {
                let viewController:VerifyEmailAndPhone = StoryBoard.prelogin.instantiateViewController(withIdentifier: "VerifyEmailAndPhone") as! VerifyEmailAndPhone
                viewController.isEmail = true
                viewController.delegateVerifyEmailPhone = self
                self.navigationController?.pushView(viewController, animated: true)
                //textField.keyboardType = .emailAddress
                return false
            }
        }else if textField.tag == 6{
            self.view.endEditing(true)
            showDOBDatePicker()
            return false
            }
       else if textField.tag == 1{
            self.view.endEditing(true)
            ActionSheetMultipleStringPicker.show(withTitle: "", rows: [
                userTypeArray
            ], initialSelection: [0, 0], doneBlock: {
                picker, indexes, values in
            
                 if let str = (values as AnyObject?) as? NSArray {
                 
                     self.userObject.headline   = str[0] as? String ?? ""
                     self.tblView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                 }
                
                return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: textField)
            return false
            
        }else if textField.tag == 2{
            self.view.endEditing(true)
            ActionSheetMultipleStringPicker.show(withTitle: "", rows: [
                categoryArray
            ], initialSelection: [0, 0], doneBlock: {
                picker, indexes, values in
            
                 if let str = (values as AnyObject?) as? NSArray {
                 
                     self.userObject.job   = str[0] as? String ?? ""
                     self.tblView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
                 }
                
                return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: textField)
            return false
            
        }else if textField.tag == 7{
            
          
            self.view.endEditing(true)
            let destVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "SearchLocationVC") as! SearchLocationVC
            destVC.delegate = self
            self.navigationController?.pushViewController(destVC, animated: true)

            return false
        }
        
        return true
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let previousText:NSString = textField.text! as NSString
        let updatedText = previousText.replacingCharacters(in: range, with: string)
        if textField.tag == 0{
           
            if string.isEmpty {
                return true
            }
            return string.isValidName()

//            let alphaNumericRegEx = #"[a-zA-Z\s]"#
//            let predicate = NSPredicate(format:"SELF MATCHES %@", alphaNumericRegEx)
//            return predicate.evaluate(with: string)
            
        }else if textField.tag == 1 {
            if string.isEmpty {
                return true
            }
            
            if updatedText.length > 50 {
                self.view.makeToast(message: "Character limit exceeds." , duration: 2, position: HRToastActivityPositionDefault)
                return false
            }
            
            
            
            let stringArray = updatedText.components(separatedBy: CharacterSet.decimalDigits)
            if stringArray.count - 1 > 5 {
                self.view.makeToast(message: "Only 5 digits allowed" , duration: 2, position: HRToastActivityPositionDefault)
                return false
            }
            
            let alphaNumericRegEx = #"[a-zA-Z0-9. \s]"#
            let predicate = NSPredicate(format:"SELF MATCHES %@", alphaNumericRegEx)
            return predicate.evaluate(with: string)
        }else if textField.tag == 2 {
            if string.isEmpty {
                return true
            }
            
            if updatedText.length > 30 {
                self.view.makeToast(message: "Character limit exceeds." , duration: 2, position: HRToastActivityPositionDefault)
                return false
            }
            
            let alphaNumericRegEx = #"[a-zA-Z. \s]"#
            let predicate = NSPredicate(format:"SELF MATCHES %@", alphaNumericRegEx)
            return predicate.evaluate(with: string)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
        textField.text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch textField.tag
        {
        case 0:
            isChangedName = false
            textField.text = textField.text?.condenseWhitespace()
            if userObject.fullName != textField.text ?? ""{
                isChangedName = true
            }
            
            userObject.fullName = textField.text ?? ""
            break
        
        case 1:
            userObject.headline = textField.text ?? ""
            break
        case 2:
            userObject.job = textField.text ?? ""
            break
        case 3:
            userObject.mobile = textField.text ?? ""
            break
            
        case 4:
            userObject.email = textField.text ?? ""
            break
        case 8:
            userObject.webLink = textField.text ?? ""
            break
            
        case 9:
            userObject.interest = textField.text ?? ""
            break
            
        default:
            break
        }
        self.tblView.reloadRows(at: [IndexPath(row: textField.tag, section: 0)], with: .none)
        
    }
    
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    // This will notify us when something has changed on the textfield
        @objc func textFieldDidChange(_ textfield: UITextField) {
            if let text = textfield.text {
                if let floatingLabelTextField = textfield as? SkyFloatingLabelTextFieldWithIcon {
                    if(text.count < 3 || !text.contains("@")) {
                        floatingLabelTextField.errorMessage = "Invalid email"
                    }
                    else {
                        // The error message will only disappear when we reset it to nil or empty string
                        floatingLabelTextField.errorMessage = ""
                    }
                }
            }
        }
    
    //MARK: - SearchLocationResultDelegate
    func LocationSelected(searchRegion: MKCoordinateRegion, locationString:String) {
        LocationHelper.shared.getReverseGeoCodedLocationUpdated(location: CLLocation.init(latitude: searchRegion.center.latitude, longitude: searchRegion.center.longitude)) { (location, placemark, error) in
            self.userObject.location = ""
            self.userObject.location = placemark?.locality ?? ""
            
            if (self.userObject.location).length > 0 {
                self.userObject.location = (self.userObject.location) + "," + " " + (placemark?.country ?? "")
            }else{
                self.userObject.location =  (placemark?.country ?? "")
            }
            
            self.tblView.reloadRows(at: [IndexPath(row: 7, section: 0)], with: .none)
        }
    }
    
    
    //MARK: - Date Picker Methods
    
     func showDOBDatePicker() {
        self.view.endEditing(true)
         viewDatePicker.removeFromSuperview()
        
        viewDatePicker = UIView(frame: CGRect(x: 0,
                                              y: self.view.frame.height - 260,
                                              width: self.view.frame.width,
                                              height: 260))
        viewDatePicker.backgroundColor = UIColor.white
        let toolBar = UIToolbar(frame: CGRect(x: 0,
                                              y: 0,
                                              width: self.view.frame.width,
                                              height: 44))
        toolBar.setItems([buttonItem(withSystemItemStyle: .cancel),
                          buttonItem(withSystemItemStyle: .flexibleSpace),
                          buttonItem(withSystemItemStyle: .done)],
                         animated: true)
        toolBar.backgroundColor = UIColor.white
        viewDatePicker.addSubview(toolBar)
        
        datePicker = UIDatePicker(frame: CGRect(x: (self.view.frame.width - 320) / 2,
                                                y: 44,
                                                width: 320,
                                                height: 216))
         datePicker.setYearValidation(year:13)
         if #available(iOS 13.4, *) {
             datePicker.preferredDatePickerStyle = .wheels
         } else {
             // Fallback on earlier versions
         }
        datePicker.sizeToFit()
        datePicker.datePickerMode = .date
        datePicker.setValue(UIColor.black, forKey: "textColor")
        viewDatePicker.addSubview(datePicker)
        self.view.addSubview(viewDatePicker)
        
    }
    
    
    func buttonItem(withSystemItemStyle style: UIBarButtonItem.SystemItem) -> UIBarButtonItem {
        let buttonTarget = style == .flexibleSpace ? nil : target
        let action: Selector? = {
            switch style {
            case .cancel:
                return  #selector(self.cancelAction)
            case .done:
                return #selector(self.doneActionDOBPicker)
            default:
                return nil
            }
        }()
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: style,
                                            target: buttonTarget,
                                            action: action)
        return barButtonItem
    }
    
    
    @objc func cancelAction() {
        viewDatePicker.removeFromSuperview()
    }
    
    @objc func doneActionDOBPicker() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.string(from: datePicker.date)
      
        isChangeddDob = false

        if userObject.dob != dateString{
            isChangeddDob = true
        }
        
        self.userObject.dob = dateString
        
//        let dateFormatter1 = DateFormatter()
//        dateFormatter1.dateFormat = "yyyy-MM-dd"
//        self.userObject.dob = dateFormatter1.string(from: datePicker.date)
        self.tblView.reloadRows(at: [IndexPath(row: 6, section: 0)], with: .none)

        viewDatePicker.removeFromSuperview()
    }
    
}

extension ProfileEditVC:VerifyEmailPhoneDelegate {
    func verifyEmailPhoneSuccess(isEmail:Bool, strEmailPhone:String) {
        if isEmail == true {
            self.userObject.email = strEmailPhone
            self.userObject.isEmailVerified = 1
        }else {
            self.userObject.mobile = strEmailPhone
            self.userObject.isMobileVerified = 1
        }
        self.tblView.reloadData()
    }
}

extension ProfileEditVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate,RSKImageCropViewControllerDelegate,RSKImageCropViewControllerDataSource{
   
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.delegate=self
            self.presentView(picker, animated: true)
        }
        else
        {
            openGallary()
        }
    }
    
    func openGallary()
    {
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.delegate=self
        
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.presentView(picker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        let image : UIImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
        let compressedimg = image.jpegData(compressionQuality: 0.3)
        
        if isCoverImage{
            let imageCropVC = RSKImageCropViewController(image: image)
            imageCropVC.delegate = self
            imageCropVC.dataSource = self
            imageCropVC.cropMode = .custom
            imageCropVC.preferredContentSize = .init(width: self.view.frame.size.width, height: self.view.frame.size.width/2.0)
            imageCropVC.avoidEmptySpaceAroundImage = true
            imageCropVC.isRotationEnabled = true
            imageCropVC.applyMaskToCroppedImage = true
            self.pushView(imageCropVC, animated: true)
            
        }else{
            let imageCropVC = RSKImageCropViewController(image: UIImage(data: compressedimg!)!)
            imageCropVC.delegate = self
            imageCropVC.cropMode = .circle
            self.pushView(imageCropVC, animated: true)
        }
        picker.dismissView(animated: true, completion: nil)
    }
    func imageCropViewControllerCustomMaskRect(_ controller: RSKImageCropViewController) -> CGRect {
        //let maskSize = CGSizeMake(320, 320)
        let maskRect = CGRectMake(0 , self.view.frame.size.height / 2.0 - self.view.frame.size.width / 4.0,  self.view.frame.size.width,  self.view.frame.size.width/2.0)
        return maskRect
    }

    func imageCropViewControllerCustomMaskPath(_ controller: RSKImageCropViewController) -> UIBezierPath {
       return UIBezierPath(rect: controller.maskRect)
    }

    func imageCropViewControllerCustomMovementRect(_ controller: RSKImageCropViewController) -> CGRect {
        let rect = controller.maskRect
        return rect;
    }
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        self.pop(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
       // profileImg_Btn.setBackgroundImage(croppedImage, for: .normal)
        self.profilePicView.imgVwProfile?.image = croppedImage
        self.pop(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat)
    {
        self.pop(animated: true)
        
        //if Settings.sharedInstance.confidenceThreshold < 0.80 {
            self.CheckNudityforImage(image: croppedImage)
        //}
       /* if isCoverImage{
            imgVwCover.image = croppedImage
            uploadImage(image: croppedImage)
        }else{
            profileImg_Btn.setImage(croppedImage, for: .normal)
            uploadImage(image: croppedImage)
        }
       */
    }
    func showAlertForNudity() {
        // Create the alert controller
        let alertController = UIAlertController(title: "", message: "Uploading or sharing any form of vulgar or offensive content on this platform is strictly prohibited.", preferredStyle: .alert)
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
        }
        // Add the actions
        alertController.addAction(okAction)
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
   
    func CheckNudityforImage(image:UIImage) {
        NSFWDetector.shared.check(image: image) { result in
            switch result {
            case .error:
                print("Detection failed")
            case let .success(nsfwConfidence: confidence):
                print(String(format: "%.1f %% porn", confidence * 100.0))
                if Double(confidence)  > Settings.sharedInstance.confidenceThreshold {
                    DispatchQueue.main.async {
                            self.showAlertForNudity()
                    }
                    
                }else {
                    if self.isCoverImage{
                        self.imgVwCover.image = image
                        self.uploadImage(image: image)
                     }else{
                        // self.profileImg_Btn.setBackgroundImage(image, for: .normal)
                         self.profilePicView.imgVwProfile?.image = image
                         self.uploadImage(image: image)
                     }
                     
                }
            }
        }
    }
    
    
}


extension ProfileEditVC:LocationDelegate,SearchLocationDelegate,FrameSelectionDelegate{
    func getUpdatedObject(avatar:String, svgaUrl:String){
        pickzonUser.avatar = avatar
        pickzonUser.avatarSVGA = svgaUrl
        self.profilePicView.setImgView(profilePic: pickzonUser.profilePic, remoteSVGAUrl: pickzonUser.avatarSVGA,changeValue:(pickzonUser.profilePic.count == 0) ? 12 : 18)
    }
    
    func selectedSearchedLocation(place:MKPlacemark,mapItem:MKMapItem,title:String,Subtitle:String){
/*
        print(place)
        print(mapItem)
        let locationName = "\(mapItem.name) \(mapItem.placemark.locality) \(mapItem.placemark.country)"
        print( place.location)
        print( place.locality)
        print( place.subLocality)
        print( place.subThoroughfare)
        print( place.administrativeArea)
        
        var locationString  = mapItem.name
        locationString =  locationString! + " " + (place.locality ?? "" )
        locationString = (locationString!) + "," + " " + (place.country ?? "")
        print("mapItem.name == \(mapItem.name)")
        print()
        print("locationString == \(locationString!)")
//        locationObj.locationName = "\(locationObj.apartment) \(locationObj.streetAddress) \(locationObj.city) \(locationObj.state) \(locationObj.country) \(locationObj.postalCode)".trimmingLeadingAndTrailingSpaces()
        */
        self.userObject.location = "\(title), \(Subtitle)"
        self.tblView.reloadRows(at: [IndexPath(row: 7, section: 0)], with: .none)
    }
    
    
    func selectedLocation(locObj:LocationModal){
        
        self.userObject.location = locObj.locationName
        self.locationObj = locObj
        self.tblView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .none)
        
    }
}




//MARK: UITAbleview cell
class  GenderTblCell:UITableViewCell{

    @IBOutlet weak var segmentedcontrol:UISegmentedControl!
}



class ProfileTblCell:UITableViewCell{
    @IBOutlet weak var bgView:UIViewX!
    @IBOutlet weak var btnSwitch:UISwitch!
    @IBOutlet weak var ddImgVw:UIImageView!
    @IBOutlet weak var txtfield:SkyFloatingLabelTextFieldWithIcon!
    
    override func awakeFromNib() {
        btnSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    }
    
}



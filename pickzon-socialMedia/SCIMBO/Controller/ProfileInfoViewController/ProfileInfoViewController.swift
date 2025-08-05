//
//  ProfileInfoViewController.swift

//
//  Created by Casp iOS on 02/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import RSKImageCropper
import JSSAlertView
import ActionSheetPicker_3_0
import IQKeyboardManager
import MapKit
import GSImageViewerController
import SDWebImage
import Kingfisher
import IQKeyboardManager
import SCIMBOEx
import NSFWDetector



class ProfileInfoViewController: UIViewController,SocketIOManagerDelegate{
    
    @IBOutlet weak var enterchat_view: UIView!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var go_btn: UIButton!
    @IBOutlet weak var Entername_field: UITextField!
    @IBOutlet weak var HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tfTiktokName: UITextField!
    @IBOutlet weak var user_image: UIImageView!
       
    @IBOutlet weak var profileSubBgView:UIView!
    @IBOutlet weak var btnCheckBox:UIButtonX!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var logoImgVw: UIImageView!
    @IBOutlet weak var imgViewBanner:UIImageView!
    
    var locationObj = LocationModal(locationDict: [:])
    var picker = UIImagePickerController()
    var username:String=String()
    var email:String=String()
    var jobProfile:String=String()
    var livesIn:String=String()
    var msisdn:String=String()
    var user_id:String=String()
    var tikTokName:String = String()
    var fullImage:NSArray = NSArray()
    var imageName:String = String()
    var istermsChecked:Bool = Bool()
    var user_info:NSMutableDictionary = [:]
    var countryCode = ""
    var mobileNumber = ""
    var isProfileSelected = true
    var randomNumber:Int64 = 0
   
    var viewDatePicker : UIView = UIView()
    var jobArray:Array<String> = Array<String>()
    var jobIdArray:Array<String> = Array<String>()
    
    private var datePicker: UIDatePicker = UIDatePicker()

    var userObject = UserModel(dict: [:])
    var titleArray:NSArray? = nil
    var iconArray:NSArray? = nil
    var imageUrl = ""
    var profileThumbUrl = ""
    
    var coverImageS3 = ""
    var coverImageS3Compress = ""
    var localTimeZoneIdentifier = ""
    var socialId = ""
    var isVerifyEmail = false
    var isEmailMobileVerified = false

    
    //MARK: Controller life cycle methods
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("UIViewController: ProfileInfoViewController")
        
        //Referal Code is enable for India only
         countryCode = Themes.sharedInstance.getMobileCode()
        
      /*  if  Themes.sharedInstance.getIsReferAvailable() as? Int ?? 0 == 1 {
        iconArray = NSMutableArray(objects:"FullName","headlineIcon","Position","LivesIn","Gender","DOB","ReferIcon")

        titleArray = NSArray(objects: "Full Name","Organization","Job Title","Lives In","Gender","Date Of Birth", "Referal Code")
        }else {
            iconArray = NSMutableArray(objects:"FullName","headlineIcon","Position","LivesIn","Gender","DOB")
            titleArray = NSArray(objects: "Full Name","Organization","Job Title","Lives In","Gender","Date Of Birth")
        }*/
        
        tblView.register(UINib(nibName: "PasswordCell", bundle: nil),
                          forCellReuseIdentifier: "PasswordCell")
        tblView.register(UINib(nibName: "EmailCell", bundle: nil),
                          forCellReuseIdentifier: "EmailCell")
        
        
        if  Themes.sharedInstance.getIsCoinReferAvailable() as? Int ?? 0 == 1 || Themes.sharedInstance.getIsReferAvailable() as? Int ?? 0 == 1   {
            if  socialId.length == 0{
                iconArray = NSMutableArray(objects:"FullName", "Gender","DOB", "ReferIcon","chat_lock")
               titleArray = NSArray(objects: "Full Name",  "Gender","Date Of Birth", "Referal Code","Enter Password")
            }else{
                iconArray = NSMutableArray(objects:"FullName","Gender","DOB", "ReferIcon")
               titleArray = NSArray(objects: "Full Name", "Gender","Date Of Birth", "Referal Code")
            }
       
        }else {
            if  socialId.length == 0{
                
                iconArray = NSMutableArray(objects:"FullName", "Gender","DOB","chat_lock")
                titleArray = NSArray(objects: "Full Name","Gender","Date Of Birth", "Enter Password")
            }else{
                iconArray = NSMutableArray(objects:"FullName", "Gender","DOB")
                titleArray = NSArray(objects: "Full Name","Gender","Date Of Birth")
            }
        }
        
        initialSetupMethods()
    }
   
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }
    
    
    
  
    //MARK: Initial Setup Methods
    func initialSetupMethods(){
        istermsChecked = false
        btnCheckBox.isSelected = false
        btnCheckBox.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        localTimeZoneIdentifier = TimeZone.current.identifier
        profileSubBgView.layer.cornerRadius = 25.0
        profileSubBgView.clipsToBounds = true
        user_image.layer.cornerRadius=user_image.frame.size.width/2
        user_image.clipsToBounds=true
        user_image.layer.borderWidth = 1.0
        user_image.layer.borderColor = UIColor.white.cgColor
        imageBtn.layer.cornerRadius=imageBtn.frame.size.width/2
        imageBtn.clipsToBounds=true
        updateDetail()
    }
    
    func updateDetail(){
        userObject.dob = user_info.value(forKey: "dob") as? String ?? ""
        
        if userObject.dob.length > 0 {
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat =  "yyyy-MM-dd" //"yyyy/MM/dd"
            
            if  let dateDOB =  dateFormatter1.date(from: userObject.dob){
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                userObject.dob = dateFormatter.string(from: dateDOB)
            }
        }
        
        let  strGender = user_info.value(forKey: "gender") as? String ?? ""
        if strGender == "" {
            userObject.gender = "Male"
        }else{
            userObject.gender = strGender
        }
        
        if let urlStr = user_info.value(forKey: "ProfilePic") as? String {
            var profilePic = urlStr
            if profilePic.prefix(1) == "." {
                profilePic = String(profilePic.dropFirst(1))
            }
            profilePic = Themes.sharedInstance.getURL() + profilePic
            
            self.user_image.kf.setImage(with: URL(string: profilePic), placeholder: UIImage(named: "avatar"), options: nil, progressBlock: nil) { response in
            }
            
        }
        
        userObject.location = user_info.value(forKey: "livesIn") as? String ?? ""
        userObject.job = user_info.value(forKey: "jobProfile") as? String ?? ""
        userObject.fullName = user_info.value(forKey: "Name") as? String ?? ""
        userObject.email = user_info.value(forKey: "email") as? String ?? ""
        
        
        self.tblView.reloadData()
    }
   
    
    
 
    func reloadData()
    {
        user_image.setProfilePic(Themes.sharedInstance.Getuser_id(), "login")
    }
    
    
    func loginUpdated(_Updated: String) {
        print(_Updated)
    }
    
    func UpdateUserInfo(name:String,imagedata:String,base64data:String, email: String, tiktokName: String){

        let updateDict=["name":Themes.sharedInstance.CheckNullvalue(Passed_value: name), "email":Themes.sharedInstance.CheckNullvalue(Passed_value: email)]
        
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: updateDict as NSDictionary?)
      
        self.user_info["Name"] = name
        self.user_info["Tiktokname"] = tiktokName
        self.user_info["jobProfile"] = jobProfile
        self.user_info["livesIn"] = livesIn

        self.user_info["email"] = email
        
        if ((self.user_info["dob"] as? String)?.length ?? 0 > 0) && ((self.user_info["email"] as? String)?.length ?? 0 > 0) && ((self.user_info["gender"] as? String)?.length ?? 0 > 0  && ((self.user_info["jobProfile"] as? String)?.length ?? 0 > 0) && ((self.user_info["livesIn"] as? String)?.length ?? 0 > 0)) {
            
            UserDefaults.standard.setValue(true, forKey: Constant.sharedinstance.isProfileInfoAvailable)
            UserDefaults.standard.synchronize()
            (UIApplication.shared.delegate as! AppDelegate).MovetoRooVC()
            
        } else{
            UserDefaults.standard.setValue(false, forKey: Constant.sharedinstance.isProfileInfoAvailable)
            UserDefaults.standard.synchronize()

        }
    }
    
    //MARK: UIButton Action Methods
    @IBAction func backButtonAction()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func DidclickTermsandcondition(_ sender: Any) {
        self.view.endEditing(true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destVC:PrivacyPolicyViewController = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
        destVC.strTitle = "Terms and Conditions"
        destVC.strURl = Constant.sharedinstance.termsURL
        self.navigationController?.pushView(destVC, animated: true)
    }
    
    @IBAction func didClickPrivacy(_ sender: Any) {
        self.view.endEditing(true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destVC:PrivacyPolicyViewController = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
        destVC.strTitle = "Terms and Privacy Policy"
        destVC.strURl = Constant.sharedinstance.privacyURL
        self.navigationController?.pushView(destVC, animated: true)
    }
    
    @IBAction func didClickCheckTerms(_ sender: Any) {
        btnCheckBox.isSelected = !btnCheckBox.isSelected
        if(btnCheckBox.isSelected == true){
            istermsChecked = true
            btnCheckBox.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        }else{
            istermsChecked = false
            btnCheckBox.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        }
    }

    
    @IBAction func DIdclickCheck_Btn(_ sender: Any) {
        self.view.endEditing(true)
        if(istermsChecked)
        {
            istermsChecked = false
           // Check_Btn.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            
        }
        else
        {
            istermsChecked = true
          //  Check_Btn.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            
        }
    }
    
    @IBAction func goAction(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let headlineArrayAlPhabets = self.userObject.headline.components(separatedBy: CharacterSet.decimalDigits.inverted)
        
        if   self.userObject.fullName.trimmingCharacters(in: .whitespaces).isEmpty == true{
            self.view.makeToast(message: "Please enter your name" , duration: 3, position: HRToastActivityPositionDefault)
            
        }else if  self.userObject.fullName.count > 50  || self.userObject.fullName.count < 3 {
            self.view.makeToast(message: "Name length must be greater than 3 and less than 50 characters" , duration: 3, position: HRToastActivityPositionDefault)
        }
        /*else if  self.userObject.headline.count > 0 && ( self.userObject.headline.count > 50  || self.userObject.headline.count < 3) {
            self.view.makeToast(message: "Organization length must be greater than 3 and less than 50 characters" , duration: 3, position: HRToastActivityPositionDefault)
            
        }else if  self.userObject.headline.count > 0 && headlineArrayAlPhabets.count == 1 {
            self.view.makeToast(message: "Organization must contain atleast one alphabet" , duration: 3, position: HRToastActivityPositionDefault)
        }
        else if  self.userObject.position.count > 0 && (self.userObject.position.count > 30  || self.userObject.position.count < 3) {
            self.view.makeToast(message: "Job Title length must be greater than 3 and less than 30 characters" , duration: 3, position: HRToastActivityPositionDefault)
            
        }
      /*  else if   self.userObject.location.trimmingCharacters(in: .whitespaces).isEmpty == true{
            self.view.makeToast(message: "Please enter your location." , duration: 3, position: HRToastActivityPositionDefault)
        } */
         */
        
        /*else if   self.userObject.email.isEmpty {
            self.view.makeToast(message: "Please enter email" , duration: 3, position: HRToastActivityPositionDefault)
        }else if   self.userObject.email.isValidEmail == false {
            self.view.makeToast(message: "Please enter valid email" , duration: 3, position: HRToastActivityPositionDefault)
        }else if   self.isVerifyEmail == false {
            self.view.makeToast(message: "Please verify email" , duration: 3, position: HRToastActivityPositionDefault)
        }*/
        else if   self.userObject.gender.isEmpty  {
            self.view.makeToast(message: "Please select gender" , duration: 3, position: HRToastActivityPositionDefault)
        }/* DOB is optional as per recommendation from Apple as app rejected for DOB mandatory field
          else if self.userObject.dob.isEmpty  {
            self.view.makeToast(message: "Please select Date of Birth." , duration: 3, position: HRToastActivityPositionDefault)
            
        }*/else if imageUrl.length == 0 {
            self.view.makeToast(message: "Please upload profile picture" , duration: 3, position: HRToastActivityPositionDefault)
        }else if self.userObject.password.length == 0 && socialId.length == 0{
            self.view.makeToast(message: "Please enter password" , duration: 3, position: HRToastActivityPositionDefault)
        }else if (self.userObject.password != self.userObject.confirmPassword)  && socialId.length == 0{
            self.view.makeToast(message: "Password and Confirm password does not match" , duration: 3, position: HRToastActivityPositionDefault)
        }else if (self.userObject.password.isValidPassword == false) && socialId.length == 0 {
            self.view.makeToast(message: "Password must be of minimum 5 characters at least 1 Alphabet and 1 Number" , duration: 3, position: HRToastActivityPositionDefault)
        } else if(istermsChecked == false) {
            self.view.makeToast(message: "Please check terms and conditions." , duration: 3, position: HRToastActivityPositionDefault)
            
        }else{
            if isEmailMobileVerified == true {
                self.updateUserDataApi()
            }else {
                //commented as OTP
                self.hashingCreatorApi()
            }
        }
    }
    
    
  
  
    
    @IBAction func DidclickenterChat(_ sender: Any) {
        
        self.UpdateUserInfo(name: self.Entername_field.text!, imagedata: "", base64data: "", email: self.email, tiktokName: self.tfTiktokName.text?.trim() ?? "".trimmingCharacters(in: .whitespaces))
    }
    
    
    
    
    
    @IBAction func bannerCameraButtonAction(_ sender: Any) {
        
        isProfileSelected = false
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        {
            UIAlertAction in
        }
        picker.delegate = self
        picker.isEditing = false
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the controller
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.presentView(alert, animated: true, completion: nil)
        }
        else
        {
            
        }
        
    }

    
    @IBAction func profileCameraButtonAction(_ sender: Any) {
        isProfileSelected = true
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        {
            UIAlertAction in
        }
        picker.delegate = self
        picker.isEditing = true
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.presentView(alert, animated: true, completion: nil)
        }
        else
        {
            
        }
    }
    
    @IBAction func DidclickimageBtn(_ sender: Any) {
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        {
            UIAlertAction in
        }
        // Add the actions
        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the controller
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.presentView(alert, animated: true, completion: nil)
        }
        else
        {
            
        }
        
    }
    
    
    
    func openEnterChat()
    {
        self.UpdateUserInfo(name: self.Entername_field.text!, imagedata: "", base64data: "", email: "", tiktokName: self.tfTiktokName.text?.trim() ?? "".trimmingCharacters(in: .whitespaces))
        
//        let identityAnimation = CGAffineTransform.identity
//        let scaleOfIdentity = identityAnimation.scaledBy(x: 0.001, y: 0.001)
//        enterchat_view.transform = scaleOfIdentity
//        enterchat_view.isHidden = false
//        UIView.animate(withDuration: 0.3/1.5, animations: {
//            let scaleOfIdentity = identityAnimation.scaledBy(x: 1.1, y: 1.1)
//            self.enterchat_view.transform = scaleOfIdentity
//        }, completion: {finished in
//            UIView.animate(withDuration: 0.3/2, animations: {
//                let scaleOfIdentity = identityAnimation.scaledBy(x: 0.9, y: 0.9)
//                self.enterchat_view.transform = scaleOfIdentity
//            }, completion: {finished in
//                UIView.animate(withDuration: 0.3/2, animations: {
//                    self.enterchat_view.transform = identityAnimation
//                })
//            })
//        })
    }
   
    
    //MARK: Api Methods

    func sendOTPAction() {
         var param:NSDictionary = [:]
        param = ["email":userObject.email, "deviceId":"\(Themes.sharedInstance.getDeviceUUIDString())"]
           Themes.sharedInstance.activityView(View: self.view)
         URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.authSendEmailOTP, param: param) { (responseObject, error) -> () in
               Themes.sharedInstance.RemoveactivityView(View: self.view)
               //self.NextButton.isUserInteractionEnabled = true
                        if(error != nil)
                        {
                            self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
   
                            print(error ?? "defaultValue")
   
                        }
                        else{
                            print(responseObject ?? "response")
                            let result = responseObject! as NSDictionary
                            let status = result["status"] as? Int ?? 0
                            let message = result["message"]
   
                            if status == 1{
                                
                                let alert = UIAlertController(title: "Enter OTP Sent On Your Email", message: "", preferredStyle: .alert)
                                alert.addTextField {
                                    $0.placeholder = "Enter OTP recieved on email"
                                    $0.keyboardType = .numberPad
                                    $0.textAlignment = .center
                                    $0.isSecureTextEntry = true
                                }
                                
                                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                                let loginAction = UIAlertAction(title: "Verify", style: .default) { [unowned self] _ in
                                    if let otp = alert.textFields?[0].text {
                                        print(otp)
                                        if otp.count > 0 {
                                            self.verifyEmailOtpApi(otp: otp)
                                        }
                                    }
                                }
                                alert.addAction(loginAction)
                                self.present(alert, animated: true)
                                
                                
                            }else{
                                self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)
   
                            }
   
                        }
           }
       }
   
   
    func verifyEmailOtpApi(otp: String) {
       
   
   var param:NSDictionary = [:]
       param = [ "email":userObject.email, "otp":otp, "deviceId":"\(Themes.sharedInstance.getDeviceUUIDString())"]

       Themes.sharedInstance.activityView(View: self.view)



       URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.authVerifyEmailOTP, param: param) { (responseObject, error) -> () in
           Themes.sharedInstance.RemoveactivityView(View: self.view)
           //self.NextButton.isUserInteractionEnabled = true
                    if(error != nil)
                    {
                        self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)

                        print(error ?? "defaultValue")

                    }
                    else{
                        print(responseObject ?? "response")
                        let result = responseObject! as NSDictionary
                        let status = result["status"] as? Int ?? 0
                        let message = result["message"]

                        if status == 1{
                            self.isVerifyEmail = true
                            self.tblView.reloadData()
                            let payload = result["payload"] as? NSDictionary ?? [:]
                            let authToken = payload["authToken"] as? String ?? ""
                            if authToken.length > 0 {
                                Themes.sharedInstance.saveAuthToken(authToken: authToken)
                            }
                            
                            
                            

                        }else{
                            //In case invalid otp
                            let alert = UIAlertController(title: "Enter OTP Sent On Your Email", message: "", preferredStyle: .alert)
                            alert.addTextField {
                                $0.placeholder = "Enter OTP recieved on email"
                                $0.keyboardType = .numberPad
                                $0.textAlignment = .center
                                $0.isSecureTextEntry = true
                            }
                            
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                            let loginAction = UIAlertAction(title: "Verify", style: .default) { [unowned self] _ in
                                if let otp = alert.textFields?[0].text {
                                    print(otp)
                                    if otp.count > 0 {
                                        self.verifyEmailOtpApi(otp: otp)
                                    }
                                }
                            }
                            alert.addAction(loginAction)
                            self.present(alert, animated: true)
                            
                            self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)

                        }

                    }
       }
   }
   
   
   @objc func verifyEmailButtonAction(){
       self.view.endEditing(true)
       
       if userObject.email.count == 0{
           self.view.makeToast(message: "Please enter valid email Id." , duration: 3, position: HRToastActivityPositionDefault)
           return
       }else if userObject.email.isValidEmail == false {
           
           self.view.makeToast(message: "Please enter valid email Id." , duration: 3, position: HRToastActivityPositionDefault)
           return
       }else {
           
           self.sendOTPAction()
           
       }
   }
    
    @objc func dobInfoButtonAction(){
        self.view.endEditing(true)
        let alert = UIAlertController(title: "Why do I need to provide my date of birth?", message: "Providing your birthday helps make sure that you get the right PickZon experience for your age. No one will see this on your profile.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
   func getAllJobListApi(){
    
    let params = NSMutableDictionary()
    
    Themes.sharedInstance.activityView(View: self.view)
    
    URLhandler.sharedinstance.makeGetCall(url:Constant.sharedinstance.getAllJob, param: params, completionHandler: {(responseObject, error) ->  () in
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
            
                if let  jobArr = result["payload"] as? NSArray {
                    
                    for dict in jobArr {
                        self.jobArray.append((dict as! Dictionary)["jobName"] ?? "")
                        self.jobIdArray.append((dict as! Dictionary)["_id"] ?? "")
                    }
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

    func uploadImage(image:UIImage){
          
          Themes.sharedInstance.activityView(View: self.view)
          
        URLhandler.sharedinstance.uploadImageWithParameters(profileImg:image, imageName:(isProfileSelected) ? "images" : "coverImage", url: Constant.sharedinstance.uploadProfileImage, params: [:])
          {  response in
              Themes.sharedInstance.RemoveactivityView(View: self.view)
              
               //let msg = response["message"] as? String ?? ""
               let status = response["status"] as? Int16 ?? 0
               
              if status == 1 {
                  let payload = response["payload"] as? NSDictionary ?? [:]
                  if self.isProfileSelected{
                      self.imageUrl = payload["profileImage"] as? String ?? ""
                      self.profileThumbUrl = payload["profileThumbUrl"] as? String ?? ""
                  }else{
                      self.coverImageS3 = payload["coverImageS3"] as? String ?? ""
                      self.coverImageS3Compress = payload["coverImageS3Compress"] as? String ?? ""
                      
                  }
              }
          }
      }
    
    
    func hashingCreatorApi(){
      
        let dictParams:NSDictionary = ["deviceId" : "\(Themes.sharedInstance.getDeviceUUIDString())","OS" : "ios","modelName" : "\(UIDevice.current.model)","manufacturerId" : [17, 3, 52,64, 92, 87, 22], "version":"\(Themes.sharedInstance.osVersion)"]
        
        let url = "\(Constant.sharedinstance.hashingCreator)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        URLhandler.sharedinstance.makePostAPICall(url: url, param: dictParams, completionHandler: {(responseObject, error) ->  () in
                   Themes.sharedInstance.RemoveactivityView(View: self.view)
                   if(error != nil)
                   {
                       self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                   }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int64 ?? 0
                let message = result["message"]
                if status == 1{
                    if let payload = result["payload"] as? Dictionary<String,Any> {
                        let securityAuthToken = payload["securityAuthToken"] as? String ?? ""
                        if securityAuthToken.length > 0 {
                            Themes.sharedInstance.saveSecurityAuthToken(securityAuthToken: securityAuthToken)
                        }
                        self.randomNumber = payload["randomNumber"] as? Int64 ?? 0
                        self.updateUserDataApi()
                    }
                                    
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
  
     func updateUserDataApi() {
        var dobSend = ""
        if userObject.dob.length > 0 {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let dt = dateFormatter.date(from: userObject.dob)
            
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "yyyy-MM-dd"
            dobSend =  dateFormatter1.string(from: dt!)
        }
         let countryISO: String? = (NSLocale.current as NSLocale).countryCode ?? ""
         let params:NSDictionary = ["socialId":socialId, "password":userObject.password,"countryISO":countryISO,  "name":userObject.fullName,"dob":dobSend, "gender":userObject.gender, "mobileNumber":mobileNumber, "countryCode":countryCode, "profilePic":imageUrl, "userReferralCode":userObject.referalCode,  "timeZone":localTimeZoneIdentifier, "email":userObject.email, "jobProfile":userObject.position, "livesIn":userObject.location, "thumbProfilePic":profileThumbUrl,  "randomNumber":self.randomNumber,"coverImageS3":coverImageS3,"coverImageS3Compress":coverImageS3Compress, "headline":userObject.headline, "gcm_id":UserDefaults.standard.string(forKey: "fcm_token") ?? ""]
                 
        
        Themes.sharedInstance.activityView(View: self.view)
      
         URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.createNewUser, param: params) { (responseObject, error) -> () in

            
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
               
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int64 ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    
                    if let userDetailDict = result["payload"] as? NSDictionary{
                       
                        let user_ID = userDetailDict["userId"] as? String ?? ""
                        
                        //To display the welcome popup
                        let popUpUrl = userDetailDict["popUpUrl"] as? String ?? ""
                        if popUpUrl.length > 0 {
                            UserDefaults.standard.set(popUpUrl, forKey: "popUpUrl")
                            UserDefaults.standard.set(true, forKey: "isDisplayWelcomePointAlert")
                        }else {
                            
                            UserDefaults.standard.set(false, forKey: "isDisplayWelcomePointAlert")
                        }
                        UserDefaults.standard.synchronize()
                        
                        let authToken = userDetailDict["authToken"] as? String ?? ""
                        if authToken.length > 0 {
                            Themes.sharedInstance.saveAuthToken(authToken: authToken)
                        }
                        
                        
                        let Dic
                        : NSDictionary  = ["user_id":user_ID,"status":"","mobilenumber":self.msisdn,"name":self.userObject.fullName,"profilepic":"","current_call_status":"0","call_id":"","wallpaper_type" : "default", "wallpaper" : "", "status_privacy" : "0", "otp" : Themes.sharedInstance.CheckNullvalue(Passed_value: "")]

                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict:  Dic , Entityname: Constant.sharedinstance.User_detail)
                        
                        let Dict:Dictionary = ["user_id":user_ID, "login_key":String(Date().ticks), "is_updated" : "0"]
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Login_details)
                                                
                        if let imgUrl = userDetailDict["profilePic"]{
                         
                            var image_Url = Themes.sharedInstance.CheckNullvalue(Passed_value: imgUrl)
                            if(image_Url.substring(to: 1) == ".")
                            {
                                image_Url.remove(at: image_Url.startIndex)
                                image_Url = ("\(ImgUrl)\(image_Url)")
                            }
                            //let imageUrl:String = ("\(ImgUrl)\(image_Url)")
                            
                            let CheckUser:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString:user_ID as String?)
                            if (!CheckUser){
                            }
                            else{
                                let UpdateDict:[String:Any]=["profilepic": image_Url]
                                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail , FetchString: user_ID, attribute:"user_id" , UpdationElements: UpdateDict as NSDictionary?)
                            }
                                            
                        }
                        
                        self.updateUserInfoInDB(respdict: userDetailDict)
                        
                    }
                    
                
                        let updateDict=["name":Themes.sharedInstance.CheckNullvalue(Passed_value: self.userObject.fullName), "email":Themes.sharedInstance.CheckNullvalue(Passed_value: self.userObject.email)]
                        
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: updateDict as NSDictionary?)
                    
                    //Remove the SecurityAuthToken
                    Themes.sharedInstance.removeSecurityAuthToken()
                    
                    //Disconnect the socket so the it can be connected with latest User ID
                    DispatchQueue.global(qos: .background).async {
                        SocketIOManager.sharedInstance.socket.disconnect()
                    }
                        
                let alertview = JSSAlertView().show(self,title: "Pickzon",text: message ,buttonText: "Ok",cancelButtonText: nil ,color: CustomColor.sharedInstance.newThemeColor)
                alertview.addAction {
                   
                    UserDefaults.standard.setValue(true, forKey: Constant.sharedinstance.isProfileInfoAvailable)
                    UserDefaults.standard.synchronize()
                    (UIApplication.shared.delegate as! AppDelegate).MovetoRooVC()
                }
                }
                else
                {
                    DispatchQueue.main.async {
                        
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)}
                }
            }
        }
    }
    
   
    func updateUserInfoInDB(respdict:NSDictionary) {
        
        var objUser = PickzonUser(respdict: [:])
        objUser.id = respdict["userId"] as? String ?? ""
        objUser.dob = respdict["dob"] as? String ?? ""
        objUser.email = respdict["email"] as? String ?? ""
        objUser.gender = respdict["gender"] as? String ?? ""
        objUser.jobProfile = respdict["jobProfile"] as? String ?? ""
        objUser.livesIn = respdict["livesIn"] as? String ?? ""
        objUser.mobileNo = (respdict["countryCode"] as? String ?? "") + (respdict["mobileNumber"] as? String ?? "")
        objUser.name = respdict["name"] as? String ?? ""
        objUser.profilePic = respdict["profilePic"] as? String ?? ""
        objUser.pickzonId = respdict["tiktokName"] as? String ?? ""
        objUser.usertype = respdict["usertype"] as? Int ?? 0
        objUser.website = respdict["website"] as? String ?? ""
        objUser.postCount = respdict["total_post"] as? String ?? ""
        objUser.followingCount = respdict["total_following"] as? String ?? ""
        objUser.followerCount = respdict["total_fans"] as? String ?? ""
        objUser.actualProfileImage = respdict["thumbProfilePic"] as? String ?? ""
        objUser.avatar = respdict["avatar"] as? String ?? ""
        objUser.giftingLevel = respdict["giftingLevel"] as? String ?? ""

        DBManager.shared.insertOrUpdateUSerDetail(userId: objUser.id, userObj: objUser)
        Themes.sharedInstance.savePickZonID(pickzonId: objUser.pickzonId)
    }
}


extension ProfileInfoViewController:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    
    //MARK: UItableview Delegate and datasource methods
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return titleArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  indexPath.row ==  (titleArray?.count ?? 0) - 1 && socialId.length == 0{
            return 115
        }else {
            return 65
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Email Verify
        /*if indexPath.row == 1 {
            let ddCell = tableView.dequeueReusableCell(withIdentifier: "EmailCell") as! EmailCell

            if isVerifyEmail == true{
                ddCell.btnVerify.setTitle("Verified", for: .normal)
                ddCell.btnVerify.setTitleColor(UIColor.green, for: .normal)
                ddCell.btnVerify.isUserInteractionEnabled = false
                ddCell.txtfield.isUserInteractionEnabled = false
            }
            
            ddCell.txtfield.addRightPaddingWithValue(paddingValue: 65)
            
            ddCell.btnVerify.addTarget(self, action: #selector(verifyEmailButtonAction), for: .touchUpInside)
           //  ddCell.txtfield.placeholder = titleArray?[indexPath.row] as? String ?? ""
            ddCell.txtfield.delegate = self
            ddCell.txtfield.tag = indexPath.row
            ddCell.backgroundColor = UIColor.white
            ddCell.txtfield.errorColor = UIColor.red
            
            ddCell.txtfield.setAttributedPlaceHolder(frstText: titleArray?[indexPath.row] as? String ?? "", color: UIColor.lightGray, secondText: "*", secondColor: UIColor.red)
            
            ddCell.txtfield.iconWidth = 20
            ddCell.txtfield.iconImage = UIImage(named: iconArray?[indexPath.row] as? String ?? "")
            ddCell.txtfield.iconColor = UIColor.lightGray
            ddCell.txtfield.text = userObject.email
            
            
            
            return ddCell
        }else*/ if indexPath.row == 1{
            let genderCell = tableView.dequeueReusableCell(withIdentifier: "GenderTblCell") as! GenderTblCell
            genderCell.backgroundColor = .systemBackground
            genderCell.segmentedcontrol.layer.borderColor = UIColor.lightGray.cgColor
            genderCell.segmentedcontrol.layer.borderWidth = 1.0
            
            
            genderCell.segmentedcontrol.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
            genderCell.segmentedcontrol.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)
            genderCell.segmentedcontrol.addTarget(self, action: #selector(indexChanged(_:)), for: .valueChanged)
            
            if userObject.gender.lowercased() == "male"{
                genderCell.segmentedcontrol.selectedSegmentIndex = 0
            }else if userObject.gender.lowercased() == "female"{
                genderCell.segmentedcontrol.selectedSegmentIndex = 1

            }else if userObject.gender.lowercased() == "others"{
                genderCell.segmentedcontrol.selectedSegmentIndex = 2
            }
            return genderCell
        }else if  indexPath.row ==  (titleArray?.count ?? 0) - 1 && socialId.length == 0{
            
            
            let ddCell = tableView.dequeueReusableCell(withIdentifier: "PasswordCell") as! PasswordCell

            ddCell.txtPassword.delegate = self
            ddCell.txtPassword.tag = 100
            ddCell.backgroundColor = .systemBackground
            ddCell.txtPassword.errorColor = UIColor.red
            
            ddCell.txtPassword.setAttributedPlaceHolder(frstText: "Password", color: UIColor.label, secondText: "*", secondColor: UIColor.red)
            
            ddCell.txtPassword.iconWidth = 20
            ddCell.txtPassword.iconImage = UIImage(named: iconArray?[indexPath.row] as? String ?? "")
            ddCell.txtPassword.iconColor = UIColor.lightGray
            
            
            ddCell.txtConfirmPassword.delegate = self
            ddCell.txtConfirmPassword.tag = 101
            ddCell.backgroundColor = .systemBackground
            ddCell.txtConfirmPassword.errorColor = UIColor.red
            
            ddCell.txtConfirmPassword.setAttributedPlaceHolder(frstText: "Confirm Password", color: UIColor.label, secondText: "*", secondColor: UIColor.red)
            
            ddCell.txtConfirmPassword.iconWidth = 20
            ddCell.txtConfirmPassword.iconImage = UIImage(named: iconArray?[indexPath.row] as? String ?? "")
            ddCell.txtConfirmPassword.iconColor = UIColor.lightGray
            
            return ddCell
            
        }

        
        let ddCell = tableView.dequeueReusableCell(withIdentifier: "ProfileInfoTblCell") as! ProfileInfoTblCell

       //  ddCell.txtfield.placeholder = titleArray?[indexPath.row] as? String ?? ""
        ddCell.btnInfo.isHidden = true
        ddCell.txtfield.delegate = self
        ddCell.txtfield.tag = indexPath.row
        ddCell.backgroundColor = .systemBackground
        ddCell.txtfield.errorColor = UIColor.red
        if indexPath.row == 0 || indexPath.row == 5{
        ddCell.txtfield.setAttributedPlaceHolder(frstText: titleArray?[indexPath.row] as? String ?? "", color: UIColor.lightGray, secondText: "*", secondColor: UIColor.red)
        }else{
            ddCell.txtfield.setAttributedPlaceHolder(frstText: titleArray?[indexPath.row] as? String ?? "", color: UIColor.lightGray, secondText: "", secondColor: UIColor.red)
        }
        ddCell.txtfield.iconWidth = 20
        ddCell.txtfield.iconImage = UIImage(named: iconArray?[indexPath.row] as? String ?? "")
        ddCell.txtfield.iconColor = UIColor.lightGray
        switch indexPath.row{

        case 0:
            ddCell.txtfield.autocapitalizationType = .words
            ddCell.txtfield.text = userObject.fullName
            break
      /*  case 1:
            ddCell.txtfield.text = userObject.headline
            break
        case 2:
            ddCell.txtfield.text = userObject.position
            break
        case 3:
            ddCell.txtfield.text = userObject.location
            break*/
        case 2:
            ddCell.txtfield.text = userObject.dob
            ddCell.btnInfo.isHidden = false
            ddCell.btnInfo.addTarget(self, action: #selector(dobInfoButtonAction), for: .touchUpInside)
            break

       
        case 3:
            ddCell.txtfield.text = userObject.referalCode
            
            break

        default:
            break
        }
        
        return ddCell
    }
    
    
    
    //MARK: - UItextfield Delegate methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
       // let previousText:NSString = textField.text! as NSString
      //  let updatedText = previousText.replacingCharacters(in: range, with: string)
        
        if textField.tag == 0{
            if string.isEmpty {
                return true
            }
            let alphaNumericRegEx = #"[a-zA-Z\s]"#
            let predicate = NSPredicate(format:"SELF MATCHES %@", alphaNumericRegEx)
            return predicate.evaluate(with: string)
            
        }
        /*else if textField.tag == 1{
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
        */
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
//        if textField.tag == 1{
//            textField.keyboardType = .emailAddress
//        }else
        if textField.tag == 2{
            self.view.endEditing(true)
            showDOBDatePicker()
            return false
        }
            
            /*
             
             else if textField.tag == 3{
                 
                 self.view.endEditing(true)
                 let destVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "SearchLocationVC") as! SearchLocationVC
                 destVC.delegate = self
                 self.navigationController?.pushViewController(destVC, animated: true)
                 return false  }
             self.view.endEditing(true)
             let vc = UIStoryboard(name: "LetGo", bundle: nil).instantiateViewController(withIdentifier: "SearchResultTableViewController") as! SearchResultTableViewController
             vc.delegate = self
             self.navigationController?.setNavigationBarHidden(false, animated: true)
             self.navigationController?.pushViewController(viewController: vc, completion: {})
             return false*/
      
       /* else if textField.tag == 4{
            self.view.endEditing(true)
            
            ActionSheetMultipleStringPicker.show(withTitle: "", rows: [
                jobArray
            ], initialSelection: [0, 0], doneBlock: {
                picker, indexes, values in
            
                 if let str = (values as AnyObject?) as? NSArray {
                 
                     self.userObject.job   = str[0] as? String ?? ""
                     self.tblView.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .none)
                 }
                
                return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: textField)
            return false
        }else if textField.tag == 5{
            self.view.endEditing(true)
            let vc = UIStoryboard(name: "LetGo", bundle: nil).instantiateViewController(withIdentifier: "SearchResultTableViewController") as! SearchResultTableViewController
            vc.delegate = self
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.pushViewController(viewController: vc, completion: {
                
            })
            return false
        }
        */
        
        return true
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
        textField.text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        switch textField.tag
        {
     
        case 0:
            textField.text = textField.text?.condenseWhitespace()
            userObject.fullName = textField.text ?? ""
            break
//        case 1:
//            userObject.headline = textField.text ?? ""
//            break
//        case 2:
//            userObject.position = textField.text ?? ""
//            break
            
        /*case 1:
            userObject.email = textField.text ?? ""
            
            break
         */
        case 3:
            userObject.referalCode = textField.text ?? ""
            break
            
        case 100:
            userObject.password = textField.text ?? ""
            break
        case 101:
            userObject.confirmPassword = textField.text ?? ""
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
//            if let text = textfield.text {
//                if let floatingLabelTextField = textfield as? SkyFloatingLabelTextFieldWithIcon {
//                    if(text.count < 3 || !text.contains("@")) {
//                        floatingLabelTextField.errorMessage = "Invalid email"
//                    }
//                    else {
//                        // The error message will only disappear when we reset it to nil or empty string
//                        floatingLabelTextField.errorMessage = ""
//                    }
//                }
//            }
        }
    
    @objc func indexChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            userObject.gender = "Male"
        } else if sender.selectedSegmentIndex == 1 {
            userObject.gender = "Female"
        } else if sender.selectedSegmentIndex == 2 {
            userObject.gender = "Others"
        }
        self.tblView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)

    }
    
    //MARK: - SearchLocationResultDelegate
    func LocationSelected(searchRegion: MKCoordinateRegion, locationString:String) {
        LocationHelper.shared.getReverseGeoCodedLocationUpdated(location: CLLocation.init(latitude: searchRegion.center.latitude, longitude: searchRegion.center.longitude)) { (location, placemark, error) in
            self.userObject.location = ""
            self.userObject.location = placemark?.locality ?? ""
            self.userObject.location = (self.userObject.location) + "," + " " + (placemark?.country ?? "")
            self.tblView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .none)
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
         datePicker.setYearValidation(year: 13)
         
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
        self.userObject.dob = dateString
        
//        let dateFormatter1 = DateFormatter()
//        dateFormatter1.dateFormat = "yyyy-MM-dd"
//        self.userObject.dob = dateFormatter1.string(from: datePicker.date)
        self.tblView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)

        viewDatePicker.removeFromSuperview()
    }
    
}

extension ProfileInfoViewController:LocationDelegate,SearchLocationDelegate{
    
    
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
        self.tblView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .none)
    }
    
    
    func selectedLocation(locObj:LocationModal){
        
        self.userObject.location = locObj.locationName
        self.locationObj = locObj
        self.tblView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .none)
        
    }
}


extension ProfileInfoViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate,RSKImageCropViewControllerDelegate,RSKImageCropViewControllerDataSource{
    
    func openCamera(){
       
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
        if isProfileSelected == false {
            let imageCropVC = RSKImageCropViewController(image: image)
            imageCropVC.delegate = self
            imageCropVC.dataSource = self
            imageCropVC.cropMode = .custom
            imageCropVC.preferredContentSize = .init(width: self.view.frame.size.width, height: self.view.frame.size.width/2.0)
            imageCropVC.avoidEmptySpaceAroundImage = true
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
        
        if isProfileSelected == true {
            user_image.image = croppedImage
        }else{
            
            imgViewBanner.image = croppedImage
        }
        self.pop(animated: true)
    }
    
   
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat)
    {
        self.pop(animated: true)
        
        self.CheckNudityforImage(image: croppedImage)
       
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
                    if self.isProfileSelected == true {
                        self.user_image.image = image
                        self.uploadImage(image: image)
                    }else{
                        self.imgViewBanner.image = image
                        self.uploadImage(image: image)
                        
                    }
                     
                }
            }
        }
    }
}



class ProfileInfoTblCell:UITableViewCell{
    
    @IBOutlet weak var txtfield:SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var bgView:UIView!
    @IBOutlet weak var btnInfo:UIButton!
    
}

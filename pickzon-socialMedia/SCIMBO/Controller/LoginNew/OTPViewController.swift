
//
//  OTPViewController.swift
//
//
//  Created by CASPERON on 29/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit
import JSSAlertView
import SWMessages
import PinCodeTextField
import SDWebImage
import IQKeyboardManager
import Alamofire
import Firebase
import FirebaseAuth

@available(iOS 10.0, *)
class OTPViewController: UIViewController {
    
    @IBOutlet weak var lblMsg: UILabel!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var mob_numberFld: CustomLblFont!
    @IBOutlet weak var timer_Lbl:UILabel!
    @IBOutlet weak var nextBtn:UIButton!
    @IBOutlet var otpFeilds: [UITextFieldX]!
    @IBOutlet weak var mobileNumberLbl: UILabel!
    @IBOutlet weak var resend_button: UIButton!
    @IBOutlet weak var wrapper_view: UIView!
    @IBOutlet weak var view5:UIViewX!
    @IBOutlet weak var view6 :UIViewX!
    
    var otpNo:String = ""
    var mssidn_No:String = ""
    var mssidn_OldNo:String = ""
    var User_id:String = ""
    var Name:String = ""
    var emailId:String = ""
    var status:String = ""
    var jobProfile:String = ""
    var livesIn:String = ""
    var profilePicUrl:String = ""
    var gender:String = ""
    var dob:String = ""
    var hashcode:String = ""
    var randomNumber:Int64 = 0
    var isFromProduction:Bool = Bool()
    var PhNumber:String = String()
    var CountryCode:String = String()
    var tikTokName:String=String()

    var imageUrl:String=String()
    var minute:Double = Double()
    var seconds:Double = Double()
    var timer:Timer = Timer()
    var profilePic:String = String()
    var DetailDic:NSMutableDictionary = NSMutableDictionary()
    var fromUpdateNumber: Bool = false
    var previousTF:UITextFieldX?

    //var
    var URL_handler:URLhandler = URLhandler()
    var db_Handler = DatabaseHandler()
    var countdownTimer = Timer()
    var counter = 60
    var user_info:NSDictionary = [:]
    var isFirebaseUsed = false
    
    var isSignup = false
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print("UIViewController: OTPViewController")
        UserDefaults.standard.setValue(false, forKey: videosStartWithSound)
        otpFeilds[0].textContentType = .oneTimeCode
        if fromUpdateNumber{
            self.hashingCreatorApi()
        }
        otpFeilds[0].delegate = self
        otpFeilds[1].delegate = self
        otpFeilds[2].delegate = self
        otpFeilds[3].delegate = self
        otpFeilds[4].delegate = self
        otpFeilds[5].delegate = self
        updateView()
        otpFeilds[0].becomeFirstResponder()
        self.hideKeyboardWhenTappedAround()
        if mssidn_No.contains("9417169139"){
            otpNo = "1234"
        }
        
        
        if isSignup == true {
            if PhNumber.length > 0 {
                lblMsg.text = "Please enter the OTP, You received on Phone"
                mobileNumberLbl.text = "\(self.CountryCode)\(self.PhNumber)"
            }else {
                lblMsg.text = "Please enter the OTP, You received in Email"
                mobileNumberLbl.text = "\(self.emailId)"
            }
        }else {
            mobileNumberLbl.text = mssidn_No
        }
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14) as Any,NSAttributedString.Key.foregroundColor : UIColor.white] as [NSAttributedString.Key : Any]
        let underlineAttributedString = NSAttributedString(string: "Resend OTP", attributes: underlineAttribute)
        resend_button.setAttributedTitle(underlineAttributedString, for: .normal)
        seconds = 60
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:  #selector(OTPViewController.updateTimerLabel), userInfo: nil, repeats: true)
        resend_button.isUserInteractionEnabled = false
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }

    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }

    override func viewWillDisappear(_ animated: Bool) {

        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        countdownTimer.invalidate()
        PlayerHelper.shared.pausePlayer()
    }
        
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.updateConstraintsIfNeeded()
    }
    
    override var prefersStatusBarHidden: Bool {
          return true
      }
      
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Initial Setup MEthods
    func updateView(){
        if isFirebaseUsed == true {
            view5.isHidden = false
            view6.isHidden = false
        }else {
            view5.isHidden = true
            view6.isHidden = true
        }
    }
    
    @objc func updateTime() {

    if counter > 0{
        lblTimer.text = "\(counter)"
        counter -= 1

        }else{
            countdownTimer.invalidate()
            resend_button.isUserInteractionEnabled = true
            counter = 60
            lblTimer.text = "0"
        }
    }
    
//    func SendOTP(To:String,OTP:String){
//
//        let param:NSDictionary = ["msisdn":"\(mssidn_No)","hashcode":""]
//
//        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.SendOTP, param: param) { (responseObject, error) -> () in
//
//            if(error != nil)
//            {
//                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
//
//                print(error ?? "defaultValue")
//            }else{
//                print(responseObject ?? "response")
//                let result = responseObject! as NSDictionary
//                let errNo = result["errNum"] as! String
//                let message = result["message"]
//
//                if errNo == "99"{
//
//                    if let strOtp = result["otp"] as? Int {
//                        self.otpNo = "\(strOtp)"
//                        self.resendOTP(strOtp: "\(strOtp)")
//                    }
//                }else{
//                    self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)
//
//                }
//
//            }
//
//        }
//    }
    
    //MARK: UIButton Action Methods
    @IBAction func textChangedAction(_ sender: UITextFieldX) {
        
        if sender.textContentType == .oneTimeCode {
            if isFirebaseUsed == true {
                otpFeilds[0].maxLength = 6
                if let otpCode = sender.text, otpCode.count == 6{
                    otpFeilds[0].text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 0)])
                    otpFeilds[1].text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 1)])
                    otpFeilds[2].text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 2)])
                    otpFeilds[3].text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 3)])
                    otpFeilds[4].text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 4)])
                    otpFeilds[5].text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 5)])
                }
            }else {
                otpFeilds[0].maxLength = 4
                if let otpCode = sender.text, otpCode.count == 4{
                    otpFeilds[0].text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 0)])
                    otpFeilds[1].text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 1)])
                    otpFeilds[2].text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 2)])
                    otpFeilds[3].text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 3)])
                }
            }
        }
    }

    @IBAction func resendAction(_ sender: UIButton) {
       
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        resend_button.isUserInteractionEnabled = false
        self.hashingCreatorApi()
    }
    

   
    @IBAction func nextAction(_ sender: UIButton) {
        view.endEditing(true)
        
        if isFirebaseUsed == true {
            let otp = otpFeilds[0].text!+otpFeilds[1].text!+otpFeilds[2].text!+otpFeilds[3].text!+otpFeilds[4].text!+otpFeilds[5].text!
            if otp.count < 6{
                Themes.sharedInstance.ShowNotification("Please enter correct OTP number", false)
            }else {
                if isSignup == true {
                    self.CallVerifyMobileEmailOTPAPI()
                }else {
                    self.verfiyOTPFirebase()
                }
            }
        }else {
            let otp = otpFeilds[0].text!+otpFeilds[1].text!+otpFeilds[2].text!+otpFeilds[3].text!
            if otp.count < 4{
                Themes.sharedInstance.ShowNotification("Please enter correct OTP number", false)
            }else {
                if isSignup == true {
                    self.CallVerifyMobileEmailOTPAPI()
                    
                }else {
                    self.makePostAPICallWithTwoHeaders(uuid: "")
                }
            }
        }
        
    }
    
    //MARK: Api Methods
    
   
    
    func resendOTP(strOtp:String){
        
        let param:NSDictionary = ["otp":"\(strOtp)","msisdn":mssidn_No, "manufacturer":"Apple","OS":"ios","Version":"\(Themes.sharedInstance.osVersion)","DeviceId":Themes.sharedInstance.getDeviceUUIDString(),"DateTime":"\(Themes.sharedInstance.current_Time)","PhNumber":self.PhNumber,"CountryCode":self.CountryCode, "callToken":Themes.sharedInstance.getCallToken()]
        
        Themes.sharedInstance.activityView(View: self.view)
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.RegisterNo as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                
                print(error ?? "defaultValue")
            }
            else{
                print(responseObject ?? "response")
                let result = responseObject! as NSDictionary
                let errNo = result["errNum"] as! String
                let message = result["message"]
                if errNo == "0"{
                    self.otpNo = Themes.sharedInstance.CheckNullvalue(Passed_value: result["code"])
                    if self.mssidn_No.contains("9417169139"){
                        self.otpNo = "1234"
                    }
                    self.resend_button.setTitleColor(UIColor.lightGray, for:.normal)
                    self.resend_button.isUserInteractionEnabled = false
                    self.seconds = 60
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:  #selector(OTPViewController.updateTimerLabel), userInfo: nil, repeats: true)
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
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
                    }
                    if self.isSignup == true {
                        self.callsendEmailMobileOtpAPI()
                    }else {
                        self.sendOtpWithNewHashCodeApi()
                    }
                    
                
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    func callsendEmailMobileOtpAPI (){
        var param:NSDictionary = [:]
        param = ["email":"\(self.emailId)",  "countryCode":CountryCode,"mobileNumber":"\(PhNumber)", "randomNumber": self.randomNumber, "otpHashcode":""]
        
        Themes.sharedInstance.activityView(View: self.view)
        
        
        
        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.sendEmailMobileOtpURL, param: param) { (responseObject, error) -> () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            //self.NextButton.isUserInteractionEnabled = true
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                
                print(error ?? "defaultValue")
                
            }else{
                print(responseObject ?? "response")
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
                
                if status == 1{
                    let payload = result["payload"] as? NSDictionary ?? [:]
                    
                    let otpStatus = payload["otpStatus"] as? Int ?? 0
                    if otpStatus == 0 {
                        self.isFirebaseUsed = false
                    }else {
                        self.isFirebaseUsed = true
                    }
                    
                    let securityAuthToken = payload["securityAuthToken"] as? String ?? ""
                    if securityAuthToken.length > 0 {
                        Themes.sharedInstance.saveSecurityAuthToken(securityAuthToken: securityAuthToken)
                    }
                    
                    self.randomNumber = payload["randomNumber"] as? Int64 ?? 0
                    
                    
                    self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)
                    
                }else{
                    self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)
                    
                }
                
            }
        }
    
    }
    
    
    func sendOtpWithNewHashCodeApi(){
                
        let dictParams:NSDictionary = ["countryCode":"\(self.CountryCode)","mobileNumber":"\(self.PhNumber)","randomNumber":self.randomNumber]
       let url = "\(Constant.sharedinstance.sendMobileOtpURL)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        Themes.sharedInstance.activityView(View: self.view)
        
        
        URLhandler.sharedinstance.makePostAPICall(url: url, param: dictParams, completionHandler: {(responseObject, error) ->  () in
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
                     {
                         self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
         
                         print(error ?? "defaultValue")
         
                     }else{
                         print(responseObject ?? "response")
                         let result = responseObject! as NSDictionary
                         let status = result["status"] as? Int64 ?? 0
                         let message = result["message"] as? String ?? ""

                         if status == 1{
                             if let payload = result["payload"] as? Dictionary<String,Any>  {
                                 
                                 let CheckLogin:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: nil)
                                 if(CheckLogin)
                                 {
                                     DatabaseHandler.sharedInstance.truncateDataForTable(Entityname: Constant.sharedinstance.User_detail)
                                 }
                                 
                                 
                                 let securityAuthToken = payload["securityAuthToken"] as? String ?? ""
                                 if securityAuthToken.length > 0 {
                                     Themes.sharedInstance.saveSecurityAuthToken(securityAuthToken: securityAuthToken)
                                 }
                                 self.randomNumber = payload["randomNumber"] as? Int64 ?? 0
                                 
                                 let otpStatus = payload["otpStatus"] as? Int ?? 0
                                 if otpStatus == 0 {
                                     self.isFirebaseUsed = false
                                     let alertController = UIAlertController(title: "Pickzon", message: message, preferredStyle: .alert)
                                     let OKAction = UIAlertAction(title: "OK", style: .default) {
                                         (action: UIAlertAction!) in
                                         
                                     }
                                     alertController.addAction(OKAction)
                                     self.present(alertController, animated: true, completion: nil)
                                 }else{
                                     self.isFirebaseUsed = true
                                     self.sendOTPUsingFirebase()
                                 }
                             }
                             
                         }else{
                             self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
         
                         }
         
                     }
        })
    }
  
    func sendOTPUsingFirebase() {
        let phoneNumber = mssidn_No
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                if let error = error {
                    self.view.makeToast(message: error.localizedDescription , duration: 3, position: HRToastActivityPositionDefault)
                    return
                }else {
                    // Sign in using the verificationID and the code sent to the user
                    // ...
                    UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                    let otp = "0"
                    
                }
            }
    }
    
    func  CallVerifyMobileEmailOTPAPI(){
        
        let otp =   (isFirebaseUsed) ? otpFeilds[0].text!+otpFeilds[1].text!+otpFeilds[2].text!+otpFeilds[3].text!+otpFeilds[4].text!+otpFeilds[5].text!  : otpFeilds[0].text!+otpFeilds[1].text!+otpFeilds[2].text!+otpFeilds[3].text!

        let param:NSDictionary = ["otp":otp, "email":self.emailId, "countryCode":self.CountryCode,"mobileNumber":self.PhNumber, "randomNumber":self.randomNumber]
        
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.verifyEmailMobileOtp, param: param) { (responseObject, error) -> () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                
                print(error ?? "defaultValue")
                
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int64
                let message = result["message"]
                
                    if status == 1{
                     
                        let  payload = result["payload"] as? NSDictionary ?? NSDictionary()
                        
                        let securityAuthToken = payload["securityAuthToken"] as? String ?? ""
                        if securityAuthToken.length > 0 {
                            Themes.sharedInstance.saveSecurityAuthToken(securityAuthToken: securityAuthToken)
                        }
                        self.randomNumber = payload["randomNumber"] as? Int64 ?? 0
                        
                        let profileVC = StoryBoard.prelogin.instantiateViewController(withIdentifier:"ProfileInfoID" ) as! ProfileInfoViewController
                        profileVC.randomNumber = self.randomNumber
                        profileVC.countryCode = self.CountryCode
                        profileVC.mobileNumber = self.PhNumber
                        profileVC.isEmailMobileVerified = true
                        profileVC.user_info.setValue(self.emailId, forKey: "email")
                        
                        self.pushView(profileVC, animated: true)
                        
                    }else{
                        self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        }
  
    func  makePostAPICallWithTwoHeaders(uuid:String){
        
        let otp =   (isFirebaseUsed) ? otpFeilds[0].text!+otpFeilds[1].text!+otpFeilds[2].text!+otpFeilds[3].text!+otpFeilds[4].text!+otpFeilds[5].text!  : otpFeilds[0].text!+otpFeilds[1].text!+otpFeilds[2].text!+otpFeilds[3].text!

        
       /* let param:NSDictionary = ["countryCode":self.CountryCode,"mobileNumber":self.PhNumber,"otp":otp, "randomNumber":self.randomNumber,"version":"\(Themes.sharedInstance.osVersion)","deviceId":Themes.sharedInstance.getDeviceUUIDString(), "manufacturer":"Apple","OS":"ios","modelName":"\(UIDevice.current.model)","uuid":uuid,"gcmId":"\(UserDefaults.standard.string(forKey: "fcm_token") ?? "")"]
        
        */
        let param:NSDictionary = ["countryCode":self.CountryCode,"mobileNumber":self.PhNumber,"otp":otp, "randomNumber":self.randomNumber,"version":"\(Themes.sharedInstance.osVersion)","deviceId":Themes.sharedInstance.getDeviceUUIDString(), "manufacturer":"Apple","OS":"ios","modelName":"\(UIDevice.current.model)","uuid":uuid,"gcmId":"\(UserDefaults.standard.string(forKey: "fcm_token") ?? "")"]
        
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.verifyMobileOtp, param: param) { (responseObject, error) -> () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                
                print(error ?? "defaultValue")
                
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int64
                let message = result["message"]
                
                    if status == 1{
                     
                        let  userDataDict = result["payload"] as? NSDictionary ?? NSDictionary()
                        self.dob = userDataDict["dob"] as? String ?? ""
                        self.emailId = userDataDict["email"] as? String ?? ""
                        self.gender = userDataDict["gender"] as? String ?? ""
                        self.jobProfile = userDataDict["jobProfile"] as? String ?? ""
                        self.livesIn = userDataDict["livesIn"] as? String ?? ""
                        self.Name = userDataDict["name"] as? String ?? ""
                        self.profilePicUrl = userDataDict["profilePic"] as? String ?? ""
                        self.tikTokName = userDataDict["tiktokName"] as? String ?? ""
                        
                         let isReferAvailable = userDataDict["isReferAvailable"] as? Int ?? 0
                        Themes.sharedInstance.saveIsReferAvailable(status: isReferAvailable)
                        
                        let isCoinReferAvailable = userDataDict["isCoinReferAvailable"] as? Int ?? 0
                       Themes.sharedInstance.saveIsCoinReferAvailable(status: isCoinReferAvailable)

                      
                        
                        self.user_info = userDataDict
                        
                        let Checkfav:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: "\(Constant.sharedinstance.Login_details)", attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
                        if(Checkfav == false){
                            let Dict:Dictionary = ["user_id":self.User_id, "login_key":String(Date().ticks), "is_updated" : "0"]
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Login_details)
                        }
                        
                        let is_updated = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Login_details, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "is_updated")
                        print(is_updated)
                        if self.fromUpdateNumber{
                            
                            self.changePhoneNo(otp:otp)
                            
                        }else{
                            
                            let authToken = userDataDict["authToken"] as? String ?? ""
                            if authToken.length > 0 {
                                Themes.sharedInstance.saveAuthToken(authToken: authToken)
                            }
                            
                            let securityAuthToken = userDataDict["securityAuthToken"] as? String ?? ""
                            if securityAuthToken.length > 0 {
                                Themes.sharedInstance.saveSecurityAuthToken(securityAuthToken: securityAuthToken)
                            }
                            self.randomNumber = userDataDict["randomNumber"] as? Int64 ?? 0
                            var image_Url = Themes.sharedInstance.CheckNullvalue(Passed_value: self.profilePic)
                           
                            if(image_Url.substring(to: 1) == ".")
                            {
                                image_Url.remove(at: image_Url.startIndex)
                            }
                          
                            if(image_Url != "")
                            {
                                self.imageUrl = ("\(ImgUrl)\(image_Url)")
                            }
                            else
                            {
                                self.imageUrl = ""
                            }
                            
                            if(self.status == "")
                            {
                                self.status = "Hey there! I am using PickZon"
                                
                            }
                            
                            var user_id = Themes.sharedInstance.CheckNullvalue(Passed_value: userDataDict.value(forKey: "_id"))
                            if(user_id == "")
                            {
                                user_id = self.User_id
                            }
                            else
                            {
                                self.User_id = user_id
                            }
                            
                            Themes.sharedInstance.savepublicKey(DeviceToken: "")
                            Themes.sharedInstance.savesPrivatekey(DeviceToken: "")
                            Themes.sharedInstance.savesecurityToken(DeviceToken: "")
                            let token = Themes.sharedInstance.CheckNullvalue(Passed_value: result["token"])
                            KeychainService.removePassword()
                            KeychainService.savePassword(service: user_id, data: token)
                            Themes.sharedInstance.savesecurityToken(DeviceToken: token)
                            self.DetailDic=["user_id":user_id,"status":self.status,"mobilenumber":self.mssidn_No,"name":self.Name,"profilepic":self.imageUrl,"current_call_status":"0","call_id":"","wallpaper_type" : "default", "wallpaper" : "", "status_privacy" : "0", "otp" : Themes.sharedInstance.CheckNullvalue(Passed_value: otp)]
                            
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict:  self.DetailDic , Entityname: Constant.sharedinstance.User_detail)
                            (UIApplication.shared.delegate as! AppDelegate).IntitialiseSocket()
                            
                            let alertview = JSSAlertView().show(self,title: Themes.sharedInstance.GetAppname(),text: message as? String,buttonText: "OK",color: CustomColor.sharedInstance.newThemeColor)
                            alertview.addAction(self.closeCallback)
                        }
                    }else{
                        self.view.makeToast(message: message as! String , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        }
    
    
    
    func verfiyOTPFirebase(){
        
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") ?? ""
        let verificationCode = otpFeilds[0].text!+otpFeilds[1].text!+otpFeilds[2].text!+otpFeilds[3].text!+otpFeilds[4].text!+otpFeilds[5].text!
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        Themes.sharedInstance.activityView(View: self.view)
        Auth.auth().signIn(with: credential) { authResult, error in
        Themes.sharedInstance.RemoveactivityView(View: self.view)
            print(authResult)
            if let error = error {
                let authError = error as NSError
                // ...
                self.view.makeToast(message: error.localizedDescription , duration: 3, position: HRToastActivityPositionDefault)
                
                return
            }
            // User is signed in
            self.makePostAPICallWithTwoHeaders(uuid: authResult?.user.uid ?? "")
            
        }
        
    }
    
    

    func changePhoneNo(otp:String){
        
        let param:NSDictionary = [
                                    "msisdn":mssidn_OldNo,
                                    "PhNumber":PhNumber,
                                    "CountryCode":CountryCode
                                  ]
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.updateNo, param: param,isToCheckUserId:false) { (responseObject, error) ->  () in
 
            Themes.sharedInstance.RemoveactivityView(View: self.view)
           
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let payloadDict = result["payload"] as? NSDictionary ?? [:]
                let message = result["message"] as? String ?? ""
                let phoneNumber = payloadDict["PhNumber"] as? String ?? ""
                let code = payloadDict["CountryCode"] as? String ?? ""
                
                if status == 1{

                    let user_dict:NSDictionary = [
                                                "mobilenumber":self.mssidn_No,
                                                "otp":otp
                    ]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: user_dict)
                    
                    
                    let alertview = JSSAlertView().show(self,title: Themes.sharedInstance.GetAppname(),text: message,buttonText: "OK",color: CustomColor.sharedInstance.newThemeColor)
                    alertview.addAction {
                        DBManager.shared.clearDB()
                        (UIApplication.shared.delegate as! AppDelegate).Logout(istocallApi: false)
                    }
                    
                }else{
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
    }
    
    
    func getDBDetails(){
        
        let detail = db_Handler.FetchFromDatabase(Entityname: Constant.sharedinstance.User_detail, attribute: "", FetchString: "user_dp",SortDescriptor: nil)
        print(detail)
    }
    
    
    func moveHomeVC(){
        
        SDWebImageDownloader.shared().setValue(Themes.sharedInstance.getToken(), forHTTPHeaderField: "authorization")
        SDWebImageDownloader.shared().setValue(Themes.sharedInstance.Getuser_id(), forHTTPHeaderField: "userid")
        SDWebImageDownloader.shared().setValue("site", forHTTPHeaderField: "requesttype")
        SDWebImageDownloader.shared().setValue(ImgUrl, forHTTPHeaderField: "referer")

    
        if self.dob.length > 0 && self.gender.length > 0 && self.Name.length > 0{
            
            //Remove the SecurityAuthToken
            Themes.sharedInstance.removeSecurityAuthToken()
            
            if ContactHandler.sharedInstance.permissionUnknown(){
                ContactHandler.sharedInstance.GetPermission()
            }else {
            ContactHandler.sharedInstance.StoreContacts()
            }
            
            let result = (user_info.mutableCopy() as! NSMutableDictionary)
                        
                let user_ID = result["_id"] as? String ?? ""
              
                if let imgUrl = result["profilePic"]{
                 
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
            
        
                let updateDict=["name":Themes.sharedInstance.CheckNullvalue(Passed_value: self.Name), "email":Themes.sharedInstance.CheckNullvalue(Passed_value: self.emailId)]
                
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: updateDict as NSDictionary?)
            
            UserDefaults.standard.setValue(true, forKey: Constant.sharedinstance.isProfileInfoAvailable)
            UserDefaults.standard.synchronize()
            (UIApplication.shared.delegate as! AppDelegate).MovetoRooVC()
            
        }else{
         
            let ProfileVC = StoryBoard.prelogin.instantiateViewController(withIdentifier:"ProfileInfoID" ) as! ProfileInfoViewController
            ProfileVC.email = self.emailId
            ProfileVC.randomNumber = self.randomNumber
            ProfileVC.countryCode = CountryCode
            ProfileVC.mobileNumber = PhNumber
            
            ProfileVC.username = self.Name
            ProfileVC.msisdn=self.mssidn_No
            ProfileVC.user_id=self.User_id
            ProfileVC.tikTokName = self.tikTokName
            ProfileVC.livesIn = self.livesIn
            ProfileVC.jobProfile = self.jobProfile
            //ProfileVC.hashCode = hashcode
            ProfileVC.user_info = (user_info.mutableCopy() as! NSMutableDictionary)
            self.pushView(ProfileVC, animated: true)
        }
        
    }
    
   
    
    @IBAction func backAction(_ sender: UIButton) {
        self.pop(animated: true)
    }
    
    @objc func updateTimerLabel(){
        if(seconds == 0)
        {
            timer.invalidate()

        }
        else
        {
//            timer_Lbl.text = "\(Int(seconds))"
        }
        seconds -= 1
    }
    
    func closeCallback() {
        SocketIOManager.sharedInstance.establishConnection(Nickname: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()) as NSString, isLogin: true)
      //  self.storeStatus()
        DispatchQueue.main.async {
            self.moveHomeVC()
        }
    }
        
 
//    func storeStatus(){
//
//        if(!statusList_Array.contains(status))
//        {
//            statusList_Array.add(status)
//        }
//
//        if(statusList_Array.count > 0)
//        {
//            for i in 0..<statusList_Array.count
//            {
//                let checkStatus = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.status_List, attribute: "status_title", FetchString: statusList_Array[i] as? String)
//                if(!checkStatus)
//                {
//                    let Dict:NSMutableDictionary=["status_id":"\(i)","status_title":statusList_Array[i]]
//                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict, Entityname:Constant.sharedinstance.status_List)
//                }
//            }
//        }
//        SettingHandler.sharedinstance.SaveSetting(user_ID: User_id, setting_type: .notification)
//    }
}




extension OTPViewController:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

         if (string.count == 1){
                  if textField == otpFeilds[0] {
                      otpFeilds[1].becomeFirstResponder()
                  } else if textField == otpFeilds[1] {
                      otpFeilds[2].becomeFirstResponder()
                  }else if textField == otpFeilds[2] {
                      otpFeilds[3].becomeFirstResponder()
                  }else  if textField == otpFeilds[3] {
                      if isFirebaseUsed == true {
                          otpFeilds[4].becomeFirstResponder()
                      }else {
                      otpFeilds[3].resignFirstResponder()
                      }
                  }else if textField == otpFeilds[4] {
                      otpFeilds[5].becomeFirstResponder()
                  }else if textField == otpFeilds[5] {
                      otpFeilds[5].resignFirstResponder()
                  }
                  textField.text? = string
                  return false
              }else{
                  if textField == otpFeilds[0] {
                      otpFeilds[0].becomeFirstResponder()
                  }else if textField == otpFeilds[1] {
                      otpFeilds[0].becomeFirstResponder()
                  }else if textField == otpFeilds[2] {
                      otpFeilds[1].becomeFirstResponder()
                  }else  if textField == otpFeilds[3] {
                      otpFeilds[2].becomeFirstResponder()
                  }else  if textField == otpFeilds[4] {
                      otpFeilds[3].becomeFirstResponder()
                  }else  if textField == otpFeilds[5] {
                      otpFeilds[4].becomeFirstResponder()
                  }
                  textField.text? = string
                  return false
              }
    }
  
}

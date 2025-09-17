//
//  LoginVCNew.swift
//  SCIMBO
//
//  Created by gurmukh singh on 9/8/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import AuthenticationServices
import JSSAlertView
import GoogleSignIn
import Security




class LoginVCNew: UIViewController {
    
    @IBOutlet weak var lblCountrycode: UILabel!
    @IBOutlet weak var viewEmail:UIView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var viewMobile:UIView!
    @IBOutlet weak var viewPassword:UIView!

    @IBOutlet weak var viewMCountryCode:UIView!
    @IBOutlet weak var txtMobile: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnShowPassword:UIButton!
    @IBOutlet weak var btnLogin:UIButton!
    @IBOutlet weak var btnAppleLogin:UIButton!
    @IBOutlet weak var btnGmailLogin:UIButton!
    @IBOutlet weak var btnSignUp:UIButton!
    @IBOutlet weak var segmentControl:UISegmentedControl!
    
    @IBOutlet weak var btnPrivacyPolicy:UIButton!

    @IBOutlet weak var bgViewSegmentControl:UIView!
    @IBOutlet weak var imgVwDDIcon:UIImageView!
    @IBOutlet weak var btnForgotPassword:UIButton!

    var country_Code = String()
    var randomNumber: Int64 = 0
    var socialUser = ""
    var socialFullName = ""
    var socialEmail = ""
    var socialProfilePicUrl = ""
    
   
    //MARK: Controller Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgVwDDIcon.setImageColor(color: .black)
        txtEmail.setAttributedPlaceHolder(text: "Enter Email/PickZon Id", color: .lightGray)
        txtMobile.setAttributedPlaceHolder(text: "Your Mobile Number", color: .lightGray)
        txtPassword.setAttributedPlaceHolder(text: "Password", color: .lightGray)

        viewEmail.backgroundColor = CustomColor.sharedInstance.txtFdBgColor
        viewEmail.layer.cornerRadius = 20.0
        viewEmail.clipsToBounds = true
        viewMobile.backgroundColor = CustomColor.sharedInstance.txtFdBgColor
        viewMobile.layer.cornerRadius = 20.0
        viewMobile.clipsToBounds = true
        viewPassword.backgroundColor = CustomColor.sharedInstance.txtFdBgColor
        viewPassword.layer.cornerRadius = 20.0
        viewPassword.clipsToBounds = true
        
//        viewMCountryCode.layer.borderColor = UIColor.label.cgColor
//        viewMCountryCode.layer.borderWidth = 0.5
       // viewMCountryCode.layer.cornerRadius = 5.0
      //  viewMCountryCode.clipsToBounds = true
        
//        btnAppleLogin.layer.borderColor = UIColor.lightGray.cgColor
//        btnAppleLogin.layer.borderWidth = 1.0
        btnAppleLogin.backgroundColor = CustomColor.sharedInstance.txtFdBgColor
        btnAppleLogin.layer.cornerRadius = 20.0
        btnAppleLogin.clipsToBounds = true
        
        btnAppleLogin.setImageTintColor(.black)
        
//        btnGmailLogin.layer.borderColor = UIColor.lightGray.cgColor
//        btnGmailLogin.layer.borderWidth = 1.0
        btnGmailLogin.backgroundColor = CustomColor.sharedInstance.txtFdBgColor
        btnGmailLogin.layer.cornerRadius = 20.0
        btnGmailLogin.clipsToBounds = true

        btnLogin.backgroundColor = CustomColor.sharedInstance.newThemeColor
        btnLogin.layer.cornerRadius = 20.0
        btnLogin.clipsToBounds = true

        btnSignUp.setTitleColor(CustomColor.sharedInstance.newThemeColor, for: .normal)
        
        
         btnPrivacyPolicy.setTitle("Terms and Privacy Policy", for: .normal)
           
           // Create an attributed string for the button title
           let attributedString = NSMutableAttributedString(string: "Terms and Privacy Policy")
           
           // Define the attributes, including the underline style
           let underlineAttributes: [NSAttributedString.Key: Any] = [
               .underlineStyle: NSUnderlineStyle.single.rawValue,
               .foregroundColor: UIColor.label // Optional: set text color
           ]
           
           // Apply the attributes to the entire string
           attributedString.addAttributes(underlineAttributes, range: NSRange(location: 0, length: attributedString.length))
           
           // Set the attributed title for the button
         btnPrivacyPolicy.setAttributedTitle(attributedString, for: .normal)

        Themes.sharedInstance.setCountryCode(self.lblCountrycode, nil)
        country_Code = self.lblCountrycode.text!
        AppDelegate.sharedInstance.rootUSerApi()
        
        txtMobile.addTarget(self, action: #selector(textFiedDidChange(_:)), for: .editingChanged)
    
        segmentControl.backgroundColor = CustomColor.sharedInstance.txtFdBgColor
        segmentControl.selectedSegmentTintColor = CustomColor.sharedInstance.newThemeColor
        bgViewSegmentControl.layer.borderColor = CustomColor.sharedInstance.txtFdBgColor.cgColor
        bgViewSegmentControl.layer.cornerRadius = bgViewSegmentControl.bounds.height / 2.0
        bgViewSegmentControl.clipsToBounds = true
        segmentControl.applyCapsuleStyle()
    }
    

    
    @objc func textFiedDidChange(_ sender: Any) {
        var prefix = self.country_Code
        if  txtMobile.text!.hasPrefix(prefix) == true {
            if txtMobile.text!.length > prefix.length {
                txtMobile.text  = String(txtMobile.text!.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }else {
            prefix =  prefix.hasPrefix("+") ? String(prefix.dropFirst(1)): prefix
            if  txtMobile.text!.hasPrefix(prefix) == true {
                if txtMobile.text!.length > prefix.length {
                    txtMobile.text  = String(txtMobile.text!.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
        }
    }
    
    
    //MARK: INitial Setup Methods
//    func setTextInLabel(){
//        
//        let underlineAttribute = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15) as Any,NSAttributedString.Key.foregroundColor :CustomColor.sharedInstance.newThemeColor] as [NSAttributedString.Key : Any]
//        
//        let underlineAttribute1 = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15) as Any,NSAttributedString.Key.foregroundColor :CustomColor.sharedInstance.newThemeColor] as [NSAttributedString.Key : Any]
//        
//        let attributedString = NSMutableAttributedString(string: "", attributes: underlineAttribute)
//        let underlineAttributedString1 = NSAttributedString(string: "Forgot Password", attributes: underlineAttribute1)
//        attributedString.append(underlineAttributedString1)
//        self.lblPasswordForget.attributedText = attributedString
//        self.lblPasswordForget.addRangeGesture(stringRange: "Forgot Password") {
//            // Do anything here
//            let forgotPasswordVC = StoryBoard.prelogin.instantiateViewController(withIdentifier:"ForgotPasswordVC" ) as! ForgotPasswordVC
//            self.navigationController?.pushViewController(forgotPasswordVC, animated: true)
//        }
//    }
    
    //MARK: UIBUtton Action Methods
    
    
    @IBAction func forgotPasswordBtnAction(){
        let forgotPasswordVC = StoryBoard.prelogin.instantiateViewController(withIdentifier:"ForgotPasswordVC" ) as! ForgotPasswordVC
        self.navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        self.view.endEditing(true)
        txtEmail.text = ""
        txtMobile.text = ""
    
        if sender.selectedSegmentIndex == 0 {
            self.viewEmail.isHidden = true
            self.viewMobile.isHidden = false
        } else if sender.selectedSegmentIndex == 1 {
            self.viewEmail.isHidden = false
            self.viewMobile.isHidden = true
        }
        
       // segmentControl.makeCapsule()

    }
    
    
    @IBAction func showPasswordAction(){
        
        if btnShowPassword.currentImage == PZImages.showEye { //} UIImage(named: "eye-5 1") {
            btnShowPassword.setImage(PZImages.hideEye, for: .normal)
            txtPassword.isSecureTextEntry = true
        }else {
            btnShowPassword.setImage(PZImages.showEye, for: .normal)
            txtPassword.isSecureTextEntry = false
        }
    }
    
    @IBAction func termsOfServicesAction(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController:PrivacyPolicyViewController = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
        viewController.strTitle = "Terms of Services"
        viewController.strURl = Constant.sharedinstance.termsURL
        self.navigationController?.pushView(viewController, animated: true)
    }
    
    @IBAction func privacyPolicyAction(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController:PrivacyPolicyViewController = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
        viewController.strTitle = "Privacy Policy"
        viewController.strURl = Constant.sharedinstance.privacyURL
        self.navigationController?.pushView(viewController, animated: true)
    }
    
    
    @IBAction func contactUsAction(){
        let storyboard = UIStoryboard(name: "Feeds", bundle: nil)
        let destVC:ContactUSViewController = storyboard.instantiateViewController(withIdentifier: "ContactUSViewController") as! ContactUSViewController
        self.navigationController?.pushView(destVC, animated: true)
    }
    
    
    @IBAction func handleGoogleSignInButton() {
        
        txtEmail.text = ""
        txtMobile.text = ""
        
        let signInConfig = GIDConfiguration.init(clientID: "531803338654-snn153cm7patvj9mhvuvh3chupfles7u.apps.googleusercontent.com")
            /*  GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            
            
            if error == nil {
                if let user = user {
                    let userID = user.userID ?? ""
                    let emailAddress = user.profile?.email ?? ""
                    let fullName = user.profile?.name ?? ""
                    let givenName = user.profile?.givenName ?? ""
                    let familyName = user.profile?.familyName ?? ""
                    let profilePicUrl = user.profile?.imageURL(withDimension: 320)
                    
                    self.socialUser = userID
                    self.socialFullName = fullName
                    self.socialEmail = emailAddress
                    print("socialUser \(self.socialUser), socialFullName: \(self.socialFullName) , socialEmail: \(self.socialEmail)")
                    self.loginButtonAction()
                }
            }else{
                print("ERROR GOOGLE SIGN IN \(error?.localizedDescription ?? "")")
            }
        }
        
        */
        
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else {
                print("Error: ",error?.localizedDescription ?? "")
                return }
            guard let user = user else { return }
            
            
            let userID = user.userID ?? ""
            let emailAddress = user.profile?.email ?? ""
            let fullName = user.profile?.name ?? ""
//            let givenName = user.profile?.givenName ?? ""
//            let familyName = user.profile?.familyName ?? ""
//            let profilePicUrl = user.profile?.imageURL(withDimension: 320)
            
            self.socialUser = userID
            self.socialFullName = fullName
            self.socialEmail = emailAddress
            print("socialUser \(self.socialUser), socialFullName: \(self.socialFullName) , socialEmail: \(self.socialEmail)")
            self.loginButtonAction()
            
            
        }
        
        
    }
 
    
    @IBAction func loginButtonAction() {
        self.view.endEditing(true)
        
        while (txtMobile.text?.hasPrefix("0"))! {
            txtMobile.text = txtMobile.text?.substring(from: 1)
        }
        
        if (txtMobile.text?.hasPrefix("+"))! {
            txtMobile.text = txtMobile.text?.substring(from: country_Code.length)
        }
        
        if (txtPassword.text?.length ?? 0) > 0 {
            txtPassword.text = txtPassword.text?.trimmingCharacters(in: .whitespaces)
        }
        
        if socialUser.length > 0 {
            self.hashingCreatorApi()
        }else if viewEmail.isHidden == false && txtEmail.text?.length == 0 {
            self.view.makeToast(message: "Please enter your Email-id or PickZon ID" , duration: 3, position: HRToastActivityPositionDefault)
            return
        } else if viewMobile.isHidden == false && txtMobile.text?.length == 0 {
            self.view.makeToast(message: "Please enter your mobile number" , duration: 3, position: HRToastActivityPositionDefault)
            return
        }else if  txtPassword.text?.length == 0 {
            self.view.makeToast(message: "Please enter your password" , duration: 3, position: HRToastActivityPositionDefault)
            return
        } else {
            self.hashingCreatorApi()
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
                        self.login()
                    }
                                    
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    func login() {
        var loginType = 1
           var username = ""
        if (txtEmail.text ?? "").length > 0 {
            username = txtEmail.text ?? ""
            loginType = 0
        }else if country_Code.length > 0 && (txtMobile.text ?? "").length > 0{
            username = country_Code + (txtMobile.text ?? "")
            loginType = 0
        }else {
            username = socialEmail
            loginType = 1
        }
        
        
        var param:NSDictionary = [:]
        param = ["loginType":loginType, "socialId":socialUser, "username":"\(username)", "password":"\(txtPassword.text ?? "")", "deviceId":"\(Themes.sharedInstance.getDeviceUUIDString())", "gcmId":"\(UserDefaults.standard.string(forKey: "fcm_token") ?? "")","OS": "ios", "modelName": "\(UIDevice.current.model)", "manufacturer": "Apple", "version": "\(Themes.sharedInstance.osVersion)", "randomNumber": self.randomNumber ]
    
            Themes.sharedInstance.activityView(View: self.view)
    
    
    
            URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.authLogin, param: param) { (responseObject, error) -> () in
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                //self.NextButton.isUserInteractionEnabled = true
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
                                 
                                
                                 
                                 if let userDetailDict = result["payload"] as? NSDictionary{
                                     let requestType =  userDetailDict ["requestType"] as? Int ?? 0
                                     if requestType == 1 {
                                         let ProfileVC = StoryBoard.prelogin.instantiateViewController(withIdentifier:"ProfileInfoID" ) as! ProfileInfoViewController
                                         
                                         
                                        // ProfileVC.username = self.socialFullName
                                         //ProfileVC.email = self.socialEmail
                                         
                                         ProfileVC.user_info.setValue(self.socialFullName, forKey:"Name")
                                         ProfileVC.user_info.setValue(self.socialEmail, forKey: "email")
                                         //ProfileVC.user_info.setValue(self.socialProfilePicUrl, forKey:"ProfilePic")
                                         
                                         ProfileVC.socialId = self.socialUser
                                         
                                         self.pushView(ProfileVC, animated: true)
                                     }else {
                                         
                                         let user_ID = userDetailDict["_id"] as? String ?? ""
                                         let name = userDetailDict["name"] as? String ?? ""
                                         let profilepic =  userDetailDict["profilePic"] as? String ?? ""
                                         let email = userDetailDict["email"] as? String ?? ""
                                         let mobileNumber = (userDetailDict["countryCode"] as? String ?? "") +  (userDetailDict["mobileNumber"] as? String ?? "")
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
                                         : NSDictionary  = ["user_id":user_ID,"status":"","mobilenumber":"\(mobileNumber)","name":name, "profilepic":profilepic,"current_call_status":"0","call_id":"","wallpaper_type" : "default", "wallpaper" : "", "status_privacy" : "0", "otp" : Themes.sharedInstance.CheckNullvalue(Passed_value: "")]
                                         
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
                                         
                                         let updateDict=["name":Themes.sharedInstance.CheckNullvalue(Passed_value: name), "email":Themes.sharedInstance.CheckNullvalue(Passed_value: email)]
                                         
                                         DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: updateDict as NSDictionary?)
                                         
                                         
                                         //Remove the SecurityAuthToken
                                         Themes.sharedInstance.removeSecurityAuthToken()
                                         
                                         self.updateUserInfoInDB(respdict: userDetailDict)
                                         
                                         UserDefaults.standard.setValue(true, forKey: Constant.sharedinstance.isProfileInfoAvailable)
                                         UserDefaults.standard.synchronize()
                                         
                                         //Disconnect the socket so the it can be connected with latest User ID
                                         DispatchQueue.global(qos: .background).async {
                                             SocketIOManager.sharedInstance.socket.disconnect()
                                         }
                                         
                                         
                                         (UIApplication.shared.delegate as! AppDelegate).MovetoRooVC()
                                     }
                                     
                                 }
                             }else{
                                 self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
    
                             }
                             
    
                         }
            }
        }
    
    func updateUserInfoInDB(respdict:NSDictionary) {
      
        var objUser = PickzonUser(respdict: [:])
        objUser.id = respdict["_id"] as? String ?? ""
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
    
    @IBAction func signUpAction(_ sender:UIButton) {
     
        let forgotPasswordVC = StoryBoard.prelogin.instantiateViewController(withIdentifier:"PhoneEmailSignUpVC" ) as! PhoneEmailSignUpVC
        self.navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }
    
    @IBAction func forgotPasswordAction(_ sender:UIButton) {
        let forgotPasswordVC = StoryBoard.prelogin.instantiateViewController(withIdentifier:"ForgotPasswordVC" ) as! ForgotPasswordVC
        self.navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }
    
    @IBAction func countrycodeBtnAction(_ sender:UIButton) {
        let  country = MICountryPicker()
        country.delegate = self
        country.showCallingCodes = true
        if let navigator = self.navigationController
        {
            navigator.pushViewController(country, animated: true)
        }
    }
    
}

extension LoginVCNew: MICountryPickerDelegate,UITextFieldDelegate {
    
    func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String) {
        picker.navigationController?.popToRootViewController(animated: true)
        picker.navigationController?.isNavigationBarHidden = true
    }
    
    func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String,countryFlagImage:UIImage){
        picker.navigationController?.popToRootViewController(animated: true)
        lblCountrycode.text = "\(dialCode)"
        country_Code = dialCode
        Themes.sharedInstance.saveMobileCode(dialCode)
        picker.navigationController?.isNavigationBarHidden = true
    }
    
}


extension LoginVCNew: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    @IBAction func handleAuthorizationAppleIDButtonPress() {
        txtEmail.text = ""
        txtMobile.text = ""
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
   
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
             socialUser = appleIDCredential.user
            socialFullName = appleIDCredential.fullName?.givenName ?? ""
             socialEmail = appleIDCredential.email ?? ""
            print("socialUser \(socialUser), socialFullName: \(socialFullName) , socialEmail: \(socialEmail)")
            
            self.loginButtonAction()
            
            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
            //self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
            
        case let passwordCredential as ASPasswordCredential:
            
            // Sign in using an existing iCloud Keychain credential.
           // let username = passwordCredential.user
          //  let password = passwordCredential.password
            
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
               // self.showPasswordCredentialAlert(username: username, password: password)
            }
            
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print(error.localizedDescription)
    }
    
    
    
}





class RangeGestureRecognizer: UITapGestureRecognizer {
    // Stored variables
    typealias MethodHandler = () -> Void
    static var stringRange: String?
    static var function: MethodHandler?
  
    func didTappedAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
      
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
      
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}


extension UILabel {
    typealias MethodHandler = () -> Void
    func addRangeGesture(stringRange: String, function: @escaping MethodHandler) {
        RangeGestureRecognizer.stringRange = stringRange
        RangeGestureRecognizer.function = function
        self.isUserInteractionEnabled = true
        let tapgesture: UITapGestureRecognizer = RangeGestureRecognizer(target: self, action: #selector(tappedOnLabel(_ :)))
        tapgesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapgesture)
    }

    @objc func tappedOnLabel(_ gesture: RangeGestureRecognizer) {
        guard let text = self.text else { return }
        let stringRange = (text as NSString).range(of: RangeGestureRecognizer.stringRange ?? "")
        if gesture.didTappedAttributedTextInLabel(label: self, inRange: stringRange) {
            guard let existedFunction = RangeGestureRecognizer.function else { return }
            existedFunction()
        }
    }
}


extension UIApplication {
    
    var statusBarView: UIView? {
        if responds(to: Selector("statusBar")) {
            return value(forKey: "statusBar") as? UIView
        }
        return nil
    }
}
 
 
extension String {
   var isNumeric: Bool {
     return !(self.isEmpty) && self.allSatisfy { $0.isNumber }
   }
}



import UIKit

extension UISegmentedControl {
    func applyCapsuleStyle() {
        let radius = bounds.height / 2

        // Whole control rounded
        layer.cornerRadius = radius
        clipsToBounds = true

        // Normal background (clear capsule)
        let normalImage = UIImage.capsule(color:CustomColor.sharedInstance.txtFdBgColor, radius: radius)
        setBackgroundImage(normalImage, for: .normal, barMetrics: .default)

        // Selected background (teal capsule)
        let selectedImage = UIImage.capsule(color: CustomColor.sharedInstance.newThemeColor, radius: radius)
        setBackgroundImage(selectedImage, for: .selected, barMetrics: .default)

        // Divider hidden
        setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

        // Text colors
        let normalAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label]
        let selectedAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
        setTitleTextAttributes(normalAttrs, for: .normal)
        setTitleTextAttributes(selectedAttrs, for: .selected)
    }
}

extension UIImage {
    static func capsule(color: UIColor, radius: CGFloat) -> UIImage {
        let size = CGSize(width: 2 * radius + 1, height: 2 * radius + 1)
        let rect = CGRect(origin: .zero, size: size)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        color.setFill()
        path.fill()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return img!.resizableImage(withCapInsets: UIEdgeInsets(top: radius, left: radius, bottom: radius, right: radius))
    }
}



extension UITextField{
    
    func setplaceholderColorWithText(placeholderText:String,color:UIColor){
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color // Set placeholder color to black
        ]
        self.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
    }
}
    



class MyViewController:UIViewController{
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(named: "backgroundColor") ?? .label

    }
    
}

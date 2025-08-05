//
//  RequestVerificationViewController.swift
//  SCIMBO
//
//  Created by gurmukh singh on 12/17/21.
//  Copyright © 2021 Radheshyam Yadav. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class RequestVerificationViewController: UIViewController {
 
    @IBOutlet weak var scrScrollview:TPKeyboardAvoidingScrollView!
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblApply:UILabel!
    @IBOutlet weak var lblDesc:UILabel!
    @IBOutlet weak var lblVerifyFace:UILabel!
    @IBOutlet weak var btnUserImage:UIButton!
    @IBOutlet weak var btnCameraImage:UIButton!
    
    @IBOutlet weak var lblFullName:UILabel!
    @IBOutlet weak var lblDOB:UILabel!
    @IBOutlet weak var lblDocumentType:UILabel!
    @IBOutlet weak var lblCategory:UILabel!
    @IBOutlet weak var lblPhone:UILabel!
    @IBOutlet weak var lblEmail:UILabel!
    @IBOutlet weak var lblSocialProfile:UILabel!
    @IBOutlet weak var lblLinkType:UILabel!
    @IBOutlet weak var lblFatherName:UILabel!
    @IBOutlet weak var lblPickzonId:UILabel!

    @IBOutlet weak var txtFullName:UITextField!
    @IBOutlet weak var txtDOB:UITextField!
    @IBOutlet weak var txtDocumentType:UITextField!
    @IBOutlet weak var txtCategory:UITextField!
    @IBOutlet weak var txtPhone:UITextField!
    @IBOutlet weak var txtEmail:UITextField!
    @IBOutlet weak var txtSocialProfileType:UITextField!
    @IBOutlet weak var txtLinkType:UITextField!
    @IBOutlet weak var btnSubmit:UIButton!
    @IBOutlet weak var btnVerifyPhone:UIButton!
    @IBOutlet weak var btnVerifyEmail:UIButton!
    @IBOutlet weak var btnChooseFile:UIButton!
    @IBOutlet weak var btnChooseBackFile:UIButton!

    @IBOutlet weak var txtFatherName:UITextField!
    @IBOutlet weak var txtFdPickzonId:UITextField!

    var arrProfileCategory:Array = Array<String>()
    var arrProfileCategoryId:Array = Array<String>()
    var arrDocType:Array = Array<String>()
    var arrDocTypeId:Array = Array<String>()
    var arrSocialProfileType = Array<String>()
    var arrSocialProfileTypeId = Array<String>()
    var imgUserFileURL = ""
    private var datePicker: UIDatePicker = UIDatePicker()
    var viewDatePicker : UIView = UIView()
    var strDOB = ""
    var selCategoryId = ""
    var selDocumentTypeId = ""
    var selSocialTypeId = ""
    var picker:UIImagePickerController?
    var isDocumentFrontSelected = false
    var isDocumentBackSelected = false
    var profileImg:UIImage?
    var documentFrontImage:UIImage?
    var documentBackImage:UIImage?
    var mergedDocumentImage:UIImage?
    var isEmailVerified = 0
    var isMobileVerified = 0
    var isMobileVerifyRequired = 0
    @IBOutlet weak var viewPhone:UIView!
    @IBOutlet weak var constraintViewPhoneHeight: NSLayoutConstraint?
    
    //MARK: - Controller Life Cycle Methods
    override func viewDidLoad() {
        print("UIViewController: RequestVerificationViewController")
        super.viewDidLoad()
        self.btnChooseFile.titleLabel?.numberOfLines  = 0
        self.btnChooseFile.contentHorizontalAlignment = .center
        self.btnChooseFile.layer.cornerRadius = 5.0
        self.btnChooseFile.layer.borderColor = UIColor.lightGray.cgColor
        self.btnChooseFile.layer.borderWidth = 0.5
        self.btnChooseFile.clipsToBounds = true
      
        self.btnChooseBackFile.titleLabel?.numberOfLines  = 0
        self.btnChooseBackFile.layer.cornerRadius = 5.0
        self.btnChooseBackFile.layer.borderColor = UIColor.lightGray.cgColor
        self.btnChooseBackFile.layer.borderWidth = 0.5
        self.btnChooseBackFile.clipsToBounds = true
        self.btnChooseBackFile.contentHorizontalAlignment = .center

        
        scrScrollview.contentSize = CGSize(width: UIScreen.main.bounds.width, height: contentView.frame.height)
        self.getCategoryAction()
        self.updateProperties()
        btnUserImage.layer.borderColor = UIColor.lightGray.cgColor
        btnUserImage.layer.borderWidth = 1.0
        btnUserImage.layer.cornerRadius =  btnUserImage.frame.size.width/2.0
        btnUserImage.clipsToBounds = true
        btnCameraImage.layer.cornerRadius =  btnCameraImage.frame.size.width/2.0
        txtEmail.setRightPaddingPoints(70)
        self.txtFdPickzonId.text = Themes.sharedInstance.getPickzonId()
    }
    
    override func viewWillLayoutSubviews(){
    super.viewWillLayoutSubviews()
        scrScrollview.contentSize = CGSize(width: UIScreen.main.bounds.width, height: contentView.frame.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrScrollview.contentSize = CGSize(width: UIScreen.main.bounds.width, height: contentView.frame.height)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    //MARK: - Button Action Methods
    @IBAction func needHelpButtonAction(){
        
        let storyboard = UIStoryboard(name: "Feeds", bundle: nil)
        let destVC:ContactUSViewController = storyboard.instantiateViewController(withIdentifier: "ContactUSViewController") as! ContactUSViewController
        self.navigationController?.pushView(destVC, animated: true)
    }

    
    @IBAction func infoButtonAction(){

        let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
        vc.urlString = Constant.sharedinstance.userGreenBadgePolicyURL
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func verifyEmailButtonAction(){
        self.view.endEditing(true)
        
       /* if txtEmail.text?.count == 0{
            return
        }else if txtEmail.text?.isValidEmail == false {
            
            self.view.makeToast(message: "Please enter valid email Id." , duration: 3, position: HRToastActivityPositionDefault)
            return
        }else {
            
            sendEmailOtpApi()
           
        }*/
        
        if isEmailVerified == 0 {
            let viewController:VerifyEmailAndPhone = StoryBoard.prelogin.instantiateViewController(withIdentifier: "VerifyEmailAndPhone") as! VerifyEmailAndPhone
            viewController.delegateVerifyEmailPhone = self
            viewController.isEmail = true
            self.navigationController?.pushView(viewController, animated: true)
        }
    }
    
    @IBAction func verifyPhoneAction() {
        if isMobileVerified == 0 {
            let viewController:VerifyEmailAndPhone = StoryBoard.prelogin.instantiateViewController(withIdentifier: "VerifyEmailAndPhone") as! VerifyEmailAndPhone
            viewController.delegateVerifyEmailPhone = self
            viewController.isEmail = false
            self.navigationController?.pushView(viewController, animated: true)
        }
    }
    
    @IBAction func backButtonAction()
    {
        
        self.navigationController?.popViewController(animated: true)

        //self.navigationController?.popToRoot(animated: true)

    }
    
    
    
    func setTextFieldProperties(txtField:UITextField){
        txtField.layer.cornerRadius = 5.0
        txtField.layer.borderColor = UIColor.lightGray.cgColor
        txtField.layer.borderWidth = 0.5
        txtField.setLeftPaddingPoints(5)
        txtField.setRightPaddingPoints(5)
        txtField.font = UIFont(name: FontRoboto, size: 16)
    }
    
    func setMendatory(lbl:UILabel) {
        // Initialize with a string only
        let attrStar = NSAttributedString(string: "*", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        
        // Initialize with a string and inline attribute(s)
        let attrString2 = NSAttributedString(string: "\(lbl.text ?? "")", attributes: [NSAttributedString.Key.foregroundColor: UIColor.label])
        let attr1: NSMutableAttributedString = NSMutableAttributedString()
        attr1.append(attrString2)
        attr1.append(attrStar)
        lbl.attributedText = attr1
    }

    func updateProperties(){
        lblTitle.font = UIFont(name: FontRobotoBold, size: 20)
        lblApply.font = UIFont(name: FontRobotoBold, size: 20)
        lblDesc.font = UIFont(name: FontRoboto, size: 16)
        lblVerifyFace.font = UIFont(name: FontRobotoBold, size: 17)
        
        lblFullName.font = UIFont(name: FontRoboto, size: 16)
        lblDOB.font = UIFont(name: FontRoboto, size: 16)
        lblDocumentType.font = UIFont(name: FontRoboto, size: 16)
        lblCategory.font = UIFont(name: FontRoboto, size: 16)
        lblPhone.font = UIFont(name: FontRoboto, size: 16)
        lblEmail.font = UIFont(name: FontRoboto, size: 16)
        lblSocialProfile.font = UIFont(name: FontRoboto, size: 16)
        lblLinkType.font = UIFont(name: FontRoboto, size: 16)
        lblFatherName.font = UIFont(name: FontRoboto, size: 16)
        lblPickzonId.font = UIFont(name: FontRoboto, size: 16)

        
        self.setMendatory(lbl: lblFullName)
        self.setMendatory(lbl: lblDOB)
        self.setMendatory(lbl: lblDocumentType)
        self.setMendatory(lbl: lblCategory)
        self.setMendatory(lbl: lblEmail)
        self.setMendatory(lbl: lblPhone)
        self.setMendatory(lbl: lblFatherName)
        self.setMendatory(lbl: lblPickzonId)
        
        

        txtFullName.autocapitalizationType = .words
        self.setTextFieldProperties(txtField: txtFullName)
        self.setTextFieldProperties(txtField: txtDOB)
        self.setTextFieldProperties(txtField: txtDocumentType)
        self.setTextFieldProperties(txtField: txtCategory)
        self.setTextFieldProperties(txtField: txtPhone)
        self.setTextFieldProperties(txtField: txtEmail)
        self.setTextFieldProperties(txtField: txtSocialProfileType)
        self.setTextFieldProperties(txtField: txtLinkType)
        self.setTextFieldProperties(txtField: txtFatherName)
        self.setTextFieldProperties(txtField: txtFdPickzonId)

        btnSubmit.layer.cornerRadius = 5.0
        btnSubmit.layer.borderColor = UIColor.lightGray.cgColor
        btnSubmit.layer.borderWidth = 0.5
    }
    
    func openDeviceCamera(){
        
        cameraAllowsAccessToApplicationCheck()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.cameraDevice = .rear
            imagePicker.mediaTypes = ["public.image"]
            imagePicker.videoMaximumDuration =   60
            imagePicker.videoQuality = .typeHigh
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func openCamera()
    {
        self.isDocumentFrontSelected = false
        isDocumentBackSelected = false
        openDeviceCamera()
       
    }
    
    @IBAction func showDocumentTypePicker(){
        print("showDocumentTypePicker")
        
    }
    
    @IBAction func chooseFileAction(){
        print("chooseFileAction")
        isDocumentFrontSelected = true
        isDocumentBackSelected = false
        let alert = UIAlertController(title: "Select front side document Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.isDocumentFrontSelected = true

            self.openDeviceCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func btnChooseBackFileAction(){
        print("chooseFileAction")
        isDocumentFrontSelected = false
        isDocumentBackSelected = true
        let alert = UIAlertController(title: "Select back side of document Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.isDocumentBackSelected = true

            self.openDeviceCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func mergedTwoImagesIntoSIngle(){
       
        let firstImage =  documentFrontImage ?? UIImage()
        let secondImage = documentBackImage ?? UIImage()

        if documentFrontImage == nil{
            mergedDocumentImage = documentBackImage

        }else if documentBackImage == nil {
            mergedDocumentImage = documentFrontImage

        }else if (documentBackImage != nil && documentFrontImage != nil){
            DispatchQueue.global(qos: .userInteractive).async {
                
                let newImageWidth  = max(firstImage.size.width,  secondImage.size.width )
                let newImageHeight = max(firstImage.size.height, secondImage.size.height)
        
                let size = CGSize(width: newImageWidth, height: newImageHeight + newImageHeight + 10)
                UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                
                firstImage.draw(in: CGRect(x: 0, y: 0, width: firstImage.size.width, height: firstImage.size.height))
                secondImage.draw(in: CGRect(x: 0, y: firstImage.size.height + 10, width:secondImage.size.width, height: secondImage.size.height))
                
                let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
                UIGraphicsEndImageContext()
                
                self.mergedDocumentImage = newImage
            }
           
        }
    }
    
    //MARK: Api MEthods
    
    func sendEmailOtpApi(){
        
        Themes.sharedInstance.activityView(View: self.view)
        
        
        URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.sendEmailOTP, param: ["email":txtEmail.text!], completionHandler: {(responseObject, error) ->  () in
        
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                

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
                        if let email = alert.textFields?[0].text {
                            print(email)
                            if email.count > 0 {
                                self.verifyEmailOtpApi(otp: email)
                            }
                        }
                    }
                    alert.addAction(loginAction)
                    self.present(alert, animated: true)
                }else {
                    self.view.makeToast(message:message  , duration: 2, position: HRToastPositionCenter)
                }
            }
            
            
        })
        
    }
    
    
    func verifyEmailOtpApi(otp:String){
        
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.verifyEmailOTP, param: ["otp":otp], completionHandler: {(responseObject, error) ->  () in
        
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                self.view.makeToast(message:message  , duration: 2, position: HRToastPositionCenter)

                if status == 1{
                    self.isEmailVerified = 1
                    self.btnVerifyEmail.setTitle("Verified", for: .normal)
                    self.btnVerifyEmail.setTitleColor(UIColor.green, for: .normal)
                    self.btnVerifyEmail.isUserInteractionEnabled = false
                    self.txtEmail.isUserInteractionEnabled = false
                }else {
                    self.view.makeToast(message:message  , duration: 2, position: HRToastPositionCenter)
                }
            }
            
            
        })
        
    }
    
    
    
    
    func getCategoryAction(){
        print("selectCategoryAction")
        let param:NSDictionary = [:]

        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeGetCall(url:Constant.sharedinstance.getProfileCategoryURL as String, param: param, completionHandler: { [self](responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1 {
                                        
                   if let payloadDict = result["payload"] as? NSDictionary {
                                                
                        let arr = payloadDict["profileCategory"] as? Array<Dictionary<String, Any>> ?? []
                        for obj in arr {
                            let str = obj["name"] as? String ?? ""
                            self.arrProfileCategory.append(str)
                            self.arrProfileCategoryId.append(obj["_id"] as? String ?? "")
                            
//                            if let userDict = payloadDict["user"] as? Dictionary<String,Any> {
//                                //Already selected category
//                                if (userDict["jobProfile"] as? String ?? "") == str{
//                                    self.selCategoryId = obj["_id"] as? String ?? ""
//                                }
//                            }
                        }
                        
                        let documentTypeArr = payloadDict["documentType"] as? Array<Dictionary<String, Any>> ?? []
                        for obj in documentTypeArr {
                            self.arrDocType.append(obj["name"] as? String ?? "")
                            self.arrDocTypeId.append(obj["_id"] as? String ?? "")
                        }
                        
                        
                        let socialProfile = payloadDict["socialProfile"] as? Array<Dictionary<String, Any>> ?? []
                        for obj in socialProfile {
                            self.arrSocialProfileType.append(obj["name"] as? String ?? "")
                            self.arrSocialProfileTypeId.append(obj["_id"] as? String ?? "")
                        }
                        
                        
                        if let userDict = payloadDict["user"] as? Dictionary<String,Any> {
                            
                            self.txtFullName.text = userDict["fullName"] as? String ?? ""
                            self.txtEmail.text = userDict["email"] as? String ?? ""
                           // self.txtCategory.text = userDict["jobProfile"] as? String ?? ""
                            
                            
                            
                            
                            self.isEmailVerified = userDict["isEmailVerified"] as? Int ?? 0
                            
                            
                            if self.isEmailVerified == 1 {
                                self.btnVerifyEmail.setTitle("Verified", for: .normal)
                                self.btnVerifyEmail.setTitleColor(UIColor.green, for: .normal)
                                self.btnVerifyEmail.isUserInteractionEnabled = false
                                self.txtEmail.isUserInteractionEnabled = false
                            }
                            
                            self.txtPhone.text = userDict["msisdn"] as? String ?? ""
                            
                            self.isMobileVerified = userDict["isMobileVerified"] as? Int ?? 0
                            if self.isMobileVerified == 1 {
                                self.btnVerifyPhone.setTitle("Verified", for: .normal)
                                self.btnVerifyPhone.setTitleColor(UIColor.green, for: .normal)
                                self.btnVerifyPhone.isUserInteractionEnabled = false
                                self.txtPhone.isUserInteractionEnabled = false
                            }
                            
                            self.isMobileVerifyRequired = userDict["isMobileVerifyRequired"] as? Int ?? 0
                            //self.isMobileVerifyRequired = 0
                            if isMobileVerifyRequired == 0 {
                                //self.viewPhone.isHidden = true
                                //self.constraintViewPhoneHeight?.constant = 0
                                self.btnVerifyPhone.isHidden = true
                            }
                            
                            self.txtDOB.text = userDict["dob"] as? String ?? ""
                            let isRequested = userDict["isRequested"] as? Int ?? 0
                            
                            if (userDict["isRequested"] as? Int ?? 0) == 1 {
                                // "You are verified user!."
                                
                                AlertView.sharedManager.presentAlertWith(title: "", msg:message as NSString , buttonTitles: ["ok"], onController: self) { title, index in
                                    if (isRequested != 0){
                                      // self.navigationController?.popToRoot(animated: true)
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                }
                            }
                            
                        }
                        
                    }
                    print(self.arrProfileCategory)
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    
    @IBAction func selectProfileTypeAction() {
        print("selectProfileTypeAction")
    
    }
    
    @IBAction func submitButtonAction(){
        print("submitButtonAction")
        self.view.endEditing(true)
        
        if profileImg == nil {
            self.view.makeToast(message: "Please upload your photo" , duration: 3, position: HRToastActivityPositionDefault)
        }else if txtFullName.text?.trim().count == 0 {
            self.view.makeToast(message: "Please enter fullname" , duration: 3, position: HRToastActivityPositionDefault)
        }else if txtFatherName.text?.trim().count == 0{
            self.view.makeToast(message: "Please enter father/husband name" , duration: 3, position: HRToastActivityPositionDefault)
        }else if txtDOB.text?.count == 0{
            self.view.makeToast(message: "Please select Date of Birth" , duration: 3, position: HRToastActivityPositionDefault)
        }else if txtDocumentType.text?.count == 0{
            self.view.makeToast(message: "Please select docuent type" , duration: 3, position: HRToastActivityPositionDefault)
        }else  if documentFrontImage == nil {
            self.view.makeToast(message: "Please upload document front image" , duration: 3, position: HRToastActivityPositionDefault)
        }else if txtCategory.text?.count == 0{
            self.view.makeToast(message: "Please select category" , duration: 3, position: HRToastActivityPositionDefault)
            
        }else if txtEmail.text?.trim().count ?? 0 > 0 && self.txtEmail.text?.isValidEmail == false {
            self.view.makeToast(message: "Please enter valid email Id." , duration: 3, position: HRToastActivityPositionDefault)
        }else if txtEmail.text?.trim().count == 0{
            self.view.makeToast(message: "Please enter email Id." , duration: 3, position: HRToastActivityPositionDefault)
        }else if isEmailVerified == 0 {
            self.view.makeToast(message: "Please verify email Id." , duration: 3, position: HRToastActivityPositionDefault)
        }else if txtPhone.text?.trim().count == 0 && isMobileVerifyRequired == 1{
            self.view.makeToast(message: "Please enter mobile number." , duration: 3, position: HRToastActivityPositionDefault)
        }else if isMobileVerified == 0 && isMobileVerifyRequired == 1{
            self.view.makeToast(message: "Please verify mobile number." , duration: 3, position: HRToastActivityPositionDefault)
        }else{
           
            Themes.sharedInstance.activityView(View: self.view)

            let params = ["fullName":txtFullName.text ?? "","dob":txtDOB.text ?? "","documentType":selDocumentTypeId,"socialProfile":selSocialTypeId,"profileCategory":selCategoryId,"email":txtEmail.text ?? "","profileLink":txtLinkType.text ?? "","fatherName":txtFatherName.text ?? "","phoneNumber":txtPhone.text ?? ""]
            
            
            URLhandler.sharedinstance.uploadVerificationDocuments(profileImg: profileImg ?? UIImage(), documentImg: mergedDocumentImage ?? UIImage(), url: Constant.sharedinstance.vipVerificationRequest, params: params) { message, status in
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                
                AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["ok"], onController: self) { title, index in
                    
                    if status == 1 {
                      //  self.navigationController?.popToRoot(animated: true)
                        self.navigationController?.popViewController(animated: true)

                    }
                }
            }
        }
        
    }
    

   
     func showDOBDatePicker() {
         
        self.view.endEditing(true)
        
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
    
    
    @objc  func cancelAction() {
        viewDatePicker.removeFromSuperview()
    }
    
    
    @objc func doneActionDOBPicker() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateString = dateFormatter.string(from: datePicker.date)
        self.txtDOB.text = dateString
        
        // let dateFormatter1 = DateFormatter()
        // dateFormatter1.dateFormat = "yyyy-MM-dd"
        // strDOB = dateFormatter1.string(from: datePicker.date)
        
        viewDatePicker.removeFromSuperview()
    }
    
}


extension RequestVerificationViewController:UITextFieldDelegate,PickzonIdDelegate{
     
    
    func getPickzonId(pickzonId:String)
    {
        Themes.sharedInstance.savePickZonID(pickzonId: pickzonId)
        self.txtFdPickzonId.text = pickzonId
        //self.btnPickzonId.setTitle("@" + pickzonId, for: .normal)
    }
    
     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         
        // viewDatePicker.removeFromSuperview()
         if string.isEmpty {
             return true
         }
         
         if textField == txtFullName || textField == txtFatherName{
             return string.isValidName()
         }
         
        /* if textField == txtFullName {
             let alphaNumericRegEx = "[a-zA-Z ]"
             let predicate = NSPredicate(format:"SELF MATCHES %@", alphaNumericRegEx)
             return predicate.evaluate(with: string)
         }else
         
         
         
         if textField == txtFatherName {
             let alphaNumericRegEx = "[a-zA-Z ]"
             let predicate = NSPredicate(format:"SELF MATCHES %@", alphaNumericRegEx)
             return predicate.evaluate(with: string)
         }
         */
         return true
     }
     
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         textField.resignFirstResponder()
         return true
     }
     
     func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
         //viewDatePicker.removeFromSuperview()
         self.cancelAction()
         if textField == txtPhone{
             self.view.endEditing(true)
             if isMobileVerified == 0 && isMobileVerifyRequired == 1{
                 let viewController:VerifyEmailAndPhone = StoryBoard.prelogin.instantiateViewController(withIdentifier: "VerifyEmailAndPhone") as! VerifyEmailAndPhone
                 viewController.delegateVerifyEmailPhone = self
                 viewController.isEmail = false
                 self.navigationController?.pushView(viewController, animated: true)
             }else if isMobileVerifyRequired == 0 {
                 return true
             }
             return false
             
         }else if textField == txtEmail{
             self.view.endEditing(true)
             if isEmailVerified == 0 {
                 let viewController:VerifyEmailAndPhone = StoryBoard.prelogin.instantiateViewController(withIdentifier: "VerifyEmailAndPhone") as! VerifyEmailAndPhone
                 viewController.delegateVerifyEmailPhone = self
                 viewController.isEmail = true
                 self.navigationController?.pushView(viewController, animated: true)
             }
             return false
             
         }else if textField == txtFdPickzonId{
             if Settings.sharedInstance.isPickzonIdChange == 1{
                 let vc = self.storyboard?.instantiateViewController(withIdentifier: "PickzonIdEditVC") as! PickzonIdEditVC
                 vc.pickzonId = txtFdPickzonId.text ?? ""
                 vc.delegate = self
                 navigationController?.pushViewController(vc, animated: true)
             }
         }else if textField == txtCategory {
             self.view.endEditing(true)
             
             ActionSheetMultipleStringPicker.show(withTitle: "", rows: [
                 arrProfileCategory
             ], initialSelection: [0, 0], doneBlock: {
                 picker, indexes, values in
                 
                 if let str = (values as AnyObject?) as? NSArray {
                     
                     self.txtCategory.text  = str[0] as? String ?? ""
                 }
                 if let index = (indexes as AnyObject?) as? NSArray {
                     
                     self.selCategoryId  = self.arrProfileCategoryId[(index[0] as? Int ?? 0)] as? String ?? ""
                     print(self.selCategoryId)
                 }
                 return
             }, cancel: { ActionMultipleStringCancelBlock in return }, origin: txtCategory)
             return false
             
         }else  if textField == txtDocumentType {
             self.view.endEditing(true)
             
             ActionSheetMultipleStringPicker.show(withTitle: "", rows: [
                 arrDocType
             ], initialSelection: [0, 0], doneBlock: {
                 picker, indexes, values in
                 
                 if let str = (values as AnyObject?) as? NSArray {
                     
                     self.txtDocumentType.text  = str[0] as? String ?? ""
                 }
                 if let index = (indexes as AnyObject?) as? NSArray {
                     
                     self.selDocumentTypeId  = self.arrDocTypeId[(index[0] as? Int ?? 0)] as? String ?? ""
                     print(self.selDocumentTypeId)
                 }
                 return
             }, cancel: { ActionMultipleStringCancelBlock in return }, origin: txtDocumentType)
             return false
             
         }else  if textField == txtSocialProfileType {
             self.view.endEditing(true)
             
             ActionSheetMultipleStringPicker.show(withTitle: "", rows: [
                 arrSocialProfileType
             ], initialSelection: [0, 0], doneBlock: {
                 picker, indexes, values in
                 
                 if let str = (values as AnyObject?) as? NSArray {
                     
                     self.txtSocialProfileType.text  = str[0] as? String ?? ""
                 }
                 
                 if let index = (indexes as AnyObject?) as? NSArray {
                     
                     self.selSocialTypeId  = self.arrSocialProfileTypeId[(index[0] as? Int ?? 0)]
                     print(self.selSocialTypeId)
                 }
                 
                 return
             }, cancel: { ActionMultipleStringCancelBlock in return }, origin: txtSocialProfileType)
             return false
             
         }else if textField == txtDOB {
             textField.resignFirstResponder()
             self.view.endEditing(true)
             self.showDOBDatePicker()
             return false
         }
         return true
     }
}

extension RequestVerificationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func openGallery(){
        picker = UIImagePickerController()
        picker?.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker?.delegate = self
        self.present(picker!, animated: true, completion: nil)
    }
   
    
    //MARK: - CAMERA ACCESS CHECK
    func cameraAllowsAccessToApplicationCheck()
    {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorizationStatus {
        case .notDetermined:
            // permission dialog not yet presented, request authorization
            AVCaptureDevice.requestAccess(for: AVMediaType.video,
                                             completionHandler: { (granted:Bool) -> Void in
                if granted {
                    print("access granted", terminator: "")
                }
                else {
                    print("access denied", terminator: "")
                }
            })
        case .authorized:
            print("Access authorized", terminator: "")
        case .denied, .restricted:
            alertToEncourageCameraAccessWhenApplicationStarts()
            
            break
        default:
            print("DO NOTHING", terminator: "")
        }
    }
    
    //MARK: -  CAMERA & GALLERY NOT ALLOWING ACCESS - ALERT
    func alertToEncourageCameraAccessWhenApplicationStarts()
    {
        AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: "Please enable camera", buttonTitles: ["Cancel","Okay"], onController: self) { title, index in
            
            if index == 0{
                return
            }else{
                let settingsUrl = NSURL(string:UIApplication.openSettingsURLString)
                if let url = settingsUrl {
                    DispatchQueue.main.async {
                        UIApplication.shared.openURL(url as URL)
                    }
                    
                }
            }
        }
    }
    
    
    //MARK: -- ImagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as AnyObject
        
        if let image = info[.originalImage] as? UIImage {
     
            if isDocumentFrontSelected{
                documentFrontImage = image
                self.btnChooseFile.setTitle("Document Uploaded", for: .normal)
                mergedTwoImagesIntoSIngle()

            }else if isDocumentBackSelected{
                documentBackImage = image
                self.btnChooseBackFile.setTitle("Document Uploaded", for: .normal)
                mergedTwoImagesIntoSIngle()

            }else{
                btnUserImage.setBackgroundImage(image, for: .normal)
                profileImg = image
            }
            
        }else {
            
        }
        picker.dismissView(animated: true, completion: nil)

      //  picker.dismiss(animated: true, completion: nil)
        
//        let zoomCtrl = VKImageZoom()
//        zoomCtrl.image = mergedDocumentImage
//        //zoomCtrl.image = sender.currentImage
//     zoomCtrl.modalPresentationStyle = .fullScreen
//    self.present(zoomCtrl, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismissView(animated: true, completion: nil)
    }
    
}


extension RequestVerificationViewController:VerifyEmailPhoneDelegate {
    func verifyEmailPhoneSuccess(isEmail:Bool, strEmailPhone:String) {
        
        if isEmail == true {
            self.isEmailVerified = 1
            self.txtEmail.text = strEmailPhone
            self.btnVerifyEmail.setTitle("Verified", for: .normal)
            self.btnVerifyEmail.setTitleColor(UIColor.green, for: .normal)
            self.btnVerifyEmail.isUserInteractionEnabled = false
            self.txtEmail.isUserInteractionEnabled = false
            
        }else {
            self.txtPhone.text = strEmailPhone
            self.isMobileVerified = 1
            self.btnVerifyPhone.setTitle("Verified", for: .normal)
            self.btnVerifyPhone.setTitleColor(UIColor.green, for: .normal)
            self.btnVerifyPhone.isUserInteractionEnabled = false
            self.txtPhone.isUserInteractionEnabled = false
            
        }
        
    }
}


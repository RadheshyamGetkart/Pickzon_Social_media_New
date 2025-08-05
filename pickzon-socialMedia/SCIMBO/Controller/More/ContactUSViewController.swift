//
//  ContactUSViewController.swift
//  SCIMBO
//
//  Created by gurmukh singh on 2/5/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import IQKeyboardManager
import Photos


class ContactUSViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var txtName:SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var txtEmail:SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var txtPhone:SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var txtCategory:SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var tvQuery:UITextView!
    @IBOutlet weak var svScroll:UIScrollView!
    @IBOutlet weak var btnSubmit:UIButton!
    @IBOutlet weak var btncountryCode:UIButton!
    @IBOutlet weak var lblUploadFile:UILabel!
    @IBOutlet weak var btnChooseFile:UIButton!
    @IBOutlet weak var imguploadedFile:UIImageView!
    
    var countryCode = ""
    var categoryArray:Array<String> = Array<String>()
    var picker:UIImagePickerController?
    var documentImg:UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtName.tag = 1000
        txtEmail.tag = 1001
        txtPhone.tag = 1002
        svScroll.isScrollEnabled = true
        txtPhone.delegate = self
        btnSubmit.layer.cornerRadius = 10.0
        tvQuery.layer.cornerRadius = 10.0
        tvQuery.layer.borderColor = UIColor.lightGray.cgColor
        tvQuery.layer.borderWidth = 1.0
        
        tvQuery.text = "Enter your issues/query"
        tvQuery.textColor = UIColor.label
        
        categoryArray = ["Help", "Bug", "Sales", "Support", "Feedback", "Other Issue"]
        self.getContactUsCategoryListing()
        
        Themes.sharedInstance.setCountryCodeButton(self.btncountryCode, nil)  
        countryCode = self.btncountryCode.currentTitle ?? ""
        
        btnChooseFile.layer.borderColor = UIColor.lightGray.cgColor
        btnChooseFile.layer.borderWidth = 1.0
        
        
        imguploadedFile.layer.borderColor = UIColor.systemBlue.cgColor
        imguploadedFile.layer.borderWidth = 1.0
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // svScroll.contentSize = CGSize(width: self.view.frame.width, height: 3000)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        svScroll.contentSize = CGSize(width: self.view.frame.size.width, height: 900)
    }
    
    @IBAction func countryCodeBtnAction()
    {
        let  country = MICountryPicker()
        country.delegate = self
        country.showCallingCodes = true
        if let navigator = self.navigationController
        {
            navigator.pushViewController(country, animated: true)
        }
    }
    
    @IBAction func backButtonAction()
    {
        self.navigationController?.popViewController(animated: true)
       
    }
    
    //MARK: API Methods
    func getContactUsCategoryListing(){
        
        let params = NSMutableDictionary()

        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeGetCall(url:Constant.sharedinstance.getContactUsCategory, param: params, completionHandler: {(responseObject, error) ->  () in
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
                
                    self.categoryArray.removeAll()
                    if let  catArr = result["payload"] as? NSArray {
                        for dict in catArr {
                            self.categoryArray.append((dict as! Dictionary)["value"] ?? "")
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
    
   
    @IBAction func submitButtonAction(){
        self.view.endEditing(true)
        var txtquery = tvQuery.text?.trimmingCharacters(in: .whitespaces)
        if txtquery == "Enter your issues/query" {
            txtquery = ""
        }
        
        if txtName.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            Themes.sharedInstance.ShowNotification("Name cannot be empty", false)
        }else if txtEmail.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            Themes.sharedInstance.ShowNotification("Email cannot be empty", false)
        } else if  txtEmail.text?.isValidEmail == false {
            Themes.sharedInstance.ShowNotification("Invalid email", false)
        }else if txtPhone.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            Themes.sharedInstance.ShowNotification("Phone number cannot be empty", false)
        }else if ((self.txtPhone.text?.count)! < 4 || (self.txtPhone.text?.count)! >= 16) {
            Themes.sharedInstance.ShowNotification("Enter valid mobile number", false)
        }else if txtCategory.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            Themes.sharedInstance.ShowNotification("Category cannot be empty", false)
        }else if txtquery!.isEmpty == true {
            Themes.sharedInstance.ShowNotification("Issue/Query cannot be empty", false)
        }else {
            let params = NSMutableDictionary()
            
            
            params.setValue(txtName.text, forKey: "name")
            params.setValue(txtEmail.text, forKey: "email")
            params.setValue(txtPhone.text, forKey: "mobile")
            params.setValue(txtCategory.text, forKey: "category")
            params.setValue(tvQuery.text, forKey: "issue")
            params.setValue("OS:IOS, Version:\(UIDevice.current.systemVersion) Model:\(UIDevice.current.model)", forKey: "OS")
            
            
            if countryCode.length > 0{
                params.setValue( countryCode + (txtPhone.text ?? ""), forKey: "mobile")
                
            }
            
            Themes.sharedInstance.activityView(View: self.view)
            
            //
            //            URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.submitContactUsURL, param: params, completionHandler: {(responseObject, error) ->  () in
            
            
            URLhandler.sharedinstance.uploadImageWithParameters(profileImg:documentImg ?? UIImage(), imageName: "attachment", url: Constant.sharedinstance.submitContactUsURL, params: params as! [String : Any])
            { response in
                
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                
                let message = response["message"] as? String ?? ""
                let status = response["status"] as? Int16 ?? 0
                
                
                if status == 1 {
                    
                    let alert = UIAlertController(title: "PickZon Support", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                        
                    }
                }
            }
        }
    }
    
    @IBAction func showCategoryAction(){
        
        self.view.endEditing(true)
        
        ActionSheetMultipleStringPicker.show(withTitle: "", rows: [
            categoryArray
        ], initialSelection: [0, 0], doneBlock: {
            picker, indexes, values in
        
             if let str = (values as AnyObject?) as? NSArray {
              
                 self.txtCategory.text = str[0] as? String ?? ""
                 //self.userObject.job   = str[0] as? String ?? ""
                 //self.tblView.reloadRows(at: [IndexPath(row: 5, section: 0)], with: .none)
             }
            
            return
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: txtCategory)
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == txtCategory{
            self.view.endEditing(true)
            
            ActionSheetMultipleStringPicker.show(withTitle: "", rows: [
                categoryArray
            ], initialSelection: [0, 0], doneBlock: {
                picker, indexes, values in
            
                 if let str = (values as AnyObject?) as? NSArray {
                  
                     self.txtCategory.text = str[0] as? String ?? ""
                     //self.userObject.job   = str[0] as? String ?? ""
                     //self.tblView.reloadRows(at: [IndexPath(row: 5, section: 0)], with: .none)
                 }
                
                return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: textField)
            return false
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let length = (textField.text?.count)! - range.length + string.count
        
       
        if textField.tag == 1002{
            if length > 16{
                return false
            }
        }
        
        return true
    }
    //MARK: - UITextViewDelegate methods
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter your issues/query" {
            textView.text = nil
            textView.textColor = UIColor.label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter your issues/query"
            textView.textColor = UIColor.lightGray
        }
    }
}


extension ContactUSViewController: MICountryPickerDelegate {
    @IBAction func uploadimageAction(){
        self.openGallery()
    }

func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String) {
  //  picker.navigationController?.popViewController(animated: true)
    picker.navigationController?.isNavigationBarHidden = true
}

func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String,countryFlagImage:UIImage){
    picker.navigationController?.popViewController(animated: true)
    btncountryCode.setTitle("\(dialCode)", for: .normal)
    countryCode = dialCode
    picker.navigationController?.isNavigationBarHidden = true
}

}


extension ContactUSViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func openGallery(){
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                DispatchQueue.main.async {
                    self.picker = UIImagePickerController()
                    self.picker?.sourceType = UIImagePickerController.SourceType.photoLibrary
                    self.picker?.delegate = self
                    self.present(self.picker!, animated: true, completion: nil)
                }
                
            }
        }
    }
        
        
    
    
    //MARK: -- ImagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as AnyObject
        
        if let image = info[.originalImage] as? UIImage {
                documentImg = image
                self.btnChooseFile.setTitle("File Attached", for: .normal)
            self.imguploadedFile.image = documentImg
            self.imguploadedFile.isHidden = false
                
        }else {
            documentImg = nil
            self.imguploadedFile.image = documentImg
            self.imguploadedFile.isHidden = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismissView(animated: true, completion: nil)
    }
    
}


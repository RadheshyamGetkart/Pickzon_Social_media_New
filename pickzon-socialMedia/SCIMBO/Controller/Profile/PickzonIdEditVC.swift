//
//  PickzonIdEditVC.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 2/7/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit
import JSSAlertView
import Alamofire

protocol PickzonIdDelegate: AnyObject{
    func getPickzonId(pickzonId:String)
}
class PickzonIdEditVC: UIViewController ,UITextFieldDelegate{
    var pickzonId = ""
    var isIdExists = true
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnIsAvailable: UIButtonX!
    @IBOutlet weak var txtfield:SkyFloatingLabelTextFieldWithIcon!
    var delegate:PickzonIdDelegate? = nil
    
    //MARK: UIButton ACtion Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnDone.isUserInteractionEnabled = false
        txtfield.delegate = self
        txtfield.text = pickzonId
        self.btnIsAvailable.setImageTintColor(UIColor.systemGreen)
    }
    
    @IBAction func donePickzonIdBtnAction(_ sender: UIButton){
        self.view.endEditing(true)
        txtfield.text = (txtfield.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (txtfield?.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty == true{
            
            Themes.sharedInstance.ShowNotification("Pickzon Id cannot be empty", false)
            
        }else if (txtfield?.text ?? "").isValidUserName == false{
            
            Themes.sharedInstance.ShowNotification("Pickzon Id can only contains alphanumeric characters, underscore, dot & minimum length is 5 characters and maximum 20 characters.", false)
        }else if self.isIdExists == true{
            Themes.sharedInstance.ShowNotification("Pickzon Id already exists.", false)
        }else{
            updatePickzonId()
            /* else if txtfield?.text?.fisrtCharacterIsAlphabet == false {
             Themes.sharedInstance.ShowNotification("Pickzon Id must starts with alphabet.", false)
             } if let stringArray = txtfield?.text?.components(separatedBy: CharacterSet.decimalDigits) {
             if stringArray.count > 2 {
             updatePickzonId()
             }else {
             Themes.sharedInstance.ShowNotification("Pickzon Id must contain at least two digits.", false)
             }
             }*/
        }
    }
    
    
    @IBAction func backBtnAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Api Methods
    
    func updatePickzonId(){

        let params = NSMutableDictionary()
        
        params.setValue((txtfield.text ?? "").lowercased(), forKey: "pickzonName")
       

        Themes.sharedInstance.activityView(View: self.view)
        
        
        URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.updatePickzonName, param: params, completionHandler: {(responseObject, error) ->  () in
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
                    
                    self.delegate?.getPickzonId(pickzonId: self.txtfield.text?.lowercased() ?? "")
                    let alertview = JSSAlertView().show(self,title: "Pickzon",text: message ,buttonText: "Ok",cancelButtonText: nil ,color: CustomColor.sharedInstance.newThemeColor)
                    
                    alertview.addAction {
                    
                    }
                  self.navigationController?.popViewController(animated: true)
                
                }
                else
                {
                    DispatchQueue.main.async {
                        
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)}
                }
            }
        })
        
    }
    
    func searchUserByPickZonId(pickZonID : String){

        let params = NSMutableDictionary()
        let url = Constant.sharedinstance.searchUserBuPickZonIdUrl + "?keyword=\((pickZonID).lowercased())"
        
        if URLhandler.sharedinstance.isUploadingNewPost == false {
            AF.cancelAllRequests()
        }
       // Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeGetAPICall(url:url, param: params, completionHandler: {(responseObject, error) ->  () in
           // Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    DispatchQueue.main.async {
                        self.btnIsAvailable.setImage(UIImage(named: "tick"), for: .normal)
                        self.btnIsAvailable.setImageTintColor(UIColor.systemGreen)
                        self.isIdExists = false
                        self.btnDone.isUserInteractionEnabled = true
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        self.isIdExists = true
                        self.btnDone.isUserInteractionEnabled = false
                        self.btnIsAvailable.setImage(UIImage(named: "close_view"), for: .normal)
                        self.btnIsAvailable.setImageTintColor(UIColor.systemRed)
                        Themes.sharedInstance.ShowNotification(message, false)
                    }
                }
            }
        })
        
    }
    
   
    //MARK: UITextfield  Delegate methods
    //restrict from paste
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            return action == #selector(UIResponderStandardEditActions.paste(_:)) ?
                false : super.canPerformAction(action, withSender: sender)
        }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        

        
        if string == " " || string == "@" || string == "#" || string == "," ||  string == "?" ||  string == "&"{
            return false
        }
        
        /*let  char = string.cString(using: String.Encoding.utf8)!
           
           let isBackSpace = strcmp(char, "\\b")
           
           var currentText = ""
           
           if (isBackSpace == -92) {
              currentText = textField.text!.substring(to: textField.text!.index(before: textField.text!.endIndex))
           }
           else {
               currentText = textField.text! + string
           }*/
        
        var currentText = ""
        if let text = textField.text,
                   let textRange = Range(range, in: text) {
                    currentText = text.replacingCharacters(in: textRange,
                                                               with: string)
        }
        
        
        if self.validateUsername(str: currentText) == true {
            
            self.isIdExists = true
            self.btnDone.isUserInteractionEnabled = false
            self.btnIsAvailable.setImage(UIImage(named: "close_view"), for: .normal)
            self.btnIsAvailable.setImageTintColor(UIColor.systemRed)
            if currentText.length > 5 {
                    self.searchUserByPickZonId(pickZonID: currentText)
                }
        }else {
            return false
        }
        return true
    }
    
    
   
    func validateUsername(str: String) -> Bool
    {
        do
        {
            let regex = try NSRegularExpression(pattern: "^[0-9a-zA-Z\\_\\.]{0,20}$", options: .caseInsensitive)
            if regex.matches(in: str, options: [], range: NSMakeRange(0, str.count)).count > 0
            {
                return true
            }
        }
        catch {}
        return false
    }
    
}



extension String {
        var isValidUserName : Bool {
            let userNameRegEx = "^[0-9a-zA-Z\\_\\.]{5,20}$"

            let userNameChecker = NSPredicate(format:"SELF MATCHES[c] %@", userNameRegEx)
            return userNameChecker.evaluate(with: self)
        }
    }
extension String {
    var fisrtCharacterIsAlphabet: Bool {
         guard let firstChar = self.first else { return false }
         let unicode = String(firstChar).unicodeScalars
         let ascii = Int(unicode[unicode.startIndex].value)
         return (ascii >= 65 && ascii <= 90) || (ascii >= 97 && ascii <= 122)
    }
    
}

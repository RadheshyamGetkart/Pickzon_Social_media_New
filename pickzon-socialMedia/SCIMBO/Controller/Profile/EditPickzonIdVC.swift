//
//  EditPickzonIdVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 23/07/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import JSSAlertView
import Alamofire
import IQKeyboardManager

class EditPickzonIdVC: UIViewController {

    @IBOutlet weak var imgVwTick:UIImageView!
    @IBOutlet weak var lblTItle:UILabel!
    @IBOutlet weak var txtFdPickzonId:UITextField!
    @IBOutlet weak var lblCoin:UILabel!
    @IBOutlet weak var btnSubmit:UIButton!
    @IBOutlet weak var lblErrorMsg:UILabel!
    @IBOutlet weak var cnstrntHeight:NSLayoutConstraint!

    var delegate:PickzonIdDelegate? = nil
    var pickzonId = ""
    var isIdExists = true
    var availableCoin = 0
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtFdPickzonId.layer.borderColor = UIColor.systemBlue.cgColor
        self.txtFdPickzonId.layer.borderWidth = 1.5
        self.txtFdPickzonId.layer.cornerRadius = 5.0
        self.txtFdPickzonId.clipsToBounds = true
        self.txtFdPickzonId.addLeftPadding()
        self.txtFdPickzonId.delegate = self
        self.txtFdPickzonId.addRightPadding()
        self.imgVwTick.setImageColor(color: UIColor.systemBlue)
        self.imgVwTick.isHidden = true
        self.lblErrorMsg.isHidden = true
        self.lblErrorMsg.text = "This PickZon Id is taken"
        
        self.lblTItle.text = "Change your PickZon Id for just \(Settings.sharedInstance.pickzonIdChangeCharge) cheer coins"
        self.btnSubmit.layer.cornerRadius = 5.0
        self.btnSubmit.clipsToBounds = true
        self.txtFdPickzonId.text = pickzonId
        
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        getAvailableCoinsApi()
    }
   
    //MARK: UIButton Action methods
    
    @IBAction func submitBtnAction(_ sender : UIButton){
       
        txtFdPickzonId.text = (txtFdPickzonId.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (txtFdPickzonId?.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty == true{
            
            
        }else{
            if availableCoin < Settings.sharedInstance.pickzonIdChangeCharge{
               
                let viewController:WalletVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
                viewController.isGiftedCoinsTabOpen = false
                self.navigationController?.pushView(viewController, animated: true)
                
            }else{
                self.updatePickzonId()
            }
        }
    }
    
    @IBAction func crossBtnAction(_ sender : UIButton){
        
        if self.sheetViewController?.options.useInlineMode == true {
            self.sheetViewController?.attemptDismiss(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: Api Methods
    func getAvailableCoinsApi(){
        
        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: true)

        URLhandler.sharedinstance.makeGetCall(url: Constant.sharedinstance.userCoinInfo, param: [:]) {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)

            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let msg = result["message"] as? String ?? ""

                if status == 1 {
                    if let payload = result["payload"] as? Dictionary<String, Any> {
                        self.availableCoin = payload["cheerCoins"] as? Int ?? 0
                        self.lblCoin.text = "\(self.availableCoin)"
                    }
                        
                }else{
                    self.view.makeToast(message: msg , duration: 3, position: HRToastActivityPositionDefault)

                }
            }
        }
    }
    func updatePickzonId(){

        let params = NSMutableDictionary()
        
        params.setValue((txtFdPickzonId.text ?? "").lowercased(), forKey: "pickzonName")

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
                    
                    self.delegate?.getPickzonId(pickzonId: self.txtFdPickzonId.text?.lowercased() ?? "")
                    let alertview = JSSAlertView().show(self,title: "Pickzon",text: message ,buttonText: "Ok",cancelButtonText: nil ,color: CustomColor.sharedInstance.newThemeColor)
                    
                    alertview.addAction {
                    
                    }
                    if self.sheetViewController?.options.useInlineMode == true {
                        self.sheetViewController?.attemptDismiss(animated: true)
                    } else {
                        self.dismiss(animated: true, completion: nil)
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
               // self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    DispatchQueue.main.async {
                        self.imgVwTick.isHidden = false
                        self.lblErrorMsg.isHidden = true
                        self.isIdExists = false
                        self.btnSubmit.isUserInteractionEnabled = true
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        self.isIdExists = true
                        self.btnSubmit.isUserInteractionEnabled = false
                        self.imgVwTick.isHidden = true
                        self.lblErrorMsg.isHidden = false
                        self.lblErrorMsg.text = message
                    }
                }
            }
        })
        
    }
    
    
}


extension EditPickzonIdVC:UITextFieldDelegate{
    //MARK: UITextfield  Delegate methods
    
    
    //restrict from paste
//    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        return action == #selector(UIResponderStandardEditActions.paste(_:)) ?
//        false : super.canPerformAction(action, withSender: sender)
//    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
        print("Range: \(range), Replacement String: '\(string)'")
                
        if string == " " || string == "@" || string == "#" || string == "," ||  string == "?" ||  string == "&"{
            return false
        }
        
     
        var currentText = ""
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            currentText = text.replacingCharacters(in: textRange,
                                                   with: string)
        }
                
        if self.validateUsername(str: currentText) == true {
            self.isIdExists = true
            self.btnSubmit.isUserInteractionEnabled = false
           // self.imgVwTick.isHidden = true
            //self.lblErrorMsg.isHidden = false
            
            if currentText.length > 5 {
                self.searchUserByPickZonId(pickZonID: currentText)
                self.btnSubmit.backgroundColor = .systemBlue

            }else{
                self.btnSubmit.backgroundColor = .darkGray
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

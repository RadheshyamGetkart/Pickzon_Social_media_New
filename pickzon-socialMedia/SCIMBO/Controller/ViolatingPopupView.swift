//
//  ViolatingPopupView.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 4/1/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit


class ViolatingPopupView: UIView {
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var bgview:UIView!
    @IBOutlet weak var lblMsg:UILabel!
    @IBOutlet weak var btnPrivacy:UIButton!
    @IBOutlet weak var btnChkBox:UIButton!
    var isSelected = false
    var delegate:StoriesDelegate? = nil
    
    func initializeMethods(frame:CGRect,title:String,message:String)  {
        self.removeFromSuperview()
        self.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        view.backgroundColor = .clear
        bgview.backgroundColor =  UIColor.black.withAlphaComponent(0.8)
       // self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnView)))
        self.lblMsg.text = message
        self.lblTitle.text = title
    }
    
   
    @objc func tapOnView(){
        self.removeFromSuperview()
    }
    
    
    @IBAction func checkBoxButtonAction(_ sender: UIButton) {
        btnChkBox.isSelected.toggle()
    }
 
    @IBAction func privacyButtonAction(_ sender: UIButton) {
        
        let destVC:PrivacyPolicyViewController = StoryBoard.main.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
        destVC.strTitle = "Terms and Privacy Policy"
        destVC.strURl = Constant.sharedinstance.privacyURL
        print(Constant.sharedinstance.privacyURL)
        AppDelegate.sharedInstance.navigationController?.pushView(destVC, animated: true)
        tapOnView()
//        guard let url = URL(string: Constant.sharedinstance.privacyURL) else { return }
//        UIApplication.shared.open(url)
    }
    
    @IBAction func submitButtonAction(_ sender: UIButton) {
      
        if btnChkBox.state == .normal {
            view.makeToast(message: "Please accept Pickzon privacy policy" , duration: 3, position: HRToastActivityPositionDefault)
        }else{

            readWarnedUserApi()
        }
    }
    
    //MARK: Api Methods
    
    func readWarnedUserApi(){
        let params = ["isRead":1] as [String : Any]
        
        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.warnUserRead, param: params as NSDictionary, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
               
                AppDelegate.sharedInstance.navigationController?.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)

                if status == 1 {
                    Settings.sharedInstance.warningDict = nil
                    self.removeFromSuperview()
                }
            }
        })
    }
    
    
}

//
//  DeleteAccountOptionsVC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 1/11/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import IQKeyboardManager
class DeleteAccountOptionsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblDescTitle:UILabel!
    @IBOutlet weak var lblDescription:UILabel!
    @IBOutlet weak var tblOptions:UITableView!
    @IBOutlet weak var btnDelete:UIButtonX!
    @IBOutlet weak var txtVwReason:UITextView!
    
    var selectedOption:Int = 0
    var selectedIndex:Int = -1
    var arrOptions:Array<String> = Array()
    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedOption == 0 {
            lblTitle.text = "Deactivate account"
            lblDescTitle.text = "Why do you want to deactivate your account?"
            lblDescription.text = "Your account will be deactivated until you reactivate it from your side. Although your profile and media files will remain as it is, they won’t be visible to other users."
            btnDelete.setTitle("Deactivate account", for: .normal)
        }else {
            lblTitle.text = "Delete account"
            lblDescTitle.text = "Why do you want to delete your account?"
            lblDescription.text = "Your account will be deleted permanently. It may take anywhere between 7 days to 30 days to permanently delete your Pickzon account."
            btnDelete.setTitle("Delete account", for: .normal)
        }
        
        btnDelete.backgroundColor = UIColor.lightGray
        
        txtVwReason.isHidden = true
        txtVwReason.layer.cornerRadius = 5.0
        txtVwReason.clipsToBounds = true
        txtVwReason.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        self.getDeleteReasonList()
        
        
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
    
    
    //MARK: UIBUtton Action Methods
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func deleteButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        if selectedIndex == -1 {
            self.view.makeToast(message: "Please select reason" , duration: 3, position: HRToastActivityPositionDefault)
            
        }else if selectedIndex == arrOptions.count - 1 && txtVwReason.text.trim().count == 0 {
            self.view.makeToast(message: "Please enter reason" , duration: 3, position: HRToastActivityPositionDefault)
        }else{
            let title = (selectedOption == 0) ? "deactivate" : "delete"
            AlertView.sharedManager.presentAlertWith(title: "Are you sure you want to \(title) your account?" as NSString, msg: "" , buttonTitles: ["Yes","No"], onController: self) { title, index in
                if index == 0 {
                    self.deleteAccountApi()
                }
            }

        }
    }
    
    //MARK: APi Methods
    func getDeleteReasonList()
    {
        Themes.sharedInstance.activityView(View: self.view)
        let param:NSDictionary = [:]
        
        let url =  Constant.sharedinstance.deleteReasonListURL + "?isDelete=\(selectedOption)"
        
        URLhandler.sharedinstance.makeGetCall(url:url as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
                
                if status == 1 {
                    let dictPayload = result["payload"] as? NSDictionary ?? [:]
                    self.arrOptions = dictPayload["reason"] as? Array<String> ?? []
                    self.lblDescTitle.text = dictPayload["title"] as? String ?? ""
                    self.lblDescription.text = dictPayload["description"] as? String ?? ""
                    self.tblOptions.reloadData()
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
  
    func deleteAccountApi(){
        
        var reason = ""
        if selectedIndex == arrOptions.count - 1 {
            reason = txtVwReason.text ?? ""
        }else {
            reason = arrOptions[selectedIndex]
        }

        let params = ["reason":reason,"type":(selectedOption == 0) ? "temporary" : "permanent"] as [String : Any]
        Themes.sharedInstance.activityView(View: self.view)
        

        URLhandler.sharedinstance.makeDeleteAPICall(url: Constant.sharedinstance.deleteAccountURL, param: params as NSDictionary) { responseObject, error in
            Themes.sharedInstance.RemoveactivityView(View: self.view)

            if let result = responseObject {
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["Ok"], onController: self) { title, index in
                        
                        DBManager.shared.clearDB()
                        (UIApplication.shared.delegate as! AppDelegate).Logout(istocallApi: false)
                    }
                }else{
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
                
                
            }
            
        }
    }
    
    
    @objc func selectButtonAction(sender: UIButton) {
        selectedIndex = sender.tag
        btnDelete.backgroundColor = UIColor.systemBlue
        
        if selectedIndex == arrOptions.count - 1 {
            txtVwReason.isUserInteractionEnabled = true
            txtVwReason.isHidden = false

        }else {
            txtVwReason.isUserInteractionEnabled = false
            txtVwReason.isHidden = true
            txtVwReason.text = ""
        }
        self.tblOptions.reloadData()
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteAccountOptionsCell", for: indexPath) as! DeleteAccountOptionsCell
        cell.lblDesc.text = arrOptions[indexPath.row]
        cell.btnRadio.tag = indexPath.row
        cell.btnRadio.addTarget(self, action: #selector(selectButtonAction(sender:)), for: .touchUpInside)
        cell.btnRadio.setImage(UIImage(named: "unselectedRadio"), for: .normal)
        if indexPath.row == selectedIndex{
            cell.btnRadio.setImage(UIImage(named: "selectedRadio"), for: .normal)
        }
       
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        btnDelete.backgroundColor = UIColor.systemBlue
        if selectedIndex == arrOptions.count - 1 {
            txtVwReason.isHidden = false
            txtVwReason.isUserInteractionEnabled = true
        }else {
            txtVwReason.isUserInteractionEnabled = false
            txtVwReason.isHidden = true
            txtVwReason.text = ""
        }
        self.tblOptions.reloadData()
    }
    
}


class DeleteAccountOptionsCell:UITableViewCell{
    @IBOutlet weak var lblDesc:UILabel!
    @IBOutlet weak var btnRadio:UIButton!
}

//
//  NotificationSettingsVC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 4/4/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class NotificationSettingsVC: UIViewController {
    
    @IBOutlet weak var cntrntHt_NavBar:NSLayoutConstraint!
    @IBOutlet weak var tblNotifications:UITableView!
    var arrOptions:Array<Dictionary<String,Any>> = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cntrntHt_NavBar.constant = self.getNavBarHt
        tblNotifications.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
        tblNotifications.separatorColor = UIColor.clear
        self.getNotificationSettings()
    }
    
    
    deinit{
        print("deinit")
    }
    //MARK: UIButton Action Methods
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getNotificationSettings(){
        
        DispatchQueue.main.async {
            Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
        }
        
        let params = NSMutableDictionary()
        
        URLhandler.sharedinstance.makeGetCall(url:Constant.sharedinstance.getNotificationSettingsURL as String, param: params, completionHandler: {(responseObject, error) ->  () in
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
            }
            
            if(error != nil)
            {
                DispatchQueue.main.async {
                    
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    print(error ?? "defaultValue")
                }
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                
                if status == 1 {
                    self.arrOptions = result["payload"] as? Array<Dictionary<String, Any>> ?? []
                    self.tblNotifications.reloadData()
                    
                }
                else
                {
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        })
    }
    
    func updateNotificationsApi(dict:Dictionary<String, Any>)  {
        
        
        
        let param:NSDictionary = [  "notifType": dict["notifType"] as? String ?? "",
                                    "value": dict["value"] as? Int ?? 0
        ]
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.updateNotificationSettingsURL as String, param: param, methodType: .put, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
                if status == 1{
                    
                    self.arrOptions = result["payload"] as? Array<Dictionary<String, Any>> ?? []
                    self.tblNotifications.reloadData()
                } else {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    
    @objc func switchBtnAction(_ sender:UISwitch){
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tblNotifications)
        if let indexPath = self.tblNotifications.indexPathForRow(at: buttonPosition) {
            
            var obj = arrOptions[indexPath.row]
            obj["value"] = sender.isOn == true ?  1 :  0
            arrOptions[indexPath.row] = obj
            
            if indexPath.row == 0 {
                for ind in 0..<arrOptions.count {
                    var obj = arrOptions[ind]
                    obj["value"] = sender.isOn == true ? 1 : 0
                    arrOptions[ind] = obj
                }
            }else {
                
                var isAllOne = 1
                for ind in 1..<arrOptions.count {
                    let obj = arrOptions[ind]
                    if obj["value"] as? Int ?? 0 == 0 {
                        isAllOne = 0
                    }
                }
                
                var obj = arrOptions[0]
                if isAllOne == 1 {
                    obj["value"] = 1
                }else {
                    obj["value"] = 0
                }
                arrOptions[0] = obj
            }
            tblNotifications.reloadData()
            self.updateNotificationsApi(dict: arrOptions[indexPath.row])
        }
        
    }
    
}


extension NotificationSettingsVC:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as! NotificationCell
        let obj = arrOptions[indexPath.row]
        cell.lblTitle.text = obj["title"] as? String ?? ""
        cell.lblSubTitle.text = obj["subTitle"] as? String ?? ""
        cell.optionSwitch.onTintColor = UIColor.lightGray
        if obj["value"] as? Int == 1 {
            cell.optionSwitch.setOn(true, animated: false)
        }else {
            cell.optionSwitch.setOn(false, animated: false)
        }
        
        cell.optionSwitch.addTarget(self, action: #selector(switchBtnAction(_ : )), for: .valueChanged)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//
//  ReportUserVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 3/11/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

enum ReportType{
    
    case chat
    case user
    case post
    case warnUser
    case clip
}

class ReportUserVC: UIViewController {
   
    @IBOutlet weak var mainBgView: UIViewX!
    @IBOutlet weak var lblSubHeading: UILabel!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var tblView: UITableView!
    var listArray = [String]()
    var reportingId = ""
    var reportType:ReportType?
    var toReportedUserId = ""

    //MARK: Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        getReportListApi()
        tblView.layer.cornerRadius = 5.0
        tblView.clipsToBounds = true
    }
        
    // MARK: - UIButton Action Methods
    @IBAction func crossbtnAction(_ sender: UIButton) {
        self.dismissView(animated: true)
        self.navigationController?.dismissView(animated: true)
    }
    //MARK: Api Methods

    func getReportListApi(){
        
        var listUrl = Constant.sharedinstance.reportList + "type=chat"
        if reportType == .user{
            listUrl = Constant.sharedinstance.reportList + "type=chat"
        }else  if reportType == .post{
            listUrl = Constant.sharedinstance.reportList + "type=post"
        }else  if reportType == .warnUser{
            listUrl = Constant.sharedinstance.reportList + "type=post"
        }else  if reportType == .clip{
            listUrl = Constant.sharedinstance.reportList + "type=post"
        }
            
            
        
        URLhandler.sharedinstance.makeGetAPICall(url: listUrl, param: [:]) {(responseObject, error) ->  () in
          
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
               
                if status == 1{
                    
                    if let payload = result["payload"] as? NSDictionary{
                        
                        let title = payload["title"] as? String ?? ""
                        self.listArray = payload["reason"] as? [String] ?? [String]()
                        DispatchQueue.main.async {
                            self.lblHeading.text = title
                            self.tblView.reloadData()
                        }
                    }
                } else {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
    }
    
    func messageAlertWithReport() {
        
        let alertController = UIAlertController(title: "Report ", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Submit", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            if (firstTextField.text?.trim().count ?? 0 > 0){
                if self.reportType == .post{
                    self.reportPostApi(message:  firstTextField.text!)
                }else if self.reportType == .warnUser{
                    self.warnUserRegardingPostApi(reason: firstTextField.text!)
                }
//                else if self.reportType == .clip
//                {
//                    self.reportClipApi(message: firstTextField.text!)
//                }
                else{
                    self.reportUserApi(reason: firstTextField.text!)
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in })
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Report message"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
   
    
    //MARK: API methods
    
    func warnUserRegardingPostApi(reason:String){
        
        let params = ["to":toReportedUserId ,"reason":reason,"feedId":reportingId] as [String : Any]
        
        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.userWarn, param: params as NSDictionary, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1 {
                    self.dismissView(animated: true)
                    self.navigationController?.dismissView(animated: true)
                }
       
                AppDelegate.sharedInstance.navigationController?.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
            }
        })
    }
    
    func reportUserApi(reason:String){
        
        DispatchQueue.main.async {
            Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
        }
        
        let params = NSMutableDictionary()
        params.setValue(reportingId, forKey: "reportUserId")
        params.setValue(reason, forKey: "reason")

        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.reportUserProfile, param: params) { responseObject, error in
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)}
            
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
               
                self.dismissView(animated: true)
                self.navigationController?.dismissView(animated: true)

                AlertView.sharedManager.displayMessageWithAlert(title: "", msg: message)

            }
        }
    }
    
    
    @objc func reportPostApi(message:String)  {
        
        let param:NSDictionary = ["feedId":"\(reportingId)","message":message]
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.reportWallPost as String, param: param, completionHandler: {(responseObject, error) ->  () in
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
                    self.dismissView(animated: true)
                    self.navigationController?.dismissView(animated: true)
                   // let objDict = ["feedId":self.reportingId]
                   // NotificationCenter.default.post(name: notif_FeedRemoved, object: objDict)
                    
                    AlertView.sharedManager.displayMessage(title: "PickZon", msg: message as! String, controller: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
                }else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    

    
    
//    @objc func reportClipApi(message:String)  {
//        
//        let param:NSDictionary = ["clipId":"\(reportingId)","message":message]
//        
//        Themes.sharedInstance.activityView(View: self.view)
//        
//        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.clip_report_clip as String, param: param, completionHandler: {(responseObject, error) ->  () in
//            Themes.sharedInstance.RemoveactivityView(View: self.view)
//            if(error != nil)
//            {
//                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
//                print(error ?? "defaultValue")
//            }else{
//                let result = responseObject! as NSDictionary
//                let status = result["status"] as? Int ?? 0
//                let message = result["message"]
//                if status == 1{
//                    self.dismissView(animated: true)
//                    self.navigationController?.dismissView(animated: true)
//
//                    
//                    AlertView.sharedManager.displayMessage(title: "PickZon", msg: message as! String, controller: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
//                }else
//                {
//                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
//                }
//            }
//        })
//    }

    
}

extension ReportUserVC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "cellId")
        cell.selectionStyle = .none
        cell.textLabel?.text = listArray[indexPath.row]
        cell.textLabel?.numberOfLines = 0
       // cell.backgroundColor = .clear
        cell.textLabel?.font =  UIFont(name: "Roboto-Regular", size: 16.0)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        if listArray[indexPath.row] == "Others"{
            
            self.messageAlertWithReport()
        }else{
            if reportType == .post{
                self.reportPostApi(message:  listArray[indexPath.row])
            }else if reportType == .warnUser{
                self.warnUserRegardingPostApi(reason: listArray[indexPath.row])
                
            }
//            else if self.reportType == .clip
//            {
//                self.reportClipApi(message: listArray[indexPath.row])
//            }
            else{
                self.reportUserApi(reason: listArray[indexPath.row])
            }
        }
    }
}

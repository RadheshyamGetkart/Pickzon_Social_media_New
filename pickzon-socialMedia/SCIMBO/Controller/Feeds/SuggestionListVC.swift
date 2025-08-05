//
//  SuggestionListVC.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 1/8/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit
import Contacts

class SuggestionListVC: UIViewController {

    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var lblSeperator:UILabel!
    @IBOutlet weak var btnSuggested:UIButton!
    @IBOutlet weak var btnContacts:UIButton!
    @IBOutlet weak var btnRequests:UIButton!
    
    var isSuggestedSelected = true
    var isContactSelected = false
    var isRequestSelected = false
    var listArray = [SuggestedUser]()
    var contactArray = [SuggestedUser]()
    var requestArray = [Followers]()
    var emptyView:EmptyList?
    var pageNoSuggestion = 1
    var pageNoContact = 1
    var isDataLoading = false
    var pageNoRequest = 1
    
    //MARK: - Controller Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyView = EmptyList(frame: CGRect(x: 0, y: -64, width: self.view.frame.size.width, height: tblView.frame.size.height))
        self.tblView.addSubview(emptyView!)
        emptyView?.imageView?.image = PZImages.noData 
        emptyView?.lblMsg?.text = ""
        emptyView?.isHidden = true
        
        tblView.register(UINib(nibName: "SuggestionListTblCell", bundle: nil), forCellReuseIdentifier: "SuggestionListTblCell")
        tblView.register(UINib(nibName: "LoadMoreTblCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTblCell")
        
        if ContactHandler.sharedInstance.permissionUnknown(){
            ContactHandler.sharedInstance.GetPermission()
        }else{
           // ContactHandler.sharedInstance.StoreContacts()
        }
        
        btnContacts.setTitleColor(.lightGray, for: .normal)
        btnRequests.setTitleColor(.lightGray, for: .normal)
        btnSuggested.setTitleColor(.lightGray, for: .normal)

        if isSuggestedSelected == true {
            getSuggestionListApi(type: 0)
            lblSeperator.frame =  CGRect(x: btnSuggested.frame.origin.x, y: btnSuggested.frame.origin.y+btnSuggested.frame.size.height, width: btnSuggested.frame.size.width, height: 4)
            btnSuggested.setTitleColor(.label, for: .normal)

        }else if isContactSelected == true  {
            lblSeperator.frame =  CGRect(x: btnContacts.frame.origin.x, y: btnContacts.frame.origin.y+btnContacts.frame.size.height, width: btnContacts.frame.size.width, height: 4)
            btnContacts.setTitleColor(.label, for: .normal)

        }else if isRequestSelected == true  {
            self.fetchFriendRequestList()
            btnRequests.setTitleColor(.label, for: .normal)
            lblSeperator.frame =  CGRect(x: btnRequests.frame.origin.x, y: btnRequests.frame.origin.y+btnRequests.frame.size.height, width: btnRequests.frame.size.width, height: 4)
        }
    }
    
    override  func  viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        requestContactsAccess()

    }
    
    private func requestContactsAccess() {
        let store = CNContactStore()

        store.requestAccess(for: .contacts) {granted, error in
            if granted {
               // ContactHandler.sharedInstance.StoreContacts()

            }else{
                let alertController = UIAlertController(title: "Contact Permission Required", message: "Please enable contact permissions in settings to upload your contacts to PickZon's servers to help you quickly get in touch with your friends and help us provide a better experience.", preferredStyle: UIAlertController.Style.alert)
                
                let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
                    //Redirect to Settings app
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
                alertController.addAction(cancelAction)
                
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    //MARK: - UIButton Action Methods
    @IBAction func backBtnAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func updateErrorMessage(){
       
        if isSuggestedSelected{
            
            DispatchQueue.main.async {
                
                self.emptyView?.isHidden = (self.listArray.count) == 0 ? false : true
                self.emptyView?.lblMsg?.text = "There are no recommendations for you."
            }
        }else if isContactSelected{
            DispatchQueue.main.async {
                
                self.emptyView?.isHidden = (self.contactArray.count) == 0 ? false : true
                self.emptyView?.lblMsg?.text = "Oops! You don’t have any contacts to follow."
            }
        }else if isRequestSelected{
            DispatchQueue.main.async {
                
                self.emptyView?.isHidden = (self.requestArray.count) == 0 ? false : true
                self.emptyView?.lblMsg?.text = "You haven’t received any request yet."
            }
        }
    }
    
    
    @IBAction func comonBtnAction(_ sender: UIButton){
        
        btnContacts.setTitleColor(.lightGray, for: .normal)
        btnRequests.setTitleColor(.lightGray, for: .normal)
        btnSuggested.setTitleColor(.lightGray, for: .normal)
        
        sender.setTitleColor(.label, for: .normal)

        UIView.animate(withDuration: 0.3, animations: {

        self.lblSeperator.frame =  CGRect(x: sender.frame.origin.x, y: sender.frame.origin.y+sender.frame.size.height, width: sender.frame.size.width, height: 4)
        })
        self.emptyView?.isHidden = true
       
        if sender.tag == 1000{
           //Suggested
            isSuggestedSelected = true
            isContactSelected = false
            isRequestSelected = false
            if listArray.count == 0{
                self.pageNoSuggestion = 1
                self.getSuggestionListApi(type: 0)
            }
            
        }else if sender.tag == 1001{
           //Contacts
            isSuggestedSelected = false
            isContactSelected = true
            isRequestSelected = false
          
            if contactArray.count == 0{
                self.pageNoContact = 1
                self.getSuggestionListApi(type: 1)
                
            }
            
        }else  if sender.tag == 1002 {
             isSuggestedSelected = false
             isContactSelected = false
             isRequestSelected = true
            self.fetchFriendRequestList()
            }
        
       // self.updateErrorMessage()
        self.tblView.reloadData()
    }

   
    //MARK: - Api methods
    
    func getContactSuggestionListApi(){
        if self.pageNoContact == 1{
            DispatchQueue.main.async {
                Themes.sharedInstance.activityView(View: self.view)
            }
        }
        let param = NSMutableDictionary()
  
        let url = Constant.sharedinstance.contactSuggestedFriendsList + "?pageNumber=\(pageNoContact)&pageLimit=25"
        
        URLhandler.sharedinstance.makeGetCall(url: url, param: param) { responseObject, error in
            
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
                let totalPage = result["totalPages"] as? Int ?? 0
                self.isDataLoading = false
                
                if status == 1{
                    
                    if self.pageNoContact == 1 && self.isContactSelected{
                        self.contactArray.removeAll()
                    }
                    let payload = result.value(forKey: "payload") as? NSArray ?? []
                    if payload.count > 0{
                        for obj in payload {
                            autoreleasepool {
                                let objWallpostata = SuggestedUser(dict: obj as! NSDictionary,isNew: true)
                                self.contactArray.append(objWallpostata)
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.tblView.reloadData()
                        self.updateErrorMessage()
                    }
                }else
                {
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        }
        
    }
    
    func getSuggestionListApi(type:Int){
        
        if type == 1 {
            self.getContactSuggestionListApi()
        }else{
          
            if self.pageNoSuggestion == 1{
                DispatchQueue.main.async {
                    Themes.sharedInstance.activityView(View: self.view)
                }
            }
            let params = NSMutableDictionary()
            
            let url = Constant.sharedinstance.suggestedFriendsList + "?pageNumber=\(pageNoSuggestion)"
            
            URLhandler.sharedinstance.makeGetCall(url: url, param: params)  {(responseObject, error) ->  () in
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
                    let status = result["status"] as? Int16 ?? 0
                    let message = result["message"] as? String ?? ""
                   
                    self.isDataLoading = false
                    if status == 1{
                        
                        if self.pageNoContact == 1 && self.isContactSelected{
                            self.contactArray.removeAll()
                            
                        }else if self.pageNoSuggestion == 1 && self.isSuggestedSelected{
                            self.listArray.removeAll()
                            
                        }
                        
                           if let data = result.value(forKey: "payload") as? NSArray {
                             
                               if data.count > 0{
                                   for obj in data {
                                       autoreleasepool {
                                           let objWallpostata = SuggestedUser(dict: obj as! NSDictionary, isNew: true)
                                           self.listArray.append(objWallpostata)
                                       }
                                   }
                               }
                           }
                        
                        DispatchQueue.main.async {
                            self.tblView.reloadData()
                            self.updateErrorMessage()
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async {
                            self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                        }
                    }
                }
            }
        }
    }
    
    
    func fetchFriendRequestList(){
        
        let param:NSDictionary = ["pageNumber":pageNoRequest] //,"pageLimit":25]
        if self.pageNoRequest == 1{
            DispatchQueue.main.async {
                Themes.sharedInstance.activityView(View: self.view)}
        }
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.friendRequestList as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
             
                self.isDataLoading = false
                
                if status == 1{
                    if self.pageNoRequest == 1{
                        self.requestArray.removeAll()
                    }
                        if let reqArr = result["payload"] as? Array<[String:Any]> {
                            
                            for dict in reqArr {
                                autoreleasepool {
                                    self.requestArray.append(Followers(respDict: (dict as NSDictionary)))
                                }
                            }
                        }
      
                } else {
                    //self.view.makeToast(message: message, duration: 3, position: HRToastActivityPositionDefault)
                }
                
                
            DispatchQueue.main.async {
                self.tblView.reloadData()
                self.updateErrorMessage()

            }

            }
        })
    }
    
    func followBtn(index:Int){
        
        
        var status = 0
        let isFollow = (isContactSelected) ? contactArray[index].isFollow : listArray[index].isFollow
        
        if isFollow == 2
        {
            cancelFriendRequestApi(index: index)
        }else{
            let statuss = (isContactSelected) ? contactArray[index].isFollow : listArray[index].isFollow
            if statuss == 0 || statuss == 3
            {
                status = 1
            }else
            {
                status = 0
            }
                        
            let param:NSDictionary = ["followedUserId":((isContactSelected) ? contactArray[index].id :  listArray[index].id),"status":status]

            Themes.sharedInstance.activityView(View: self.view)
            
            URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.follow as String, param: param, completionHandler: {(responseObject, error) ->  () in
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                if(error != nil)
                {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                }
                else{
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int ?? 0
                    let message = result["message"]
                    let payloadDict = result["payload"] as? NSDictionary ?? [:]
//                    let isFollow = payloadDict["isFollow"] as? Int ?? 0
                    
                    if status == 1{
                        self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: noti_RefreshFeed), object:nil)

                        if self.isContactSelected {
                            self.contactArray.remove(at: index)
                        }else {
                            self.listArray.remove(at: index)
                        }
    
                        DispatchQueue.main.async {
                            self.tblView.reloadData()
                            self.updateErrorMessage()

                        }
                    }
                    else
                    {
                        self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            })
        }
    }
      
      
    func cancelFriendRequestApi(index:Int){
          
         Themes.sharedInstance.activityView(View: self.view)

        let param:NSDictionary =  ["followedUserId": (isContactSelected) ?  contactArray[index].id : listArray[index].id]

          URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.cancelRequest as String, param: param, completionHandler: {(responseObject, error) ->  () in
              Themes.sharedInstance.RemoveactivityView(View: self.view)
              if(error != nil)
              {
                  self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
              }
              else{
                  let result = responseObject! as NSDictionary
                  let status = result["status"] as? Int ?? 0
                  let message = result["message"] as? String ?? ""
                  //  let payloadDict = result["payload"] as? NSDictionary ?? [:]
                  //let isFollow = payloadDict["isFollow"] as? Int ?? 0
                
                  if status == 1{
                      
                      if self.isContactSelected {
                          self.contactArray[index].isFollow = 0
                      }else{
                          self.listArray[index].isFollow = 0
                      }

                     
                      DispatchQueue.main.async {
                          self.tblView.reloadData()
                          self.updateErrorMessage()
                        //  self.tblView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                      }

                      self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)

                  }
                  else
                  {
                      self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                  }
              }
          })
      }
    
    func removeSuggestionApi(index:Int){
        
        Themes.sharedInstance.activityView(View: self.view)
            
        let param:NSDictionary =  ["suggestedUserId":listArray[index].id]

         //key - 0 for friendSuggestion, 1 for contactSuggestion

         URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.removeSuggestedFriend as String, param: param, completionHandler: {(responseObject, error) ->  () in
             Themes.sharedInstance.RemoveactivityView(View: self.view)
             if(error != nil)
             {
                 self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
             }
             else{
                 let result = responseObject! as NSDictionary
                 let status = result["status"] as? Int16 ?? 0
                 let message = result["message"]
               
                 if status == 1 {
                         self.listArray.remove(at: index)

                     DispatchQueue.main.async {
                         self.tblView.reloadData()
                         self.updateErrorMessage()

                     }
                    
                 }
                 else
                 {
                     self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                 }
             }
         })
     }
    
    func removeContactFriendsSuggestionAPI(index:Int){
        
        Themes.sharedInstance.activityView(View: self.view)
            
        let param:NSDictionary =  ["userId":self.contactArray[index].id]

         URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.removeContactFriendsSuggestionURL as String, param: param, completionHandler: {(responseObject, error) ->  () in
             Themes.sharedInstance.RemoveactivityView(View: self.view)
             if(error != nil)
             {
                 self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
             }
             else{
                 let result = responseObject! as NSDictionary
                 let status = result["status"] as? Int16
                 let message = result["message"] as? String ?? ""
               
                 if status == 1{
                         self.contactArray.remove(at: index)
                     DispatchQueue.main.async {
                         self.tblView.reloadData()
                         self.updateErrorMessage()
                     }
                 }
                 else
                 {
                     self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                 }
             }
         })
     }
    

   
    func acceptRejectFriendRequest(isToAccept:Bool,index:Int){
        
        Themes.sharedInstance.activityView(View: self.view)
                    
        //let param:NSDictionary = ["requestId":obj.id , "key":((isToAccept == true) ? 1 : 0 )]
        let param:NSDictionary = ["userId":requestArray[index].id , "action":((isToAccept == true) ? 1 : 0 )]

        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.acceptFriend as String, param: param, completionHandler: { [self](responseObject, error) ->  () in
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                if(error != nil)
                {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                }
                else{
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int ?? 0
                    let message = result["message"]
                    if status == 1{
                        
                        self.requestArray.remove(at: index)
                        self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                        
                        self.tblView.reloadData()
                        self.updateErrorMessage()
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: noti_RefreshProfile), object:nil)
                    }else
                    {
                        self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            })
        
    }
}


extension SuggestionListVC: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if isSuggestedSelected == true && listArray.count > 13 {
            return 2
        }else if isContactSelected == true && contactArray.count > 13 {
            return 2
        }else if isRequestSelected == true && requestArray.count > 13 {
            return 2
        }
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            return 1
        }
        if isSuggestedSelected == true {
            return listArray.count
        }else if isContactSelected == true {
            return contactArray.count
        }else {
            return requestArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1{
            return 60
        }
        return UITableView.automaticDimension
      //  return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1{
            //Loading cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreTblCell", for: indexPath) as! LoadMoreTblCell
          //  cell.lblMessage.isHidden = true
            cell.activityIndicator.startAnimating()
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionListTblCell") as! SuggestionListTblCell
        cell.selectionStyle = .none
        
        cell.btnRemove.setImageTintColor(.black)
        if isSuggestedSelected == true {
           
            cell.profileImgView.setImgView(profilePic: listArray[indexPath.item].profilePic, frameImg: listArray[indexPath.item].avatar, changeValue: 6)
            cell.imgVwCelebrity.isHidden = true
            if listArray[indexPath.item].celebrity == 1{
                cell.imgVwCelebrity.isHidden = false
                cell.imgVwCelebrity.image = PZImages.greenVerification
            }else if listArray[indexPath.item].celebrity == 4{
                cell.imgVwCelebrity.isHidden = false
                cell.imgVwCelebrity.image = PZImages.goldVerification
            }else if listArray[indexPath.item].celebrity == 5{
                cell.imgVwCelebrity.isHidden = false
                cell.imgVwCelebrity.image = PZImages.blueVerification
            }
            
            cell.btnConnect.setTitle(" Follow", for: .normal)
            cell.btnRemove.setTitle(" Remove", for: .normal)
            cell.btnConnect.addTarget(self, action: #selector(connectBtnAction(_ : )), for: .touchUpInside)
            cell.btnRemove.addTarget(self, action: #selector(removeBtnAction(_ : )), for: .touchUpInside)
            
            /*cell.lblName.text = listArray[indexPath.item].name.capitalized
            if listArray[indexPath.item].jobProfile.count > 0{
                cell.lblUserName.text = listArray[indexPath.item].jobProfile
            }else if listArray[indexPath.item].livesIn.count > 0{
                cell.lblUserName.text = listArray[indexPath.item].livesIn
            }else if listArray[indexPath.item].pickzonId.count > 0{
                cell.lblUserName.text =  listArray[indexPath.item].pickzonId
            }*/
            
            cell.lblUserName.text =  listArray[indexPath.item].pickzonId

            if listArray[indexPath.item].jobProfile.count > 0{
                cell.lblName.text = listArray[indexPath.item].jobProfile
            }else if listArray[indexPath.item].livesIn.count > 0{
                cell.lblName.text = listArray[indexPath.item].livesIn
            }else if listArray[indexPath.item].name.count > 0{
                cell.lblName.text =  listArray[indexPath.item].name.capitalized
            }else{
                cell.lblName.text = ""
            }
            cell.bgViewName.isHidden = (cell.lblName.text?.count ?? 0 > 0) ? false : true

        }else if isContactSelected == true {
            
            cell.lblUserName.text = contactArray[indexPath.item].pickzonId
            
            cell.profileImgView.setImgView(profilePic: contactArray[indexPath.item].profilePic, frameImg: contactArray[indexPath.item].avatar, changeValue: 6)

            cell.imgVwCelebrity.isHidden = true
             if contactArray[indexPath.item].celebrity == 1{
                cell.imgVwCelebrity.isHidden = false
                cell.imgVwCelebrity.image = PZImages.greenVerification
            }else if contactArray[indexPath.item].celebrity == 4{
                cell.imgVwCelebrity.isHidden = false
                cell.imgVwCelebrity.image = PZImages.goldVerification
            }else if contactArray[indexPath.item].celebrity == 5{
                cell.imgVwCelebrity.isHidden = false
                cell.imgVwCelebrity.image = PZImages.blueVerification
            }
            cell.btnConnect.setTitle(" Follow", for: .normal)
            cell.btnRemove.setTitle(" Remove", for: .normal)
            cell.btnConnect.addTarget(self, action: #selector(connectBtnAction(_ : )), for: .touchUpInside)
            cell.btnRemove.addTarget(self, action: #selector(removeBtnAction(_ : )), for: .touchUpInside)
            
            if contactArray[indexPath.item].jobProfile.count > 0{
                cell.lblName.text = contactArray[indexPath.item].jobProfile
            }else if contactArray[indexPath.item].livesIn.count > 0{
                cell.lblName.text = contactArray[indexPath.item].livesIn
            }else if contactArray[indexPath.item].name.count > 0{
                cell.lblName.text =  contactArray[indexPath.item].name.capitalized
            }else{
                cell.lblName.text = ""
            }
            
            cell.bgViewName.isHidden = (cell.lblName.text?.count ?? 0 > 0) ? false : true

            
        }else{
            cell.lblUserName.text = requestArray[indexPath.item].pickzonId
            cell.profileImgView.setImgView(profilePic: requestArray[indexPath.item].profilePic, frameImg: requestArray[indexPath.item].avatar, changeValue: 6)

            cell.imgVwCelebrity.isHidden = true
             if requestArray[indexPath.item].celebrity == 1{
                cell.imgVwCelebrity.isHidden = false
                cell.imgVwCelebrity.image = PZImages.greenVerification
            }else if requestArray[indexPath.item].celebrity == 4{
                cell.imgVwCelebrity.isHidden = false
                cell.imgVwCelebrity.image = PZImages.goldVerification
            }else if requestArray[indexPath.item].celebrity == 5{
                cell.imgVwCelebrity.isHidden = false
                cell.imgVwCelebrity.image = PZImages.blueVerification
            }
            cell.btnConnect.setTitle(" Accept", for: .normal)
            cell.btnRemove.setTitle(" Reject", for: .normal)
            
            cell.btnConnect.addTarget(self, action: #selector(acceptFriendRequestBtn(sender:)) , for: .touchUpInside)
            cell.btnRemove.addTarget(self, action: #selector(rejectFriendRequestBtn(sender:)) , for: .touchUpInside)
            
            if requestArray[indexPath.item].jobProfile.count > 0{
                cell.lblName.text = requestArray[indexPath.item].jobProfile
            }
//            else if requestArray[indexPath.item].livesIn.count > 0{
//                cell.lblName.text = contactArray[indexPath.item].livesIn
//            }
            else if requestArray[indexPath.item].name.count > 0{
                cell.lblName.text = requestArray[indexPath.item].name.capitalized
            }else{
                cell.lblName.text = ""
            }
            cell.bgViewName.isHidden = (cell.lblName.text?.count ?? 0 > 0) ? false : true

        }
        cell.btnRemove.tag = indexPath.item
        cell.btnConnect.tag = indexPath.item
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        if isSuggestedSelected == true {
            profileVC.otherMsIsdn =  listArray[indexPath.row].id
        }else if isContactSelected == true {
            profileVC.otherMsIsdn =  contactArray[indexPath.row].id
        }else if isRequestSelected == true {
            profileVC.otherMsIsdn =  requestArray[indexPath.row].id
        }
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1{
            if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                
                self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
                
            }else  if !isDataLoading  && isSuggestedSelected{
                    isDataLoading = true
                    pageNoSuggestion = pageNoSuggestion + 1
                    self.getSuggestionListApi(type:0)
                
            }else  if !isDataLoading  && isContactSelected{
                    isDataLoading = true
                    pageNoContact = pageNoContact + 1
                    self.getSuggestionListApi(type:1)
            }else  if !isDataLoading  && isRequestSelected{
                    isDataLoading = true
                    pageNoRequest = pageNoRequest + 1
                    self.fetchFriendRequestList()
            }
        }
    }
  
    
    //MARK: Selector Methods
    
    @objc func removeBtnAction(_ sender : UIButton){
        if isRequestSelected == false{
//        AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: "Are you sure want to remove selected user from suggestion ?", buttonTitles: ["Yes","No"], onController: self) { title, btnIndex in
//            
//            if btnIndex == 0{
                if self.isContactSelected == true {
                    self.removeContactFriendsSuggestionAPI(index: sender.tag)
                }else {
                    self.removeSuggestionApi(index: sender.tag)
                }
//            }
//        }
        }
    }
    
    @objc func connectBtnAction(_ sender : UIButton){
        if isRequestSelected == false{
        self.followBtn(index: sender.tag)
        }
    }
    
    @objc  func rejectFriendRequestBtn(sender:UIButton){
        if isRequestSelected == true{
            
            AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to reject Request?", buttonTitles: ["Yes","No"], onController: self) { title, index in
                
                if index == 0 {
                    
                    self.acceptRejectFriendRequest(isToAccept: false, index: sender.tag)
                    
                }
            }
        }
    }

    @objc  func acceptFriendRequestBtn(sender:UIButton){
        
        if isRequestSelected == true{
            
            AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to accept Request?", buttonTitles: ["Yes","No"], onController: self) { title, index in
                
                if index == 0 {
                    self.acceptRejectFriendRequest(isToAccept: true, index: sender.tag)
                }
            }
        }
    }
}

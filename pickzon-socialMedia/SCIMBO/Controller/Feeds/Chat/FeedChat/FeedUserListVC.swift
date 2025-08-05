//
//  FeedUserListVC.swift
//  SCIMBO
//
//  Created by Getkart on 02/08/21.
//  Copyright © 2021 Radheshyam Yadav. All rights reserved.
//

import UIKit


protocol FeedUserListDelegate{
    
    func getSelectedUser()
}

class FeedUserListVC: UIViewController,UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblView:UITableView!
    
    var listArray:Array<FriendModal> = Array<FriendModal>()
    var searchArray:Array<FriendModal> = Array<FriendModal>()
    var isSearching = false
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.enablesReturnKeyAutomatically = true
        

        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.friendListObserver), name: NSNotification.Name(rawValue: Constant.sharedinstance.friend_list), object: nil)
        
        
        //getUserListApi()
        let param = ["authToken":Themes.sharedInstance.getAuthToken()]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.friend_list, param)
    }
    
    
    //MARK: -  UIButton Action Methods
    @IBAction func backButtonAction(sender:UIButton){
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    
    //MARK: Api Methods
    
    @objc func friendListObserver(notification: Notification) {
        
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            
            let result = response as NSDictionary
            let errNo = result["errNum"] as? String ?? ""
            let message = result["message"] as? String ?? ""
            
            let data = result.value(forKey: "friends") as? NSArray ?? []
            if data.count > 0{
                self.listArray.removeAll()
                for obj in data {
                    let objStatus = FriendModal(respDict: obj as! NSDictionary)
                    self.listArray.append(objStatus)
                }
                  
                self.tblView.separatorStyle = (self.listArray.count == 0) ? .none : .singleLine
                    self.tblView.reloadData()
                
            
            } else {
                self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
            }
        }
        
    }
    
    
    func getUserListApi(){
        
        Themes.sharedInstance.activityView(View: self.view)
        
        let params = NSMutableDictionary()
        params.setValue("\(Themes.sharedInstance.GetMyPhonenumber())", forKey: "msisdn") //selected users msisdn
        
        print("wallPostNotification")
        URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.feedFriendList, param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }
            else{
                
                let result = responseObject! as NSDictionary
                let errNo = result["errNum"] as? String ?? ""
                let message = result["message"] as? String ?? ""
                if errNo == "99"{
                    
                    let data = result.value(forKey: "friendList") as? NSArray ?? []
                    if data.count > 0{
                        self.listArray.removeAll()
                        for obj in data {
                            let objStatus = FriendModal(respDict: obj as! NSDictionary)
                            self.listArray.append(objStatus)
                        }
                          
                        self.tblView.separatorStyle = (self.listArray.count == 0) ? .none : .singleLine
                            self.tblView.reloadData()
                        
                        
                    }else{
                        
                    }
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    //MARK: UISearchBar Delegate
//    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
//
//        let previousText:NSString = searchBar.text! as NSString
//        let updatedText = previousText.replacingCharacters(in: range, with: text)
//        print("======\(updatedText)")
//        if updatedText.count > 0 {
//            isSearching = true
//
//            searchArray = listArray.filter({ $0.name.contains(updatedText)})
//
//        }else{
//            searchArray.removeAll()
//            isSearching = false
//        }
//        tblView.reloadData()
//
//        return true
//    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            print("searchText \(searchText)")
        //self.view.endEditing(true)
        if searchText.count > 0 {
            isSearching = true

            searchArray = listArray.filter({ $0.name.lowercased().contains(searchText.lowercased())})
            if searchArray.count == 0{
                self.view.makeToast(message: "No user found" , duration: 0.5, position: HRToastPositionCenter)
            }
            self.tblView.separatorStyle = (self.searchArray.count == 0) ? .none : .singleLine

        }else{
            searchArray.removeAll()
            isSearching = false
            self.tblView.separatorStyle = (self.listArray.count == 0) ? .none : .singleLine

        }
        tblView.reloadData()
        

       
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
          //  print("searchText \(searchBar.text)")
        self.view.endEditing(true)
        }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchArray.removeAll()
        isSearching = false
        self.view.endEditing(true)
        tblView.reloadData()


    }

    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
       // print("searchText \(searchBar.text)")
    }
    
}



extension FeedUserListVC:UITableViewDelegate,UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  (isSearching == true) ? searchArray.count : listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedNotificationTblCellId") as? FeedNotificationTblCell

        let obj = ((isSearching == true) ? searchArray : listArray)[indexPath.row]
        cell?.lblName.text = obj.name.capitalized
        cell?.lblLastMsg.text = obj.msisdn
        cell?.btnProfie.kf.setBackgroundImage(with:  URL(string: obj.profilePic) , for: .normal, placeholder:UIImage(named: "avatar"),options: nil)
        cell?.btnProfie.tag = indexPath.row
        cell?.imgVwCelebrity.isHidden = (obj.celebrity == 1) ? false : true
        cell?.lblLastMsg.text = "@\(obj.pickzonId)"

        cell?.btnProfie.addTarget(self, action: #selector(openProfileSharedUser(sender:)), for: .touchUpInside)
        
        return cell!
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let obj = ((isSearching == true) ? searchArray : listArray)[indexPath.row]

        let settingsVC:FeedChatVC = StoryBoard.chat.instantiateViewController(withIdentifier: "FeedChatVC") as! FeedChatVC
        settingsVC.toChat = obj.id
        settingsVC.fromName = obj.name
        settingsVC.fullUrl = obj.profilePic
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    //MARK:  SElector methods
    @objc func openProfileSharedUser(sender:UIButton){
        let obj = ((isSearching == true) ? searchArray : listArray)[sender.tag]

        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.otherMsIsdn =  obj.id as? String ?? ""
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
}



struct FriendModal{
    
    var name = ""
    var profilePic = ""
    var msisdn = ""
    var id = ""
    var celebrity = 0
    var isSelected = false
    var actualProfileImage = ""
    var pickzonId = ""
    var mobile = ""
    
    init(respDict:NSDictionary) {
        
        self.name = respDict["Name"] as? String ?? ""
        
        if let name = respDict["first_name"] as? String{
            
            self.name = name
        }
        self.msisdn = respDict["msisdn"] as? String ?? ""
        self.id = respDict["_id"] as? String ?? ""
        self.pickzonId = respDict["Tiktokname"] as? String ?? ""
        self.profilePic = respDict["ProfilePic"] as? String ?? ""
        self.celebrity = respDict["celebrity"] as? Int ?? 0
        self.actualProfileImage = respDict["actualProfileImage"] as? String ?? ""

        if let name = respDict["name"] as? String{
            
            self.name = name
        }
        
        if let msisdn = respDict["msisdn"] as? String{
            
            self.mobile = msisdn
        }
        if let pickzonId = respDict["pickzonId"] as? String{
            
            self.pickzonId = pickzonId
        }
        
        if let userId =  respDict["id"] as? String{
                self.id = userId
        }
        
        if let profile_pic = respDict["profile_pic"] as? String{
            
            self.profilePic = profile_pic
        }

        if let profilePic = respDict["profilePic"] as? String{
            
            self.profilePic = profilePic
        }
        
        if profilePic.prefix(1) == "." {
            self.profilePic = String(profilePic.dropFirst(1))
            self.profilePic = Themes.sharedInstance.getURL() + self.profilePic
        }
    }
    
}


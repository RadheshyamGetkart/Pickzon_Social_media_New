//
//  ChatUserListVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 2/16/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit


protocol SelectedNewUserDelegate: AnyObject{
    
    func selectedUsers(userArray:Array<Followers>,messageIdArray:NSMutableArray)
    
}


class ChatUserListVC: UIViewController,UISearchBarDelegate {
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var constrntHeightNavBar:NSLayoutConstraint!
    @IBOutlet weak var btnDone:UIButton!
    var messageDatasourceArr:NSMutableArray?
    var toChatUserId = ""
    var emptyView:EmptyList?
    var isSearching = false
    var searchUserList:Array<Followers> = Array<Followers>()
    var arrSelectedUser:Array<Followers> = Array<Followers>()
    var arrUserList:Array<Followers> = Array<Followers>()
    var isMultipleSelection = false
    var pageNo = 1
    var pageLimit = 20
    var isDataLoading = true
    let followUserId = Themes.sharedInstance.Getuser_id()
    var delegate:SelectedNewUserDelegate?
    var isDataMoreAvailable = true
    
    //MARK: Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.constrntHeightNavBar.constant = self.getNavBarHt
        emptyView = EmptyList(frame: CGRect(x: 0, y: -64, width: tblView.frame.size.width, height: tblView.frame.size.height))
        emptyView?.imageView?.image = PZImages.noChat
        emptyView?.lblMsg?.text = "Not following anyone"
        self.tblView.addSubview(emptyView!)
        emptyView?.isHidden = true
        tblView.register(UINib(nibName: "TagPeopleTableViewCell", bundle: nil), forCellReuseIdentifier: "TagPeopleTableViewCell")
        self.tblView.register(UINib(nibName: "LoadMoreTblCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTblCell")
        
        tblView.separatorColor = UIColor.clear
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        self.btnDone.isHidden = (isMultipleSelection==true) ? false : true
        getNewFollowingList()
        
    }
    
    //MARK: UIBUtton Action Methods
    @IBAction func backBtnAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneBtnAction() {
        if messageDatasourceArr?.count ?? 0 > 0{
            delegate?.selectedUsers(userArray: arrSelectedUser, messageIdArray: messageDatasourceArr!)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - UISearchbar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count ?? 0 == 0{
            self.view.endEditing(true)
            isSearching = false
            searchUserList.removeAll()
            self.tblView.reloadData()
            self.emptyView?.isHidden = true
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        isSearching = false
        searchUserList.removeAll()
        self.tblView.reloadData()
        self.emptyView?.isHidden = true
    }
    
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar) {
        self.view.endEditing(true)
        isSearching = true
        pageNo = 1
        getNewFollowingList()
    }
    
    
    
    //MARK: Api Methods
    
    func getNewFollowingList(){
        
        if pageNo == 1{
            self.searchUserList.removeAll()
            Themes.sharedInstance.activityView(View: self.view)
        }
        
        let param:NSDictionary = [:]
        
        let url = "\(Constant.sharedinstance.get_forward_chat_friend_list)?pageNumber=\(pageNo)&searchName=\(searchBar.text ?? "")"
        
        
//        let url = "\(Constant.sharedinstance.getFollowingsDetails)?userId=\(followUserId)&pageNumber=\(pageNo)&pageLimit=\(pageLimit)&searchName=\(searchBar.text ?? "")"
//
        URLhandler.sharedinstance.makeGetCall(url: url, param: param) { responseObject, error in
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                self.isDataLoading = false

            }else{
                let result = responseObject ?? [:]
                let status = result["status"] as? Int ?? 0
                //let message = result["message"] as? String ?? ""
             
                if status == 1{
                    
                    if let reqArr = result["payload"] as? Array<[String:Any]> {
                        for dict in reqArr {
                            if self.isSearching == true {
                                self.searchUserList.append(Followers(respDict: (dict as NSDictionary)))
                            }else{
                                self.arrUserList.append(Followers(respDict: (dict as NSDictionary)))
                            }
                        }
                        
                         
                        let searchArr = (self.isSearching == true) ? self.searchUserList : self.arrUserList
                        self.isDataMoreAvailable = (reqArr.count > 0 && searchArr.count > 13) ? true : false
                    }
                    self.tblView.reloadData {
                        self.pageNo = self.pageNo + 1
                        self.isDataLoading = false

                    }
                    
                }else{
                    // self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    self.isDataLoading = false

                }
                if  self.isSearching == true {
                    self.emptyView?.isHidden =   ( self.searchUserList.count == 0) ? false : true
                }else{
                    self.emptyView?.isHidden = (self.arrUserList.count == 0) ? false : true
                }
                
            }
        }
    }
}


extension ChatUserListVC:UITableViewDelegate,UITableViewDataSource {
    
    //MARK: - TableviewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isDataMoreAvailable {
            return 2
        }
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            return 1
        }
        return  (self.isSearching == true) ? searchUserList.count : arrUserList.count
    }
    
    func checkSelection(userObj:Followers)->Bool{
        
        for obj in arrSelectedUser{
            if userObj.id == obj.id{
                return true
            }
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            //Loading cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreTblCell", for: indexPath) as! LoadMoreTblCell
            //  cell.lblMessage.isHidden = true
            cell.activityIndicator.startAnimating()
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagPeopleTableViewCell", for: indexPath) as! TagPeopleTableViewCell
        cell.selectionStyle = .none
        let obj = (isSearching == true) ? searchUserList[indexPath.row] : arrUserList[indexPath.row]
        
        cell.imgCelebrity.isHidden = true
        if obj.celebrity == 1 {
            cell.imgCelebrity.isHidden = false
            cell.imgCelebrity.image = PZImages.greenVerification
        }else if obj.celebrity == 4 {
            cell.imgCelebrity.isHidden = false
            cell.imgCelebrity.image = PZImages.goldVerification
        }else if obj.celebrity == 5{
            cell.imgCelebrity.isHidden = false
            cell.imgCelebrity.image = PZImages.blueVerification
        }
        cell.lblUserName.text =  obj.pickzonId
        cell.lblName.text = obj.name.capitalized
        cell.lblName.isHidden = (obj.name.count > 0) ? false : true
        
        cell.profilePicView.setImgView(profilePic: obj.profilePic, frameImg: obj.avatar,changeValue: 5)
        
        cell.btnSelectUser.setImage(((obj.isSelected == 0) ? PZImages.uncheck :PZImages.check), for: .normal)
        cell.btnSelectUser.tag = indexPath.row
        cell.btnSelectUser.addTarget(self, action: #selector(selectUserAction(sender:)), for: .touchUpInside)
        cell.btnSelectUser.isHidden = (isMultipleSelection==true) ? false : true
        
        if checkSelection(userObj: obj){
            cell.btnSelectUser.setImage(PZImages.check, for: .normal)
        }else{
            cell.btnSelectUser.setImage(PZImages.uncheck, for: .normal)
        }
        
        if toChatUserId == obj.id{
            cell.btnSelectUser.isHidden = true
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let obj = (isSearching == true) ? searchUserList[indexPath.row] : arrUserList[indexPath.row]
        if isMultipleSelection{
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn =  obj.id
            self.navigationController?.pushViewController(profileVC, animated: true)
        }else{
            /* if obj.isFollowBack == 0{
             AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Both of you needs to follow each other to send message.")
             }else{*/
            let profileVC:FeedChatVC = StoryBoard.chat.instantiateViewController(withIdentifier: "FeedChatVC") as! FeedChatVC
            profileVC.toChat =  obj.id
            profileVC.fromName = obj.name
            profileVC.fullUrl = obj.profilePic
            profileVC.pickzonId = obj.pickzonId
            self.navigationController?.pushViewController(profileVC, animated: true)
            //  }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1  {
            if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                
                self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
                
            }else  if isDataLoading == false   {
                
                isDataLoading = true
                self.getNewFollowingList()
            }
        }
        
    }
    
    
    //MARK: Selector Methods
    
    @objc func openProfileUser(sender:UIButton){
        
        let obj = (isSearching == true) ? searchUserList[sender.tag] : arrUserList[sender.tag]
        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.otherMsIsdn =  obj.id
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    @objc func selectUserAction(sender:UIButton){
        
        if isSearching == true {
            
            var mainObj = searchUserList[sender.tag]
            
            //may be dict added from arrselected user or from searched users i.e. removed from the list
            for var i in 0..<arrSelectedUser.count{
                if arrSelectedUser.count > i {
                    
                    let obj = arrSelectedUser[i]
                    
                    if obj.id == mainObj.id {
                        arrSelectedUser.remove(at: i)
                        i = i-1
                    }
                }
            }
            
            if mainObj.isSelected == 0 {
                if arrSelectedUser.count >= 5{
                    self.view.makeToast(message: "You can share to 5 users at a time." , duration: 2, position: HRToastActivityPositionDefault)
                    return
                }
                mainObj.isSelected = 1
                searchUserList[sender.tag] = mainObj
                arrSelectedUser.append(mainObj)
            }else {
                mainObj.isSelected = 0
                searchUserList [sender.tag] = mainObj
            }
        } else {
            var mainObj = arrUserList[sender.tag]
            
            //may be dict added from arrselected user or from searched users i.e. removed from the list
            for var i in 0..<arrSelectedUser.count{
                if arrSelectedUser.count > i {
                    let obj = arrSelectedUser[i]
                    
                    if obj.id  == mainObj.id {
                        arrSelectedUser.remove(at: i)
                        i = i-1
                    }
                }
            }
            
            if mainObj.isSelected == 0 {
                if arrSelectedUser.count >= 5{
                    self.view.makeToast(message: "You can share only 5 users at a time." , duration: 2, position: HRToastActivityPositionDefault)
                    return
                }
                mainObj.isSelected = 1
                arrUserList[sender.tag] = mainObj
                arrSelectedUser.append(mainObj)
            }else {
                mainObj.isSelected = 0
                arrUserList[sender.tag] = mainObj
            }
        }
        
        if arrSelectedUser.count == 0{
            self.btnDone.tintColor = .lightGray
        }else{
            self.btnDone.tintColor = .blue
        }
        tblView.reloadData()
    }
    
}

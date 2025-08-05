//
//  FollowingListViewController.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 5/24/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit



enum FriendType {
    
    case followersList
    case followingList
    case comonFriends
}

class FollowingListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblUserList:UITableView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var bgVwSearch:UIView!
    @IBOutlet weak var txtFdSearch:UITextField!
    @IBOutlet weak var cnstntTopNavBarr:NSLayoutConstraint!

    var arrUserList:Array<Followers> = Array<Followers>()
    var searchUserList:Array<Followers> = Array<Followers>()
    var followUserId = ""
    var pageNo = 1
    var isSearching = false
    var userType:FriendType? = .followersList
    var emptyView:EmptyList?
    var pageLimit = 20
    var isDataLoading = true
    var isDataMoreAvailable = true
    
    //MARK: - Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cnstntTopNavBarr.constant = self.getNavBarHt
        bgVwSearch.isHidden = true
        txtFdSearch.attributedPlaceholder = NSAttributedString(string:"Search by name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        emptyView = EmptyList(frame: CGRect(x: 0, y: -64, width: tblUserList.frame.size.width, height: tblUserList.frame.size.height))
        emptyView?.imageView?.image = PZImages.noData
        self.tblUserList.addSubview(emptyView!)
        emptyView?.isHidden = true
        tblUserList.keyboardDismissMode = .onDrag
        
        if userType == .followersList{
            lblTitle.text = "Followers"
            emptyView?.lblMsg?.text = "No Followers"
            self.getNewFollowersList()
            
        }else  if userType == .followingList{
            lblTitle.text = "Followings"
            emptyView?.lblMsg?.text = "No Followings"
            getNewFollowingList()
            
        }else  if userType == .comonFriends{
            lblTitle.text = "Common Friend"
            emptyView?.lblMsg?.text = "No Common Friends"
            fetchMutualFriends()
        }
        
        tblUserList.register(FollowingTableViewCell.self, forCellReuseIdentifier: "FollowingTableViewCell")
        tblUserList.register(UINib(nibName: "FollowingTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowingTableViewCell")
        tblUserList.register(UINib(nibName: "LoadMoreTblCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTblCell")
     
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.feedFollwedNotification(notification:)), name: notif_FeedFollowed, object: nil)
    }
    
    
    deinit{
        print("Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: Observer methos
    @objc func feedFollwedNotification(notification: Notification) {
        
        if let objDict = notification.object as? Dictionary<String, Any> {
            let userId = objDict["userId"] as? String ?? ""
            let isFollowed = objDict["isFollowed"] as? Int ?? 0
            
            
            if self.isSearching == true {
                
                for index in 0..<searchUserList.count {
                    
                    if searchUserList[index].id == userId {
                        
                        searchUserList[index].isFollow = isFollowed
                    }
                }
                
            }else{
                for index in 0..<searchUserList.count {
                    
                    if searchUserList[index].id == userId {
                        
                        searchUserList[index].isFollow = isFollowed
                    }
                }
            }
            self.tblUserList.reloadData()
        }
    }

    
    
    //MARK: - UIButton Action
    @IBAction func searchBtnAction(_sender: Any){
        self.view.endEditing(true)
        bgVwSearch.isHidden = false
        txtFdSearch.becomeFirstResponder()
    }
    
    @IBAction func searchBackBtnAction(_sender: Any){
        self.view.endEditing(true)
        bgVwSearch.isHidden = true
        isSearching = false
        searchUserList.removeAll()
        arrUserList.removeAll()
        txtFdSearch.text = ""
        self.tblUserList.reloadData()
        self.emptyView?.isHidden = true
        
        //Blank the search result
        pageNo = 1
        if userType == .followersList{
            self.getNewFollowersList()
            
        }else  if userType == .followingList{
            getNewFollowingList()
            
        }else  if userType == .comonFriends{
            fetchMutualFriends()
        }
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Api Methods
    
    func getNewFollowersList(){
        
        
        if pageNo == 1{
            self.arrUserList.removeAll()
            Themes.sharedInstance.activityView(View: self.view)
        }
        
        guard  let url = "\(Constant.sharedinstance.getFollowersDetails)?userId=\(followUserId)&pageNumber=\(pageNo)&pageLimit=\(pageLimit)&searchName=\(txtFdSearch.text ?? "")".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return
        }
        self.isDataLoading = true
        URLhandler.sharedinstance.makeGetCall(url: url, param: [:]) { responseObject, error in
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                self.isDataLoading = false
                
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1 {
                    
                    if let reqArr = result["payload"] as? Array<[String:Any]> {
                        
                        for dict in reqArr {
                            self.arrUserList.append(Followers(respDict: (dict as NSDictionary)))
                        }
                        self.isDataMoreAvailable = (reqArr.count == 0) ? false : true
                    }
                    
                    self.tblUserList.reloadData {
                        self.isDataLoading = false }
                    
                } else {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    self.isDataLoading = false
                    self.isDataMoreAvailable = false
                }
                self.emptyView?.isHidden = (self.arrUserList.count == 0) ? false : true
            }
        }
    }
    
    
    func getNewFollowingList(){
        
        if pageNo == 1{
            self.arrUserList.removeAll()
            Themes.sharedInstance.activityView(View: self.view)
        }
        
        guard let url = "\(Constant.sharedinstance.getFollowingsDetails)?userId=\(followUserId)&pageNumber=\(pageNo)&pageLimit=\(pageLimit)&searchName=\(txtFdSearch.text ?? "")".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return
        }
        
        self.isDataLoading = true

        
        URLhandler.sharedinstance.makeGetCall(url: url, param: [:]) { responseObject, error in
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
              //  self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                self.isDataLoading = false

            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    
                    if let reqArr = result["payload"] as? Array<[String:Any]> {
                        for dict in reqArr {
                            self.arrUserList.append(Followers(respDict: (dict as NSDictionary)))
                        }
                        
                        self.isDataMoreAvailable = (reqArr.count == 0) ? false : true

                    }
                    
                    self.tblUserList.reloadData {
                        self.isDataLoading = false
                    }

                    
                } else {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    self.isDataLoading = false
                    self.isDataMoreAvailable = false
                }

                self.emptyView?.isHidden = (self.arrUserList.count == 0) ? false : true
            }
        }
    }
    
    
    func fetchMutualFriends(){
        
        if pageNo == 1{
            self.arrUserList.removeAll()
            Themes.sharedInstance.activityView(View: self.view)
        }

        guard let url = "\(Constant.sharedinstance.getMutualFriend)?userId=\(followUserId)&pageNumber=\(pageNo)&pageLimit=\(pageLimit)&searchName=\(txtFdSearch.text ?? "")".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return
        }
            
        self.isDataLoading = true

        URLhandler.sharedinstance.makeGetCall(url: url, param: [:] ) { responseObject, error in
    
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
               //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                self.isDataLoading = false

            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1 {
                    
                    if let reqArr = result["payload"] as? Array<[String:Any]> {
                        
                        for dict in reqArr {
                            self.arrUserList.append(Followers(respDict: (dict as NSDictionary)))
                        }
                        self.isDataMoreAvailable = (reqArr.count == 0) ? false : true

                    }
                    self.tblUserList.reloadData {
                        self.isDataLoading = false
                    }
                    
                } else {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    self.isDataLoading = false
                    self.isDataMoreAvailable = false
                }

                self.emptyView?.isHidden = (self.arrUserList.count == 0) ? false : true

            }
        }
    }
    
    
    func followUnfollowApi(index:Int){
        Themes.sharedInstance.activityView(View: self.view)
        
        var obj = (isSearching == true) ? searchUserList[index] : arrUserList[index]
        
        if arrUserList.count > 0 {
            
            let param:NSDictionary = ["followedUserId":obj.id ,"status": (obj.isFollow == 1) ? 0 : 1 ]

            URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.follow as String, param: param, completionHandler: {(responseObject, error) ->  () in
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                if(error != nil)
                {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                }
                else{
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int ?? 0
                    let message = result["message"] as? String ?? ""
                    let payloadDict = result["payload"] as? NSDictionary ?? [:]
                    
                    if status == 1{

                        obj.isFollow =  payloadDict["isFollow"] as? Int ?? 0
                        
                        if self.isSearching{
                            self.searchUserList[index]  = obj
                        }else{
                            self.arrUserList[index]  = obj
                        }
                                                
                        if let cell = self.tblUserList.cellForRow(at: IndexPath(row: index, section: 0))as? FollowingTableViewCell  {
                            cell.btnUnfollow.setTitle(getFollowUnfollowRequestedText(isFollowValue: obj.isFollow), for: .normal)
                        }
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: noti_RefreshProfile), object:nil)
                    }else
                    {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            })
        }
    }
    
    
    func cancelFriendRequestApi(otherMsIsdn:String,index:Int){
        Themes.sharedInstance.activityView(View: self.view)
            
        let obj = (isSearching == true) ? searchUserList[index] : arrUserList[index]

        let param:NSDictionary = ["followedUserId":otherMsIsdn]
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.cancelRequest as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                let payloadDict = result["payload"] as? NSDictionary ?? [:]
                let isFollow = payloadDict["isFollow"] as? Int ?? 0
                
                if status == 1 {
                    if self.isSearching{
                        self.searchUserList[index].isFollow  = isFollow
                    }else{
                        self.arrUserList[index].isFollow  = isFollow
                    }
                    DispatchQueue.main.async {
                        
                        if let cell = self.tblUserList.cellForRow(at: IndexPath(row: index, section: 0))as? FollowingTableViewCell  {
                            cell.btnUnfollow.setTitle(getFollowUnfollowRequestedText(isFollowValue: isFollow), for: .normal)
                        }
                    }
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    

   //MARK: - TableView Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
       
        let checkArray = (isSearching == true) ? searchUserList : arrUserList
        if checkArray.count > 15 &&  isDataMoreAvailable == true {
           return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1{
            return 1
        }
        if self.isSearching == true {
            return searchUserList.count
        }
        return arrUserList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            //Loading cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreTblCell", for: indexPath) as! LoadMoreTblCell
            //  cell.lblMessage.isHidden = true
            cell.activityIndicator.startAnimating()
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowingTableViewCell") as! FollowingTableViewCell
        let obj = (isSearching == true) ? searchUserList[indexPath.row] : arrUserList[indexPath.row]
        
        cell.profilePicView.setImgView(profilePic: obj.profilePic, frameImg: obj.avatar,changeValue: 7)
    
        cell.lblName.text =   obj.pickzonId
        cell.lblPhone.text =  obj.name
        cell.lblPhone.isHidden = (obj.name.count > 0) ? false : true

        cell.lblName.tag = indexPath.row
        cell.btnUnfollow.isHidden = false
        cell.btnUnfollow.setTitle(getFollowUnfollowRequestedText(isFollowValue: obj.isFollow), for: .normal)
        cell.btnUnfollow.tag = indexPath.row
        cell.btnUnfollow.addTarget(self, action: #selector(followBtn(sender:)) , for: .touchUpInside)
        
        cell.profilePicView.imgVwProfile?.tag = indexPath.row
        cell.profilePicView.imgVwProfile?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                      action:#selector(self.handleProfilePicTap(_:))))
        cell.imgVwCelebrity.isHidden = true
         if obj.celebrity == 1{
            cell.imgVwCelebrity.isHidden = false
            cell.imgVwCelebrity.image = PZImages.greenVerification
        }else if obj.celebrity == 4{
            cell.imgVwCelebrity.isHidden = false
            cell.imgVwCelebrity.image = PZImages.goldVerification
        }else if obj.celebrity == 5{
            cell.imgVwCelebrity.isHidden = false
            cell.imgVwCelebrity.image = PZImages.blueVerification
        }
        
        if obj.id  == Themes.sharedInstance.Getuser_id() || userType == .comonFriends{
            cell.btnUnfollow.isHidden = true
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            let obj = (isSearching == true) ? searchUserList[indexPath.row] : arrUserList[indexPath.row]
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn =  obj.id
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let checkArray = (isSearching == true) ? searchUserList : arrUserList
        //Call API befor the end of all records
        if  (indexPath.row == (checkArray.count - 1)) && isDataMoreAvailable == true {
            
            if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                
                self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
                
            }else if isDataLoading  == false{
                self.isDataLoading = true
                pageNo = pageNo + 1
                if userType == .followersList {
                    self.getNewFollowersList()
                }else  if userType == .followingList {
                    self.getNewFollowingList()
                }else  if userType == .comonFriends{
                    self.fetchMutualFriends()
                }
            }
        }
    }
    
    
    //MARK: Selector methods
    
    @objc  func handleProfilePicTap(_ sender: UITapGestureRecognizer? = nil){

        let obj = (isSearching == true) ? searchUserList[sender?.view?.tag ?? 0] : arrUserList[sender?.view?.tag ?? 0]
        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.otherMsIsdn =  obj.id
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc func followBtn(sender:UIButton){
        
        let obj = (isSearching == true) ? searchUserList[sender.tag] : arrUserList[sender.tag]
        
        if (obj.isFollow == 2) {
            
            AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: "Are you sure want to cancel request?", buttonTitles: ["Yes","No"], onController: self) { title, index in
                if index == 0{
                    self.cancelFriendRequestApi(otherMsIsdn: obj.id ,index:sender.tag)
                }
            }
            
        }else{
            
            self.followUnfollowApi(index: sender.tag)
        }
        
    }
}

//MARK: - UITextfield Delegate methods
extension FollowingListViewController:UITextFieldDelegate{
    
 
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
       /* let previousText:NSString = textField.text! as NSString
        let updatedText = previousText.replacingCharacters(in: range, with: string)

        if updatedText.count > 0 {
            
        isSearching = true

            searchUserList = arrUserList.filter({ $0.name.lowercased().contains(updatedText.lowercased())})
            self.emptyView?.isHidden = true

            if searchUserList.count == 0{
                self.emptyView?.isHidden = false
        }
        self.tblUserList.separatorStyle = (self.searchUserList.count == 0) ? .none : .singleLine

    }else{
        searchUserList.removeAll()
        isSearching = false
        self.tblUserList.separatorStyle = (self.arrUserList.count == 0) ? .none : .singleLine

    }
    tblUserList.reloadData()
    */
        
        return true
   
}
    
   
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        isSearching = false
        searchUserList.removeAll()
        self.tblUserList.reloadData()
        self.emptyView?.isHidden = true

        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        pageNo = 1

        if userType == .followersList{
            self.getNewFollowersList()
            
        }else  if userType == .followingList{
            getNewFollowingList()
            
        }else  if userType == .comonFriends{
            fetchMutualFriends()
        }
        return true
    }
}














//
//  FeedsNotificationVC.swift
//  SCIMBO
//
//  Created by Getkart on 17/07/21.
//  Copyright © 2021 GETKART. All rights reserved.
//

import UIKit
import Kingfisher


class FeedsNotificationVC: UIViewController {

    var isMultipleToselect:Bool = false
    var selectedArray:Array<Bool> = Array()
    var wallStatusArray = [WallStatus]()
    var availableStatus = 0
    var pageNo = 1
    var totalPageNo = 0
    var pageLimit = 18
    var isDataLoading = false
    var listArray:Array = Array<PostNotificationModal>()
    var emptyView:EmptyList?
    var states : Array<Bool> = Array()
    var arrClearNotificartionIDs:Array = Array<String>()
    var showSelect = false
    @IBOutlet weak var tblView:UITableView!
    {
        didSet {
            tblView.estimatedRowHeight = 70
            tblView.rowHeight = UITableView.automaticDimension
        }
    }
    @IBOutlet weak var btnClearAll:UIButton!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var btnSelectAll:UIButton!

    
    private lazy var topRefreshControl:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handlePullDownRefresh(_ : )), for: .valueChanged)
        refreshControl.tintColor = UIColor.systemBlue
        return refreshControl
    }()
    

    //MARK: Controller Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnSelectAll.isHidden = true
        cnstrntHtNavBar.constant = self.getNavBarHt
        emptyView = EmptyList(frame: CGRect(x: 0, y: -64, width: tblView.frame.size.width, height: tblView.frame.size.height))
        emptyView?.imageView?.image = PZImages.noChat
        emptyView?.lblMsg?.text = "No Notifications"
        self.tblView.addSubview(emptyView!)
        emptyView?.isHidden = true
        getAllNotificationListApi()
        self.tblView.refreshControl = self.topRefreshControl
//        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshCount),
//                                               name: NSNotification.Name(rawValue: noti_RefreshChatCount),
//                                               object: nil)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
        self.pageNo = 1
        self.totalPageNo = 0
        self.isDataLoading = false
        self.listArray.removeAll()
        self.tblView.reloadData()
        self.getAllNotificationListApi()
        refreshControl.endRefreshing()
    }

    func checkSocketStatus(){
        if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected)
        {
            SocketIOManager.sharedInstance.establishConnection(Nickname: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()) as NSString, isLogin: true)
        }else{
            SocketIOManager.sharedInstance.emitChatAndNotificationCount(userId: Themes.sharedInstance.Getuser_id())
        }
    }
    
    
    @objc func refreshCount(notification: Notification) {
        
       
        if let indexData = notification.userInfo?["count"] as? Int {
           // DispatchQueue.main.async {
               // self.btnNotification.badgeString =   (indexData == 0) ? "" :"\(indexData)"
                Constant.sharedinstance.notificationCount = (indexData == 0) ? 0 : indexData
           // }
        }
        
        if let feedChatCount = notification.userInfo?["feedChatCount"] as? Int {
           // DispatchQueue.main.async {
              //  self.btnChat.badgeString =  (feedChatCount == 0) ? "" :"\(feedChatCount)"
                Constant.sharedinstance.feedChatCount = feedChatCount
            //}
        }
        
        if let requestedChatCount = notification.userInfo?["requestedChatCount"] as? Int {
          //  DispatchQueue.main.async {
               // self.btnChat.badgeString =  "\( Constant.sharedinstance.feedChatCount + mallChatCount)"
                if (Constant.sharedinstance.feedChatCount + requestedChatCount) == 0 {
                   // self.btnChat.badgeString =  ""
                }
                Constant.sharedinstance.requestedChatCount = requestedChatCount
          //  }
        }
        
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: notif_Badgecount),
//                                        object:nil, userInfo: nil)
    }
    //MARK: UIButton Action Methods
    
   

    @IBAction func backButtonAction(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Api Methods
    func getAllNotificationListApi(){
      
        let params = NSMutableDictionary()
        params.setValue(pageLimit, forKey: "pageLimit")
        params.setValue(pageNo, forKey: "pageNumber")
        params.setValue("", forKey: "search")
        params.setValue("", forKey: "sort")

        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.wallPostNotification, param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
               
                self.totalPageNo = result["totalPages"] as? Int ?? 0
                self.isDataLoading = false
                
                if status == 1{
                    self.pageNo = self.pageNo + 1
                    if self.pageNo == 1{
                        self.listArray.removeAll()
                    
                    }

                    if let data = result.value(forKey: "payload") as? NSArray{
                       
                        for obj in data {
                            let objStatus = PostNotificationModal(respDict: obj as! NSDictionary)
                            self.listArray.append(objStatus)
                        }
                        
                        self.states = [Bool](repeating: true, count: self.listArray.count)
                        self.selectedArray = [Bool](repeating: true, count: data.count)

                    }
                    DispatchQueue.main.async {
                        
                        self.emptyView?.isHidden = (self.listArray.count == 0) ? false :  true
                        self.tblView.separatorStyle = (self.listArray.count == 0) ? .none : .singleLine
                        self.btnClearAll.isHidden = (self.listArray.count == 0) ? true :  false
                        self.tblView.reloadData()
                    }
                    self.checkSocketStatus()

                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    @objc func selectNotificationAction(sender:UIButton){

        var obj = listArray[sender.tag]
        if obj.isSelect == true {
            obj.isSelect = false
            arrClearNotificartionIDs = arrClearNotificartionIDs.filter { $0 != obj.id }
        }else {
            obj.isSelect = true
            arrClearNotificartionIDs.append(obj.id)
        }
        listArray[sender.tag] = obj
        DispatchQueue.main.async {
            self.tblView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
        }
        
        if arrClearNotificartionIDs.count == 0 {
            btnClearAll.setTitle("Done", for: .normal)
            btnClearAll.setImage(UIImage(), for: .normal)
        }else {
            btnClearAll.setTitle("Delete", for: .normal)
            btnClearAll.setImage(UIImage(named: "delete"), for: .normal)
        }
    }

    @IBAction func selectAllButtonAction(sender:UIButton){
        
        isMultipleToselect.toggle()
       
        if isMultipleToselect == true {
            self.btnSelectAll.setImage(PZImages.check, for: .normal)
            for (index,obj) in self.listArray.enumerated(){
                self.listArray[index].isSelect = true
                arrClearNotificartionIDs.append(obj.id)
            }
            self.tblView.reloadData()
        }else{
            arrClearNotificartionIDs.removeAll()
            self.btnSelectAll.setImage(PZImages.uncheck, for: .normal)
            for (index,_) in self.listArray.enumerated(){
                self.listArray[index].isSelect = false
            }
            self.tblView.reloadData()
        }
        
        if arrClearNotificartionIDs.count == 0 {
            btnClearAll.setTitle("Done", for: .normal)
            btnClearAll.setImage(UIImage(), for: .normal)
        }else {
            btnClearAll.setTitle("Delete", for: .normal)
            btnClearAll.setImage(UIImage(named: "delete"), for: .normal)
        }
    }

    
    @IBAction func showSelectionNotification( ) {

        if btnClearAll.titleLabel?.text == "Select" {
            self.showSelect = true
            tblView.reloadData()
            
            if arrClearNotificartionIDs.count == 0 {
                btnClearAll.setTitle("Done", for: .normal)
                btnClearAll.setImage(UIImage(), for: .normal)
            }else {
                btnClearAll.setTitle("Delete", for: .normal)
                btnClearAll.setImage(UIImage(named: "delete"), for: .normal)
            }
            
            self.btnSelectAll.isHidden = false

        }else{
            self.btnSelectAll.isHidden = true
            self.showSelect = false
            tblView.reloadData()
            btnClearAll.setTitle("Select", for: .normal)
            btnClearAll.setImage(UIImage(), for: .normal)
            self.clearMultipleNotificationApi()
        }
    }
    
    
    func clearMultipleNotificationApi(){
        if arrClearNotificartionIDs.count == 0 {
            return
        }
        print("After Return")
        let params = NSMutableDictionary()
        params.setValue(arrClearNotificartionIDs, forKey: "notificationId")
        

        Themes.sharedInstance.activityView(View: self.view)
        URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.clearMultipleNotificationURL, param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            self.arrClearNotificartionIDs.removeAll()
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
               
                self.isDataLoading = false
                
                if status == 1{
                    //remove selected objects
                    
                    self.listArray = self.listArray.filter { $0.isSelect == false }
                    self.states = [Bool](repeating: true, count: self.listArray.count)
                    self.arrClearNotificartionIDs.removeAll()
                    
                    self.btnSelectAll.setImage(PZImages.uncheck, for: .normal)
                    self.btnSelectAll.isHidden = true
                    
                    self.btnClearAll.setTitle("Select", for: .normal)
                    self.btnClearAll.setImage(UIImage(), for: .normal)
                    
                    DispatchQueue.main.async {
                        self.emptyView?.isHidden = (self.listArray.count == 0) ? false :  true
                        self.tblView.separatorStyle = (self.listArray.count == 0) ? .none : .singleLine
                        self.btnClearAll.isHidden = (self.listArray.count == 0) ? true :  false
                        self.tblView.reloadData()
                    }
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
   
    func getAllStatusListApi(statusId:String,isToPush:Bool){
        
        let params = NSMutableDictionary()
        params.setValue(UserDefaults.standard.string(forKey: "fcm_token") ?? "", forKey: "gcm_id")
        params.setValue(Themes.sharedInstance.getAppVersion(), forKey: "appVersion")
        params.setValue("ios", forKey: "OS")
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.getAllFeedsStatus, param: params, completionHandler: {(responseObject, error) ->  () in
            DispatchQueue.main.async {
                
                Themes.sharedInstance.RemoveactivityView(View: self.view)}
            if(error != nil)
            {
                DispatchQueue.main.async {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)}
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    
                    let payload = result["payload"] as? Dictionary<String, Any> ?? [:]
                    self.availableStatus = payload["availableStatus"] as? Int ?? 0
                    self.wallStatusArray.removeAll()
                    let data = payload["wallstatus"] as? NSArray ?? []
                    if data.count > 0{
                        for obj in data {
                            
                            if let statusDict = obj as? NSDictionary {
                                
                                self.wallStatusArray.append(WallStatus(responseDict: statusDict))
                            }
                        }
                        if isToPush {
                            self.pushToSpecifiedStory(statusId: statusId, wallStatusArray: self.wallStatusArray)
                        }else{
                            for controller in self.navigationController?.viewControllers ?? [] {
                                
                                if controller.isKind(of: FeedsViewController.self){
                                    DispatchQueue.main.async {
                                        
                                        (controller as! FeedsViewController).wallStatusArray = self.wallStatusArray
                                        (controller as! FeedsViewController).availableStatus = self.availableStatus
                                        (controller as! FeedsViewController).tblFeeds.reloadData()
                                    }
                                    break
                                }
                            }
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async {
                            
                            self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                        }
                    }
                }
            } })
        
    }
    
  
    
    func deleteAllNotificationsApi(){
        AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: "Are you sure to delete all notifications?", buttonTitles: ["Yes","No"], onController: self, dismissBlock: { title, index in
            if index == 0{
         Themes.sharedInstance.activityView(View: self.view)
         let params = NSMutableDictionary()
         URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.clearAllNotification, param: params, completionHandler: {(responseObject, error) ->  () in
             Themes.sharedInstance.RemoveactivityView(View: self.view)
             if(error != nil)
             {
                 self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                 print(error ?? "defaultValue")
                 
             }else{
                 
                 let result = responseObject! as NSDictionary
                 let status = result["status"] as? Int16 ?? 0
                 let message = result["message"] as? String ?? ""
                 
                 if status == 1{
                     self.listArray.removeAll()
                     self.tblView.reloadData()
                     AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: message as NSString, buttonTitles: ["Ok"], onController: self, dismissBlock: { title, index in
                         if index == 0{
                             self.navigationController?.popViewController(animated: true)
                         }
                     })
                         
                 }
                 else
                 {
                     self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                 }
             }
         })
            }
        })
    }
    /*
    func pushToSpecifiedStory(statusId:String){
        var index = 0
        for mainStatus in wallStatusArray{
            
            for status in mainStatus.statusArray{
                
                if status.statusId == statusId {
                    
                    DispatchQueue.main.async {
                        
                        let vc = StoryBoard.main.instantiateViewController(withIdentifier: "StoryPageViewVC") as! StoryPageViewVC
                        vc.isMyStatus = true
                        vc.currentStatusIndex = 0
                        vc.wallStatusArray  =  [mainStatus] //self.wallStatusArray
                       // vc.currentStatusIndex = index //0
                        vc.view.backgroundColor = .black
                        vc.modalPresentationStyle = .custom
                        //vc.customDelegate = self
                        //self.navigationController?.presentView(vc, animated: true)
                        //self.navigationController?.pushViewController(vc, animated: true)
                        AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
                    }
                    return
                  
                }
            }
            
            index = index + 1
        }
    }*/
    
    func pushToSpecifiedStory(statusId:String,wallStatusArray:[WallStatus]){
       
        for mainStatus in wallStatusArray{
            var index = 0
            for status in mainStatus.statusArray{
                
                if status.statusId == statusId {
                    
                    DispatchQueue.main.async {
                        
                        let vc = StoryBoard.main.instantiateViewController(withIdentifier: "StoryPageViewVC") as! StoryPageViewVC
                        //vc.isMyStatus = true
                        vc.currentStatusIndex = 0
                        vc.startIndex = index
                        vc.wallStatusArray  =  [mainStatus]
                        vc.view.backgroundColor = .black
                        vc.modalPresentationStyle = .custom
                        vc.customDelegate = self
                        AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
                    }
                    return
                  
                }
                index = index + 1
            }
        }
    }
}

extension FeedsNotificationVC:UITableViewDelegate,UITableViewDataSource{
    
    func shouldAllowSelectionAt(indexPath:IndexPath) -> Bool{
        return  true
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.shouldAllowSelectionAt(indexPath:indexPath)
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return self.shouldAllowSelectionAt(indexPath:indexPath)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if self.shouldAllowSelectionAt(indexPath:indexPath) {
            return indexPath
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedNotificationTblCellId") as? FeedNotificationTblCell
        cell?.lblName.text = (listArray[indexPath.row].userInfo?.pickzonId ?? "")
        
        cell?.imgVwCelebrity.isHidden = true
        if listArray[indexPath.row].userInfo?.celebrity == 1 {
            cell?.imgVwCelebrity.isHidden = false
            cell?.imgVwCelebrity.image = PZImages.greenVerification
        }else if listArray[indexPath.row].userInfo?.celebrity == 4 {
            cell?.imgVwCelebrity.isHidden = false
            cell?.imgVwCelebrity.image = PZImages.goldVerification
        }else if listArray[indexPath.row].userInfo?.celebrity == 5{
            cell?.imgVwCelebrity.isHidden = false
            cell?.imgVwCelebrity.image = PZImages.blueVerification
        }
        
        cell?.profileImgView.setImgView(profilePic:  listArray[indexPath.row].userInfo!.profilePic, frameImg:  listArray[indexPath.row].userInfo!.avatar,changeValue: 6)
        
        cell?.profileImgView?.imgVwProfile?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                      action:#selector(self.handleProfilePicTap(_:))))
        cell?.lblDate.text = listArray[indexPath.row].feedTime
        cell?.profileImgView.imgVwProfile?.tag = indexPath.row
        cell?.lblLastMsg.textReplacementType = .word
        cell?.lblLastMsg.shouldCollapse = true
        cell?.lblLastMsg.numberOfLines = 3
        cell?.lblLastMsg.delegate = self
        cell?.lblLastMsg.isUserInteractionEnabled = false
        if states.count > indexPath.row {
            cell?.lblLastMsg.collapsed = states[indexPath.row]
        }
        cell?.lblLastMsg.attributedText =  convertAttributtedColorText(text:listArray[indexPath.row].message)
        
        cell?.lblLastMsg.collapsedAttributedLink = NSAttributedString(string: "Read more" ,attributes:  [.foregroundColor:UIColor.systemBlue])
        
        if self.showSelect == true {
            cell?.btnSelect.isHidden = false
            if listArray[indexPath.row].isSelect == true {
                cell?.btnSelect.setImage(PZImages.check, for: .normal)
            }else {
                cell?.btnSelect.setImage(PZImages.uncheck, for: .normal)
            }
        }else {
            cell?.btnSelect.isHidden = true
        }
        cell?.btnSelect.tag = indexPath.row
        cell?.btnSelect.addTarget(self, action: #selector(selectNotificationAction(sender:)), for: .touchUpInside)
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //  1 for feed, 2 for clips, 3 for mall

        
        if listArray[indexPath.row].type == "scheduledPk"{
            let destVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "AgencyPkVC") as! AgencyPkVC
            self.navigationController?.pushView(destVC, animated: true)
            
        }else if listArray[indexPath.row].type == "refer"{
                
                let destVC:ReferalsViewController = StoryBoard.feeds.instantiateViewController(withIdentifier: "ReferalsViewController") as! ReferalsViewController
                self.navigationController?.pushView(destVC, animated: true)
                
            }else if listArray[indexPath.row].type == "story"{

                if listArray[indexPath.row].storyId.count == 0 {
                    self.getAllStatusListApi(statusId: listArray[indexPath.row].feedId, isToPush: true)
                }else{
                    self.getAllStatusListApi(statusId: listArray[indexPath.row].storyId, isToPush: true)
                }

            }else if listArray[indexPath.row].type == "storyTag"{

                    self.getAllStatusListApi(statusId: listArray[indexPath.row].storyId, isToPush: true)
                
            }else if listArray[indexPath.row].type == "wallpost" || listArray[indexPath.row].type == "post" || listArray[indexPath.row].type == "pagePost"{
                
                let vc = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
                vc.postId = listArray[indexPath.row].feedId
                vc.controllerType = .isFromNotification
                self.navigationController?.pushViewController(vc, animated: true)
                
                
            }else if listArray[indexPath.row].type == "postLike" || listArray[indexPath.row].type == "pagePostLike" || listArray[indexPath.row].type == "pagePostComment" || listArray[indexPath.row].type == "postCommentLike" ||
                listArray[indexPath.row].type == "postComment" || listArray[indexPath.row].type == "pagePostCommentLike"{
                
                let vc = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
                vc.postId = listArray[indexPath.row].feedId
                vc.controllerType = .isFromNotification
                self.navigationController?.pushViewController(vc, animated: true)
                
                
            }else if (listArray[indexPath.row].type == "following_you") || (listArray[indexPath.row].type == "followingUser") || (listArray[indexPath.row].type == "followUser") || (listArray[indexPath.row].type == "profile"){
                
                let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                profileVC.otherMsIsdn =  listArray[indexPath.row].userInfo?.userId ?? ""
                self.navigationController?.pushViewController(profileVC, animated: true)
                
            }else if (listArray[indexPath.row].type == "Friend request") || (listArray[indexPath.row].type == "request") || (listArray[indexPath.row].type == "requestedUser"){
                
                let viewController:SuggestionListVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "SuggestionListVC") as! SuggestionListVC
                viewController.isRequestSelected = true
                viewController.isContactSelected = false
                viewController.isSuggestedSelected = false
                self.navigationController?.pushView(viewController, animated: true)
                
            }else if listArray[indexPath.row].type == "leaderboard"{
                
                let viewController = StoryBoard.premium.instantiateViewController(withIdentifier: "LeaderBoardVC") as! LeaderBoardVC
                viewController.isLastMonth = true
                self.navigationController?.pushView(viewController, animated: true)
            }else{
                
                switch listArray[indexPath.row].notificationType {
                    
                case 1:
                    if listArray[indexPath.row].feedId.count > 0 {
                        let vc = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
                        vc.postId = listArray[indexPath.row].feedId
                        vc.controllerType = .isFromNotification
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    break

                case 3:
                    
                    break
                    
                case 4:
                    
                    if (listArray[indexPath.row].type == "following_you"){
                        
                        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                        profileVC.otherMsIsdn =  listArray[indexPath.row].userInfo?.userId ?? ""
                        self.navigationController?.pushViewController(profileVC, animated: true)
                        
                    }else{
                        let viewController:SuggestionListVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "SuggestionListVC") as! SuggestionListVC
                        viewController.isRequestSelected = true
                        viewController.isContactSelected = false
                        viewController.isSuggestedSelected = false
                        self.navigationController?.pushView(viewController, animated: true)
                    }
                    break
                    
                case 5:
                    
                    // Story
                    break
                    
                    
                default:
                    break
                }
            }
        
    }
    
    private func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    
   
    
    private func tableView(tableView: UITableView!, commitEditingStyle editingStyle:   UITableViewCell.EditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            
        }
    }
   
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
                   
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
            {
                if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                    
                    self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
                    
                }else  if !isDataLoading {
                    if pageNo <= totalPageNo {
                        isDataLoading = true
                        self.getAllNotificationListApi()
                    }
                }
            }
        
    }
   
    
    //MARK: SElector methods
    
    @objc  func handleProfilePicTap(_ sender: UITapGestureRecognizer? = nil){


            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn =  listArray[sender?.view?.tag ?? 0].userInfo?.userId ?? ""
            self.navigationController?.pushViewController(profileVC, animated: true)
            
    }
    
   
    
    func dateTimeStatus(date: String) -> Date{
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?

        let newDdate = dateFormatter.date(from: date)!
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter1.locale = .autoupdatingCurrent
        dateFormatter1.timeZone = NSTimeZone.local
        let dateString = dateFormatter1.string(from: newDdate)
        
        let convDate = dateFormatter1.date(from: dateString) ?? Date()
        
        return convDate
    }
  
}

extension FeedsNotificationVC:StoryPageViewControllerDelegate {
    
    //MARK:- Delegate method of Stories cell
    
    func DidDismiss() {
    }
    
    func didclickedViewCount(){
        let profileVC:LikeUsersVC = StoryBoard.main.instantiateViewController(withIdentifier: "LikeUsersVC") as! LikeUsersVC
        profileVC.controllerType = .storyView
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func didClickDelete(_ messageFrame: WallStatus.StoryStaus) {
        
        let param:NSDictionary = ["statusId":messageFrame.statusId]
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeDeleteAPICall(url:Constant.sharedinstance.deleteStoryStatus as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int64 ?? 0
                let message = result["message"]
                
                if status == 1{
                    self.getAllStatusListApi(statusId: messageFrame.statusId, isToPush: false)
                    AlertView.sharedManager.displayMessage(title: "PickZon", msg: message as! String, controller: self)
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
}
    
    
extension FeedsNotificationVC:ExpandableLabelDelegate{
    func numberTextClicked(_ label: ExpandableLabel, number: String) {
        
        if let url = URL(string: "tel://\(number)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func hashTagTextClicked(_ label: ExpandableLabel, hashTag: String) {
        
        let destVc:WallPostViewVC = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
        destVc.controllerType = .hashTag
            destVc.hashTag = hashTag
        AppDelegate.sharedInstance.navigationController?.pushViewController(destVc, animated: true)
    }
    
    
    
    func convertAttributtedColorText(text:String) -> NSAttributedString{
        
        let  originalStr = text
        let att = NSMutableAttributedString(string: originalStr);

//        let detectorType: NSTextCheckingResult.CheckingType = [.address, .phoneNumber, .link]
        let detectorType: NSTextCheckingResult.CheckingType = [.link, .phoneNumber]

        do {
            let detector = try NSDataDetector(types: detectorType.rawValue)
            let results = detector.matches(in: originalStr, options: [], range: NSRange(location: 0, length:
                                                                                    originalStr.utf16.count))
            for result in results {
                if let range1 = Range(result.range, in: originalStr) {
                    let matchResult = originalStr[range1]
                    if matchResult.count > 0 {
                        att.addAttributes([NSAttributedString.Key.foregroundColor:Themes.sharedInstance.tagAndLinkColor()], range: result.range)
                    }
                    //print("result: \(matchResult), range: \(result.range)")
                }
            }
        } catch {
            print("handle error")
        }
    return att
    }
    
    
    
    // MARK: ExpandableLabel Delegate
    func willExpandLabel(_ label: ExpandableLabel) {
        tblView.beginUpdates()
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        let point = label.convert(CGPoint.zero, to: tblView)
        if let indexPath = tblView.indexPathForRow(at: point) as IndexPath? {
            if states.count > indexPath.row {
                states[indexPath.row] = false
            }            //DispatchQueue.main.async { [weak self] in
              //  self?.tblFeeds.scrollToRow(at: indexPath, at: .none, animated: false)
           // }
        }
        tblView.endUpdates()
    }
    
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        tblView.beginUpdates()
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        let point = label.convert(CGPoint.zero, to: tblView)
        if let indexPath = tblView.indexPathForRow(at: point) as IndexPath? {
            states[indexPath.row] = true
            DispatchQueue.main.async { [weak self] in
               self?.tblView.reloadRows(at: [indexPath], with: .none)

              // self?.tblFeeds.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
        tblView.endUpdates()
    }
    
    func mentionTextClicked(_ label: ExpandableLabel,mentionText:String){
        
        print("mentionTextClicked \(mentionText)")
        
       // let mentionString:String = mentionText
       // self.getUserIdFromPickzonId(pickzonId: mentionString.replacingOccurrences(of: "@", with: ""))
    }
    

    
    func urlTextClicked(_ label: ExpandableLabel,strURL:String) {
       /* let point = label.convert(CGPoint.zero, to: tblView)
        if let indexPath = tblView.indexPathForRow(at: point) as IndexPath? {
            if let objWallPost = arrwallPost[indexPath.row] as? WallPostModel {
                if objWallPost.sharedWallData == nil {
                    if objWallPost.userInfo?.celebrity == 1 {
                        let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
                        vc.strUrl = strURL
                        AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
                    }
                }else {
                    if objWallPost.sharedWallData.userInfo?.celebrity == 1 {
                        let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
                        vc.strUrl = strURL
                        
                    }
                }
            }
            
        }*/
        
        let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
        vc.urlString = strURL
        AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
    }
    
}





class FeedNotificationTblCell:UITableViewCell{
    
    @IBOutlet weak var profileImgView:ImageWithFrameImgView!
    @IBOutlet weak var lblLastMsg:ExpandableLabel!
    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var imgVwCelebrity:UIImageView!
    @IBOutlet weak var btnSelect:UIButton!
    
    override  func awakeFromNib() {
        profileImgView.initializeView()
    }
}





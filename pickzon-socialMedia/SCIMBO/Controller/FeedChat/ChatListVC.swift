//
//  ChatLIstVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 11/28/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import UIKit
import DropDown
import RxSwift
import Kingfisher
import IQKeyboardManager
import FittedSheets

class ChatListVC: SwiftBaseViewController,OptionDelegate {
    
    @IBOutlet weak var txtFdSearch: UITextField!

    
    @IBOutlet weak var bgVwNotifcationCount:UIViewX!
    @IBOutlet weak var lblNotificationCount:UILabel!
    @IBOutlet weak var searchTxtFdBgVw:UIView!
//    @IBOutlet weak var btnClose:UIButton!
//    @IBOutlet weak var btnCloseSearch:UIButton!

    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var  btnNewChat:UIButton!
   // @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var btnOption:MIBadgeButton!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    var emptyView:EmptyList?
    var searchFeedChatArray: [FeedChatModel] = []
    var pageNumber = 1
    var pageLimit =  15
    var totalPages = 0
    var isDataLoading = false
    var chatListArray:Array<FeedChatModel> = Array<FeedChatModel>()
    var selectedFcrId = ""
    var isSearching = false
    
   
    //MARK: Controller life cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print("UIViewController: FeedsChatListVC")
        addObservers()
        checkSocketStatusAndUpdateCount()
        fetchFeedChatListFromDB()
        cnstrntHtNavBar.constant = self.getNavBarHt
        emptyView = EmptyList(frame: CGRect(x: 0, y: -64, width: tblView.frame.size.width, height: tblView.frame.size.height))
        emptyView?.imageView?.image = PZImages.noChat
        emptyView?.lblMsg?.text = "No Chats available"
        self.tblView.addSubview(emptyView!)
        emptyView?.isHidden = true
        tblView.register(UINib(nibName: "ChatListTblCell", bundle: nil), forCellReuseIdentifier: "ChatListTblCell")
        if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected){
            SocketIOManager.sharedInstance.establishConnection(Nickname: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()) as NSString, isLogin: true)
        }
        designMethodInitial()
       // self.btnOption.badgeString = "\(Constant.sharedinstance.requestedChatCount)"
        //self.btnOption.isHidden = (Constant.sharedinstance.requestedChatCount == 0) ? true : false
        tblView.keyboardDismissMode = .onDrag
    }
    
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkSocketStatusAndUpdateCount()
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        if Themes.sharedInstance.isChatListRefresh == 0 {
            emitChatList(isToClearList: true)
        }
        selectedFcrId = ""
        SocketIOManager.sharedInstance.emitChatAndNotificationCount(userId: Themes.sharedInstance.Getuser_id())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Initial Setup Methods
    
    func addObservers(){
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshFeedChatList), name: NSNotification.Name(rawValue: Constant.sharedinstance.feed_chat_list), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.socketError(notification:)), name: NSNotification.Name(rawValue: Constant.sharedinstance.socket_error), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveFeedMessage), name: NSNotification.Name(rawValue:Constant.sharedinstance.sio_feed_receive_new_user_list), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.clearChat(notification:)), name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_clear_user_chat_list), object: nil)
       
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshCount),
                                               name: NSNotification.Name(rawValue: noti_RefreshChatCount),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.socketConnected(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.socketCnnected), object: nil)
    }

    func designMethodInitial(){
//        searchBar.showsCancelButton = true
//        if #available(iOS 13.0, *) {
//            searchBar.searchTextField.delegate = self
//        } else {
//            searchBar.textFieldSearchBar?.delegate = self
//        }
//        searchBar.showsCancelButton = false
    }
    
    func clearAllData(){
        self.pageNumber = 1
       // self.totalPages = 0
        self.chatListArray.removeAll()
        self.searchFeedChatArray.removeAll()
        self.tblView.reloadData()
    }
    
    func fetchFeedChatListFromDB(){
        
        guard let realm = DBManager.openRealm() else {
            return
        }
        
        for dbObj in realm.objects(FeedChat.self){
            
            var chatObj = FeedChatModel(respDict: [:])
            chatObj.fcrId =  dbObj.fcrId ?? ""
            chatObj.createdAt = dbObj.createdAt
            chatObj.createdAtFCM =  dbObj.createdAtFCM
            chatObj.blockStatus =  dbObj.blockStatus
            chatObj.unreadCount = dbObj.unreadcount
            chatObj.lastMessage = dbObj.lastMessage
            chatObj.requestedUser =   Int(dbObj.requestedUser)
            chatObj.messageStatus = dbObj.messageStatus
            chatObj.timeStamp = Int(dbObj.timeStamp)
            chatObj.type = Int(dbObj.type)
           // chatObj.chatType = Int(dbObj.chatType)

            chatObj.userInfo = ChatUser(userDict:[:])
            if let userObj = realm.object(ofType: LastMessageUserInfo.self, forPrimaryKey: dbObj.chatUserId ){
                
                chatObj.userInfo?.actualProfileImage =  userObj.actualProfileImage
                chatObj.userInfo?.name =  userObj.name
                chatObj.userInfo?.onlineOfflineStatus =  Int(userObj.onlineOfflineStatus)
                chatObj.userInfo?.onlineOfflineTime =   Int(userObj.onlineOfflineTime)
                chatObj.userInfo?.pickzonId  = userObj.pickzonId
                chatObj.userInfo?.profilePic = userObj.profilePic
                chatObj.userInfo?.userId = userObj.userId ?? ""
                chatObj.userInfo?.celebrity = Int(userObj.celebrity)

            }else{
                chatObj.userInfo?.actualProfileImage =  dbObj.userObj?.actualProfileImage ?? ""
                chatObj.userInfo?.name =  dbObj.userObj?.name ?? ""
                chatObj.userInfo?.onlineOfflineStatus =  Int(dbObj.userObj?.onlineOfflineStatus ?? 0)
                chatObj.userInfo?.onlineOfflineTime =   Int(dbObj.userObj?.onlineOfflineTime ?? 0)
                chatObj.userInfo?.pickzonId  = dbObj.userObj?.pickzonId ?? ""
                chatObj.userInfo?.profilePic = dbObj.userObj?.profilePic ?? ""
                chatObj.userInfo?.userId = dbObj.userObj?.userId ?? ""
                chatObj.userInfo?.celebrity = Int(dbObj.userObj?.celebrity ?? 0)
            }

            self.chatListArray.append(chatObj)
        }
        self.emptyView?.isHidden =  (self.chatListArray.count == 0) ? false : true
        self.tblView.reloadData()
    }
    
    //MARK: Socket Emit Methods
    
    func checkSocketStatusAndUpdateCount(){

        if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected)
        {
            SocketIOManager.sharedInstance.establishConnection(Nickname: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()) as NSString, isLogin: true)
        }else{
            SocketIOManager.sharedInstance.emitChatAndNotificationCount(userId: Themes.sharedInstance.Getuser_id())

        }
    }
    
    
    func emitChatList(isToClearList:Bool){
        // Themes.sharedInstance.activityView(View: self.view)
        if isToClearList{
            self.pageNumber = 1
            self.totalPages = 0
        }
        // listType: "chatList" // requested
        let param = ["authToken":Themes.sharedInstance.getAuthToken(),"pageNumber":pageNumber,"pageLimit":pageLimit,"listType":"chatList"] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.feed_chat_list, param)
    }
   
    
    func checkSocketStatus(){
        
        if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected)
        {
            SocketIOManager.sharedInstance.establishConnection(Nickname: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()) as NSString, isLogin: true)
        }
        SocketIOManager.sharedInstance.emitChatAndNotificationCount(userId: Themes.sharedInstance.Getuser_id())
    }
    
    //MARK: Observers methods
    @objc func socketConnected(notification: Notification) {
        
        if self.chatListArray.count == 0{
            self.emitChatList(isToClearList:true)
        }
    }
    
    
    @objc func refreshCount(notification: Notification) {
        
        if let indexData = notification.userInfo?["count"] as? Int {
                Constant.sharedinstance.notificationCount = (indexData == 0) ? 0 : indexData
        }
        
        if let feedChatCount = notification.userInfo?["feedChatCount"] as? Int {
 
            Constant.sharedinstance.feedChatCount = feedChatCount
            
        }
        
        if let requestedChatCount = notification.userInfo?["requestedChatCount"] as? Int {
            DispatchQueue.main.async {
              // self.btnOption.badgeString =  "\(requestedChatCount)"
              Constant.sharedinstance.requestedChatCount = requestedChatCount
                if requestedChatCount == 0{
                    self.btnOption.badgeString =  ""
                    
                }
               // self.btnOption.isHidden = (Constant.sharedinstance.requestedChatCount == 0) ? true : false
            }
        }
        
        self.lblNotificationCount.text = "\(Constant.sharedinstance.notificationCount)"
        
        if  Constant.sharedinstance.notificationCount == 0 {
            self.lblNotificationCount.text =  ""
            
        }
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: notif_Badgecount),
//                                        object:nil, userInfo: nil)
    }
    
    
    @objc func receiveFeedMessage(_ notify: Notification){
        
        if let messageDict = notify.userInfo as? NSDictionary {
            
            if let payloadDict = messageDict.object(forKey: "payload") as? NSDictionary {
    
                if payloadDict["listType"] as? String ?? "" == "chatList"{
                    
                   var chatObj = FeedChatModel(respDict: payloadDict)
                    var index = 0
                    var isFound = false
                    for obj in self.chatListArray{
                        
                        if obj.fcrId == chatObj.fcrId && selectedFcrId != chatObj.fcrId{
                        
                      //  if obj.fcrId == chatObj.fcrId { // && fcrId != chatObj.fcrId{

                            isFound = true
                            let replaceObj =  self.chatListArray[index]
                            chatObj.unreadCount =  replaceObj.unreadCount  + 1
                            let newArray =  self.chatListArray.filter { filterObj in
                                return filterObj.fcrId != chatObj.fcrId
                            }
                            self.chatListArray  = newArray
                            self.chatListArray.insert(chatObj, at: 0)
                            self.tblView.reloadData()
                            break
                        }
                        index = index + 1
                    }
                                
                        if isFound == false && selectedFcrId != chatObj.fcrId{
                            self.chatListArray.insert(chatObj, at: 0)
                            self.tblView.reloadData()

                        }
                    }
                self.emptyView?.isHidden = self.chatListArray.count == 0 ? false : true
                
            }
        }
    }
    
    
    
    
    
    @objc func refreshFeedChatList(notification: Notification) {
              
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            self.isDataLoading = false
            /*  let dataDict =  response["data"] as? NSDictionary ?? [:]
             let result =  dataDict["response"] as? NSDictionary ?? [:]
             let status = response["status"] as? Int ?? 0
             */
            let message = response["message"] as? String ?? ""
            
            if message == "chatList" {
                
                totalPages = response["totalPages"] as? Int ?? 0
                
                if pageNumber == 1{
                    self.chatListArray.removeAll()
                    self.clearAllData()
                }
                if let payload = response["payload"] as? NSArray {
                    
                    for dict in payload{
                        self.chatListArray.append(FeedChatModel(respDict: dict as? NSDictionary ?? [:]))
                    }
                }
                self.emptyView?.isHidden =  ( self.chatListArray.count == 0) ? false : true
                self.tblView.reloadData()
                if self.pageNumber == 1{
                    DBManager.shared.insertChatList(chatArray: self.chatListArray, isInitial: true)
                }
                self.pageNumber = self.pageNumber + 1
            }
        }
    }
    
    
    @objc func clearChat(notification:Notification){
        
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            if let payloadDict = response["payload"] as? NSDictionary{
                
                if payloadDict["type"] as? Int ?? 0 == 1 {
                    var index = 0
                    for chatObj in chatListArray{
                        if (payloadDict.object(forKey: "fcrId") as? String ?? "") == chatObj.fcrId{
                            self.chatListArray.remove(at: index)
                            self.tblView.reloadData()
                            break
                        }
                        index = index + 1
                    }
                    index = 0
                    for chatObj in searchFeedChatArray{
                        if (payloadDict.object(forKey: "fcrId") as? String ?? "") == chatObj.fcrId{
                            self.searchFeedChatArray.remove(at: index)
                            self.tblView.reloadData()
                            break
                        }
                        index = index + 1
                    }
                }
            }
        }
    }
    
    
    @objc func socketError(notification: Notification){
        Themes.sharedInstance.RemoveactivityView(View: self.view)
    }
    
    //MARK: UIButton Action Methods
    
    @IBAction func closebtnSearch(sender:UIButton){
        
        self.searchTxtFdBgVw.isHidden = true
        self.txtFdSearch.resignFirstResponder()
        self.isSearching = false
        self.txtFdSearch.text = ""
        self.tblView.reloadData()
    }
    
    @IBAction func searchBtnAction(sender:UIButton){
        self.searchTxtFdBgVw.isHidden = false
        self.txtFdSearch.becomeFirstResponder()
    }
    
    @IBAction func notificationBtnAction(sender:UIButton){
       if let viewController:FeedsNotificationVC = StoryBoard.main.instantiateViewController(withIdentifier: "FeedsNotificationVC") as? FeedsNotificationVC {
//             viewController.wallStatusArray = wallStatusArray
//             viewController.availableStatus = availableStatus
             self.navigationController?.pushView(viewController, animated: true)
         }
    }

    
    @IBAction func newChatButtonAction(sender:UIButton){
        
        let newChatVC:ChatUserListVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatUserListVC") as! ChatUserListVC
        self.navigationController?.pushView(newChatVC, animated: true)
        
    }
    
    @IBAction func backButtonAction(sender:UIButton){
        NotificationCenter.default.removeObserver(self)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func optionButtonAction(sender:UIButton){
        self.view.endEditing(true)
        let controller = UIStoryboard(name: "TableViewDemo", bundle: nil).instantiateInitialViewController()! as! TableViewDemo
        
        controller.listArray = ["Chat Requests","Blocked User List"]
        controller.iconArray =  ["friend","BlockAccount"]
        
//        controller.listArray = ["Blocked User List"]
//        controller.iconArray =  ["BlockAccount"]
        
        //let msg = (Constant.sharedinstance.requestedChatCount == 0 || Constant.sharedinstance.requestedChatCount == 0) ?  "" : "\(Constant.sharedinstance.requestedChatCount)"
//        controller.countRowIndex = 0
//        controller.countNotification = msg
        controller.videoIndex = 0
        controller.delegate = self
        let useInlineMode = view != nil
        
        let sheet = SheetViewController(
            controller: controller,
            sizes: [.percent(0.25), .intrinsic],
            options: SheetOptions(useFullScreenMode:false, shrinkPresentingViewController:false, useInlineMode: useInlineMode))
        sheet.allowPullingPastMaxHeight = false
        if let view = view {
            sheet.animateIn(to: view, in: self)
        } else {
            self.present(sheet, animated: true, completion: nil)
        }
    }
    
    
    //MARK: - Delegete method of bottom sheet view
    func selectedOption(index:Int,videoIndex:Int,title:String){
        
        if title == "Blocked User List"{
            
            let vc = StoryBoard.main.instantiateViewController(withIdentifier: "BlockedUserVC") as! BlockedUserVC
            self.pushView(vc, animated: true)
            
        }else  if title == "Chat Requests"{
            
            let settingsVC:MessageRequestListVC = StoryBoard.chat.instantiateViewController(withIdentifier: "MessageRequestListVC") as! MessageRequestListVC
            self.navigationController?.pushView(settingsVC, animated: true)
            
        }
      
        
       
    }
}


extension ChatListVC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  (isSearching) ? searchFeedChatArray.count : chatListArray.count
       
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListTblCell") as? ChatListTblCell
        
        if isSearching && searchFeedChatArray.count > indexPath.row {
            cell?.setChatlistData(searchFeedChatArray[indexPath.row])
        }else {
            cell?.setChatlistData(chatListArray[indexPath.row])
        }
        cell?.lblDate.isHidden = false
//        cell?.btnProfile.tag = indexPath.row
//        cell?.btnProfile.addTarget(self, action: #selector(openProfile(sender:)), for: .touchUpInside)
        cell?.profileImgView.imgVwProfile?.tag = indexPath.row
        cell?.profileImgView.imgVwProfile?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                          action:#selector(self.handleProfilePicTap(_:))))
        return cell!
    }
    
    
    private func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
     
        return true
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in

            AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: "Are you sure want to Delete?", buttonTitles: ["Yes","No"], onController: self, dismissBlock: { title, index in
                    if index == 0{
                        self.deleteChatList(indexPath:indexPath )
                    }
                })
            
            
            completionHandler(true)
        }
        
        delete.image = UIImage(systemName: "trash")
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [delete])
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        return swipeActionConfig
    }
    
    private func tableView(tableView: UITableView!, commitEditingStyle editingStyle:   UITableViewCell.EditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            
            /*tblView.beginUpdates()
             tblView.removeAtIndex(indexPath!.row)
             tblView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: nil)
             tblView.endUpdates()
             */
            
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
        {
            if !isDataLoading {
                isDataLoading = true
                if pageNumber <= totalPages {
                    emitChatList(isToClearList: false)
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Themes.sharedInstance.isChatListRefresh = 1
        var chatObj: FeedChatModel?
        if isSearching {
            chatObj = searchFeedChatArray[indexPath.row]
            searchFeedChatArray[indexPath.row].unreadCount = 0
        }else{
            chatObj = chatListArray[indexPath.row]
            chatListArray[indexPath.row].unreadCount = 0
        }
        selectedFcrId = chatObj?.fcrId ?? ""
        isSearching = false
        txtFdSearch.text = ""
        self.tblView.reloadData()
      //  self.tblView.reloadRows(at: [indexPath], with: .none)

        let settingsVC:FeedChatVC = StoryBoard.chat.instantiateViewController(withIdentifier: "FeedChatVC") as! FeedChatVC
        settingsVC.toChat = chatObj?.userInfo?.userId ?? ""
        settingsVC.fromName = chatObj?.userInfo?.name ?? ""
        settingsVC.pickzonId = chatObj?.userInfo?.pickzonId ?? ""
        settingsVC.fcrId = chatObj?.fcrId ?? ""
        settingsVC.fullUrl = chatObj?.userInfo?.profilePic ?? ""
        settingsVC.avatar = chatObj?.userInfo?.avatar ?? ""
       // settingsVC.messageType = chatObj?.chatType ?? 1
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    
    //MARK: Selector Methods
    
    @objc func deleteChatList(indexPath:IndexPath){
        
        DBManager.shared.deleteChatList(fcrId: ((isSearching) ? searchFeedChatArray[indexPath.row] : chatListArray[indexPath.row]).fcrId)
        
        let params = ["authToken":Themes.sharedInstance.getAuthToken(),"fcrId": self.chatListArray[indexPath.row].fcrId,"type":1] as NSDictionary
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_feed_clear_user_chat_list, params)
     
       
    }

    @objc  func handleProfilePicTap(_ sender: UITapGestureRecognizer? = nil){

   // @objc func openProfile(sender:UIButton){
        
        if let index = sender?.view?.tag{
            var opponentId = ""
            if isSearching {
                opponentId = searchFeedChatArray[index].userInfo?.userId ?? ""
            }else{
                opponentId = chatListArray[index].userInfo?.userId ?? ""
            }
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn = opponentId
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    /*
    //MARK: - UISearchbarDelegate
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool   {
        
        let searchedText = NSString(string: searchBar.text!).replacingCharacters(in: range, with: text)
        searchFeedChatArray.removeAll()
        
        searchFeedChatArray = chatListArray.filter {$0.userInfo?.name.lowercased().range(of: searchedText.lowercased(), options: .caseInsensitive) != nil
        }
        if  searchedText.length > 0{
            self.isSearching = true
        }else{
            self.isSearching = false
        }
        tblView.reloadData()
        return true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.isSearching = false
            self.searchBar.text = ""
            searchFeedChatArray.removeAll()
            tblView.reloadData()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        self.view.endEditing(true)
        searchBar.resignFirstResponder()
        print(" searchBar.text ")
        if searchBar.text == "" {
            self.isSearching = false
            self.searchBar.text = ""
            searchFeedChatArray.removeAll()
            tblView.reloadData()
        }else{
            searchFeedChatArray.removeAll()
            searchFeedChatArray = chatListArray.filter {$0.userInfo?.name.lowercased().range(of: searchBar.text!.lowercased(), options: .caseInsensitive) != nil
            }
           self.isSearching = true
           tblView.reloadData()
        }
    }
  
    */
   
}


extension  ChatListVC: UITextFieldDelegate{
    //MARK: - UItextfield Delegate methods
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.isSearching = false
        self.txtFdSearch.text = ""
        searchFeedChatArray.removeAll()
        tblView.reloadData()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        txtFdSearch.resignFirstResponder()
        print(" searchBar.text ")
        
        if textField.text?.count ?? 0 > 0{
            searchFeedChatArray.removeAll()
            searchFeedChatArray = chatListArray.filter {$0.userInfo?.name.lowercased().range(of: textField.text!.lowercased(), options: .caseInsensitive) != nil
            }
            self.isSearching = true
            tblView.reloadData()
        }else{
            self.isSearching = false
            self.txtFdSearch.text = ""
            searchFeedChatArray.removeAll()
            tblView.reloadData()
        }
        
        
        return true
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let previousText:NSString = textField.text! as NSString
        let searchedText = previousText.replacingCharacters(in: range, with: string)
       
        searchFeedChatArray.removeAll()
        
        searchFeedChatArray = chatListArray.filter {$0.userInfo?.name.lowercased().range(of: searchedText.lowercased(), options: .caseInsensitive) != nil
        }
        if  searchedText.length > 0{
            self.isSearching = true
        }else{
            self.isSearching = false
        }
        tblView.reloadData()
        return true
    }
    
    
}





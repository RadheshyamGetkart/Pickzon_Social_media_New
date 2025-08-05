//
//  MessageRequestListVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 2/14/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

let refreshRequestList = "refreshRequestList"

class MessageRequestListVC: UIViewController {
    @IBOutlet weak var searchBgView:UIView!
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnOption:UIButton!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    var emptyView:EmptyList?
    var pageNumber = 1
    var pageLimit =  20
    var totalPages = 0
    var isDataLoading = false
    var chatListArray:Array<FeedChatModel> = Array<FeedChatModel>()
    var searchFeedChatArray: [FeedChatModel] = []
    var selectedFcrId = ""
    var isSearching = false
    
    //MARK: Controller life cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        self.tblView.contentInset = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
        print("UIViewController: MessageRequestListVC")
        emptyView = EmptyList(frame: CGRect(x: 0, y: -64, width: tblView.frame.size.width, height: tblView.frame.size.height))
        emptyView?.imageView?.image = PZImages.noChat
        emptyView?.lblMsg?.text = "No Chats available"
        self.tblView.addSubview(emptyView!)
        tblView.register(UINib(nibName: "ChatListTblCell", bundle: nil), forCellReuseIdentifier: "ChatListTblCell")
        emptyView?.isHidden = true
        addObservers()
        emitChatList(isToClearList: false)
        self.searchBgView.isHidden = true
        tblView.keyboardDismissMode = .onDrag

    }
    
    //MARK: Initial Setup Methods
    
    func addObservers(){
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshFeedChatList), name: NSNotification.Name(rawValue: Constant.sharedinstance.feed_chat_list), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.socketError(notification:)), name: NSNotification.Name(rawValue: Constant.sharedinstance.socket_error), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveFeedMessage), name: NSNotification.Name(rawValue:Constant.sharedinstance.sio_feed_receive_new_user_list), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.clearChat(notification:)), name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_clear_user_chat_list), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshRequestListNoti(notification:)), name: NSNotification.Name(rawValue: refreshRequestList), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: UIButton Action Methods
  
    @IBAction func crossBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.searchBgView.isHidden = true
        isSearching = false
        self.searchBar.text = ""
        self.tblView.reloadData()
    }
    
    
    @IBAction func backButtonAction(sender:UIButton){
        self.searchBgView.isHidden = true
        NotificationCenter.default.removeObserver(self)
        self.navigationController?.popViewController(animated: true)
    }
    
   
    @IBAction func optionButtonAction(sender:UIButton){
        self.view.endEditing(true)
        self.searchBgView.isHidden = false
        self.searchBar.becomeFirstResponder()
    }
    
    //MARK: Socket Emit Methods
    func emitChatList(isToClearList:Bool){
        // Themes.sharedInstance.activityView(View: self.view)
        if isToClearList{
            self.pageNumber = 1
            self.totalPages = 0
        }
        // listType: "chatList" // requested
        let param = ["authToken":Themes.sharedInstance.getAuthToken(),"pageNumber":pageNumber,"pageLimit":pageLimit,"listType":"requested"] as [String : Any]
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
                }
            }
        }
    }

    @objc func receiveFeedMessage(_ notify: Notification){
        
        if let messageDict = notify.userInfo as? NSDictionary {
            
            if let payloadDict = messageDict.object(forKey: "payload") as? NSDictionary {
    
                if payloadDict["listType"] as? String ?? "" == "requested"{
                    
                   var chatObj = FeedChatModel(respDict: payloadDict)
                    var index = 0
                    var isFound = false
                    for obj in self.chatListArray{
                        
                        if obj.fcrId == chatObj.fcrId{
                            isFound = true
                            var replaceObj =  self.chatListArray[index]
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
                                
                        if isFound == false{
                            self.chatListArray.insert(chatObj, at: 0)
                            self.tblView.reloadData()

                        }
                    }
                self.emptyView?.isHidden = self.chatListArray.count == 0 ? false : true

                
            }
        }
    }
    
    
  
    @objc func refreshRequestListNoti(notification: Notification) {
        if let fcrId = notification.userInfo?["fcrId"] as? String {
            
            
            var index = 0
            for chatObj in chatListArray{
                if chatObj.fcrId == fcrId{
                    self.chatListArray.remove(at: index)
                    self.tblView.reloadData()
                    break
                }
                index = index + 1
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
             let message = response["message"] as? String ?? ""
             */
            let message = response["message"] as? String ?? ""
            
            if message == "requested" {
                
                totalPages = response["totalPages"] as? Int ?? 0
                
                if pageNumber == 1{
                    self.chatListArray.removeAll()
                    //self.clearAllData()
                }
                if let payload = response["payload"] as? NSArray {
                    
                    for dict in payload{
                        self.chatListArray.append(FeedChatModel(respDict: dict as? NSDictionary ?? [:]))
                    }
                }
                self.pageNumber = self.pageNumber + 1
                
                //  DBManager.shared.insertChatList(chatArray: self.chatListArray, isInitial: true)
                
                self.emptyView?.isHidden =  ( self.chatListArray.count == 0) ? false : true
                self.tblView.reloadData()
            }
        }
    }
    
    
    
    @objc func socketError(notification: Notification){
        Themes.sharedInstance.RemoveactivityView(View: self.view)
    }
    
}

extension MessageRequestListVC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if chatListArray.count == 0 {
            return 0
            
        }
        return 55
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      
        if chatListArray.count == 0 {
            return UITableViewHeaderFooterView()
        }
        let headerView = UITableViewHeaderFooterView()
        let label = UILabel(frame: CGRect(x: 10, y: 0 , width: self.view.frame.width, height: 55))
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = "Open a chat to get more info about who's message you.\nThey won't know you've seen it until you accept."
        headerView.addSubview(label)
        let bottomBorderColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
        let headerBottom_Clr = UIColor(red: 224/255.0, green: 224/255.0, blue: 224/255.0, alpha: 1)
        //headerView.backgroundColor = bottomBorderColor
        headerView.contentView.backgroundColor = bottomBorderColor
        let bottomBorder = CALayer()
        let bottomWidth = CGFloat(2.0)
        bottomBorder.borderColor = headerBottom_Clr.cgColor
        bottomBorder.frame = CGRect(x: 0, y: label.frame.maxY-1, width:  tblView.frame.size.width, height: 1)
        bottomBorder.borderWidth = bottomWidth
        headerView.contentView.layer.addSublayer(bottomBorder)
        headerView.contentView.layer.masksToBounds = true

        return headerView
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
        cell?.profileImgView.imgVwProfile?.tag = indexPath.row
        cell?.profileImgView.imgVwProfile?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                          action:#selector(self.handleProfilePicTap(_:))))
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
        searchBar.text? = ""
        self.tblView.reloadData()
        
        let settingsVC:FeedChatVC = StoryBoard.chat.instantiateViewController(withIdentifier: "FeedChatVC") as! FeedChatVC
        settingsVC.toChat = chatObj?.userInfo?.userId ?? ""
        settingsVC.fromName = chatObj?.userInfo?.name ?? ""
        settingsVC.pickzonId = chatObj?.userInfo?.pickzonId ?? ""
        settingsVC.fcrId = chatObj?.fcrId ?? ""
        settingsVC.fullUrl = chatObj?.userInfo?.profilePic ?? ""
        self.navigationController?.pushViewController(settingsVC, animated: true)
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

    //MARK: Selector Methods
    @objc func deleteChatList(indexPath:IndexPath){
        
        let params = ["authToken":Themes.sharedInstance.getAuthToken(),"fcrId": self.chatListArray[indexPath.row].fcrId,"type":1] as NSDictionary
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_feed_clear_user_chat_list, params)
        
    }
    
    @objc  func handleProfilePicTap(_ sender: UITapGestureRecognizer? = nil){
        
        if let index = sender?.view?.tag{
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn = chatListArray[index].userInfo?.userId ?? ""
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
}



extension MessageRequestListVC:UISearchBarDelegate{
    
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
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
  
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.isSearching = false
        self.searchBar.text = ""
        searchFeedChatArray.removeAll()
        tblView.reloadData()
        return true
    }
}








//
//  FeedChatVC.swift
//  SCIMBO
//
//  Created by Getkart on 02/08/21.
//  Copyright © 2021 Radheshyam Yadav. All rights reserved.
//

import UIKit
import DKImagePickerController
import SwiftyGiphy
import SDWebImage
import CoreLocation
import JSSAlertView
import AVFoundation
import SimpleImageViewer
import AVKit
import GrowingTextView
import Kingfisher
 
class FeedChatVC: BaseViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgListing: UIImageViewX!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var lytMsgViewBottom: NSLayoutConstraint!
    @IBOutlet weak var lytTableBottom: NSLayoutConstraint!
    @IBOutlet weak var btnBlockedUser: UIButton!
    @IBOutlet weak var cnstr_BlockUserVwHeigHt: NSLayoutConstraint!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var onlineView: UIView!
    @IBOutlet weak var imgVwCelebrity: UIView!
    
    
    @IBOutlet weak var bgVwAcceptRejectChat: UIView!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnBlock: UIButton!
    @IBOutlet weak var lblTitleAccept: UILabel!
    @IBOutlet weak var lblMessageAccept: UILabel!
    
    
    //MARK: - Userdefined Variables
    var is_you_removed:Bool = Bool()
    var popovershow = false
    @IBOutlet var selectiontoolbar: UIToolbar!
    @IBOutlet var left_item: UIBarButtonItem!
    @IBOutlet var right_item: UIBarButtonItem!
    @IBOutlet var center_item: UIBarButtonItem!
    
    var IFView:UUInputFunctionView!
    var ReplyView:ReplyDetailView!;
    var newFrame:CGRect=CGRect()
    var Firstindexpath:IndexPath = IndexPath()
    var isForwardAction:Bool = Bool()
    var isShowBottomView:Bool = Bool()
    var isReplyMessage:Bool = Bool()
    var isKeyboardShown:Bool = Bool()
    var isBeginEditing:Bool = Bool()
    var ReplyMessageRecord:UUMessageFrame = UUMessageFrame()
    var selectedAssets = [DKAsset]()
    var audioPlayBtn : UIButton?
    
    @IBOutlet weak var link_bottom: NSLayoutConstraint!
    @IBOutlet weak var link_view: URLEmbeddedView!
    
    var toChat: String = ""
    var isBlocked: Bool = false
    var keyboardHeight: Float = 0.0
    var chatType: String = "single"
    var convoId: String = ""
    var fromName: String = ""
    var fullUrl :String = ""
    var blockByMe = 0
    var blockByUser = 0
    var istartTyping:Bool = false
    var typingTimer:Timer?
    var fromLastTypedAt:UInt64 = 0
    let timeSize = 2
    var isFromMall = false
    var pageNumber = 1
    var pageLimit = 20
    var totalPages = 0
    var isDataLoading = false
    var onlineStatus = ""
    var selectedIndex = 0
    var requestedUser = 1
    
    private  lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemBlue
        return refreshControl
    }()
    
    
    var chatHistory:NSMutableArray = NSMutableArray()
    
    //MARK: - Controller  Lifecycles
    override func viewDidLoad() {
        print("ViewController: FeedChatVC")
        super.viewDidLoad()
        
        //
        //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //        let ObjInitiateChatViewController:InitiateChatViewController=storyboard.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
        //        ObjInitiateChatViewController.Chat_type="single"
        //        ObjInitiateChatViewController.opponent_id = "9015946133"
        //        self.navigationController?.pushView(ObjInitiateChatViewController, animated: true)
        
        
        
        self.onlineView.isHidden = true
        self.lblStatus.text = ""
        if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected)
        {
            SocketIOManager.sharedInstance.establishConnection(Nickname: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()) as NSString, isLogin: true)
        }
        
        tblChat.register(UINib(nibName: "ChatInfoCell", bundle: nil), forCellReuseIdentifier: "ChatInfoCell")
        tblChat.register(UINib(nibName: "EncryptionTableViewCell", bundle: nil), forCellReuseIdentifier: "EncryptionTableViewCell")
        self.tblChat.isHidden = false
        tblChat.registerCell()
        updateUserInfo()
        addNotificationListener()
        self.emitChatHistory()
        onlineView.layer.cornerRadius = onlineView.frame.size.height/2.0
        onlineView.clipsToBounds = true
        self.onlineView.backgroundColor = UIColor.lightGray
        self.lblStatus.text = "Offline"
        self.tblChat.refreshControl = self.topRefreshControl
        let params = ["from":Themes.sharedInstance.Getuser_id(),"status":"1"]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sc_change_status, params)
        
        
        UpdateUI()
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else{ return }
            weak.keyboardChangeShow(notify)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else{ return }
            weak.keyboardChangeHide(notify)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.checkOnlineSttaus()
        Themes.sharedInstance.chattingUSerId = toChat
        emitFetchUserInfo()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Themes.sharedInstance.chattingUSerId = ""
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //NotificationCenter.default.removeObserver(self)
        typingTimer?.invalidate()
    }
    
    
    
    deinit {
        removeNotificationListener()
    }
    
    
    //MARK: Pull Down refresh
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
        
        if !isDataLoading {
            isDataLoading = true
            if pageNumber <= totalPages {
                pageNumber = pageNumber + 1
                self.emitChatHistory()
            }
        }
        refreshControl.endRefreshing()
    }
    
    //MARK: Emit chat History
    
    func emitDeleteChat(messageIds:[String]){
        //
        //        let params = ["from":Themes.sharedInstance.Getuser_id(),"mssgid": messageIds,"deleteFlag":1] as NSDictionary
        //        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.delete_chats, params)
        
        
        let params = ["authToken":Themes.sharedInstance.getAuthToken(),"type": 1,"messageIds":messageIds] as NSDictionary
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_feed_delete_user_chat, params)
    }
    
    func emitDeleteChatFromBoth(messageIds:[String]){
        let params = ["authToken":Themes.sharedInstance.getAuthToken(),"type": 0,"receiverId":toChat,"messageIds":messageIds] as NSDictionary
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_feed_delete_user_chat, params)
    }
    
    
    func emitFetchUserInfo(){
        let params = ["authToken":Themes.sharedInstance.getAuthToken(),"receiverId": toChat] as NSDictionary
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_fetch_user_info, params)
    }
    
    func emitClearChat(){
        let params = ["authToken":Themes.sharedInstance.getAuthToken(),"fcrId": convoId] as NSDictionary
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_feed_clear_user_chat_list, params)
    }
    
    
    func emitAcknowledgeChat(){
        let params = ["authToken":Themes.sharedInstance.getAuthToken(),"receiverId": toChat,"fcrId":convoId] as NSDictionary
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_feed_chat_acknowledge_chat, params)
    }
    
    
    func checkOnlineSttaus(){
        
        let params = ["authToken":Themes.sharedInstance.getAuthToken(),"userId": toChat] as NSDictionary
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sc_fetch_online_status, params)
        
    }
    func emitChatHistory(){
    
        let params1 = ["authToken":Themes.sharedInstance.getAuthToken(),"fcrId":convoId,"receiverId":toChat,"pageLimit":pageLimit, "pageNumber":pageNumber] as [String : Any]
        SocketIOManager.sharedInstance.emitChaWithCallBack(params: params1 as NSDictionary, eventName: Constant.sharedinstance.sio_feed_fetch_user_chat_list)
    }
    
 
    func emitAcceptChatRequest(){
        let params1 = ["authToken":Themes.sharedInstance.getAuthToken(),"receiverId":toChat,"fcrId":convoId] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_feed_accept_chat_request, params1)
    }
    
    
    
    //MARK: - Notification servers
    
    @objc func socketConnected(notification: Notification) {
        
        if self.chatHistory.count == 0{
            self.emitChatHistory()
            
            let params = ["from":Themes.sharedInstance.Getuser_id(),"status":"1"]
            SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sc_change_status, params)
            
        }
        
        self.checkOnlineSttaus()
    }
    
    @objc func onlineOfflineStatus(notification: Notification) {
        
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            
            if let onlineStatusDict = response["onlineStatus"] as? NSDictionary{
                
                if toChat == onlineStatusDict["_id"] as? String ?? "" {
                    let status = onlineStatusDict["online_offline_status"] as? Int ?? 0
                    
                    if status == 1{
                        self.onlineView.backgroundColor = UIColor.green
                        self.onlineStatus = "Online"
                    }else{
                        self.onlineView.backgroundColor = UIColor.lightGray
                        self.onlineStatus = "Offline"
                    }
                    self.lblStatus.text = onlineStatus
                }
            }
        }
    }
    
    @objc func socketError(notification: Notification){
        
        Themes.sharedInstance.RemoveactivityView(View: self.view)
    }
    

    
   
    
    
    @objc func refreshFeedChatDetail(notification: Notification){
        
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            
            let status = response["status"] as? Int ?? 0
            self.totalPages = response["totalPages"] as? Int ?? 0
            self.isDataLoading = false
            
            if status == 1{
                
                if pageNumber == 1{
                    
                }
                let newChatModel = NSMutableArray()
                
                if let payloadArray = response["payload"] as? Array<NSDictionary>{
                    for dict in payloadArray{
                        newChatModel.add(returnNewMessageFrame(msg: ChatHIstory(respDict: dict)))
                    }
                }
                
                //old dates objects used to show the date
                for msg in chatHistory{
                    if (msg as! UUMessageFrame).message.info_type == "10" || (msg as! UUMessageFrame).message.info_type == "72"{
                        chatHistory.remove(msg)
                    }
                }
                
                let oldCount = chatHistory.count
                
                for obj in chatHistory{
                    newChatModel.add(obj)
                }
                chatHistory = newChatModel
                
                self.tblChat.reloadData()
                
                if chatHistory.count > 0 {
                    if pageNumber == 1{
                        self.reorderingMessage(pageNo: pageNumber, oldCount: 0)
                    }else{
                        self.reorderingMessage(pageNo: pageNumber, oldCount: oldCount)
                    }
                }
            }
            
            /*
             var chatResponse =  FeedChatResponse()
             chatResponse.deserilize(values: response)
             
             self.totalPages = chatResponse.totalPages
             
             if self.pageNumber == 0 {
             self.blockByMe = chatResponse.blockByMe
             self.blockByUser = chatResponse.blockByUser
             if isFromMall{
             
             }else{
             self.fromName = chatResponse.fromName
             self.fullUrl = chatResponse.userProfileImage
             }
             self.setUI()
             self.setBlockAction()
             }
             self.chatList = chatResponse.chatDetails.chatMessages
             
             self.isDataLoading = false
             
             let newChatModel = NSMutableArray()
             for msg in chatList{
             newChatModel.add(returnMessageFrame(msg: msg))
             if convoId.length == 0{
             self.convoId = msg.convoId
             }
             }
             
             //old dates objects used to show the date
             for obj in chatModel.dataSource{
             if (obj as! UUMessageFrame).message.info_type == "10" || (obj as! UUMessageFrame).message.info_type == "72"{
             chatModel.dataSource.remove(obj)
             }
             }
             
             let oldCount = chatModel.dataSource.count
             
             for obj in chatModel.dataSource{
             newChatModel.add(obj)
             }
             chatModel.dataSource = newChatModel
             
             self.tblChat.reloadData()
             
             if chatModel.dataSource.count > 0 {
             if pageNumber == 0{
             self.reorderingMessage(pageNo: pageNumber, oldCount: 0)
             }else{
             self.reorderingMessage(pageNo: pageNumber, oldCount: oldCount)
             }
             }
             */
        }
        
        if chatHistory.count == 0{
            
            let dict:[String: String] = ["type": "0","convId":"","doc_id":"","filesize":"","from":""
                                         ,"to":"","isStar":"","message_status":"","id":"","name":"","payload":"","recordId":"","timestamp":"\(Date.timeStamp*1000)","thumbnail":"","width":"0.0","height":"0.0","msgId":""
                                         ,"contactmsisdn":"","user_common_id":"","message_from":"","chat_type":"","info_type":"72","created_by":""]
            
            self.chatHistory.add(self.returnMessageFrame(dict: dict, type: MessageType.UUMessageTypeText))
            
            
            let dict2:[String: String] = ["type": "0","convId":"","doc_id":"","filesize":"","from":""
                                          ,"to":"","isStar":"","message_status":"","id":"","name":"","payload":"","recordId":"","timestamp":"\(Date.timeStamp*1000)","thumbnail":"","width":"0.0","height":"0.0","msgId":""
                                          ,"contactmsisdn":"","user_common_id":"","message_from":"","chat_type":"","info_type":"10","created_by":""]
            
            self.chatHistory.add(self.returnMessageFrame(dict: dict2, type: MessageType.UUMessageTypeText))
            
            self.tblChat.reloadData()
            
        }
    }
    
    
    
    func scrollToLastRow() {
        
        if chatHistory.count > 0 {
            let indexPath = NSIndexPath(row: chatHistory.count - 1, section: 0)
            self.tblChat.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
        }
        
    }
    
    
    /*  @objc func refreshFeedChatDetail(notification: Notification) {
     
     if  let response = notification.userInfo as? Dictionary<String, Any> {
     print(response)
     //let resultDict = response["result"] as? Dictionary<String, Any>
     var chatResponse =  FeedChatResponse()
     chatResponse.deserilize(values: response)
     
     self.blockByMe = chatResponse.blockByMe
     self.blockByUser = chatResponse.blockByUser
     if isFromMall{
     
     }else{
     self.fromName = chatResponse.fromName
     self.fullUrl = chatResponse.userProfileImage
     }
     self.chatList = chatResponse.chatDetails.chatMessages
     
     self.setChatModel()
     //  self.isBlocked = (response?.chatDetails.isBlock ?? 0).boolValue
     self.setUI()
     self.setBlockAction()
     
     if self.chatList.count > 0{
     if let obj = self.chatList.last{
     
     let msgId: Int64 = Int64(obj.id) ?? 0
     //
     //                    SocketIOManager.sharedInstance.AcknowledegmentFeedChatHandler(from: Themes.sharedInstance.Getuser_id(), to:toch , status: "3", doc_id: obj.docId, msgIds: [msgId], chat_type: "single", convId: obj.convoId, recordId: [obj.convoId])
     
     }
     }
     }
     }
     
     */
    /*@objc func sendMsgAcknowledgement(notification: Notification) {
     if  let response = notification.userInfo as? Dictionary<String, Any> {
     print("Message Delivered: ",response)
     }
     }*/
    
    
    //MARK: UIBUtton Action Methods
    
    @IBAction func acceptBtnAction(){
        self.emitAcceptChatRequest()
    }
    
    @IBAction func deleteBtnAction(){
        
        self.emitClearChat()
    }
    
    @IBAction func blockBtnAction(){
        openBlockConfirmation()
    }
    
    
    @IBAction func profileBtnAction(){
        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.otherMsIsdn = toChat
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.removeNotificationListener()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnMoreOptions(_ sender: UIButton) {
        openMoreOptions()
    }
    
    //MARK: - Userdefined Functions
    func updateUserInfo() {
        imgListing.kf.setImage(with: URL(string: fullUrl), placeholder: UIImage(named: "avatar")!, options: [.fromMemoryCacheOrRefresh], progressBlock: nil) { response in}
        lblName.text = fromName
        if blockByMe == 1 || blockByUser == 1 {
            self.lblStatus.isHidden = true
            self.onlineView.isHidden = true
            lytTableBottom.constant = 20
            let msg = (blockByUser == 1) ? "User has blocked you" : "you've blocked this user"
            btnBlockedUser.setTitle(msg, for: .normal)
            btnBlockedUser.isHidden = false
            self.cnstr_BlockUserVwHeigHt.constant = 25
            self.onlineView.isHidden = true
            self.lblStatus.text = ""
            IFView?.isHidden = true
        }else{
            self.onlineView.isHidden = false
            self.lblStatus.isHidden = false
            self.onlineView.isHidden = false
            self.cnstr_BlockUserVwHeigHt.constant = 0
            btnBlockedUser.isHidden = true
            IFView?.isHidden = false
            
        }
        
        if requestedUser == 0{
            self.view.addSubview(self.bgVwAcceptRejectChat)
            self.bgVwAcceptRejectChat.isHidden = false
        }else{
            self.bgVwAcceptRejectChat.isHidden = true
        }
    }
    
    
    
   
    
    func setChatModel(){
        /*
         chath = chatList.sorted(by: {$0.timestamp < $1.timestamp})
         for msg in chatList{
         chatModel.dataSource.add(returnMessageFrame(msg: msg))
         }
         
         //  let filteredUnseenMsg = (chatList.filter{$0.status == "2" || $0.status == "1"}).map{Int64($0.id)}
         
         let filteredUnseenMsg = (chatList.filter{$0.status == "2" || $0.status == "1"}).map{Int64($0.id)}
         
         let filteredUnseenMsgDocId = (chatList.filter{$0.status == "2" || $0.status == "1"}).map{$0.docId}
         
         //  let filteredUnseenMsgRecordId = (chatList.filter{$0.status == "2" || $0.status == "1"}).map{$0.recordID}
         
         
         //  setChatUpdates(filteredUnseenMsg, docId: filteredUnseenMsgDocId,recordId:[String]())
         tblChat.reloadData()
         // //self.tableViewScrollToBottom()
         self.setTail(isAtBottom: true)
         // reordering()
         tableViewScrollToBottom()
         */
    }
    
    
    func reorderingMessage(pageNo:Int,oldCount:Int)
    {
        
        DispatchQueue.main.async {
            //        let messageFrame = (self.chatHistory[0] as! UUMessageFrame)
            let messageFrame = (self.chatHistory[0] as! UUMessageFrame)
            
            var timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.timestamp)
            
            
            var orderingArr = [UUMessageFrame]()
            _ = (self.chatHistory as! [UUMessageFrame]).map {
                
                if(orderingArr.count > 0)
                {
                    
                    
                    if(timestamp != "")
                    {
                        let presenttimestamp:String =  Themes.sharedInstance.CheckNullvalue(Passed_value: $0.message.timestamp)
                        let Prevdate:Date = Themes.sharedInstance.ConverttimeStamptodateentity(timestamp: timestamp) as Date
                        let Presentdate:Date = Themes.sharedInstance.ConverttimeStamptodateentity(timestamp: presenttimestamp) as Date
                        var components:Int! = Themes.sharedInstance.ReturnNumberofDays(fromdate:Prevdate , todate: Presentdate)
                        if(components == 0)
                        {
                            if(!Calendar.current.isDate(Prevdate, inSameDayAs: Presentdate))
                            {
                                components = 1
                            }
                        }
                        if components != 0 {
                            let dict:[String: String] = ["type": "0","convId":"","doc_id":"","filesize":"","from":""
                                                         ,"to":"","isStar":"","message_status":"","id":"","name":"","payload":"","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:$0.message.timestamp),"thumbnail":"","width":"0.0","height":"0.0","msgId":""
                                                         ,"contactmsisdn":"","user_common_id":"","message_from":"","chat_type":"","info_type":"10","created_by":""]
                            orderingArr.append(self.returnMessageFrame(dict: dict, type: MessageType.UUMessageTypeText))
                            
                        }
                        
                        
                        timestamp = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.message.timestamp)
                        
                    }
                    
                }
                else
                {
                    
                    let dict:[String: String] = ["type": "0","convId":"","doc_id":"","filesize":"","from":""
                                                 ,"to":"","isStar":"","message_status":"","id":"","name":"","payload":"","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:$0.message.timestamp),"thumbnail":"","width":"0.0","height":"0.0","msgId":""
                                                 ,"contactmsisdn":"","user_common_id":"","message_from":"","chat_type":"","info_type":"10","created_by":""]
                    
                    orderingArr.append(self.returnMessageFrame(dict: dict, type: MessageType.UUMessageTypeText))
                    
                }
                orderingArr.append($0)
            }
            
            
            
            let dict:[String: String] = ["type": "0","convId":"","doc_id":"","filesize":"","from":""
                                         ,"to":"","isStar":"","message_status":"","id":"","name":"","payload":"","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:messageFrame.message.timestamp),"thumbnail":"","width":"0.0","height":"0.0","msgId":""
                                         ,"contactmsisdn":"","user_common_id":"","message_from":"","chat_type":"","info_type":"72","created_by":""]
            
            orderingArr.insert(self.returnMessageFrame(dict: dict, type: MessageType.UUMessageTypeText), at: 0)
            
            //            self.chatHistory.removeAllObjects()
            //            self.chatHistory.addObjects(from: orderingArr)
            
            self.chatHistory.removeAllObjects()
            self.chatHistory.addObjects(from: orderingArr)
            self.tblChat.reloadData()
            self.setTail(isAtBottom: true)
            
            if pageNo == 1{
                self.tableViewScrollToBottom()
            }else{
                // self.tableViewScrollToBottom()
                // self.scrollToLastRow()
            }
        }
    }
    
    
    
    
    /*
     func reordering()
     {
     var orderingArr = [UUMessageFrame]()
     _ = (self.chatHistory as! [UUMessageFrame]).map {
     if(orderingArr.count > 0)
     {
     let messageFrame = orderingArr[orderingArr.count - 1]
     let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.timestamp)
     if(timestamp != "")
     {
     let presenttimestamp:String =  Themes.sharedInstance.CheckNullvalue(Passed_value: $0.message.timestamp)
     let Prevdate:Date = Themes.sharedInstance.ConverttimeStamptodateentity(timestamp: timestamp) as Date
     let Presentdate:Date = Themes.sharedInstance.ConverttimeStamptodateentity(timestamp: presenttimestamp) as Date
     var components:Int! = Themes.sharedInstance.ReturnNumberofDays(fromdate:Prevdate , todate: Presentdate)
     if(components == 0)
     {
     if(!Calendar.current.isDate(Prevdate, inSameDayAs: Presentdate))
     {
     components = 1
     }
     }
     if components != 0 {
     let dict:[String: String] = ["type": "0","convId":"","doc_id":"","filesize":"","from":""
     ,"to":"","isStar":"","message_status":"","id":"","name":"","payload":"","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:$0.message.timestamp),"thumbnail":"","width":"0.0","height":"0.0","msgId":""
     ,"contactmsisdn":"","user_common_id":"","message_from":"","chat_type":"","info_type":"10","created_by":""]
     orderingArr.append(self.returnMessageFrame(dict: dict, type: MessageType.UUMessageTypeText))
     
     }
     }
     
     }
     else
     {
     let dict:[String: String] = ["type": "0","convId":"","doc_id":"","filesize":"","from":""
     ,"to":"","isStar":"","message_status":"","id":"","name":"","payload":"","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:$0.message.timestamp),"thumbnail":"","width":"0.0","height":"0.0","msgId":""
     ,"contactmsisdn":"","user_common_id":"","message_from":"","chat_type":"","info_type":"10","created_by":""]
     
     orderingArr.append(self.returnMessageFrame(dict: dict, type: MessageType.UUMessageTypeText))
     }
     orderingArr.append($0)
     }
     
     self.chatHistory.removeAllObjects()
     self.chatHistory.addObjects(from: orderingArr)
     
     var j = 0
     var arr = [IndexPath]()
     for _ in self.tblChat.numberOfRows(inSection: 0)-1..<self.chatHistory.count-1 {
     arr.append(IndexPath(row: j, section: 0))
     j += 1
     }
     self.tblChat.reloadData()
     }
     
     */
    
    func returnMessageFrame(dict : [String : String], type : MessageType) -> UUMessageFrame
    {
        let newmessageFrame = UUMessageFrame()
        let message = UUMessage()
        message.type = type;
        message.strContent = dict["payload"];
        message.conv_id = dict["convId"];
        message.doc_id = dict["doc_id"];
        message.filesize = dict["filesize"];
        message.user_from = dict["from"];
        message.isStar = dict["isStar"];
        message.message_status = dict["message_status"];
        message.msgId = dict["msgId"];
        message.name = dict["name"];
        message.payload = dict["payload"];
        message.recordId = dict["recordId"];
        message.thumbnail = dict["thumbnail"];
        message.timestamp = dict["timestamp"];
        message.to = dict["to"];
        message.width = dict["width"];
        message.height = dict["height"];
        message.chat_type = dict["chat_type"];
        message.info_type = dict["info_type"];
        message._id = dict["id"];
        message.contactmsisdn = dict["contactmsisdn"];
        message.progress = "0.0";
        message.message_type = dict["type"];
        message.user_common_id = dict["user_common_id"];
        message.imagelink = "";
        message.latitude = "";
        message.longitude = "";
        message.title_place = "";
        message.stitle_place = "";
        message.is_deleted = dict["is_deleted"];
        message.reply_type = dict["reply_type"];
        newmessageFrame.message = message
        return newmessageFrame
    }
    
    func setTail(isAtBottom:Bool){
        guard self.chatHistory.count > 1 else{
            if chatHistory.count == 1, let newMessage = chatHistory.lastObject as? UUMessageFrame{
                newMessage.message.isLastMessage = true
            }
            return}
        if isAtBottom{
            guard let lastMessage = self.chatHistory.lastObject as? UUMessageFrame else{return}
            guard let previousMessage = self.chatHistory[self.chatHistory.count-2] as? UUMessageFrame else{return}
            
            lastMessage.message.isLastMessage = true
            previousMessage.message.isLastMessage = !(previousMessage.message.from == lastMessage.message.from)
            
            guard tblChat.numberOfRows(inSection: 0) > 1 else{return}
            let lastCell = tblChat.cellForRow(at: IndexPath(row: tblChat.numberOfRows(inSection: 0)-1, section: 0))
            let previousCell = tblChat.cellForRow(at: IndexPath(row: tblChat.numberOfRows(inSection: 0)-2, section: 0))
            
            (lastCell as? CustomTableViewCell)?.bubleImage = (lastMessage.message.from == MessageFrom(rawValue: 1)) ? "inBubble" : "outBubble"
            
            (previousCell as? CustomTableViewCell)?.bubleImage = (previousMessage.message.from == MessageFrom(rawValue: 1)) ? "inBubble" : "outBubble"
        }else{
            guard let newMessage = self.chatHistory.firstObject as? UUMessageFrame else{return}
            guard let previousMessage = self.chatHistory[1] as? UUMessageFrame else{return}
            newMessage.message.isLastMessage = !(newMessage.message.from.rawValue == previousMessage.message.from.rawValue)
            
        }
    }
}



extension FeedChatVC:UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.length > 0{
            let params = ["authToken":Themes.sharedInstance.getAuthToken(),"fcrId":convoId,"receiverId":toChat,"senderId":Themes.sharedInstance.Getuser_id(), "typing":true] as [String : Any]
            SocketIOManager.sharedInstance.emitChaWithCallBack(params: params as NSDictionary, eventName: Constant.sharedinstance.sio_feed_chat_typing)
            // SocketIOManager.sharedInstance.emitTypingStatus(from: Themes.sharedInstance.Getuser_id(), to: toChat, convId: convoId, type: "single")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let params = ["authToken":Themes.sharedInstance.getAuthToken(),"fcrId":convoId,"receiverId":toChat,"senderId":Themes.sharedInstance.Getuser_id(), "typing":false] as [String : Any]
        SocketIOManager.sharedInstance.emitChaWithCallBack(params: params as NSDictionary, eventName: Constant.sharedinstance.sio_feed_chat_typing)
    }
    
    
    private func actionSheetIndex(_ index: Int) {
        if(index == 0)
        {
            let pickerController = DKImagePickerController()
            pickerController.maxSelectableCount = 4
            pickerController.assetType = .allPhotos
            pickerController.sourceType = .camera
            pickerController.didSelectAssets = { (assets: [DKAsset]) in
                
                if(assets.count > 0)
                {
                    self.selectedAssets = assets
                    Themes.sharedInstance.activityView(View: self.view)
                    AssetHandler.sharedInstance.isgroup = false
                    
                    AssetHandler.sharedInstance.ProcessAsset(assets: [assets[0]],oppenentID: self.toChat,isFromStatus: false, completionHandler: {[weak self]
                        (AssetArr, error) -> ()? in
                        
                        if((AssetArr?.count)! > 0)
                        {
                            DispatchQueue.main.async {
                                Themes.sharedInstance.RemoveactivityView(View: (self?.view)!)
                                
                                let EditVC = StoryBoard.main.instantiateViewController(withIdentifier: "EditViewControllerID") as! EditViewController
                                EditVC.AssetArr = AssetArr!
                                EditVC.isVideoData = false
                                EditVC.isfromStatus = false
                                EditVC.Delegate = self
                                EditVC.selectedAssets = (self?.selectedAssets)!
                                EditVC.isgroup = AssetHandler.sharedInstance.isgroup
                                EditVC.to_id = self!.toChat
                                self?.pushView(EditVC, animated: true)
                                
                            }
                        }
                        return ()
                    })
                }
                
            }
            self.presentView(pickerController, animated: true)
        }
        else if(index == 1)
        {
            
            let pickerController = DKImagePickerController()
            pickerController.singleSelect = true
            pickerController.assetType = .allAssets
            pickerController.sourceType = .photo
            pickerController.isFromChat = true
            pickerController.didSelectAssets = { (assets: [DKAsset]) in
                if(assets.count > 0)
                {
                    
                    self.selectedAssets = assets
                    Themes.sharedInstance.activityView(View: self.view)
                    
                    AssetHandler.sharedInstance.isgroup = false
                    
                    
                    AssetHandler.sharedInstance.ProcessAsset(assets: assets,oppenentID: self.toChat,isFromStatus: false, completionHandler: { [weak self] (AssetArr, error) -> ()? in
                        if((AssetArr?.count)! > 0)
                        {     DispatchQueue.main.async {
                            Themes.sharedInstance.RemoveactivityView(View: (self?.view)!)
                            let EditVC = StoryBoard.main.instantiateViewController(withIdentifier: "EditViewControllerID") as! EditViewController
                            EditVC.AssetArr = AssetArr!
                            EditVC.isfromStatus = false
                            EditVC.Delegate = self
                            EditVC.selectedAssets = (self?.selectedAssets)!
                            EditVC.isgroup = AssetHandler.sharedInstance.isgroup
                            EditVC.to_id = self!.toChat
                            self?.pushView(EditVC, animated: true)
                        }
                        }
                        return ()
                    })
                    
                }
            }
            pickerController.didClickGif = {
                let picker = SwiftyGiphyViewController()
                picker.delegate = self
                let navigation = UINavigationController(rootViewController: picker)
                self.presentView(navigation, animated: true)
                
            }
            self.presentView(pickerController, animated: true)
        }
        else if(index == 2)
        {
            self.PresentDocumentPicker()
        }
        else if(index == 3)
        {
            //Share Location
            let mapVC = StoryBoard.main.instantiateViewController(withIdentifier: "MapViewViewController") as! MapViewViewController
            mapVC.delegate = self
            
            self.pushView(mapVC,animated: true)
        }else if(index == 4)
        {
            //            let CheckFav:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
            //
            //            if(CheckFav)
            //            {
            
            let contactVC = StoryBoard.main.instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController
            if let exampleType = ExampleType(rawValue: "comparison") {
                contactVC.example = exampleByType(exampleType)
            }
            //                if(self.Chat_type == "group"){
            //                    contactVC.is_from_group = true
            //                }
            //                contactVC.oppponent_id = opponent_id
            contactVC.delegate = self
            
            self.pushView(contactVC, animated: true)
            
            //            }
            //
            //            else
            //
            //            {
            //                Themes.sharedInstance.jssAlertView(viewController: self, title: Themes.sharedInstance.GetAppname(), text: "No Contact kindly invite friends", buttonTxt: "Ok", color: CustomColor.sharedInstance.themeColor)
            //            }
        }
    }
    
    
    func PresentDocumentPicker() {
        let importMenu = UIDocumentPickerViewController(documentTypes: ["public.text", "public.data","public.pdf", "public.doc"], in: .import)
        importMenu.delegate = self
        self.presentView(importMenu, animated: true)
    }
    
}


extension FeedChatVC:MapViewViewControllerDelegate,SwiftyGiphyViewControllerDelegate,contactShare,EditViewControllerDelegate{

    func removeFiles(fileUrl:URL?){
        do {
            if let url = fileUrl {
                if FileManager.default.fileExists(atPath: (url.path)) {
                    try FileManager.default.removeItem(at: url)
                    print(" Image DEleted")
                }
            }
        } catch let err as NSError {
            print("Not able to remove\(err)")
        }
    }
    
    func EdittedImage(AssetArr:NSMutableArray,Status:String){
        
        if(AssetArr.count > 0)
        {
            _ = AssetArr.map {
                let ObjMultiMedia:MultimediaRecord = $0 as! MultimediaRecord
               
                self.uploadMedia(objRecord: ObjMultiMedia)
               /* if(!ObjMultiMedia.isVideo){
                    
                }else{
                    
                }*/
            }
        }
    }
    
  
    
    func uploadMedia(objRecord:MultimediaRecord){
        var fileURL:URL?
        do {

            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            fileURL = documentsDirectory.appendingPathComponent(objRecord.assetname)
            
            do {
                
                let params = [String:Any]()
                
                var strMime = ""
                
                if (objRecord.isVideo){
                    try (objRecord.isVideo) ? objRecord.rawData.write(to: fileURL!) : objRecord.CompresssedData.write(to: fileURL!)

                     strMime = "video/*"
                }else  if (objRecord.isGif){
                    strMime = "image/gif"
                    try  objRecord.rawData.write(to: fileURL!)
                }else{
                    strMime = "image/*"
                    try  objRecord.CompresssedData.write(to: fileURL!)

                }
                
                URLhandler.sharedinstance.uploadMedia(fileName: objRecord.assetname, param: params as [String : AnyObject], file:fileURL! , url: Constant.sharedinstance.uploadFeedMedia, mimeType:strMime){
                    (msg,status,url, thumbUrl) in
                    
                    print(msg,status,url,thumbUrl)
                    self.removeFiles(fileUrl: fileURL)
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                    
                    if status == "1"{
                        
                        self.sendMediaToSocket(mainUrl: url, thumbUrl: thumbUrl, caption: objRecord.caption)
                        
                    }else {
                        
                    }
                }
            } catch {
                print("error saving file to documents:", error)
            }
        }catch {
            print("error saving file to documents:", error)
        }
        
    }
    
    
    func sendMediaToSocket(mainUrl:String,thumbUrl:String,caption:String){
        
        var params = [String : Any]()
        
        params["authToken"] = Themes.sharedInstance.getAuthToken()
        params["fcrId"] = convoId
        params["receiverId"] = toChat
        
        let timeStamp = Date.timeStamp*1000
        let docId = "\(Themes.sharedInstance.Getuser_id())-\(toChat)-\(timeStamp)"
        params["messageDocId"] = docId
        
        
        /* 0-Text, 1-Media (Image,video,GIF, Document), 2-Link, 3-Contact, 4-Location,*/
        params["payload"] = caption.trimmingCharacters(in: .whitespaces)
        params["type"] = 1
        
        var mediaDict = [String : Any]()
        mediaDict["url"] = mainUrl
        mediaDict["thumbUrl"] = thumbUrl
        params["media"] = [mediaDict]

        addOutgoingMediaMessage(caption, timeStamp, type: 1, url: mainUrl, thumbUrl: thumbUrl)
        SocketIOManager.sharedInstance.emitChaWithCallBack(params: params as NSDictionary, eventName: Constant.sharedinstance.sio_feed_send_chat_message)
        
    }

    //Contact Share
    func share(rec:NSMutableArray){
        
        print("rec == \(rec)")
        
        if let obj = rec.firstObject as? FavRecord {
            
            var params = [String : Any]()
            
            params["authToken"] = Themes.sharedInstance.getAuthToken()
            params["fcrId"] = convoId
            params["receiverId"] = toChat
           
            let timeStamp = Date.timeStamp*1000
            let docId = "\(Themes.sharedInstance.Getuser_id())-\(toChat)-\(timeStamp)"
            params["messageDocId"] = docId
           
            params["type"] = 3
            
             var paloadDict = [String : Any]()
             paloadDict["name"] = obj.name
             paloadDict["mobileNumber"] = obj.phnumber
             params["contactDetails"] = paloadDict
            
            SocketIOManager.sharedInstance.emitChaWithCallBack(params: params as NSDictionary, eventName: Constant.sharedinstance.sio_feed_send_chat_message)
            addOutgoingContact(payload: "", timestamp: timeStamp, type: 3, name: obj.name, mobileno: obj.phnumber)
        }
    }
    
    func setBool(view:Bool){
        
    }
    
    //Location
    func isLocation(location:Bool)
    {
       // locationR = location
        
    }
    
    func coordinate(latitude:CLLocationDegrees,longitude:CLLocationDegrees,title:String,display:String,subTitle:String)
    {
        
        let imagelink:String = "https://maps.googleapis.com/maps/api/staticmap?center=\(latitude),\(longitude)&zoom=15&size=300x300&maptype=roadmap&key=\(Constant.sharedinstance.GoogleMapKey)&markers=color:red%7Clabel:N%7C\(latitude),\(longitude)"
        let RedirectLink:String = "https://maps.google.com/maps?q=\(latitude),\(longitude)&amp;z=15&amp;hl=en"
        var params = [String : Any]()
        params["authToken"] = Themes.sharedInstance.getAuthToken()
        params["fcrId"] = convoId
        params["receiverId"] = toChat
        
        let timeStamp = Date.timeStamp*1000
        let docId = "\(Themes.sharedInstance.Getuser_id())-\(toChat)-\(timeStamp)"
        params["messageDocId"] = docId
        params["type"] = 4
        
        var paloadDict = [String : Any]()
        paloadDict["image"] = imagelink
        paloadDict["description"] = subTitle
        paloadDict["title"] = title
        paloadDict["link"] = RedirectLink
        paloadDict["latitude"] = "\(latitude)"
        paloadDict["longitude"] = "\(longitude)"
        params["location"] = paloadDict
            
        addOutgoingLocation(payload: "", timestamp: timeStamp, type: 4, title: title, subTitle: subTitle, redirectLink: RedirectLink, imagelink: imagelink, lat: latitude, long: longitude)
        SocketIOManager.sharedInstance.emitChaWithCallBack(params: params as NSDictionary, eventName: Constant.sharedinstance.sio_feed_send_chat_message)
        
    }

//GIF
    func giphyControllerDidSelectGif(controller: SwiftyGiphyViewController, item: GiphyItem){
        self.dismissView(animated: true, completion: {
            Themes.sharedInstance.showprogressAlert(controller: self)
            var url : URL?
            if(item.downsizedImage != nil)
            {
                url = item.downsizedImage?.url
            }
            else if(item.fixedHeightImage != nil)
            {
                url = item.fixedHeightImage?.url
            }
            else
            {
                url = item.originalImage?.url
            }
            
            SDWebImageDownloader.shared().downloadImage(with: url, options: .highPriority, progress: { (received, total, url) in
                DispatchQueue.main.async {
                    if(received != total)
                    {
                        Themes.sharedInstance.setprogressinAlert(controller: self, progress: Float(received) / Float(total), completionHandler: nil)
                    }
                }
            }) { (image, data, error, success) in
                if(error == nil)
                {
                    DispatchQueue.main.async {
                        Themes.sharedInstance.setprogressinAlert(controller: self, progress: 1.0, completionHandler: {
                            
                            Filemanager.sharedinstance.CreateFolder(foldername: "Temp")
                            
                            var timestamp:String = String(Date().ticks)
                            var servertimeStr:String = Themes.sharedInstance.getServerTime()
                            
                            if(servertimeStr == "")
                            {
                                servertimeStr = "0"
                            }
                            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                            timestamp =  "\((timestamp as NSString).longLongValue + Int64(0) - serverTimestamp)"
                            
                            
                            let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                            let to = Themes.sharedInstance.CheckNullvalue(Passed_value: self.toChat)
                            
                            let User_chat_id = from + "-" + to;
                            
                            let url = Filemanager.sharedinstance.SaveImageFile(imagePath: "Temp/\(timestamp).gif", imagedata: data!)
                            
                            let ObjMultiRecord:MultimediaRecord = MultimediaRecord()
                            
                            let Pathextension:String = "GIF"
                           
                            ObjMultiRecord.assetname = "\(User_chat_id)-\(timestamp).\(Pathextension.lowercased())"
                            
                            ObjMultiRecord.timestamp = timestamp
                            ObjMultiRecord.userCommonID = User_chat_id
                            ObjMultiRecord.assetpathname = url
                            ObjMultiRecord.toID = to
                            ObjMultiRecord.isVideo = false
                            ObjMultiRecord.StartTime = 0.0
                            ObjMultiRecord.Endtime = 0.0
                            ObjMultiRecord.Thumbnail = image
                            ObjMultiRecord.rawData = data
                            ObjMultiRecord.isGif = true
                            
                            ObjMultiRecord.CompresssedData = image!.jpegData(compressionQuality: 0.1)
                            ObjMultiRecord.Base64Str = Themes.sharedInstance.convertImageToBase64(imageData:ObjMultiRecord.CompresssedData)
                            
                            Filemanager.sharedinstance.DeleteFile(foldername: "Temp/\(timestamp).gif")
                            
                            let EditVC = StoryBoard.main.instantiateViewController(withIdentifier: "EditViewControllerID") as! EditViewController
                            EditVC.AssetArr = NSMutableArray.init(array: [ObjMultiRecord])
                            EditVC.isfromStatus = false
                            EditVC.Delegate = self
                            EditVC.selectedAssets = []
                            EditVC.isgroup =  false
                            EditVC.to_id = self.toChat
                            self.pushView(EditVC, animated: true)
                        })
                    }
                }
                else {
                    Themes.sharedInstance.setprogressinAlert(controller: self, progress: 1.0, completionHandler: nil)
                }
            }
        })
    }
    func giphyControllerDidCancel(controller: SwiftyGiphyViewController){
        
    }
}


extension FeedChatVC : UIDocumentPickerDelegate {
   
   func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
      
       guard urls.count > 0 else {return}
       
       var pdfUrl = urls.first
       let  filename = urls.first?.absoluteString.components(separatedBy: "/").last ?? ""
      
       do {
           let pdfData = try Data.init(contentsOf: pdfUrl!)
           let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
           let fileURL = documentsDirectory.appendingPathComponent(filename)
           
           do {
               try pdfData.write(to: fileURL)
               pdfUrl = fileURL
               
               let params = [String:Any]()
               
               URLhandler.sharedinstance.uploadMedia(fileName: filename, param: params as [String : AnyObject], file:pdfUrl! , url: Constant.sharedinstance.uploadFeedMedia, mimeType:"application/*"){
                   (msg,status,url, thumbUrl) in
                   
                   self.removeFiles(fileUrl: fileURL)
                   Themes.sharedInstance.RemoveactivityView(View: self.view)
                   
                   if status == "1"{
                       self.sendMediaToSocket(mainUrl: url, thumbUrl: thumbUrl, caption: "")
                       
                   }else {
                       
                   }
               }
               
               
           } catch {
               print("error saving file to documents:", error)
           }
       }catch {
           print("error saving file to documents:", error)
       }
       
       /*
       let url = urls[0]
       if(Chat_type == "secret")
       {
           let user_common_id = opponent_id + "-" + Themes.sharedInstance.Getuser_id()
           let checkBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "user_common_id", FetchString: user_common_id)
           if(!checkBool)
           {
               self.time(time:"1 hour")
           }
       }
       
       let cico = url
       let objRecord:DocumentRecord = DocumentRecord()
       let Pathextension:String = cico.pathExtension
       if(Pathextension.uppercased() == "PDF")
       {
           let document: CGPDFDocument? = CGPDFDocument(url as CFURL)
           let pageCount: size_t = document!.numberOfPages
           objRecord.docPageCount = "\(pageCount)"
           objRecord.docType = "1"
           objRecord.docImage =  self.buildThumbnailImage(document: document!)!
           objRecord.docPath = cico
           objRecord.path_extension = Pathextension.lowercased()
           objRecord.docName = cico.lastPathComponent.lowercased()
       }
       else if (Pathextension.uppercased() == "TXT" || Pathextension.uppercased() == "DOC" || Pathextension.uppercased() == "DATA" || Pathextension.uppercased() == "TEXT" || Pathextension.uppercased() == "DAT" || Pathextension.uppercased() == "DOCX")
       {
           objRecord.docPageCount = ""
           objRecord.docType = "2"
           objRecord.docImage =  #imageLiteral(resourceName: "docicon")
           objRecord.docPath = cico
           objRecord.path_extension = Pathextension.lowercased()
           objRecord.docName = cico.lastPathComponent.lowercased()
       }
       
       var filesize = Float()
       var Docdata = Data()
       if(objRecord.docType != "")
       {
           do
           {
               Docdata = try Data(contentsOf: objRecord.docPath)
               filesize = Float(Docdata.count) / 1024.0 / 1024.0
               if(filesize > Constant.sharedinstance.DocumentUploadSize)
               {
                   _ = JSSAlertView().show(self,title: Themes.sharedInstance.GetAppname(),text: "Document size exceeded. Kindly choose below 30 MB size file.",buttonText: "OK",color: CustomColor.sharedInstance.themeColor)
                   return
               }
           }
           catch
           {
               print(error.localizedDescription)
           }
           
           SaveDoc(objRecord: objRecord) { Dict in
               
               var secret_msg_id:String = ""
               if(Dict.count > 0)
               {
                   let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                   let to = Themes.sharedInstance.CheckNullvalue(Passed_value: self.opponent_id)
                   var timestamp:String =  String(Date().ticks)
                   var servertimeStr:String = Themes.sharedInstance.getServerTime()
                   var user_common_id:String = ""
                   if(self.Chat_type == "secret"){
                       user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: to + "-" + from)
                       var checksecretmessagecount:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "user_common_id", FetchString: user_common_id, SortDescriptor: "timestamp") as! NSArray
                       checksecretmessagecount = checksecretmessagecount.reversed() as NSArray
                       
                       if(checksecretmessagecount.count > 0)
                       {
                           
                           secret_msg_id = Themes.sharedInstance.CheckNullvalue(Passed_value: (checksecretmessagecount[0] as! NSManagedObject).value(forKey: "doc_id"))
                       }
                   }else{
                       user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: from + "-" + to)
                   }
                   if(servertimeStr == "")
                   {
                       servertimeStr = "0"
                   }
                   let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                   timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                   if(self.Chat_type == "group")
                   {
                       timestamp = self.document_msg_id
                   }
                   let _:String = Dict.object(forKey: "id") as! String
                   let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
                   let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
                   
                   let dic:[AnyHashable: Any] = ["type": "6","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(self.document_doc_id)"
                       ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                       ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                       ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                       ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                       ),"id":timestamp,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
                       ),"payload":"Document","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                       ),"thumbnail":self.pathname,"width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                       ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
                       ),"user_common_id":user_common_id,"message_from":"1","chat_type":self.Chat_type,"info_type":"0","created_by":from,"docType":objRecord.docType,"docName":objRecord.docName,"docPageCount":objRecord.docPageCount,"is_reply":"0","secret_msg_id":secret_msg_id,"secret_timestamp":"", "date" : Themes.sharedInstance.getTimeStamp(), "while_blocked" : Themes.sharedInstance.isImBlocked(to) ? "1" : "0"]
                   DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

                   if(self.Chat_type == "secret"){
                       let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: "\(to)-\(from)")
                       if(!chatarray)
                       {
                           let User_dict:[AnyHashable: Any] = ["user_common_id": "\(to)-\(from)","user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":self.Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                           DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                           
                       }
                       else
                       {
                           let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                           DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: "\(to)-\(from)" , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                       }
                   }else{
                       let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: "\(from)-\(to)")
                       if(!chatarray)
                       {
                           let User_dict:[AnyHashable: Any] = ["user_common_id": "\(from)-\(to)","user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":self.Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                           DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                           
                       }
                       else
                       {
                           let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                           DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: "\(from)-\(to)" , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                       }
                   }
                   DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                       self.dealTheFunctionData(dic, fromOrdering: false)
                       
                   }
                   DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                       UploadHandler.Sharedinstance.handleUpload()
                   }
               }
           }
       }
       else
       {
           Themes.sharedInstance.jssAlertView(viewController: self, title: Themes.sharedInstance.GetAppname(), text: "Unable to upload this file format", buttonTxt: "Ok", color: CustomColor.sharedInstance.themeColor)
       }
       
       */
   }
   
   func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
       self.dismissView(animated: true, completion: nil)
   }
        
        //MARK: New Methods
    
    func returnNewMessageFrame(msg: ChatHIstory, type: MessageType = .UUMessageTypeText) -> UUMessageFrame
    {
        let newmessageFrame = UUMessageFrame()
        let message = UUMessage()
        message.type = type;
        message.strContent = msg.payload
        message.conv_id = msg.fcrId
        message.doc_id = msg.messageDocId
        message.filesize = ""
        message.user_from = msg.senderId
        message.isStar = "false"
        message.message_status = "\(msg.messageStatus)"
        message.msgId = msg._id
        message.name =  "" // msg.displayName
        message.payload = msg.payload
        message.recordId = ""
        message.thumbnail = msg.thumbUrl
        message.timestamp = "\(msg.timeStamp)"
        message.to = msg.receiverId
        message.width = ""
        message.height = ""
        message.chat_type = "" // msg.type
        message.info_type = "0"
        message._id = "\(msg._id)"
        message.contactmsisdn = ""
        message.progress = "0.0";
        message.message_type =  "\(msg.type)" //msg.type
        message.user_common_id = msg.receiverId + "-" + Themes.sharedInstance.Getuser_id()
        message.imagelink = "";
        message.latitude = msg.locationObj.latitude
        message.longitude = msg.locationObj.longitude
        message.title_place = "";
        message.stitle_place = "";
        message.is_deleted = "false"
        message.reply_type = "false"
        
        if msg.type == 1{
            
            print("msg.thumbUrl==\(msg.thumbUrl)")
            message.url_str = msg.url
            message.thumbnail = msg.thumbUrl
            message.title_str = msg.payload
            let objUrlString = msg.url as NSString

            if objUrlString.pathExtension.lowercased() == "gif" || objUrlString.pathExtension.lowercased() == "gif" || objUrlString.pathExtension.lowercased() == "jpeg" || objUrlString.pathExtension.lowercased() == "jpg"  || objUrlString.pathExtension.lowercased() == "png"{
                message.type = .UUMessageTypePicture
            }else if objUrlString.pathExtension.lowercased() == "mp4"{
              message.type = .UUMessageTypeVideo
            }else if objUrlString.pathExtension.lowercased() == "pdf" || objUrlString.pathExtension.lowercased() == "txt" || objUrlString.pathExtension.lowercased() == "data"{
                message.type = .UUMessageTypeDocument
            }
        }else if msg.type == 3 {
            message.type = .UUMessageTypeContact
            message.contact_name = msg.contactObj.name
            message.contact_phone = msg.contactObj.mobileNumber
            message.contact_profile = ""
        }else if msg.type == 4 {
            message.type = .UUMessageTypeLocation
            message.title_place = msg.locationObj.title
            message.stitle_place = msg.locationObj.description
            message.imagelink = msg.locationObj.image
            message.payload = msg.locationObj.title
        }else if msg.type == 5 {
            message.type = .UUMessageTypeReply
            message.reply_type = "\(msg.type)"
            message.reply_type = "true"
            message.title_str = msg.replyObj.payload
        }else if msg.type == 6 {
            message.url_str = msg.url
            message.thumbnail = msg.thumbUrl
            message.type = .UUMessageTypeVoice
        }
        message.from = msg.senderId.elementsEqual("\(Themes.sharedInstance.Getuser_id())") ? .UUMessageFromMe : .UUMessageFromOther
        newmessageFrame.message = message
        return newmessageFrame
    }
    
}

extension FeedChatVC:UUInputFunctionViewDelegate{
   
    func callActionSheet() {
       
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let CameraAction: UIAlertAction = UIAlertAction(title: "Camera", style: .default) { action -> Void in
            self.actionSheetIndex(0)
        }
        let PhotoAction: UIAlertAction = UIAlertAction(title: "Photo & Video Library", style: .default)
        { action -> Void in
            self.actionSheetIndex(1)
        }
        let shareDocAction: UIAlertAction = UIAlertAction(title: "Share Document", style: .default) { action -> Void in
            self.actionSheetIndex(2)
        }
        let shareLocAction: UIAlertAction = UIAlertAction(title: "Share Location", style: .default) { action -> Void in
            self.actionSheetIndex(3)
        }
        let shareConAction: UIAlertAction = UIAlertAction(title: "Share Contact", style: .default) { action -> Void in
            self.actionSheetIndex(4)
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
//        CameraAction.setValue(#imageLiteral(resourceName: "cameraaction"), forKey: "image")
//        PhotoAction.setValue(#imageLiteral(resourceName: "gallery"), forKey: "image")
//        shareDocAction.setValue(#imageLiteral(resourceName: "documentaction"), forKey: "image")
//        shareLocAction.setValue(UIImage(named:"sharelocation"), forKey: "image")
//        shareConAction.setValue(#imageLiteral(resourceName: "contactaction"), forKey: "image")
//
//        CameraAction.setValue(0, forKey: "titleTextAlignment")
//        PhotoAction.setValue(0, forKey: "titleTextAlignment")
//        shareDocAction.setValue(0, forKey: "titleTextAlignment")
//        shareLocAction.setValue(0, forKey: "titleTextAlignment")
//        shareConAction.setValue(0, forKey: "titleTextAlignment")
        
        
        actionSheetController.addAction(CameraAction)
        actionSheetController.addAction(PhotoAction)
        actionSheetController.addAction(shareDocAction)
        actionSheetController.addAction(shareLocAction)
        actionSheetController.addAction(shareConAction)
        actionSheetController.addAction(cancelAction)
        
       // actionSheetController.view.tintColor = UIColor.darkGray
//        actionSheetController.view.backgroundColor = UIColor.white
        self.presentView(actionSheetController, animated: true, completion: nil)
    }
    
    func uuInputFunctionView(_ funcView: UUInputFunctionView!, sendMessage message: String!) {
        
        if isReplyMessage{
            
            var params = [String : Any]()
            
            params["authToken"] = Themes.sharedInstance.getAuthToken()
            params["fcrId"] = convoId
            params["receiverId"] = toChat
            
            let timeStamp = Date.timeStamp*1000
            let docId = "\(Themes.sharedInstance.Getuser_id())-\(toChat)-\(timeStamp)"
            params["messageDocId"] = docId
            
            
            /* 0-Text, 1-Media (Image,video,GIF, Document), 2-Link, 3-Contact, 4-Location,*/
            params["payload"] = message.trimmingCharacters(in: .whitespaces)
            params["type"] = 5
            params["reply"] = ReplyMessageRecord.message.msgId
            addOutgoingMessage(message.trimmingCharacters(in: .whitespaces),timeStamp, type: 5)
            
            SocketIOManager.sharedInstance.emitChaWithCallBack(params: params as NSDictionary, eventName: Constant.sharedinstance.sio_feed_send_chat_message)
            PassCloseAction()
        }else{
          
            var params = [String : Any]()
            
            params["authToken"] = Themes.sharedInstance.getAuthToken()
            params["fcrId"] = convoId
            params["receiverId"] = toChat
            
            let timeStamp = Date.timeStamp*1000
            let docId = "\(Themes.sharedInstance.Getuser_id())-\(toChat)-\(timeStamp)"
            params["messageDocId"] = docId
            
            
            /* 0-Text, 1-Media (Image,video,GIF, Document), 2-Link, 3-Contact, 4-Location,*/
            params["payload"] = message.trimmingCharacters(in: .whitespaces)
            params["type"] = 0
            addOutgoingMessage(message.trimmingCharacters(in: .whitespaces),timeStamp, type: 0)
            
            SocketIOManager.sharedInstance.emitChaWithCallBack(params: params as NSDictionary, eventName: Constant.sharedinstance.sio_feed_send_chat_message)
        }
     
        IFView.textView.text = ""
    }
    
    func uuInputFunctionView(_ funcView: UUInputFunctionView!, sendPicture image: UIImage!) {
        
    }
    
    
    func uuInputFunctionView(_ funcView: UUInputFunctionView!, sendVoice voice: Data!, time second: Int) {
//        guard !Themes.sharedInstance.checkBlock(id: opponent_id) else
//        {
//            Themes.sharedInstance.showBlockalert(id: opponent_id)
//            return
//        }
    
        let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to = Themes.sharedInstance.CheckNullvalue(Passed_value: toChat)
        let timestamp:String =  String(Date().ticks)
        let User_chat_id = from + "-" + to
        let assetName:String = "\(User_chat_id)-\(timestamp).mp3"
        
        var fileURL:URL?
        do {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            fileURL = documentsDirectory.appendingPathComponent(assetName)
            
            do {
                try voice.write(to: fileURL!)
                
                let params = [String:Any]()
                
                
                URLhandler.sharedinstance.uploadMedia(fileName: assetName, param: params as [String : AnyObject], file:fileURL! , url: Constant.sharedinstance.uploadFeedMedia, mimeType:"audio/mpeg"){
                    (msg,status,url, thumbUrl) in
                    
                    print(msg,status,url,thumbUrl)
                    self.removeFiles(fileUrl: fileURL)
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                    
                    if status == "1"{
                      
                        var params = [String : Any]()
                        params["authToken"] = Themes.sharedInstance.getAuthToken()
                        params["fcrId"] = self.convoId
                        params["receiverId"] = self.toChat
                        
                        let timeStamp = Date.timeStamp*1000
                        let docId = "\(Themes.sharedInstance.Getuser_id())-\(self.toChat)-\(timeStamp)"
                        params["messageDocId"] = docId
                        
                        
                        /* 0-Text, 1-Media (Image,video,GIF, Document), 2-Link, 3-Contact, 4-Location,*/
                        params["payload"] = ""
                        params["type"] = 6
                        
                        var mediaDict = [String : Any]()
                        mediaDict["url"] = url
                        mediaDict["thumbUrl"] = thumbUrl
                        params["media"] = [mediaDict]

                        self.addOutgoingMediaMessage("", timeStamp, type: 6, url: url, thumbUrl: thumbUrl)
                        SocketIOManager.sharedInstance.emitChaWithCallBack(params: params as NSDictionary, eventName: Constant.sharedinstance.sio_feed_send_chat_message)
                        
                    }else {
                        
                    }
                }
            } catch {
                print("error saving file to documents:", error)
            }
        }catch {
            print("error saving file to documents:", error)
        }
     
    }
    
    func uuInputFunctionView(_ funcView: UUInputFunctionView!, textViewDidchange Text: String!) {
        
    }
    
    func uuInputFunctionView(_ funcView: UUInputFunctionView!, shouldChangeTextIn range: NSRange, replacementText text: String!) {
        
    }
    
    
    func UpdateUI(){
    
        self.lblTitleAccept.setAttributedText(firstText: "Acccept the messag request from ", firstcolor: UIColor.darkGray, seconText: "\(fromName)", secondColor: UIColor.black)
        self.lblMessageAccept.text = "If yoy accept the message request, you can able to send & receive more messages and see each other online activities!"
//        addRefreshViews();
//        var rect : CGRect = not_member_view_bottom.frame
//        rect.origin.y = self.view.frame.size.height
       // not_member_view_bottom.frame = rect
        link_view.isHidden = true
        self.lytTableBottom.constant = 50
//        tblChat.backgroundColor=UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.0)
//        Chat_imageView.layer.cornerRadius = Chat_imageView.frame.size.width/2
//        Chat_imageView.clipsToBounds=true
//        bottomnavigateView.isHidden = true
        self.selectiontoolbar.isHidden = true
        
        right_item.action = #selector(self.ReleaseEditing)
        left_item.action = #selector(self.DoMessageAction)
        center_item.action = #selector(self.DoClearChat)
        
        
        tblChat.allowsMultipleSelectionDuringEditing = true
        ReplyView = Bundle.main.loadNibNamed("ReplyDetailView", owner: self, options: nil)?[0] as? ReplyDetailView
//        tagView = Bundle.main.loadNibNamed("PersonViewedStatusView", owner: self, options: nil)?[0] as? PersonViewedStatusView
//        tagView.isFromTag = true
//        setBackground()
       
//        self.Title_str = ""
//        self.ImageURl = ""
//        self.Desc = ""
//        self.Url_str = ""
//        self.link_view.title_Str = ""
//        self.link_view.image_Url = ""
//        self.link_view.desc_Str = ""
//        self.link_str = ""
//        updateChatViewAtLoad()
        
        loadBaseViewsAndData()
    }
    
    func loadBaseViewsAndData() {
        
//        Checkencryptedmessage()
//        self.chatModel = ChatModel()
//        self.tblChat.reloadData()
//        self.chatModel.isGroupChat = false
        if(IFView == nil)
        {
            IFView = Bundle.main.loadNibNamed("UUInputFunctionView", owner: self, options: nil)?[0] as? UUInputFunctionView
            IFView.setVC()
             IFView.delegate = self
            if UIDevice().hasNotch {
                IFView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-80, width: UIScreen.main.bounds.size.width, height: 50)
            } else {
                IFView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-50, width: UIScreen.main.bounds.size.width, height: 50)
            }
            IFView.set_Frame()
            if(!self.view.subviews.contains(IFView)) {
                self.view.addSubview(IFView)
            }
        }
        ReplyView.Delegate = self
        ReplyView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-100, width: UIScreen.main.bounds.size.width, height: 50)
//        tagView.delegate = self
//        tagView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-tagView.frame.size.height, width: self.view.frame.size.width, height: tagView.frame.size.height)
        ReplyView.awakeFromNib()
        ReplyView.message_Lbl.frame = CGRect(x: ReplyView.message_Lbl.frame.origin.x, y: ReplyView.message_Lbl.frame.origin.y, width: ReplyView.close_Btn.frame.origin.x - 10, height: ReplyView.message_Lbl.frame.size.height)
        self.view.addSubview(ReplyView)
       // self.view.addSubview(tagView)
        ReplyView.isHidden = true
        
//        tagView.isHidden = true
//        left_item.isEnabled = false
//        center_item.isEnabled = false
        
        //    self.selectiontoolbar.bringSubview(toFront: self.view)
       
        /*let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
        var User_chat_id:String = ""
        
        if(self.Chat_type == "secret"){
            User_chat_id=to + "-" + from
        }else{
            User_chat_id=from + "-" + to
        }
        
        let p1 = NSPredicate(format: "user_common_id = %@", User_chat_id)
        let p2 = NSPredicate(format: "message_status != %@", "3")
        let p3 = NSPredicate(format: "message_status != %@", "0")
        let p4 = NSPredicate(format: "chat_type == %@", self.Chat_type)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2, p3,p4])
        
        let AcknowledgeChathandlerArr = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, SortDescriptor: "timestamp", predicate: predicate,Limit:0) as! NSArray
        if(AcknowledgeChathandlerArr.count > 0)
        {
            let ResponseDict = AcknowledgeChathandlerArr.firstObject as! NSManagedObject
            let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msgId"));
            let id:String =  Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id"))
            let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from"));
            let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "to"));
            var toID:String=String()
            if(from != Themes.sharedInstance.Getuser_id())
            {
                toID=from
            }
            else
            {
                toID=to
            }
            let Doc_id:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id"));
            let convId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "convId"));
            if(Chat_type == "single" || Chat_type == "secret")
            {
                SocketIOManager.sharedInstance.AcknowledegmentHandler(from: Themes.sharedInstance.Getuser_id() as NSString, to: toID as NSString, status: "3", doc_id: Doc_id as NSString, timestamp: timestamp as NSString,isEmit_status: true, is_deleted_message_ack: false, chat_type: Chat_type, convId: convId)
            }
            else
            {
                let param_ack=["groupType": 12, "from": Themes.sharedInstance.Getuser_id(), "groupId": convId, "status":2, "msgId":(id as NSString).longLongValue] as [String : Any]
                SocketIOManager.sharedInstance.GroupmessageAcknowledgement(Param: param_ack)
            }
            */
        }
    
    
    func PassCloseAction(){
        ReplyView.isHidden = true
        isShowBottomView = false
        ReplyView.isHidden = true
        isReplyMessage = false
        if(!isKeyboardShown)
        {
            self.lytTableBottom.constant = 50
        }
        else
        {
            IFView.resign_FirtResponder()
        }
    }
        
     //MARK: TOOLBAR Items
    @objc func ReleaseEditing()
    {
        isBeginEditing = false
        HideToolBar()
    }
       
    
    @objc func DoMessageAction()
    {
        if(isForwardAction)
        {
            if let Indexpath = tblChat.indexPathsForSelectedRows, Indexpath.count != 0 {
                moveToShareContactVC(Indexpath)
            }
            self.HideToolBar()
        }
        else
        {
            if let indexPaths = tblChat.indexPathsForSelectedRows, indexPaths.count != 0
            {
                let deleteActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let deleteForEveryOneAction = UIAlertAction(title: "Delete for Everyone", style: .destructive) { (delete) in
                    let Indexpath:[IndexPath] = self.tblChat.indexPathsForSelectedRows!
                    _ = Indexpath.map {
                        
                        let indexpath = $0
                        
                        self.tableView(self.tblChat, cellForRowAt: indexpath)
                        
                        
                        let chatobj:UUMessageFrame = self.chatHistory[indexpath.row] as! UUMessageFrame
                        
                        if($0 == Indexpath.last)
                        {
                            //self.RemovechatForEveryOne(type: self.Chat_type, convId: chatobj.message.conv_id, status: "1", recordId: chatobj.message.recordId, last_msg: "1")
                        }
                        else
                        {
                            //self.RemovechatForEveryOne(type: self.Chat_type, convId: chatobj.message.conv_id, status: "1", recordId: chatobj.message.recordId, last_msg: "0")
                            
                        }
                    }
                    self.HideToolBar()
                }
                let deleteForMe = UIAlertAction(title: "Delete for Me", style: .destructive) { [unowned self] (delete) in
                    var Indexpath:[IndexPath] = self.tblChat.indexPathsForSelectedRows!
                    _ = Indexpath.map {
                        let indexpath = $0
                        self.tableView(self.tblChat, cellForRowAt: indexpath)
                        
                        
                        let chatobj:UUMessageFrame = self.chatHistory[indexpath.row] as! UUMessageFrame
                        
                        
                        
                        if($0 == Indexpath.last)
                        {
                           // self.Removechat(type: self.Chat_type, convId: chatobj.message.conv_id, status: "1", recordId: chatobj.message.recordId, last_msg: "1")
                        }
                        else
                            
                        {
                            //self.Removechat(type: self.Chat_type, convId: chatobj.message.conv_id, status: "1", recordId: chatobj.message.recordId, last_msg: "0")
                            
                        }
                        
                        if(chatobj.message.message_type == "0" || chatobj.message.message_type == "4" || chatobj.message.message_type == "5" || chatobj.message.message_type == "14" || chatobj.message.message_type == "11")
                        {
//                            let p1 = NSPredicate(format: "id = %@", chatobj.message._id)
//                            DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Chat_one_one, Predicatefromat: p1, Deletestring: "id", AttributeName: "id")
                            
                        }
                        else
                            
                        {
                          /*  let p1 = NSPredicate(format: "id = %@", chatobj.message._id)
                            DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Chat_one_one, Predicatefromat: p1, Deletestring: "id", AttributeName: "id")
                            
                            let predic = NSPredicate(format: "upload_data_id == %@",chatobj.message.thumbnail)
                            
                            let uploadDetailArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: chatobj.message.thumbnail, SortDescriptor: nil) as! [NSManagedObject]
                            _ = uploadDetailArr.map {
                                let uploadDict = $0
                                
                                let upload_Path:String = Themes.sharedInstance.CheckNullvalue(Passed_value: uploadDict.value(forKey: "upload_Path"))
                                Filemanager.sharedinstance.DeleteFile(foldername: upload_Path)
                            }
                            DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Upload_Details, Predicatefromat: predic, Deletestring: "chatobj.message.thumbnail", AttributeName: "id")*/
                        }
                    }
                    
                    
                    Indexpath = (self.tblChat.indexPathsForSelectedRows!).sorted {$0.row < $1.row}
                    let indexset = NSMutableIndexSet()
                    _ = Indexpath.map {
                        indexset.add($0.row)
                    }
                    self.chatHistory.removeObjects(at: indexset as IndexSet)
                    self.tblChat.deleteRows(at: Indexpath, with: .fade)
                    self.tblChat.reloadData()
                    self.HideToolBar()
                }
                
                let Cancel = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
                }
                var Indexpath:[IndexPath] = self.tblChat.indexPathsForSelectedRows!
                Indexpath = (self.tblChat.indexPathsForSelectedRows!).sorted {$0.row < $1.row}
                let indexset = NSMutableIndexSet()
                _ = Indexpath.map {
                    indexset.add($0.row)
                }
                var ShowEveryOne = true
                indexset.forEach({ i in
                    
                    let chatobj:UUMessageFrame = self.chatHistory[i] as! UUMessageFrame
                    if(chatobj.message.from == MessageFrom(rawValue: 0) || chatobj.message.is_deleted == "1" || chatobj.message.message_status == "0")
                    {
                        ShowEveryOne = false
                    }
                })
                var isLesser = true
                indexset.forEach({ i in
                    
                    let chatobj:UUMessageFrame = self.chatHistory[i] as! UUMessageFrame
                    let lesser = Themes.sharedInstance.checkTimeStampMorethan10Mins(timestamp: chatobj.message.timestamp!)
                    
                    if(!lesser)
                    {
                        isLesser = false
                    }
                })
                
                if(ShowEveryOne && isLesser)
                {
                    deleteActionSheet.addAction(deleteForEveryOneAction)
                }
                
                deleteActionSheet.addAction(deleteForMe)
                deleteActionSheet.addAction(Cancel)
                self.presentView(deleteActionSheet, animated: true, completion: nil)
            }
        }
    }
    
    
        @objc func DoClearChat(){
            if isForwardAction{
                var objectsToShare:[Any] = []
                if let indexPaths = tblChat.indexPathsForSelectedRows , indexPaths.count != 0{
                    for i in indexPaths{
                        let cellItem:CustomTableViewCell? = tblChat.cellForRow(at: i as IndexPath) as? CustomTableViewCell
//                        if let url = getUrlFromPathId(pathId: cellItem?.messageFrame.message.thumbnail ?? "", type: cellItem?.messageFrame.message.type.rawValue ?? 0){
//                            objectsToShare.append(url)
//                        }
                    }
                }
                let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]

                self.present(activityViewController, animated: true, completion: nil)
            }else
            {
                if let indexPaths = tblChat.indexPathsForSelectedRows, indexPaths.count != 0
                {
                    let deleteActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let deleteForEveryOneAction = UIAlertAction(title: "Clear for Everyone", style: .destructive) { (delete) in
                        let Indexpath:[IndexPath] = self.tblChat.indexPathsForSelectedRows!
                        _ = Indexpath.map {
                            
                            let indexpath = $0
                            
                            self.tableView(self.tblChat, cellForRowAt: indexpath)
                            
                            
                            let chatobj:UUMessageFrame = self.chatHistory[indexpath.row] as! UUMessageFrame
                            
                            if($0 == Indexpath.last)
                            {
                                //self.RemovechatForEveryOne(type: self.Chat_type, convId: chatobj.message.conv_id, status: "1", recordId: chatobj.message.recordId, last_msg: "1")
                            }
                            else
                            {
                               // self.RemovechatForEveryOne(type: self.Chat_type, convId: chatobj.message.conv_id, status: "1", recordId: chatobj.message.recordId, last_msg: "0")
                                
                            }
                        }
                        self.HideToolBar()
                    }
                    let deleteForMe = UIAlertAction(title: "Clear for Me", style: .destructive) { [unowned self] (delete) in
                        var Indexpath:[IndexPath] = self.tblChat.indexPathsForSelectedRows!
                        _ = Indexpath.map {
                            let indexpath = $0
                            self.tableView(self.tblChat, cellForRowAt: indexpath)
                            
                            
                            let chatobj:UUMessageFrame = self.chatHistory[indexpath.row] as! UUMessageFrame
                            
                            if($0 == Indexpath.last)
                            {
                               // self.Removechat(type: self.Chat_type, convId: chatobj.message.conv_id, status: "1", recordId: chatobj.message.recordId, last_msg: "1")
                            }
                            else
                                
                            {
                               // self.Removechat(type: self.Chat_type, convId: chatobj.message.conv_id, status: "1", recordId: chatobj.message.recordId, last_msg: "0")
                                
                            }
                          
                        }
                        
                        Indexpath = (self.tblChat.indexPathsForSelectedRows!).sorted {$0.row < $1.row}
                        let indexset = NSMutableIndexSet()
                        _ = Indexpath.map {
                            indexset.add($0.row)
                        }
                        self.chatHistory.removeObjects(at: indexset as IndexSet)
                        self.tblChat.deleteRows(at: Indexpath, with: .fade)
                        self.tblChat.reloadData()
                        self.HideToolBar()
                    }
                    
                    let Cancel = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
                    }
                    var Indexpath:[IndexPath] = self.tblChat.indexPathsForSelectedRows!
                    Indexpath = (self.tblChat.indexPathsForSelectedRows!).sorted {$0.row < $1.row}
                    let indexset = NSMutableIndexSet()
                    _ = Indexpath.map {
                        indexset.add($0.row)
                    }
                    var ShowEveryOne = true
                    indexset.forEach({ i in
                        
                        let chatobj:UUMessageFrame = self.chatHistory[i] as! UUMessageFrame
                        if(chatobj.message.from == MessageFrom(rawValue: 0) || chatobj.message.is_deleted == "1" || chatobj.message.message_status == "0")
                        {
                            ShowEveryOne = false
                        }
                    })
                    var isLesser = true
                    indexset.forEach({ i in
                        
                        let chatobj:UUMessageFrame = self.chatHistory[i] as! UUMessageFrame
                        let lesser = Themes.sharedInstance.checkTimeStampMorethan10Mins(timestamp: chatobj.message.timestamp!)
                        
                        if(!lesser)
                        {
                            isLesser = false
                        }
                    })
                    
                    if(ShowEveryOne && isLesser)
                    {
                        deleteActionSheet.addAction(deleteForEveryOneAction)
                    }
                    
                    deleteActionSheet.addAction(deleteForMe)
                    deleteActionSheet.addAction(Cancel)
                    self.presentView(deleteActionSheet, animated: true, completion: nil)
                }
            }
   
        }
    
    
    
    fileprivate func moveToShareContactVC(_ Indexpath: [IndexPath]) {
        let Chat_arr:NSMutableArray = NSMutableArray()
        _ = Indexpath.map {
            let indexpath = $0
            let chatobj:UUMessageFrame = self.chatHistory[indexpath.row] as! UUMessageFrame
            Chat_arr.add(chatobj)
        }
        if(Chat_arr.count > 0)
        {
            let selectShareVC = StoryBoard.main.instantiateViewController(withIdentifier:"SelectShareContactViewController" ) as! SelectShareContactViewController
            selectShareVC.messageDatasourceArr =  Chat_arr
            selectShareVC.isFromForward = true
            self.pushView(selectShareVC, animated: true)
        }
    }
}

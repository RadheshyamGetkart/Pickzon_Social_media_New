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
import AVFoundation
import SimpleImageViewer
import AVKit
import Kingfisher
import FittedSheets
import Contacts

class FeedChatVC: SwiftBaseViewController {
    
    //MARK: - Outlets

    @IBOutlet weak var profileImgView:ImageWithFrameImgView!

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var lytMsgViewBottom: NSLayoutConstraint!
    @IBOutlet weak var lytTableBottom: NSLayoutConstraint!
    @IBOutlet weak var btnBlockedUser: UIButton!
    @IBOutlet weak var cnstr_BlockUserVwHeigHt: NSLayoutConstraint!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var onlineView: UIView!
    @IBOutlet weak var imgVwCelebrity: UIImageView!
    @IBOutlet weak var btnFollow: UIButtonX!
    
    @IBOutlet weak var bgVwAcceptRejectChat: UIView!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnBlock: UIButton!
    @IBOutlet weak var lblTitleAccept: UILabel!
    @IBOutlet weak var lblMessageAccept: UILabel!
    @IBOutlet weak var btnOption: UIButton!

    var previewDocUrl = URL(string: "")
    
    //MARK: - Userdefined Variables
    var is_you_removed:Bool = Bool()
    var popovershow = false
    @IBOutlet var selectiontoolbar: UIToolbar!
    @IBOutlet var left_item: UIBarButtonItem!
    @IBOutlet var right_item: UIBarButtonItem!
    @IBOutlet var center_item: UIBarButtonItem!
    var isFollow = 1
    var inputFuncView:UUInputFunctionView!
    var replyView:ReplyDetailView!;
    var newFrame:CGRect=CGRect()
    var firstIndexpath:IndexPath = IndexPath()
    var isForwardAction:Bool = Bool()
    var isShowBottomView:Bool = Bool()
    var isReplyMessage:Bool = Bool()
    var isKeyboardShown:Bool = Bool()
    var isBeginEditing:Bool = Bool()
    var replyMessageRecord:UUMessageFrame = UUMessageFrame()
    var selectedAssets = [DKAsset]()
    var audioPlayBtn : UIButton?
    var sendMedia = 0
    
    @IBOutlet weak var cnstrntWidthFollow: NSLayoutConstraint!
    @IBOutlet weak var link_bottom: NSLayoutConstraint!
    @IBOutlet weak var link_view: URLEmbeddedView!
    
    var toChat: String = ""
    var isBlocked: Bool = false
    var keyboardHeight: Float = 0.0
    var chatType: String = "single"
    var fcrId: String = ""
    var fromName: String = ""
    var fullUrl :String = ""
    
    var isChatBlockByMe = 0
    var isChatBlockByUser = 0

    var blockByMe = 0
    var blockByUser = 0
    var istartTyping:Bool = false
    var typingTimer:Timer?
    var fromLastTypedAt:UInt64 = 0
    let timeSize = 2
    var isFromPage = false
    var pageNumber = 1
    var pageLimit = 20
    var totalPages = 0
    var isDataLoading = false
    var onlineStatus = ""
    var selectedIndex = 0
    var requestedUser = 1
    var isAPiCalled = 0
    var pickzonId = ""
    var strMsg = ""
    var messageType:Int = 1  //messageType 1 = Normal Chat, 2 = Official Chat
    var avatar = ""
    
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
        self.bgVwAcceptRejectChat.roundGivenCorners([.topLeft,.topRight], radius: 15)
        // tblChat.transform = CGAffineTransformMakeScale(1, -1);
        SocketIOManager.sharedInstance.establishConnection(Nickname: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()) as NSString, isLogin: true)
//        lblName.text = fromName
        profileImgView.initializeView()
        if fromName.count > 0{
            lblName.text =  fromName
        }else{
            lblName.text =  pickzonId
        }
        
        self.fetchFeedChatListFromDB()
        self.onlineView.isHidden = true
        self.lblStatus.text = ""
        if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected){
            SocketIOManager.sharedInstance.establishConnection(Nickname: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()) as NSString, isLogin: true)
        }
        tblChat.register(UINib(nibName: "ChatInfoCell", bundle: nil), forCellReuseIdentifier: "ChatInfoCell")
        tblChat.register(UINib(nibName: "EncryptionTableViewCell", bundle: nil), forCellReuseIdentifier: "EncryptionTableViewCell")
        self.tblChat.isHidden = false
        tblChat.registerCell()
        updateUserInfo()
        addNotificationListener()
        onlineView.layer.cornerRadius = onlineView.frame.size.height/2.0
        onlineView.clipsToBounds = true
        self.onlineView.backgroundColor = UIColor.lightGray
        self.lblStatus.text = "Offline"
        self.topRefreshControl.backgroundColor = .clear
        self.tblChat.refreshControl = topRefreshControl
        let params = ["authToken":Themes.sharedInstance.getAuthToken(),"status":"1"]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_change_online_offline_status, params)
        updateUI()
        if strMsg.length > 0 {
            self.inputFuncView.textView.text = strMsg
            self.inputFuncView.textView.becomeFirstResponder()
        }
        
        self.emitChatHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.checkOnlineSttaus()
        Themes.sharedInstance.chattingUSerId = toChat
        emitFetchUserInfo()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Themes.sharedInstance.chattingUSerId = ""
        self.view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
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
    
    func emitClearChat(type:Int){
        let params = ["authToken":Themes.sharedInstance.getAuthToken(),"fcrId": fcrId,"type":type] as NSDictionary
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_feed_clear_user_chat_list, params)
    }
    
    
    func emitAcknowledgeChat(){
        let params = ["authToken":Themes.sharedInstance.getAuthToken(),"receiverId": toChat,"fcrId":fcrId] as NSDictionary
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_feed_chat_acknowledge_chat, params)
    }
    
    
    func checkOnlineSttaus(){
        
        let params = ["authToken":Themes.sharedInstance.getAuthToken(),"receiverId": toChat] as NSDictionary
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_fetch_online_offline_status, params)
    }
    
    func emitChatHistory(){
    
//        let params1 = ["authToken":Themes.sharedInstance.getAuthToken(),"fcrId":fcrId,"receiverId":toChat,"pageLimit":pageLimit, "pageNumber":pageNumber, "chatType": messageType] as [String : Any]
        
        let params1 = ["authToken":Themes.sharedInstance.getAuthToken(),"fcrId":fcrId,"receiverId":toChat,"pageLimit":pageLimit, "pageNumber":pageNumber] as [String : Any]

        SocketIOManager.sharedInstance.emitChaWithCallBack(params: params1 as NSDictionary, eventName: Constant.sharedinstance.sio_feed_fetch_user_chat_list)
    }
    
 
    func emitAcceptChatRequest(){
        let params1 = ["authToken":Themes.sharedInstance.getAuthToken(),"receiverId":toChat,"fcrId":fcrId] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_feed_accept_chat_request, params1)
    }
    
    
    
    //MARK: - Notification servers
    
    @objc func socketConnected(notification: Notification) {
        
        if self.chatHistory.count == 0 || isAPiCalled == 0{
            self.emitChatHistory()
            self.isAPiCalled = 1
        }
        let params = ["authToken":Themes.sharedInstance.getAuthToken(),"status":"1"]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_change_online_offline_status, params)
        emitFetchUserInfo()
        self.checkOnlineSttaus()
    }
    
    
    @objc func socketError(notification: Notification){
        
        Themes.sharedInstance.RemoveactivityView(View: self.view)
    }
    
    
    @objc func refreshFeedChatDetail(notification: Notification){
        
        self.isAPiCalled = 1
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            
            let status = response["status"] as? Int ?? 0
            self.totalPages = response["totalPages"] as? Int ?? 0
            self.isDataLoading = false
            var dbSaveArray = [ChatHIstory]()

            if status == 1{
                
                if pageNumber == 1{
                    self.chatHistory.removeAllObjects()
                    self.tblChat.reloadData()
                }
                let newChatModel = NSMutableArray()
                
                
                if let payloadArray = response["payload"] as? Array<NSDictionary>{
                    for dict in payloadArray{
                        let obj = ChatHIstory(respDict: dict)
                        dbSaveArray.append(obj)
                        newChatModel.add(returnNewMessageFrame(msg: obj))
                        if fcrId.length == 0{
                            self.fcrId = obj.fcrId
                        }
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
                
                if chatHistory.count > 0 {
                    if pageNumber == 1{
                        self.reorderingMessage(pageNo: pageNumber, oldCount: 0)
                    }else{
                        self.reorderingMessage(pageNo: pageNumber, oldCount: oldCount)
                    }
                }
            }
            
            
            if self.pageNumber == 1 && fcrId.count > 0{
        
                    DBManager.shared.insertChatDetail(chatArray: dbSaveArray, fcrId: self.fcrId, isInitial: true)
                    dbSaveArray.removeAll()
            }
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
            self.tblChat.reloadAnimately{}
            
        }
        

    }
    
   
    func fetchFeedChatListFromDB(){
        
        guard let realm = DBManager.openRealm() else {
            return
        }
        
        let newChatModel = NSMutableArray()
        realm.beginWrite()
        
        if  let chat = realm.object(ofType: ChatDetail.self, forPrimaryKey: fcrId){
            
            for dbObj in  chat.messageArray {
                
                var chatObj = ChatHIstory(respDict: [:])
                
                chatObj._id =  dbObj.msgId
                chatObj.createdAt =  dbObj.createdAt
                chatObj.messageForward =  dbObj.messageForward
                chatObj.fcrId =  dbObj.fcrId 
                chatObj.payload =  dbObj.payload
                chatObj.receiverId =  dbObj.receiverId
                chatObj.status =  dbObj.status
                chatObj.timeStamp =  dbObj.timeStamp
                chatObj.senderId =  dbObj.senderId
                chatObj.type =  dbObj.type
                chatObj.messageStatus =  dbObj.messageStatus
                chatObj.reply =  dbObj.reply
                chatObj.url =  dbObj.url
                chatObj.thumbUrl =  dbObj.thumbUrl
                chatObj.messageDocId =  dbObj.messageDocId
                chatObj.duration =  dbObj.mediaDuration

                chatObj.contactObj = ContactInfo(respDict: [:])
                chatObj.locationObj = LocationInfo(respDict: [:])
                chatObj.replyObj = ReplyInfo(respDict: [:])
                
                if dbObj.type == 1 || dbObj.type == 6 {
                    chatObj.url = dbObj.url
                    chatObj.thumbUrl = dbObj.thumbUrl
                    chatObj.duration =  dbObj.mediaDuration

                }else  if dbObj.type == 3 {
                    
                    chatObj.contactObj.name = dbObj.contactName
                    chatObj.contactObj.mobileNumber =  dbObj.contactMobileNo
                    
                }else  if dbObj.type == 4 {
                    
                    chatObj.locationObj.latitude = dbObj.locationLat
                    chatObj.locationObj.longitude =  dbObj.locationLong
                    chatObj.locationObj.description = dbObj.locationDesc
                    chatObj.locationObj.link =  dbObj.locationLink
                    chatObj.locationObj.title = dbObj.locationTitle
                    chatObj.locationObj.image = dbObj.locationImage
                }
                
                
                if dbObj.reply.length > 0 {
                    
                    chatObj.replyObj.fromId = dbObj.replyFromId
                    chatObj.replyObj.fromName = dbObj.replyFromName
                    chatObj.replyObj.type =   dbObj.replyType
                    chatObj.replyObj.payload =   dbObj.replyPayload
                    
                    if dbObj.replyType == 1 || dbObj.replyType == 6 {
                        chatObj.replyObj.url = dbObj.replyUrl
                        chatObj.replyObj.thumbUrl = dbObj.replyThumb
                        chatObj.duration =  dbObj.replyMediaDuration

                    }else  if dbObj.replyType == 3 {
                        
                        chatObj.replyObj.contactObj.name = dbObj.replyContactName
                        chatObj.replyObj.contactObj.mobileNumber = dbObj.replyContactMobileNo
                        
                    }else  if dbObj.replyType == 4 {
                        
                        chatObj.replyObj.locationObj.latitude =  dbObj.replyLocationLat
                        chatObj.replyObj.locationObj.longitude = dbObj.replyLocationLong
                        chatObj.replyObj.locationObj.description = dbObj.replyLocationDesc
                        chatObj.replyObj.locationObj.link = dbObj.replyLocationLink
                        chatObj.replyObj.locationObj.title = dbObj.replyLocationTitle
                        chatObj.replyObj.locationObj.image = dbObj.replyLocationImage
                    }
                }
                
                newChatModel.add(returnNewMessageFrame(msg: chatObj))
                
            }
        }
        
       try? realm.commitWrite()
      chatHistory = newChatModel
        
        
        if chatHistory.count > 0 {
            self.reorderingMessage(pageNo: pageNumber, oldCount: 0)
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
            self.tblChat.reloadAnimately{}
        }
        
        //UIView.setAnimationsEnabled(false)
       // self.tblChat.reloadData()
        //UIView.setAnimationsEnabled(true)
    }
    
    
    
  
    
    //MARK: UIBUtton Action Methods
    
    @IBAction func followBtnAction(){
        
        Themes.sharedInstance.activityView(View: self.view)
            
        let param:NSDictionary = ["followedUserId":toChat,"status": "1"]
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.follow as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
                let payloadDict = result["payload"] as? NSDictionary ?? [:]
                
                if status == 1{
                    self.isFollow = payloadDict["isFollow"] as? Int ?? 0
                    self.updateUserInfo()
                }else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    @IBAction func acceptBtnAction(){
        self.view.endEditing(true)
        self.emitAcceptChatRequest()
    }
    
    @IBAction func deleteBtnAction(){
        
        self.emitClearChat(type: 1)
    }
    
    @IBAction func blockBtnAction(){
        self.view.endEditing(true)
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
        self.view.endEditing(true)
        openMoreOptions()
    }
    
    //MARK: - Userdefined Functions
    func updateUserInfo() {
    //imgListing.kf.setImage(with: URL(string: fullUrl), placeholder: UIImage(named: "avatar")!, options: [.fromMemoryCacheOrRefresh], progressBlock: nil) { response in}
        
        profileImgView.setImgView(profilePic: fullUrl, frameImg: avatar)
//        if fromName.count > 0{
//            lblName.text =  fromName
//        }else{
            lblName.text =  pickzonId
        //}
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
            inputFuncView?.isHidden = true
        }else{
            self.onlineView.isHidden = false
            self.lblStatus.isHidden = false
            self.onlineView.isHidden = false
            self.cnstr_BlockUserVwHeigHt.constant = 0
            btnBlockedUser.isHidden = true
            inputFuncView?.isHidden = false
        }
        
        if (isChatBlockByMe == 1 || isChatBlockByUser == 1)  && (blockByMe == 0 || blockByUser == 0 ) {
            
            self.lblStatus.isHidden = true
            self.onlineView.isHidden = true
            lytTableBottom.constant = 20
            let msg = (isChatBlockByUser == 1) ? "User has blocked chat" : "you've blocked chat"
            btnBlockedUser.setTitle(msg, for: .normal)
            btnBlockedUser.isHidden = false
            self.cnstr_BlockUserVwHeigHt.constant = 25
            self.onlineView.isHidden = true
            self.lblStatus.text = ""
            inputFuncView?.isHidden = true
        }

        if requestedUser == 0 && ( blockByMe == 0 && blockByUser == 0){
            self.view.addSubview(self.bgVwAcceptRejectChat)
            self.bgVwAcceptRejectChat.isHidden = false
        }else{
            self.bgVwAcceptRejectChat.isHidden = true
        }
        DispatchQueue.main.async {
            self.btnFollow.isHidden = (self.isFollow == 0 || self.isFollow == 3) ? false : true
            self.cnstrntWidthFollow.constant = (self.isFollow == 0 || self.isFollow == 3) ? 70 : 0
          
            if self.blockByMe == 1 || self.blockByUser == 1 {
                self.btnFollow.isHidden = true
                self.cnstrntWidthFollow.constant = 0
            }
        }
    }
    
    
    func reorderingMessage(pageNo:Int,oldCount:Int){
        
        DispatchQueue.main.async {

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
        
            self.chatHistory.removeAllObjects()
            self.chatHistory.addObjects(from: orderingArr)
            
           UIView.setAnimationsEnabled(false)
            self.tblChat.reloadData()
          UIView.setAnimationsEnabled(true)
           // self.setTail(isAtBottom: true)
            
            if pageNo == 1{
                self.tableViewScrollToBottom()                
            }else{
           
            }
        }
    }
    
   
    func returnMessageFrame(dict : [String : String], type : MessageType) -> UUMessageFrame
    {
        let newmessageFrame = UUMessageFrame()
        let message = UUMessage()
        message.replyObj = ReplyInfo(respDict: [:])
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
    
   
    
    //MARK: - Userdefined Functions
    
    @objc func tableViewScrollToBottom() {
        if self.chatHistory.count == 0 ||  self.chatHistory.count == 1{
            return
        }else  {
                if self.tblChat.numberOfRows(inSection: 0) > 0{
                    let indexPath = IndexPath(row: self.tblChat.numberOfRows(inSection: 0)-1, section: 0)
                    self.tblChat.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
        }
    }
    
    
    func updateUI(){
        
        self.lblTitleAccept.setAttributedText(firstText: "Acccept the message request from ", firstcolor: UIColor.darkGray, seconText: "@\(pickzonId)", secondColor: UIColor.label)
        self.lblMessageAccept.text = "Once you accept the message, you will be able to send & receive the messages and see each other's online activities!"
        link_view.isHidden = true
        self.lytTableBottom.constant = 50
        self.selectiontoolbar.isHidden = true
        right_item.action = #selector(self.ReleaseEditing)
        left_item.action = #selector(self.DoMessageAction)
        center_item.action = #selector(self.DoClearChat)
        tblChat.allowsMultipleSelectionDuringEditing = true
        replyView = Bundle.main.loadNibNamed("ReplyDetailView", owner: self, options: nil)?[0] as? ReplyDetailView
        loadBaseViewsAndData()
    }
    
    func loadBaseViewsAndData() {
        
        if(inputFuncView == nil)
        {
            inputFuncView = Bundle.main.loadNibNamed("UUInputFunctionView", owner: self, options: nil)?[0] as? UUInputFunctionView
            inputFuncView.setVC()
            inputFuncView.delegate = self
            if UIDevice().hasNotch {
                inputFuncView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-80, width: UIScreen.main.bounds.size.width, height: 50)
            } else {
                inputFuncView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-50, width: UIScreen.main.bounds.size.width, height: 50)
            }
            inputFuncView.set_Frame()
            if(!self.view.subviews.contains(inputFuncView)) {
                self.view.addSubview(inputFuncView)
            }
        }
        replyView.Delegate = self
        replyView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-100, width: UIScreen.main.bounds.size.width, height: 50)
        replyView.awakeFromNib()
        replyView.message_Lbl.frame = CGRect(x: replyView.message_Lbl.frame.origin.x, y: replyView.message_Lbl.frame.origin.y, width: replyView.close_Btn.frame.origin.x - 10, height: replyView.message_Lbl.frame.size.height)
        self.view.addSubview(replyView)
        replyView.isHidden = true
    }
    
    private func requestContactsAccess() {
        let store = CNContactStore()

        store.requestAccess(for: .contacts) {granted, error in
            if granted {
                let contactsArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_add, attribute: nil, FetchString: nil, SortDescriptor: nil) as! [Contact_add]
                if contactsArray.count == 0{
                    ContactHandler.sharedInstance.StoreContacts()
                }
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
}




extension FeedChatVC{
    
    //MARK: -  Action Sheet action options
    private func actionSheetIndex(_ index: Int) {
        if(index == 0)
        {
            let pickerController = DKImagePickerController()
            pickerController.maxSelectableCount = 5
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
            
        }else if(index == 1){
            
            let pickerController = DKImagePickerController()
            pickerController.singleSelect = true
            pickerController.assetType = .allAssets
            pickerController.sourceType = .photo
            pickerController.isFromChat = true
            pickerController.maxSelectableCount = 5

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
            let contactVC = StoryBoard.main.instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController
            if let exampleType = ExampleType(rawValue: "comparison") {
                contactVC.example = exampleByType(exampleType)
            }
            contactVC.delegate = self
            contactVC.oppponent_id = toChat
            contactVC.navigationController?.navigationBar.isHidden = true
            self.pushView(contactVC, animated: true)
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
        uploadMediaArray(assetArray: AssetArr)
    }
       
    
    func uploadMediaArray(assetArray:NSMutableArray){

        if(assetArray.count > 0)
        {
            if let objRecord  = assetArray.firstObject as? MultimediaRecord{
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
                        DispatchQueue.main.async {
                            Themes.sharedInstance.activityView(View: self.view)
                        }
                        
                        URLhandler.sharedinstance.uploadMedia(fileName: objRecord.assetname, param: params as [String : AnyObject], file:fileURL! , url: Constant.sharedinstance.uploadFeedMedia, mimeType:strMime){
                            (msg,status,url, thumbUrl,duration) in
                            
                            DispatchQueue.main.async {
                                
                                Themes.sharedInstance.RemoveactivityView(View: self.view)
                            }
                            if status == "1"{
                                DispatchQueue.main.async {
                                    self.sendMediaToSocket(mainUrl: url, thumbUrl: thumbUrl, caption: objRecord.caption, duration: duration)
                                    self.removeFiles(fileUrl: fileURL)
                                    assetArray.removeObject(at: 0)
                                    self.uploadMediaArray(assetArray: assetArray)
                                }
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
                DispatchQueue.main.async {
                    Themes.sharedInstance.activityView(View: self.view)
                }
                
                if objRecord.isVideo == true {
                    FYVideoCompressor().compressVideo(fileURL!, quality: .highQuality) { result in
                        switch result {
                        case .success(let compressedVideoURL):
                            URLhandler.sharedinstance.uploadMedia(fileName: objRecord.assetname, param: params as [String : AnyObject], file:compressedVideoURL , url: Constant.sharedinstance.uploadFeedMedia, mimeType:strMime){
                                (msg,status,url, thumbUrl,duration) in
                                
                                DispatchQueue.main.async {
                                    
                                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                                }
                                if status == "1"{
                                    DispatchQueue.main.async {
                                        self.sendMediaToSocket(mainUrl: url, thumbUrl: thumbUrl, caption: objRecord.caption, duration: duration)
                                        self.removeFiles(fileUrl: fileURL)
                                    }
                                }else {
                                    
                                }
                            }
                            
                        case .failure(let error):
                            print(error.localizedDescription)
                            break
                        }
                        
                    }
               
                }else{
                    URLhandler.sharedinstance.uploadMedia(fileName: objRecord.assetname, param: params as [String : AnyObject], file:fileURL! , url: Constant.sharedinstance.uploadFeedMedia, mimeType:strMime){
                        (msg,status,url, thumbUrl,duration) in
                        
                        DispatchQueue.main.async {
                            
                            Themes.sharedInstance.RemoveactivityView(View: self.view)
                        }
                        if status == "1"{
                            DispatchQueue.main.async {
                                self.sendMediaToSocket(mainUrl: url, thumbUrl: thumbUrl, caption: objRecord.caption, duration: duration)
                                self.removeFiles(fileUrl: fileURL)
                            }
                        }else {
                            
                        }
                    }
                }
            } catch {
                print("error saving file to documents:", error)
            }
        }catch {
            print("error saving file to documents:", error)
        }
        
    }
    
    func sendMediaToSocket(mainUrl:String,thumbUrl:String,caption:String,duration:String){
        
        var params = [String : Any]()
        
        params["authToken"] = Themes.sharedInstance.getAuthToken()
        params["fcrId"] = fcrId
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
        mediaDict["duration"] = duration
        params["media"] = [mediaDict]

        DispatchQueue.main.async {
            self.addOutgoingMediaMessage(caption, timeStamp, type: 1, url: mainUrl, thumbUrl: thumbUrl, duration: duration)
        }
        SocketIOManager.sharedInstance.emitChaWithCallBack(params: params as NSDictionary, eventName: Constant.sharedinstance.sio_feed_send_chat_message)
        
    }

    //Contact Share Delegate
    func share(rec:NSMutableArray){
        
        if let obj = rec.firstObject as? FavRecord {
            
            var params = [String : Any]()
            
            params["authToken"] = Themes.sharedInstance.getAuthToken()
            params["fcrId"] = fcrId
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
        params["fcrId"] = fcrId
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
                   (msg,status,url, thumbUrl,duration) in
                   
                   self.removeFiles(fileUrl: fileURL)
                   Themes.sharedInstance.RemoveactivityView(View: self.view)
                   
                   if status == "1"{
                       self.sendMediaToSocket(mainUrl: url, thumbUrl: thumbUrl, caption: "", duration: duration)
                       
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
   
   func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
       self.dismissView(animated: true, completion: nil)
      
   }
        
    //MARK: New Methods
    
    func returnNewMessageFrame(msg: ChatHIstory, type: MessageType = .UUMessageTypeText) -> UUMessageFrame
    {
        let newmessageFrame = UUMessageFrame()
        let message = UUMessage()
        message.type = type;
        message.senderImage = fullUrl
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
        message.name = fromName
        message.replyObj = ReplyInfo(respDict: [:])
        message.duration = msg.duration
        message.isForwarded = "\(msg.messageForward)"
        
        if msg.type == 1{
            
            message.url_str = msg.url
            message.thumbnail = msg.thumbUrl
            message.title_str = msg.payload

            if  checkMediaTypes(strUrl: msg.url) == 1{
                message.type = .UUMessageTypePicture
            }else if checkMediaTypes(strUrl: msg.url) == 2{
                message.type = .UUMessageTypeDocument
            }else if checkMediaTypes(strUrl: msg.url) == 3{
                message.type = .UUMessageTypeVideo
               message.duration = msg.duration
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
        }else if msg.reply.count > 0 {
            message.type = .UUMessageTypeReply
            message.reply_type = "\(msg.replyObj.type)"
            message.title_str = msg.replyObj.payload
            message.replyObj = msg.replyObj
            message.message_type = "\(msg.replyObj.type)"
            message.replyMsgId = msg.reply
        }else if msg.type == 6 {
            message.url_str = msg.url
            message.thumbnail = msg.thumbUrl
            message.type = .UUMessageTypeVoice
        }else if msg.type == 7 {
            message.url_str = msg.storyThumb
            message.storyPayload = msg.storyPayload
            message.type = .UUMessageTypeStory
            message.storyId = msg.storyId
        }
        message.from = msg.senderId.elementsEqual("\(Themes.sharedInstance.Getuser_id())") ? .UUMessageFromMe : .UUMessageFromOther
        newmessageFrame.message = message
        return newmessageFrame
    }
    
}



extension FeedChatVC:UUInputFunctionViewDelegate{
    
    //MARK: UUInputFunctionViewDelegate
    func callActionSheet() {
        self.requestContactsAccess()
        
        if messageType == 2 {
            return  //messageType 1 = Normal Chat, 2 = Official Chat
        }
        
        if sendMedia == 0{
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Once chat request is accepted. You can send photo/video/document.")
            return
        }
        
//        let contactsArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_add, attribute: nil, FetchString: nil, SortDescriptor: nil) as! [Contact_add]
//        if contactsArray.count == 0{
//            ContactHandler.sharedInstance.StoreContacts()
//        }
        
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
        
        /*CameraAction.setValue(#imageLiteral(resourceName: "cameraaction"), forKey: "image")
         PhotoAction.setValue(#imageLiteral(resourceName: "gallery"), forKey: "image")
         shareDocAction.setValue(#imageLiteral(resourceName: "documentaction"), forKey: "image")
         shareLocAction.setValue(UIImage(named:"sharelocation"), forKey: "image")
         shareConAction.setValue(#imageLiteral(resourceName: "contactaction"), forKey: "image")
         
         CameraAction.setValue(0, forKey: "titleTextAlignment")
         PhotoAction.setValue(0, forKey: "titleTextAlignment")
         shareDocAction.setValue(0, forKey: "titleTextAlignment")
         shareLocAction.setValue(0, forKey: "titleTextAlignment")
         shareConAction.setValue(0, forKey: "titleTextAlignment")
         */
        actionSheetController.addAction(CameraAction)
        actionSheetController.addAction(PhotoAction)
        actionSheetController.addAction(shareDocAction)
        actionSheetController.addAction(shareLocAction)
        actionSheetController.addAction(shareConAction)
        actionSheetController.addAction(cancelAction)
        
        actionSheetController.view.tintColor = UIColor.systemBlue
        // actionSheetController.view.backgroundColor = UIColor.white
        self.presentView(actionSheetController, animated: true, completion: nil)      

    }
  
    
    func uuInputFunctionView(_ funcView: UUInputFunctionView!, sendMessage message: String!) {
        
        if messageType == 2 {
            return  //messageType 1 = Normal Chat, 2 = Official Chat
        }
        
        if message.trim().count == 0{
            return
        }
        
            if isReplyMessage{
            
            var params = [String : Any]()
            
            params["authToken"] = Themes.sharedInstance.getAuthToken()
            params["fcrId"] = fcrId
            params["receiverId"] = toChat
            
            let timeStamp = Date.timeStamp*1000
            let docId = "\(Themes.sharedInstance.Getuser_id())-\(toChat)-\(timeStamp)"
            params["messageDocId"] = docId
            
            /* 0-Text, 1-Media (Image,video,GIF, Document), 2-Link, 3-Contact, 4-Location,*/
            params["payload"] = message.trimmingCharacters(in: .whitespaces)
            params["type"] = 0 // 5
            params["reply"] = replyMessageRecord.message.msgId
            addOutgoingMessage(message.trimmingCharacters(in: .whitespaces),timeStamp, type: 5)
            
            SocketIOManager.sharedInstance.emitChaWithCallBack(params: params as NSDictionary, eventName: Constant.sharedinstance.sio_feed_send_chat_message)
            PassCloseAction()
        }else{
            
            var params = [String : Any]()
            
            params["authToken"] = Themes.sharedInstance.getAuthToken()
            params["fcrId"] = fcrId
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
        
        inputFuncView.textView.text = ""
    }
    
    func uuInputFunctionView(_ funcView: UUInputFunctionView!, sendPicture image: UIImage!) {
        
    }
   
    func checkMicPermission() -> Bool {
        
        var permissionCheck: Bool = false
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            permissionCheck = true
        case AVAudioSession.RecordPermission.denied:
            permissionCheck = false
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    permissionCheck = true
                } else {
                    permissionCheck = false
                }
            })
        default:
            break
        }
        return permissionCheck
    }
    
    func uuInputFunctionView(_ funcView: UUInputFunctionView!, sendVoice voice: Data!, time second: Int) {
       
        if messageType == 2 {
            return  //messageType 1 = Normal Chat, 2 = Official Chat
        }
        
        if  checkMicPermission() == false{
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Please enable microphone to send audio message from settings.")
            return
        }
        if sendMedia == 0{
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Once chat request is accepted. You can send photo/video/document.")
            return
        }
        
        if second <= 0{
            return
        }
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
                    (msg,status,url, thumbUrl,duration) in
                    
                    self.removeFiles(fileUrl: fileURL)
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                    
                    if status == "1"{
                        
                        var params = [String : Any]()
                        params["authToken"] = Themes.sharedInstance.getAuthToken()
                        params["fcrId"] = self.fcrId
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
                        mediaDict["duration"] = duration
                        params["media"] = [mediaDict]
                        
                        self.addOutgoingMediaMessage("", timeStamp, type: 6, url: url, thumbUrl: thumbUrl, duration: duration)
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
        
        if Text.length > 0{
            let params = ["authToken":Themes.sharedInstance.getAuthToken(),"fcrId":fcrId,"receiverId":toChat,"senderId":Themes.sharedInstance.Getuser_id(), "typing":true] as [String : Any]
            SocketIOManager.sharedInstance.emitChaWithCallBack(params: params as NSDictionary, eventName: Constant.sharedinstance.sio_feed_chat_typing)
        }else{
            let params = ["authToken":Themes.sharedInstance.getAuthToken(),"fcrId":fcrId,"receiverId":toChat,"senderId":Themes.sharedInstance.Getuser_id(), "typing":false] as [String : Any]
            SocketIOManager.sharedInstance.emitChaWithCallBack(params: params as NSDictionary, eventName: Constant.sharedinstance.sio_feed_chat_typing)
        }
    }
    
    func uuInputFunctionView(_ funcView: UUInputFunctionView!, shouldChangeTextIn range: NSRange, replacementText text: String!) {
        
    }
    
    
   
    
    func PassCloseAction(){
        replyView.isHidden = true
        isShowBottomView = false
        replyView.isHidden = true
        isReplyMessage = false
        if(!isKeyboardShown)
        {
            self.lytTableBottom.constant = 50
        }
        else
        {
            inputFuncView.resign_FirtResponder()
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
                
                if Indexpath.count > 5 {
                    AlertView.sharedManager.displayMessageWithAlert(title: "You can forward maximum 5 messages at a time", msg: "")
                }else{
                    moveToShareContactVC(Indexpath)
                    self.HideToolBar()
                }
            }
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
                        self.emitDeleteChatFromBoth(messageIds: [chatobj.message.msgId])
                    }
                    self.HideToolBar()
                }
                
                let deleteForMe = UIAlertAction(title: "Delete for Me", style: .destructive) { [unowned self] (delete) in
                    var Indexpath:[IndexPath] = self.tblChat.indexPathsForSelectedRows!
                    _ = Indexpath.map {
                        let indexpath = $0
                        self.tableView(self.tblChat, cellForRowAt: indexpath)
                        let chatobj:UUMessageFrame = self.chatHistory[indexpath.row] as! UUMessageFrame
                        self.emitDeleteChat(messageIds: [chatobj.message.msgId])
                    }
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
        return
       /* if isForwardAction{
            var objectsToShare:[Any] = []
            if let indexPaths = tblChat.indexPathsForSelectedRows , indexPaths.count != 0{
                for i in indexPaths{
                    let cellItem:CustomTableViewCell? = tblChat.cellForRow(at: i as IndexPath) as? CustomTableViewCell
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
                        
                    }
                    self.HideToolBar()
                }
                let deleteForMe = UIAlertAction(title: "Clear for Me", style: .destructive) { [unowned self] (delete) in
                    var Indexpath:[IndexPath] = self.tblChat.indexPathsForSelectedRows!
                    _ = Indexpath.map {
                        let indexpath = $0
                        self.tableView(self.tblChat, cellForRowAt: indexpath)
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
        }*/
        
    }
    
    
    
    fileprivate func moveToShareContactVC(_ Indexpath: [IndexPath]) {
        let Chat_arr:NSMutableArray = NSMutableArray()
        _ = Indexpath.map {
            let indexpath = $0
            let chatobj:UUMessageFrame = self.chatHistory[indexpath.row] as! UUMessageFrame
            Chat_arr.add(chatobj.message.msgId)
        }
        
        if(Chat_arr.count > 0)
        {
            let selectShareVC = StoryBoard.chat.instantiateViewController(withIdentifier:"ChatUserListVC" ) as! ChatUserListVC
            selectShareVC.isMultipleSelection = true
            selectShareVC.delegate = self
            selectShareVC.messageDatasourceArr =  Chat_arr
            selectShareVC.toChatUserId = toChat
            self.pushView(selectShareVC, animated: true)
        }
    }
}


extension FeedChatVC:SelectedNewUserDelegate{
    
    func selectedUsers(userArray: Array<Followers>, messageIdArray: NSMutableArray) {
        
        var userIdArray = [String]()
        for obj in userArray{
            userIdArray.append(obj.id)
        }
        if userArray.count > 0{
         
            let params = ["authToken":Themes.sharedInstance.getAuthToken(),"receiverIds": userIdArray,"messageForwardIds":messageIdArray] as NSDictionary
            SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_feed_send_forward_message, params)
        }
    }
}

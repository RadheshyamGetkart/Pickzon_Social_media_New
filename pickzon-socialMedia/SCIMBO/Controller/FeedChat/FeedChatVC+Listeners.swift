//
//  FeedChatVC+Listeners.swift
//  SCIMBO
//
//  Created by Getkart on 02/08/21.
//  Copyright © 2021 Radheshyam Yadav. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManager

extension FeedChatVC{
    
    //MARK: Notification listiners
    func addNotificationListener() {
                
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.sio_block_unblock_user_chat(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_block_unblock_user_chat), object: nil)
        
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.acceptChatRequestCallBack(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_accept_chat_request), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchUserInfo(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_fetch_user_info), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.clearChat(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_clear_user_chat_list), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshFeedChatDetail(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_fetch_user_chat_list), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.socketError(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.socket_error), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendMessageCallback),
                                               name: NSNotification.Name(rawValue:Constant.sharedinstance.sio_feed_send_chat_message), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(readMessageStatusUpdate),
                                               name: NSNotification.Name(rawValue:Constant.sharedinstance.sio_feed_chat_acknowledge_chat), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveMessage),
                                               name: NSNotification.Name(rawValue:Constant.sharedinstance.sio_feed_receive_chat_message), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(typingStatus(not:)),
                                               name: NSNotification.Name(rawValue:Constant.sharedinstance.sio_feed_chat_typing), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData(notification:)),
                                               name: NSNotification.Name(rawValue:Constant.sharedinstance.reloadFeedData), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onlineOfflineStatus(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_fetch_online_offline_status), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteMsgStatus(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_delete_user_chat), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.socketConnected(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.socketCnnected), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.forwardMessageCallback(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_send_forward_message), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.blockUnblockCheckCallback(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_check_block_unblock_user), object: nil)
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else{ return }
            weak.keyboardChangeShow(notify)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else{ return }
            weak.keyboardChangeHide(notify)
        }
    }
    
    
    
    
    func removeNotificationListener() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_block_unblock_user_chat), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_check_block_unblock_user), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_send_forward_message), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_accept_chat_request), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_delete_user_chat), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_fetch_user_chat_list), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadFeedData), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_fetch_online_offline_status), object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Observers methods
    
    
    
    @objc func sio_block_unblock_user_chat(notification: Notification) {
        
        
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            
            if let onlineStatusDict = response["payload"] as? NSDictionary{
                let isBlockUser = onlineStatusDict["isBlockUser"] as? Int ?? 0
               // let isBlockUserMessage = onlineStatusDict["isBlockUserMessage"] as? String ?? ""
               
                if isBlockUser == 1{
                    self.isChatBlockByMe = 1
                }else if isBlockUser == 2{
                    self.isChatBlockByUser = 1
                }else{
                    self.isChatBlockByMe = 0
                    self.isChatBlockByUser = 0
                }
                self.updateUserInfo()
            }
        }
    }
    
  
    @objc func blockUnblockCheckCallback(notification: Notification) {
        
        
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            
            if let onlineStatusDict = response["payload"] as? NSDictionary{
                let isBlockUser = onlineStatusDict["isBlockUser"] as? Int ?? 0
                
                if isBlockUser == 1{
                    self.blockByMe = 1
                }else if isBlockUser == 2{
                    self.blockByUser = 1
                }else{
                    self.blockByMe = 0
                    self.blockByUser = 0
                }
                self.updateUserInfo()
            }
        }
    }
    
    
    @objc func onlineOfflineStatus(notification: Notification) {
        
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            
            if let onlineStatusDict = response["payload"] as? NSDictionary{
                
                if toChat == onlineStatusDict["receiverId"] as? String ?? "" {
                    let status = onlineStatusDict["status"] as? Int ?? 0
                    
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
    
    @objc func forwardMessageCallback(notification:Notification){
        Themes.sharedInstance.isChatListRefresh = 0
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            if let payloadDict = response["payload"] as? NSDictionary{
                print(payloadDict)
            }
        }
    }
    
    @objc func clearChat(notification:Notification){
        
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            if let payloadDict = response["payload"] as? NSDictionary{
                
                if payloadDict["type"] as? Int ?? 0 == 1 {
                    if self.requestedUser == 0 {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: refreshRequestList), object:nil, userInfo: ["fcrId":fcrId])
                    }
                    self.bgVwAcceptRejectChat.isHidden = true
                    
                    var isfound = false
                    for controller in self.navigationController?.viewControllers ?? [] {
                        
                        if controller.isKind(of: ChatListVC.self){
                            
                            self.navigationController?.popToViewController(controller, animated: true)
                            isfound = true
                            break
                        }
                    }
                    if  isfound == false {
                        self.navigationController?.popViewController(animated: false)
                    }
                }else if payloadDict["type"] as? Int ?? 0 == 0 {
                    self.totalPages = 0
                    self.pageNumber = 1
                    self.chatHistory.removeAllObjects()
                    self.tblChat.reloadData()
                }
            }
        }
    }
    
    
    @objc func fetchUserInfo(notification:Notification){
        
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            
            if response["status"] as? Int ?? 0 == 0{
                self.inputFuncView.isHidden = true
                self.btnOption.isHidden = true
                AlertView.sharedManager.presentAlertWith(title: "", msg: (response["message"] as? String ?? "") as NSString, buttonTitles: ["Ok"], onController: self, dismissBlock: { (title,index)in
                   
                    self.btnFollow.isHidden = true
                    self.cnstrntWidthFollow.constant = 0
                    self.requestedUser = 0
                    if self.chatHistory.count <= 2 {
                        self.navigationController?.popViewController(animated: true)
                    }
                })
                
            }else{
                
                if let payloadDict = response["payload"] as? NSDictionary{
                    
                    self.toChat = payloadDict["userId"] as? String ?? ""
                    self.fromName = payloadDict["name"] as? String ?? ""
                    self.pickzonId =  payloadDict["pickzonId"] as? String ?? ""
                    self.fullUrl = payloadDict["profilePic"] as? String ?? ""
                    self.fcrId = payloadDict["fcrId"] as? String ?? ""
                    self.messageType = payloadDict["chatType"] as? Int ?? 1
                    self.avatar =  payloadDict["avatar"] as? String ?? ""
                    self.requestedUser = payloadDict["requestedUser"] as? Int ?? 0
                    let isBlockUser = payloadDict["isBlockUser"] as? Int ?? 0 //  isBlockUser: 0 // 0 is not blocked, 1 is Blocked by you, 2 is user has blocked you
                    let isBlockUserMessage = payloadDict["isBlockUserMessage"] as? String ?? ""
                    let celebrity = payloadDict["celebrity"] as? Int ?? 0
                    if let followStatus = payloadDict["isFollow"] as? Int {
                        self.isFollow = followStatus
                    }
                    if let sendMedia = payloadDict["sendMedia"] as? Int {
                        self.sendMedia = sendMedia
                    }
                    
                    if isBlockUser == 1{
                        self.blockByMe = 1
                    }else if isBlockUser == 2{
                        self.blockByUser = 1
                    }else{
                        self.blockByMe = 0
                        self.blockByUser = 0
                    }
                    
                    //  isBlockUserChat: 0 // 0 is not blocked, 1 is Blocked by you, 2 is user has blocked you
                    let isBlockUserChat = payloadDict["isBlockUserChat"] as? Int ?? 0
                    let isBlockUserMessageChat = payloadDict["isBlockUserMessageChat"] as? String ?? ""
                    
                    if isBlockUserChat == 1{
                        self.isChatBlockByMe = 1
                    }else if isBlockUserChat == 2{
                        
                        self.isChatBlockByUser = 1
                    }else{
                        self.isChatBlockByMe = 0
                        self.isChatBlockByUser = 0
                    }
                    
                    
                    self.imgVwCelebrity.isHidden = true
                    
                    if celebrity == 1{
                        self.imgVwCelebrity.isHidden = false
                        self.imgVwCelebrity.image = PZImages.greenVerification
                    }else if celebrity == 4{
                        self.imgVwCelebrity.isHidden = false
                        self.imgVwCelebrity.image = PZImages.goldVerification
                    }else if celebrity == 5{
                        self.imgVwCelebrity.isHidden = false
                        self.imgVwCelebrity.image = PZImages.blueVerification
                    }
                    self.updateUserInfo()
                    self.tblChat.reloadAnimately {
                        
                    }
                }
            }
        }
    }
    
    
    @objc func acceptChatRequestCallBack(notification:Notification){
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            if let payloadDict = response["payload"] as? NSDictionary{
                self.fcrId = payloadDict["fcrId"] as? String ?? ""
                self.requestedUser = 1
                self.updateUserInfo()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: refreshRequestList) , object:nil, userInfo: ["fcrId":fcrId])
                let params = ["authToken":Themes.sharedInstance.getAuthToken(),"blockUserId":self.toChat] as NSDictionary
                SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_check_block_unblock_user, params)
            }
        }
    }
    
   
    func deleteMessageUpdateCell(msgIdArray:[String]){
        chatHistory.forEach({ chatObj in
            if let chatObj = chatObj as? UUMessageFrame{
                
                if msgIdArray.contains(chatObj.message.msgId){
                    
                    let index = chatHistory.index(of: chatObj)
                    chatObj.message.is_deleted = "1"
                    chatObj.message.type = MessageType(rawValue: 0)!
                    chatObj.message.message_type = "0"
                    
                    if(chatObj.message.from == MessageFrom(rawValue: 1))
                    {
                        chatObj.message.payload = "🚫 You deleted this message."
                    }else
                    {
                        chatObj.message.payload = "🚫 This message was deleted."
                    }
                    DispatchQueue.main.async{
                        self.tblChat.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                    }
                }
            }
        })
    }
    
    @objc func deleteMsgFromToStatus(notification:Notification){
        
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            
            let deleteFlag = response["deleteFlag"] as? Int ?? 0
            let from = response["from"] as? String ?? ""
            let to = response["to"] as? String ?? ""
            if toChat == to &&  from == Themes.sharedInstance.Getuser_id() && deleteFlag == 2 {
                if let payloadDict = response["mssgid"] as? [String]{
                    var index = 0
                    
                    for obj in self.chatHistory {
                        
                        if (obj as! UUMessageFrame).message.msgId == payloadDict.first {
                            
                            self.chatHistory.removeObject(at: index)
                            self.tblChat.reloadData()
                            break
                        }
                        index = index + 1
                    }
                }
            }
        }
    }
    
    
    @objc func deleteMsgStatus(notification:Notification){
        
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            
            if let payloadArray = response["payload"] as? [String]{
                
                self.deleteMessageUpdateCell(msgIdArray: payloadArray)
            }
        }
        
    }
    
    
    @objc func reloadData(notification:Notification){
        let msgObject = notification.userInfo as? NSDictionary ?? [:]
        let from:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: msgObject.object(forKey: "_id"))
        if from == toChat{
            if Themes.sharedInstance.CheckNullvalue(Passed_value: msgObject.object(forKey: "Status")) == "1"{
                self.onlineView.backgroundColor = UIColor.green
                self.onlineStatus = "Online"
            }else{
                self.onlineView.backgroundColor = UIColor.lightGray
                self.onlineStatus = "Offline"
            }
            self.lblStatus.text = onlineStatus
        }
    }
    
    @objc func typingStatus(not:Notification){
        
        if  let ResponseDict = not.userInfo as? NSDictionary {
            
            if(ResponseDict.count > 0)
            {
               // let message = ResponseDict.object(forKey: "message") as? NSDictionary ?? [:]
                let payloadDict = ResponseDict.object(forKey: "payload") as? NSDictionary ?? [:]
                let _conv_id = Themes.sharedInstance.CheckNullvalue(Passed_value: payloadDict.object(forKey: "fcrId"))
                let from = Themes.sharedInstance.CheckNullvalue(Passed_value: payloadDict.object(forKey: "senderId"))
                let typing = Themes.sharedInstance.CheckNullvalue(Passed_value: payloadDict.object(forKey: "typing"))
                
                if(from != Themes.sharedInstance.Getuser_id())
                {
                    if(_conv_id == fcrId)
                    {
                        if(!istartTyping)
                        {
                            if(typingTimer != nil)
                            {
                                typingTimer = nil
                                typingTimer?.invalidate()
                            }
                            istartTyping = true
                            if(typing == "1")
                            {
                                fromLastTypedAt = Date().currentTimeInMiliseconds()
                                lblStatus.text = "typing..."
                            }
                            
                            typingTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.StopTimer), userInfo: nil, repeats: false)
                        }
                    }
                }
            }
        }
    }
    
    @objc func StopTimer()
    {
        istartTyping = false
        if(typingTimer != nil)
        {
            typingTimer = nil
            typingTimer?.invalidate()
        }
        let  currentTime:UInt64 = Date().currentTimeInMiliseconds()
        let timeDiff = currentTime - fromLastTypedAt
        if (timeDiff > timeSize)
        {
            lblStatus.text = ""
            self.lblStatus.text = onlineStatus
        }
    }
    
    @objc func readMessageStatusUpdate(_ notify: Notification){
        
        if  let msgObject = notify.userInfo as? NSDictionary {
            
            if let payloadDict = msgObject.object(forKey: "payload") as? NSDictionary {
                
               // if payloadDict["receiverId"] as? String ?? "" == Themes.sharedInstance.Getuser_id(){
                    
                    for i in 0..<chatHistory.count{
                        let msgFrame = chatHistory[i] as! UUMessageFrame
                        if fcrId.length > 0 && fcrId == (payloadDict["fcrId"] as? String  ?? ""){
                            
                            // if toChat.elementsEqual("\(payloadDict.object(forKey: "receiverId") ?? "")"){
                            
                            //msgFrame.message.message_status = "\(msgObject.object(forKey: "messageStatus") ?? "1")"
                            if msgFrame.message.message_status != "3" {
                                msgFrame.message.message_status =  "3" //"\(msgObject.object(forKey: "status") ?? "")"
                                chatHistory[i] = msgFrame
                                tblChat.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                            }
                            //}
                            /* else if msgFrame.message.message_status != "3"{
                             msgFrame.message.message_status = "3"
                             chatHistory[i] = msgFrame
                             tblChat.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                             }*/
                        }
                    }
                    // tblChat.reloadData()
                //}
            }
        }
    }
    
    
    @objc func receiveMessage(_ notify: Notification){
        
        if let object = notify.userInfo as? NSDictionary {
            if let payloadDict = object.object(forKey: "payload") as? NSDictionary {
                if fcrId.length == 0{
                    fcrId = payloadDict.object(forKey: "fcrId") as? String ?? ""
                }
                let user_from = "\(payloadDict.object(forKey: "senderId") ?? "")"
                if  user_from == toChat {
                    Themes.sharedInstance.isChatListRefresh = 0
                    chatHistory.add(addIncomingMessage(msg: ChatHIstory(respDict: payloadDict)))
                    tblChat.beginUpdates()
                    tblChat.insertRows(at: [IndexPath(row: chatHistory.count - 1, section: 0)], with: .none)
                    tblChat.endUpdates()
                    tableViewScrollToBottom()
                    self.emitAcknowledgeChat()
                }
            }
        }
    }
    
    
    @objc func sendMessageCallback(_ notify: Notification){
        Themes.sharedInstance.isChatListRefresh = 0
        
        if let object = notify.userInfo as? NSDictionary {
            
            let msgObject = object.object(forKey: "payload") as? NSDictionary ?? [:]
            if fcrId.length == 0{
                fcrId = msgObject.object(forKey: "fcrId") as? String ?? ""
            }
            
            for i in 0..<chatHistory.count{
                
                let msgFrame = chatHistory[i] as! UUMessageFrame
                
                if msgFrame.message.doc_id.elementsEqual("\(msgObject.object(forKey: "messageDocId") ?? "")"){
                    
                    msgFrame.message.message_status = "\(msgObject.object(forKey: "messageStatus") ?? "1")"
                    msgFrame.message.timestamp = "\(msgObject.object(forKey: "timeStamp") ?? "")"
                    msgFrame.message.status = "\(msgObject.object(forKey: "status") ?? "")"
                    msgFrame.message.recordId = "\(msgObject.object(forKey: "_id") ?? "")"
                    msgFrame.message.doc_id = "\(msgObject.object(forKey: "messageDocId") ?? "")"
                    msgFrame.message.msgId = "\(msgObject.object(forKey: "_id") ?? "")"
                    msgFrame.message.to = "\(msgObject.object(forKey: "receiverId") ?? "")"
                    msgFrame.message.message_type = "\(msgObject.object(forKey: "type") ?? "")"
                    
                    if let  replyDetails = msgObject.object(forKey: "replyDetails") as? NSDictionary{
                        
                        msgFrame.message.replyObj =  ReplyInfo(respDict: replyDetails)
                    }
                    
                    if let  contactDetails = msgObject.object(forKey: "contactDetails") as? NSDictionary{
                        
                        msgFrame.message.contact_name = contactDetails["name"] as? String ?? ""
                        msgFrame.message.contact_phone =  contactDetails["mobileNumber"] as? String ?? ""
                        
                    }else if let  payload = msgObject.object(forKey: "location") as? NSDictionary{
                        
                        msgFrame.message.title_place = payload["title"] as? String ?? ""
                        msgFrame.message.stitle_place =  payload["description"] as? String ?? ""
                        msgFrame.message.imagelink =  payload["image"] as? String ?? ""
                        msgFrame.message.imageURl =  payload["link"] as? String ?? ""
                        
                    }else if let  payload = msgObject.object(forKey: "payload") as? String{
                        msgFrame.message.type = .UUMessageTypeText
                        msgFrame.message.payload = payload
                    }
                    
                    if "\(msgObject.object(forKey: "type") ?? "")" == "1"{
                        
                        if let media = msgObject.object(forKey: "media") as? Array<Any>{
                            
                            if let mediaDict = media.first as? NSDictionary{
                                msgFrame.message.url_str = mediaDict["url"] as? String ?? ""
                                msgFrame.message.thumbnail = mediaDict["thumbUrl"] as? String ?? ""
                                msgFrame.message.duration = mediaDict["duration"] as? String ?? ""
                            }
                        }
                        
                        if  checkMediaTypes(strUrl: msgFrame.message.url_str) == 1{
                            msgFrame.message.type = .UUMessageTypePicture
                        }else if checkMediaTypes(strUrl: msgFrame.message.url_str) == 3{
                            msgFrame.message.type = .UUMessageTypeVideo
                        }else if checkMediaTypes(strUrl: msgFrame.message.url_str) == 2{
                            msgFrame.message.type = .UUMessageTypeDocument
                        }
                        
                    }else if  "\(msgObject.object(forKey: "type") ?? "")" == "3"{
                        msgFrame.message.type = .UUMessageTypeContact
                    }else if   "\(msgObject.object(forKey: "type") ?? "")" == "4"{
                        msgFrame.message.type = .UUMessageTypeLocation
                    }  else if  "\(msgObject.object(forKey: "type") ?? "")" == "6"{
                        msgFrame.message.type = .UUMessageTypeVoice
                        if let media = msgObject.object(forKey: "media") as? Array<Any>{
                            
                            if let mediaDict = media.first as? NSDictionary{
                                msgFrame.message.url_str = mediaDict["url"] as? String ?? ""
                                msgFrame.message.thumbnail = mediaDict["thumbUrl"] as? String ?? ""
                                msgFrame.message.duration = mediaDict["duration"] as? String ?? ""
                            }
                        }
                    }
                    
                    if  "\(msgObject.object(forKey: "reply") ?? "")".count > 0 { //}== "5"{
                        msgFrame.message.type = .UUMessageTypeReply
                        msgFrame.message.reply_type = "\(msgFrame.message.replyObj.type)"
                        msgFrame.message.replyMsgId = "\(msgObject.object(forKey: "reply") ?? "")"
                    }
                    
                    msgFrame.message.from = .UUMessageFromMe
                    chatHistory[i] = msgFrame
                    tblChat.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                }
            }
        }
    }
    
    
    func addIncomingMessage(msg: ChatHIstory, type: MessageType = .UUMessageTypeText) -> UUMessageFrame{
        
        let newmessageFrame = UUMessageFrame()
        let message = UUMessage()
        message.type = type;
        message.senderImage = fullUrl
        message.strContent = msg.payload
        message.conv_id = msg.fcrId
        message.doc_id = "" // msg.docId
        message.filesize = ""
        message.user_from = msg.senderId
        message.isStar = "false"
        message.message_status = "3" //\(msg.messageStatus)"
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
        message.isForwarded = "\(msg.messageForward)"
        
        if msg.type == 1{
            
            message.url_str = msg.url
            message.thumbnail = msg.thumbUrl
            message.title_str = msg.payload
            
            
            if  checkMediaTypes(strUrl: message.url_str) == 1{
                message.type = .UUMessageTypePicture
            }else if checkMediaTypes(strUrl: message.url_str) == 3{
                message.type = .UUMessageTypeVideo
                message.duration = msg.duration
            }else if checkMediaTypes(strUrl: message.url_str) == 2{
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
        }else if msg.reply.count > 0 {//} == 5 {
            message.type = .UUMessageTypeReply
            message.reply_type = "\( msg.replyObj.type)"
            message.title_str = msg.replyObj.payload
            message.replyObj = msg.replyObj
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
        message.from = .UUMessageFromOther
        newmessageFrame.message = message
        return newmessageFrame
    }
}
       

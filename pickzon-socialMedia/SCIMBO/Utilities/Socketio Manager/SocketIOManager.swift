  
  //  SocketIOManager.swift
  //  SocketChat
  //  http://192.168.1.251:3002/notify
  //
  //  Created by Gabriel Theodoropoulos on 1/31/16.
  //  Copyright © 2016 AppCoda. All rights reserved.
  //
  
  import UIKit
  import CoreData
  import Foundation
  import SocketIO
  import UserNotifications
  import JSSAlertView
  import SwiftKeychainWrapper
  import SwiftyRSA
  
  typealias JSONDictionary = [String : Any]
  
  @available(iOS 10.0, *)

@objc protocol SocketIOManagerDelegate : AnyObject {
    @objc optional  func callBackImageUploaded(UploadedStr:String)
}
 

class SocketIOManager: NSObject {
    
    static let sharedInstance = SocketIOManager()
    var ResponseDict:NSDictionary?
    var socket:SocketIOClient!
    let manager = SocketManager(socketURL: URL(string: SocketCreateRoomUrl as String)!, config: [.log(false), .reconnects(true),.forcePolling(true), .reconnectAttempts(-1), .forceNew(true), .secure(true), .compress, .forceWebsockets(false),.extraHeaders(["referer":SocketCreateRoomUrl]),.connectParams(["token" : Themes.sharedInstance.Getuser_id()])])
    
    let NonEncryptionEvents = [Constant.sharedinstance.remove_user,
                               Constant.sharedinstance.sc_uploadImage,
                               Constant.sharedinstance.getFilesizeInBytes,
                               Constant.sharedinstance.create_user]
    
    override init(){
        super.init()
        socket = manager.defaultSocket
    }
    
    
    func returnDataFromEncryption(_ data : [Any]) -> NSDictionary {
        guard let data:NSDictionary = EncryptionHandler.sharedInstance.decryptData(data: data[0]) as? NSDictionary else { return [:] }
        return data
    }
    
    func emitEvent(_ event : String, _ param : Any)
    {
        if ISDEBUG == true {
            print("socketURL",socket.manager?.socketURL ?? "")
            print("nsps",socket.manager?.nsps ?? "")
            print("event: ",event,"param: ", param)
        }
        
        if NonEncryptionEvents.contains(event)
        {
            socket.emit(event, param as! NSDictionary)
            
        }else{
            if(Constant.sharedinstance.isEncryptionEnabled)
            {
                let dict = EncryptionHandler.sharedInstance.encryptData(data: param)
                socket.emit(event, dict as! String)
            }
            else
            {
                socket.emit(event, param as! NSDictionary)
            }
        }
    }
    
  
    func emitWithAck(_ event : String, _ param : Any, _ completionHandler: @escaping(_ resp: [String:Any]) -> Void) {
        
        if ISDEBUG == true {
            print("socketURL",socket.manager?.socketURL ?? "")
            print("nsps",socket.manager?.nsps ?? "")
            print("event: ",event,"param: ", param)
        }
        if NonEncryptionEvents.contains(event)
        {
            socket.emitWithAck(event, param as! NSDictionary).timingOut(after: 10.0) { (data) in
                //completionHandler(data[0] as! [String : Any])
                if ISDEBUG == true {
                    print(data[0])
                }
            }
        }else
        {
            if(Constant.sharedinstance.isEncryptionEnabled)
            {
                let dict = EncryptionHandler.sharedInstance.encryptData(data: param)
                socket.emitWithAck(event, dict as! String).timingOut(after: 10.0) { (data) in
                    // completionHandler(data[0] as! [String : Any])
                    if ISDEBUG == true {
                        print(data[0])
                    }
                }
            }
            else
            {
                socket.emitWithAck(event, param as! NSDictionary).timingOut(after: 10.0) { (data) in
                    //completionHandler(data[0] as! [String : Any])
                    if ISDEBUG == true {
                        print(data[0])
                    }
                }
            }
        }
    }
    
    
    func asString(jsonDictionary: JSONDictionary) -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
            return String(data: data, encoding: String.Encoding.utf8) ?? ""
        } catch {
            return ""
        }
    }
    
    func AddListeners()
    {
        let Nickname = Themes.sharedInstance.Getuser_id() as NSString
        ListenSocketStatusEvents(Nickname: Nickname)
        Listentochat(Nickname: Nickname)
        listenFeedSocketResponse()
        listenSocketResponse()
    }
    
    func establishConnection(Nickname:NSString,isLogin:Bool){
      
        socket.removeAllHandlers()
        AddListeners()
        socket.connect()
        print("Connecting...")
        
        socket.on(clientEvent: .connect) {data, ack in
            
            if ISDEBUG == true {
                print(data)
                print(ack)
                print("socket connected")
            }
            let param = ["authToken":Themes.sharedInstance.getAuthToken(),"userId":Themes.sharedInstance.Getuser_id(),"gcmId":"\(UserDefaults.standard.string(forKey: "fcm_token") ?? "")","deviceId":"\(Themes.sharedInstance.getDeviceUUIDString())"]
            
            if Themes.sharedInstance.Getuser_id() != "" {
                SocketIOManager.sharedInstance.online(from: Themes.sharedInstance.Getuser_id(), status: "1")
                                
                SocketIOManager.sharedInstance.emitEvent("initiateSocket", param)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.socketCnnected), object: nil, userInfo: nil)
                
                SocketIOManager.sharedInstance.online(from: Themes.sharedInstance.Getuser_id(), status: "1")
                
                SocketIOManager.sharedInstance.emitChatAndNotificationCount(userId: Themes.sharedInstance.Getuser_id())
            }
        }
        
       
        socket.on(clientEvent: .error) {data, ack in
            print("socket disconnect with Error \(data) \(ack)")
            if Themes.sharedInstance.Getuser_id().length > 0 {
                DispatchQueue.global(qos: .background).async {
                    self.socket.connect()
                }
            }
            
        }
        
        socket.on(clientEvent: .disconnect) {data, ack in
            print("socket disconnect \(data) \(ack)")
            if Themes.sharedInstance.Getuser_id().length > 0 {
                DispatchQueue.global(qos: .background).async {
                    self.socket.connect()
                }
                
            }
        }
        
    }
    
    
    
    //MARK: Go Live listenFeedSocketResponse
    
    func  listenFeedSocketResponse(){
        
        
        
        
        socket.on(Constant.sharedinstance.sio_block_unblock_user_chat) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_block_unblock_user_chat ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_block_unblock_user_chat ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        socket.on(Constant.sharedinstance.sio_action_on_live) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_action_on_live ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_action_on_live ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        
        
        socket.on(Constant.sharedinstance.sio_restart_pk) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_restart_pk ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_restart_pk ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        socket.on(Constant.sharedinstance.sio_report_live_pk) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_report_live_pk ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_report_live_pk ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        socket.on(Constant.sharedinstance.sio_play_random_pk) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_play_random_pk ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_play_random_pk ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket.on(Constant.sharedinstance.sio_leave_random_pk) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_leave_random_pk ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_leave_random_pk ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        socket.on(Constant.sharedinstance.sio_get_live_status) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_get_live_status ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_live_status ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
         
        socket.on(Constant.sharedinstance.sio_top_gifters) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_top_gifters ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_top_gifters ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket.on(Constant.sharedinstance.sio_feed_live_users) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_feed_live_users ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_live_users ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        socket.on(Constant.sharedinstance.sio_pk_result) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_pk_result ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_pk_result ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        socket.on(Constant.sharedinstance.sio_block_user) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_block_user ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_block_user ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket.on(Constant.sharedinstance.sio_send_gift_pk) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_send_gift_pk ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_send_gift_pk ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        socket.on(Constant.sharedinstance.sio_kick_out) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_kick_out ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_kick_out ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        socket.on(Constant.sharedinstance.sio_pk_request_count) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_pk_request_count ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_pk_request_count ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        socket.on(Constant.sharedinstance.sio_get_all_live_user_list) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_get_all_live_user_list ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_all_live_user_list ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        socket.on(Constant.sharedinstance.sio_get_golive_endlive_user_info) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_get_golive_endlive_user_info ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_golive_endlive_user_info ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket.on(Constant.sharedinstance.sio_get_followers_live_list) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_get_followers_live_list ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_followers_live_list ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket.on(Constant.sharedinstance.sio_exit_go_live_host_user) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_exit_go_live_host_user ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_exit_go_live_host_user ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket.on(Constant.sharedinstance.sio_get_live_pk_info) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_get_live_pk_info ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_live_pk_info ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        socket.on(Constant.sharedinstance.sio_start_live_pk) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_start_live_pk ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_start_live_pk ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket.on(Constant.sharedinstance.sio_accept_live_pk_request) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_accept_live_pk_request ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_accept_live_pk_request ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket.on(Constant.sharedinstance.sio_reject_live_pk_request) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_reject_live_pk_request ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_reject_live_pk_request ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        socket.on(Constant.sharedinstance.sio_get_all_live_friend_list) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_get_all_live_friend_list ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_all_live_friend_list ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket.on(Constant.sharedinstance.sio_live_pk_time_slot) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_live_pk_time_slot ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_live_pk_time_slot ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket.on(Constant.sharedinstance.sio_like_live_broadcast) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_like_live_broadcast ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_like_live_broadcast ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket.on(Constant.sharedinstance.sio_join_user_room) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_join_user_room ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_join_user_room ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket.on(Constant.sharedinstance.sio_get_comment_message_list) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_get_comment_message_list ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_comment_message_list ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        socket.on(Constant.sharedinstance.sio_get_user_info) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_get_user_info ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_user_info ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        socket.on(Constant.sharedinstance.sio_leave_user_room) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_leave_user_room ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_leave_user_room ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket.on(Constant.sharedinstance.sio_get_live_join_user_count) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_get_live_join_user_count ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_live_join_user_count ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket.on(Constant.sharedinstance.sio_get_join_user_list) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_get_join_user_list ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_join_user_list ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket.on(Constant.sharedinstance.sio_get_all_user_pk_request_list) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_get_all_user_pk_request_list ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_all_user_pk_request_list ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        socket.on(Constant.sharedinstance.sio_send_live_pk_request) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_send_live_pk_request ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_send_live_pk_request ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket.on(Constant.sharedinstance.sio_send_comment_message) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_send_comment_message ) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_send_comment_message ), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
       
        
        socket.on(Constant.sharedinstance.sio_feed_fetch_user_chat_list) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_feed_fetch_user_chat_list) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_fetch_user_chat_list), object: nil, userInfo: responseDict as? [AnyHashable : Any])
                
            }
        }
        
        socket.on(Constant.sharedinstance.sio_feed_receive_new_user_list) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_feed_receive_new_user_list) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_receive_new_user_list), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        socket.on(Constant.sharedinstance.sio_feed_chat_acknowledge_chat) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_feed_chat_acknowledge_chat) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_chat_acknowledge_chat), object: nil, userInfo: responseDict as? [AnyHashable : Any])
                
            }
        }
    }
    
    
    
    
    func emitChaWithCallBack(params:NSDictionary,eventName:String){
        
        
        if ISDEBUG == true {
            print("socketURL",socket.manager?.socketURL ?? "")
            print("event: ",eventName,"param: ", params)
        }
        
        socket.emitWithAck(eventName, with: [params]).timingOut(after: 0) { data  in
            
            if let responseDict = data[0] as? NSDictionary{
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: eventName), object: nil, userInfo: responseDict as? [AnyHashable : Any])
                
                if ISDEBUG == true {
                    print("fetch_mall_user_chat_list =>\(responseDict)")
                }
            }
            
            
        }
        
    }
    
    
    //MARK: - newly added listeners
    
    func  listenSocketResponse(){
                
        socket.on(Constant.sharedinstance.sio_logout_from_all_device) { data, ack in
          
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.sio_logout_from_all_device) responseDict =>\(responseDict)")
                }
        /* NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_logout_from_all_device), object: nil, userInfo: responseDict as? [AnyHashable : Any])*/
                
                if let payloadDict = responseDict.object(forKey: "payload") as? NSDictionary {
                    
                    if payloadDict["userId"] as? String ?? "" == Themes.sharedInstance.Getuser_id(){
                        
                        if let message = responseDict.object(forKey: "message") as? String {
                            
                            AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["Ok"], onController: (AppDelegate.sharedInstance.navigationController?.topViewController)!) { title, index in
                                DBManager.shared.clearDB()
                                (UIApplication.shared.delegate as! AppDelegate).Logout(istocallApi: false)
                            }
                        }
                    }
                }
            }
        }
        
        
        socket.on(Constant.sharedinstance.feed_chat_list) { data, ack in
            print("\(Constant.sharedinstance.feed_chat_list) responseDict =")
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("\(Constant.sharedinstance.feed_chat_list) responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.feed_chat_list), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        socket.on(Constant.sharedinstance.socketConnected) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("socketConnected responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.socketCnnected), object: nil, userInfo: nil)
            }
        }
        
        socket.on(Constant.sharedinstance.sio_check_block_unblock_user) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("sio_check_block_unblock_user responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_check_block_unblock_user), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        socket.on(Constant.sharedinstance.sio_change_online_offline_status) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("sio_change_online_offline_status responseDict =>\(responseDict)")
                }
                //  NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_chat_typing), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket.on(Constant.sharedinstance.sio_feed_chat_typing) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("sio_feed_chat_typing responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_chat_typing), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        socket.on(Constant.sharedinstance.sio_feed_clear_user_chat_list) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("sio_feed_clear_user_chat_list responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_clear_user_chat_list), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket.on(Constant.sharedinstance.sio_feed_accept_chat_request) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("sio_feed_accept_chat_request responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_accept_chat_request), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket.on(Constant.sharedinstance.sio_fetch_user_info) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("sio_fetch_user_info responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_fetch_user_info), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        socket.on(Constant.sharedinstance.sio_feed_receive_chat_message) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("sio_feed_receive_chat_message responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_receive_chat_message), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        socket.on(Constant.sharedinstance.sio_feed_send_chat_message) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("sio_feed_send_chat_message responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_send_chat_message), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        
        socket.on(Constant.sharedinstance.sio_feed_delete_user_chat) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("sio_feed_delete_user_chat responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_feed_delete_user_chat), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        
        socket.on(Constant.sharedinstance.sio_fetch_online_offline_status) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("sio_fetch_online_offline_status responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_fetch_online_offline_status), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
        }
        
        

        
        socket.on(Constant.sharedinstance.socket_error) { data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("socekt-error responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.socket_error), object: nil, userInfo: responseDict as? [AnyHashable : Any])
                
            }
        }
        
        
        //Radhe
        socket.on(Constant.sharedinstance.sc_feed_notification_ack) {data, ack in
            
            if let responseDict = data[0] as? NSDictionary{
                if ISDEBUG == true {
                    print("sc_feed_notification_ack responseDict =>\(responseDict)")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: noti_RefreshChatCount), object: nil, userInfo: responseDict as? [AnyHashable : Any])
                
            }
            
        }
        
    }
    
    
    
    
    func ListenSettings(Nickname: NSString) {
     
    }
    
    
    
    
    
    
    func ListenUserAuthenticated(Nickname: NSString)
    {
        socket.on(Constant.sharedinstance.userauthenticated as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
                if Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "msg")) != "" {
                    if(AppDelegate.sharedInstance.navigationController?.presentedViewController != nil)
                    {
                        
                        AppDelegate.sharedInstance.navigationController?.dismissView(animated: true, completion: {
                            let alertview = JSSAlertView().show(
                                (AppDelegate.sharedInstance.navigationController?.topViewController)!,
                                title: Themes.sharedInstance.GetAppname(),
                                text: Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "msg")),
                                buttonText: "Ok",
                                cancelButtonText: nil
                            )
                            alertview.addAction(self.LogOut)
                        })
                    }
                    else
                    {
                        let alertview = JSSAlertView().show(
                            (AppDelegate.sharedInstance.navigationController?.topViewController)!,
                            title: Themes.sharedInstance.GetAppname(),
                            text: Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "msg")),
                            buttonText: "Ok",
                            cancelButtonText: nil
                        )
                        alertview.addAction(self.LogOut)
                    }
                }
            }
        }
        
    }
    
    
    
    
    func GetFavContact(Dict:NSDictionary)
    {
        emitEvent(Constant.sharedinstance.sio_get_phone_contact, Dict)
    }
    
 
    
    func ListenSocketStatusEvents(Nickname: NSString) {
        socket.on(Constant.sharedinstance.Connect as String) {data, ack in
            // Themes.sharedInstance.showWaitingNetwork(false, state: true)
        }
        
        socket.on(Constant.sharedinstance.network_disconnect as String) {data, ack in
            if ISDEBUG == true {
                print("..Check Socket dis Connection.....\(data).........")
            }
            //  Themes.sharedInstance.showWaitingNetwork(false, state: false)
            if let responseDict = data[0] as? NSDictionary{
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.socket_error), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
            
        }
        
        socket.on(Constant.sharedinstance.network_error as String) {data, ack in
            if ISDEBUG == true {
                print("..Check ERROR.....\(data).........")
            }
            if let responseDict = data[0] as? NSDictionary{
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.socket_error), object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
            
        }
    }
    
    
    
    func Listentochat(Nickname:NSString)
    {
        
        socket.on(Constant.sharedinstance.qrdata as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr != "1")
            {
            }
        }
        socket.on(Constant.sharedinstance.sc_get_server_time as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: (data ).object(forKey: "err"));
            if(ErrorStr == "1" || ErrorStr == "")
            {
            }
            else
            {
                let ResponseDict:NSDictionary=data;
                
                let timestamp = Int64(String(Date().ticks))!
                
                let server_time = Int64(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "server_time")))!
                
                let client_time = Int64(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "client_time")))!
                let server_time_diff = timestamp - (server_time + (timestamp - client_time)) ;
                Themes.sharedInstance.saveServerTime(serverDiff: "\(server_time_diff)", serverTime: "\(server_time)")
            }
        }
        
        
        //Removed Jun 15, 2022 as there was some issue reported from backend
        socket.on(Constant.sharedinstance.sio_get_phone_contact as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            if ISDEBUG == true {
                print("\(Constant.sharedinstance.sio_get_phone_contact) Response: ", data)
            }
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: (data  ).object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }
        }
        
        
        
        socket.on(Constant.sharedinstance.updateMobilePushNotificationKey as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: (data ).object(forKey: "err"))
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict:NSDictionary!=data
                if ISDEBUG == true {
                    print("socket.on: updateMobilePushNotificationKey", ResponseDict)
                }
                let apiMobile:NSDictionary = ResponseDict.object(forKey: "apiMobileKeys") as! NSDictionary
                let login_key = Themes.sharedInstance.CheckNullvalue(Passed_value: apiMobile.object(forKey: "login_key"))
                let loginDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Login_details, attribute: "user_id", FetchString:  Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! [Login_details]
                if(loginDetails.count > 0)
                {
                    let ResponseDictionary = loginDetails[0]
                    let my_login_key = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDictionary.login_key)
                    if(Int(login_key) != nil && Int(my_login_key) != nil)
                    {
                        if(Int(login_key)! > Int(my_login_key)!)
                        {
                            let alertview = JSSAlertView().show(
                                (AppDelegate.sharedInstance.navigationController?.topViewController)!,
                                title: Themes.sharedInstance.GetAppname(),
                                text: "Your account has been logged in another device.",
                                buttonText: "Ok",
                                cancelButtonText: nil
                            )
                            alertview.addAction(self.LogOut)
                        }
                    }
                }
            }
        }
        
        socket.on(Constant.sharedinstance.checkMobileLoginKey as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"))
            if(ErrorStr == "1")
            {
            }
            else
            {
                
                let ResponseDict : NSDictionary = data
                let apiMobile:NSDictionary = ResponseDict.object(forKey: "apiMobileKeys") as! NSDictionary
                let login_key = Themes.sharedInstance.CheckNullvalue(Passed_value: apiMobile.object(forKey: "login_key"))
                let loginDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Login_details, attribute: "user_id", FetchString:  Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! [Login_details]
                if(loginDetails.count > 0)
                {
                    let ResponseDictionary = loginDetails[0]
                    let my_login_key = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDictionary.login_key)
                    if(Int(login_key) != nil && Int(my_login_key) != nil)
                    {
                        if(Int(login_key)! > Int(my_login_key)!)
                        {
                            let alertview = JSSAlertView().show(
                                (AppDelegate.sharedInstance.navigationController?.topViewController)!,
                                title: Themes.sharedInstance.GetAppname(),
                                text: "Your account has been logged in another device.",
                                buttonText: "Ok",
                                cancelButtonText: nil
                            )
                            alertview.addAction(self.LogOut)
                        }
                    }
                }
            }
        }
        
        
        

        socket.on(Constant.sharedinstance.sc_get_user_Details as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }else{
                let ResponseDict : NSDictionary = data
                if(ResponseDict.count > 0){
                    let from:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
                    let Checkfav:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: from)
                    if(!Checkfav) {
                        ContactHandler.sharedInstance.savenonfavArr(ResponseDict: ResponseDict)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: nil)
                    }
                }
            }
        }
        
        socket.on(Constant.sharedinstance.sc_change_online_status as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }else{
                let ResponseDict : NSDictionary = data
                if ISDEBUG == true {
                    print("Socket : sc_change_online_status Response:->", ResponseDict)
                }
                
                if(ResponseDict.count > 0){
                    let from:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "_id"))
                    let status:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "Status"))
                    var timeStamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "DateTime"))
                    if(timeStamp == ""){
                        timeStamp = String(Date().ticks)
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadFeedData), object: nil , userInfo:ResponseDict as! [String : Any])
                    
                    
                    let Checkuser:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: from)
                    
                    
                    
                    if(Checkuser)
                    {
                        
                        let dict:NSDictionary = ["is_online":status,"time_stamp":timeStamp]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: from, attribute: "id", UpdationElements: dict as NSDictionary?)
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo:nil)
                        
                        
                    }
                    
                }
            }
        }
        
        
        
        socket.on(Constant.sharedinstance.sc_online_status as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }else{
                let ResponseDict : NSDictionary = data
                if(ResponseDict.count > 0){
                    let from:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "_id"))
                    let status:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "Status"))
                    var timeStamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "DateTime"))
                    if(timeStamp == ""){
                        timeStamp = String(Date().ticks)
                    }
                    let privacy:NSDictionary = ResponseDict.object(forKey: "Privacy") as! NSDictionary
                    let last_seen:String = Themes.sharedInstance.CheckNullvalue(Passed_value: privacy.object(forKey: "last_seen"))
                    let profile_photo:String = Themes.sharedInstance.CheckNullvalue(Passed_value: privacy.object(forKey: "profile_photo"))
                    let show_status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: privacy.object(forKey: "status"))
                    let Checkuser:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: from)
                    if(Checkuser)
                    {
                        let dict:NSDictionary = ["is_online":status,"time_stamp":timeStamp,"last_seen":last_seen,"profile_photo":profile_photo,"show_status":show_status]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: from, attribute: "id", UpdationElements: dict as NSDictionary?)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: ResponseDict , userInfo:dict as? [AnyHashable : Any])
                    }
                    
                }
                
                
            }
        }
        
        
    }
    
    func LogOut()
    {
        AppDelegate.sharedInstance.Logout()
    }
    
    
 
    
    func  viewOtherStoryStatus(userId:String,statusId:String){
        
        let reqDict = [ "userId": userId, "statusId": statusId] as [String : Any]
        
        emitEvent(Constant.sharedinstance.sc_see_status, reqDict)
        
        socket.on(Constant.sharedinstance.sc_see_status) { data, ack in
            
        }
    }
    
    func  emitChatAndNotificationCount(userId:String){
        
        let reqDict = [ "from": userId] as [String : Any]
        
        emitEvent(Constant.sharedinstance.sc_feed_notification, reqDict)
        
    }
    
    func online(from:String,status:String){
        let param = ["authToken":Themes.sharedInstance.getAuthToken(),"status":status]
        emitEvent(Constant.sharedinstance.sio_change_online_offline_status, param)
    }
    
    
    //MARK: - Generic Deserilizer Method
    func populateData<T>(_ arg : Any) -> T where T:JsonDeserilizer{
        
        var instance = T.init()
        let responseConverted = arg as! [String:Any]
        
        instance.deserilize(values:responseConverted)
        return instance
    }
}

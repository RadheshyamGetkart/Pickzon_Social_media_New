//
//  FeedChatVC+ChatTable.swift
//  SCIMBO
//
//  Created by Getkart on 02/08/21.
//  Copyright © 2021 Radheshyam Yadav. All rights reserved.
//

import Foundation
import UIKit
import Contacts
import ContactsUI
import MessageUI
import Social
import SimpleImageViewer
import ActionSheetPicker_3_0
import SwiftyGiphy
import SwiftyGif
import AVKit
import CoreLocation
import Kingfisher
import FittedSheets
import MessageUI
import QuickLook
import Alamofire

extension FeedChatVC:OptionDelegate{
    //MARK: - Delegete method of bottom sheet view
    func selectedOption(index:Int,videoIndex:Int,title:String){
        if title == "Clear All Chat"{
            AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to clear all messages?", buttonTitles: ["No","Yes"], onController: self) { title, index in
                
                if index == 1{
                    self.emitClearChat(type : 0)
                }
            }
            
        }else if title == "Report"{
            
            let destVc:ReportUserVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ReportUserVC") as! ReportUserVC
            destVc.modalPresentationStyle = .overCurrentContext
            destVc.modalTransitionStyle = .coverVertical
            destVc.reportType = .chat
            destVc.reportingId = toChat
            self.present(destVc, animated: true, completion: nil)
            
        }else if title == "View Profile"{
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn = toChat
            self.navigationController?.pushViewController(profileVC, animated: true)
            
        }else if title == "Block User"{
            self.openBlockConfirmation()
            
        }else if title == "Unblock User"{
            self.openBlockConfirmation()
        }else if title == "Unblock Chat"{
            self.openChatBlockConfirmation()
        }else if title == "Block Chat"{
            self.openChatBlockConfirmation()

        }
    }
    
   
    func openMoreOptions(){
        
        let controller = UIStoryboard(name: "TableViewDemo", bundle: nil).instantiateInitialViewController()! as! TableViewDemo
        let blockUnblock = (blockByMe == 1) ? "Unblock User" : "Block User"
        let isChatBlock = (isChatBlockByMe == 1) ? "Unblock Chat" : "Block Chat"

        
        controller.listArray = ["View Profile","Report","Clear All Chat",blockUnblock,isChatBlock]
        controller.iconArray =  ["User","Report","Delete1","BlockAccount","chatb"]
        
        controller.videoIndex = 0
        controller.delegate = self
        let useInlineMode = view != nil
        let sheet = SheetViewController(
            controller: controller,
            sizes: [.percent(0.30), .intrinsic],
            options: SheetOptions(useFullScreenMode:false, shrinkPresentingViewController:false, useInlineMode: useInlineMode))
        sheet.allowPullingPastMaxHeight = false
        if let view = view {
            sheet.animateIn(to: view, in: self)
        } else {
            self.present(sheet, animated: true, completion: nil)
        }
    }
    
    
    
    func openChatBlockConfirmation(){
        
        let title = (isChatBlockByMe == 1) ? "Unblock Chat" : "Block Chat"
        let message = (isChatBlockByMe == 1) ? "Do you really want to unblock this chat?" : "Do you really want to block this chat?"
     
        let actionSheetAlertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        actionSheetAlertController.addAction(cancel)
        
        let blockUser = UIAlertAction(title: "Block", style: .default) { (action) in
            self.emitBlockUnblockChat(isToBlock: true)
            
        }
        let unblockUser = UIAlertAction(title: "Unblock", style: .default) { (action) in
            
            self.emitBlockUnblockChat(isToBlock: false)
        }
        (isChatBlockByMe == 1) ? actionSheetAlertController.addAction(unblockUser) : actionSheetAlertController.addAction(blockUser)
        
        self.present(actionSheetAlertController, animated: true, completion: nil)
    }
    
    
    func openBlockConfirmation(){
        
        let title = (blockByMe == 1) ? "Unblock User" : "Block User"
        let message = (blockByMe == 1) ? "Do you really want to unblock this user?" : "Do you really want to block this user?"
        
        let actionSheetAlertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        actionSheetAlertController.addAction(cancel)
        
        let blockUser = UIAlertAction(title: "Block", style: .default) { (action) in
            self.blockUnblockUserApi(isToBlock: true)
            
        }
        let unblockUser = UIAlertAction(title: "Unblock", style: .default) { (action) in
            
            self.blockUnblockUserApi(isToBlock: false)
        }
        (blockByMe == 1) ? actionSheetAlertController.addAction(unblockUser) : actionSheetAlertController.addAction(blockUser)
        
        self.present(actionSheetAlertController, animated: true, completion: nil)
    }
    
    func openDeleteChatConfirmation(){
        let actionSheetAlertController: UIAlertController = UIAlertController(title: "Delete Chat", message: "Do you really want to delete this conversation?", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (action) in
            
        }
        actionSheetAlertController.addAction(cancel)
        
        let deleteChat = UIAlertAction(title: "Delete Chat", style: .default) { (action) in
            self.emitClearChat(type: 0)
        }
        actionSheetAlertController.addAction(deleteChat)
        self.present(actionSheetAlertController, animated: true, completion: nil)
        
    }
    
    
    func messageAlertWithReport() {
        
        let alertController = UIAlertController(title: "Report ", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Submit", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            if (firstTextField.text?.trim().count ?? 0 > 0){
                self.reportUserApi(reason: firstTextField.text!)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in })
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Report message"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: API methods
    
    func reportUserApi(reason:String){
        
        DispatchQueue.main.async {
            Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
        }
        
        let params = NSMutableDictionary()
        params.setValue(toChat, forKey: "reportUserId")
        params.setValue(reason, forKey: "reason")
        
        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.reportUserProfile, param: params) { responseObject, error in
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)}
            
            if(error != nil)
            {
                DispatchQueue.main.async {
                    
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    print(error ?? "defaultValue")
                }
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
            }
        }
    }
    
    
    
    func emitBlockUnblockChat(isToBlock:Bool){
        
        let params = ["authToken":Themes.sharedInstance.getAuthToken(),"blockUserId":self.toChat] as NSDictionary
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_block_unblock_user_chat, params)
    }

    
    func blockUnblockUserApi(isToBlock:Bool){
        
        let param:NSDictionary = ["blockuserId":toChat,"key":(isToBlock) ? 1 : 0]
        
        URLhandler.sharedinstance.makeCall(url: Constant.sharedinstance.blockUnblockuser, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
                
                if status == 1 {
                    
                    let params = ["authToken":Themes.sharedInstance.getAuthToken(),"blockUserId":self.toChat] as NSDictionary
                    SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_check_block_unblock_user, params)
                    
                    AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: message as? NSString ?? "", buttonTitles: ["OK"], onController: self) { title, index in
                        //self.navigationController?.popViewController(animated: true)
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: noti_RefreshFeed), object:nil)
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    func getAllStatusListApi(storyId:String){
        
        let params = NSMutableDictionary()
        params.setValue(UserDefaults.standard.string(forKey: "fcm_token") ?? "", forKey: "gcm_id")
        params.setValue(Themes.sharedInstance.getAppVersion(), forKey: "appVersion")
        params.setValue("ios", forKey: "OS")
        params.setValue(storyId, forKey: "storyId")

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
                    let availableStatus = payload["availableStatus"] as? Int ?? 0
                    
                    var wallStatusArray = [WallStatus]()

                    let data = payload["wallstatus"] as? NSArray ?? []
                    if data.count > 0{
                        for obj in data {
                            
                            if let statusDict = obj as? NSDictionary {
                                
                                wallStatusArray.append(WallStatus(responseDict: statusDict))
                            }
                        }
                        
                        if storyId.count > 0 {
                            self.pushToSpecifiedStory(statusId: storyId, wallStatusArray: wallStatusArray)
                        }
//                        DispatchQueue.main.async {
//
//                            let vc = StoryBoard.main.instantiateViewController(withIdentifier: "StoryPageViewVC") as! StoryPageViewVC
//                            vc.isMyStatus = false
//                            vc.currentStatusIndex = 0
//                            vc.wallStatusArray  =  wallStatusArray
//                            vc.view.backgroundColor = .black
//                            vc.modalPresentationStyle = .custom
//                            self.navigationController?.pushViewController(vc, animated: true)
//
//                        }
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

extension FeedChatVC:StoryPageViewControllerDelegate{
   
    func DidDismiss() {
        
    }
    
    func didclickedViewCount() {
        
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
                let status = result["status"]  as? Int64  ?? 0

                let message = result["message"]
                
                if status == 1{
                   // self.getAllStatusListApi(isToShowLoader: false)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: noti_RefreshStory), object:nil)
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

extension FeedChatVC: UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate,ReplyDetailViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  self.chatHistory.count
        
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let messageFrame:UUMessageFrame = self.chatHistory[indexPath.row] as! UUMessageFrame
        var cell_main : UITableViewCell = UITableViewCell()
        messageFrame.isChatRequested =  Int32(self.requestedUser)
        if messageFrame.message.info_type == "0" {
            let cell1 = TableviewCellGenerator.sharedInstance.returnCell(for: tableView, messageFrame: messageFrame, indexPath: indexPath, searchedText: "")
            
           
            //cell1.isChatRequested = self.requestedUser
            cell1.delegate = self
            cell1.RowIndex = indexPath
            cell1.customButton.addTarget(self, action: #selector(self.didClickCellButton(_:)), for: .touchUpInside)
            cell1.contentView.tag = indexPath.row
            cell1.contentView.tag = indexPath.row
            let long = UILongPressGestureRecognizer(target: self, action: #selector(self.longGestureCellAction(_:)))
            long.delegate = self
            cell1.contentView.addGestureRecognizer(long)
            //            let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureCellAction(_:)))
            //            pan.delegate = self
            //             cell1.contentView.addGestureRecognizer(pan)
            
            let left = UISwipeGestureRecognizer(target : self, action : #selector(Swipeleft(_ : )))
            left.direction = .left
            cell1.contentView.addGestureRecognizer(left)
            
            let right = UISwipeGestureRecognizer(target : self, action : #selector(Swiperight(_ : )))
            right.direction = .right
            cell1.contentView.addGestureRecognizer(right)
           // cell1.transform = CGAffineTransformMakeScale(1, -1);

            return cell1
            
        }else if(messageFrame.message.info_type == "72"){
            
            let encryptiocell:EncryptionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "EncryptionTableViewCell") as! EncryptionTableViewCell
            encryptiocell.msgLbl.layer.cornerRadius = 5.0
            encryptiocell.msgLbl.text = "🔒 Messages to this chat are now secured with end-to-end encryption"
           // encryptiocell.transform = CGAffineTransformMakeScale(1, -1);

            return encryptiocell
        }else{
            
            let cell:ChatInfoCell = tableView.dequeueReusableCell(withIdentifier: "ChatInfoCell") as! ChatInfoCell
            cell.Info_Btn.tag = indexPath.row
            var infoStr : String = String()
            var dateStr : String = String()
            
            cell.Info_Btn.isHidden = true
            cell.date_lbl.isHidden = false
            dateStr = Themes.sharedInstance.ReturnDateTimeFormat(timestamp: messageFrame.message.timestamp)
            var Info_Btnsize: CGSize = (infoStr as NSString).size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16.0)])
            Info_Btnsize.width = Info_Btnsize.width >= self.view.frame.size.width ? self.view.frame.size.width - 10 : Info_Btnsize.width
            
            cell.Info_Btn.frame = CGRect(x: ((cell.frame.size.width) - Info_Btnsize.width)/2  , y: ((cell.frame.size.height) - Info_Btnsize.height)/2 , width: Info_Btnsize.width, height: Info_Btnsize.height)
            
            cell.Info_Btn.setTitle(infoStr, for: .normal)
            
            var date_lblsize: CGSize = (dateStr as NSString).size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16.0)])
            date_lblsize.width = date_lblsize.width >= self.view.frame.size.width ? self.view.frame.size.width - 10 : date_lblsize.width
            
            cell.date_lbl.frame = CGRect(x: ((cell.frame.size.width) - date_lblsize.width + 5)/2  , y: ((cell.frame.size.height) - date_lblsize.height)/2 , width: date_lblsize.width + 5, height: date_lblsize.height)
            cell.date_lbl.setTitle(dateStr, for: .normal)
            cell_main = cell
            
        }
        cell_main.selectionStyle = .blue
        cell_main.backgroundColor =  UIColor.clear
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        cell_main.selectedBackgroundView = backgroundView
       // cell_main.transform = CGAffineTransformMakeScale(1, -1);

        return cell_main
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(indexPath.section == 0)
        {
            let chat_Obj:UUMessageFrame = self.chatHistory[indexPath.row] as! UUMessageFrame
            if(chat_Obj.message.info_type == "0")
            {
                return true
            }
            return false
        }
        else
        {
            return false
        }
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.transform = self.tblChat.transform;
//
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        var cell:ChatInfoCell? = tableView.dequeueReusableCell(withIdentifier: "ChatInfoCell") as! ChatInfoCell?
        let messageFrame: UUMessageFrame = self.chatHistory[indexPath.row] as! UUMessageFrame
        if cell == nil {
            cell = ChatInfoCell(style: .default, reuseIdentifier: "ChatInfoCell")
            //cell?.contentView.backgroundColor = UIColor.clear
        }
        
        
        if(isBeginEditing)
        {
            
            if(tblChat.indexPathsForSelectedRows != nil)
            {
                let indexpath:[IndexPath] = tblChat.indexPathsForSelectedRows!
                
                if(indexpath.count > 0)
                {
                    left_item.isEnabled = true
                    center_item.isEnabled = true
                    
                }
                else
                {
                    left_item.isEnabled = false
                    center_item.isEnabled = false
                    
                }
            }
            else
            
            {
                left_item.isEnabled = false
                center_item.isEnabled = false
                
            }
            self.center_item.title = "\(tblChat.indexPathsForSelectedRows?.count ?? 0) Selected"
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if(isBeginEditing)
        {
            if(tblChat.indexPathsForSelectedRows != nil)
            {
                let indexpath:[IndexPath] = tblChat.indexPathsForSelectedRows!
                
                if(indexpath.count > 0)
                {
                    left_item.isEnabled = true
                    center_item.isEnabled = true
                }
                else
                {
                    left_item.isEnabled = false
                    center_item.isEnabled = false
                }
            }
            else
            {
                left_item.isEnabled = false
                center_item.isEnabled = false
            }
            self.center_item.title = "\(tblChat.indexPathsForSelectedRows?.count ?? 0) Selected"
        }
    }
    
    
    @objc func didClickCellButton(_ sender: UIButton){
        
        if  self.requestedUser == 0{
            return
        }
        
        guard !isBeginEditing else{
            let row:Int = (sender as AnyObject).tag
            guard self.chatHistory.count > row else{return}
            let indexpath = NSIndexPath.init(row: row, section: 0)
            self.firstIndexpath = indexpath as IndexPath
            
            if let cell = tblChat.cellForRow(at: self.firstIndexpath) {
                if cell.isSelected {
                    tblChat.deselectRow(at: firstIndexpath, animated: false)
                    tableView(tblChat, cellForRowAt: firstIndexpath)
                }else {
                    tblChat.selectRow(at: firstIndexpath, animated: false, scrollPosition: .none)
                    tableView(tblChat, cellForRowAt: firstIndexpath)
                }
            }
            return
        }
        
        //        if(pause_row != sender.tag)
        //        {
        //            self.pauseGif()
        //        }
        let row:Int = sender.tag
        //        pause_row = row
        //        initial = 1
        
        guard self.chatHistory.count > row else{return}
        let messageFrame: UUMessageFrame = self.chatHistory[row] as! UUMessageFrame
        // self.PausePlayingAudioIfAny()
        let indexpath = NSIndexPath.init(row: row, section: 0)
        
        if let cellItem:CustomTableViewCell = self.tblChat.cellForRow(at: indexpath as IndexPath) as? CustomTableViewCell {
            switch cellItem.messageFrame.message.type{
                
            case MessageType(rawValue: 7):
                
                var index = 0
                for obj in chatHistory{
                    
                    if let  msgObj = obj as? UUMessageFrame {
                        if msgObj.message.msgId == messageFrame.message.replyMsgId{
                            
                            UIView.animate(withDuration: 0.1, animations: {
                                
                                self.tblChat.isPagingEnabled = true
                                self.tblChat.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: false)
                                self.tblChat.isPagingEnabled = false
                            }, completion: {_ in
                                
                                if let cell = self.tblChat.cellForRow(at: IndexPath(row: index, section: 0)) as? TextTableViewCell {
                                    cell.chatView.layer.borderColor = UIColor.orange.cgColor
                                    cell.chatView.layer.borderWidth = 3.0
                                }else if let cell = self.tblChat.cellForRow(at: IndexPath(row: index, section: 0)) as? AudioTableViewCell {
                                    cell.chatView.layer.borderColor = UIColor.orange.cgColor
                                    cell.chatView.layer.borderWidth = 3.0
                                }else if let cell = self.tblChat.cellForRow(at: IndexPath(row: index, section: 0)) as? ImageTableViewCell {
                                    cell.chatView.layer.borderColor = UIColor.orange.cgColor
                                    cell.chatView.layer.borderWidth = 3.0
                                }else if let cell = self.tblChat.cellForRow(at: IndexPath(row: index, section: 0)) as? DocTableViewCell {
                                    cell.chatView.layer.borderColor = UIColor.orange.cgColor
                                    cell.chatView.layer.borderWidth = 3.0
                                }else if let cell = self.tblChat.cellForRow(at: IndexPath(row: index, section: 0)) as? ContactTableViewCell {
                                    cell.chatView.layer.borderColor = UIColor.orange.cgColor
                                    cell.chatView.layer.borderWidth = 3.0
                                }else if let cell = self.tblChat.cellForRow(at: IndexPath(row: index, section: 0)) as? ReplayTableViewCell {
                                    cell.chatView.layer.borderColor = UIColor.orange.cgColor
                                    cell.chatView.layer.borderWidth = 3.0
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    if let cell = self.tblChat.cellForRow(at: IndexPath(row: index, section: 0)) as? TextTableViewCell {
                                        cell.chatView.layer.borderColor = UIColor.clear.cgColor
                                        cell.chatView.layer.borderWidth = 0.0
                                    }else if let cell = self.tblChat.cellForRow(at: IndexPath(row: index, section: 0)) as? AudioTableViewCell {
                                        cell.chatView.layer.borderColor = UIColor.clear.cgColor
                                        cell.chatView.layer.borderWidth = 0.0
                                    }else if let cell = self.tblChat.cellForRow(at: IndexPath(row: index, section: 0)) as? ImageTableViewCell {
                                        cell.chatView.layer.borderColor = UIColor.clear.cgColor
                                        cell.chatView.layer.borderWidth = 0.0
                                    }else if let cell = self.tblChat.cellForRow(at: IndexPath(row: index, section: 0)) as? DocTableViewCell {
                                        cell.chatView.layer.borderColor = UIColor.clear.cgColor
                                        cell.chatView.layer.borderWidth = 0.0
                                    }else if let cell = self.tblChat.cellForRow(at: IndexPath(row: index, section: 0)) as? ContactTableViewCell {
                                        cell.chatView.layer.borderColor = UIColor.clear.cgColor
                                        cell.chatView.layer.borderWidth = 0.0
                                    }else if let cell = self.tblChat.cellForRow(at: IndexPath(row: index, section: 0)) as? ReplayTableViewCell {
                                        cell.chatView.layer.borderColor = UIColor.clear.cgColor
                                        cell.chatView.layer.borderWidth = 0.0
                                    }
                                }
                                
                            })
                            break
                        }
                        index = index + 1
                    }
                }
                
                break
            case MessageType(rawValue: 1):
                guard let imgCell = cellItem as? ImageTableViewCell else{return}
                
                let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
                
                if(download_status == "2"){
                    let PhotoPath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                    if FileManager.default.fileExists(atPath: PhotoPath) {
                        let url = URL(fileURLWithPath: PhotoPath)
                        if(url.pathExtension.lowercased() == "gif")
                        {
                            if(imgCell.gifImg.isAnimatingGif())
                            {/*
                              imgCell.gifImg.stopAnimatingGif()
                              imgCell.customButton.setImage(#imageLiteral(resourceName: "gifIcon"), for: .normal)
                              
                              let configuration = ImageViewerConfiguration { config in
                              config.image = imgCell.gifImg.gifImage
                              config.imagePath = url
                              }
                              var name: String = ""
                              let messageFrame: UUMessageFrame = self.chatHistory[sender.tag] as! UUMessageFrame
                              let timestamp = messageFrame.message.timestamp ?? ""
                              
                              let DayStr:String = Themes.sharedInstance.ReturnDateTimeFormat(timestamp: timestamp)
                              let TimeStr:String = Themes.sharedInstance.ReturnTimeForChat(timestamp: timestamp)
                              
                              let time = DayStr + " " + TimeStr
                              
                              let userid = messageFrame.message.user_from ?? ""
                              if Themes.sharedInstance.Getuser_id() == userid{
                              name = "You"
                              }else{
                              if self.Chat_type.elementsEqual("single"){
                              name = Group_name_Lbl.text ?? ""
                              }else{
                              name = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: userid, returnStr: "user_name")
                              }
                              }
                              
                              let vc = ImageViewerController(configuration: configuration, senderName: name, sendedTime: time)
                              self.presentView(vc, animated: true)
                              
                              
                              if (cellItem.delegate is UIViewController) {
                              (cellItem.delegate as! UIViewController).view.endEditing(true)
                              }
                              */
                            }
                            else
                            {
                                imgCell.gifImg.startAnimatingGif()
                                imgCell.customButton.setImage(nil, for: .normal)
                            }
                            return
                        }
                    }
                }
                
                let configuration = ImageViewerConfiguration { config in
                    //  config.imageView = imgCell.chatImg
                    config.image = imgCell.chatImg.image
                }
                
                var name: String = ""
                let messageFrame: UUMessageFrame = self.chatHistory[sender.tag] as! UUMessageFrame
                let timestamp = messageFrame.message.timestamp ?? ""
                
                let DayStr:String = Themes.sharedInstance.ReturnDateTimeFormat(timestamp: timestamp)
                let TimeStr:String = Themes.sharedInstance.ReturnTimeForChat(timestamp: timestamp)
                
                let time = DayStr + " " + TimeStr
                
                let userid = messageFrame.message.user_from ?? ""
                if Themes.sharedInstance.Getuser_id() == userid{
                    name = "You"
                }else{
                    name = self.fromName
                }
                
                let vc = ImageViewerController(configuration: configuration, senderName: name, sendedTime: time)
                self.presentView(vc, animated: true)
                
                
                if (cellItem.delegate is UIViewController) {
                    (cellItem.delegate as! UIViewController).view.endEditing(true)
                }
                break
            case MessageType(rawValue:2):
                guard let imgCell = cellItem as? ImageTableViewCell else{return}
                
                
                let videoURL = URL(string: imgCell.messageFrame.message.url_str)
                self.presentPlayer(videoURL, cellItem)
                
                
                break
            case MessageType(rawValue: 4):
                guard var urlString = messageFrame.message.payload else{return}
                if !urlString.contains("https://") && !urlString.contains("http://")
                {
                    urlString = "https://\(urlString)"
                }
                urlString = urlString.removingWhitespaces()
                guard let url = URL(string: urlString) else {return}
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                break
            case MessageType(rawValue:6):
                
//                let objVC:DocViewController = StoryBoard.main.instantiateViewController(withIdentifier: "DocViewControllerID") as! DocViewController
//                objVC.webkitTitle =  "" //cellItem.messageFrame.message.docName
//                objVC.webkitURL = cellItem.messageFrame.message.url_str
//                self.pushView(objVC, animated: true)
                
                let name = cellItem.messageFrame.message.url_str.components(separatedBy: "/").last ?? ""
                self.downloadfile(fileName: name, itemUrl: cellItem.messageFrame.message.url_str)
                 
                
                /*
                 var id = cellItem.messageFrame.message.thumbnail!
                 if(id == "")
                 {
                 id = cellItem.messageFrame.message.doc_id!
                 }
                 let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: id, upload_detail: "download_status") as! String
                 
                 if((cellItem.messageFrame.message.from == MessageFrom(rawValue: 1)! || (download_status == "2" && cellItem.messageFrame.message.from == MessageFrom(rawValue: 0)!)))
                 {
                 // self.DidclickContentBtn(messagFrame: (cellItem.messageFrame))
                 }
                 */
                break
            case MessageType(rawValue:7):
                let isFromStatus = (messageFrame.message.reply_type == "status") ? true : false
                let recordId:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Reply_detail, attrib_name: "doc_id", fetchString: messageFrame.message.doc_id, returnStr: "recordId")
                let index = IndexPath(row: row, section: 0)
                //  self.PasReplyDetail(index:index,ReplyRecordID:recordId, isStatus : isFromStatus)
                break
                
            case MessageType(rawValue:14):
                let s = StoryBoard.main.instantiateViewController(withIdentifier:"OnCellClickViewController" ) as! OnCellClickViewController
                let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
                
                s.latitude = cellItem.messageFrame.message.latitude
                s.longitude = cellItem.messageFrame.message.longitude
                if(cellItem.messageFrame.message.from == MessageFrom(rawValue: 1))
                {
                    s.on_title = "\(Name)(you)"
                }
                else
                {
                    s.on_title = Themes.sharedInstance.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: cellItem.messageFrame.message.from), "single")
                }
                s.subtitle = cellItem.messageFrame.message.stitle_place
                s.place_name = cellItem.messageFrame.message.title_place
                self.pushView(s, animated: true)
                break
                
                
            case MessageType(rawValue:22):
                
                guard let imgCell = cellItem as? StoryChatTableViewCell else{return}
                
                if imgCell.messageFrame.message.storyId.count > 0{
                    self.getAllStatusListApi(storyId: imgCell.messageFrame.message.storyId)
                }
                break
            default: break
            }
        }
        
    }
    
    
    fileprivate func presentPlayer(_ videoURL: URL?, _ cellItem: CustomTableViewCell) {
        if videoURL == nil{
            return
        }
        let player = AVPlayer(url: videoURL! )
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        (cellItem.delegate as! UIViewController).presentView(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    /*
     @IBAction func longGestureCellAction(_ recognizer: UILongPressGestureRecognizer){
     guard recognizer.state == .began else {
     return
     }
     
     let touchPoint = recognizer.location(in: tblChat)
     
     if   let indexPath = tblChat.indexPathForRow(at: touchPoint){
     
     let messageFrame = (self.chatHistory as! [UUMessageFrame])[indexPath.row]
     if messageFrame.message.user_from == Themes.sharedInstance.Getuser_id() {
     let actionSheetAlertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
     
     let cancelActionButton = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
     actionSheetAlertController.addAction(cancelActionButton)
     
     let safetyButton = UIAlertAction(title: "Delete for me", style: .default) { (action) in
     self.selectedIndex = indexPath.row
     self.emitDeleteChat(messageIds: [messageFrame.message.msgId])
     }
     actionSheetAlertController.addAction(safetyButton)
     
     let deleteChatBoth = UIAlertAction(title: "Delete for Everyone", style: .default) { (action) in
     self.selectedIndex = indexPath.row
     self.emitDeleteChatFromBoth(messageIds: [messageFrame.message.msgId])
     }
     actionSheetAlertController.addAction(deleteChatBoth)
     
     
     self.present(actionSheetAlertController, animated: true, completion: nil)
     }
     }
     }
     */
    
    @IBAction func longGestureCellAction(_ recognizer: UILongPressGestureRecognizer){
        if  self.requestedUser == 0{
            return
        }
        self.center_item.tintColor = CustomColor.sharedInstance.newThemeColor
        self.left_item.tintColor = CustomColor.sharedInstance.newThemeColor
        self.right_item.tintColor = CustomColor.sharedInstance.newThemeColor
        
        if let point = recognizer.view?.convert(recognizer.location(in: recognizer.view), to: self.view) {
            
            if(popovershow == false)
            {
                popovershow = true
                
                let index = IndexPath(row: (recognizer.view?.tag)!, section: 0)
                
                let cell = self.tblChat.cellForRow(at: index)
                var messageFrame = UUMessageFrame()
                if(self.chatHistory.count > (recognizer.view?.tag)!)
                {
                    messageFrame = (self.chatHistory as! [UUMessageFrame])[(recognizer.view?.tag)!]
                }
                if messageFrame.message.replyObj == nil {
                    messageFrame.message.replyObj = ReplyInfo(respDict: [:])
                }
                let cellConfi = FTCellConfiguration()
                cellConfi.textColor = UIColor.black.withAlphaComponent(0.7)
                cellConfi.textFont = UIFont.systemFont(ofSize: 15.0)
                cellConfi.textAlignment = .left
                cellConfi.menuIconSize = 17.0
                cellConfi.ignoreImageOriginalColor = true
                
                let menuOptionNameArray = self.longGestureDataSource(messageFrame: messageFrame).0
                
                let menuOptionImageNameArray = self.longGestureDataSource(messageFrame: messageFrame).1
                
                let config = FTConfiguration.shared
                config.backgoundTintColor = UIColor(red: 213/255, green: 213/255, blue: 211/255, alpha: 1.0)
                config.borderColor = UIColor.clear
                config.menuWidth = 155
                config.menuSeparatorColor = UIColor.lightGray
                config.menuRowHeight = 44
                config.cornerRadius = 15
                config.globalShadow = true
                
                let rectOfCell = self.tblChat.rectForRow(at: index)
                let rectOfCellInSuperview = self.tblChat.convert(rectOfCell, to: AppDelegate.sharedInstance.window?.view)
                
                _ = config.selectedView.subviews.map {
                    $0.removeFromSuperview()
                }
                config.selectedView.frame = rectOfCellInSuperview
                config.selectedView.addSubview(self.copyView(viewforCopy: (cell?.contentView)!))
                
                FTPopOverMenu.showFromSenderFrame(senderFrame: CGRect(origin: point, size: CGSize.zero), with: menuOptionNameArray, menuImageArray: menuOptionImageNameArray, cellConfigurationArray: Array(repeating: cellConfi, count: menuOptionNameArray.count), done: { (selectedIndex) in
                    self.popovershow = false
                    self.view.endEditing(true)
                    let action = menuOptionNameArray[selectedIndex]
                    if(action == "Delete")
                    {
                        /* let messageFrame = (self.chatHistory as! [UUMessageFrame])[index.row]
                         // if messageFrame.message.user_from == Themes.sharedInstance.Getuser_id() {
                         let actionSheetAlertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                         
                         let cancelActionButton = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
                         actionSheetAlertController.addAction(cancelActionButton)
                         
                         let safetyButton = UIAlertAction(title: "Delete for me", style: .default) { (action) in
                         self.selectedIndex = index.row
                         self.emitDeleteChat(messageIds: [messageFrame.message.msgId])
                         }
                         actionSheetAlertController.addAction(safetyButton)
                         
                         let deleteChatBoth = UIAlertAction(title: "Delete for everyone", style: .default) { (action) in
                         self.selectedIndex = index.row
                         self.emitDeleteChatFromBoth(messageIds: [messageFrame.message.msgId])
                         }
                         actionSheetAlertController.addAction(deleteChatBoth)
                         self.present(actionSheetAlertController, animated: true, completion: nil)
                         // }
                         */
                        self.isForwardAction = false
                        self.isBeginEditing = true
                        self.left_item.image = #imageLiteral(resourceName: "trash")
                        self.right_item.title = "Cancel"
                        self.center_item.title =  "1 Selected" // "Clear Chat"
                        self.firstIndexpath = index
                        self.perform(#selector(self.SelectIndexpath), with:self , afterDelay: 0.3)
                        self.ShowToolBar()
                        
                    }
                    else if(action == "Info")
                    {
                        let messageinfoVC = StoryBoard.main.instantiateViewController(withIdentifier:"MessageInfoViewControllerID" ) as! MessageInfoViewController
                        messageinfoVC.ChatType = "single"
                        messageinfoVC.messageinfo = messageFrame
                        self.pushView(messageinfoVC, animated: true)
                        
                    }
                    else if(action == "Reply")
                    {
                        self.ShowReplyView(messageFrame)
                    }
                    else  if(action == "Forward")
                    {
                        
                        self.isForwardAction = true
                        self.isBeginEditing = true
                        self.left_item.image = #imageLiteral(resourceName: "forward")
                        // self.center_item.image = #imageLiteral(resourceName: "share")
                        self.center_item.title =  "1 Selected"
                        self.right_item.title = "Cancel"
                        self.firstIndexpath = index
                        self.perform(#selector(self.SelectIndexpath), with:self , afterDelay: 0.3)
                        self.ShowToolBar()
                        
                    }
                    else  if(action == "Star")
                    {
                        //                        messageFrame.message.isStar = "1"
                        //                        self.StarMessage(status: "1", DocId: messageFrame.message.doc_id,convId:messageFrame.message.conv_id,recordId:messageFrame.message.recordId)
                        //                        DispatchQueue.main.async{
                        //                            self.tblChat.reloadRows(at: [index], with: .none)
                        //                        }
                        
                    }
                    else  if(action == "Unstar")
                    {
                        //                        messageFrame.message.isStar = "0"
                        //                        self.StarMessage(status: "0", DocId: messageFrame.message.doc_id,convId:messageFrame.message.conv_id,recordId:messageFrame.message.recordId )
                        //                        DispatchQueue.main.async{
                        //                            self.tblChat.reloadRows(at: [index], with: .none)
                        //                        }
                        
                    }
                    else if(action == "Copy")
                    {
                        //copy for map
                        if(messageFrame.message.message_type == "14"){
                            UIPasteboard.general.string = "https://maps.google.com/?g=\(messageFrame.message.latitude!),\(messageFrame.message.longitude!)"
                        }else{
                            UIPasteboard.general.string = messageFrame.message.payload
                        }
                    }else if(action == "Download")
                    {
                        self.downloadAllMedia(urlArray: [messageFrame.message.url_str])

                    }
                }) {
                    self.popovershow = false
                }
            }
        }
    }
    @objc func SelectIndexpath()
    {
        tblChat.setEditing(true, animated: false)
        tblChat.selectRow(at: firstIndexpath, animated: false, scrollPosition: .none)
        tableView(tblChat, cellForRowAt: firstIndexpath)
        left_item.isEnabled = true
        center_item.isEnabled = true
    }
    
    func ShowToolBar()
    {
        self.selectiontoolbar.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.selectiontoolbar.frame = CGRect(x: 0, y: self.inputFuncView.frame.origin.y + 2, width: self.selectiontoolbar.frame.size.width, height: self.selectiontoolbar.frame.size.height )
            self.view.bringSubviewToFront(self.selectiontoolbar)
        }, completion: nil)
    }
    
    func HideToolBar()
    {
        self.selectiontoolbar.isHidden = true
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.selectiontoolbar.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.selectiontoolbar.frame.size.width, height: self.selectiontoolbar.frame.size.height )
        }, completion:{ (istrue) in
            self.tblChat.setEditing(false, animated: true)
            self.isForwardAction = false
            self.isBeginEditing = false
            
        } )
    }
    func copyView(viewforCopy: UIView) -> UIView {
        if let viewCopy = viewforCopy.snapshotView(afterScreenUpdates: true) {
            return viewCopy
        }
        return UIView()
    }
    
    
    @objc func Swipeleft(_ recognizer:UIGestureRecognizer){
        
        if  self.requestedUser == 0{
            return
        }
        
        let cell = self.tblChat.cellForRow(at: IndexPath(row: (recognizer.view?.tag)!, section: 0)) as? CustomTableViewCell
        var messageFrame = UUMessageFrame()
        if(self.chatHistory.count > (recognizer.view?.tag)!)
        {
            messageFrame = (self.chatHistory as! [UUMessageFrame])[(recognizer.view?.tag)!]
        }
        
        
        
        
        //  let translation = recognizer.translationInView(self.view)
        
        let translation: CGPoint =  recognizer.location(in: view) //recognizer.translation(in: view)
        //Swipe to Left
        if(messageFrame.message.from == MessageFrom(rawValue: 1))
        {
            recognizer.view?.center = CGPoint(x: (recognizer.view?.center.x ?? 0.0) + translation.x, y: recognizer.view?.center.y ?? 0.0)
            //  recognizer.setTranslation(CGPoint(x: 0, y: 0), in: view)
            recognizer.location(ofTouch: 0, in: view)
            
            UIView.animate(withDuration: 0.25) {
                cell?.replyImg.alpha = 1.0
            }
            
            if (recognizer.view?.frame.origin.x ?? 0.0) < -(UIScreen.main.bounds.size.width * 0.9) {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                    recognizer.view?.frame = CGRect(x: 0, y: recognizer.view?.frame.origin.y ?? 0.0, width: recognizer.view?.frame.size.width ?? 0.0, height: recognizer.view?.frame.size.height ?? 0.0)
                })
            }
            if recognizer.state == .ended {
                let x = Int(recognizer.view?.frame.origin.x ?? 0)
                
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                    recognizer.view?.frame = CGRect(x: 0, y: recognizer.view?.frame.origin.y ?? 0.0, width: recognizer.view?.frame.size.width ?? 0.0, height: recognizer.view?.frame.size.height ?? 0.0)
                }) { finished in
                    if CGFloat(x) < -50 {
                        let messageinfoVC = StoryBoard.main.instantiateViewController(withIdentifier:"MessageInfoViewControllerID" ) as! MessageInfoViewController
                        messageinfoVC.ChatType = "single"
                        messageinfoVC.messageinfo = messageFrame
                        self.pushView(messageinfoVC, animated: true)
                    }
                    cell?.replyImg.alpha = 0.0
                }
            }
        }
    }
    
    @objc func Swiperight(_ recognizer:UIGestureRecognizer){
        
        
        if  self.requestedUser == 0{
            return
        }
        let cell = self.tblChat.cellForRow(at: IndexPath(row: (recognizer.view?.tag)!, section: 0)) as? CustomTableViewCell
        var messageFrame = UUMessageFrame()
        if(self.chatHistory.count > (recognizer.view?.tag)!)
        {
            messageFrame = (self.chatHistory as! [UUMessageFrame])[(recognizer.view?.tag)!]
        }
        let translation: CGPoint = recognizer.location(in: view)  // recognizer.translation(in: view)
        UIView.animate(withDuration: 0.25) {
            cell?.replyImg.alpha = 1.0
        }
        recognizer.view?.center = CGPoint(x: (recognizer.view?.center.x ?? 0.0) + translation.x, y: recognizer.view?.center.y ?? 0.0)
        // recognizer.setTranslation(CGPoint(x: 0, y: 0), in: view)
        recognizer.location(ofTouch: 0, in: view)
        
        if (recognizer.view?.frame.origin.x ?? 0.0) > UIScreen.main.bounds.size.width * 0.9 {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                recognizer.view?.frame = CGRect(x: 0, y: recognizer.view?.frame.origin.y ?? 0.0, width: recognizer.view?.frame.size.width ?? 0.0, height: recognizer.view?.frame.size.height ?? 0.0)
            })
        }
        if recognizer.state == .ended {
            let x = Int(recognizer.view?.frame.origin.x ?? 0)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                recognizer.view?.frame = CGRect(x: 0, y: recognizer.view?.frame.origin.y ?? 0.0, width: recognizer.view?.frame.size.width ?? 0.0, height: recognizer.view?.frame.size.height ?? 0.0)
            }) { finished in
                if CGFloat(x) > 85 {
                    if(messageFrame.message.message_status != "0")
                    {
                        self.inputFuncView.become_FirtResponder()
                        self.ShowReplyView(messageFrame)
                    }
                }
                cell?.replyImg.alpha = 0.0
            }
        }
    }
    
    @objc func panGestureCellAction(_ recognizer: UIPanGestureRecognizer) {
        
        
        let cell = self.tblChat.cellForRow(at: IndexPath(row: (recognizer.view?.tag)!, section: 0)) as? CustomTableViewCell
        var messageFrame = UUMessageFrame()
        if(self.chatHistory.count > (recognizer.view?.tag)!)
        {
            messageFrame = (self.chatHistory as! [UUMessageFrame])[(recognizer.view?.tag)!]
        }
        let translation: CGPoint = recognizer.translation(in: view)
        
        if (recognizer.view?.frame.origin.x ?? 0.0) < 0.0 { //Swipe to Left
            if(messageFrame.message.from == MessageFrom(rawValue: 1))
            {
                recognizer.view?.center = CGPoint(x: (recognizer.view?.center.x ?? 0.0) + translation.x, y: recognizer.view?.center.y ?? 0.0)
                recognizer.setTranslation(CGPoint(x: 0, y: 0), in: view)
                UIView.animate(withDuration: 0.25) {
                    cell?.replyImg.alpha = 1.0
                }
                
                if (recognizer.view?.frame.origin.x ?? 0.0) < -(UIScreen.main.bounds.size.width * 0.9) {
                    UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                        recognizer.view?.frame = CGRect(x: 0, y: recognizer.view?.frame.origin.y ?? 0.0, width: recognizer.view?.frame.size.width ?? 0.0, height: recognizer.view?.frame.size.height ?? 0.0)
                    })
                }
                if recognizer.state == .ended {
                    let x = Int(recognizer.view?.frame.origin.x ?? 0)
                    UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                        recognizer.view?.frame = CGRect(x: 0, y: recognizer.view?.frame.origin.y ?? 0.0, width: recognizer.view?.frame.size.width ?? 0.0, height: recognizer.view?.frame.size.height ?? 0.0)
                    }) { finished in
                        if CGFloat(x) < -50 {
                            let messageinfoVC = StoryBoard.main.instantiateViewController(withIdentifier:"MessageInfoViewControllerID" ) as! MessageInfoViewController
                            messageinfoVC.ChatType = "single"
                            messageinfoVC.messageinfo = messageFrame
                            self.pushView(messageinfoVC, animated: true)
                        }
                        cell?.replyImg.alpha = 0.0
                    }
                }
            }
        }
        else //Swipe to Right
        {
            UIView.animate(withDuration: 0.25) {
                cell?.replyImg.alpha = 1.0
            }
            recognizer.view?.center = CGPoint(x: (recognizer.view?.center.x ?? 0.0) + translation.x, y: recognizer.view?.center.y ?? 0.0)
            recognizer.setTranslation(CGPoint(x: 0, y: 0), in: view)
            
            if (recognizer.view?.frame.origin.x ?? 0.0) > UIScreen.main.bounds.size.width * 0.9 {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                    recognizer.view?.frame = CGRect(x: 0, y: recognizer.view?.frame.origin.y ?? 0.0, width: recognizer.view?.frame.size.width ?? 0.0, height: recognizer.view?.frame.size.height ?? 0.0)
                })
            }
            if recognizer.state == .ended {
                let x = Int(recognizer.view?.frame.origin.x ?? 0)
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                    recognizer.view?.frame = CGRect(x: 0, y: recognizer.view?.frame.origin.y ?? 0.0, width: recognizer.view?.frame.size.width ?? 0.0, height: recognizer.view?.frame.size.height ?? 0.0)
                }) { finished in
                    if CGFloat(x) > 85 {
                        if(messageFrame.message.message_status != "0")
                        {
                            self.inputFuncView.become_FirtResponder()
                            self.ShowReplyView(messageFrame)
                        }
                    }
                    cell?.replyImg.alpha = 0.0
                }
            }
        }
        
    }
    
    func ShowReplyView(_ messageFrame: UUMessageFrame){
        if messageFrame.message.type == .UUMessageTypeStory{
            return
        }

        isShowBottomView = true
        isReplyMessage = true
        replyView.isHidden = false
        
        let message_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.message_type)
        var payload = Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.payload)
        let arr = Themes.sharedInstance.getID_Range_Payload_Name(message: payload)
        let ReplyrangeArr = arr[1] as! [NSRange]
        payload = arr[2] as! String
        
        if(messageFrame.message.from == MessageFrom(rawValue: 1))
        {
            replyView.name_Lbl.text = "You"
            replyView.name_Lbl.textColor = UIColor(red:23/255, green:109/255, blue:69/255, alpha:1.0)
        }else
        {
            //replyView.name_Lbl.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single")
            replyView.name_Lbl.text = messageFrame.message.name
            replyView.name_Lbl.textColor = UIColor.orange
        }
        if(message_type == "0")
        {
            replyView.thumbnail_Image.isHidden = true
            replyView.message_Lbl.text = payload
            
        }else if(message_type == "1")
        {
            replyView.thumbnail_Image.isHidden = false
            
            
            
            if messageFrame.message.type == .UUMessageTypeReply{
                
                if messageFrame.message.payload.count > 0 {
                    
                    replyView.message_Lbl.text = messageFrame.message.payload
                    
                }else{
                                        
                    if  checkMediaTypes(strUrl:messageFrame.message.replyObj.url) == 1{
                        replyView.message_Lbl.text = "📷 Photo"
                        replyView.thumbnail_Image.kf.setImage(with: URL(string: messageFrame.message.thumbnail), placeholder: UIImage(named: "VideoThumbnail")!, options: [.fromMemoryCacheOrRefresh], progressBlock: nil) { response in}
                        
                    }else if checkMediaTypes(strUrl:messageFrame.message.replyObj.url) == 3{
                        replyView.message_Lbl.text = "📹 Video"
                        replyView.thumbnail_Image.kf.setImage(with: URL(string: messageFrame.message.thumbnail), placeholder: UIImage(named: "VideoThumbnail")!, options: [.fromMemoryCacheOrRefresh], progressBlock: nil) { response in}
                        
                    }else if checkMediaTypes(strUrl: messageFrame.message.replyObj.url) == 2{
                        replyView.message_Lbl.text = "📄 Document"
                        if let url = URL(string: messageFrame.message.replyObj.thumbUrl){
                            
                            DispatchQueue.global(qos: .userInitiated).async {
                                let pdfImage = url.drawPDFfromURL()
                                DispatchQueue.main.async {
                                    self.replyView.thumbnail_Image.image = pdfImage
                                }
                            }
                        }
                    }
                }
            }else{
                
                if  checkMediaTypes(strUrl:messageFrame.message.url_str) == 1{
                    
                    replyView.message_Lbl.text = "📷 Photo"
                    replyView.thumbnail_Image.kf.setImage(with: URL(string: messageFrame.message.thumbnail), placeholder: UIImage(named: "VideoThumbnail")!, options: [.fromMemoryCacheOrRefresh], progressBlock: nil) { response in}
                    
                    
                }else if checkMediaTypes(strUrl:messageFrame.message.url_str) == 3{
                    replyView.message_Lbl.text = "📹 Video"
                    replyView.thumbnail_Image.kf.setImage(with: URL(string: messageFrame.message.thumbnail), placeholder: UIImage(named: "VideoThumbnail")!, options: [.fromMemoryCacheOrRefresh], progressBlock: nil) { response in}
                    
                }else if checkMediaTypes(strUrl:messageFrame.message.url_str) == 2{
                    replyView.message_Lbl.text = "📄 Document"
                    if let url = URL(string: messageFrame.message.thumbnail){
                        
                        DispatchQueue.global(qos: .userInitiated).async {
                            let pdfImage = url.drawPDFfromURL()
                            DispatchQueue.main.async {
                                self.replyView.thumbnail_Image.image = pdfImage
                            }
                        }
                    }
                }
                
                if messageFrame.message.payload.count > 0 {
                    
                    replyView.message_Lbl.text = messageFrame.message.payload
                    
                }
            }
            
            
        } else if(message_type == "3")
        {
            replyView.thumbnail_Image.isHidden = true
            replyView.message_Lbl.text = "📝 \(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.contact_name))"
            
        }else if(message_type == "4"){
            replyView.thumbnail_Image.isHidden = true
            replyView.message_Lbl.text = "📍" + payload
        }else if(message_type == "6")
        {
            replyView.thumbnail_Image.isHidden = true
            replyView.message_Lbl.text = "🎵 Audio"
            
        }
        
        if(payload.length > 0)
        {
            let attributed = NSMutableAttributedString(string: replyView.message_Lbl.text!)
            
            attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: NSMakeRange(0, (replyView.message_Lbl.text?.length)!))
            _ = ReplyrangeArr.map {
                attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15.0)], range: $0)
            }
            if(ReplyrangeArr.count > 0)
            {
                replyView.message_Lbl.attributedText = attributed
            }
        }
        
        replyMessageRecord = messageFrame
        
        let previousReplyH = replyView.message_Lbl.frame.size.height
        
        var height = replyView.message_Lbl.text?.height(withConstrainedWidth: replyView.message_Lbl.frame.size.width, font: UIFont.boldSystemFont(ofSize: 15.0))
        
        inputFuncView.become_FirtResponder()
        if(Double(height!) > Double(previousReplyH))
        {
            if(Double(height!) > 62.0){
                height = 62
            }
            var rect = replyView.message_Lbl.frame
            rect.size.height = height!
            rect.size.width = rect.size.width - 10
            replyView.message_Lbl.frame = rect
            
            rect = replyView.frame
            rect.size.height = replyView.frame.size.height + (height! - previousReplyH)
            rect.origin.y = replyView.frame.origin.y - (height! - previousReplyH)
            replyView.frame = rect
            self.view.layoutIfNeeded()
        }
        else
        {
            var rect = replyView.message_Lbl.frame
            rect.size.height = height!
            replyView.message_Lbl.frame = rect
            replyView.frame = CGRect(x: 0, y: inputFuncView.frame.origin.y - 50 , width: replyView.frame.size.width, height: 50)
            self.view.layoutIfNeeded()
        }
    }
    
    func longGestureDataSource(messageFrame : UUMessageFrame) -> ([String], [String]){
        
        var menuOptionNameArray : [String] = []
        var menuOptionImageNameArray : [String] = []

        if(messageFrame.message.from == MessageFrom(rawValue: 1))
        {
            // let customMenuItem = StarString
            let customMenuItem2 = "Reply"
            let customMenuItem3 = "Forward"
            let customMenuItem4 = "Copy"
            // let customMenuItem5 =  "Info"
            let customMenuItem6 = "Delete"
            let customMenuItem7 = "Download"

            if(messageFrame.message.message_status == "0")
            {
                if(messageFrame.message.is_deleted == "1")
                {
                    //                    menuOptionNameArray = [customMenuItem6]
                    //                    menuOptionImageNameArray = ["menu_delete"]
                    
                    
                }
                else
                {
                    menuOptionNameArray = [customMenuItem3,customMenuItem4,customMenuItem6,customMenuItem7]
                    menuOptionImageNameArray = [ "menu_forward", "menu_copy", "menu_delete","DownloadVideo"]
                }
                
            }
            else
            {
                if(messageFrame.message.is_deleted == "1")
                {
                    //                    menuOptionNameArray = [customMenuItem6]
                    //                    menuOptionImageNameArray = ["menu_delete"]
                }
                else
                {
                    menuOptionNameArray = [customMenuItem2,customMenuItem3,customMenuItem4,customMenuItem6,customMenuItem7]
                    menuOptionImageNameArray = ["menu_reply", "menu_forward", "menu_copy", "menu_delete","DownloadVideo"]
                    
                }
                
            }
            if(is_you_removed)
            {
                if (menuOptionNameArray.contains(customMenuItem2))
                {
                    if let index = (menuOptionNameArray.firstIndex(of: customMenuItem2)){
                        menuOptionNameArray.remove(at: index)
                        menuOptionImageNameArray.remove(at: index)
                    }
                }
            }
            
            if messageFrame.message.payload == "" && menuOptionNameArray.contains(customMenuItem4)
            {
                if let index = (menuOptionNameArray.firstIndex(of: customMenuItem4)){
                    menuOptionNameArray.remove(at: index)
                    menuOptionImageNameArray.remove(at: index)
                }
                
               
            }
            
            if messageFrame.message.type == .UUMessageTypeVideo ||   messageFrame.message.type == .UUMessageTypePicture ||  messageFrame.message.type == .UUMessageTypeDocument{
                
            }else{
               
                if let index = (menuOptionNameArray.firstIndex(of: customMenuItem7)){
                    menuOptionNameArray.remove(at: index)
                    menuOptionImageNameArray.remove(at: index)
                }
            }
            if messageFrame.message.type == .UUMessageTypeStory{
                if let index = (menuOptionNameArray.firstIndex(of: customMenuItem3)){
                    menuOptionNameArray.remove(at: index)
                    menuOptionImageNameArray.remove(at: index)
                }
                
                if let index = (menuOptionNameArray.firstIndex(of: customMenuItem2)){
                    menuOptionNameArray.remove(at: index)
                    menuOptionImageNameArray.remove(at: index)
                }
            }
            
        }
        else
        {
            //  let customMenuItem = StarString
            let customMenuItem2 = "Reply"
            let customMenuItem3 = "Forward"
            let customMenuItem4 = "Copy"
            let customMenuItem6 = "Delete"
            let customMenuItem7 = "Download"

            if(messageFrame.message.message_status == "0")
            {
                if(messageFrame.message.is_deleted == "1")
                {
                    //                    menuOptionNameArray = [customMenuItem6]
                    //                    menuOptionImageNameArray = ["menu_delete"]
                }
                else
                {
                    menuOptionNameArray = [customMenuItem3,customMenuItem4,customMenuItem6,customMenuItem7]
                    menuOptionImageNameArray = ["menu_forward", "menu_copy", "menu_delete" ,"DownloadVideo"]
                }
            }
            else
            {
                if(messageFrame.message.is_deleted == "1")
                {
                    //                    menuOptionNameArray = [customMenuItem6]
                    //                    menuOptionImageNameArray = ["menu_delete"]
                }
                else
                {
                    menuOptionNameArray = [customMenuItem2,customMenuItem3,customMenuItem4,customMenuItem6,customMenuItem7]
                    menuOptionImageNameArray = ["menu_reply", "menu_forward", "menu_copy", "menu_delete","DownloadVideo"]
                }
                
            }
            if(is_you_removed)
            {
                if (menuOptionNameArray.contains(customMenuItem2))
                {
                    if let index = (menuOptionNameArray.firstIndex(of: customMenuItem2)){
                        menuOptionNameArray.remove(at: index)
                        menuOptionImageNameArray.remove(at: index)
                }
                    if let index = (menuOptionNameArray.firstIndex(of: customMenuItem7)){
                        menuOptionNameArray.remove(at: index)
                        menuOptionImageNameArray.remove(at: index)
                    }
                }
            }
            if messageFrame.message.payload == "" && menuOptionNameArray.contains(customMenuItem4)
            {
                if  let index = (menuOptionNameArray.firstIndex(of: customMenuItem4)){
                    menuOptionNameArray.remove(at: index)
                    menuOptionImageNameArray.remove(at: index)
                }
                
            }
            
            if messageFrame.message.type == .UUMessageTypeVideo ||   messageFrame.message.type == .UUMessageTypePicture ||  messageFrame.message.type == .UUMessageTypeDocument{
                
            }else{
               
                if let index = (menuOptionNameArray.firstIndex(of: customMenuItem7)){
                    menuOptionNameArray.remove(at: index)
                    menuOptionImageNameArray.remove(at: index)
                }
            }
            
            if messageFrame.message.type == .UUMessageTypeStory{
                if let index = (menuOptionNameArray.firstIndex(of: customMenuItem3)){
                    menuOptionNameArray.remove(at: index)
                    menuOptionImageNameArray.remove(at: index)
                }
                
                if let index = (menuOptionNameArray.firstIndex(of: customMenuItem2)){
                    menuOptionNameArray.remove(at: index)
                    menuOptionImageNameArray.remove(at: index)
                }
            }
        }
        return (menuOptionNameArray, menuOptionImageNameArray)
    }
    
    
    
    func keyboardChangeShow(_ notification: Notification) {
        // self.pauseGif()
        isKeyboardShown=true;
        var userInfo = notification.userInfo!
        let animationCurve: UIView.AnimationCurve=UIView.AnimationCurve(rawValue: Int(userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber))!
        let animationDuration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(animationDuration)
        UIView.setAnimationCurve(animationCurve)
        
        //adjust ChatTableView's height
        if notification.name == UIResponder.keyboardWillShowNotification && link_view.isHidden {
            if(isShowBottomView)
            {
                self.lytTableBottom.constant = keyboardEndFrame.size.height + 100
                
            }
            else
            {
                self.lytTableBottom.constant = keyboardEndFrame.size.height + 50
            }
            if(link_view.isHidden == true)
            {
                self.lytTableBottom.constant = keyboardEndFrame.size.height + 50
                self.link_bottom.constant=keyboardEndFrame.size.height + 50
            }
        }
        else if(!link_view.isHidden){
            
            UIView.animate(withDuration: 0.1,
                           delay: 0.1,
                           options: UIView.AnimationOptions.curveEaseIn,
                           animations: { () -> Void in
                self.link_bottom.constant=keyboardEndFrame.size.height + 50
            }, completion: { (finished) -> Void in
                self.lytTableBottom.constant = keyboardEndFrame.size.height + self.link_view.frame.size.height + 50
            })
            
            
        }
        else {
            if(isShowBottomView)
            {
                self.lytTableBottom.constant = 50+50
            }
            else
            {
                self.lytTableBottom.constant = 50
                self.lytTableBottom.constant = 50+link_view.frame.size.height
                self.link_bottom.constant=50
            }
        }
        self.view.layoutIfNeeded()
        //adjust UUInputFunctionView's originPoint
        newFrame = inputFuncView.frame
        newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height
        inputFuncView.frame = newFrame
        replyView.frame.origin.y =  newFrame.origin.y-50-replyView.message_Lbl.frame.size.height+25
        inputFuncView.set_Frame()
        UIView.commitAnimations()
        tableViewScrollToBottom()
        
    }
    
    func keyboardChangeHide(_ notification: Notification) {
        isKeyboardShown=false
        var userInfo = notification.userInfo!
        let animationCurve: UIView.AnimationCurve=UIView.AnimationCurve(rawValue: Int(userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber))!
        let animationDuration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(animationDuration)
        UIView.setAnimationCurve(animationCurve)
        //adjust ChatTableView's height
        if notification.name == UIResponder.keyboardWillShowNotification {
            
            if(isShowBottomView)
            {
                self.lytTableBottom.constant = keyboardEndFrame.size.height + 100
                
            }
            else
            {
                self.lytTableBottom.constant = keyboardEndFrame.size.height + 50
            }
            
        }else if(link_view.isHidden){
            
            if(isReplyMessage)
            {
                self.lytTableBottom.constant = 50 + self.replyView.frame.size.height
            }
            else
            {
                self.lytTableBottom.constant = 50
                self.link_bottom.constant=50
            }
        }
        else {
            
            if(isShowBottomView)
            {
                self.lytTableBottom.constant = 50+50
            }else if(link_view.isHidden == false){
                self.lytTableBottom.constant = 50 + 55
                self.link_bottom.constant=50
            }
            else
            {
                self.lytTableBottom.constant = 50
            }
            
        }
        self.view.layoutIfNeeded()
        //adjust UUInputFunctionView's originPoint
        newFrame = inputFuncView.frame
        if UIDevice().hasNotch {
            newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height - 30
        } else {
            newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height
        }
        inputFuncView.frame = newFrame
        replyView.frame.origin.y =  newFrame.origin.y-50
        inputFuncView.set_Frame()
        UIView.commitAnimations()
    }
    
}

extension FeedChatVC: CustomTableViewCellDelegate,MFMessageComposeViewControllerDelegate,CNContactViewControllerDelegate,AudioManagerDelegate{
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismissView(animated: true, completion: nil)
        var message = ""
        switch result {
        case .cancelled:
            message = "Message cancelled"
            break
        case .sent:
            message = "Message sent"
            break
        case .failed:
            message = "Message failed"
            break
        default:
            break
        }
        self.view.makeToast(message: message, duration: 3, position: HRToastActivityPositionDefault)
    }
  
  
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        if contact != nil{
            if(contact?.givenName ?? "") != "" { 
                ContactHandler.sharedInstance.StoreContacts()
            }
        }
        viewController.dismissView(animated: true, completion: nil)
        
    }
    
    func DidClickMenuAction(actioname: MenuAcion, index: IndexPath) {
        print("")
    }
    
    func contactBtnTapped(sender: UIButton) {
        
        let row = sender.tag
        let indexpath = NSIndexPath.init(row: row, section: 0)
        let cellItem:CustomTableViewCell = (tblChat.cellForRow(at: indexpath as IndexPath) as? CustomTableViewCell)!
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Download PickZon app & stay entertained! \nIOS App: https://apps.apple.com/in/app/pickzon/id1560097730 \n Android App: https://play.google.com/store/apps/details?id=com.chat.pickzon"
            controller.recipients = [cellItem.messageFrame.message.contact_phone]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
 
    
    func contactInfoBtnTapped(sender: UIButton){
        let row = sender.tag
        let indexpath = NSIndexPath.init(row: row, section: 0)
        let cellItem:CustomTableViewCell = (tblChat.cellForRow(at: indexpath as IndexPath) as? CustomTableViewCell)!
        var phone_num:[CNLabeledValue<CNPhoneNumber>] = []
        var email:[CNLabeledValue<NSString>] = []
        var address:[CNLabeledValue<CNPostalAddress>] = []
        let contact = CNMutableContact()
        contact.givenName = (cellItem.messageFrame.message.contact_name)!
        let values = CNLabeledValue(label:"Home" , value:CNPhoneNumber(stringValue:cellItem.messageFrame.message.contact_phone))
        contact.phoneNumbers.append(values)
        if(phone_num.count > 0){
            contact.phoneNumbers = phone_num
        }
        let controller = CNContactViewController(forNewContact: contact)
        controller.delegate = self
        let navigationController = UINavigationController(rootViewController: controller)
        self.presentView(navigationController, animated: true)
    }
    
    
    func saveTarget(sender: UIButton) {
        if(ContactHandler.sharedInstance.CheckCheckPermission())
        {
            
            let row = sender.tag
            let indexpath = NSIndexPath.init(row: row, section: 0)
            let cellItem:CustomTableViewCell = (tblChat.cellForRow(at: indexpath as IndexPath) as? CustomTableViewCell)!
           // self.is_chatPage_contact = true
            var phone_num:[CNLabeledValue<CNPhoneNumber>] = []
            var email:[CNLabeledValue<NSString>] = []
            var address:[CNLabeledValue<CNPostalAddress>] = []
            
            let contact = CNMutableContact()
            contact.givenName = (cellItem.messageFrame.message.contact_name)!
            let values = CNLabeledValue(label:"Home" , value:CNPhoneNumber(stringValue:cellItem.messageFrame.message.contact_phone))

            contact.phoneNumbers.append(values)

           /* let data = (cellItem.messageFrame.message.contact_details)!.data(using:.utf8)
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                let contact_address = CNMutablePostalAddress()
                // Parse JSON data
                if let phone_number:NSArray = jsonResult.value(forKey: "phone_number") as? NSArray {
                    _ = phone_number.map {
                        let i = phone_number.index(of: $0)
                        let get_value:NSDictionary = phone_number[i] as! NSDictionary
                        let type = get_value.value(forKey:"type") as! String
                        let value_ph = get_value.value(forKey:"value") as! String
                        let values = CNLabeledValue(label:type , value:CNPhoneNumber(stringValue:value_ph))
                        phone_num.append(values)
                    }
                }
                
                if let email_arr:NSArray = jsonResult.value(forKey: "email") as? NSArray {
                    _ = email_arr.map {
                        let i = email_arr.index(of: $0)
                        let get_value:NSDictionary = email_arr[i] as! NSDictionary
                        let type = get_value.value(forKey:"type") as! String
                        let value_ph = get_value.value(forKey:"value") as! String
                        let values = CNLabeledValue(label:type , value:value_ph as NSString)
                        email.append(values)
                    }
                }
                
                if let address_arr:NSArray = jsonResult.value(forKey: "address") as? NSArray {
                    _ = address_arr.map {
                        let i = address_arr.index(of: $0)
                        
                        let get_value:NSDictionary = address_arr[i] as! NSDictionary
                        contact_address.street = get_value.value(forKey:"street") as! String
                        contact_address.city = get_value.value(forKey:"city") as! String
                        contact_address.state = get_value.value(forKey:"state") as! String
                        contact_address.postalCode = get_value.value(forKey:"postalCode") as! String
                        contact_address.country = get_value.value(forKey:"country") as! String
                        let values = CNLabeledValue<CNPostalAddress>(label:"home" , value:contact_address)
                        address.append(values)
                    }
                }
            } catch {
                
            }
            */
            if(phone_num.count > 0){
                
                contact.phoneNumbers = phone_num
//                contact.emailAddresses = email
//                contact.postalAddresses = address
                
            }
            
            let controller = CNContactViewController(forNewContact: contact)
            controller.delegate = self
            
            let navigationController = UINavigationController(rootViewController: controller)
            self.presentView(navigationController, animated: true)
        }
        else
        {
            self.presentView(Themes.sharedInstance.showContactPermissionAlert, animated: true)
        }
        
    }
    
    func playPauseTapped(sender: UIButton) {
        
        //self.pauseGif()
        audioPlayBtn = sender
        let row:Int = (sender as AnyObject).tag
//        pause_row = row
//        initial = 1
        guard self.chatHistory.count > row else{return}
        let indexpath = NSIndexPath.init(row: row, section: 0)
        
        if let cellItem:CustomTableViewCell = tblChat.cellForRow(at: indexpath as IndexPath) as? CustomTableViewCell {
            
            guard let imgCell = cellItem as? AudioTableViewCell else{return}

            if let audioUrl = URL(string: imgCell.messageFrame.message.url_str){
                
                
                
                let destVc:AudioPlayerVC = StoryBoard.chat.instantiateViewController(withIdentifier: "AudioPlayerVC") as! AudioPlayerVC
                destVc.modalPresentationStyle = .overCurrentContext
                destVc.modalTransitionStyle = .coverVertical
                destVc.audioUrl = audioUrl
                self.present(destVc, animated: true, completion: nil)
                
               // presentPlayer(videoURL, cellItem)
            }
            return
            
            AudioManager.sharedInstence.delegate = self
            if cellItem.RowIndex == AudioManager.sharedInstence.currentIndex{
                if !sender.isSelected{
                    AudioManager.sharedInstence.playSound()
                }
                else{
                    AudioManager.sharedInstence.pauseSound()
                }
                
            }else{
                playerCompleted()
                
                AudioManager.sharedInstence.setupAudioPlayer(with: cellItem.songData, at: indexpath as IndexPath)
            }
            sender.isSelected = !sender.isSelected
            
        }
        
    }
    
    func updateSlider(value:Float){
        guard let index = AudioManager.sharedInstence.currentIndex else{return}
        guard self.chatHistory.count > index.row else{return}
        guard let currentCell:CustomTableViewCell = tblChat.cellForRow(at: index) as? CustomTableViewCell else{return}
        guard let currentAudioCell = currentCell as? AudioTableViewCell else{return}
        UIView.animate(withDuration: 0.3) {
            currentAudioCell.audioSlider.setValue(value, animated: true)
        }
    }
    
    func updateDuration(value: String, at indexPath: IndexPath) {
        guard let index = AudioManager.sharedInstence.currentIndex else{return}
        guard self.chatHistory.count > index.row else{return}
        guard let currentCell:CustomTableViewCell = tblChat.cellForRow(at: index) as? CustomTableViewCell else{return}
        guard let currentAudioCell = currentCell as? AudioTableViewCell else{return}
        currentAudioCell.audioDuration.text = value
        
    }
    func playerCompleted(){
        guard let index = AudioManager.sharedInstence.currentIndex else{return}
        guard self.chatHistory.count > index.row else{return}
        guard let previousCell:CustomTableViewCell = tblChat.cellForRow(at: index) as? CustomTableViewCell else{return}
        guard let preAudioCell = previousCell as? AudioTableViewCell else{return}
        preAudioCell.playPauseButton.isSelected = false
        preAudioCell.audioSlider.value = 0
    }
    
    
    func sliderChanged(_ slider: UISlider, event: UIControl.Event) {
        let row = slider.tag
        let indexpath = IndexPath(row: row, section: 0)
        guard let audioIndex = AudioManager.sharedInstence.currentIndex else{return}
        guard indexpath == audioIndex else{return}
        AudioManager.sharedInstence.playbackSliderValueChanged(slider, event: event)
        guard self.chatHistory.count > indexpath.row else{return}
        guard let previousCell:CustomTableViewCell = tblChat.cellForRow(at: indexpath) as? CustomTableViewCell else{return}
        guard let audioCell = previousCell as? AudioTableViewCell else{return}
        audioCell.playPauseButton.isSelected = event == .editingDidEnd ? true : false
    }
    
    func readMorePressed(sender: UIButton, count: String) {
        print("")

        let row:Int = (sender as AnyObject).tag
//        pause_row = row
//        initial = 1
        guard self.chatHistory.count > row else{return}
        let messageFrame: UUMessageFrame = self.chatHistory[row] as! UUMessageFrame
        messageFrame.message.readmore_count = count
        let indexpath = IndexPath(row: row, section: 0)
        DispatchQueue.main.async{
            self.tblChat.reloadRows(at: [indexpath], with: .none)
        }
    }
    
    func forwordPressed(_ sender: UIButton) {
        print("")
    }
    
    func PasPersonDetail(id: String) {
        print("")
    }
}

extension FeedChatVC{
    
    
    //MARK: OUTGOING MESSAGE
    func addOutgoingMessage(_ payload: String,_ timestamp: Int64 ,type:Int,payloadDict:NSDictionary = [:]){
        
        let newmessageFrame = UUMessageFrame()
        let message = UUMessage()
        message.type = .UUMessageTypeText
        message.strContent = payload
        message.conv_id = fcrId
        message.doc_id = "\(Themes.sharedInstance.Getuser_id())-\(toChat)-\(timestamp)"
        message.filesize = ""
        message.user_from = "\(Themes.sharedInstance.Getuser_id())"
        message.isStar = "false"
        message.message_status = "1"
        message.msgId = "\(timestamp)"
        message.name = fromName
        message.payload = payload
        message.recordId = ""
        message.thumbnail = ""
        message.timestamp = "\(timestamp)"
        message.to = "\(toChat)"
        message.width = ""
        message.height = ""
        message.chat_type = "single"
        message.info_type = "0"
        message._id = "\(timestamp)"
        message.contactmsisdn = ""
        message.progress = "0.0";
        message.message_type = "0"
        message.user_common_id = "\(toChat)-\(Themes.sharedInstance.Getuser_id())"
        message.imagelink = "";
        message.latitude = "";
        message.longitude = "";
        message.title_place = "";
        message.stitle_place = "";
        message.is_deleted = "false"
        message.reply_type = "false"
        message.from = MessageFrom(rawValue: 1) ?? .UUMessageFromMe
        
    //type: 0 /* 0-Text, 1-Media (Image,video,GIF, Document), 2-Link, 3-Contact, 4-Location,*/
        
        if  type == 3{
            message.type = .UUMessageTypeContact
        }else if  type == 4{
            message.type = .UUMessageTypeLocation
        }else if  type == 5{
            message.type = .UUMessageTypeReply
            message.reply_type = "\(replyMessageRecord.message.message_type)"
            message.title_str = replyMessageRecord.message.payload
            message.replyObj = ReplyInfo(respDict: [:])
            message.replyObj.fromName = replyMessageRecord.message?.replyObj?.fromName ?? ""
            message.replyObj.fromId = replyMessageRecord.message?.replyObj?.fromId ?? ""
            message.replyObj.type = replyMessageRecord.message?.replyObj?.type ?? 0
            message.replyObj.payload = replyMessageRecord.message?.replyObj?.payload ?? ""
            message.message_type = "\(replyMessageRecord.message.message_type ?? "")"
        }
        
        newmessageFrame.message = message
        
        chatHistory.add(newmessageFrame)
        tblChat.insertRows(at: [IndexPath(row: chatHistory.count-1, section: 0)], with: .none)
        tableViewScrollToBottom()
        setTail(isAtBottom: true)
    }
    
    
    func addOutgoingContact(payload: String,timestamp: Int64 ,type:Int,name:String,mobileno:String){
        
        let newmessageFrame = UUMessageFrame()
        let message = UUMessage()
        message.type = .UUMessageTypeText
                
    //type: 0 /* 0-Text, 1-Media (Image,video,GIF, Document), 2-Link, 3-Contact, 4-Location,*/
        
        if  type == 3{
            message.type = .UUMessageTypeContact
        }else if  type == 4{
            message.type = .UUMessageTypeLocation
        }else if  type == 1{
            //message.type = .UUMessageTypePicture
        }
        message.strContent = name
        message.conv_id = fcrId
        message.doc_id = "\(Themes.sharedInstance.Getuser_id())-\(toChat)-\(timestamp)"
        message.filesize = ""
        message.user_from = "\(Themes.sharedInstance.Getuser_id())"
        message.isStar = "false"
        message.message_status = "1"
        message.msgId = "\(timestamp)"
        message.name = fromName
        message.payload = payload
        message.recordId = ""
        message.thumbnail = ""
        message.timestamp = "\(timestamp)"
        message.to = "\(toChat)"
        message.width = ""
        message.height = ""
        message.chat_type = "single"
        message.info_type = "0"
        message._id = "\(timestamp)"
        message.contactmsisdn = mobileno
        message.progress = "0.0";
        message.message_type = "0"
        message.user_common_id = "\(toChat)-\(Themes.sharedInstance.Getuser_id())"
        message.imagelink = "";
        message.latitude = "";
        message.longitude = "";
        message.title_place = "";
        message.stitle_place = "";
        message.is_deleted = "false"
        message.reply_type = "false"
        message.contact_profile = ""
        message.contact_phone = mobileno
        message.contact_name = name
        message.from = MessageFrom(rawValue: 1) ?? .UUMessageFromMe
        newmessageFrame.message = message
        newmessageFrame.message.picture  = UIImage(named: "avatar")
        chatHistory.add(newmessageFrame)
        tblChat.insertRows(at: [IndexPath(row: chatHistory.count-1, section: 0)], with: .none)
        tableViewScrollToBottom()
        setTail(isAtBottom: true)
    }
    
    
    func addOutgoingLocation(payload: String,timestamp: Int64 ,type:Int,title:String,subTitle:String,redirectLink:String,imagelink:String,lat:CLLocationDegrees,long:CLLocationDegrees){
        
        let newmessageFrame = UUMessageFrame()
        let message = UUMessage()
        message.type = .UUMessageTypeText
                
    //type: 0 /* 0-Text, 1-Media (Image,video,GIF, Document), 2-Link, 3-Contact, 4-Location,*/
        
       
        message.strContent = title
        message.conv_id = fcrId
        message.doc_id = "\(Themes.sharedInstance.Getuser_id())-\(toChat)-\(timestamp)"
        message.filesize = ""
        message.user_from = "\(Themes.sharedInstance.Getuser_id())"
        message.isStar = "false"
        message.message_status = "1"
        message.msgId = "\(timestamp)"
        message.name = fromName
        message.payload = payload
        message.recordId = ""
        message.thumbnail = ""
        message.timestamp = "\(timestamp)"
        message.to = "\(toChat)"
        message.width = ""
        message.height = ""
        message.chat_type = "single"
        message.info_type = "0"
        message._id = "\(timestamp)"
        message.contactmsisdn = ""
        message.progress = "0.0";
        message.message_type = "0"
        message.user_common_id = "\(toChat)-\(Themes.sharedInstance.Getuser_id())"
        message.imagelink = redirectLink
        message.latitude = "\(lat)"
        message.longitude = "\(long)"
        message.title_place = title
        message.stitle_place = subTitle
        message.imageURl = imagelink
        message.is_deleted = "false"
        message.reply_type = "false"
        message.contact_profile = ""
        message.contact_phone = ""
        message.contact_name = ""
        message.from = MessageFrom(rawValue: 1) ?? .UUMessageFromMe
        newmessageFrame.message = message
        newmessageFrame.message.picture  = UIImage(named: "avatar")
        
        if  type == 3{
            message.type = .UUMessageTypeContact
        }else if  type == 4{
            message.type = .UUMessageTypeLocation
            message.payload = title

        }else if  type == 1{
            //message.type = .UUMessageTypePicture
        }
        chatHistory.add(newmessageFrame)
        tblChat.insertRows(at: [IndexPath(row: chatHistory.count-1, section: 0)], with: .none)
        tableViewScrollToBottom()
        setTail(isAtBottom: true)
    }
    
    
    func addOutgoingMediaMessage(_ payload: String,_ timestamp: Int64 ,type:Int,url:String,thumbUrl:String,duration:String){
        
        let newmessageFrame = UUMessageFrame()
        let message = UUMessage()
        message.type = .UUMessageTypeText
        message.strContent = payload
        message.conv_id = fcrId
        message.doc_id = "\(Themes.sharedInstance.Getuser_id())-\(toChat)-\(timestamp)"
        message.filesize = ""
        message.user_from = "\(Themes.sharedInstance.Getuser_id())"
        message.isStar = "false"
        message.message_status = "1"
        message.msgId = "\(timestamp)"
        message.name = fromName
        message.payload = payload
        message.recordId = ""
        message.thumbnail = ""
        message.timestamp = "\(timestamp)"
        message.to = "\(toChat)"
        message.width = ""
        message.height = ""
        message.chat_type = "single"
        message.info_type = "0"
        message._id = "\(timestamp)"
        message.contactmsisdn = ""
        message.progress = "0.0";
        message.message_type = "0"
        message.user_common_id = "\(toChat)-\(Themes.sharedInstance.Getuser_id())"
        message.imagelink = "";
        message.latitude = "";
        message.longitude = "";
        message.title_place = "";
        message.stitle_place = "";
        message.is_deleted = "false"
        message.reply_type = "false"
        message.from = MessageFrom(rawValue: 1) ?? .UUMessageFromMe

    //type: 0 /* 0-Text, 1-Media (Image,video,GIF, Document), 2-Link, 3-Contact, 4-Location,*/
        
        message.title_str = payload
        if  type == 1{
            message.url_str = url
            message.thumbnail = thumbUrl
            
            if  checkMediaTypes(strUrl: message.url_str) == 1{
                message.type = .UUMessageTypePicture
            }else if checkMediaTypes(strUrl: message.url_str) == 3{
              message.type = .UUMessageTypeVideo
              message.duration = duration
            }else if checkMediaTypes(strUrl: message.url_str) == 2{
                message.type = .UUMessageTypeDocument
            }
            
        }else if  type == 3{
            message.type = .UUMessageTypeContact
        }else if  type == 4{
            message.type = .UUMessageTypeLocation
        }else if  type == 5{
            message.type = .UUMessageTypeReply
            message.reply_type = "\(replyMessageRecord.message.type)"
            message.reply_type = "true"
            message.title_str = replyMessageRecord.message.payload
        }else if  type == 6{
            message.type = .UUMessageTypeVoice
            message.url_str = url
            message.thumbnail = thumbUrl
            message.duration = duration
        }
        
        newmessageFrame.message = message
        
        chatHistory.add(newmessageFrame)
        tblChat.insertRows(at: [IndexPath(row: chatHistory.count-1, section: 0)], with: .none)
        tableViewScrollToBottom()
        setTail(isAtBottom: true)
    }
}




extension FeedChatVC:QLPreviewControllerDataSource, QLPreviewControllerDelegate{
    
    
    
    private func downloadfile(fileName:String, itemUrl:String){
        
        if let url = URL(string:itemUrl){
            previewDocUrl = url
            let documentsURL = Themes.sharedInstance.getLocalURLForFileServerURL(Url: url)
            print("Audio File URL :",documentsURL)
            
            let destination: DownloadRequest.Destination = { _, _ in
                return (documentsURL, [.removePreviousFile])
            }
            Themes.sharedInstance.activityView(View: self.view)
            
            AF.download(itemUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil, to: destination).downloadProgress(queue: DispatchQueue.global(qos: .background)) {
                (progress) in
                // print("Completed Progress: \(progress.fractionCompleted)")
                //print("Totaldddd Progress: \(progress.completedUnitCount)....\(url)")
                
                
            }.validate().responseData { ( response ) in
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                DispatchQueue.main.async {
                    switch response.result {
                        
                    case .success(_):
                        print("success")
                        
                        
                        self.previewDocUrl = documentsURL
                        DispatchQueue.main.async {
                            let previewController = QLPreviewController()
                            previewController.dataSource = self
                            previewController.delegate = self
                            self.present(previewController, animated: true)
                        }
                        
                    case let .failure(error):
                        print("\(error.localizedDescription)")
                    }
                }
            }
        }
        else
        {
            
        }
        
    }
    
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        
        [previewDocUrl].removeSavedURLFiles()
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
        
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        
        return previewDocUrl! as  QLPreviewItem
    }
}

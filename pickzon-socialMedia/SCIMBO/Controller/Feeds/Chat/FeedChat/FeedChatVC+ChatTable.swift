//
//  FeedChatVC+ChatTable.swift
//  SCIMBO
//
//  Created by Getkart on 02/08/21.
//  Copyright © 2021 Radheshyam Yadav. All rights reserved.
//

import Foundation
import UIKit
import JSSAlertView
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

extension FeedChatVC: UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate,ReplyDetailViewDelegate{

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return  self.chatHistory.count
        
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let messageFrame:UUMessageFrame = self.chatHistory[indexPath.row] as! UUMessageFrame
        var cell_main : UITableViewCell = UITableViewCell()
        
        if messageFrame.message.info_type == "0" {
            let cell1 = TableviewCellGenerator.sharedInstance.returnCell(for: tableView, messageFrame: messageFrame, indexPath: indexPath, searchedText: "")
            cell1.delegate = self
            cell1.RowIndex = indexPath
            cell1.customButton.addTarget(self, action: #selector(self.didClickCellButton(_:)), for: .touchUpInside)
           // cell1.backgroundColor = isSearchCell(messageFrame) ? .lightText : .clear
//            
//            let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureCellAction(_:)))
//            pan.delegate = self
            
            cell1.contentView.tag = indexPath.row
            
            let long = UILongPressGestureRecognizer(target: self, action: #selector(self.longGestureCellAction(_:)))
            long.delegate = self
            
           // cell1.contentView.addGestureRecognizer(pan)
            cell1.contentView.addGestureRecognizer(long)
            
            return cell1
            
        }else if(messageFrame.message.info_type == "72"){
            
            let encryptiocell:EncryptionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "EncryptionTableViewCell") as! EncryptionTableViewCell
            encryptiocell.msgLbl.layer.cornerRadius = 5.0
            
            encryptiocell.msgLbl.text = "🔒 Messages to this chat are now secured with end-to-end encryption"
            
            return encryptiocell
        }else{
            
            let cell:ChatInfoCell = tableView.dequeueReusableCell(withIdentifier: "ChatInfoCell") as! ChatInfoCell
            cell.Info_Btn.tag = indexPath.row
            var infoStr : String = String()
            var dateStr : String = String()
            
            if(messageFrame.message.info_type != "10")
            {
                cell.Info_Btn.isHidden = false
                cell.date_lbl.isHidden = true
                if(messageFrame.message._id != nil)
                {
                    let checkOtherMessages:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: messageFrame.message._id!)
                    if(checkOtherMessages)
                    {
                        let MessageInfoArr=DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: messageFrame.message._id, SortDescriptor: nil) as! [NSManagedObject]
                        
                        if(MessageInfoArr.count > 0)
                        {
                            _ = MessageInfoArr.map{
                                
                                let messageDict=$0
                                let GrounInfo=Themes.sharedInstance.CheckNullvalue(Passed_value: messageDict.value(forKey: "group_type"))
                                let CreatedUserID = Themes.sharedInstance.CheckNullvalue(Passed_value: messageDict.value(forKey: "from"))
                                
                                infoStr = Themes.sharedInstance.returnOtherMessages(CreatedUserID, Themes.sharedInstance.CheckNullvalue(Passed_value: messageDict.value(forKey: "person_id")), GrounInfo)
                                
                                cell.Info_Btn.clipsToBounds=true
                                cell.Info_Btn.layer.cornerRadius=5.0
                            }
                        }
                        
                    }
                    else
                    {
                        infoStr = "can't show this message"
                    }
                }
                else
                {
                    infoStr = "can't show this message"
                }
                
            }
            
            else
            {
                cell.Info_Btn.isHidden = true
                cell.date_lbl.isHidden = false
                dateStr = Themes.sharedInstance.ReturnDateTimeFormat(timestamp: messageFrame.message.timestamp)
            }
            
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
        cell_main.backgroundColor = UIColor.clear
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        cell_main.selectedBackgroundView = backgroundView
        
        return cell_main
    }
    
    
    @objc func didClickCellButton(_ sender: UIButton){
        guard !isBeginEditing else{
            let row:Int = (sender as AnyObject).tag
            guard self.chatHistory.count > row else{return}
            let indexpath = NSIndexPath.init(row: row, section: 0)
            self.Firstindexpath = indexpath as IndexPath
            
            if let cell = tblChat.cellForRow(at: self.Firstindexpath) {
                if cell.isSelected {
                    tblChat.deselectRow(at: Firstindexpath, animated: false)
                    tableView(tblChat, cellForRowAt: Firstindexpath)
                }else {
                    tblChat.selectRow(at: Firstindexpath, animated: false, scrollPosition: .none)
                    tableView(tblChat, cellForRowAt: Firstindexpath)
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
                    
                    name = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: userid, returnStr: "user_name")
                    
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
                
               /* let videoPath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                
                let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
                
                let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                
                
                if(download_status == "2"),(videoPath != ""),FileManager.default.fileExists(atPath: videoPath)
                {
                    let videoURL = URL(fileURLWithPath: videoPath)
                    self.presentPlayer(videoURL, cellItem)
                    
                }
                else
                {
                    if download_status != "1"{
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: ["download_status" : "0"])
                        DownloadHandler.sharedinstance.handleDownLoad(true)
                    }
                    
                    if(serverpath != "")
                    {
                        let videoURL = URL(string: Themes.sharedInstance.getDownloadURL(serverpath))
                        self.presentPlayer(videoURL, cellItem)
                    }
                }
                */
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
                
                let objVC:DocViewController = StoryBoard.main.instantiateViewController(withIdentifier: "DocViewControllerID") as! DocViewController
                objVC.webkitTitle =  "" //cellItem.messageFrame.message.docName
                objVC.webkitURL = cellItem.messageFrame.message.url_str
                self.pushView(objVC, animated: true)
                
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
            default: break
            }
        }
        
    }
    
    
    fileprivate func presentPlayer(_ videoURL: URL?, _ cellItem: CustomTableViewCell) {
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
                config.menuWidth = 135
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
                        let messageFrame = (self.chatHistory as! [UUMessageFrame])[index.row]
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
                        
                        /*self.isForwardAction = false
                        self.isBeginEditing = true
                        self.left_item.image = #imageLiteral(resourceName: "trash")
                        self.right_item.title = "Cancel"
                        self.center_item.title = "Clear Chat"
                        self.Firstindexpath = index
                        self.perform(#selector(self.SelectIndexpath), with:self , afterDelay: 0.3)
                       self.ShowToolBar()
                        */
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
                        self.center_item.image = #imageLiteral(resourceName: "share")
                        self.right_item.title = "Cancel"
                        self.Firstindexpath = index
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
        tblChat.selectRow(at: Firstindexpath, animated: false, scrollPosition: .none)
        tableView(tblChat, cellForRowAt: Firstindexpath)
        left_item.isEnabled = true
        center_item.isEnabled = true
    }
    
    func ShowToolBar()
    {
        self.selectiontoolbar.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.selectiontoolbar.frame = CGRect(x: 0, y: self.IFView.frame.origin.y + 2, width: self.selectiontoolbar.frame.size.width, height: self.selectiontoolbar.frame.size.height )
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
                            let messageinfoVC = self.storyboard?.instantiateViewController(withIdentifier:"MessageInfoViewControllerID" ) as! MessageInfoViewController
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
                            self.IFView.become_FirtResponder()
                           self.ShowReplyView(messageFrame)
                        }
                    }
                    cell?.replyImg.alpha = 0.0
                }
            }
        }
    }
    
    func ShowReplyView(_ messageFrame: UUMessageFrame){
        
        isShowBottomView = true
        isReplyMessage = true
        ReplyView.isHidden = false
        
        let message_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.message_type)
        var payload = Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.payload)
        
        let arr = Themes.sharedInstance.getID_Range_Payload_Name(message: payload)
        
        let ReplyrangeArr = arr[1] as! [NSRange]
        
        payload = arr[2] as! String
        
        if(messageFrame.message.from == MessageFrom(rawValue: 1))
        {
            
            ReplyView.name_Lbl.text = "You"
            ReplyView.name_Lbl.textColor = UIColor(red:23/255, green:109/255, blue:69/255, alpha:1.0)
        }
        else
        {
            ReplyView.name_Lbl.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single")
            ReplyView.name_Lbl.textColor = UIColor.orange
        }
        
        if(message_type == "1")
        {
            ReplyView.thumbnail_Image.isHidden = false
            
            if(ReplyView.name_Lbl.text == "You")
            {
                UploadHandler.Sharedinstance.loadMyImage(messageFrame: messageFrame, imageView: ReplyView.thumbnail_Image, isLoaderShow: false)
            }
            else
            {
                UploadHandler.Sharedinstance.loadFriendsImage(messageFrame: messageFrame, imageView: ReplyView.thumbnail_Image, isLoaderShow: false)
            }
            ReplyView.message_Lbl.text = "📷 Photo"
        }
        else if(message_type == "2")
        {
            ReplyView.thumbnail_Image.isHidden = false
            if(ReplyView.name_Lbl.text == "You")
            {
                UploadHandler.Sharedinstance.loadVideoThumbnailOfMe(messageFrame: messageFrame, ImageView: ReplyView.thumbnail_Image)
            }
            else
            {
                UploadHandler.Sharedinstance.loadVideoThumbnailOfOthers(messageFrame: messageFrame, ImageView: ReplyView.thumbnail_Image)
            }
            ReplyView.message_Lbl.text = "📹 Video"
        }
        else if(message_type == "3")
        {
            ReplyView.thumbnail_Image.isHidden = true
            ReplyView.message_Lbl.text = "🎵 Audio"
            
        }
        else if(message_type == "5")
        {
            ReplyView.thumbnail_Image.isHidden = true
            ReplyView.message_Lbl.text = "📝 \(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.contact_name))"
            
        }
        else if(message_type == "6" || message_type == "20")
        {
            ReplyView.thumbnail_Image.isHidden = true
            ReplyView.message_Lbl.text = "📄 Document"
            
        }
        else if(message_type == "14")
        {
            ReplyView.thumbnail_Image.isHidden = true
            ReplyView.message_Lbl.text = payload
            
        }
        else if(message_type == "4"){
            ReplyView.thumbnail_Image.isHidden = true
            ReplyView.message_Lbl.text = payload
            
        }
        else if(message_type == "0")
        {
            ReplyView.thumbnail_Image.isHidden = true
            ReplyView.message_Lbl.text = payload
            
        }else if(message_type == "7")
        {
            ReplyView.thumbnail_Image.isHidden = true
            ReplyView.message_Lbl.text = payload
        }
        
        if(payload.length > 0)
        {
            let attributed = NSMutableAttributedString(string: ReplyView.message_Lbl.text!)
            
            attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: NSMakeRange(0, (ReplyView.message_Lbl.text?.length)!))
            _ = ReplyrangeArr.map {
                attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15.0)], range: $0)
            }
            if(ReplyrangeArr.count > 0)
            {
                ReplyView.message_Lbl.attributedText = attributed
            }
        }
        
        ReplyMessageRecord = messageFrame
        
        let previousReplyH = ReplyView.message_Lbl.frame.size.height
        
        var height = ReplyView.message_Lbl.text?.height(withConstrainedWidth: ReplyView.message_Lbl.frame.size.width, font: UIFont.boldSystemFont(ofSize: 15.0))
        
        IFView.become_FirtResponder()
        if(Double(height!) > Double(previousReplyH))
        {
            if(Double(height!) > 62.0){
                height = 62
            }
            var rect = ReplyView.message_Lbl.frame
            rect.size.height = height!
            rect.size.width = rect.size.width - 10
            ReplyView.message_Lbl.frame = rect
            
            rect = ReplyView.frame
            rect.size.height = ReplyView.frame.size.height + (height! - previousReplyH)
            rect.origin.y = ReplyView.frame.origin.y - (height! - previousReplyH)
            ReplyView.frame = rect
            self.view.layoutIfNeeded()
        }
        else
        {
            var rect = ReplyView.message_Lbl.frame
            rect.size.height = height!
            ReplyView.message_Lbl.frame = rect
            ReplyView.frame = CGRect(x: 0, y: IFView.frame.origin.y - 50 , width: ReplyView.frame.size.width, height: 50)
            self.view.layoutIfNeeded()
        }
    }
    
    func longGestureDataSource(messageFrame : UUMessageFrame) -> ([String], [String]){
        
        var menuOptionNameArray : [String] = []
        var menuOptionImageNameArray : [String] = []
        
//        var StarString:String = ""
//        if(messageFrame.message.isStar == "1")
//        {
//            StarString = "Unstar"
//        }
//        else
//        {
//            StarString = "Star"
//        }
        if(messageFrame.message.from == MessageFrom(rawValue: 1))
        {
           // let customMenuItem = StarString
            let customMenuItem2 = "Reply"
            let customMenuItem3 = "Forward"
            let customMenuItem4 = "Copy"
           // let customMenuItem5 =  "Info"
            let customMenuItem6 = "Delete"
            if(messageFrame.message.message_status == "0")
            {
                if(messageFrame.message.is_deleted == "1")
                {
                    menuOptionNameArray = [customMenuItem6]
                    menuOptionImageNameArray = ["menu_delete"]
                    
                    
                }
                else
                {
                    menuOptionNameArray = [customMenuItem3,customMenuItem4,customMenuItem6]
                    menuOptionImageNameArray = [ "menu_forward", "menu_copy", "menu_delete"]
                }
                
            }
            else
            {
                if(messageFrame.message.is_deleted == "1")
                {
                    menuOptionNameArray = [customMenuItem6]
                    menuOptionImageNameArray = ["menu_delete"]
                }
                else
                {
                    menuOptionNameArray = [customMenuItem2,customMenuItem3,customMenuItem4,customMenuItem6]
                    menuOptionImageNameArray = ["menu_reply", "menu_forward", "menu_copy", "menu_delete"]
                    
                }
                
            }
            if(is_you_removed)
            {
                if (menuOptionNameArray.contains(customMenuItem2))
                {
                    let index = (menuOptionNameArray.index(of: customMenuItem2))!
                    menuOptionNameArray.remove(at: index)
                    menuOptionImageNameArray.remove(at: index)
                }
            }
            
            if messageFrame.message.payload == "" && menuOptionNameArray.contains(customMenuItem4)
            {
                let index = (menuOptionNameArray.index(of: customMenuItem4))!
                menuOptionNameArray.remove(at: index)
                menuOptionImageNameArray.remove(at: index)
                
            }
            
        }
        else
        {
          //  let customMenuItem = StarString
            let customMenuItem2 = "Reply"
            let customMenuItem3 = "Forward"
            let customMenuItem4 = "Copy"
            let customMenuItem6 = "Delete"
            if(messageFrame.message.message_status == "0")
            {
                if(messageFrame.message.is_deleted == "1")
                {
                    menuOptionNameArray = [customMenuItem6]
                    menuOptionImageNameArray = ["menu_delete"]
                }
                else
                {
                    menuOptionNameArray = [customMenuItem3,customMenuItem4,customMenuItem6]
                    menuOptionImageNameArray = ["menu_forward", "menu_copy", "menu_delete"]
                }
            }
            else
            {
                if(messageFrame.message.is_deleted == "1")
                {
                    menuOptionNameArray = [customMenuItem6]
                    menuOptionImageNameArray = ["menu_delete"]
                }
                else
                {
                    menuOptionNameArray = [customMenuItem2,customMenuItem3,customMenuItem4,customMenuItem6]
                    menuOptionImageNameArray = ["menu_reply", "menu_forward", "menu_copy", "menu_delete"]
                }
                
            }
            if(is_you_removed)
            {
                if (menuOptionNameArray.contains(customMenuItem2))
                {
                    let index = (menuOptionNameArray.index(of: customMenuItem2))!
                    menuOptionNameArray.remove(at: index)
                    menuOptionImageNameArray.remove(at: index)
                }
            }
            if messageFrame.message.payload == "" && menuOptionNameArray.contains(customMenuItem4)
            {
                let index = (menuOptionNameArray.index(of: customMenuItem4))!
                menuOptionNameArray.remove(at: index)
                menuOptionImageNameArray.remove(at: index)
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
        newFrame = IFView.frame
        newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height
        IFView.frame = newFrame
        ReplyView.frame.origin.y =  newFrame.origin.y-50
      //  tagView.frame.origin.y = newFrame.origin.y-tagView.frame.size.height
        IFView.set_Frame()
//        if(bottomnavigateView.isHidden == true)
//        {
//            self.tableViewScrollToBottom()
//        }
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
                self.lytTableBottom.constant = 50 + self.ReplyView.frame.size.height
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
        newFrame = IFView.frame
        if UIDevice().hasNotch {
            newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height - 30
        } else {
            newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height
        }
        IFView.frame = newFrame
        ReplyView.frame.origin.y =  newFrame.origin.y-50
        //tagView.frame.origin.y = newFrame.origin.y-tagView.frame.size.height
        IFView.set_Frame()
        UIView.commitAnimations()
    }
    
}


extension FeedChatVC: CustomTableViewCellDelegate,CNContactViewControllerDelegate,AudioManagerDelegate{
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        if contact != nil{
            if(contact?.givenName ?? "") != "" { //} && self.is_chatPage_contact == false)
                
                    //                let param = ["name" : (contact?.givenName)!]
                    //                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: opponent_id, attribute: "id", UpdationElements: param as NSDictionary)
                    //                chatTableView.reloadData()
                    //                if(!ContactHandler.sharedInstance.StorecontactInProgress)
                    //                {
                    ContactHandler.sharedInstance.StoreContacts()
                    //                }
                }
            }
            viewController.dismissView(animated: true, completion: nil)
            
        }
    
    func DidClickMenuAction(actioname: MenuAcion, index: IndexPath) {
        print("")
    }
    
    func contactBtnTapped(sender: UIButton) {
        print("")
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
    
    //MARK: - Userdefined Functions
    func openMoreOptions(){
        let actionSheetAlertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        actionSheetAlertController.addAction(cancelActionButton)
        
       
        
        let deleteChat = UIAlertAction(title: "Clear Chat", style: .default) { (action) in
           // self.openDeleteChatConfirmation()
            self.emitClearChat()
        }
        actionSheetAlertController.addAction(deleteChat)
        
        
        let blockUser = UIAlertAction(title: "Block User", style: .default) { (action) in
            self.openBlockConfirmation()
        }
        let unblockUser = UIAlertAction(title: "Unblock User", style: .default) { (action) in
            self.openBlockConfirmation()
        }
        (blockByMe == 1) ? actionSheetAlertController.addAction(unblockUser) : actionSheetAlertController.addAction(blockUser)
        
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

          //  self.blockUserVM.blockListingUser(BlockListingUserRequest(from: Themes.sharedInstance.Getuser_id(), to: self.toChat, listingId: self.listing.productId))
        }
        let unblockUser = UIAlertAction(title: "Unblock", style: .default) { (action) in
            
            self.blockUnblockUserApi(isToBlock: false)
          //  self.blockUserVM.unblockListingUser(BlockListingUserRequest(from: Themes.sharedInstance.Getuser_id(), to: self.toChat, listingId: self.listing.productId))
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
            self.emitClearChat()
        }
        actionSheetAlertController.addAction(deleteChat)
        
        
        
        self.present(actionSheetAlertController, animated: true, completion: nil)
        
    }
    
    
    //MARK: API methods
    
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

                           AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: message as? NSString ?? "", buttonTitles: ["OK"], onController: self) { title, index in
                              self.navigationController?.popViewController(animated: true)
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
 
    @objc func tableViewScrollToBottom() {
       
        DispatchQueue.main.async {
            if self.chatHistory.count == 0 ||  self.chatHistory.count == 1{
                return
            }
            let indexPath = IndexPath(row: self.tblChat.numberOfRows(inSection: 0)-1, section: 0)
            self.tblChat.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    //MARK: OUTGOING MESSAGE
    func addOutgoingMessage(_ payload: String,_ timestamp: Int64 ,type:Int,payloadDict:NSDictionary = [:]){
        
        let newmessageFrame = UUMessageFrame()
        let message = UUMessage()
        message.type = .UUMessageTypeText
        message.strContent = payload
        message.conv_id = convoId
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
            message.reply_type = "\(ReplyMessageRecord.message.type)"
            message.reply_type = "true"
            message.title_str = ReplyMessageRecord.message.payload
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
        message.conv_id = convoId
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
        message.conv_id = convoId
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
    
    
    func addOutgoingMediaMessage(_ payload: String,_ timestamp: Int64 ,type:Int,url:String,thumbUrl:String){
        
        let newmessageFrame = UUMessageFrame()
        let message = UUMessage()
        message.type = .UUMessageTypeText
        message.strContent = payload
        message.conv_id = convoId
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

            let objUrlString = url as NSString

            if objUrlString.pathExtension.lowercased() == "gif" ||  objUrlString.pathExtension.lowercased() == "jpeg" || objUrlString.pathExtension.lowercased() == "jpg"  || objUrlString.pathExtension.lowercased() == "png"{
                message.type = .UUMessageTypePicture
            }else if objUrlString.pathExtension.lowercased() == "mp4"{
                message.type = .UUMessageTypePicture
                
            }else if objUrlString.pathExtension.lowercased() == "pdf" || objUrlString.pathExtension.lowercased() == "txt" || objUrlString.pathExtension.lowercased() == "data"{
                message.type = .UUMessageTypeDocument
              }
            
       
        }else if  type == 3{
            message.type = .UUMessageTypeContact
        }else if  type == 4{
            message.type = .UUMessageTypeLocation
        }else if  type == 5{
            message.type = .UUMessageTypeReply
            message.reply_type = "\(ReplyMessageRecord.message.type)"
            message.reply_type = "true"
            message.title_str = ReplyMessageRecord.message.payload
        }else if  type == 6{
            message.type = .UUMessageTypeVoice
            message.url_str = url
            message.thumbnail = thumbUrl
        }
        
        newmessageFrame.message = message
        
        chatHistory.add(newmessageFrame)
        tblChat.insertRows(at: [IndexPath(row: chatHistory.count-1, section: 0)], with: .none)
        tableViewScrollToBottom()
        setTail(isAtBottom: true)
    }
}


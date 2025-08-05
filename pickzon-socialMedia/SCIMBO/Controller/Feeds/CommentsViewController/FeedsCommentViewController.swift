//
//  FeedsCommentViewController.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 7/7/21.
//  Copyright © 2021 GETKART. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding
import GrowingTextView
import IQKeyboardManager
import Alamofire


protocol FeedsCommentDelegate: AnyObject {
    
    func commentAdded(commentText: String, selPostIndex: Int, isFromShared: Bool, isFromDelete:Bool,commentCount:Int16)
}


class FeedsCommentViewController: UIViewController {
    
    @IBOutlet weak var lblReplyingTo:UILabel!
    @IBOutlet weak var replyingBgVw:UIView!
    @IBOutlet weak var txtVwMsg: GrowingTextView!
    @IBOutlet weak var tblView: UITableView!{
        didSet {
            tblView.estimatedRowHeight = 80
            tblView.rowHeight = UITableView.automaticDimension
            tblView.estimatedSectionHeaderHeight = 80
            tblView.sectionHeaderHeight = UITableView.automaticDimension
        }
    }
    var selectedReplySectionIndex:Int = -1
    var selectedReplyRow:Int = -1
    var wallpostid = ""
    var commentDelegate:FeedsCommentDelegate?
    var arrComments = [CommentModel]()
    var isReplySelected = false
    var selPostIndex = 0
    var isFeedsShared = false
    var emptyView:EmptyList?
    var commentCount:Int16 = 0
    var pageNo = 1
    var totalPages = 0
    var isDataLoading = false
    var isHeaderSelected = false
    var pageId = ""
    var postOwnerUserId = ""
    var postFromType: WallPostFrom?
    
    
    //MARK: Controller Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Comments"
        tblView.register(UINib(nibName: "ClipCommentTblCell", bundle: nil), forCellReuseIdentifier: "ClipCommentTblCellId")
        emptyView = EmptyList(frame: CGRect(x: 0, y: -64, width: tblView.frame.size.width, height: tblView.frame.size.height-50))
        emptyView?.imageView?.image = PZImages.noChat
        emptyView?.lblMsg?.text = "No Comments"
        self.tblView.addSubview(emptyView!)
        emptyView?.isHidden = true
        self.tblView?.estimatedRowHeight = 80.0
        self.tblView?.rowHeight = UITableView.automaticDimension

        self.addBackButton()
        self.getCommentAPICall()
        self.tblView?.separatorStyle = .none
        replyingBgVw.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        IQKeyboardManager.shared().isEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        IQKeyboardManager.shared().isEnabled = false
    }
    
    //MARK: UIBUtton Action Methods
    
    func addBackButton(){
        let image3 = UIImage(named: "back")
        let frameimg = CGRect(x: 0, y: 5, width: 40, height: 40)
        
        let someButton = UIButton(frame: frameimg)
        someButton.setImage(image3, for: .normal)
        someButton.addTarget(self, action: #selector(backBtnAction1(_ : )), for: .touchUpInside)
        someButton.showsTouchWhenHighlighted = true
        
        let mailbutton = UIBarButtonItem(customView: someButton)
        self.navigationItem.leftBarButtonItem = mailbutton
    }
    
    @IBAction func backBtnAction1(_ sender: UIButton) {
        
        if self.sheetViewController?.options.useInlineMode == true {
            self.sheetViewController?.attemptDismiss(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func closeReplyViewBtnAction(_ sender: UIButton) {
        
        self.replyingBgVw.isHidden = true
        isReplySelected = false
        lblReplyingTo.text = ""
        isHeaderSelected = false
    }
    
    @IBAction func sendMsgBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        
        if !txtVwMsg.text!.isEmpty {
            if Settings.sharedInstance.userActivity == 0 {
                self.showPostNotAllowedAlert()
            }else if (txtVwMsg.text.count) > 400{
                self.view.makeToast(message: "Text limit exceeds" , duration: 3, position: HRToastActivityPositionDefault)
                
            }else if isReplySelected == true && isHeaderSelected == true {
                
                self.replyCommentApi(row: selectedReplyRow, isHeader: true, section: selectedReplySectionIndex)
            }else if isReplySelected == true && isHeaderSelected == false {
                self.replyCommentApi(row: selectedReplyRow, isHeader: false, section: selectedReplySectionIndex)
            }else {
                self.addCommentAPICall()
            }
        }
    }
    
    func showPostNotAllowedAlert(){
        // Create the alert controller
        let alertController = UIAlertController(title: "PickZon", message: Settings.sharedInstance.userActivityMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - API Implementation
    
    func getCommentAPICall() {
        
        let params = NSMutableDictionary()
        
        params.setValue("\(wallpostid)", forKey: "feedId")
        params.setValue(pageNo, forKey: "pageNumber")
        params.setValue(25, forKey: "pageLimit")
        
        ApiHandler.sharedInstance.makePostGenericData(url: Constant.sharedinstance.getCommentURL, param: params, completion: { (obj:CommentClass) in
            if self.pageNo == 1 {
                self.arrComments.removeAll()
            }
            if obj.status == 1{
                self.isDataLoading = false
                self.commentCount =  obj.payload?.commentCount ?? 0
                self.totalPages = obj.totalPages ?? 0
                self.arrComments.append(contentsOf: obj.payload?.comment ?? [CommentModel]())
                DispatchQueue.main.async {
                    self.tblView.reloadData()
                }
            }else{
                
            }
            self.emptyView?.isHidden = (self.arrComments.count == 0) ? false : true
        })
    }
    
    
    func addCommentAPICall() {
        
        let params = NSMutableDictionary()
        params.setValue("\(wallpostid)", forKey: "feedId")
        params.setValue("\(txtVwMsg.text!)", forKey: "comment")
        
      
        ApiHandler.sharedInstance.makePostGenericData(url: Constant.sharedinstance.addFeedCommentURL, param: params, completion: { (obj:AddCommentResponse) in
            
            if obj.status == 1{
                
                self.commentCount =  obj.payload?.commentCount ?? 0
                self.arrComments.append((obj.payload?.comment)!)
                
                DispatchQueue.main.async {
                    self.commentDelegate?.commentAdded(commentText: self.txtVwMsg.text, selPostIndex: self.selPostIndex , isFromShared:self.isFeedsShared, isFromDelete: false, commentCount:  self.commentCount)
                    self.txtVwMsg.text = ""
                    self.tblView.reloadData()
                }
                
            }else{
                
            }
            self.emptyView?.isHidden = (self.arrComments.count == 0) ? false : true
        })
    }
    
    
    func commentlikeDislikeAPICall(section:Int,isHeader:Bool,row:Int) {
        
        let params = NSMutableDictionary()
        params.setValue("\(wallpostid)", forKey: "feedId")
        
        let objComment = arrComments[section]
        
        if isHeader == true {
            params.setValue(objComment.id, forKey: "commentId")
            params.setValue((objComment.isLike ?? 0) == 1 ? 0 : 1, forKey: "action")
        }else{
            let reply = objComment.reply[row]
            params.setValue(reply.id, forKey: "commentId")
            params.setValue((reply.isLike ?? 0) == 1 ? 0 : 1, forKey: "action")
        }
       
        
        ApiHandler.sharedInstance.makePostGenericData(url: Constant.sharedinstance.commentlikeDislike,param: params, isToShowLoader:false, completion: { (obj:CommentLikeDislike) in
            
            if obj.status == 1 {
                
                if isHeader == true {
                    self.arrComments[section].isLike = (objComment.isLike ?? 0) == 1 ? 0 : 1
                    self.arrComments[section].commentLikeCount = obj.payload?.commentLikeCount ?? 0
                }else{
                    
                    let reply = objComment.reply[row]
                    self.arrComments[section].reply[row].isLike = (reply.isLike ?? 0) == 1 ? 0 : 1
                    self.arrComments[section].reply[row].commentLikeCount = obj.payload?.commentLikeCount ?? 0
                }
                
                DispatchQueue.main.async {
                    self.tblView.reloadData()
                }
                
            }else{
                
            }
            
        })
    }
    
    
    func deleteCommentApiBtnAction(section:Int,isHeader:Bool,row:Int) {
        
        
        let params = NSMutableDictionary()
        let objComment = arrComments[section]
        
        var commentId = ""
        if isHeader == true {
            commentId = objComment.id ?? ""
        }else{
            commentId = objComment.reply[row].id ?? ""
        }
        
        let url = "\(Constant.sharedinstance.deleteFeedCommentURL)/\(commentId)"
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeDeleteAPICall(url: url, param: params) { responseObject, error in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }
            else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                let payload = result["payload"] as? NSDictionary ?? [:]
                
                if status == 1{
                    
                    if isHeader == true {
                        self.arrComments.remove(at: section)
                    }else{
                        self.arrComments[section].reply.remove(at:row)
                    }
                    
                    self.commentDelegate?.commentAdded(commentText: self.txtVwMsg.text, selPostIndex: self.selPostIndex , isFromShared:self.isFeedsShared, isFromDelete: true, commentCount: payload["commentCount"] as? Int16 ?? 0)
                    
                    DispatchQueue.main.async {
                        self.tblView.reloadData()
                    }
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
            
            self.emptyView?.isHidden = (self.arrComments.count == 0) ? false : true
        }
    }
    
    
    
    func replyCommentApi(row:Int,isHeader:Bool,section:Int){
        
        let params = NSMutableDictionary()
        let commentObj = arrComments[section]
        params.setValue(commentObj.id, forKey: "commentId")
        params.setValue("\(wallpostid)", forKey: "feedId")
        params.setValue("\(txtVwMsg.text!)", forKey: "comment")
        
        if isHeader == false {
            let replyObj = commentObj.reply[row]
            params.setValue(replyObj.userInfo?.pickzonId ?? "", forKey: "replyTo")
        }else{
            params.setValue(commentObj.userInfo?.pickzonId ?? "", forKey: "replyTo")
        }
        
       
        ApiHandler.sharedInstance.makePostGenericData(url: Constant.sharedinstance.addFeedCommentURL, param: params, completion: { (obj:CommentReplyResponse) in
            
            if obj.status == 1{
                self.commentCount =  obj.payload?.commentCount ?? 0
                self.arrComments[section].reply.append(obj.payload?.comment ?? CommentReply())
                
                self.commentDelegate?.commentAdded(commentText: self.txtVwMsg.text, selPostIndex: self.selPostIndex , isFromShared:self.isFeedsShared, isFromDelete: false, commentCount: self.commentCount)
                
                DispatchQueue.main.async {
                    
                    self.replyingBgVw.isHidden = true
                    self.isReplySelected = false
                    self.arrComments[section].isExpanded = true
                    self.isHeaderSelected = false
                    self.selectedReplySectionIndex = -1
                    self.lblReplyingTo.text = ""
                    self.txtVwMsg.text = ""
                    self.tblView.reloadData()
                }
                
            }else{
                
            }
        })
    }
}
    

//MARK: - TableViewDelegate and DataSource implementation

extension FeedsCommentViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrComments.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if arrComments.count > section{
            
            
            return  (arrComments[section].isExpanded) ? arrComments[section].reply.count : 0
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClipCommentTblCellId") as! ClipCommentTblCell
        
        let obj = arrComments[section]
        cell.lblName.text = obj.userInfo?.pickzonId?.lowercased() ?? ""
        cell.lblComment.text = obj.comment ?? ""
        cell.btnDay.setTitle(obj.feedTime ?? "", for: .normal)
        cell.cnstrntLeading.constant = 0
        cell.profilePicView.setImgView(profilePic: obj.userInfo?.profilePic ?? "", frameImg:  obj.userInfo?.avatar ?? "",changeValue: 5)
             cell.imgVwCelebrity.isHidden = true
         if (obj.userInfo?.celebrity ?? 0) == 1{
            cell.imgVwCelebrity.isHidden = false
            cell.imgVwCelebrity.image = PZImages.greenVerification
        }else if (obj.userInfo?.celebrity ?? 0) == 4{
            cell.imgVwCelebrity.isHidden = false
            cell.imgVwCelebrity.image = PZImages.goldVerification
        }else if (obj.userInfo?.celebrity ?? 0) == 5{
            cell.imgVwCelebrity.isHidden = false
            cell.imgVwCelebrity.image = PZImages.blueVerification
        }
        
        let str = (obj.isExpanded) ? "Hide \(obj.reply.count) replies" : "View \(obj.reply.count) replies"
        cell.btnExpand.setTitle(str, for: .normal)
        cell.btnExpand.isHidden = (obj.reply.count) > 0 ? false : true
        cell.btnExpand.tag = section
        cell.btnExpand.addTarget(self, action: #selector(expandHeaderBtnAction(_ : )), for: .touchUpInside)
        
        cell.btnReply.tag = section
        cell.btnReply.addTarget(self, action: #selector(replyHeaderBtnAction(_ : )), for: .touchUpInside)
        
        cell.btnLike.tag = section
        cell.btnLike.addTarget(self, action: #selector(likeHeaderListBtnAction(_ : )), for: .touchUpInside)

        cell.profilePicView?.imgVwProfile?.tag = section
        cell.profilePicView?.imgVwProfile?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                      action:#selector(self.handleHeaderProfilePicTap(_:))))
        cell.btnHeart.isHidden = true
        cell.btnReply.isHidden = false
        cell.btnDelete.isHidden = true

        cell.btnDelete.tag = section
        cell.btnDelete.addTarget(self, action: #selector(deleteCommentHeaderBtnAction(sender:)), for: .touchUpInside)
        
        if obj.commentLikeCount ?? 0  == 0 {
            cell.btnLike.setTitle("", for: .normal)
            
        }else{
            cell.btnLike.setTitle("\(obj.commentLikeCount ?? 0) like", for: .normal)
        }
        
        if  obj.userInfo?.id ?? "" ==  Themes.sharedInstance.Getuser_id() {
            
            cell.btnHeart.isHidden = true
            cell.btnDelete.isHidden = false
            cell.btnReply.isHidden = true
       
        }else if  postOwnerUserId == Themes.sharedInstance.Getuser_id() {
           
            cell.btnHeart.isHidden = false
            cell.btnDelete.isHidden = false
            cell.btnReply.isHidden = false
           
        }else {
            cell.btnHeart.isHidden = false
            cell.btnReply.isHidden = false
        }
        
        cell.btnHeart.setImage(UIImage(named:  (obj.isLike ?? 0) == 1 ? "heart-selected" : "heart-7"), for: .normal)
        cell.btnHeart.tag = section
        cell.btnHeart.addTarget(self, action: #selector(likeHeaderCommentBtnAction(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClipCommentTblCellId", for: indexPath) as! ClipCommentTblCell
        cell.cnstrntLeading.constant = 40
        cell.btnExpand.isHidden = true
        
        let obj = arrComments[indexPath.section]
        
        let replyObj = obj.reply[indexPath.row]
        
        cell.lblName.text = replyObj.userInfo?.pickzonId?.lowercased() ?? ""
        
        let replyMsg = (replyObj.replyTo ?? "").count > 0 ? "@\(replyObj.replyTo ?? "")" : ""
        cell.lblComment.setAttributedText(firstText: replyMsg, firstcolor: UIColor.systemBlue, seconText: replyObj.comment ?? "", secondColor: UIColor.label ,isBold:false)
        
        cell.btnDay.setTitle(replyObj.feedTime ?? "", for: .normal)

        cell.imgVwCelebrity.isHidden = true
         if (replyObj.userInfo?.celebrity ?? 0) == 1{
            cell.imgVwCelebrity.isHidden = false
            cell.imgVwCelebrity.image = PZImages.greenVerification
        }else if (replyObj.userInfo?.celebrity ?? 0) == 4{
            cell.imgVwCelebrity.isHidden = false
            cell.imgVwCelebrity.image = PZImages.goldVerification
        }else if (replyObj.userInfo?.celebrity ?? 0) == 5{
            cell.imgVwCelebrity.isHidden = false
            cell.imgVwCelebrity.image = PZImages.blueVerification
        }
        
        
        cell.profilePicView.setImgView(profilePic: replyObj.userInfo?.profilePic ?? "", frameImg: replyObj.userInfo?.avatar ?? "",changeValue: 5)
   
        cell.btnReply.tag = indexPath.row
        cell.btnReply.addTarget(self, action: #selector(replyBtnAction(_ : )), for: .touchUpInside)
        
        cell.btnLike.tag = indexPath.row
        cell.btnLike.addTarget(self, action: #selector(likeListBtnAction(_ : )), for: .touchUpInside)
        
        
        if replyObj.commentLikeCount ?? 0  == 0 {
            cell.btnLike.setTitle("", for: .normal)
            
        }else{
            cell.btnLike.setTitle("\(replyObj.commentLikeCount ?? 0) like", for: .normal)
        }
       
        cell.btnProfile.tag = indexPath.row
        cell.btnProfile.addTarget(self, action: #selector(openProfile(sender:)), for: .touchUpInside)
        
        cell.profilePicView.imgVwProfile?.tag = indexPath.row
        cell.profilePicView.imgVwProfile?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                      action:#selector(self.handleProfilePicTap(_:))))
        cell.btnHeart.isHidden = true
        cell.btnReply.isHidden = false
        cell.btnDelete.isHidden = true
        
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(deleteCommentBtnAction(sender:)), for: .touchUpInside)
        
        
        
        if  replyObj.userInfo?.id ?? "" == Themes.sharedInstance.Getuser_id(){
            
            cell.btnHeart.isHidden = true
            cell.btnDelete.isHidden = false
            cell.btnReply.isHidden = true
       
        }else if  postOwnerUserId == Themes.sharedInstance.Getuser_id() {
           
            cell.btnHeart.isHidden = false
            cell.btnDelete.isHidden = false
            cell.btnReply.isHidden = false
           
        }else{
            cell.btnHeart.isHidden = false
            cell.btnReply.isHidden = false
        }
        
        cell.btnHeart.setImage(UIImage(named:  (replyObj.isLike ?? 0) == 1 ? "heart-selected" : "heart-7"), for: .normal)
        cell.btnHeart.tag = indexPath.row
        cell.btnHeart.addTarget(self, action: #selector(likeBtnAction(_:)), for: .touchUpInside)
                
        return cell
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
        {
            if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                
                self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
                return
            }
            if !isDataLoading {
                if pageNo <= totalPages {
                    isDataLoading = true
                    pageNo = pageNo + 1
                    self.getCommentAPICall()
                }
            }
        }
        
    }
    
    //MARK: Selector Methods
    
    @objc func deleteCommentBtnAction(sender:UIButton) {
        
        let buttonPosition = sender.convert(CGPoint.zero,  to: self.tblView)
        if  let indexPath = self.tblView.indexPathForRow(at: buttonPosition){
            deleteCommentApiBtnAction(section: indexPath.section, isHeader: false,row:indexPath.row)
        }
    }
    
    @objc func likeBtnAction(_ sender:UIButton){
        
        let buttonPosition = sender.convert(CGPoint.zero,  to: self.tblView)
        if  let indexPath = self.tblView.indexPathForRow(at: buttonPosition){
            
            commentlikeDislikeAPICall(section: indexPath.section, isHeader: false, row: indexPath.row)
        }
    }
    
    
    @objc func replyBtnAction(_ sender:UIButton){
        
        txtVwMsg.becomeFirstResponder()
        
        self.replyingBgVw.isHidden = false
        isReplySelected = true
        isHeaderSelected = false
        let buttonPosition = sender.convert(CGPoint.zero,  to: self.tblView)
        if  let indexPath = self.tblView.indexPathForRow(at: buttonPosition){
            selectedReplySectionIndex = indexPath.section
            selectedReplyRow = indexPath.row
            let commentObj = arrComments[indexPath.section]
            let replyObj =  commentObj.reply[indexPath.row]
            lblReplyingTo.text = "Replying to @\(replyObj.userInfo?.pickzonId ?? "")"
        }
    }
    
   
    @objc  func handleProfilePicTap(_ sender: UITapGestureRecognizer? = nil){
        self.view.endEditing(true)
        
        if let sender = sender?.view{
            
            let buttonPosition = sender.convert(CGPoint.zero,  to: self.tblView)
            let indexPath = self.tblView.indexPathForRow(at: buttonPosition)
           
            if indexPath != nil {
                let commentObj = arrComments[indexPath?.section ?? 0]

                    let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                    profileVC.otherMsIsdn =  commentObj.reply[indexPath?.row ?? 0].userInfo?.id ?? ""
                    self.parent?.navigationController?.pushViewController(profileVC, animated: true)
            }
        }
        
    }
    @objc func openProfile(sender:UIButton){
        
        let buttonPosition = sender.convert(CGPoint.zero,  to: self.tblView)
        let indexPath = self.tblView.indexPathForRow(at: buttonPosition)
       
        if indexPath != nil {
            let commentObj = arrComments[indexPath?.section ?? 0]
            

                let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                profileVC.otherMsIsdn =  commentObj.reply[indexPath?.row ?? 0].userInfo?.id ?? ""
                self.parent?.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    
    @objc func  likeListBtnAction(_ sender:UIButton){
        let buttonPosition = sender.convert(CGPoint.zero,  to: self.tblView)
        let indexPath = self.tblView.indexPathForRow(at: buttonPosition)
        if indexPath != nil {
            let profileVC:LikeUsersVC = StoryBoard.main.instantiateViewController(withIdentifier: "LikeUsersVC") as! LikeUsersVC
            profileVC.controllerType = .commentLikeList
            profileVC.postId = arrComments[indexPath!.section].reply[indexPath!.row].id ?? ""
            self.pushView(profileVC, animated: true)
            self.dismissView(animated: true, completion: nil)
        }
    }
    
    
    @objc func expandHeaderBtnAction(_ sender:UIButton){
        
        arrComments[sender.tag].isExpanded = !arrComments[sender.tag].isExpanded
        self.tblView.reloadData()
    }
    
    @objc func replyHeaderBtnAction(_ sender:UIButton){
        txtVwMsg.becomeFirstResponder()
        self.replyingBgVw.isHidden = false
        isReplySelected = true
        isHeaderSelected = true
        selectedReplySectionIndex = sender.tag
        let commentObj = arrComments[selectedReplySectionIndex]
        lblReplyingTo.text = "Replying to @\(commentObj.userInfo?.pickzonId ?? "")"
    }
    
    @objc func deleteCommentHeaderBtnAction(sender:UIButton) {
        
        deleteCommentApiBtnAction(section: sender.tag, isHeader: true,row:-1)
    }
    
    
    @objc func likeHeaderCommentBtnAction(sender:UIButton) {
        
        commentlikeDislikeAPICall(section: sender.tag, isHeader: true, row: -1)
    }
    
    @objc func likeHeaderListBtnAction(_ sender:UIButton){
        
        
        let profileVC:LikeUsersVC = StoryBoard.main.instantiateViewController(withIdentifier: "LikeUsersVC") as! LikeUsersVC
        profileVC.controllerType = .commentLikeList
        profileVC.postId = arrComments[sender.tag].id ?? ""
        self.pushView(profileVC, animated: true)
        self.dismissView(animated: true, completion: nil)
        
    }
    
    @objc  func handleHeaderProfilePicTap(_ sender: UITapGestureRecognizer? = nil){
        self.view.endEditing(true)
        
        if let tag = sender?.view?.tag {

                let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                profileVC.otherMsIsdn =  arrComments[tag].userInfo?.id ?? ""
                self.parent?.navigationController?.pushViewController(profileVC, animated: true)
                
        }
    }

    
    @objc func openHeaderProfile(sender:UIButton){
        self.view.endEditing(true)
             
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn =  arrComments[sender.tag].userInfo?.id ?? ""
            self.parent?.navigationController?.pushViewController(profileVC, animated: true)
        }
}


extension StringProtocol {
    var lines: [SubSequence] { split(whereSeparator: \.isNewline) }
    var removingAllExtraNewLines: String { lines.joined(separator: "\n") }
}



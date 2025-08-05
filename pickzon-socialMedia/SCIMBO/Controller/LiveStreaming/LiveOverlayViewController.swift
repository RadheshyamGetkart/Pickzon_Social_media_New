//
//  LiveOverlayViewController.swift
//
//  Created by Rahul Tiwari on 3/5/20.
//  Copyright © 2020 CASPERON. All rights reserved.

import UIKit
import SocketIO
import IHKeyboardAvoiding
import GrowingTextView
import FittedSheets
import Kingfisher
import SVGAPlayer

class LiveOverlayViewController: UIViewController, UITextViewDelegate {
    
    var notification_dict:NSDictionary = NSDictionary()
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var emitterView: WaveEmitterView!
    @IBOutlet weak var tfMessage: UITextField!
    @IBOutlet weak var inputContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    /// @IBOutlet weak var giftArea: GiftDisplayArea!
    @IBOutlet weak var tvMessage: GrowingTextView!
    @IBOutlet weak var btnLikeVideo: UIButton!
    @IBOutlet weak var btnSendGift: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnPk: UIButton!
    @IBOutlet weak var btnHostOption: UIButton!

    @IBOutlet weak var btnPkRequests: MIBadgeButton!
    @IBOutlet weak var cnstrntHeightCommentTblView: NSLayoutConstraint!
    
    var isUserScrollDown = false
    var isDataLoading = false
    var KeyboardHeight = Double()
    var comments: [LiveComment] = []{
        didSet{
            self.tableView.reloadData()
        }
    }
    var isGoLiveUser = false
    var pageNumber = 1
    var fromId = ""
    var toId = ""
    var livePkId = ""
    var isThreeDotoption = false
    var pickzonId = ""
    private var lastContentOffset: CGFloat = 0

    var timerRefresh:Timer? = nil
    
    //MARK: Controller Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        btnHostOption.isHidden = true
        btnSendGift.layer.cornerRadius = btnSendGift.frame.size.height/2.0
        btnSendGift.clipsToBounds = true
        self.btnSendGift.setGradientColork(colorLeft: Themes.sharedInstance.colorWithHexString(hex: "007AFE"), colorRight: Themes.sharedInstance.colorWithHexString(hex: "18409E"), titleColor: .white, cornerRadious:  btnSendGift.layer.cornerRadius, image: "", title: "Send a gift")
        self.tableView.estimatedRowHeight = 55
        self.tableView.rowHeight = UITableView.automaticDimension
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        if isGoLiveUser == true {
            self.fromId =  fromId.isEmpty ? Themes.sharedInstance.Getuser_id() : fromId
        }
        
        tvMessage.delegate = self
        tfMessage.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 30
        tableView.rowHeight = UITableView.automaticDimension
        tfMessage.attributedPlaceholder = NSAttributedString(string: "Chat here...",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        
 

       // Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(LiveOverlayViewController.tick(_:)), userInfo: nil, repeats: true)
      
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LiveOverlayViewController.handleTap(_:)))
        addObservers()
        
        // self.tableView.refreshControl = self.topRefreshControl
        
        if isGoLiveUser == false{
            
            self.btnShare.setImage(PZImages.threedot, for: .normal)
        }
        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            
            self.emitGetComments()
        //}
        btnShare.setImageTintColor(.white)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.contentInset.top = tableView.bounds.height
        tableView.reloadData()
        timerRefresh?.invalidate()
        timerRefresh = nil
     //   timerRefresh =   Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(tick(_:)), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timerRefresh?.invalidate()
        timerRefresh = nil
        super.viewWillDisappear(animated)
    }
    
    
    func entryEffectAnimate(effectUrl:String,url:String,profilePic:String,avatar:String,pickzonId:String,roomId:String){
      
       // let extra = (UIDevice().hasNotch) ? (UIDevice().safeAreaHeight + 5) : 10
        
   /*
        if isGoLiveUser == false {
            self.cnstrntYAxisEntryEffect.constant = (self.view.frame.size.height * 0.35) + 125 //+ extra
        }else{
            self.cnstrntYAxisEntryEffect.constant = (self.view.frame.size.height * 0.35) + 105 //+ extra
        }
        

        if checkMediaTypes(strUrl: effectUrl) == 5 {
            //SVGA
            print("roomId = \(roomId) = Themes.sharedInstance.Getuser_id() \(Themes.sharedInstance.Getuser_id())")
//            if isGoLiveUser == false  && (roomId == Themes.sharedInstance.Getuser_id()) {
//                self.cnstrntYAxisEntryEffect.constant = (self.view.frame.size.height * 0.35) + 35 // 130 //+ extra
//            }else{
//                self.cnstrntYAxisEntryEffect.constant = (self.view.frame.size.height * 0.35) +  65 //110 //+ extra
//            }
            self.entryEffectBgView.center.x =  self.view.bounds.size.width

            self.animateSVGA(remoteSVGAUrl: effectUrl, pickzonId: pickzonId)
        } else {
            self.entryEffectBgView.center.x =  self.view.bounds.size.width

            entryProfilePicVw.initializeView()
            entryProfilePicVw.setImgView(profilePic: profilePic, frameImg: avatar, changeValue: 5)
            self.entryLblPickzonId.text = "@"+pickzonId
            self.entryEffectGifImgView.setGifFromURL(URL(string: effectUrl), manager: .defaultManager, loopCount: -1, showLoader: true)
            self.entryEffectGifImgView.stopAnimatingGif()
            self.entryEffectBgImgView.kf.setImage(with:  URL(string: url ), placeholder: PZImages.avatar, options: nil, progressBlock: nil) { response in
                //self.imgVwProfile.layer.borderColor = self.bgImagVw.image?.getAverageColour?.cgColor
            }
            self.entryEffectBgView.alpha = 1.0
            self.entryEffectGifImgView.startAnimatingGif()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                
                self.entryEffectBgView.isHidden = false
                
                UIView.animateKeyframes(withDuration:1.5, delay: 0, options: .beginFromCurrentState, animations: {
                    self.entryEffectBgView.center.x -= (self.view.bounds.width - 15)
                    
                    
                }, completion: {_ in
                    // self.entryEffectGifImgView.stopAnimatingGif()
                    //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    //                    self.entryEffectBgView.layer.opacity = 0.5
                    //                    self.entryEffectBgView.isHidden = true
                    //                }
                    
                    UIView.animate(withDuration: 1.0, delay: 0.9, options: .curveEaseOut,
                                   animations: {
                        self.entryEffectBgView.alpha = 0
                    },
                                   completion: { _ in
                        self.entryEffectBgView.isHidden = true
                        //Do anything else that depends on this animation ending
                    })
                })
                
            }
        }*/
    }
    
    
    func animateSVGA(remoteSVGAUrl:String,pickzonId:String){
     /*
        self.remoteSVGAPlayer?.stopAnimation()
      
        if remoteSVGAPlayer == nil {
//            remoteSVGAPlayer = SVGAPlayer(frame: CGRect(x:10, y: -40, width: self.view.frame.size.width-20, height: 150))
         
            remoteSVGAPlayer = SVGAPlayer(frame: CGRect(x:0, y: 0, width: self.bgVwSVGAEntryEffect.frame.size.width, height: 70))

            remoteSVGAPlayer?.backgroundColor = .yellow
            remoteSVGAPlayer?.loops = 1
            remoteSVGAPlayer?.clearsAfterStop = true
            self.bgVwSVGAEntryEffect.addSubview(self.remoteSVGAPlayer!)
        }
        self.remoteSVGAPlayer?.contentMode = .top
        self.remoteSVGAPlayer?.isUserInteractionEnabled = true
        self.bgVwSVGAEntryEffect.backgroundColor = .red
        
        if let url = URL(string: remoteSVGAUrl) {
            let remoteSVGAParser = SVGAParser()
            remoteSVGAParser.enabledMemoryCache = true
            remoteSVGAParser.parse(with: url, completionBlock: { (svgaItem) in
                self.remoteSVGAPlayer?.videoItem = svgaItem
                let para = NSMutableParagraphStyle()
                para.lineBreakMode = .byTruncatingTail
                para.alignment = .left
                
                let shadow = NSShadow()
                shadow.shadowOffset = CGSize(width: 1.0, height: 1.0)
                shadow.shadowBlurRadius = 0.0
                shadow.shadowColor = UIColor.black
                
                let str = NSAttributedString(
                    string: "\(pickzonId)",
                    attributes: [
                        .font: UIFont(name: "Amaranth-Bold", size: 40.0)!,
                        .foregroundColor: UIColor.white,.shadow:shadow,
                        .paragraphStyle: para,
                    ])
                self.remoteSVGAPlayer?.setAttributedText(str, forKey: "name")
                
                self.remoteSVGAPlayer?.startAnimation()
            }, failureBlock: { (error) in
                print("--------------------- \(String(describing: error))")
                
            })
        }
        */
    }
          
    
    func refreshChatListBasedOnPKUserSelected(userId:String){
       
        if userId.length > 0 {
            
        self.comments.removeAll()
        self.tableView.reloadData()
      
            let param = [
                "authToken": Themes.sharedInstance.getAuthToken(),
                "roomId": userId,
                "pageNumber": pageNumber
            ] as [String : Any]
            SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_get_comment_message_list  , param)
        }
    }
    
    func emitAllUserPkRequestList(){
        
        let param = [
            "authToken": Themes.sharedInstance.getAuthToken()
        ] as [String : Any]
        
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_get_all_user_pk_request_list, param)
    }
    
    
    func emitGetComments(){
        if fromId.length > 0 {
            
            let param = [
                "authToken": Themes.sharedInstance.getAuthToken(),
                "roomId": fromId,
                "pageNumber": pageNumber
            ] as [String : Any]
            SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_get_comment_message_list  , param)
        }
    }
    
    
    func addObservers(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sioKickOutUser(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_kick_out ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.recieveNewcomment(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_send_comment_message ), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.commentList(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_comment_message_list ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.socketConnected(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.socketCnnected), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getLikeGoLive(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_like_live_broadcast), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_report_live_pk(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_report_live_pk), object: nil)
        }
    
    
    //MARK: Observers methods
    @objc func socketConnected(notification: Notification) {
        
    }
    
    @objc func sioKickOutUser(notification: Notification) {
        
       /* self.emitterView.emitImage(R.image.heart()!)
        self.emitterView.emitImage(R.image.heart()!)
        self.emitterView.emitImage(R.image.heart()!)*/
    }
    
    @objc func getLikeGoLive(notification: Notification) {
        
        self.emitterView.emitImage(R.image.heart()!)
        self.emitterView.emitImage(R.image.heart()!)
        self.emitterView.emitImage(R.image.heart()!)
    }
    
    @objc func sio_report_live_pk(notification: Notification) {
        
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            
            if let message = response["message"] as? String{
                AppDelegate.sharedInstance.navigationController?.topViewController?.view.makeToast(message:message, duration: 1, position: HRToastActivityPositionDefault)
            }
        }
    }
    
    
    @objc func recieveNewcomment(notification: Notification) {
        
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            
            if let payload = response["payload"] as? Dictionary<String,Any>{
                
              /*  if let entryEffect = payload["entryEffect"] as? Dictionary<String,Any>{
                    
                    let  pickzonId = payload["pickzonId"] as? String ?? ""
                    let  profilePic = payload["profilePic"] as? String ?? ""
                    
                    let  effectUrl = entryEffect["effectUrl"] as? String ?? ""
                    let  url = entryEffect["url"] as? String ?? ""
                    let  avatar = entryEffect["avatar"] as? String ?? ""

                    let roomId = payload["roomId"] as? String ?? ""
                    
                    if effectUrl.count > 0 {
                        
                        self.entryEffectAnimate(effectUrl: effectUrl, url: url, profilePic: profilePic, avatar: avatar, pickzonId: pickzonId, roomId: roomId)
                    }
                }
                */
                if (payload["userId"] as? String ?? "") !=  Themes.sharedInstance.Getuser_id(){
                    //fromId
                    self.comments.append(LiveComment(respDict: payload))
               
                }else if (payload["type"] as? Int ?? 0) == 2{
                    //}else if ((payload["message"] as? String ?? "").lowercased()).contains("gifted"){
                    
                    self.comments.append(LiveComment(respDict: payload))
                }

                if comments.count > 0 {
                    tableView.scrollToRow(at: IndexPath(row: comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                }
            }
        }
    }
    
    @objc func commentList(notification: Notification) {
        
        
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            
            if let payloadArr = response["payload"] as? Array<Dictionary<String,Any>>{
                
                if pageNumber == 1 && self.comments.count > 0 {
                    self.comments.removeAll()
                    self.tableView.reloadData()
                }
                for  objDict in payloadArr{
                   /* if self.pageNumber > 1{
                        self.comments.insert(LiveComment(respDict: objDict), at: 0)
                    }else{
                        self.comments.append(LiveComment(respDict: objDict))
                        
                    }*/
                    self.comments.append(LiveComment(respDict: objDict))
                }
                /*   if self.pageNumber > 1{
                 self.isUserScrollDown = true
                 }
                 
                 if self.comments.count >= 5{
                 tableView.contentInset.top = 0
                 }else{
                 tableView.contentInset.top = tableView.bounds.height
                 }
                 
                 self.pageNumber = self.pageNumber + 1*/
                
//                if self.comments.count >= 5{
//                    tableView.contentInset.top = 0
//                }else{
//                    tableView.contentInset.top = tableView.bounds.height
//                }
               
                if comments.count > 0 {
                    tableView.scrollToRow(at: IndexPath(row: comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                }
            }
            
            self.isDataLoading = false
            self.isUserScrollDown = false

        }
    }
    
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = (endFrame?.size.height ?? 0.0)-view.safeAreaInsets.bottom
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded()},
                           completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }
        tfMessage.resignFirstResponder()
    }
    
    
    @objc func scrollToLastrow(){
        
       if comments.count >= 6 {
           tableView.contentInset.top =  (UIDevice().hasNotch) ? 70 : 0
           
        }else{
            tableView.contentInset.top = tableView.bounds.height
        }

        if comments.count > 0{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                self.tableView.scrollToRow(at: IndexPath(row:  self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }
    }
    
    
    @objc func tick(_ timer: Timer) {
        
        guard comments.count > 0 else {
            return
        }
        /*
         if tableView.contentSize.height > tableView.bounds.height {
         tableView.contentInset.top = 0
         }
         tableView.scrollToRow(at: IndexPath(row: comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
         */
        
        if isUserScrollDown == false {
            /// you reached the end of the table
            if tableView.contentSize.height > tableView.bounds.height {
                tableView.contentInset.top = 0
            }
            if comments.count > 0{
                tableView.scrollToRow(at: IndexPath(row: comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }else{
            
        }
    }
    
    
    //MARK: UIButton Action methods
    @IBAction func giftButtonPressed(_ sender: AnyObject) {
        let vc = R.storyboard.main.giftChooser()!
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func upvoteButtonPressed(_ sender: AnyObject) {
        
        if fromId == Themes.sharedInstance.Getuser_id(){
            
            emitAllUserPkRequestList()
            
        }else{
            self.emitterView.emitImage(R.image.heart()!)
            self.emitterView.emitImage(R.image.heart()!)
            
            let param = [
                "authToken": Themes.sharedInstance.getAuthToken(),
                "roomId": fromId,
            ]
            SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_like_live_broadcast  , param)
        }
    }
    
    
    @IBAction func btnSendMessageAction(_ sender: UIButton) {
        
        //  tvMessage.resignFirstResponder()
        if let text = tvMessage.text , text != "" , text.trimmingLeadingAndTrailingSpaces().count > 0{
            
            let param = [
                "authToken": Themes.sharedInstance.getAuthToken(),
                "roomId": fromId,
                "message": text.trimmingCharacters(in: .whitespaces)
            ]
            SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_send_comment_message , param)
            
            
            guard let realm = DBManager.openRealm() else {
                return
            }
            
            var objComment = LiveComment(respDict: [:])
            objComment.userId = Themes.sharedInstance.Getuser_id()
            objComment.roomId = fromId
            objComment.message = text.trimmingCharacters(in: .whitespaces)
            objComment.name = "Me"
            
            if let existingUser =  realm.object(ofType: DBUser.self, forPrimaryKey: Themes.sharedInstance.Getuser_id()) {
                
                objComment.name = "Me"
                objComment.profilePic = existingUser.profilePic
                objComment.celebrity = existingUser.celebrity
                objComment.pickzonId = existingUser.pickzonId
                objComment.avatar = existingUser.avatar
                objComment.giftingLevel = existingUser.giftingLevel
                
            }else{
                
                
            }
            self.comments.append(objComment)
            self.tableView.reloadData()
        }
        
        tvMessage.text = ""
    }
    
    
    @IBAction func shareBtnAction(_ sender: AnyObject) {
        self.view.endEditing(true)
        
        
        if isGoLiveUser == false {
            isThreeDotoption = true
            let controller = UIStoryboard(name: "TableViewDemo", bundle: nil).instantiateInitialViewController()! as! TableViewDemo
            
            controller.listArray =  ["Share","Report"]
            controller.iconArray =  ["shareRight","Report"]
            controller.delegate = self
            controller.videoIndex = 0
            
            let useInlineMode = AppDelegate.sharedInstance.navigationController!.topViewController!.view != nil
            
            let sheet = SheetViewController(
                controller: controller,
                sizes: [.percent(0.20), .intrinsic],
                options: SheetOptions(useFullScreenMode:false, shrinkPresentingViewController:false, useInlineMode: useInlineMode))
            sheet.allowPullingPastMaxHeight = false
            if let view = AppDelegate.sharedInstance.navigationController?.topViewController?.view {
                sheet.animateIn(to: view, in: AppDelegate.sharedInstance.navigationController!.topViewController!)
            } else {
                AppDelegate.sharedInstance.navigationController?.topViewController!.present(sheet, animated: true, completion: nil)
            }
            
        }else{
            isThreeDotoption = false
            if livePkId.count > 0 {
                let mergeId = "\(fromId)_\(toId)_\(livePkId)"
                ShareMedia.shareMediafrom(type: .pkGolive, mediaId: mergeId, controller: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
                
            }else{
                ShareMedia.shareMediafrom(type: .golive, mediaId: fromId, controller: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
            }
        }
    }
    
    
    @IBAction func sendAGiftBuuttonAction(_ sender: AnyObject) {
        self.view.endEditing(true)
        
        if #available(iOS 13.0, *) {
            
            let controller = StoryBoard.letGo.instantiateViewController(identifier: "SendGiftVC")
            as! SendGiftVC
            // controller.objWallPost = self.objWallPost
            let useInlineMode = view != nil
            controller.title = "Cheer Coins"
            controller.delegate = self
            controller.roomId = fromId
            controller.pickzonId = pickzonId
            let nav = UINavigationController(rootViewController: controller)
            
            var fixedSize = 355 //435
            if UIDevice().hasNotch{
                fixedSize =  365
                //450
            }
            let sheet = SheetViewController(
                controller: nav,
                sizes: [.fixed(CGFloat(fixedSize)),.intrinsic],
                options: SheetOptions(pullBarHeight : 0, presentingViewCornerRadius : 10 , useInlineMode: useInlineMode))
            // addSheetEventLogging(to: sheet)
            sheet.allowGestureThroughOverlay = false
            sheet.cornerRadius = 20
            
            if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
                sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
            } else {
                (AppDelegate.sharedInstance.navigationController?.topViewController)?.present(sheet, animated: true, completion: nil)
            }
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    
}

extension LiveOverlayViewController: UITextFieldDelegate,CoinUpDelegate,GoliveUserDelegate {
    
    func cheerCoinClickedOnAvailableTokens(){
        let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
        AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let previousText:NSString = textView.text! as NSString
        let updatedText = previousText.replacingCharacters(in: range, with: text)
        
        if updatedText.length > 100 {
            return false
        }
        
        if text == "\n" {
            return false
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            return false
        }
        
        let previousText:NSString = textField.text! as NSString
        let updatedText = previousText.replacingCharacters(in: range, with: string)
        
        if updatedText.length > 100 {
            return false
        }
        return true
    }
    
  
    
    /*
     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
     if string == "\n" {
     textField.resignFirstResponder()
     if let text = textField.text , text != "" {
     
     /*
      let MyID = Themes.sharedInstance.Getuser_id()
      
      //let image = "\(ImgUrl)/uploads/users/\(MyID).jpg"
      
      let otherId = opponentId.isEmpty ? MyID : opponentId
      let name = opponentId.isEmpty ? "Me": self.name
      let param = [
      "from": MyID,
      "userid": otherId,
      "comment": text.trimmingCharacters(in: .whitespaces)
      ]
      
      SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_send_comment_message, param)
      
      let comment = LiveComment(id: "", name: name, comment: text.trimmingCharacters(in: .whitespaces), profilePic: MyID)
      
      */
     
     let param = [
     "authToken": Themes.sharedInstance.getAuthToken(),
     "roomId": Themes.sharedInstance.Getuser_id(),
     "message": text.trimmingCharacters(in: .whitespaces)
     ]
     SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_send_comment_message , param)
     
     
     guard let realm = DBManager.openRealm() else {
     return true
     }
     
     
     var objComment = LiveComment(respDict: [:])
     objComment.userId = Themes.sharedInstance.Getuser_id()
     objComment.roomId = fromId
     objComment.message = text.trimmingCharacters(in: .whitespaces)
     objComment.name = "Me"
     
     if let existingUser =  realm.object(ofType: DBUser.self, forPrimaryKey: Themes.sharedInstance.Getuser_id()) {
     
     
     objComment.name = "Me"
     objComment.profilePic = existingUser.profilePic
     objComment.celebrity = existingUser.celebrity
     objComment.pickzonId = existingUser.pickzonId
     
     }else{
     
     
     }
     self.comments.append(objComment)
     self.tableView.reloadData()
     }
     
     textField.text = ""
     return false
     }
     return true
     }
     
     
     */
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //        animateViewMoving(up: true, moveValue: 300)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //        animateViewMoving(up: false, moveValue: 300)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    //MARK: Delegate User Info
    func selectedOption(index:Int,title:String){
        
        if title == "profile"{
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn = comments[index].userId
            self.navigationController?.pushView(profileVC, animated: true)
            
        }else if title == "option"{
            
            if comments[index].pickzonId.lowercased() == "pickzon"{
                return
            }
            if comments[index].userId != Themes.sharedInstance.Getuser_id() && isGoLiveUser == true {
                openListOfOptions(index:index)
            }
        }
    }
    
}

extension LiveOverlayViewController: UITableViewDataSource, UITableViewDelegate,OptionDelegate {
    
    //MARK: UITableview & Datasource Methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentCell
        cell.comment = comments[(indexPath as NSIndexPath).row]
       
        if comments[(indexPath as NSIndexPath).row].giftingLevel.count == 0 {
           // cell.imgVwGiftingLevel.isHidden = true
            cell.cnstrntWidthGiftingLevel.constant = 0

        }else{
           // self.imgVwGiftingLevel.isHidden = false
            cell.cnstrntWidthGiftingLevel.constant = 20
            cell.imgVwGiftingLevel.kf.setImage(with: URL(string: comments[(indexPath as NSIndexPath).row].giftingLevel), options: nil, progressBlock: nil, completionHandler: { response in })
        }
        
        cell.NameLabel.isUserInteractionEnabled = true
        cell.NameLabel.tag = indexPath.row
        cell.NameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleNameTap(_:))))
        cell.profilePicView.imgVwProfile?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleNameTap(_:))))
        cell.profilePicView?.imgVwProfile?.tag = indexPath.row
        
        cell.commentContainer.backgroundColor = Themes.sharedInstance.colorWithHexString(hex: "#28313c").withAlphaComponent(0.3)
   
        cell.commentContainer.layer.cornerRadius = cell.commentContainer.frame.size.height/2.0
        cell.commentContainer.updateConstraints()
        cell.commentContainer.clipsToBounds = true

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       
        if let commentCell = cell as?  CommentCell{
            commentCell.commentContainer.layer.cornerRadius = commentCell.commentContainer.frame.size.height/2.0
            commentCell.commentContainer.clipsToBounds = true
        }
        
        if (indexPath.row + 6 > comments.count) {
            isUserScrollDown = false
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let commentCell = cell as?  CommentCell{
            commentCell.commentContainer.layer.cornerRadius = commentCell.commentContainer.frame.size.height/2.0
            commentCell.commentContainer.clipsToBounds = true
        }
    }
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let visibleCells = tableView.visibleCells
        
        if visibleCells.count == 0 {
            return
        }
        
        guard let bottomCell = visibleCells.last  else {
            return
        }
        
        guard let topCell = visibleCells.first else {
            return
        }
        
        for cell in visibleCells {
            cell.contentView.alpha = 1.0
        }
        
        
        if visibleCells.count < 4 {
            topCell.alpha = 1.0
            return
        }
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            // move up
            topCell.contentView.alpha = 0.1
            if visibleCells.count > 1{
                visibleCells[1].contentView.alpha = 0.2
            }
            
        }else if (self.lastContentOffset < scrollView.contentOffset.y) {
            // move down
           // bottomCell.contentView.alpha = 0.2
        }
        if ((topCell as? CommentCell)?.NameLabel.tag ?? 0 ) > 0 {
            topCell.contentView.alpha = 0.1
            if visibleCells.count > 1{
                visibleCells[1].contentView.alpha = 0.2
            }
        }
        
        self.lastContentOffset = scrollView.contentOffset.y
        
        /* let cellHeight = topCell.frame.size.height - 1
         let tableViewTopPosition = tableView.frame.origin.y
         let tableViewBottomPosition = tableView.frame.origin.y + tableView.frame.size.height
         
         let topCellPositionInTableView = tableView.rectForRow(at: tableView.indexPath(for: topCell)!)
         let bottomCellPositionInTableView = tableView.rectForRow(at: tableView.indexPath(for: bottomCell)!)
         let topCellPosition = tableView.convert(topCellPositionInTableView, to: tableView.superview).origin.y
         let bottomCellPosition = tableView.convert(bottomCellPositionInTableView, to: tableView.superview).origin.y + cellHeight
         
         let modifier: CGFloat = 2.5
         let topCellOpacity = 1.0 - ((tableViewTopPosition - topCellPosition) / cellHeight) * modifier
         let bottomCellOpacity = 1.0 - ((bottomCellPosition - tableViewBottomPosition) / cellHeight) * modifier
         
         topCell.contentView.alpha = topCellOpacity
         bottomCell.contentView.alpha =  bottomCellOpacity
         */
    }
    
   
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if targetContentOffset.pointee.y < scrollView.contentOffset.y {
            // it's going up
            isUserScrollDown = true
                 
        } else {
            // it's going down
        }
    }
    
  
    //MARK: Selector Methods
    @objc func handleNameTap(_ tapInfo:UITapGestureRecognizer){
        
        let tag =  tapInfo.view?.tag ?? 0
        /*    if comments[tag].userId != Themes.sharedInstance.Getuser_id() && isGoLiveUser == true {
         openListOfOptions(index:tag)
         }
         */
        
       if comments.count < tag {
            return
        }
        
        if comments[tag].userId == Themes.sharedInstance.Getuser_id(){
            return
        }
        tvMessage.resignFirstResponder()
        
        
        if #available(iOS 13.0, *) {
            
            let controller = StoryBoard.letGo.instantiateViewController(identifier: "UserInfoVC")
            as! UserInfoVC
            
            
            controller.selIndex = tag
            controller.userObj.name = comments[tag].name
            controller.userObj.profilePic = comments[tag].profilePic
            controller.userObj.pickzonId = comments[tag].pickzonId
            controller.userObj.celebrity = comments[tag].celebrity
            controller.userObj.userId = comments[tag].userId
            
            controller.goLivefromId = fromId
            controller.goLiveToId = toId
            
            controller.delegate = self
            let useInlineMode = view != nil
            controller.title = ""
            controller.navigationController?.navigationBar.isHidden = true
            controller.view.backgroundColor = .clear
            
            var fixedSize = 360
            if UIDevice().hasNotch{
                fixedSize = 375
            }
            let sheet = SheetViewController(
                controller: controller,
                sizes: [.fixed(CGFloat(fixedSize)),.intrinsic],
                options: SheetOptions(pullBarHeight : 0, presentingViewCornerRadius : 0 , useInlineMode: useInlineMode))
            sheet.allowGestureThroughOverlay = false
            sheet.cornerRadius = 20
            sheet.navigationController?.navigationBar.isHidden = true
            sheet.contentBackgroundColor = .clear
            
            if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
                sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
            } else {
                (AppDelegate.sharedInstance.navigationController?.topViewController)?.present(sheet, animated: true, completion: nil)
            }
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    @objc func openListOfOptions(index:Int) {
        
        isThreeDotoption = false
        let controller = UIStoryboard(name: "TableViewDemo", bundle: nil).instantiateInitialViewController()! as! TableViewDemo
        
        
        if Themes.sharedInstance.Getuser_id() == fromId{
            controller.listArray =  ["Kick Out","Block User","Report"]
            controller.iconArray =  ["logout1","BlockAccount","Report"]
        }else{
            controller.listArray =  ["Report"]
            controller.iconArray =  ["Report"]
        }
        controller.delegate = self
        controller.videoIndex = index
        
        let useInlineMode = AppDelegate.sharedInstance.navigationController!.topViewController!.view != nil
        
        let sheet = SheetViewController(
            controller: controller,
            sizes: [.percent(0.30), .intrinsic],
            options: SheetOptions(useFullScreenMode:false, shrinkPresentingViewController:false, useInlineMode: useInlineMode))
        sheet.allowPullingPastMaxHeight = false
        if let view = AppDelegate.sharedInstance.navigationController?.topViewController?.view {
            sheet.animateIn(to: view, in: AppDelegate.sharedInstance.navigationController!.topViewController!)
        } else {
            AppDelegate.sharedInstance.navigationController?.topViewController!.present(sheet, animated: true, completion: nil)
        }
    }
    
    
    func selectedOption(index:Int,videoIndex:Int,title:String){
        
        if title == "Share"{
            
            if livePkId.count > 0 {
                let mergeId = "\(fromId)_\(toId)_\(livePkId)"
                ShareMedia.shareMediafrom(type: .pkGolive, mediaId: mergeId, controller: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
                
            }else{
                ShareMedia.shareMediafrom(type: .golive, mediaId: fromId, controller: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
            }
        }else if title == "Kick Out"{
            
            let param = [
                "authToken": Themes.sharedInstance.getAuthToken(),
                "roomId": fromId,
                "userId": comments[videoIndex].userId
            ] as [String : Any]
            SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_kick_out  , param)
            
        }else if title == "Block User"{
            
            let param = [
                "authToken": Themes.sharedInstance.getAuthToken(),
                "roomId": fromId,
                "userId": comments[videoIndex].userId
            ] as [String : Any]
            SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_block_user  , param)
            
        }else if title == "Report"{
            if isThreeDotoption == true {
                
                self.reportUser(index: 0)
                
            }else{
                self.reportUser(index: videoIndex)
            }
        }
    }
    
    
    func reportUser(index:Int){
        let alertController = UIAlertController(title: "Report", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Submit", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            if firstTextField.text?.trim().count ?? 0 > 0 {
                
                let type =  (Themes.sharedInstance.Getuser_id() == self.fromId) ? 1 : 0
                
                let param = [
                    "authToken": Themes.sharedInstance.getAuthToken(),
                    "roomId": self.fromId,
                    "reason":firstTextField.text ?? "",
                    "type":type
                ] as [String : Any]
                SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_report_live_pk  , param)
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
}


//MARK: UITableview Cell

class CommentCell: UITableViewCell {
    
  //  @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentContainer: UIView!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var imgVwGiftingLevel: UIImageView!
    @IBOutlet weak var profilePicView:ImageWithFrameImgView!
    @IBOutlet weak var cnstrntWidthGiftingLevel:NSLayoutConstraint!
    @IBOutlet weak var imgVwTopBadge1: UIImageView!

    var comment: LiveComment! {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cnstrntWidthGiftingLevel.constant = 0
        profilePicView.initializeView()
    }
    
    
    func updateUI() {

        var name = comment.pickzonId
        if Themes.sharedInstance.Getuser_id() == comment.userId{
            name = "Me"
        }
        
        switch comment.gifterLevel{
        case 1:
            imgVwTopBadge1.image = PZImages.topBadge1
            imgVwTopBadge1.isHidden = false
        case 2:
            imgVwTopBadge1.image = PZImages.topBadge2
            imgVwTopBadge1.isHidden = false
        case 3:
            imgVwTopBadge1.image = PZImages.topBadge3
            imgVwTopBadge1.isHidden = false
        default:
            imgVwTopBadge1.isHidden = true
        }
    
        
       if comment.giftingLevel.count == 0 {
           self.imgVwGiftingLevel.isHidden = true
           self.cnstrntWidthGiftingLevel.constant = 0

       }else{
           self.imgVwGiftingLevel.isHidden = false
           self.cnstrntWidthGiftingLevel.constant = 20
           self.imgVwGiftingLevel.kf.setImage(with: URL(string: comment.giftingLevel), options: nil, progressBlock: nil, completionHandler: { response in })
       }
   
        if comment.userId == Themes.sharedInstance.Getuser_id(){
            
            profilePicView.setImgView(profilePic: comment.profilePic, frameImg: comment.avatar,changeValue: 5)
        }else{
            profilePicView.setImgView(profilePic: comment.profilePic, frameImg: comment.avatar,changeValue:5)
        }
        //(comment.avatar.count > 0 ? 5 : 0)
        var verifiedImage:UIImage? = nil
        switch comment.celebrity{
        case 1:
            verifiedImage = PZImages.greenVerification
        case 4:
            verifiedImage = PZImages.goldVerification
        case 5:
            verifiedImage = PZImages.blueVerification
        default:
            verifiedImage = nil
        }
                
        let attachment:NSTextAttachment = NSTextAttachment()
        
        let nameAttr = NSMutableAttributedString(string: name, attributes:[
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.medium)])
        
        let myString:NSMutableAttributedString = nameAttr
        
        if verifiedImage == nil{
            
        }else{
            attachment.bounds = CGRect(x: 0, y: -3.5, width: 15, height: 15)
            myString.append(NSMutableAttributedString(string: " "))
            attachment.image = verifiedImage
            let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
            myString.append(attachmentString)
        }
        
        myString.append( NSMutableAttributedString(string: " : "))
        
        var messageAttr = NSMutableAttributedString(string: comment.message, attributes:[
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.light)])
        
        if comment.type == 2{
            // 1= Normal message, 2= Gift Message
            messageAttr = NSMutableAttributedString(string: comment.message, attributes:[
                NSAttributedString.Key.foregroundColor: UIColor.yellow,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.medium)])
        }
        
        myString.append(messageAttr)
        
        NameLabel.attributedText = myString
                
//        self.commentContainer.layer.cornerRadius = self.commentContainer.frame.size.height/2.0
//        self.commentContainer.clipsToBounds = true
    
        
    }
}

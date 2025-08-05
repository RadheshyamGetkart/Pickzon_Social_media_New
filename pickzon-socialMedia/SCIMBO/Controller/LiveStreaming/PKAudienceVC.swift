
//
//  AudienceViewController.swift
//
//  Created by Rahul Tiwari on 3/5/20.
//  Copyright © 2020 CASPERON. All rights reserved.

import UIKit
import SocketIO
import IHKeyboardAvoiding
import FittedSheets
import SVGAPlayer
import WebRTCiOSSDK

class PKAudienceVC: UIViewController {
    
    
    @IBOutlet weak var entryEffectBgView: UIView!
    @IBOutlet weak var entryProfilePicVw: ImageWithFrameImgView!
    @IBOutlet weak var entryEffectBgImgView: UIImageView!
    @IBOutlet weak var entryEffectGifImgView: UIImageView!
    @IBOutlet weak var entryLblPickzonId: UILabel!
    @IBOutlet weak var bgVwSVGAEntryEffect: UIView!
    var entryEffectSVGAPlayer:SVGAPlayer? = nil
    @IBOutlet weak var imgVwMicMuteLeft: UIImageView!
    @IBOutlet weak var imgVwCameraMuteLeft: UIImageView!
    @IBOutlet weak var imgVwMicMuteRight: UIImageView!
    @IBOutlet weak var imgVwCameraMuteRight: UIImageView!
    @IBOutlet weak var imgVwMicMuteSingleLive: UIImageView!
    @IBOutlet weak var imgVwCameraMuteSingleLive: UIImageView!
    
    private  var micMutedUserIdArray = [String]()
    private var cameraMutedUserIdArray = [String]()
    private  var giftSvgUrlArray = Array<Dictionary<String,Any>>()
    private var dictCurrentPlayingGift:Dictionary<String,Any>!
    private var isPlayingGift = false
    
    @IBOutlet weak var bgBlurImagevw: UIImageView!
    @IBOutlet weak var imgVwSeperatorGif: UIImageView!
    @IBOutlet weak var bgVwTimer: UIView!

    private var playedStreamIdArray = [String]()
    private var isViewDissapear = false
    
    @IBOutlet weak var bgViewPK: UIView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var cnstrntYAxixPkBg: NSLayoutConstraint!
    
    private var remoteSVGAPlayer:SVGAPlayer? = nil
    private var imgVwResultBanner = UIImageView()
    private var isToLeaveRoom = true
    @IBOutlet weak var bgVwSelectedUser: UIView!
    @IBOutlet weak var btnSelectedName: UIButton!
    @IBOutlet weak var btnSelectedTotalCoin: UIButton!
    @IBOutlet weak var imgVwCelebritySelected: UIImageView!
    @IBOutlet weak var profilePicViewSelected:ImageWithFrameImgView!

    @IBOutlet weak var btnAddSelected: UIButton!
    @IBOutlet weak var lblWinningStatus: UILabel!
    @IBOutlet weak var cnstrntWidthBtnAddSelected: NSLayoutConstraint!
    @IBOutlet weak var cnstrntWidthTopBtnAdd: NSLayoutConstraint!
    @IBOutlet weak var backView: IgnoreTouchView!
    @IBOutlet weak var previewViewLeft: UIView!
    @IBOutlet weak var previewViewRight: UIView!
    //Top View
    @IBOutlet weak var bgViewTop: UIView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnName: UIButton!
    @IBOutlet weak var btnTotalCoin: UIButton!
    @IBOutlet weak var imgVwCelebrity: UIImageView!
    @IBOutlet weak var profilePicView:ImageWithFrameImgView!

    @IBOutlet weak var collectionVwJoinedUser: UICollectionView!
    @IBOutlet weak var btnclose: UIButton!
    @IBOutlet weak var btnTotalCountJoined: UIButton!
    @IBOutlet weak var cnstrntTop: NSLayoutConstraint!
    
    @IBOutlet weak var cnstrntHeightPreviewBg: NSLayoutConstraint!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnLeftCoin: UIButton!
    @IBOutlet weak var btnRightCoin: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var blurPkImgView: UIImageView!
    
    @IBOutlet weak var leftBlurBgView: IgnoreTouchView!
    @IBOutlet weak var leftBlurImgView: IgnoreTouchImageView!
    @IBOutlet weak var rightBlurImgVw: IgnoreTouchImageView!
    @IBOutlet weak var rightBlurBgVw: IgnoreTouchView!

    @IBOutlet weak var imgVwProfileBlur: UIImageView!
    @IBOutlet weak var bgVwBlurImage: UIView!
  
    var from = String()
    private  var overlayController: LiveOverlayViewController!
    private var topGiftersArray = [JoinedUser]()
    private var selectedUserId = ""
    private var pkStartTime = -1
    var leftRoomId = ""
    var rightRoomId = ""
    var livePKId = ""
    private   var timerPk:Timer?
    private  var pkTimeSlot = 0
    private  var coinsHostUserId = 0
    private  var coinsjoinUserId = 0
    private  var pkStartImageView:UIImageView?
    private var switchPlayer = true
    private var remoteClientLeft:AntMediaClient?
    private var remoteClientRight:AntMediaClient?
    
    var is_FROM_NOTIFICATION = false
   
    //MARK: -  Controller Life cycle methods
    override func loadView() {
        super.loadView()
        remoteClientLeft =  AntMediaClient.init();
        remoteClientRight =  AntMediaClient.init();
        self.cnstrntTop.constant =  (UIDevice().hasNotch) ? (UIDevice().safeAreaHeight + 5) : 10
        DispatchQueue.main.async {
            self.cnstrntHeightPreviewBg.constant = self.view.frame.size.height * 0.35
        }
        profilePicViewSelected.initializeView()
        profilePicView.initializeView()
        progressView.progressTintColor = UIColor.blue
        progressView.trackTintColor = UIColor.red
        progressView.progress = 0.5
        progressView.progressViewStyle = .bar
        self.selectedUserId = leftRoomId
        self.bgViewPK.isHidden = (livePKId.count == 0) ? true : false
        if  self.isViewDissapear == false{
            checkLiveStatus(roomId: leftRoomId)
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        print("UIViewController: pkAudienceVC")
        self.bgBlurImagevw.isHidden = true
        self.imgVwMicMuteLeft.isHidden = true
        self.imgVwCameraMuteLeft.isHidden = true
        self.imgVwMicMuteRight.isHidden = true
        self.imgVwCameraMuteRight.isHidden = true
        self.imgVwMicMuteSingleLive.isHidden = true
        self.imgVwCameraMuteSingleLive.isHidden = true
        
        if Themes.sharedInstance.Getuser_id() == leftRoomId{
            self.navigationController?.popViewController(animated: true)
            AlertView.sharedManager.presentAlertWith(title: "", msg:  "You cannot join your live streaming.", buttonTitles: ["Ok"], onController:  AppDelegate.sharedInstance.navigationController!, dismissBlock: {  (title,index) in
            })
        }
        
        self.bgVwBlurImage.isHidden = false
        self.imgVwProfileBlur.addBlurEffect()
        self.lblWinningStatus.isHidden = true
        self.collectionVwJoinedUser.register(UINib(nibName: "ImgCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ImgCollectionCell")
        self.lblTime.text = "00 : 00"
        self.btnLeftCoin.setTitle("0", for: .normal)
        self.btnRightCoin.setTitle("0", for: .normal)
        
        updateOverlay()
        addObservers()
        getUserInfo(userId:leftRoomId)
        //   previewViewLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleLeftUserTap(_:))))
        // previewViewLeft.isUserInteractionEnabled = true
        previewViewRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleRightUserTap(_:))))
        previewViewRight.isUserInteractionEnabled = true
        setBorderColor(iSselectLeft: true)
        self.imgVwSeperatorGif.setGifImage(UIImage(gifName: "animatedLine.gif"), loopCount: -1)
        
        bgVwTimer.backgroundColor = UIColor.darkGray
        bgVwTimer.alpha = 0.75
        bgVwTimer.layer.cornerRadius = 10.0
        bgVwTimer.clipsToBounds = true
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPointMake(0.5,0.5), size: bgVwTimer.frame.size)
        gradient.cornerRadius = 10.0
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.colors = [UIColor.blue.cgColor, UIColor.red.cgColor]
        let shape = CAShapeLayer()
        shape.lineWidth = 5
        shape.path = UIBezierPath(roundedRect: bgVwTimer.bounds, cornerRadius: 9.0).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        bgVwTimer.layer.insertSublayer(gradient, at: 0)
        
        self.profilePicViewSelected?.imgVwProfile?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                                               action:#selector(self.handleProfilePicTapRight(_:))))
        
        self.profilePicView?.imgVwProfile?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                                       action:#selector(self.handleProfilePicTapLeft(_:))))
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "pkOverlay" {
            overlayController = segue.destination as? LiveOverlayViewController
            overlayController.fromId = selectedUserId
            overlayController.isGoLiveUser = false
            let label = UILabel()
            label.setNameTxt(Themes.sharedInstance.Getuser_id(), "single")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if  self.isViewDissapear == true{
            addObservers()
            checkLiveStatus(roomId: selectedUserId)
            self.isViewDissapear = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.isViewDissapear = true
        remoteClientLeft?.stop()
        remoteClientRight?.stop()
        leaveRoom(roomId: selectedUserId)
        self.timerPk?.invalidate()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    deinit{
        print("Deinit")
        NotificationCenter.default.removeObserver(self)
        remoteClientLeft?.stop(streamId: leftRoomId)
        remoteClientRight?.stop(streamId: rightRoomId)
    }
    
    //MARK: Other Helpful Methods
  
    func createSingleView(isTojoinRoom:Bool){
        
        self.bgBlurImagevw.isHidden = true
        self.imgVwSeperatorGif.stopAnimating()
        self.bgViewTop.backgroundColor = .clear
        
        if isTojoinRoom{
            self.joinRoom(roomId: selectedUserId, type: 0)
        }
        getUserInfo(userId:selectedUserId)
        
        self.timerPk?.invalidate()
        self.bgViewPK.isHidden = true
        
        self.remoteClientRight?.remoteView = nil
        self.remoteClientLeft?.stop()
        self.remoteClientLeft?.delegate = nil
        self.remoteClientRight?.stop()
        self.remoteClientRight?.delegate = nil
        
        self.remoteClientLeft?.setRemoteView(remoteContainer: self.previewView, mode: .scaleAspectFill)
        DispatchQueue.main.async {
            self.remoteClientLeft?.remoteView?.setSize(CGSize(width: self.previewView.frame.size.width, height: self.previewView.frame.size.height))
            (self.remoteClientLeft?.remoteView as? UIView)?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            (self.remoteClientLeft?.remoteView as? UIView)?.translatesAutoresizingMaskIntoConstraints = true
            (self.remoteClientLeft?.remoteView as? UIView)?.setNeedsDisplay()
        }
        
        remoteClientLeft?.setWebSocketServerUrl(url: Constant.sharedinstance.rtmpPlayUrl);
        remoteClientLeft?.play(streamId: selectedUserId)
        remoteClientLeft?.setExternalAudio(externalAudioEnabled: true)
        remoteClientLeft?.delegate = self
        
        self.previewView.clipsToBounds = true
        self.previewView.isHidden = false
        self.overlayController.cnstrntHeightCommentTblView.constant = self.view.frame.size.height * 0.35
        self.overlayController.tableView.contentInset.top = self.overlayController.tableView.bounds.height
        self.overlayController.scrollToLastrow()
    }
    
    
    func createpkView(isTojoinRoom:Bool=true){
        self.imgVwSeperatorGif.startAnimating()
        self.bgBlurImagevw.isHidden = false
        
        self.previewView.isHidden = true
        self.bgViewTop.backgroundColor = .clear
        self.remoteClientLeft?.stop()
        self.remoteClientLeft?.delegate = nil
        getUserInfo(userId: rightRoomId)
        getUserInfo(userId:leftRoomId)
        emitTopGifters(isPk: true)
        self.bgViewPK.isHidden = false
        if isTojoinRoom == true{
            self.joinRoom(roomId: selectedUserId, type: 0)
        }
        self.emitLivePkInfo()
            
            self.remoteClientLeft?.setRemoteView(remoteContainer: self.previewViewLeft, mode: .scaleAspectFill)
        DispatchQueue.main.async {
            self.remoteClientLeft?.remoteView?.setSize(CGSize(width: self.previewViewLeft.frame.size.width, height: self.previewViewLeft.frame.size.height))
            (self.remoteClientLeft?.remoteView as? UIView)?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            (self.remoteClientLeft?.remoteView as? UIView)?.translatesAutoresizingMaskIntoConstraints = true
            (self.remoteClientLeft?.remoteView as? UIView)?.setNeedsDisplay()
        }
        self.previewViewLeft.clipsToBounds = true
        
        remoteClientLeft?.setWebSocketServerUrl(url: Constant.sharedinstance.rtmpPlayUrl);
        remoteClientLeft?.play(streamId: leftRoomId)
        remoteClientLeft?.setExternalAudio(externalAudioEnabled: true)
        remoteClientLeft?.delegate = self
        self.remoteClientRight?.setRemoteView(remoteContainer: self.previewViewRight, mode: .scaleAspectFill)
        
        DispatchQueue.main.async {
            self.remoteClientRight?.remoteView?.setSize(CGSize(width: self.previewViewRight.frame.size.width, height: self.previewViewRight.frame.size.height))
            (self.remoteClientRight?.remoteView as? UIView)?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            (self.remoteClientRight?.remoteView as? UIView)?.translatesAutoresizingMaskIntoConstraints = true
            (self.remoteClientRight?.remoteView as? UIView)?.setNeedsDisplay()
        }
        self.previewViewRight.clipsToBounds = true
        remoteClientRight?.setWebSocketServerUrl(url: Constant.sharedinstance.rtmpPlayUrl);
        remoteClientRight?.play(streamId: rightRoomId)
        remoteClientRight?.setExternalAudio(externalAudioEnabled: true)
        remoteClientRight?.delegate = self
               
        AppDelegate.sharedInstance.currentOpponentId = selectedUserId
        overlayController.cnstrntHeightCommentTblView.constant = self.view.frame.size.height  - (bgViewPK.frame.origin.y + bgViewPK.frame.size.height + self.overlayController.inputContainer.frame.size.height )
        overlayController.tableView.contentInset.top = overlayController.tableView.bounds.height
        self.overlayController.scrollToLastrow()
    }
    
   
    func updateOverlay(){
        //overlayController.comments.removeAll()
        overlayController.btnPk.isHidden = true
        overlayController.isGoLiveUser = false
        overlayController.btnPkRequests.isHidden = true
        overlayController.fromId = selectedUserId
        overlayController.toId = rightRoomId
        overlayController.livePkId = livePKId
        overlayController.emitGetComments()
        overlayController.btnLikeVideo.setNeedsUpdateConstraints()
    }
    
    
    func setBorderColor(iSselectLeft:Bool){
        
        /*   if iSselectLeft == true{
         self.playerLeft?.view.layer.borderColor = UIColor.systemBlue.cgColor
         self.playerLeft?.view.layer.borderWidth = 1.5
         self.playerRight?.view.layer.borderColor = UIColor.clear.cgColor
         self.playerRight?.view.layer.borderWidth = 1.5
         }else{
         self.playerLeft?.view.layer.borderColor = UIColor.clear.cgColor
         self.playerLeft?.view.layer.borderWidth = 1.5
         self.playerRight?.view.layer.borderColor = UIColor.systemBlue.cgColor
         self.playerRight?.view.layer.borderWidth = 1.5
         }
         */
    }
    
    
    @objc func timerHandlerPk(_ timer: Timer) {
        
        if pkStartTime > 0 {
            self.pkStartTime = self.pkStartTime - 1
            let min = pkStartTime / 60
            let sec = pkStartTime % 60
            self.lblTime.text = String(format: "%02d : %02d", min,sec)
            
            if self.pkStartTime <=  ((pkTimeSlot) - 4){
                self.pkStartImageView?.removeFromSuperview()
                self.blurPkImgView.isHidden = false
            }
        }else if pkStartTime == 0{
            
            self.timerPk?.invalidate()
        }
    }
    
    
    @objc func handleLeftUserTap(_ tapgsture:UITapGestureRecognizer){
        
        /*  setBorderColor(iSselectLeft: true)
         //leave previous
         leaveRoom(roomId: selectedUserId)
         selectedUserId = leftRoomId
         
         //Join selected
         overlayController.fromId = leftRoomId
         joinRoom(roomId: leftRoomId)
         overlayController.refreshChatListBasedOnPKUserSelected(userId: leftRoomId)
         emitTopGifters(isPk: true)
         AppDelegate.sharedInstance.currentOpponentId = selectedUserId
         */
    }
    
    
    @objc func handleRightUserTap(_ tapgsture:UITapGestureRecognizer){
        
        self.isPlayingGift = false
        self.giftSvgUrlArray.removeAll()
        self.dictCurrentPlayingGift = nil
        
        imgVwResultBanner.isHidden = true
        
        setBorderColor(iSselectLeft: false)
        //leave previous
        leaveRoom(roomId: selectedUserId)
        selectedUserId = rightRoomId
        //Join selected
        overlayController.fromId = rightRoomId
        joinRoom(roomId: rightRoomId, type: 0)
        overlayController.refreshChatListBasedOnPKUserSelected(userId: rightRoomId)
        emitTopGifters(isPk: true)
        
        
        let temp = leftRoomId
        leftRoomId = rightRoomId
        rightRoomId = temp
        
        if self.switchPlayer == true {
            self.switchPlayer = false
                AntMediaClient.embedView(self.remoteClientLeft?.remoteView as! UIView, into: self.previewViewRight)
                AntMediaClient.embedView(self.remoteClientRight?.remoteView as! UIView, into: self.previewViewLeft)
            
        }else {
            self.switchPlayer = true
                AntMediaClient.embedView(self.remoteClientLeft?.remoteView as! UIView, into: self.previewViewLeft)
                AntMediaClient.embedView(self.remoteClientRight?.remoteView as! UIView, into: self.previewViewRight)
        }
        
       
        let leftVal = self.btnLeftCoin.currentTitle
        self.btnLeftCoin.setTitle(self.btnRightCoin.currentTitle, for: .normal)
        self.btnRightCoin.setTitle(leftVal, for: .normal)
        
        let first =  Float(self.btnLeftCoin.currentTitle ?? "0") ?? 0
        let second =  Float(self.btnRightCoin.currentTitle ?? "0") ?? 0
        self.calculateProgressValue(first: first, second: second)
        
        getUserInfo(userId:leftRoomId)
        getUserInfo(userId: rightRoomId)
        AppDelegate.sharedInstance.currentOpponentId = selectedUserId
    }
    
    
    //MARK: Add Observers
    func addObservers(){
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillTerminate(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.app_terminated ), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_action_on_live(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_action_on_live ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_start_live_pk(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_start_live_pk ), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_get_live_status(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_live_status ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_top_gifters(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_top_gifters ), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_pk_result(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_pk_result ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_kick_out(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_kick_out ), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_block_user(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_block_user ), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_send_gift_pk(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_send_gift_pk ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_exit_go_live_host_user(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_exit_go_live_host_user ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_get_live_pk_info(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_live_pk_info ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getUserInfo(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_user_info ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.joinUserRoom(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_join_user_room), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.socketConnected(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.socketCnnected), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.joinedLiveUserListCount(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_live_join_user_count), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
       
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(noInternetConnection), name: NSNotification.Name(Constant.sharedinstance.noInternet), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(internetConnection), name: NSNotification.Name(Constant.sharedinstance.reconnectInternet), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.recieveNewcomment(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_send_comment_message ), object: nil)
       
        
    }
    
    
    //MARK: Observers methods
  
    
    @objc func applicationWillTerminate(notification: Notification) {
        leaveRoom(roomId: selectedUserId)
    }
    
    
    
    @objc func socketConnected(notification: Notification) {
        if is_FROM_NOTIFICATION == true{
            checkLiveStatus(roomId: selectedUserId)
            is_FROM_NOTIFICATION = false
        }
        joinRoom(roomId: selectedUserId, type: 1)
    }
    
    @objc func socketError(notification: Notification){
        
    }
    
    @objc func sio_action_on_live(notification: Notification) {

        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {

            if (responseDict["status"] as? Int ?? 0) == 1 {
                if let  payload = responseDict["payload"] as? Dictionary<String, Any>{
                    
                    let userId = (payload["userId"] as? String ?? "")
                    if let  action = payload["action"] as? Dictionary<String, Any>{
                        
                        let type = (action["type"] as? Int ?? 0)
                        let value = (action["value"] as? Int ?? 0)
                        
                        if type == 1{
                            
                            //Mic mute/Unmute
                            if value == 0{
                                self.micMutedUserIdArray.removeAll { $0 == userId}
                            }else if value == 1{
                                self.micMutedUserIdArray.append(userId)
                            }
                            
                        }else if type == 2{
                            //Video mute/Unmute
                            if value == 0{
                                self.cameraMutedUserIdArray.removeAll { $0 == userId}
                            }else if value == 1{
                                self.cameraMutedUserIdArray.append(userId)
                            }
                        }
                        self.checkAndUpdateMicMuteOption()
                       
                    }
                }
            }
        }
    }
    
    
    
    func checkAndUpdateMicMuteOption(){
        
        self.imgVwMicMuteLeft.isHidden = true
        self.imgVwCameraMuteLeft.isHidden = true
        self.imgVwMicMuteRight.isHidden = true
        self.imgVwCameraMuteRight.isHidden = true
        self.imgVwMicMuteSingleLive.isHidden = true
        self.imgVwCameraMuteSingleLive.isHidden = true
        
        if micMutedUserIdArray.contains(leftRoomId){
            self.imgVwMicMuteLeft.isHidden = false
            self.imgVwMicMuteSingleLive.isHidden = false
        }
        
        if cameraMutedUserIdArray.contains(leftRoomId){
            self.imgVwCameraMuteLeft.isHidden = false
            self.imgVwCameraMuteSingleLive.isHidden = false
        }
        
        if micMutedUserIdArray.contains(rightRoomId){
            self.imgVwMicMuteRight.isHidden = false
        }
      
        if cameraMutedUserIdArray.contains(rightRoomId){
            self.imgVwCameraMuteRight.isHidden = false
        }
    }
    
    
    @objc func sio_start_live_pk(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            
            if let  payload = responseDict["payload"] as? Dictionary<String, Any>{
                self.imgVwResultBanner.isHidden = true
                let pKRoomId = payload["PKRoomId"] as? String ?? ""
                self.livePKId = payload["livePKId"] as? String ?? ""
                let restartPK = payload["restartPK"] as? Int ?? 0
                let pKBoxingglove = payload["pKBoxingglove"] as? String ?? ""
                
                self.pkStartImageView?.removeFromSuperview()
                self.pkStartImageView = UIImageViewX(frame: CGRectMake(0, (bgViewTop.frame.origin.y + bgViewTop.frame.size.height), self.view.frame.size.width, self.previewViewLeft.frame.size.height) )
                self.view.addSubview(self.pkStartImageView!)
                
                self.pkStartImageView?.contentMode = .scaleAspectFit
                self.pkStartImageView?.setGifFromURL(URL(string: pKBoxingglove), manager: .defaultManager, loopCount: -1, showLoader: true)
                
                var arr = pKRoomId.components(separatedBy: ",")
                if arr.count > 0 {
                    if let index = arr.firstIndex(of: leftRoomId){
                        arr.remove(at: index)
                    }
                    self.rightRoomId = arr.last ?? ""
                }
                
                if restartPK == 1{
                    self.bgBlurImagevw.isHidden = false
                    self.blurPkImgView.isHidden = true
                    self.lblWinningStatus.isHidden = true
                    self.imgVwResultBanner.isHidden = true
                    self.pkStartTime = -1
                    self.pkTimeSlot = 0
                    self.lblTime.text = String(format:"%02d : %02d", 0,0)
                    if self.bgViewPK.isHidden{
                        self.createpkView(isTojoinRoom: false)
                    }else{
                        self.emitLivePkInfo()
                    }
                }else{
                    self.createpkView(isTojoinRoom: false)
                    self.blurPkImgView.isHidden = true
                    self.lblWinningStatus.isHidden = true
                    self.imgVwResultBanner.isHidden = true
                    self.pkStartTime = -1
                    self.pkTimeSlot = 0
                    self.lblTime.text = String(format:"%02d : %02d", 0,0)
                }
            }
        }
    }
    
    
    @objc func sio_get_live_status(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            if (responseDict["status"] as? Int ?? 0) == 1{
                
                if let payload = responseDict["payload"] as? Dictionary<String, Any>{
                    
                    let isLive = payload["isLive"] as? Int ?? 0
                    let isLivePK = payload["isLivePK"] as? Int ?? 0
                    let livePKId = payload["livePKId"] as? String ?? ""
                    let pkRoomId = payload["PKRoomId"] as? String ?? ""
                    
                    
                    if isLivePK == 0{
                        self.livePKId = ""
                        if isLive == 1{
                            //Create single join view
                            self.createSingleView(isTojoinRoom: true)
                        }else{
                            self.navigationController?.popViewController(animated: false)
                            AppDelegate.sharedInstance.navigationController?.view.makeToast(message:(responseDict["message"] as? String ?? ""), duration: 1, position: HRToastActivityPositionDefault)
                        }
                       
                    }else{
                        
                        self.livePKId = livePKId
                        var arr = pkRoomId.components(separatedBy: ",")
                        if arr.count > 0 {
                            if let index = arr.firstIndex(of: leftRoomId){
                                arr.remove(at: index)
                            }
                            self.rightRoomId = arr.last ?? ""
                        }
                        //Create pk view
                        self.createpkView(isTojoinRoom: true)
                    }
                }
            }else{
                self.navigationController?.popViewController(animated: false)
                AppDelegate.sharedInstance.navigationController?.view.makeToast(message:(responseDict["message"] as? String ?? ""), duration: 1, position: HRToastActivityPositionDefault)
            }
        }
    }
    
    
    @objc func sio_top_gifters(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            if let  payloadArr = responseDict["payload"] as? Array<Dictionary<String, Any>>{
                self.topGiftersArray.removeAll()
                
                for dict in payloadArr{
                    self.topGiftersArray.append(JoinedUser(respDict: dict))
                }
            }
            self.collectionVwJoinedUser.reloadData()
        }
    }
    
    
    
    @objc func sio_pk_result(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            let status = responseDict["status"] as? Int ?? 0
            
            if let  payload = responseDict["payload"] as? Dictionary<String, Any>{
                
                if status == 1{
                    
                    //let hostUserId = payload["hostUserId"] as? String ?? ""
                  //  let joinUserId = payload["joinUserId"] as? String ?? ""
                   // let pkTime = payload["pkTime"] as? Int ?? 0
                   // let hostUserTotalCoins = payload["hostUserTotalCoins"] as? Int ?? 0
                   // let joinUserTotalCoins = payload["joinUserTotalCoins"] as? Int ?? 0
                    //let coins = payload["coins"] as? Int ?? 0
                    let resultBanner = payload["resultBanner"] as? String ?? ""
                    let winnerId = payload["winnerId"] as? String ?? ""
                    let isDraw = payload["isDraw"] as? Int ?? 0
                    
                    self.overlayController.view.endEditing(true)
                    
                    if isDraw == 1{
                        
                        self.lblWinningStatus.isHidden = false
                        
                    }else if leftRoomId == winnerId{
                        
                        self.imgVwResultBanner.setGifFromURL(URL(string: resultBanner), manager: .defaultManager, loopCount: -1, showLoader: true)
                        self.imgVwResultBanner.isHidden = false
                        self.imgVwResultBanner.frame = CGRectMake(0, 0, self.previewViewLeft.frame.width, self.previewViewLeft.frame.height)
                        self.previewViewLeft.addSubview(self.imgVwResultBanner)
                        
                    }else if rightRoomId == winnerId{

                        self.imgVwResultBanner.setGifFromURL(URL(string: resultBanner), manager: .defaultManager, loopCount: -1, showLoader: true)
                        self.imgVwResultBanner.isHidden = false
                        self.imgVwResultBanner.frame = CGRectMake(0, 0, self.previewViewRight.frame.width, self.previewViewRight.frame.height)
                        self.previewViewRight.addSubview(self.imgVwResultBanner)
                        self.bgVwSelectedUser.bringSubviewToFront(self.imgVwResultBanner)
                    }
                }
            }
        }
    }
    
    
    @objc func sio_kick_out(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            let status = responseDict["status"] as? Int ?? 0

            if let  payload = responseDict["payload"] as? Dictionary<String, Any>{
                
                if status == 1{
                    
                    if Themes.sharedInstance.Getuser_id() == (payload["userId"] as? String ?? ""){
                        
                        self.leaveRoom(roomId: selectedUserId)
                        self.navigationController?.popViewController(animated: false)
                        AppDelegate.sharedInstance.navigationController?.topViewController?.view.makeToast(message:(responseDict["message"] as? String ?? ""), duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        }
    }
    
    
    @objc func sio_block_user(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            let status = responseDict["status"] as? Int ?? 0
            
            if let  payload = responseDict["payload"] as? Dictionary<String, Any>{
                
                AppDelegate.sharedInstance.navigationController?.topViewController?.view.makeToast(message:(responseDict["message"] as? String ?? ""), duration: 3, position: HRToastActivityPositionDefault)
                
                if status == 1{
                    
                    if Themes.sharedInstance.Getuser_id() == (payload["blockUserId"] as? String ?? ""){
                        self.leaveRoom(roomId: selectedUserId)
                        self.navigationController?.popViewController(animated: false)
                    }
                }
            }
        }
    }
    
    
    @objc func sio_send_gift_pk(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            let status = responseDict["status"] as? Int ?? 0
            
            if let  payload = responseDict["payload"] as? Dictionary<String, Any>{
                var amount = payload["amount"] as? Int ?? 0
               // let label = payload["label"] as? String ?? ""
               // let id = payload["id"] as? Int ?? 0
                let icon = payload["icon"] as? String ?? ""
                let roomId = payload["roomId"] as? String ?? ""
                let totalUserCoin = payload["totalUserCoin"] as? Int ?? 0
                let giftedCoins = payload["giftedCoins"] as? Int ?? 0
                
                if status == 1 {
                    
                    if leftRoomId == roomId{
                        self.btnTotalCoin.setTitle("\(giftedCoins)", for: .normal)
                        self.btnLeftCoin.setTitle("\(totalUserCoin)", for: .normal)
                    }else{
                        self.btnRightCoin.setTitle("\(totalUserCoin)", for: .normal)
                        self.btnSelectedTotalCoin.setTitle("\(giftedCoins)", for: .normal)
                    }
                    
                    let first =  Float(self.btnLeftCoin.currentTitle ?? "0") ?? 0
                    let second =  Float(self.btnRightCoin.currentTitle ?? "0") ?? 0
                    
                    self.calculateProgressValue(first: first, second: second)
                    
                    if icon.length > 0 {
                        if let amt = payload["amount"] as? String {
                            amount = Int(amt) ?? 0
                        }
                        
                        if amount > 500 && isPlayingGift == true {
                            self.giftSvgUrlArray.append(payload)
                        } else if isPlayingGift == false {
                            self.dictCurrentPlayingGift = payload
                            self.addGiftView(remoteSVGAUrl: icon)
                        }else {
                            if self.dictCurrentPlayingGift != nil {
                                var oldAmt = self.dictCurrentPlayingGift["amount"] as? Int ?? 0
                                if let amt = self.dictCurrentPlayingGift["amount"] as? String {
                                    oldAmt = Int(amt) ?? 0
                                }
                                if amount >  oldAmt{
                                    self.dictCurrentPlayingGift = payload
                                    self.addGiftView(remoteSVGAUrl: icon)
                                }
                            }else {
                                self.dictCurrentPlayingGift = payload
                                self.addGiftView(remoteSVGAUrl: icon)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    @objc func sio_exit_go_live_host_user(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            if (responseDict["message"] as? String ?? "").count > 0{
                
                AppDelegate.sharedInstance.navigationController?.view.makeToast(message:(responseDict["message"] as? String ?? ""), duration: 1, position: HRToastActivityPositionDefault)
            }
            
            if let  payload = responseDict["payload"] as? Dictionary<String, Any>{
                var type = payload["type"] as? Int ?? 0
                if let typ = payload["type"] as? String{
                    type = Int(typ) ?? 0
                }
                self.pkStartImageView?.removeFromSuperview()
                self.lblWinningStatus.isHidden = true
                if type == 1{
                    //Single live end
              
                    self.navigationController?.popViewController(animated: false)
                    
                }else if type == 2 {
                    //Pk end
                    self.giftSvgUrlArray.removeAll()
                    self.dictCurrentPlayingGift = nil
                    self.bgBlurImagevw.isHidden = true
                    self.micMutedUserIdArray.removeAll()
                    self.cameraMutedUserIdArray.removeAll()
                    self.checkAndUpdateMicMuteOption()
                    self.livePKId = ""
                    self.createSingleView(isTojoinRoom: false)
                }else{
                    //End from both
                    self.navigationController?.popViewController(animated: false)
                }
            }
        }
    }
    
    
    
    @objc func sio_get_live_pk_info(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            if (responseDict["status"] as? Int ?? 0) == 1 {
                
                if let  payload = responseDict["payload"] as? Dictionary<String, Any>{
                    
                    if let pkTime = payload["pkTime"] as? Dictionary<String, Any>{
                        
                        let minute = pkTime["minute"] as? Int ?? 0
                        let second = pkTime["second"] as? Int ?? 0
                        let slot = payload["pkTimeSlot"] as? Int ?? 0
                        
                        DispatchQueue.main.async {
                            self.pkStartTime = (minute * 60) + second
                            self.lblTime.text = String(format:"%02d : %02d", minute,second)
                            self.pkTimeSlot = slot * 60
                        }
                        self.timerPk?.invalidate()
                        self.timerPk = nil
                        self.timerPk = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerHandlerPk(_:)), userInfo: nil, repeats: true)
                    }
                    
                    if let  userCoins = payload["userCoins"] as? Dictionary<String, Any>{
                        
                        if let  hostUserId = userCoins["hostUserId"] as? Dictionary<String, Any>{
                            
                            let roomId = hostUserId["roomId"] as? String ?? ""
                            if leftRoomId == roomId{
                                coinsHostUserId = hostUserId["coins"] as? Int ?? 0
                                self.btnLeftCoin.setTitle("\(coinsHostUserId)", for: .normal)
                            }else if rightRoomId == roomId{
                                coinsjoinUserId = hostUserId["coins"] as? Int ?? 0
                                self.btnRightCoin.setTitle("\(coinsjoinUserId)", for: .normal)
                            }
                        }
                        
                        if let  joinUserId = userCoins["joinUserId"] as? Dictionary<String, Any>{
                            let roomId = joinUserId["roomId"] as? String ?? ""
                            if rightRoomId == roomId{
                                coinsjoinUserId = joinUserId["coins"] as? Int ?? 0
                                self.btnRightCoin.setTitle("\(coinsjoinUserId)", for: .normal)
                            }else if leftRoomId == roomId{
                                coinsHostUserId = joinUserId["coins"] as? Int ?? 0
                                self.btnLeftCoin.setTitle("\(coinsHostUserId)", for: .normal)
                            }
                        }
                        
                        let first =  Float(self.btnLeftCoin.currentTitle ?? "0") ?? 0
                        let second =  Float(self.btnRightCoin.currentTitle ?? "0") ?? 0
                        self.calculateProgressValue(first: first, second: second)
                    }
                }
            }
        }
    }
    
    
    
    func calculateProgressValue(first:Float,second:Float){
        if first ==  second{
            self.progressView.progress = 0.5
        }else  {
            self.progressView.setProgress(first / (first + second), animated: true)
        }
        if self.progressView.progress == 1.0 {
            self.progressView.setProgress(0.99, animated: true)
        }
        
        if self.progressView.progress == 0.0 {
            
            self.progressView.setProgress(0.01, animated: true)
        }
    }
    
    @objc func joinedLiveUserListCount(notification: Notification){
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            if let  payload = responseDict["payload"] as? Dictionary<String, Any>{
                self.btnTotalCountJoined.setTitle((payload["liveJoinUserCount"] as? String ?? ""), for: .normal)
            }
        }
    }
    
    
    @objc func getUserInfo(notification: Notification) {
        
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            
            if let payload = response["payload"] as? Dictionary<String,Any>{
                
                let name = payload["name"] as? String ?? ""
                let pickzonId = payload["pickzonId"] as? String ?? ""
                let userId = payload["userId"] as? String ?? ""
                let celebrity = payload["celebrity"] as? Int ?? 0
                let giftedCoins = payload["giftedCoins"] as? Int ?? 0
               // let cheerCoins = payload["cheerCoins"] as? Int ?? 0
                let profilePic = payload["profilePic"] as? String ?? ""
                let isFollow = payload["isFollow"] as? Int ?? 0
                let avatar = payload["avatar"] as? String ?? ""

                if selectedUserId == userId {
                    overlayController.pickzonId = pickzonId
                }
                
                if userId == self.leftRoomId{
                  
                    self.btnAdd.isHidden = (isFollow == 1 || isFollow == 2) ? true : false
                    self.cnstrntWidthTopBtnAdd.constant = (isFollow == 1 || isFollow == 2) ? 0 : 25
                    
                    profilePicView.setImgView(profilePic: profilePic, frameImg: avatar,changeValue: 5)
                   /*
                    self.btnProfilePic.kf.setImage(with:  URL(string: profilePic) , for: .normal, placeholder:PZImages.avatar , options:nil)
                    self.btnProfilePic.contentMode = .scaleAspectFit
                    self.btnProfilePic.imageView?.contentMode = .scaleAspectFill*/
                    
                    self.btnName.setTitle(name.count>0 ? name : pickzonId, for: .normal)
                    self.btnTotalCoin.setTitle("\(giftedCoins)", for: .normal)
                    
                    self.leftBlurImgView.kf.setImage(with:  URL(string: profilePic), placeholder:PZImages.avatar , options:nil)
                    self.leftBlurImgView.image = self.leftBlurImgView.image?.blurred(radius: 25.0)
                    
                    
                    self.imgVwProfileBlur.kf.setImage(with:  URL(string: profilePic), placeholder:PZImages.avatar , options:nil)
                    self.imgVwProfileBlur.image = self.imgVwProfileBlur.image?.blurred(radius: 20.0)
                    
                    if Settings.sharedInstance.goLiveStream == 1 {
                        
                        if playedStreamIdArray.contains(userId){
                            self.leftBlurBgView.isHidden = true
                        }else{
                            self.leftBlurBgView.isHidden = false
                        }
                    }else{
                        
                    }
                    
                    switch celebrity{
                    case 1:
                        self.imgVwCelebrity.isHidden = false
                        self.imgVwCelebrity.image = PZImages.greenVerification
                        
                    case 4:
                        self.imgVwCelebrity.isHidden = false
                        self.imgVwCelebrity.image = PZImages.goldVerification
                    case 5:
                        self.imgVwCelebrity.isHidden = false
                        self.imgVwCelebrity.image = PZImages.blueVerification
                        
                    default:
                        self.imgVwCelebrity.isHidden = true
                    }
                    
                }else{
                    
                    self.btnAddSelected.isHidden = (isFollow == 1 || isFollow == 2) ? true : false
                    self.cnstrntWidthBtnAddSelected.constant = (isFollow == 1 || isFollow == 2) ? 0 : 20
                    
                    profilePicViewSelected.setImgView(profilePic: profilePic, frameImg: avatar,changeValue: 5)

                    /*self.btnSelectedProfilePic.kf.setImage(with:  URL(string: profilePic) , for: .normal, placeholder:PZImages.avatar , options:nil)
                    self.btnSelectedProfilePic.contentMode = .scaleAspectFit
                    self.btnSelectedProfilePic.imageView?.contentMode = .scaleAspectFill*/
                    self.btnSelectedName.setTitle(name.count>0 ? name : pickzonId, for: .normal)
                    self.btnSelectedTotalCoin.setTitle("\(giftedCoins)", for: .normal)
                    
                    self.rightBlurImgVw.kf.setImage(with:  URL(string: profilePic), placeholder:PZImages.avatar , options:nil)
                    self.rightBlurImgVw.image = self.rightBlurImgVw.image?.blurred(radius: 30.0)
                    
                    if Settings.sharedInstance.goLiveStream == 1 {
                        if playedStreamIdArray.contains(userId){
                            self.rightBlurBgVw.isHidden = true
                        }else{
                            self.rightBlurBgVw.isHidden = false
                        }
                        
                    }else{
                        
                    }
                    switch celebrity{
                    case 1:
                        self.imgVwCelebritySelected.isHidden = false
                        self.imgVwCelebritySelected.image = PZImages.greenVerification
                        
                    case 4:
                        self.imgVwCelebritySelected.isHidden = false
                        self.imgVwCelebritySelected.image = PZImages.goldVerification
                    case 5:
                        self.imgVwCelebritySelected.isHidden = false
                        self.imgVwCelebritySelected.image = PZImages.blueVerification
                        
                    default:
                        self.imgVwCelebritySelected.isHidden = true
                    }
                }
                
                
                if let  action = payload["action"] as? Dictionary<String, Any>{
                    
                    let type = (action["type"] as? Int ?? 0)
                    let value = (action["value"] as? Int ?? 0)
                    
                    if type == 1{
                        
                        //Mic mute/Unmute
                        if value == 0{
                            self.micMutedUserIdArray.removeAll { $0 == userId}
                        }else if value == 1{
                            if !self.micMutedUserIdArray.contains(userId){
                                self.micMutedUserIdArray.append(userId)
                            }
                        }
                        
                    }
                    
                    if type == 2{
                        //Video mute/Unmute
                        if value == 0{
                            self.cameraMutedUserIdArray.removeAll { $0 == userId}
                        }else if value == 1{
                            if !self.cameraMutedUserIdArray.contains(userId){
                                self.cameraMutedUserIdArray.append(userId)
                            }
                        }
                    }
                    self.checkAndUpdateMicMuteOption()
                   
                }
            }
            
        }
    }
    
    
    @objc func joinUserRoom(notification: Notification){
        
//        if  let response = notification.userInfo as? Dictionary<String, Any> {
//            
//        }
    }
    
    
    @objc func keyboardWillAppear() {
        
        if livePKId.count > 0{
            overlayController.cnstrntHeightCommentTblView.constant = 200

        }else{
            self.overlayController.cnstrntHeightCommentTblView.constant = self.view.frame.size.height * 0.35
            self.overlayController.tableView.contentInset.top = self.overlayController.tableView.bounds.height
            self.overlayController.scrollToLastrow()
        }
    }
    
    @objc func keyboardWillDisappear() {
        
        if livePKId.count > 0{
            overlayController.cnstrntHeightCommentTblView.constant = self.view.frame.size.height  - (bgViewPK.frame.origin.y + bgViewPK.frame.size.height + self.overlayController.inputContainer.frame.size.height )
            overlayController.tableView.contentInset.top = overlayController.tableView.bounds.height
            self.overlayController.scrollToLastrow()
        }else{
            
            self.overlayController.cnstrntHeightCommentTblView.constant = self.view.frame.size.height * 0.35
            self.overlayController.tableView.contentInset.top = self.overlayController.tableView.bounds.height
            self.overlayController.scrollToLastrow()
        }
    }
    
    
    @objc func recieveNewcomment(notification: Notification) {
        
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            
            if let payload = response["payload"] as? Dictionary<String,Any>{
                
                if let entryEffect = payload["entryEffect"] as? Dictionary<String,Any>{
                    
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
               
            }
        }
    }
    
    func entryEffectAnimate(effectUrl:String,url:String,profilePic:String,avatar:String,pickzonId:String,roomId:String){
   
        
        self.entryEffectBgView.center.x =  self.view.bounds.size.width

        if checkMediaTypes(strUrl: effectUrl) == 5 {
            //SVGA
            self.animateSVGA(remoteSVGAUrl: effectUrl, pickzonId: pickzonId)
        } else {

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
        }
    }
    
    
    func animateSVGA(remoteSVGAUrl:String,pickzonId:String){
     
        self.remoteSVGAPlayer?.stopAnimation()
      
        if entryEffectSVGAPlayer == nil {
            entryEffectSVGAPlayer = SVGAPlayer(frame: CGRect(x:0, y: -30, width: self.bgVwSVGAEntryEffect.frame.size.width, height: 50))
            entryEffectSVGAPlayer?.backgroundColor = .clear
            entryEffectSVGAPlayer?.loops = 1
            entryEffectSVGAPlayer?.clearsAfterStop = true
            self.bgVwSVGAEntryEffect.addSubview(self.entryEffectSVGAPlayer!)
        }
        self.entryEffectSVGAPlayer?.contentMode = .top
        self.entryEffectSVGAPlayer?.isUserInteractionEnabled = true
        
        if let url = URL(string: remoteSVGAUrl) {
            let remoteSVGAParser = SVGAParser()
            remoteSVGAParser.enabledMemoryCache = true
            remoteSVGAParser.parse(with: url, completionBlock: { (svgaItem) in
                self.entryEffectSVGAPlayer?.videoItem = svgaItem
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
                self.entryEffectSVGAPlayer?.setAttributedText(str, forKey: "name")
                self.entryEffectSVGAPlayer?.startAnimation()
            }, failureBlock: { (error) in
                print("--------------------- \(String(describing: error))")
                
            })
        }
    }
          

@objc func internetConnection() {
    print("+++++++ Re Internet Connection")
   // self.joinRoom(type: 1)
}
    
    @objc func noInternetConnection() {
        self.isPlayingGift = false
        dictCurrentPlayingGift = nil
        self.giftSvgUrlArray.removeAll()
    }
    
    //MARK: Emitting methods
    
    func emitTopGifters(isPk:Bool){
        
        if isPk == true {
            let param = ["authToken": Themes.sharedInstance.getAuthToken(),"roomId":selectedUserId,"type":"0"] as [String : Any]
            SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_top_gifters, param)
        }else{
            let param = ["authToken": Themes.sharedInstance.getAuthToken(),"roomId":Themes.sharedInstance.Getuser_id()] as [String : Any]
            SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_top_gifters, param)
        }
    }
    
    func emitLivePkInfo(){
        
        let param = ["authToken": Themes.sharedInstance.getAuthToken(),"livePKId":livePKId] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_get_live_pk_info, param)
    }
    
    func getUserInfo(userId:String){
        
        let param = [
            "authToken": Themes.sharedInstance.getAuthToken(),
            "roomId": userId
        ] as [String : Any]
        
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_get_user_info  , param)
    }
    
    func leaveRoom(roomId:String){
        
        let param = [
            "authToken": Themes.sharedInstance.getAuthToken(),
            "roomId": roomId
        ]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_leave_user_room, param)
    }
    
    
    
    func joinRoom(roomId:String ,type:Int) {
        
        let param = [
            "authToken": Themes.sharedInstance.getAuthToken(),
            "roomId": roomId,
            "type":((type == 1) ? 1 : 0)
        ] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_join_user_room, param)
    }
    
   
    func checkLiveStatus(roomId:String) {
        
        let param = [
            "authToken": Themes.sharedInstance.getAuthToken(),
            "roomId": roomId,
            "livePKId":livePKId
        ]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_get_live_status, param)
    }
    
   
    //MARK: Api methods
    func followUserApi(userId:String){
        
        Themes.sharedInstance.activityView(View: self.view)
        
        let param:NSDictionary = ["followedUserId":userId,"status":"1"]
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.follow as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    self.getUserInfo(userId: userId)
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    
                }else{
                    self.view.makeToast(message: message, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    //MARK: UIButton Action Methods
    
    @objc  func handleProfilePicTapRight(_ sender: UITapGestureRecognizer? = nil){
        let nextVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        nextVC.otherMsIsdn = self.rightRoomId
        self.navigationController?.pushView(nextVC, animated: true)
    }
    
    @objc  func handleProfilePicTapLeft(_ sender: UITapGestureRecognizer? = nil){
        let nextVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        nextVC.otherMsIsdn = self.leftRoomId
        self.navigationController?.pushView(nextVC, animated: true)
    }

    @IBAction func rightProfileButtonAction(_ sender: UIButton) {
        let nextVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        nextVC.otherMsIsdn = self.rightRoomId
        self.navigationController?.pushView(nextVC, animated: true)
    }
    
    
    @IBAction func profilePicBtnAction(_ sender: UIButton) {
        let nextVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        nextVC.otherMsIsdn = self.leftRoomId
        self.navigationController?.pushView(nextVC, animated: true)
    }
    
    
    @IBAction func nameBtnTopBtnAction(_ sender: UIButton) {
        
        let nextVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        nextVC.otherMsIsdn = self.leftRoomId
        self.navigationController?.pushView(nextVC, animated: true)
    }
    
    
    @IBAction func nameBtnRightBtnAction(_ sender: UIButton) {
        
        let nextVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        nextVC.otherMsIsdn = self.rightRoomId
        self.navigationController?.pushView(nextVC, animated: true)
        
    }
    
    
    @IBAction func addBtnAction(_ sender: UIButton) {
        
        self.followUserApi(userId: leftRoomId)
    }
    
    @IBAction func addBtnRightUserAction(_ sender: UIButton) {
        
        self.followUserApi(userId: rightRoomId)
    }
    
    @IBAction func liveUsersList(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        let controller = StoryBoard.letGo.instantiateViewController(withIdentifier: "GoLiveJoinedUsersVC") as! GoLiveJoinedUsersVC
        controller.fromId = selectedUserId
        let useInlineMode = view != nil
        let sheet = SheetViewController(
            controller: controller,
            sizes: [.percent(0.35), .intrinsic],
            options: SheetOptions(useFullScreenMode:false, shrinkPresentingViewController:false, useInlineMode: useInlineMode))
        if let view = view {
            sheet.animateIn(to: view, in: self)
        } else {
            self.present(sheet, animated: true, completion: nil)
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        leaveRoom(roomId: selectedUserId)
        self.navigationController?.popViewController(animated: false)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func closeBlurImageCloseButtonPressed(_ sender: AnyObject) {
        self.bgVwBlurImage.isHidden = true
    }
}

//MARK:- CollectionView Delegates Protocols
extension PKAudienceVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,GoliveUserDelegate {
    
    //MARK: Delegate User Info
    func selectedOption(index:Int,title:String){
        
        if title == "profile"{
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn = self.topGiftersArray[index].userId
            self.navigationController?.pushView(profileVC, animated: true)
            
        }else if title == "option"{
            
            /* if comments[index].userId == "652797eed3f9cd9fd638cde0"{
             return
             }
             if comments[index].userId != Themes.sharedInstance.Getuser_id() && isGoLiveUser == true {
             openListOfOptions(index:index)
             }*/
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return topGiftersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImgCollectionCell", for: indexPath) as! ImgCollectionCell
        cell.imgvw.kf.setImage(with: URL(string: self.topGiftersArray[indexPath.row].profilePic), placeholder: PZImages.avatar , options: nil, progressBlock: nil, completionHandler: { response in  })
        cell.imgvw.contentMode = .scaleAspectFill
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:32, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if Themes.sharedInstance.Getuser_id() == self.topGiftersArray[indexPath.item].userId{
            
        }else{   if #available(iOS 13.0, *) {
            
            let controller = StoryBoard.letGo.instantiateViewController(identifier: "UserInfoVC")
            as! UserInfoVC
            
            // controller.btnOption.isHidden = true
            controller.istoHideProfile = 0
            controller.selIndex = indexPath.item
            controller.userObj.name = self.topGiftersArray[indexPath.item].name
            controller.userObj.profilePic = self.topGiftersArray[indexPath.item].profilePic
            controller.userObj.pickzonId = self.topGiftersArray[indexPath.item].pickzonId
            controller.userObj.celebrity = self.topGiftersArray[indexPath.item].celebrity
            controller.userObj.userId = self.topGiftersArray[indexPath.item].userId
            controller.goLivefromId = leftRoomId
            controller.goLiveToId = rightRoomId
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
    }
}


extension PKAudienceVC:AntMediaClientDelegate {
    
    func publishFinished(streamId: String) {
        
    }
    
    func clientDidDisconnect(_ message: String) {
    
        print(message)

    }

    
    func clientHasError(_ message: String) {
        
        print(message)
        /* let param = ["roomId":from] as [String : Any]
         SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_exit_force_live_user, param)
         
         if message.count > 0{
         
         AppDelegate.sharedInstance.navigationController?.view.makeToast(message:message, duration: 2, position: HRToastActivityPositionDefault)
         self.navigationController?.popViewController(animated: false)
         }*/
    }
    
    func publishStarted(streamId: String) {
        print("publishStarted")
    }
    
    
    func dataReceivedFromDataChannel(streamId: String, data: Data, binary: Bool) {
        
    }
    
    func playStarted(streamId: String){
        print("playStarted")
        self.playedStreamIdArray.append(streamId)
        self.bgVwBlurImage.isHidden = true

        if streamId == leftRoomId{
            self.leftBlurBgView.isHidden = true
        }else{
            self.rightBlurBgVw.isHidden = true
        }
        
        if self.rightBlurBgVw.isHidden == true{
            
        }
    }
    
    func playFinished(streamId: String){
        
    }
    
    func newStreamsJoined(streams: [String]){
        print("newStreamsJoined")
        
    }
}


extension PKAudienceVC: SVGAPlayerDelegate {
    
    func addGiftView(remoteSVGAUrl:String){
        
        self.isPlayingGift = true
        self.remoteSVGAPlayer?.stopAnimation()
      /*  self.remoteSVGAPlayer?.clear()
        self.remoteSVGAPlayer?.frame = .zero
        self.remoteSVGAPlayer?.removeFromSuperview()
        
        remoteSVGAPlayer = SVGAPlayer(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        remoteSVGAPlayer?.backgroundColor = .clear
        backView?.addSubview(remoteSVGAPlayer!)
        
        remoteSVGAPlayer?.delegate = self
        remoteSVGAPlayer?.loops = 1       // repeat count，0 means infinite
        remoteSVGAPlayer?.clearsAfterStop = true
        */
      
        if remoteSVGAPlayer == nil {
            remoteSVGAPlayer = SVGAPlayer(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: backView!.frame.size.height))
            remoteSVGAPlayer?.backgroundColor = .clear
            backView?.addSubview(remoteSVGAPlayer!)
            remoteSVGAPlayer?.delegate = self
            remoteSVGAPlayer?.loops = 1   // repeat count，0 means infinite
            remoteSVGAPlayer?.clearsAfterStop = true
        }
       
        backView.backgroundColor = .clear

        if let url = URL(string: remoteSVGAUrl) {
            let remoteSVGAParser = SVGAParser()
            remoteSVGAParser.enabledMemoryCache = true
            
            remoteSVGAParser.parse(with: url, completionBlock: { (svgaItem) in
                self.remoteSVGAPlayer?.videoItem = svgaItem
                self.remoteSVGAPlayer?.startAnimation()
            }, failureBlock: { (error) in
                print("--------------------- \(String(describing: error))")
                self.isPlayingGift = false
                self.dictCurrentPlayingGift = nil
            })
        }
        
    }
    
    /// SVGA animation progress
    func svgaPlayerDidAnimated(toPercentage percentage: CGFloat) {
        //print("precent ------- \(percentage)")
    }
    
    /// SVGA frame index with images resource
    func svgaPlayerDidAnimated(toFrame frame: Int) {
        //print("frame ------- \(frame)")
    }
    
    /// doing after SVGA animation end or stop
    func svgaPlayerDidFinishedAnimation(_ player: SVGAPlayer!) {
        //print("play end ---------------")
        self.remoteSVGAPlayer?.stopAnimation()
        self.remoteSVGAPlayer?.clear()
        self.isPlayingGift = false
        dictCurrentPlayingGift = nil
        

        
        if giftSvgUrlArray.count > 0{
            if let dict = giftSvgUrlArray.first as? Dictionary<String,Any> {
                let icon = dict["icon"] as? String ?? ""
                dictCurrentPlayingGift = dict
                self.addGiftView(remoteSVGAUrl: icon)
                giftSvgUrlArray.removeFirst()
            }
        }
    }
}





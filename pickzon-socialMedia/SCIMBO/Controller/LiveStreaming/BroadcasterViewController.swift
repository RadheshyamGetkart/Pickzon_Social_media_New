//
//  BroadcasterViewController.swift
//
//  Created by Rahul Tiwari on 3/5/20.
//  Copyright © 2020 CASPERON. All rights reserved.

import UIKit
import SocketIO
import IHKeyboardAvoiding
import FittedSheets
import SVGAPlayer
import WebRTCiOSSDK
import WebRTC
import ReplayKit
import DeepAR
import AVFoundation

class BroadcasterViewController: UIViewController {
    
    @IBOutlet weak var entryEffectBgView: UIView!
    @IBOutlet weak var entryProfilePicVw: ImageWithFrameImgView!
    @IBOutlet weak var entryEffectBgImgView: UIImageView!
    @IBOutlet weak var entryEffectGifImgView: UIImageView!
    @IBOutlet weak var entryLblPickzonId: UILabel!
    @IBOutlet weak var bgVwSVGAEntryEffect: UIView!
    var entryEffectSVGAPlayer:SVGAPlayer? = nil

    
    @IBOutlet weak var imgVwMicMuteSingleLive: UIImageView!
    @IBOutlet weak var imgVwCameraMuteSingleLive: UIImageView!
    
    @IBOutlet weak var imgVwMicMuteLeft: UIImageView!
    @IBOutlet weak var imgVwCameraMuteLeft: UIImageView!
    
    @IBOutlet weak var imgVwMicMuteRight: UIImageView!
    @IBOutlet weak var imgVwCameraMuteRight: UIImageView!
    @IBOutlet weak var bgBlurImagevw: UIImageView!
    @IBOutlet weak var imgVwSeperatorGif: UIImageView!
    @IBOutlet weak var bgVwTimer: UIView!

    @IBOutlet weak var cnstrntYAxixPkBg: NSLayoutConstraint!
    @IBOutlet weak var waitingForOppenentVW:UIView!
    @IBOutlet weak var blurPkImgView: UIImageView!
    
    var pkStartImageView:UIImageView?
    var imgVwResultBanner = UIImageView()
    var isGoLiveRandomPrevious = false
    var remoteSVGAPlayer:SVGAPlayer? = nil
    var playedStreamIdArray = [String]()

    //PK
    @IBOutlet weak var bgViewPK: UIView!
    @IBOutlet weak var previewViewLeft: UIView!
    @IBOutlet weak var previewViewRight: UIView!
    @IBOutlet weak var cnstrntHeightPreviewBg: NSLayoutConstraint!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnLeftCoin: UIButton!
    @IBOutlet weak var btnRightCoin: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var bgVwSelectedUser: UIView!
    @IBOutlet weak var btnSelectedName: UIButton!
    @IBOutlet weak var btnSelectedTotalCoin: UIButton!
    @IBOutlet weak var imgVwCelebritySelected: UIImageView!
   // @IBOutlet weak var btnSelectedProfilePic: UIButton!
    @IBOutlet weak var profilePicViewSelected:ImageWithFrameImgView!

    @IBOutlet weak var btnAddSelected: UIButton!
    @IBOutlet weak var cnstrntWidthBtnAddSelected: NSLayoutConstraint!
    @IBOutlet weak var cnstrntWidthTopBtnAdd: NSLayoutConstraint!
    
    @IBOutlet weak var btnRestartPk: UIButton!
    @IBOutlet weak var lblWinningStatus: UILabel!
    @IBOutlet weak var lblPkDismissCounter: UILabelX!
    
    var giftSvgUrlArray = Array<Dictionary<String,Any>>()
    var dictCurrentPlayingGift:Dictionary<String,Any>!
    
    private var isPlayingGift = false
    var joinerId = ""
    private var pkTimeSlot = 0
    var newCamera: AVCaptureDevice! = nil
    var topGiftersArray = [JoinedUser]()
    var isfilterVwShown = false
    var indexSelected:Int = 0
    
    @IBOutlet weak var btnFlashLightCam:UIButton!
    @IBOutlet weak var btnRotateCam:UIButton!
    @IBOutlet weak var btnMute:UIButton!
    @IBOutlet weak var btnVideoOnOff:UIButton!
    
    @IBOutlet weak var bgVwFilterBtn:UIView!
    @IBOutlet weak var btnFilterCam:UIButton!
    @IBOutlet weak var cnstrntWidthFiltersBtnBgVw: NSLayoutConstraint!

    @IBOutlet weak var viewFilters:UIView!
    @IBOutlet weak var cvFilters:UICollectionView!
    
    //Top View
    @IBOutlet weak var bgViewTop: UIView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnName: UIButton!
    @IBOutlet weak var btnTotalCoin: UIButton!
    @IBOutlet weak var imgVwCelebrity: UIImageView!
   // @IBOutlet weak var btnProfilePic: UIButton!
    
    @IBOutlet weak var profilePicView:ImageWithFrameImgView!
    @IBOutlet weak var collectionVwJoinedUser: UICollectionView!
    @IBOutlet weak var btnclose: UIButton!
    @IBOutlet weak var btnTotalCountJoined: UIButton!
    @IBOutlet weak var cnstrntTop: NSLayoutConstraint!
    @IBOutlet weak var bgVwBottom:UIViewX!
    @IBOutlet weak var tblVwFriends:UITableView!
    @IBOutlet weak var cnstrntbgVwBottom: NSLayoutConstraint!
    @IBOutlet weak var bgVwTime:UIViewX!
    @IBOutlet weak var tblVwTime:UITableView!
    @IBOutlet weak var tblVwRequests:UITableView!
    
    @IBOutlet weak var rightBlurImgVw: IgnoreTouchImageView!
    @IBOutlet weak var rightBlurBgVw: IgnoreTouchView!
    
    var friendsArray = [JoinedUser]()
    var timeArray = [String]()
    var valueTimeIdArray = [Int]()
    var pkRequestListArray = [JoinedUser]()
    var isTimeSelcted = false
    var selectedUserId = ""
    var isPkNavigation = false
    
    @IBOutlet weak var previewView: UIView!
    var pkStartTime = -1
    var livePKId = ""
    
    @IBOutlet weak var backView: IgnoreTouchView!
    var overlayController: LiveOverlayViewController!
    var  devicePosition:AVCaptureDevice.Position = .front
    var torchEnabled = false
    var backColor = UIColor.clear
    var beautyLevel:CGFloat = 1.0
    var brightLevel:CGFloat = 0.5
    
    var timerPk:Timer?
    var coinsHostUserId = 0
    var coinsjoinUserId = 0
    var randomPkCounter = 0
    var timerRandomPk:Timer?
    var pKBoxingglove = ""
    
    var client:AntMediaClient?
    var vw = UIView()
    var pkCloseTimer:Timer?
    var pkCloseCounter = -1
    
    //Implementing Deep AR Effects
    var cameraController: CameraController!
    var effectIndex: Int = 0
    var deepAR: DeepAR!
    var arView: UIView!
    var deepARView:UIView?
    var filterIndex = 0
    private var pkDismissTime = 0
    private var isExitedGoLive = false
    private var isMuted = false
   
    //MARK: Controller Lifecycle methods
    override func loadView() {
        super.loadView()
        if UIDevice().hasNotch{
            cnstrntTop.constant = UIDevice().safeAreaHeight + 5
            cnstrntbgVwBottom.constant = UIDevice().safeAreaHeight + 60
        }else{
            cnstrntbgVwBottom.constant = 70
            cnstrntTop.constant =  10
        }
        
        //  DispatchQueue.main.async {
        //self.cnstrntHeightPreviewBg.constant = self.view.frame.size.height * 0.35
        // }
        profilePicView.initializeView()
        profilePicViewSelected.initializeView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UIApplication.shared.delegate as! AppDelegate).IsInternetconnected == true {
            cameraAllowsAccessToApplicationCheck()
        }else{
            let msg = "No Network Connection"
            self.view.makeToast(message: msg, duration: 3, position: HRToastActivityPositionDefault)
        }
        self.lblPkDismissCounter.layer.cornerRadius =  self.lblPkDismissCounter.frame.size.height/2.0
        self.lblPkDismissCounter.clipsToBounds = true
        self.lblPkDismissCounter.isHidden = true
        self.lblWinningStatus.layer.cornerRadius = 5.0
        self.btnRestartPk.layer.cornerRadius = 5.0
        btnRestartPk.clipsToBounds = true
        self.lblWinningStatus.isHidden = true
        self.bgViewPK.isHidden = true
        self.btnRestartPk.isHidden = true
        self.btnFilterCam.isHidden = false
        tblVwFriends.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.bgVwFilterBtn.isHidden = true
        self.setupDeepARAndCamera()
        self.btnVideoOnOff.isHidden = true
        imgVwMicMuteRight.isHidden = true
        imgVwCameraMuteRight.isHidden = true
        imgVwMicMuteLeft.isHidden = true
        imgVwCameraMuteLeft.isHidden = true
        imgVwMicMuteSingleLive.isHidden = true
        imgVwCameraMuteSingleLive.isHidden = true
        
        client =  AntMediaClient.init()
        client?.delegate = self
        client?.enableTrack(trackId: Themes.sharedInstance.Getuser_id(), enabled: false)
        
        client?.setExternalVideoCapture(externalVideoCapture: true)
        client?.setUseExternalCameraSource(useExternalCameraSource: true)
        client?.setWebSocketServerUrl(url:Constant.sharedinstance.rtmpPushUrl)
        client?.publish(streamId: Themes.sharedInstance.Getuser_id())
        
        
        self.imgVwResultBanner.isHidden = true
        bgVwBottom.isHidden = true
        tblVwFriends.isHidden = true
        bgVwTime.isHidden = true
        
        //Hide and show options in case user has not given permission for Camera and mickrphone
        self.overlayController.btnSendGift.isHidden = true
        self.overlayController.btnLikeVideo.isHidden = true
        self.overlayController.btnPk.isHidden = false
        self.overlayController.btnPkRequests.isHidden = false
        self.overlayController.btnHostOption.isHidden = false
        
        //Camera aceess code was there
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if self.devicePosition == .back {
                self.cameraController.position = .back
            }
        }
        tblVwRequests.isHidden = true
        registerCell()
        addObservers()
        getUserInfo(userId: Themes.sharedInstance.Getuser_id())
        getAllLivedFriendsList()
        filterViewSetup()
        waitingForOppenentVW.isHidden = true
        waitingForOppenentVW.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.waitingForOppenentVWTap(_:))))
        waitingForOppenentVW.isUserInteractionEnabled = true
        emitTopGifters(isPk: false)
        
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
        
        if pKBoxingglove.count > 0{
            self.blurPkImgView.isHidden = true
            self.pkStartImageView = UIImageViewX(frame: CGRectMake(0, (bgViewTop.frame.origin.y + bgViewTop.frame.size.height), self.view.frame.size.width, self.view.frame.size.height * 0.35) )
            self.view.addSubview(self.pkStartImageView!)
            self.pkStartImageView?.contentMode = .scaleAspectFit
            self.pkStartImageView?.setGifFromURL(URL(string: pKBoxingglove), manager: .defaultManager, loopCount: -1, showLoader: true)
        }
        
        getTimeSlotApi()
        
        self.imgVwSeperatorGif.setGifImage(UIImage(gifName: "animatedLine.gif"), loopCount: -1)
        
        
        if isPkNavigation{
            self.startPKLive(isToCreatePlayer: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("UIViewController : BroadcasterViewController")
        setLive(goLive: 3)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        self.livePKId = ""
        
        timerPk?.invalidate()
        
        self.client?.remoteView = nil
        client?.delegate = nil
        client?.disconnect()
        client?.stop()
       
        pkCloseTimer?.invalidate()
        pkCloseTimer = nil
        timerPk = nil
  

        DispatchQueue.main.async {
            do{
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
            }catch {
                
            }
            
            do{
                try AVAudioSession.sharedInstance().setCategory(.playback)
            }catch {
                
            }
            
            do {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            }catch{
                
            }
        }
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        if isExitedGoLive == false{
            self.setLive(goLive: -1)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        if deepAR != nil {
            cameraController?.deepAR.pause()
            deepAR?.pause()
            deepAR?.shutdown()
            cameraController?.deepAR.shutdown()
            deepAR = nil
            cameraController = nil
        }
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Constant.sharedinstance.app_Background), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Constant.sharedinstance.app_Foreground), object: nil)
        
        print("Deinit Broadcastviewcontroller")
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        self.tblVwFriends.isHidden = true
        self.isfilterVwShown = false
        self.bgVwBottom.isHidden = true
        self.bgVwTime.isHidden = true
        self.bgVwFilterBtn.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "overlay" {
            self.overlayController = segue.destination as? LiveOverlayViewController
            self.overlayController.isGoLiveUser = true
        }
    }
    
    
    func setupDeepARAndCamera() {
        
        self.deepAR = DeepAR()
        self.deepAR.delegate = self
        self.deepAR.setLicenseKey(Settings.sharedInstance.deepARLicenseKey)
        self.deepAR.videoRecordingWarmupEnabled = true
        cameraController = CameraController(deepAR: self.deepAR)
        
            if let deepARView = self.deepAR.createARView(withFrame: self.view.frame) {
                self.deepARView = deepARView
                self.previewView.addSubview( self.deepARView!)
            }
        
        
        cameraController.startCamera()
        self.addFilter()
    }
    
    
    
    func addFilter() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if self.filterIndex == 0 {
                self.deepAR.switchEffect(withSlot: "effect", path: nil)
            }else {
                let obj = Constant.sharedinstance.arrFilterEffect[self.filterIndex]
                let url = URL(string: obj.url)
                Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
                DownloadHandler.loadFileAsync(url: url!) { (path, error) in
                    DispatchQueue.main.async {
                        Themes.sharedInstance.RemoveactivityView(View: self.view)
                    }
                    if error == nil {
                        print("File downloaded to : \(path!)")
                        self.deepAR.switchEffect(withSlot: "effect", path: path)
                    }
                }
            }
        }
    }
    
    
    @objc func waitingForOppenentVWTap(_ tapgsture:UITapGestureRecognizer){
        waitingForOppenentVW.isHidden = true
        self.leaveRandomPk()
        randomPkCounter = 0
        timerRandomPk?.invalidate()
        timerRandomPk = nil
        self.overlayController.btnPk.isUserInteractionEnabled = true
        self.overlayController.btnPkRequests.isUserInteractionEnabled = true
    }
    
    
    func registerCell(){
        tblVwFriends.register(UINib(nibName: "FriendsTblCell", bundle: nil), forCellReuseIdentifier: "FriendsTblCell")
        tblVwTime.register(UINib(nibName: "TimeSelectionTblCell", bundle: nil), forCellReuseIdentifier: "TimeSelectionTblCell")
        cvFilters.register(UINib(nibName: "FilterCVCell", bundle: nil), forCellWithReuseIdentifier: "FilterCVCell")
        collectionVwJoinedUser.register(UINib(nibName: "ImgCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ImgCollectionCell")
        tblVwRequests.register(UINib(nibName: "PkRequestTblCell", bundle: nil), forCellReuseIdentifier: "PkRequestTblCell")
    }
    
    
    func addObservers(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.recieveNewcomment(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_send_comment_message ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillTerminate(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.app_terminated ), object: nil)
       
       
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_action_on_live(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_action_on_live ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_restart_pk(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_restart_pk ), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_play_random_pk(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_play_random_pk ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_leave_random_pk(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_leave_random_pk ), object: nil)
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_pk_request_count(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_pk_request_count ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_exit_go_live_host_user(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_exit_go_live_host_user ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_get_live_pk_info(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_live_pk_info ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_start_live_pk(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_start_live_pk), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_accept_live_pk_request(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_accept_live_pk_request), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_reject_live_pk_request(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_reject_live_pk_request ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getAllUserPkRequestList(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_all_user_pk_request_list ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendLivePkRequest(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_send_live_pk_request ), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getUserInfo(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_user_info ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.socketConnected(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.socketCnnected), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.allLivedFriendsList(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_all_live_friend_list ), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.timeSlotList(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_live_pk_time_slot), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.joinedLiveUserListCount(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_live_join_user_count), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(_ : )), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_ : )), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appForeground), name: NSNotification.Name(Constant.sharedinstance.app_Foreground), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appBackground), name: NSNotification.Name(Constant.sharedinstance.app_Background), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(noInternetConnection), name: NSNotification.Name(Constant.sharedinstance.noInternet), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(internetConnection), name: NSNotification.Name(Constant.sharedinstance.reconnectInternet), object: nil)

    }
    @objc func internetConnection() {
        print("+++++++ Re Internet Connection")
        self.manageMuteUnMute()
        
    }
    
    @objc func noInternetConnection() {
        print("+++++++ No Internet Connection")
        self.isPlayingGift = false
        dictCurrentPlayingGift = nil
        self.giftSvgUrlArray.removeAll()
    }
    
    func manageMuteUnMute(){
        if self.isMuted == true {
            client?.setAudioTrack(enableTrack: false)
        }else {
            client?.setAudioTrack(enableTrack: true)
        }
    }
    
    //MARK: Other Helpful methods
    
    func filterViewSetup(){
        
        viewFilters.isHidden = true
    }
    
    
    func getTimeSlot(){
        
        let param = [:] as [String : Any]
        
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_live_pk_time_slot  , param)
    }
    
    func sendLivePkRequest(userId:String,time:Int){
        let param = [
            "authToken": Themes.sharedInstance.getAuthToken(),
            "userId":userId,
            "pkTime":"\(time)"
        ] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_send_live_pk_request  , param)
    }
    
    func getAllLivedFriendsList(){
        
        let param = [
            "authToken": Themes.sharedInstance.getAuthToken()
        ] as [String : Any]
        
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_get_all_live_friend_list  , param)
    }
    
    
    func getUserInfo(userId:String){
        
        let param = [
            "authToken": Themes.sharedInstance.getAuthToken(),
            "roomId": userId // Themes.sharedInstance.Getuser_id()
        ] as [String : Any]
        
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_get_user_info  , param)
    }
    
    func joinRoom(type:Int) {
        
        let param = [
            "authToken": Themes.sharedInstance.getAuthToken(),
            "roomId": Themes.sharedInstance.Getuser_id(),
            "type": ((type == 1) ? 1 : 0) //type 1 meeans rejoining otherwise 0
        ] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_join_user_room, param)
    }
    
    func emitJoinedUserList(){
        
        let param = [
            "authToken": Themes.sharedInstance.getAuthToken(),
            "roomId": Themes.sharedInstance.Getuser_id(),
            "pageNumber":"1"
        ] as [String : Any]
        
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_get_join_user_list, param)
    }
    
    
    func emitPkResultDeclare(){
        
        let param = [
            "authToken": Themes.sharedInstance.getAuthToken(),
            "livePKId": livePKId
        ] as [String : Any]
        
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_pk_result, param)
    }
    
    func emitAllUserPkRequestList(){
        
        let param = [
            "authToken": Themes.sharedInstance.getAuthToken()
        ] as [String : Any]
        
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_get_all_user_pk_request_list, param)
    }
        
    func setLive(goLive:Int){
        
        if goLive == 0  {
            self.isExitedGoLive = true
            
            var exitType = 0
            if livePKId.count > 0{
                exitType = 2
                
            }else{
                exitType = 1
            }
            let param = ["authToken": Themes.sharedInstance.getAuthToken(),"roomId":Themes.sharedInstance.Getuser_id(),"type":"\(exitType)"] as [String : Any]
            SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_exit_go_live_host_user, param)
            
        }else if goLive == -1{
            
            let param = ["authToken": Themes.sharedInstance.getAuthToken(),"roomId":Themes.sharedInstance.Getuser_id(),"type":"0"] as [String : Any]
            SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_exit_go_live_host_user, param)
            
        }else{
            
        }
    }
    
    
    
    func emitLivePkInfo(){
        
        let param = ["authToken": Themes.sharedInstance.getAuthToken(),"livePKId":livePKId] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_get_live_pk_info, param)
        
    }
    
    func emitTopGifters(isPk:Bool){
        
        if isPk == true {
            let param = ["authToken": Themes.sharedInstance.getAuthToken(),"roomId":Themes.sharedInstance.Getuser_id(),"type":"0"] as [String : Any]
            SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_top_gifters, param)
        }else{
            let param = ["authToken": Themes.sharedInstance.getAuthToken(),"roomId":Themes.sharedInstance.Getuser_id()] as [String : Any]
            SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_top_gifters, param)
        }
    }
    
    
    func playRandomPk(pkTime:Int){
        
        let param = ["authToken": Themes.sharedInstance.getAuthToken(),"pkTime":"\(pkTime)","joinRoom":"1"] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_play_random_pk, param)
        
    }
    
    func leaveRandomPk(){
        
        let param = ["authToken": Themes.sharedInstance.getAuthToken(),"joinRoom":"1"] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_leave_random_pk, param)
    }
    
    func muteUnmuteEmit(type:Int,value:Int){
                   /** type: (Int)
                       * 1 - Mute Audio
                       * 2 - Mute Video
                       * 3 - Mute Audio & Video
                    type: 1,
                    value: 0  // 0= unmute, 1= mute
                   */
        let actionDict = ["type":type,"value":value] as [String : Any]
        let param = ["authToken": Themes.sharedInstance.getAuthToken(),"action":actionDict] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_action_on_live, param)
    }
    
    
    
    func emitRestartLivePk(){
        var userId = Themes.sharedInstance.Getuser_id()
        
        if self.joinerId == Themes.sharedInstance.Getuser_id(){
            
        }else{
            userId = self.joinerId
        }
        let param = ["authToken": Themes.sharedInstance.getAuthToken(),"livePKId":livePKId,"userId":userId] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_restart_pk, param)
    }
    
    
    func getTimeSlotApi(){
        
        //Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeGetCall(url: Constant.sharedinstance.get_pk_time_slot, param: [:]) {(responseObject, error) ->  () in
            
          //  Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1 {
                    
                    if let  payloadArr = result["payload"] as? Array<Dictionary<String, Any>>{
                        self.timeArray.removeAll()
                        self.valueTimeIdArray.removeAll()
                        
                        for dict in payloadArr{
                            self.timeArray.append(dict["label"] as? String ?? "")
                            self.valueTimeIdArray.append(dict["value"] as? Int ?? 0)
                        }
                    }
                    self.tblVwTime.reloadData()
                    
                }
            }
        }
    }
    
    //MARK: Observers methods
    @objc func applicationWillTerminate(notification: Notification) {
        self.setLive(goLive: -1)
    }

    @objc func appForeground() {
        
        self.manageMuteUnMute()
    
    }
    
    
    @objc func appBackground() {
            
            client?.setAudioTrack(enableTrack: false)
        
    }
    
    @objc func socketConnected(notification: Notification) {
        //When socket connected gets called
        self.joinRoom(type: 1)
        self.getUserInfo(userId: Themes.sharedInstance.Getuser_id())
        self.emitTopGifters(isPk: false)
    }
    
    @objc func socketError(notification: Notification){
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            self.view.makeToast(message:(responseDict["message"] as? String ?? ""), duration: 1, position: HRToastActivityPositionDefault)
        }
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
                            if Themes.sharedInstance.Getuser_id() == userId{
                                self.imgVwMicMuteLeft.isHidden = (value == 0) ? true : false
                                self.imgVwMicMuteSingleLive.isHidden = (value == 0) ? true : false
                            }else{
                                self.imgVwMicMuteRight.isHidden = (value == 0) ? true : false
                            }
                            
                        }else if type == 2{
                            //Video mute/Unmute
                            if Themes.sharedInstance.Getuser_id() == userId{
                                self.imgVwCameraMuteLeft.isHidden = (value == 0) ? true : false
                                self.imgVwCameraMuteSingleLive.isHidden = (value == 0) ? true : false
                            }else{
                                self.imgVwMicMuteRight.isHidden = (value == 0) ? true : false
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    @objc func sio_restart_pk(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            self.btnRestartPk.setTitle("Waiting", for: .normal)
        }
    }
    
    
    @objc func sio_leave_random_pk(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            self.waitingForOppenentVW.isHidden = true
            self.timerRandomPk = nil
            self.overlayController.btnPk.isUserInteractionEnabled = true
            self.overlayController.btnPkRequests.isUserInteractionEnabled = true
        }
    }
    
    
    @objc func sio_play_random_pk(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            
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
                
                //                AppDelegate.sharedInstance.navigationController?.topViewController?.view.makeToast(message:(responseDict["message"] as? String ?? ""), duration: 3, position: HRToastActivityPositionDefault)
                
                if status == 1{
                    pkCloseCounter = -1
                    pkCloseTimer?.invalidate()
                    pkCloseTimer = nil
                    pkCloseTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(pkCloseTimerHandler(_:)), userInfo: nil, repeats: true)
                    
                   // let hostUserId = payload["hostUserId"] as? String ?? ""
                   // let joinUserId = payload["joinUserId"] as? String ?? ""
                   // let pkTime = payload["pkTime"] as? Int ?? 0
                    //let hostUserTotalCoins = payload["hostUserTotalCoins"] as? Int ?? 0
                    //let joinUserTotalCoins = payload["joinUserTotalCoins"] as? Int ?? 0
                    
                    let resultBanner = payload["resultBanner"] as? String ?? ""
                    let winnerId = payload["winnerId"] as? String ?? ""
                   // let coins = payload["coins"] as? Int ?? 0
                    let isDraw = payload["isDraw"] as? Int ?? 0
                    
                    self.lblPkDismissCounter.isHidden = false
                    self.lblPkDismissCounter.text = "\(pkDismissTime)"
                    
                    
                    if client?.cameraPosition == .front {
                        // self.previewViewLeft.transform = CGAffineTransform(scaleX: 0, y: 0)
                        // self.previewViewLeft.transform = CGAffineTransform(scaleX: -1, y: 1)
                    }
                    self.overlayController.view.endEditing(true)
                    if isDraw == 1{
                        
                        self.lblWinningStatus.isHidden = false
                        
                    }else if Themes.sharedInstance.Getuser_id() == winnerId{
                        
                        self.imgVwResultBanner.setGifFromURL(URL(string: resultBanner), manager: .defaultManager, loopCount: -1, showLoader: true)
                        self.imgVwResultBanner.isHidden = false
                        self.imgVwResultBanner.frame = CGRectMake(0, 0, self.previewViewLeft.frame.width, self.previewViewLeft.frame.height)
                        self.previewViewLeft.addSubview(self.imgVwResultBanner)
                        if client?.cameraPosition == .front {
                            //  self.imgVwResultBanner.transform = CGAffineTransform(scaleX: -1, y: 1)
                        }
                        
                    }else if self.joinerId == winnerId{
                        
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
                
                AppDelegate.sharedInstance.navigationController?.topViewController?.view.makeToast(message:(responseDict["message"] as? String ?? ""), duration: 3, position: HRToastActivityPositionDefault)
                
                if status == 1{
                    
                    
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
                    
                    
                }
            }
        }
    }
    
    @objc func sio_send_gift_pk(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            let status = responseDict["status"] as? Int ?? 0
            
            if let  payload = responseDict["payload"] as? Dictionary<String, Any>{
                var amount = payload["amount"] as? Int ?? 0
                let label = payload["label"] as? String ?? ""
               // let id = payload["id"] as? Int ?? 0
                let icon = payload["icon"] as? String ?? ""
                let roomId = payload["roomId"] as? String ?? ""
                let totalUserCoin = payload["totalUserCoin"] as? Int ?? 0
                let giftedCoins = payload["giftedCoins"] as? Int ?? 0
                
                if status == 1 {
                    
                    if livePKId.count > 0{
                        if Themes.sharedInstance.Getuser_id() == roomId{
                            self.btnLeftCoin.setTitle("\(totalUserCoin)", for: .normal)
                            self.btnTotalCoin.setTitle("\(giftedCoins)", for: .normal)
                            
                        }else
                        {
                            self.btnRightCoin.setTitle("\(totalUserCoin)", for: .normal)
                            self.btnSelectedTotalCoin.setTitle("\(giftedCoins)", for: .normal)
                            
                        }
                        
                        let first =  Float(self.btnLeftCoin.currentTitle ?? "0") ?? 0
                        let second =  Float(self.btnRightCoin.currentTitle ?? "0") ?? 0
                        
                        self.calculateProgressValue(first: first, second: second)
                        
                        
                    }else{
                        if Themes.sharedInstance.Getuser_id() == roomId{
                            self.btnTotalCoin.setTitle("\(giftedCoins)", for: .normal)
                        }else
                        {
                            self.btnSelectedTotalCoin.setTitle("\(giftedCoins)", for: .normal)
                            
                        }
                    }
                                        
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
//                    if icon.count > 0 {
//                        self.addGiftView(remoteSVGAUrl: icon)
//                    }
                }
            }
            
            //            AppDelegate.sharedInstance.navigationController?.topViewController?.view.makeToast(message:(responseDict["message"] as? String ?? ""), duration: 3, position: HRToastActivityPositionDefault)
        }
    }
    
    @objc func sio_pk_request_count(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            if let  payload = responseDict["payload"] as? Dictionary<String, Any>{
                
                if let  requestCount = payload["requestCount"] as? Int{
                    if requestCount == 0{
                        DispatchQueue.main.async {
                            self.overlayController.btnPkRequests.badgeString = ""
                        }
                        
                    }else{
                        DispatchQueue.main.async {
                            self.overlayController.btnPkRequests.badgeString = "\(requestCount)"
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
                self.imgVwResultBanner.isHidden = true
                self.pkStartImageView?.removeFromSuperview()
                self.pkStartImageView?.isHidden = true
                
                self.overlayController.btnPk.isUserInteractionEnabled = true
                self.overlayController.btnPkRequests.isUserInteractionEnabled = true
                self.playedStreamIdArray.removeAll()
                self.rightBlurBgVw.isHidden = true
                self.previewView.isHidden = false
                self.overlayController.btnPk.isHidden = false

                if type == 1{
                    self.isExitedGoLive = true
                    self.navigationController?.popToRootViewController(animated: true)
                    
                }else if type == 2{
                    //pK ended
                    self.giftSvgUrlArray.removeAll()
                    self.dictCurrentPlayingGift = nil
                    
                    self.imgVwMicMuteRight.isHidden = true
                    self.imgVwCameraMuteRight.isHidden = true
                    
                    self.imgVwSeperatorGif.stopAnimating()
                    
                    self.isExitedGoLive = false
                    pkCloseCounter = -1
                    pkCloseTimer?.invalidate()
                    self.lblPkDismissCounter.isHidden = true
                    
                    self.client?.stop(streamId: joinerId)
                    self.client?.leave(streamId: joinerId)
                    livePKId = ""
                    joinerId = ""
                    self.client?.remoteView = nil
                    self.client?.delegate = nil

                    self.bgViewPK.isHidden = true
                    self.deepAR.setRenderingResolutionWithWidth(Int(self.view.frame.width * UIScreen.main.scale),
                                                                height: Int(self.view.frame.height * UIScreen.main.scale) )
                    self.deepARView?.removeFromSuperview()
                    self.deepARView?.frame = self.view.frame
                    previewView.addSubview(self.deepARView!)
                    
                    self.timerPk?.invalidate()
                    self.pkStartTime = -1
                    self.pkTimeSlot = 0
                    self.emitTopGifters(isPk: false)
                    self.btnRestartPk.isHidden = true
                    
                    overlayController.btnPk.isHidden = false
                    overlayController.isGoLiveUser = true
                    overlayController.fromId = Themes.sharedInstance.Getuser_id()
                    overlayController.livePkId = ""
                    overlayController.toId = ""
                    self.bgViewTop.backgroundColor = .clear
                    self.view.backgroundColor = .clear
                    self.lblWinningStatus.isHidden = true
                    self.btnRestartPk.isHidden = true
                    self.overlayController.btnPk.isUserInteractionEnabled = true
                    self.overlayController.btnPkRequests.isUserInteractionEnabled = true
                    self.overlayController.cnstrntHeightCommentTblView.constant = self.view.frame.size.height*0.35
                    self.overlayController.tableView.contentInset.top = self.overlayController.tableView.bounds.height
                    self.overlayController.scrollToLastrow()
                    
                }else{
                    
                    self.isExitedGoLive = true
                    self.navigationController?.popToRootViewController(animated: true)
                    
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
                        self.pkDismissTime = payload["pkDismissTime"] as? Int ?? 0
                        
                        DispatchQueue.main.async {
                            self.pkStartTime = (minute * 60) + second
                            self.lblTime.text =  String(format: "%2d : %2d", minute,second)
                            self.pkTimeSlot = slot * 60
                        }
                    }
                    
                    if let  userCoins = payload["userCoins"] as? Dictionary<String, Any>{
                        
                        if let  hostUserId = userCoins["hostUserId"] as? Dictionary<String, Any>{
                            
                            //let roomId = hostUserId["roomId"] as? String ?? ""
                            coinsHostUserId = hostUserId["coins"] as? Int ?? 0
                            self.btnLeftCoin.setTitle("\(coinsHostUserId)", for: .normal)
                        }
                        
                        if let  joinUserId = userCoins["joinUserId"] as? Dictionary<String, Any>{
                            // let roomId = joinUserId["roomId"] as? String ?? ""
                            coinsjoinUserId = joinUserId["coins"] as? Int ?? 0
                            self.btnRightCoin.setTitle("\(coinsjoinUserId)", for: .normal)
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
    
    
    @objc func sio_start_live_pk(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            self.lblPkDismissCounter.isHidden = true
            
            if let  payload = responseDict["payload"] as? Dictionary<String, Any>{
                let pKRoomId = payload["PKRoomId"] as? String ?? ""
                self.livePKId = payload["livePKId"] as? String ?? ""
                let restartPK = payload["restartPK"] as? Int ?? 0
                
                pKBoxingglove = payload["pKBoxingglove"] as? String ?? ""
                
                self.blurPkImgView.isHidden = true
                
                self.pkStartImageView?.removeFromSuperview()
                
                self.pkStartImageView = UIImageViewX(frame: CGRectMake(0, (bgViewTop.frame.origin.y + bgViewTop.frame.size.height), self.view.frame.size.width, self.previewViewLeft.frame.size.height) )
                self.view.addSubview(self.pkStartImageView!)
                self.pkStartImageView?.contentMode = .scaleAspectFit
                self.pkStartImageView?.setGifFromURL(URL(string: pKBoxingglove), manager: .defaultManager, loopCount: -1, showLoader: true)
                pkCloseCounter = -1
                pkCloseTimer?.invalidate()
                
                self.overlayController.btnPk.isUserInteractionEnabled = false
                self.overlayController.btnPkRequests.isUserInteractionEnabled = false
                self.imgVwSeperatorGif.startAnimating()
                self.overlayController.btnPk.isHidden = true
                
                
                if restartPK == 1{
                    self.lblWinningStatus.isHidden = true
                    self.pkStartTime = -1
                    self.pkTimeSlot = 0
                    self.timerPk?.invalidate()
                    self.timerPk = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerHandlerPk(_:)), userInfo: nil, repeats: true)
                    self.lblTime.text = String(format:"%02d : %02d", 0,0)
                    self.btnRestartPk.isHidden = true
                    self.imgVwResultBanner.isHidden = true
                    self.emitLivePkInfo()
                    overlayController.fromId = Themes.sharedInstance.Getuser_id()
                    overlayController.toId = ""
                    overlayController.livePkId = ""
                    // overlayController.emitGetComments()
                    
                }else{
                    self.isPkNavigation = true
                    let arr = pKRoomId.components(separatedBy: ",").filter { $0 != Themes.sharedInstance.Getuser_id() }
                    self.joinerId = arr.last ?? ""
                    self.waitingForOppenentVW.isHidden = true
                    self.timerRandomPk?.invalidate()
                    self.timerRandomPk = nil
                    self.randomPkCounter = 0
                    self.startPKLive(isToCreatePlayer: true)
                }
            }
        }
    }
    
    
    @objc func sio_accept_live_pk_request(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            // AppDelegate.sharedInstance.navigationController?.topViewController?.view.makeToast(message:(responseDict["message"] as? String ?? ""), duration: 1, position: HRToastActivityPositionDefault)
            
            if let  payload = responseDict["payload"] as? Dictionary<String, Any>{
                let pKRoomId = payload["PKRoomId"] as? String ?? ""
                self.livePKId = payload["livePKId"] as? String ?? ""
                self.isPkNavigation = true
                let arr = pKRoomId.components(separatedBy: ",").filter { $0 != Themes.sharedInstance.Getuser_id() }
                self.joinerId = arr.last ?? ""
            }
        }
    }
    
    
    @objc func sio_reject_live_pk_request(notification: Notification) {
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            //AppDelegate.sharedInstance.navigationController?.topViewController?.view.makeToast(message:(responseDict["message"] as? String ?? ""), duration: 1, position: HRToastActivityPositionDefault)
        }
        
    }
    
    @objc func getAllUserPkRequestList(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            if let  payloadArr = responseDict["payload"] as? Array<Dictionary<String, Any>>{
                self.pkRequestListArray.removeAll()
                for dict in payloadArr{
                    self.pkRequestListArray.append(JoinedUser(respDict: dict))
                }
            }
            self.tblVwRequests.reloadData()
        }
    }
    
    
    @objc func sendLivePkRequest(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            AppDelegate.sharedInstance.navigationController?.topViewController?.view.makeToast(message:(responseDict["message"] as? String ?? ""), duration: 1, position: HRToastActivityPositionDefault)
            
            if let  payload = responseDict["payload"] as? Dictionary<String, Any>{
                
            }
        }
    }
        
    @objc func joinedLiveUserListCount(notification: Notification){
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            if let  payload = responseDict["payload"] as? Dictionary<String, Any>{
                self.btnTotalCountJoined.setTitle((payload["liveJoinUserCount"] as? String ?? ""), for: .normal)
                
            }
        }
    }
    
    
    @objc func allLivedFriendsList(notification: Notification){
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            if let  payloadArr = responseDict["payload"] as? Array<Dictionary<String, Any>>{
                self.friendsArray.removeAll()
                for dict in payloadArr{
                    self.friendsArray.append(JoinedUser(respDict: dict))
                }
            }
            
            if  self.friendsArray.count == 0{
                AppDelegate.sharedInstance.navigationController?.topViewController?.view.makeToast(message:(responseDict["message"] as? String ?? ""), duration: 0.5, position: HRToastActivityPositionDefault)
                self.tblVwFriends.isHidden = true
            }
            self.tblVwFriends.reloadData()
        }
    }
    
    
    @objc func timeSlotList(notification: Notification){
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            if let  payloadArr = responseDict["payload"] as? Array<Dictionary<String, Any>>{
                
                if payloadArr.count > 0{
                    self.timeArray.removeAll()
                    self.valueTimeIdArray.removeAll()
                }
                
                for dict in payloadArr{
                    self.timeArray.append(dict["label"] as? String ?? "")
                    self.valueTimeIdArray.append(dict["value"] as? Int ?? 0)
                }
            }
            self.tblVwTime.reloadData()
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
                //let cheerCoins = payload["cheerCoins"] as? Int ?? 0
                let profilePic = payload["profilePic"] as? String ?? ""
                let isFollow =  payload["isFollow"] as? Int ?? 0
                let avatar = payload["avatar"] as? String ?? ""

                if userId == Themes.sharedInstance.Getuser_id() {
                    
                    self.btnAdd.isHidden = true
                    
                    self.profilePicView.setImgView(profilePic: profilePic, frameImg: avatar,changeValue: 5)
                    
                   /* self.btnProfilePic.kf.setImage(with:  URL(string: profilePic) , for: .normal, placeholder:PZImages.avatar , options:nil)
                    self.btnProfilePic.contentMode = .scaleAspectFit
                    self.btnProfilePic.imageView?.contentMode = .scaleAspectFill*/
                    self.btnName.setTitle(name.count>0 ? name : pickzonId, for: .normal)
                    self.btnTotalCoin.setTitle("\(giftedCoins)", for: .normal)
                    cnstrntWidthTopBtnAdd.constant = 0
                    
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
                    
                    self.profilePicViewSelected.setImgView(profilePic: profilePic, frameImg: avatar,changeValue: 5)


                   
                    self.btnSelectedName.setTitle(name.count>0 ? name : pickzonId, for: .normal)
                    self.btnSelectedTotalCoin.setTitle("\(giftedCoins)", for: .normal)
                    
                    self.rightBlurImgVw.kf.setImage(with:  URL(string: profilePic), placeholder:PZImages.avatar , options:nil)
                    self.rightBlurImgVw.image = self.rightBlurImgVw.image?.blurred(radius: 30.0)
                    
                    if playedStreamIdArray.contains(userId){
                        self.rightBlurBgVw.isHidden = true
                    }else{
                        self.rightBlurBgVw.isHidden = false
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
                    
                    
                    if let  action = payload["action"] as? Dictionary<String, Any>{
                        
                        let type = (action["type"] as? Int ?? 0)
                        let value = (action["value"] as? Int ?? 0)
                        
                        if type == 1{
                            
                            //Mic mute/Unmute
                            if value == 0{
                                self.imgVwMicMuteRight.isHidden = true
                            }else if value == 1{
                                self.imgVwMicMuteRight.isHidden = false
                            }
                            
                        }else if type == 2{
                            //Video mute/Unmute
                            if value == 0{
                                self.imgVwCameraMuteRight.isHidden = true
                            }else if value == 1{
                                self.imgVwCameraMuteRight.isHidden = false
                            }
                        }
                       
                    }
                }
            }
        }
    }
    
    
    @objc func joinedGOLive(notification: Notification){
        
        if  let response = notification.userInfo as? Dictionary<String, Any> {
            
        }
    }
    
    
    @objc func keyboardWillAppear(_ notification: Notification) {
        self.bgVwFilterBtn.isHidden = true
        
        if livePKId.count > 0 {
            
            self.overlayController.cnstrntHeightCommentTblView.constant = 200
            self.overlayController.tableView.contentInset.top = self.overlayController.tableView.bounds.height
            self.overlayController.scrollToLastrow()
            
        }else{
            self.overlayController.cnstrntHeightCommentTblView.constant = self.view.frame.size.height*0.35
            self.overlayController.tableView.contentInset.top = self.overlayController.tableView.bounds.height
            self.overlayController.scrollToLastrow()
        }
        //Do something here
        //        var userInfo = notification.userInfo!
        //        let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        /*  if isPkNavigation{
         //cnstrntHeightPreviewBg.constant = self.view.frame.size.height * 0.35
         cnstrntYAxixPkBg.constant = -(100)
         if livePKId.count > 0{
         self.imgVwResultBanner.frame = CGRectMake(0, -100, self.previewViewLeft.frame.width, self.previewViewLeft.frame.height)
         }
         }
         */
    }
    
    @objc func keyboardWillDisappear(_ notification: Notification) {
        
        if livePKId.count > 0 {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.overlayController.cnstrntHeightCommentTblView.constant = self.view.frame.size.height  - ( self.bgViewPK.frame.origin.y +  self.bgViewPK.frame.size.height + self.overlayController.inputContainer.frame.size.height )
            }
            self.overlayController.scrollToLastrow()
            
        }else{
            self.overlayController.cnstrntHeightCommentTblView.constant = self.view.frame.size.height*0.35
            self.overlayController.tableView.contentInset.top = self.overlayController.tableView.bounds.height
            self.overlayController.scrollToLastrow()
        }
        
        //        var userInfo = notification.userInfo!
        //        let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //
        /*   if isPkNavigation{
         // cnstrntHeightPreviewBg.constant = self.view.frame.size.height * 0.45
         cnstrntYAxixPkBg.constant = 0
         }
         
         if livePKId.count > 0{
         self.imgVwResultBanner.frame = CGRectMake(0, 0, self.previewViewLeft.frame.width, self.previewViewLeft.frame.height)
         }*/
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
    
    
    func start() {
        DispatchQueue.main.async {

            self.overlayController.comments.removeAll()
            self.overlayController.btnSendGift.isHidden = true
            self.overlayController.btnLikeVideo.isHidden = true
            self.overlayController.btnPk.isHidden = false
            self.overlayController.btnPkRequests.isHidden = false
            self.overlayController.fromId = Themes.sharedInstance.Getuser_id()
            self.overlayController.toId = self.joinerId
            self.overlayController.livePkId = self.livePKId
            self.overlayController.isGoLiveUser = true
            self.overlayController.btnPk.addTarget(self, action: #selector(self.addPkBtnAction), for: .touchUpInside)
            self.overlayController.btnPkRequests.addTarget(self, action: #selector(self.addPkRequestBtnAction), for: .touchUpInside)
            
            self.overlayController.btnHostOption.isHidden = false
            self.overlayController.btnHostOption.addTarget(self, action: #selector(self.optionsBtnAction), for: .touchUpInside)

         let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            self.overlayController.view.addGestureRecognizer(tap)
        
            self.overlayController.btnPkRequests.badgeString = ""
          
            self.joinRoom(type: 0)
        }
                
//        self.joinRoom(type: 0)
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
          
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }
        self.view.endEditing(true)
        tblVwFriends.isHidden = true
        tblVwRequests.isHidden = true
        viewFilters.isHidden = true
        bgVwBottom.isHidden = true
        self.bgVwFilterBtn.isHidden = true
    }
    
    
    //MARK: Api Methods
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
    
    
    //MARK: UIBUtton Action Methods
    
    
    @objc func optionsBtnAction(){
        self.view.endEditing(true)
        self.bgVwFilterBtn.isHidden = !self.bgVwFilterBtn.isHidden
        self.bgVwBottom.isHidden = true
        self.tblVwFriends.isHidden = true
//        let xAxis =  (self.overlayController.inputContainer.frame.size.width + 30) - self.bgVwFilterBtn.frame.size.width / 2.0
//        self.bgVwFilterBtn.frame = CGRectMake(xAxis, self.bgVwFilterBtn.frame.origin.y, self.bgVwFilterBtn.frame.size.width, self.bgVwFilterBtn.frame.size.height)
      // self.bgVwFilterBtn.leadingConstraint?.constant = xAxis
    }
    
    @IBAction func flashLightBtnAction(){
        self.view.endEditing(true)
        self.bgVwFilterBtn.isHidden = true
        //toggleFlash()
    }
    
    
    func toggleFlash() {
        self.bgVwFilterBtn.isHidden = true
        if client?.cameraPosition == .back {
            self.btnFlashLightCam.isSelected = !self.btnFlashLightCam.isSelected
            guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
            guard device.hasTorch else { return }
            do {
                try device.lockForConfiguration()
                
                if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                    device.torchMode = AVCaptureDevice.TorchMode.off
                } else {
                    do {
                        try device.setTorchModeOn(level: 1.0)
                    } catch {
                        print(error)
                    }
                }
                
                device.unlockForConfiguration()
                
            } catch {
                print(error)
            }
        }else {
            let msg = "Please enable back camera to switch on the torch."
            self.view.makeToast(message: msg, duration: 3, position: HRToastActivityPositionDefault)
        }
    }
    
    
    @IBAction func rotateBtnAction(){
        self.view.endEditing(true)
        self.bgVwFilterBtn.isHidden = true
        cameraController.position = cameraController.position == .back ? .front : .back
    }
    
    func getFilterListAPI(){
       
            Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
        let url =  "\(Constant.sharedinstance.getFiltersURL)"
        
        
        URLhandler.sharedinstance.makeGetAPICall(url:url, param: NSMutableDictionary(), completionHandler: {(responseObject, error) ->  () in
            DispatchQueue.main.async {
                 Themes.sharedInstance.RemoveactivityView(View: self.view)
            }
            
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
                if status == 1 {
                    
                    if let data = result["payload"] as? NSArray {
                        for obj in data {
                            let objFilterEffect = FilterEffects(dict: obj as! Dictionary<String,Any>)
                            Constant.sharedinstance.arrFilterEffect.append(objFilterEffect)
                        }
                        self.viewFilters.isHidden = false
                        self.cvFilters.reloadData()
                    }
                    
                } else  {
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                    
                }
                
                
            }
        })
        
    }
    
    
    @IBAction func filterBtnAction(){
        if Constant.sharedinstance.arrFilterEffect.count == 0 {
            self.getFilterListAPI()
        }else {
            viewFilters.isHidden = viewFilters.isHidden==true ? false : true
            cvFilters.reloadData()
        }
    }
    
    @IBAction func muteAction() {
        self.bgVwFilterBtn.isHidden = true
        
        
        self.client?.toggleAudio()
        // var message = ""
        if self.client?.isAudioEnabled() == true {
            self.btnMute.isSelected = false
            // message = "You have un-muted your mic."
            self.isMuted = false
            self.muteUnmuteEmit(type: 1, value: 0)
            
        }else {
            self.btnMute.isSelected = true
            // message = "You have muted your mic."
            self.isMuted = true
            self.muteUnmuteEmit(type: 1, value: 1)
        }
    }
    
    @IBAction func liveUsersList(_ sender: UIButton) {
        self.view.endEditing(true)
        let controller = StoryBoard.letGo.instantiateViewController(withIdentifier: "GoLiveJoinedUsersVC") as! GoLiveJoinedUsersVC
        controller.fromId = Themes.sharedInstance.Getuser_id()
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
    
    
    
    
    @objc func addPkBtnAction(){
        self.view.endEditing(true)
        self.bgVwFilterBtn.isHidden = true

        self.getAllLivedFriendsList()
        self.bgVwBottom.isHidden = false //.toggle()
        self.tblVwFriends.reloadData()
        self.tblVwRequests.isHidden = true
    }
    
    @objc func addPkRequestBtnAction(){
        self.view.endEditing(true)
        self.bgVwFilterBtn.isHidden = true
        self.bgVwTime.isHidden = true
        emitAllUserPkRequestList()
        tblVwRequests.isHidden = false //.toggle()
        self.bgVwBottom.isHidden = true
        self.tblVwFriends.isHidden = true
        tblVwRequests.reloadData()
    }
    
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        self.view.endEditing(true)
        AlertView.sharedManager.presentAlertWith(title: "", msg: "Do you want to exit live?", buttonTitles: ["No","Yes"], onController: self) { (title, index) in
            
            if index == 1{
                self.setLive(goLive:0)
                if self.livePKId.count == 0 { //}|| self.isGoLiveRandomPrevious == true{
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    
    @IBAction func btnFriendsAction(){
        self.isTimeSelcted = false
        self.tblVwFriends.isHidden.toggle()
        self.tblVwFriends.reloadData()
    }
    
    @IBAction func btnRandomAction(){
        self.tblVwFriends.isHidden = true
        self.isTimeSelcted = true
        bgVwTime.isHidden = true
        self.tblVwTime.reloadData()
        self.bgVwBottom.isHidden = true
        self.waitingForOppenentVW.isHidden = false
        playRandomPk(pkTime: 2)
        randomPkCounter = 0
        timerRandomPk?.invalidate()
        timerRandomPk = nil
        timerRandomPk = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerRandomPkHandlerPk(_:)), userInfo: nil, repeats: true)
    }
    
    
    
    
    @IBAction func btnFollowRightBtnAction(){
        
        self.followUserApi(userId: joinerId)
    }
    
    @IBAction func restrartPkBtnAction(_ sender:UIButton){
        emitRestartLivePk()
    }
    
    
    @objc func timerRandomPkHandlerPk(_ timer: Timer) {
        
        if randomPkCounter < 30{
            
            randomPkCounter += 1
            self.overlayController.btnPk.isUserInteractionEnabled = false
            self.overlayController.btnPkRequests.isUserInteractionEnabled = false
        }else{
            self.overlayController.btnPk.isUserInteractionEnabled = true
            self.overlayController.btnPkRequests.isUserInteractionEnabled = true
            self.leaveRandomPk()
            self.waitingForOppenentVW.isHidden = true
            randomPkCounter = 0
            timerRandomPk?.invalidate()
            timerRandomPk = nil
            self.overlayController.btnPk.isUserInteractionEnabled = false
            
        }
    }
    
    
    //MARK: - CAMERA ACCESS CHECK
    func cameraAllowsAccessToApplicationCheck(){
        
        
        
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorizationStatus {
        case .notDetermined:
            // permission dialog not yet presented, request authorization
            AVCaptureDevice.requestAccess(for: AVMediaType.video,
                                          completionHandler: { (granted:Bool) -> Void in
                if granted {
                    print("access granted", terminator: "")
                    self.checkMicPermission()
                }
                else {
                    print("access denied", terminator: "")
                    self.alertToEncourageCameraAccessWhenApplicationStarts()
                }
            })
        case .authorized:
            print("Access authorized", terminator: "")
            self.checkMicPermission()
        case .denied, .restricted:
            alertToEncourageCameraAccessWhenApplicationStarts()
            
            break
        default:
            print("DO NOTHING", terminator: "")
        }
    }
    
    func checkMicPermission() -> Bool {
        
        var permissionCheck: Bool = false
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            permissionCheck = true
            self.start()
        case AVAudioSession.RecordPermission.denied:
            permissionCheck = false
            self.alertToEncourageCameraAccessWhenApplicationStarts()
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    permissionCheck = true
                    self.start()
                } else {
                    self.alertToEncourageCameraAccessWhenApplicationStarts()
                }
            })
        default:
            break
        }
        
        return permissionCheck
    }
    
    
    
    func alertToEncourageCameraAccessWhenApplicationStarts()
    {
        AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: "Please enable camera and Microphone", buttonTitles: ["Cancel","Okay"], onController: self) { title, index in
            
            if index == 0{
                return
            }else{
                let settingsUrl = NSURL(string:UIApplication.openSettingsURLString)
                if let url = settingsUrl {
                    DispatchQueue.main.async {
                        UIApplication.shared.openURL(url as URL)
                    }
                    
                }
            }
        }
    }
}

extension BroadcasterViewController {
    
    //MARK:  Start PK
    func startPKLive(isToCreatePlayer:Bool){
        
        self.previewView.isHidden = true
        if Settings.sharedInstance.goLiveStream == 1 {
            self.client?.remoteView = nil
        }
        self.lblTime.text = "00 : 00"
        getUserInfo(userId: joinerId)
        self.btnLeftCoin.setTitle("0", for: .normal)
        self.btnRightCoin.setTitle("0", for: .normal)
        emitLivePkInfo()
        //self.bgViewTop.backgroundColor = Themes.sharedInstance.colorWithHexString(hex: "#0d1e30")
        self.bgViewTop.backgroundColor = .clear
        self.view.backgroundColor = Themes.sharedInstance.colorWithHexString(hex: "#0d1e30")
        self.bgViewPK.isHidden = false
        progressView.progressTintColor = UIColor.blue
        progressView.trackTintColor = UIColor.red
        progressView.progressViewStyle = .bar
        progressView.progress = 0.5
       
        self.deepARView?.removeFromSuperview()
        DispatchQueue.main.async {
            self.cnstrntHeightPreviewBg.constant = self.view.frame.size.height * 0.35
            self.deepARView?.bounds = self.previewViewLeft.bounds
            self.deepARView?.frame = self.previewViewLeft.bounds
           
            let width = (self.previewViewLeft.frame.size.width * UIScreen.main.scale)
            let height = (self.view.frame.size.height / (self.view.frame.size.width/self.previewViewLeft.frame.width) * UIScreen.main.scale)
            self.deepAR.setRenderingResolutionWithWidth(Int(width) ,
             height: Int(height))
            self.previewViewLeft.addSubview(self.deepARView!)
        }
        
        self.previewViewLeft.clipsToBounds = true
        
            self.client?.setRemoteView(remoteContainer: self.previewViewRight, mode: .scaleAspectFill)
            client?.play(streamId: joinerId)
            DispatchQueue.main.async {
                self.client?.remoteView?.setSize(CGSize(width: self.previewViewRight.frame.size.width, height: self.previewViewRight.frame.size.height))
                (self.client?.remoteView as? UIView)?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                (self.client?.remoteView as? UIView)?.translatesAutoresizingMaskIntoConstraints = true
                (self.client?.remoteView as? UIView)?.setNeedsDisplay()
            }
            
            if client?.delegate == nil {
                client?.delegate = self
            }
        client?.enableTrack(trackId: Themes.sharedInstance.Getuser_id(), enabled: false)
        
        self.previewViewRight.clipsToBounds = true
        timerPk?.invalidate()
        timerPk = nil
        timerPk = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerHandlerPk(_:)), userInfo: nil, repeats: true)
        emitTopGifters(isPk: true)
        overlayController.fromId = Themes.sharedInstance.Getuser_id()
        overlayController.toId = joinerId
        overlayController.livePkId = livePKId
        overlayController.btnPk.isHidden = true
        overlayController.btnPk.isUserInteractionEnabled = false
        overlayController.btnPkRequests.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.overlayController.cnstrntHeightCommentTblView.constant = self.view.frame.size.height  - ( self.bgViewPK.frame.origin.y +  self.bgViewPK.frame.size.height + self.overlayController.inputContainer.frame.size.height )
        }
        self.overlayController.btnPk.isHidden = true
        self.overlayController.scrollToLastrow()
    }
    
    
    @objc func timerHandlerPk(_ timer: Timer) {
        
        if pkStartTime > 0{
            self.pkStartTime = self.pkStartTime - 1
            let min = pkStartTime / 60
            let sec = pkStartTime % 60
            self.lblTime.text = String(format: "%02d : %02d", min,sec)
            
            if self.pkStartTime <=  ((pkTimeSlot) - 3){
                self.pkStartImageView?.removeFromSuperview()
                self.blurPkImgView.isHidden = false
            }
            
        }else if pkStartTime == 0{
            
            timerPk?.invalidate()
            timerPk = nil
            if Themes.sharedInstance.Getuser_id() != joinerId{
                self.emitPkResultDeclare()
            }
            self.btnRestartPk.isHidden = false
            self.btnRestartPk.setTitle("Restart", for: .normal)
        }
    }
    
    
    @objc func pkCloseTimerHandler(_ timer : Timer){
        
        print("pkCloseCounter ==== \(pkCloseCounter)")
        if pkCloseCounter >= pkDismissTime{
            pkCloseCounter = -1
            pkCloseTimer?.invalidate()
            
            let param = ["authToken": Themes.sharedInstance.getAuthToken(),"roomId":Themes.sharedInstance.Getuser_id(),"type":"2"] as [String : Any]
            SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_exit_go_live_host_user, param)
            
        }else if pkCloseCounter <= pkDismissTime{
            pkCloseCounter = pkCloseCounter + 1
            self.lblPkDismissCounter.isHidden = false
            self.lblPkDismissCounter.text = "\((pkDismissTime-pkCloseCounter))"
        }else{
            pkCloseCounter = -1
            pkCloseTimer?.invalidate()
            pkCloseTimer = nil
        }
    }
    
}


//MARK:- CollectionView Delegates Protocols
extension BroadcasterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if  collectionView == cvFilters{
            return  Constant.sharedinstance.arrFilterEffect.count
            
        }
        if collectionView == collectionVwJoinedUser {
            return topGiftersArray.count
        }
        
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if  collectionView == cvFilters{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCVCell", for: indexPath) as! FilterCVCell
            let objFilter = Constant.sharedinstance.arrFilterEffect[indexPath.row]
            cell.lblTitle.text = objFilter.title.capitalized
            if filterIndex == indexPath.row {
                cell.lblTitle.textColor = .label
            }else {
                cell.lblTitle.textColor = UIColor.lightGray
            }
            
            cell.imgImage.kf.setImage(with: URL(string: objFilter.icon), placeholder: nil, options:nil, progressBlock: nil, completionHandler: { (resp) in
             })
            return cell
            
        }else if collectionView == collectionVwJoinedUser {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImgCollectionCell", for: indexPath) as! ImgCollectionCell
            cell.imgvw.kf.setImage(with: URL(string: self.topGiftersArray[indexPath.row].profilePic), placeholder: PZImages.avatar , options: nil, progressBlock: nil, completionHandler: { response in  })
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == cvFilters{
            return CGSize(width:100, height: 95)
        }
        return CGSize(width:32, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if  collectionView == cvFilters{
            filterIndex = indexPath.item
            self.addFilter()
        }else if collectionView == collectionVwJoinedUser{
            
            
            if #available(iOS 13.0, *) {
                
                let controller = StoryBoard.letGo.instantiateViewController(identifier: "UserInfoVC")
                as! UserInfoVC
                
                controller.istoHideProfile = 1
                controller.selIndex = indexPath.item
                controller.userObj.name = self.topGiftersArray[indexPath.item].name
                controller.userObj.profilePic = self.topGiftersArray[indexPath.item].profilePic
                controller.userObj.pickzonId = self.topGiftersArray[indexPath.item].pickzonId
                controller.userObj.celebrity = self.topGiftersArray[indexPath.item].celebrity
                controller.userObj.userId = self.topGiftersArray[indexPath.item].userId
                let useInlineMode = view != nil
                
                controller.title = ""
                controller.navigationController?.navigationBar.isHidden = true
                controller.view.backgroundColor = .clear
                controller.goLivefromId = Themes.sharedInstance.Getuser_id()
                
                
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

extension BroadcasterViewController:UITableViewDelegate, UITableViewDataSource{
    
    //MARK: Tableview data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if tableView == tblVwRequests{
            return pkRequestListArray.count
        }
        
        if tableView == tblVwTime{
            return timeArray.count
        }
        
        return friendsArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if tableView == tblVwRequests{
            
            let cell = tblVwRequests.dequeueReusableCell(withIdentifier: "PkRequestTblCell") as! PkRequestTblCell
            cell.selectionStyle = .none
            
            cell.btnProfilePic.kf.setImage(with:  URL(string: pkRequestListArray[indexPath.row].profilePic) , for: .normal, placeholder:PZImages.avatar , options:nil)
            cell.btnProfilePic.contentMode = .scaleAspectFit
            cell.btnProfilePic.imageView?.contentMode = .scaleAspectFill
            let name = pkRequestListArray[indexPath.row].name.count>0 ? pkRequestListArray[indexPath.row].name : pkRequestListArray[indexPath.row].pickzonId
            cell.btnName.setTitle(name, for: .normal)
            cell.lblDesc.text = "\(name) send you PK request"
            cell.btnAccept.tag = indexPath.row
            cell.btnAccept.addTarget(self, action: #selector(acceptRequestBtnAction(_:)), for: .touchUpInside)
            cell.btnDecline.tag = indexPath.row
            cell.btnDecline.addTarget(self, action: #selector(declineRequestBtnAction(_:)), for: .touchUpInside)
            
            switch pkRequestListArray[indexPath.row].celebrity{
            case 1:
                cell.imgVwCelebrity.isHidden = false
                cell.imgVwCelebrity.image = PZImages.greenVerification

            case 4:
                cell.imgVwCelebrity.isHidden = false
                cell.imgVwCelebrity.image = PZImages.goldVerification
            case 5:
                cell.imgVwCelebrity.isHidden = false
                cell.imgVwCelebrity.image = PZImages.blueVerification

            default:
                cell.imgVwCelebrity.isHidden = true
            }
            
            
            return cell
            
        }else if tableView == tblVwTime{
            
            let cell = tblVwTime.dequeueReusableCell(withIdentifier: "TimeSelectionTblCell") as! TimeSelectionTblCell
            cell.selectionStyle = .none
            cell.lblTime.text = timeArray[indexPath.row]
            if indexPath.row == 1{
                cell.lblTime.layer.borderColor = UIColor.white.cgColor
            }else{
                cell.lblTime.layer.borderColor = UIColor.clear.cgColor
            }
            cell.lblTime.layer.borderWidth = 1.0
            return cell
            
        }else if tableView == tblVwFriends{
            
            let cell = tblVwFriends.dequeueReusableCell(withIdentifier: "FriendsTblCell") as! FriendsTblCell
            cell.selectionStyle = .none
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            
            let name = friendsArray[indexPath.row].name.count>0 ? friendsArray[indexPath.row].name : friendsArray[indexPath.row].pickzonId
            cell.lblName.text = name
            cell.imgVwProfilePic.kf.setImage(with: URL(string: friendsArray[indexPath.row].profilePic), placeholder: PZImages.avatar)
            
            switch friendsArray[indexPath.row].celebrity{
            case 1:
                cell.imgVwCelebrity.isHidden = false
                cell.imgVwCelebrity.image = PZImages.greenVerification

            case 4:
                cell.imgVwCelebrity.isHidden = false
                cell.imgVwCelebrity.image = PZImages.goldVerification
            case 5:
                cell.imgVwCelebrity.isHidden = false
                cell.imgVwCelebrity.image = PZImages.blueVerification

            default:
                cell.imgVwCelebrity.isHidden = true
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.bgVwBottom.isHidden = true
        
        if tableView == tblVwRequests{
            
            tblVwRequests.isHidden = true
            
        }else if tableView == tblVwTime {
            
            self.bgVwTime.isHidden = true
            
            if selectedUserId.count == 0{
                
            }else{
                sendLivePkRequest(userId: selectedUserId, time: valueTimeIdArray[indexPath.row])
            }
            
        }else if tableView == tblVwFriends{
            
            if timeArray.count == 0{
                //self.getTimeSlotApi()
            }
            selectedUserId = friendsArray[indexPath.row].userId
            self.bgVwBottom.isHidden = true
            self.tblVwFriends.isHidden = true
            self.bgVwTime.isHidden = false
            self.tblVwTime.reloadData()
        }
    }
    
    
    //MARK: Selector method
    @objc func acceptRequestBtnAction(_ sender:UIButton){
        let param = [
            "authToken": Themes.sharedInstance.getAuthToken(),
            "livePKId":pkRequestListArray[sender.tag].livePKId
        ] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_accept_live_pk_request  , param)
        self.pkRequestListArray.remove(at: sender.tag)
        self.tblVwRequests.isHidden = true
        
    }
    
    @objc func declineRequestBtnAction(_ sender:UIButton){
        let param = [
            "authToken": Themes.sharedInstance.getAuthToken(),
            "livePKId":pkRequestListArray[sender.tag].livePKId
        ] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_reject_live_pk_request  , param)
        self.pkRequestListArray.remove(at: sender.tag)
        self.tblVwRequests.isHidden = true
    }
}


extension BroadcasterViewController: SVGAPlayerDelegate {
    
    func addGiftView(remoteSVGAUrl:String){
        
     
        self.remoteSVGAPlayer?.stopAnimation()
        // self.remoteSVGAPlayer?.clear()
        //        self.remoteSVGAPlayer?.frame = .zero
        //        self.remoteSVGAPlayer?.removeFromSuperview()
        //
        //MARK: - Local
        
        //  localSVGAParser.parse(withNamed: localSVGAName, in: nil, completionBlock: { (svgaItem) in
        //       localSVGAPlayer.videoItem = svgaItem
        //       localSVGAPlayer.startAnimation()
        //  }, failureBlock: nil)
        self.isPlayingGift = true

      //  let extraVal  = (UIDevice().hasNotch) ? 130  : 130
        if remoteSVGAPlayer == nil {
            remoteSVGAPlayer = SVGAPlayer(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: backView!.frame.size.height))
            remoteSVGAPlayer?.backgroundColor = .clear
            backView?.addSubview(remoteSVGAPlayer!)
            remoteSVGAPlayer?.delegate = self
            remoteSVGAPlayer?.loops = 1   // repeat count，0 means infinite
            remoteSVGAPlayer?.clearsAfterStop = true
           // remoteSVGAPlayer?.frame = CGRect(x: 0, y: -CGFloat(extraVal), width: self.view.frame.size.width, height: backView!.frame.size.height)
            
            
        }
        
        backView.backgroundColor = .clear
        if let url = URL(string: remoteSVGAUrl) {
            let remoteSVGAParser = SVGAParser()
            remoteSVGAParser.enabledMemoryCache = true
            remoteSVGAParser.parse(with: url, completionBlock: { (svgaItem) in
                self.remoteSVGAPlayer?.videoItem = svgaItem
                self.remoteSVGAPlayer?.videoItem.saveCache(remoteSVGAUrl)
                
             /*   let para = NSMutableParagraphStyle()
                para.lineBreakMode = .byTruncatingTail
                para.alignment = .left
                let str = NSAttributedString(
                    string: "@radheshyam23894",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 28),
                        .foregroundColor: UIColor.white,
                        .paragraphStyle: para,
                    ])
                self.remoteSVGAPlayer?.setAttributedText(str, forKey: "name")*/
//                if let url = URL(string: "https://d25frd65ud7bv8.cloudfront.net/user/2024/04/013-1713950288484.png") {
//                    self.remoteSVGAPlayer?.setImageWith(url, forKey: "avator")
//                }
                
                self.remoteSVGAPlayer?.startAnimation()
            }, failureBlock: { (error) in
                print("--------------------- \(String(describing: error))")
                self.isPlayingGift = false
                self.dictCurrentPlayingGift = nil
            })
        }

//        self.remoteSVGAPlayer?.setAttributedText(NSAttributedString(string: "Hello Radhe",attributes:[
//            NSAttributedString.Key.foregroundColor: UIColor.red,
//            NSAttributedString.Key.font: UIFont(name:"Roboto-Regular", size: 15)!]), forKey: "name")
//        
    }
    
    /// SVGA animation progress
    func svgaPlayerDidAnimated(toPercentage percentage: CGFloat) {
        //  print("precent ------- \(percentage)")
    }
    
    /// SVGA frame index with images resource
    func svgaPlayerDidAnimated(toFrame frame: Int) {
        //  print("frame ------- \(frame)")
    }
    
    /// doing after SVGA animation end or stop
    func svgaPlayerDidFinishedAnimation(_ player: SVGAPlayer!) {
        
        print("play end ---------------")
        self.remoteSVGAPlayer?.stopAnimation()
        self.remoteSVGAPlayer?.clear()
        
        self.isPlayingGift = false
        dictCurrentPlayingGift = nil

        //  self.remoteSVGAPlayer?.clear()
        //            self.remoteSVGAPlayer?.frame = .zero
        //            self.remoteSVGAPlayer?.removeFromSuperview()
        //            self.view.willRemoveSubview(self.remoteSVGAPlayer!)
        
        if giftSvgUrlArray.count > 0{
            if let dict = giftSvgUrlArray.first {
                let icon = dict["icon"] as? String ?? ""
                dictCurrentPlayingGift = dict
                self.addGiftView(remoteSVGAUrl: icon)
                giftSvgUrlArray.removeFirst()
                
            }
        }else{
            
        }
    }
    
}


extension BroadcasterViewController: AntMediaClientDelegate{
    
    public func clientDidDisconnect(_ message: String) {
        
        //removePlayers();
        
    }
    
    public func clientHasError(_ message: String) {
        print("clientHasError:\(message)")
    }
    
    public func streamIdToPublish(streamId: String) {
        
        /*Run.onMainThread {
         
         AntMediaClient.printf("stream id to publish \(streamId)")
         //self.publisherStreamId = streamId;
         //opens the camera
         self.conferenceClient?.initPeerConnection(streamId: streamId, mode: AntMediaClientMode.publish)
         
         //if you can mute and close the camera, you can do that here
         //self.conferenceClient?.setAudioTrack(enableTrack: false)
         
         //self.conferenceClient?.setVideoTrack(enableTrack: true)
         
         
         //if you want to publish immediately, uncomment the line below and just call the method below
         //self.conferenceClient?.publish(streamId: self.publisherStreamId)
         }*/
        DispatchQueue.main.async{
            self.client?.initPeerConnection(streamId: streamId, mode: AntMediaClientMode.publish)
            self.client?.setVideoTrack(enableTrack: true)
            self.client?.setAudioTrack(enableTrack: true)
            AntMediaClient.speakerOn()
        }
    }
    
    func localStreamStarted(streamId: String){
        print("local audio and video is started publish")
    }
    
    public func newStreamsJoined(streams: [String]) {
        for stream in streams {
            print("New stream in the room: \(stream)")
        }
        
        if joinerId.length > 0 {
            self.client?.play(streamId: joinerId)
        }
        
    }
    
    public func streamsLeft(streams: [String])
    {
        for stream in streams {
            print("Stream(\(stream)) left the room")
        }
    }
    
    
    public func playStarted(streamId: String) {
        print("play started")
        AntMediaClient.speakerOn()
        self.playedStreamIdArray.append(streamId)
        self.rightBlurBgVw.isHidden = true
    }
    
    public func trackAdded(track: RTCMediaStreamTrack, stream: [RTCMediaStream]) {
        
       // print("Track is added with id:\(track.trackId)")
        //tracks are in this format ARDAMSv+ streamId or ARDAMSa + streamId
        // let streamId =  track.trackId.suffix(track.trackId.count - "ARDAMSv".count);
        
        /* if (streamId == self.publisherStreamId) {
         
         //TODO: Refactor here to have a better solution. I mean server should not send this track
         // When we have single object to publish and play the streams. It can be done.
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
         //It's delay for 3 seconds because in some cases server enables while adding local stream
         self.client.enableTrack(trackId: String(streamId), enabled: false);
         }
         track.isEnabled = false;
         return;
         
         }*/
        
        self.client?.enableTrack(trackId: Themes.sharedInstance.Getuser_id(), enabled: true);
        //self.remoteClient.enableTrack(trackId: joinerId, enabled: false)
        
        
        //
        
        /*AntMediaClient.printf("Track is added with id:\(track.trackId) and stream id:\(streamId)")
         if let videoTrack = track as? RTCVideoTrack
         {
         //find the view to render
         var i = 0;
         while (i < remoteViewTrackMap.count) {
         if (remoteViewTrackMap[i] == nil) {
         break
         }
         i += 1
         }
         
         if (i < remoteViewTrackMap.count) {
         //keep the track reference
         remoteViewTrackMap[i] = videoTrack;
         videoTrack.add(remoteViews[i]);
         
         Run.onMainThread { [self] in
         if let view = self.remoteViews[i] as? RTCMTLVideoView {
         view.isHidden = false;
         }
         else if let view = remoteViews[i] as? RTCEAGLVideoView {
         view.isHidden = false;
         }
         }
         }
         else {
         AntMediaClient.printf("No space to render new video track")
         }
         
         }
         else {
         AntMediaClient.printf("New track is not video track")
         }*/
    }
    
    public func trackRemoved(track: RTCMediaStreamTrack) {
        
        /* Run.onMainThread { [self] in
         var i = 0;
         
         while (i < remoteViewTrackMap.count)
         {
         if (remoteViewTrackMap[i]?.trackId == track.trackId)
         {
         remoteViewTrackMap[i] = nil;
         
         if let view = remoteViews[i] as? RTCMTLVideoView {
         view.isHidden = true;
         }
         else if let view = remoteViews[i] as? RTCEAGLVideoView {
         view.isHidden = true;
         }
         break;
         }
         i += 1
         }
         }*/
        
    }
    
    public func playFinished(streamId: String) {
        //removePlayers();
    }
    
    
    
    public func publishStarted(streamId: String) {
        print("Publish started for stream:\(streamId)")
        AntMediaClient.speakerOn();
    }
    
    public func publishFinished(streamId: String) {
        print("Publish finished for stream:\(streamId)")
        
    }
    
    public func disconnected(streamId: String) {
        print("disconnected streamId: \(streamId)")
        
    }
    
    public func audioSessionDidStartPlayOrRecord(streamId: String) {
        
    }
    
    public func dataReceivedFromDataChannel(streamId: String, data: Data, binary: Bool) {
        
    }
    
    public func streamInformation(streamInfo: [StreamInformation]) {
        
    }
    
    public func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        print("Video size changed to " + String(Int(size.width)) + "x" + String(Int(size.height)) + ". These changes are not handled in Simulator for now")
        
    }
}

extension BroadcasterViewController: DeepARDelegate {
    
    func didInitialize() {
        if (deepAR.videoRecordingWarmupEnabled) {
            DispatchQueue.main.async { [self] in
                let width: Int = Int(deepAR.renderingResolution.width)
                let height: Int =  Int(deepAR.renderingResolution.height)
                deepAR.startCapture(withOutputWidth: width, outputHeight: height, subframe: CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
            }
        }
        
    }
    
    func frameAvailable(_ sampleBuffer: CMSampleBuffer!) {
    client?.deliverExternalVideo(sampleBuffer: sampleBuffer ,rotation:0)
    }
    

    func didFinishShutdown (){
     print("didFinishShutdown!!!!!")
     }
    
    /*
     func didFinishPreparingForVideoRecording() {
     NSLog("didFinishPreparingForVideoRecording!!!!!")
     }
     
     func didStartVideoRecording() {
     NSLog("didStartVideoRecording!!!!!")
     }
     
     func didFinishVideoRecording(_ videoFilePath: String!) {
     
     NSLog("didFinishVideoRecording!!!!!")
     
     /* let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
      let components = videoFilePath.components(separatedBy: "/")
      guard let last = components.last else { return }
      let destination = URL(fileURLWithPath: String(format: "%@/%@", documentsDirectory, last))
      
      let playerController = AVPlayerViewController()
      let player = AVPlayer(url: destination)
      playerController.player = player
      present(playerController, animated: true) {
      player.play()
      }*/
     }
     
     func recordingFailedWithError(_ error: Error!) {
     print("recordingFailedWithError :\(error)")
     }
     
     func didTakeScreenshot(_ screenshot: UIImage!) {
     /* UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil)
      
      let imageView = UIImageView(image: screenshot)
      imageView.frame = view.frame
      view.insertSubview(imageView, aboveSubview: arView)
      
      let flashView = UIView(frame: view.frame)
      flashView.alpha = 0
      flashView.backgroundColor = .black
      view.insertSubview(flashView, aboveSubview: imageView)
      
      UIView.animate(withDuration: 0.1, animations: {
      flashView.alpha = 1
      }) { _ in
      flashView.removeFromSuperview()
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
      imageView.removeFromSuperview()
      }
      }*/
     }*/
    
    
    /*
     
     func faceVisiblityDidChange(_ faceVisible: Bool) {}
     
     */
}



extension String {
    var path: String? {
        return Bundle.main.path(forResource: self, ofType: nil)
    }
}







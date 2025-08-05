//
//  LiveListVC.swift
//  SCIMBO
//
//  Created by SachTech on 16/09/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import UIKit
import DeepAR



//let deepArLicenseKey = "00d69096a5676fc63bf4c4d21910371afc0ba5f771140459876c9db3108971ccd10ea3df60ce8ce7"

class GoLiveVC: UIViewController {
    
    @IBOutlet weak var waitingForOppenentVW:UIView!
    @IBOutlet weak var btnClose:UIButton!
    @IBOutlet weak var btnFlashLightCam:UIButton!
    @IBOutlet weak var btnRotateCam:UIButton!
    @IBOutlet weak var btnPenCam:UIButton!
    @IBOutlet weak var btnFilterCam:UIButton!
    @IBOutlet weak var btnGoLive:UIButton!
    @IBOutlet weak var stckVw:UIStackView!
    
    @IBOutlet weak var bgVwBottom:UIViewX!
    @IBOutlet weak var tblVwFriends:UITableView!
    
    @IBOutlet weak var bgVwTime:UIViewX!
    @IBOutlet weak var tblVwTime:UITableView!
    
    
    @IBOutlet weak var viewFilters:UIView!
    @IBOutlet weak var cvFilters:UICollectionView!
    
    var friendsArray = [JoinedUser]()
    var timeArray =  [String]()
    var valueTimeIdArray = [Int]()
    var selectedFriendId = ""
    
    @IBOutlet weak var cameraView: UIView!
    
    var randomPkCounter = 0
    var timerRandomPk:Timer?
    var  devicePosition:AVCaptureDevice.Position = .front
    
    //Implementing Deep AR Effects
    var cameraController: CameraController!
    var filterIndex: Int = 0
    var deepAR: DeepAR!
    var arView: UIView!
   
    
    var deepARView:UIView?
    
    
    
    //MARK: Controller Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print("UIViewController : GoLiveTabVC")
        
        self.waitingForOppenentVW.isHidden = true
        
        tblVwFriends.isHidden = true
        bgVwTime.isHidden = true
        registerTablevVwCell()
        btnClose.setImageTintColor(.white)
        viewFilters.isHidden = true
        
        self.cameraAllowsAccessToApplicationCheck()
        
        self.addObservers()
        
        tblVwFriends.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        waitingForOppenentVW.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.waitingForOppenentVWTap(_:))))
        waitingForOppenentVW.isUserInteractionEnabled = true
        
        getTimeSlotApi()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
        cameraController?.deepAR.shutdown()
        if deepAR == nil {
            
        }else{
            deepAR?.shutdown()
            deepAR = nil
            cameraController = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupDeepARAndCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        timerRandomPk?.invalidate()
        timerRandomPk = nil
        self.btnGoLive.isHidden = false
    }
    
    
    deinit{
        print("Deinit")
        if deepAR == nil {
            
        }else{
            deepAR?.shutdown()
            deepAR = nil
            cameraController = nil
        }
        cameraController?.deepAR.shutdown()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view != self.viewFilters {
            viewFilters.isHidden = true
        }
        self.bgVwTime.isHidden = true
        // self.tblVwTime.isHidden = true
        self.tblVwFriends.isHidden = true
        self.btnGoLive.isHidden = false
    }
    
    func setupDeepARAndCamera() {
        
        self.deepAR = DeepAR()
        //self.deepAR.delegate = self
        self.deepAR.setLicenseKey(Settings.sharedInstance.deepARLicenseKey)
        self.deepAR.videoRecordingWarmupEnabled = false
        cameraController = CameraController(deepAR: self.deepAR)
        
        if let deepARView = deepAR.createARView(withFrame: self.view.frame) {
            self.deepARView = deepARView
            self.deepARView?.frame = self.view.frame
            cameraView.addSubview( self.deepARView!)
        }
        cameraController.startCamera()
    }
    
    
    func addFilter() {
        if filterIndex == 0 {
            deepAR.switchEffect(withSlot: "effect", path: nil)
        }else {
            let obj = Constant.sharedinstance.arrFilterEffect[filterIndex]
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
    
    //MARK: Other helpfule methods
    
    @objc func waitingForOppenentVWTap(_ tapgsture:UITapGestureRecognizer){
        waitingForOppenentVW.isHidden = true
        self.leaveRandomPk()
        randomPkCounter = 0
        timerRandomPk?.invalidate()
        timerRandomPk = nil
    }
    
    
    func sendLivePkRequest(userId:String,time:Int){
        let param = [
            "authToken": Themes.sharedInstance.getAuthToken(),
            "userId":userId,
            "pkTime":"\(time)"
        ] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_send_live_pk_request  , param)
    }
    
    func getTimeSlot(){
        
        let param = [:] as [String : Any]
        
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_live_pk_time_slot  , param)
    }
    
    
    func getAllLivedFriendsList(){
        
        let param = [
            "authToken": Themes.sharedInstance.getAuthToken()
        ] as [String : Any]
        
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_get_all_live_friend_list  , param)
    }
    
    
    func playRandomPk(pkTime:Int){
        
        let param = ["authToken": Themes.sharedInstance.getAuthToken(),"pkTime":"\(pkTime)","joinRoom":"0"] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_play_random_pk, param)
        
    }
    
    func leaveRandomPk(){
        
        let param = ["authToken": Themes.sharedInstance.getAuthToken(),"joinRoom":"0"] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_leave_random_pk, param)
    }
    
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
                }else {
                    print("access denied", terminator: "")
                }
            })
        case .authorized:
            print("Access authorized", terminator: "")
            // self.goLiveUser()
            self.checkMicPermission()
            
        case .denied, .restricted:
            alertToEncourageCameraAccessWhenApplicationStarts()
            
            break
        default:
            print("DO NOTHING", terminator: "")
        }
    }
    
    func checkMicPermission()  {
        
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            print("Mic Permission granted", terminator: "")
            do{
                try AVAudioSession.sharedInstance().setPreferredSampleRate(44_100)
               try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: .allowBluetooth)
                try AVAudioSession.sharedInstance().setMode(AVAudioSession.Mode.default)
                try AVAudioSession.sharedInstance().setActive(true)
            }catch{
               print(error)
            }
        case AVAudioSession.RecordPermission.denied:
            self.alertToEncourageCameraAccessWhenApplicationStarts()
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    do{
                        try AVAudioSession.sharedInstance().setPreferredSampleRate(44_100)
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: [.defaultToSpeaker,.allowBluetooth,.allowBluetoothA2DP])
                        try AVAudioSession.sharedInstance().setMode(AVAudioSession.Mode.default)
                        try AVAudioSession.sharedInstance().setActive(true)
                    }catch{
                       print(error)
                    }
                } else {
                    self.alertToEncourageCameraAccessWhenApplicationStarts()
                }
            })
        default:
            break
        }
        
    }
    
    
    
    func alertToEncourageCameraAccessWhenApplicationStarts(){
        
        AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: "Please enable camera", buttonTitles: ["Cancel","Okay"], onController: self) { title, index in
            
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
    
    
    func registerTablevVwCell(){
        tblVwFriends.register(UINib(nibName: "FriendsTblCell", bundle: nil), forCellReuseIdentifier: "FriendsTblCell")
        tblVwTime.register(UINib(nibName: "TimeSelectionTblCell", bundle: nil), forCellReuseIdentifier: "TimeSelectionTblCell")
        cvFilters.register(UINib(nibName: "FilterCVCell", bundle: nil), forCellWithReuseIdentifier: "FilterCVCell")
    }
    
    
    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    
    func getTimeSlotApi(){
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeGetCall(url: Constant.sharedinstance.get_pk_time_slot, param: [:]) {(responseObject, error) ->  () in
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
               // let message = result["message"] as? String ?? ""
                
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
    
    
    //MARK: Add Observers
    
    func addObservers(){
        
        
       
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_play_random_pk(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_play_random_pk ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_leave_random_pk(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_leave_random_pk ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_start_live_pk(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_start_live_pk), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.allLivedFriendsList(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_get_all_live_friend_list ), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.socketConnected(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.socketCnnected), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.timeSlotList(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_live_pk_time_slot), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendLivePkRequest(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_send_live_pk_request ), object: nil)
    }
    
    
    //MARK: Observers methods
    
    @objc func socketConnected(notification: Notification) {
        
    }
  
   
    
    
    @objc func sio_leave_random_pk(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            self.waitingForOppenentVW.isHidden = true
            self.timerRandomPk = nil
        }
    }
    
    
    @objc func sio_play_random_pk(notification: Notification) {
        
//        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
//            
//        }
    }
    
    @objc func sendLivePkRequest(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            AppDelegate.sharedInstance.navigationController?.topViewController?.view.makeToast(message:(responseDict["message"] as? String ?? ""), duration: 1, position: HRToastActivityPositionDefault)
//            
//            if let  payload = responseDict["payload"] as? Dictionary<String, Any>{
//                
//            }
        }
    }
    
    
    @objc func sio_start_live_pk(notification: Notification) {
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
           // AppDelegate.sharedInstance.navigationController?.topViewController?.view.makeToast(message:(responseDict["message"] as? String ?? ""), duration: 1, position: HRToastActivityPositionDefault)
            
            if let  payload = responseDict["payload"] as? Dictionary<String, Any>{
                let pKRoomId = payload["PKRoomId"] as? String ?? ""
                let livePKId = payload["livePKId"] as? String ?? ""
                let pKBoxingglove = payload["pKBoxingglove"] as? String ?? ""
                
                self.waitingForOppenentVW.isHidden = true
                self.timerRandomPk?.invalidate()
                self.timerRandomPk = nil
                self.randomPkCounter = 0
                
                let deviceposition = cameraController.position
                self.cameraController.deepAR.pause()
                self.deepAR.pause()
                self.deepAR.shutdown()
                self.cameraController.deepAR.shutdown()
                self.deepAR = nil
                self.cameraController = nil
                
                if let broadCasterVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "BroadcasterViewController") as? BroadcasterViewController{
                    let arr = pKRoomId.components(separatedBy: ",").filter { $0 != Themes.sharedInstance.Getuser_id() }
                    broadCasterVC.joinerId = arr.last ?? ""
                    broadCasterVC.isPkNavigation = true
                    broadCasterVC.devicePosition =  deviceposition
                    broadCasterVC.filterIndex = self.filterIndex
                    broadCasterVC.torchEnabled =  self.btnFlashLightCam.isSelected
                    broadCasterVC.livePKId = livePKId
                    broadCasterVC.isGoLiveRandomPrevious = true
                    broadCasterVC.pKBoxingglove = pKBoxingglove

                    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                    self.navigationController?.pushViewController(broadCasterVC, animated: false)
                }
                
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
            if self.friendsArray.count == 0{
                AppDelegate.sharedInstance.navigationController?.topViewController?.view.makeToast(message:(responseDict["message"] as? String ?? ""), duration: 0.5, position: HRToastActivityPositionDefault)
                
                self.tblVwFriends.isHidden = true
                self.btnGoLive.isHidden  = false
            }else{
                self.btnGoLive.isHidden  = true
            }
            self.tblVwFriends.reloadData()
        }
    }
    
    
    @objc func timeSlotList(notification: Notification){
        
        if  let responseDict = notification.userInfo as? Dictionary<String, Any> {
            
            if let  payloadArr = responseDict["payload"] as? Array<Dictionary<String, Any>>{
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
    
    
    //MARK: UIButton Action Methods
    @IBAction func goLiveBtnAction(_ sender: Any) {
        
        guard  cameraController != nil else{
            return
        }
        
        let broadCasterVC:BroadcasterViewController = StoryBoard.letGo.instantiateViewController(withIdentifier: "BroadcasterViewController") as! BroadcasterViewController
        broadCasterVC.devicePosition =  cameraController.position
        broadCasterVC.torchEnabled =  self.btnFlashLightCam.isSelected
        broadCasterVC.filterIndex = self.filterIndex
        
        cameraController.deepAR.pause()
        deepAR.pause()
        deepAR.shutdown()
        cameraController.deepAR.shutdown()
        deepAR = nil
        cameraController = nil
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.pushView(broadCasterVC, animated: true)
    }
    
    @IBAction func btnCancelAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func flashLightBtnAction(){
        
        
        /*let currentCameraInput:AVCaptureInput = captureSession.inputs.first as! AVCaptureInput
         if let input = currentCameraInput as? AVCaptureDeviceInput {
         if input.device.position == .back {
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
         }*/
        
    }
    @IBAction func slicerValueChangedAction(sender: UISlider){
        /* if sender == sliderBeauty {
         session.beautyLevel = CGFloat(sender.value)
         }else {
         session.brightLevel = CGFloat(sender.value)
         }*/
        
    }
    
    @IBAction func rotateBtnAction(){
        
        if cameraController.position == .front {
            cameraController.position = .back
        }else {
            cameraController.position = .front
        }
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
    
    func  closeFilter() {
        viewFilters.isHidden = true
    }
    
    @IBAction func btnFriendsAction(){
        self.btnGoLive.isHidden = true
        self.getAllLivedFriendsList()
        self.tblVwFriends.isHidden = false
        self.tblVwFriends.reloadData()
        if friendsArray.count > 0 {
            self.btnGoLive.isHidden  = true
        }else {
            self.btnGoLive.isHidden  = false
        }
        
    }
    
    @IBAction func btnRandomAction(){
        self.btnGoLive.isHidden = false
        
        self.playRandomPk(pkTime: 2)
        self.waitingForOppenentVW.isHidden = false
        randomPkCounter = 0
        timerRandomPk?.invalidate()
        timerRandomPk = nil
        timerRandomPk = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerRandomPkHandlerPk(_:)), userInfo: nil, repeats: true)
    }
    
    @objc func timerRandomPkHandlerPk(_ timer: Timer) {
        
        if randomPkCounter < 30{
            randomPkCounter += 1
        }else{
            timerRandomPk?.invalidate()
            timerRandomPk = nil
            self.waitingForOppenentVW.isHidden = true
            self.leaveRandomPk()
            randomPkCounter = 0
        }
    }
    
}


extension GoLiveVC:UITableViewDelegate, UITableViewDataSource{
    
    //MARK: Tableview data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if tableView == tblVwTime{
            return timeArray.count
        }
        
        if tableView == tblVwFriends{
            return friendsArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if tableView == tblVwTime{
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
            
            cell.imgVwProfilePic.kf.setImage(with: URL(string: friendsArray[indexPath.row].profilePic), placeholder: PZImages.avatar)
            let name = friendsArray[indexPath.row].name.count>0 ? friendsArray[indexPath.row].name : friendsArray[indexPath.row].pickzonId
            cell.lblName.text = name
           
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
        
        if  tableView == tblVwFriends{
            self.bgVwTime.isHidden = false
            self.selectedFriendId = friendsArray[indexPath.row].userId
            tblVwFriends.isHidden = true
            
            
        }else{
            self.bgVwTime.isHidden = true
            sendLivePkRequest(userId: self.selectedFriendId, time: valueTimeIdArray[indexPath.row])
        }
    }
}


extension GoLiveVC:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
            return CGSize(width:100, height: 95)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  Constant.sharedinstance.arrFilterEffect.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        filterIndex = indexPath.item
        cvFilters.reloadData()
        self.addFilter()
    }
    
}



// MARK: - ARViewDelegate -

extension GoLiveVC: DeepARDelegate {
    func didFinishPreparingForVideoRecording() {
        NSLog("didFinishPreparingForVideoRecording!!!!!")
    }
    
    func didStartVideoRecording() {
        NSLog("didStartVideoRecording!!!!!")
    }
    
    func didFinishVideoRecording(_ videoFilePath: String!) {
        
    }
    
    func recordingFailedWithError(_ error: Error!) {}
    
    func didTakeScreenshot(_ screenshot: UIImage!) {
        
    }
    
    func didInitialize() {
        if (deepAR.videoRecordingWarmupEnabled) {
           // DispatchQueue.main.async { [self] in
                //                let width: Int32 = Int32(deepAR.renderingResolution.width)
                //                let height: Int32 =  Int32(deepAR.renderingResolution.height)
                //                deepAR.startVideoRecording(withOutputWidth: width, outputHeight: height)
           // }
        }
    }
    
    
    func didFinishShutdown (){
        NSLog("didFinishShutdown!!!!!")
    }
    
    func faceVisiblityDidChange(_ faceVisible: Bool) {}
}




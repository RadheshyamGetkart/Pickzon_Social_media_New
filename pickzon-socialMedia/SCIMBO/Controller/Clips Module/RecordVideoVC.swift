//
//  RecordVideoVC.swift
//  SCIMBO
//
//  Created by SachTech on 08/08/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import DKImagePickerController
import PhotosUI
import DeepAR
import AVKit


enum RecordingMode : String {
    case video
    case photo
    case lowQualityVideo
}


class RecordVideoVC: SwiftBaseViewController {
   
   
    private var buttonRecordingModePairs: [(UIButton, RecordingMode)] = []
    private var currentRecordingMode: RecordingMode! {
        didSet {
            updateRecordingModeAppearance()
        }
    }
    
    private var isRecordingInProcess: Bool = false
    @IBOutlet weak var cvFilters:UICollectionView!
    @IBOutlet weak var vwFilter:UIView!

    //Implementing Deep AR Effects
    var cameraController: CameraController!
    var filterIndex: Int = 0
    var deepAR: DeepAR!
    var arView: UIView!
    var deepARView:UIView?
    
    var hashTag = ""
    @IBOutlet weak var cameraUIView: UIView!
    @IBOutlet weak var timerProgress: UIViewX!
    @IBOutlet weak var btnFlipCamera: UIButton!
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var btnTimer: UIButton!
    @IBOutlet weak var btnGallery: UIButton!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var progresswidth: NSLayoutConstraint!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var captureBtn: UIButtonX!
    @IBOutlet weak var sliderValue: UILabel!
    @IBOutlet weak var capturePauseView: UIViewX!
    @IBOutlet weak var addSoundBtn: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var btnBack: UIButton!
    
    private var timer:Timer?
    var audioThumbUrl = ""
    var audioId = "0"
    var audioURL = ""
    var audioOriginalURL = ""
    var audioName = ""
    var audioLength = 0
    let step: Float = 2
    var totalTime = Int(Settings.sharedInstance.clipDurationCam)
    var timerValue : Int? = Int(Settings.sharedInstance.clipDurationCam)
    var progressWidth = CGFloat(0.0)
    var isCreateFeed = false
    
   
    var tempFilePath: NSURL = {
        let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let tempPath = documentsDirectory.appendingPathComponent("tempMovieClip.mp4").absoluteString
        
        if FileManager.default.fileExists(atPath: tempPath) {
            do {
                try FileManager.default.removeItem(atPath: tempPath)
            } catch { }
        }
        return NSURL(string: tempPath)!
    }()
    
    
    override var shouldAutorotate: Bool{
        return false
    }
   
   
    //MARK: Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print("UIViewController : RecordVideoVC")
        cameraController?.deepAR.shutdown()
        if deepAR == nil {
            
        }else{
            deepAR?.shutdown()
            deepAR = nil
            cameraController = nil
        }
        cameraAllowsAccessToApplicationCheck()
        self.setupDeepARAndCamera()
        PlayerHelper.shared.startAudio(url: audioURL)
        progressWidth = self.view.frame.width-30

        if audioName.isEmpty {
            addSoundBtn.setTitle("Add Sound", for: .normal)
        } else {
            addSoundBtn.setTitle(audioName, for: .normal)
        }
        
        //New mthods
        cvFilters.register(UINib(nibName: "FilterCVCell", bundle: nil), forCellWithReuseIdentifier: "FilterCVCell")
        vwFilter.isHidden = true
   
        if let val =  timerValue{
            totalTime = val
            sliderValue.text = "\(val) sec"
            slider.maximumValue = Float(val)
            slider.value = Float(val)
        }
    }
  
    
    deinit{
        cameraController?.deepAR.shutdown()
        if deepAR == nil {
            
        }else{
            deepAR?.shutdown()
            deepAR = nil
            cameraController = nil
        }
        PlayerHelper.shared.pausePlayer()
        
    }
    
    
    //MARK: New Methods
    func removeTempFile(){
        print(tempFilePath.path!)
        print(tempFilePath.absoluteString!)
        
        if FileManager.default.fileExists(atPath: tempFilePath.path ?? "") {
            do {
                
                try FileManager.default.removeItem(atPath: tempFilePath.path ?? "")
            } catch {
                print("Error:", error.localizedDescription)
            }
        }
    }
    
  
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        vwFilter.isHidden =  true
    }
    
    
    private func updateRecordingModeAppearance() {
        buttonRecordingModePairs.forEach { (button, recordingMode) in
            button.isSelected = recordingMode == currentRecordingMode
        }
    }
    
  
    func setupDeepARAndCamera() {
        self.deepAR = DeepAR()
        self.deepAR.delegate = self
        self.deepAR.setLicenseKey(Settings.sharedInstance.deepARLicenseKey)
        self.deepAR.videoRecordingWarmupEnabled = false
        cameraController = CameraController(deepAR: self.deepAR)
        if let deepARView = deepAR.createARView(withFrame: self.view.frame) {
            self.deepARView = deepARView
            self.deepARView?.frame = self.view.frame
            cameraUIView.addSubview( self.deepARView!)
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
    
    
    override func cameraAllowsAccessToApplicationCheck(){
        
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
    
    
    override func alertToEncourageCameraAccessWhenApplicationStarts(){
        
        AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: "Please enable Camera and Microphone.", buttonTitles: ["Cancel","Okay"], onController: self) { title, index in
            
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
    
    func checkMicPermission()  {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            print("Mic Permission granted", terminator: "")
            
           
            
        case AVAudioSession.RecordPermission.denied:
            self.alertToEncourageCameraAccessWhenApplicationStarts()
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    
                    
                } else {
                    self.alertToEncourageCameraAccessWhenApplicationStarts()
                }
            })
        default:
            break
        }
        
    }
    
    
    //MARK: UIButton Action Methods
    
    @IBAction func timeSlider(_ sender: Any) {
   
    }
    
    @IBAction func flashBtnAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.flashBtn.isSelected = !self.flashBtn.isSelected
            self.toggleFlash()
        }
    }
    
    @IBAction func timerDone(_ sender: Any) {
        timerView.isHidden = true
    }
    
    
    @IBAction func timerBtn(_ sender: Any) {
        timerView.isHidden = false
        self.timer?.invalidate()
    }
    
    func toggleFlash(){
        
        if cameraController.position == .front{
            self.view.makeToast(message: "Flash is not allowed when front camera is enabled." , duration: 3, position: HRToastActivityPositionDefault)
            return
        }
        
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
    }
    
    
    @IBAction func sliderChanged(_ sender: Any) {
        let a = sender as! UISlider
        let roundedValue = round(a.value / step) * step
        a.value = roundedValue
        sliderValue.text = "\(roundedValue) Sec."
        timerValue = Int(roundedValue)
    }
    
    
    
    func btnOpenGalleryConfirm() {
        let pickerController = DKImagePickerController()
        if isCreateFeed == true {
            pickerController.singleSelect = false
            pickerController.assetType = .allAssets
            pickerController.sourceType = .photo
            pickerController.maxSelectableCount = 5
        }else {
            pickerController.singleSelect = true
            pickerController.assetType = .allVideos
            pickerController.sourceType = .photo
        }
        
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            if self.isCreateFeed == true && assets.count > 0{
                 
                    
                    Themes.sharedInstance.activityView(View: self.view)
                    AssetHandler.sharedInstance.isgroup = false
                    
                    AssetHandler.sharedInstance.ProcessAsset(assets: assets,oppenentID: "",isFromStatus: false, completionHandler: { [weak self] (AssetArr, error) -> ()? in
                        if((AssetArr?.count)! > 0)
                        {     DispatchQueue.main.async {
                            Themes.sharedInstance.RemoveactivityView(View: (self?.view)!)
                            let EditVC = StoryBoard.main.instantiateViewController(withIdentifier: "EditViewControllerID") as! EditViewController
                            EditVC.AssetArr = AssetArr!
                            EditVC.isfromStatus = false
                            EditVC.isCreateFeed = true
                            //EditVC.Delegate = self
                           // EditVC.selectedAssets = (self?.selectedAssets)!
                            EditVC.selectedAssets = assets
                            EditVC.isgroup = false
                            //EditVC.to_id = self!.toChat
                            self?.pushView(EditVC, animated: true)
                        }
                        }
                        return ()
                    })
                
                
            }else if(assets.count > 0)
            {
                
                if  let duration = assets.first?.duration {
                    if duration > Settings.sharedInstance.clipDuration {
                        self.view.makeToast(message:"Video exceeds the size limit of \(Settings.sharedInstance.clipDuration) seconds.", duration: 3, position: HRToastActivityPositionDefault)
                        //return
                    }
                    
                    if duration < 3 {
                        self.view.makeToast(message:"Video length must be  at least 3 seconds duration.", duration: 3, position: HRToastActivityPositionDefault)
                        return
                    }
                }
                
                Themes.sharedInstance.activityView(View: self.view)
                AssetHandler.sharedInstance.isgroup = false
                AssetHandler.sharedInstance.ProcessAsset(assets: assets,oppenentID: "",isFromStatus: false, completionHandler: { [weak self] (AssetArr, error) -> ()? in
                    DispatchQueue.main.async {
                    Themes.sharedInstance.RemoveactivityView(View: self!.view)
                    }
                    if((AssetArr?.count)! > 0)
                    {
                        
                        DispatchQueue.main.async {
                            pickerController.dismiss(animated: true, completion: nil)
                            let _: EditVideoVC = (self?.customPresent(){
                                $0.ObjMultimedia = AssetArr?[0] as? MultimediaRecord ?? MultimediaRecord()
                                $0.audioID = self?.audioId ?? "0"
                                $0.audioLength = self?.audioLength ?? 0
                                $0.audioURL = self?.audioURL ?? ""
                                $0.delegateVideo = self
                                })!
                        }
                    }
                    return ()
                })
            }else {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
            }
        }
        self.present(pickerController, animated: true, completion: nil)
    }
    
    
    @IBAction func btnOpenGallery(_ sender: UIButton) {
        // Request permission to access photo library
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] (status) in
                DispatchQueue.main.async { [unowned self] in
                    switch status {
                    case .authorized:
                        self.btnOpenGalleryConfirm()
                    case .limited:
                        print("Limited access - show picker.")
                        self.btnOpenGalleryConfirm()
                    case .denied:
                        print("Access Denied")
                    case .notDetermined:
                        PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                            switch newStatus {
                            case .limited:
                                print("Limited access.")
                                break
                            case .authorized:
                                print("Full access.")
                            case .denied:
                                break
                            default:
                                break
                            }
                        }
                    default:
                        break
                    }
                }
            }
        } else {
            // Fallback on earlier versions
            PHPhotoLibrary.requestAuthorization { s in
                DispatchQueue.main.async {
                    if(s == .authorized) {
                        self.btnOpenGalleryConfirm()
                    }
                }
            }
        }
        
       
    }
        
    func startTimer(){
        totalTime = timerValue ?? 30
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    @objc func updateProgress(){
        
        if totalTime == 1
        {
            self.timer?.invalidate()
            self.videoTapped(self)
        }
        else
        {
            totalTime -= 1
            let a = progressWidth/(timerValue ?? 30)
            progresswidth.constant = progressWidth - a*CGFloat(totalTime)
        }
    }
    
   
    
    @IBAction func goBack(_ sender: Any) {
        
        AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to go back ?", buttonTitles: ["Yes","No"], onController: self) { title, index in
            if index == 0{
                
                self.cameraController?.deepAR.shutdown()
                if self.deepAR == nil {
                    
                }else{
                    self.deepAR?.shutdown()
                    self.deepAR = nil
                    self.cameraController = nil
                }
                PlayerHelper.shared.pausePlayer()
                
                self.navigationController?.popViewController(animated: true)

            }
        }
    }
    
    
    func rotateCameraAction(){
        
        if cameraController.position == .front {
            cameraController.position = .back
        }else {
            cameraController.position = .front
        }
    }
    

    
    @IBAction func filterBtnAction(){
        if Constant.sharedinstance.arrFilterEffect.count == 0 {
            self.getFilterListAPI()
        }else {
            vwFilter.isHidden = vwFilter.isHidden==true ? false : true
            cvFilters.reloadData()
        }
    }
    
    func  closeFilter() {
        vwFilter.isHidden = true
    }
    
    
    @IBAction func flipCamera(_ sender: Any) {
        
        rotateCameraAction()
    
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
 

  
    
    @IBAction func videoTapped(_ sender: Any) {
        
        
        didTapRecordActionButton()
    }
    
    
   
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        addSoundBtn.isEnabled = true
        btnFlipCamera.isEnabled = true
        btnTimer.isEnabled = true
        btnGallery.isEnabled = true
        
        if (error != nil)
        {
            print("Unable to save video to the iPhone  \(error?.localizedDescription ?? "error")")
        }else {
            print(outputFileURL)
            
            let a =   audioURL
            //let audioUrl = URL(string: a.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? "")
            let audioUrl = URL(fileURLWithPath: a)
            if audioURL.length > 0 {
                
                
             
                    self.mergeVideoAndAudio(videoUrl: outputFileURL, audioUrl: audioUrl) { error, url in
                        if url != nil {
                            DispatchQueue.main.async {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
                                vc.url = url
                                vc.onCancel = self
                                vc.onDone = self
                                vc.soundID = self.audioId
                                vc.fileName = "\(Int64(Date().timeIntervalSince1970))pickZone.mp4"
                                vc.modalPresentationStyle = .fullScreen
                                self.navigationController?.presentView(vc, animated: true)
                            }
                        }
                    }
            }else{
                
                DispatchQueue.main.async {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
                    vc.url = outputFileURL
                    vc.onCancel = self
                    vc.onDone = self
                    vc.soundID = "0"
                    vc.fileName = "\(Int64(Date().timeIntervalSince1970))pickZone.mp4"
                    vc.modalPresentationStyle = .fullScreen
                    self.navigationController?.presentView(vc, animated: true)
                }

            }
        }
    }
    
   
    
    @IBAction func addsoundBtn(_ sender: Any) {
        let viewController:SpotifyCategoriesVC = StoryBoard.spotify.instantiateViewController(withIdentifier: "SpotifyCategoriesVC") as! SpotifyCategoriesVC
        viewController.onSongSelection = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    func mergeFilesWithUrl(videoUrl:URL, audioUrl:URL,time:Int32)
    {
        let mixComposition : AVMutableComposition = AVMutableComposition()
        var mutableCompositionVideoTrack : [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack : [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        
        //start merge  
        
        let aVideoAsset : AVAsset = AVAsset(url: videoUrl)
        let aAudioAsset : AVAsset = AVAsset(url: audioUrl)
        
        mutableCompositionVideoTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        mutableCompositionAudioTrack.append( mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        
        let aVideoAssetTrack : AVAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaType.video)[0]
        //let aAudioAssetTrack : AVAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaType.audio)[0]
        
       
        if aAudioAsset.tracks(withMediaType: AVMediaType.audio).count > 0{
            let aAudioAssetTrack : AVAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaType.audio)[0]
            
        mutableCompositionVideoTrack.first?.preferredTransform = aVideoAssetTrack.preferredTransform
        
        do{
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: CMTime.zero)
            
            //In my case my audio file is longer then video file so i took videoAsset duration
            //instead of audioAsset duration
            
            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: CMTime.zero)
            
            
        }catch{
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            print("Exception ========\(error.localizedDescription)")
            return
        }
        
        totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero,duration: aVideoAssetTrack.timeRange.duration )
        
        let mutableVideoComposition : AVMutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: time)
        
        let savePathUrl : URL = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/\(Int64(Date().timeIntervalSince1970))pickZone.mp4")
        
        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = savePathUrl
        assetExport.shouldOptimizeForNetworkUse = true
        
        assetExport.exportAsynchronously { () -> Void in
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
            }
            
            print("assetExport.status: ", assetExport.status)
            switch assetExport.status {
            case AVAssetExportSession.Status.completed:
                print("Export Success")
                DispatchQueue.main.async {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
                    vc.url = savePathUrl
                    vc.onCancel = self
                    vc.onDone = self
                    vc.soundID = self.audioId
                   // vc.parentVC = self
                    vc.fileName = "\(Int64(Date().timeIntervalSince1970))pickZone.mp4"
                    vc.modalPresentationStyle = .fullScreen
                    self.navigationController?.presentView(vc, animated: true)
                }

                
            case  AVAssetExportSession.Status.failed:
                print("Export Failed")
                DispatchQueue.main.async {
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                    self.view.makeToast("Failed to save..")
                }
            case AVAssetExportSession.Status.cancelled:
                print("Export Cancelled")
                DispatchQueue.main.async {
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                    self.view.makeToast("Cancelled..")
                }
            default:
                print("complete")
            }
        }
        }else {
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                let message = "No Network Connection: Unable to save the video"
                self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
            }
        }
    }

    
    func mergeVideoAndAudio(videoUrl: URL,
                            audioUrl: URL,
                            shouldFlipHorizontally: Bool = false,
                            completion: @escaping (_ error: Error?, _ url: URL?) -> Void) {

        Themes.sharedInstance.activityView(View: self.view)

        
        let mixComposition = AVMutableComposition()
        var mutableCompositionVideoTrack = [AVMutableCompositionTrack]()
        var mutableCompositionAudioTrack = [AVMutableCompositionTrack]()
        var mutableCompositionAudioOfVideoTrack = [AVMutableCompositionTrack]()

        //start merge

        let aVideoAsset = AVAsset(url: videoUrl)
        let aAudioAsset = AVAsset(url: audioUrl)

        let compositionAddVideo = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                                       preferredTrackID: kCMPersistentTrackID_Invalid)
        
        
        let compositionAddAudio = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                 preferredTrackID: kCMPersistentTrackID_Invalid)!

        let compositionAddAudioOfVideo = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                            preferredTrackID: kCMPersistentTrackID_Invalid)

        let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaType.video)[0]
        let aAudioOfVideoAssetTrack: AVAssetTrack? = aVideoAsset.tracks(withMediaType: AVMediaType.audio).first
        let aAudioAssetTrack: AVAssetTrack? = aAudioAsset.tracks(withMediaType: AVMediaType.audio).first

        // Default must have tranformation
        compositionAddVideo?.preferredTransform = aVideoAssetTrack.preferredTransform

        if shouldFlipHorizontally {
            // Flip video horizontally
            var frontalTransform: CGAffineTransform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            frontalTransform = frontalTransform.translatedBy(x: -aVideoAssetTrack.naturalSize.width, y: 0.0)
            frontalTransform = frontalTransform.translatedBy(x: 0.0, y: -aVideoAssetTrack.naturalSize.width)
            compositionAddVideo?.preferredTransform = frontalTransform
        }

        mutableCompositionVideoTrack.append(compositionAddVideo!)
        mutableCompositionAudioTrack.append(compositionAddAudio)
        mutableCompositionAudioOfVideoTrack.append(compositionAddAudioOfVideo!)

        do {
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                                                                duration: aVideoAssetTrack.timeRange.duration),
                                                                of: aVideoAssetTrack,
                                                                at: CMTime.zero)

            //In my case my audio file is longer then video file so i took videoAsset duration
            //instead of audioAsset duration
            if let aAudioAssetTrack = aAudioAssetTrack {
                try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                                                                    duration: aVideoAssetTrack.timeRange.duration),
                                                                    of: aAudioAssetTrack,
                                                                    at: CMTime.zero)
            }

          /*  // adding audio (of the video if exists) asset to the final composition
            if let aAudioOfVideoAssetTrack = aAudioOfVideoAssetTrack {
                try mutableCompositionAudioOfVideoTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                                                                           duration: aVideoAssetTrack.timeRange.duration),
                                                                           of: aAudioOfVideoAssetTrack,
                                                                           at: CMTime.zero)
            }*/
        } catch {
            print(error.localizedDescription)
        }

        // Exporting
        //let savePathUrl: URL = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/newVideo.mp4")
        let savePathUrl : URL = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/\(Int64(Date().timeIntervalSince1970))pickZone.mp4")
        do { // delete old video
            try FileManager.default.removeItem(at: savePathUrl)
        } catch { print(error.localizedDescription) }

        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = savePathUrl
        assetExport.shouldOptimizeForNetworkUse = true

        assetExport.exportAsynchronously { () -> Void in
            switch assetExport.status {
            case AVAssetExportSession.Status.completed:
                print("success")
                completion(nil, savePathUrl)
            case AVAssetExportSession.Status.failed:
                print("failed \(assetExport.error?.localizedDescription ?? "error nil")")
                completion(assetExport.error, nil)
            case AVAssetExportSession.Status.cancelled:
                print("cancelled \(assetExport.error?.localizedDescription ?? "error nil")")
                completion(assetExport.error, nil)
            default:
                print("complete")
                completion(assetExport.error, nil)
            }
        }

    }
  
}

extension RecordVideoVC:onSongSelectionDelegate,onCancelClick,onDonePreviewClick,PostClipDelegate{
    
    //MARK: Clip Upload Delegate
    func onSuccessClipUpload(clipObj: WallPostModel, selectedIndex: Int) {
        
    }

   //MARK: Preview Delegate Methods
   
   func onDismiss() {
       DispatchQueue.main.async {
           Themes.sharedInstance.activityView(View: self.view)
           PlayerHelper.shared.startAudio(url: self.audioURL)
       }
       DispatchQueue.main.asyncAfter(deadline: .now()+3)
       {
           Themes.sharedInstance.RemoveactivityView(View: self.view)
       }
   }
   
   
   func onDone(soundID:String,url:URL,fileName:String){
       
     
       DispatchQueue.main.async {
           if let vc = StoryBoard.main.instantiateViewController(withIdentifier: "PostClipVC") as? PostClipVC {
               
               var soundInfo =  SoundInfo(dict: [:])
               soundInfo.id =  soundID
               soundInfo.thumb =  self.audioThumbUrl
               soundInfo.name =  self.audioName
               soundInfo.audio = self.audioOriginalURL
                vc.url = url
               //vc.fileName = fileName
               vc.clipObj = WallPostModel(dict: [:])
               vc.clipObj.soundInfo =  soundInfo
               vc.clipObj.payload = self.hashTag
               vc.delegate = self
               self.pushView(vc, animated: true)
               
               self.cameraController?.deepAR.shutdown()
               if self.deepAR == nil {
                   
               }else{
                   self.deepAR?.shutdown()
                   self.deepAR = nil
                   self.cameraController = nil
               }
           }
       }
   }
       
   //MARK: Song Selected Delegate Methods
   func onSelection(id: String, url: String,name:String, timeLimit: Int,thumbUrl:String,originalUrl:String) {
       audioId = id
       audioURL = url
       audioOriginalURL = originalUrl
       audioName = name
       self.audioLength = timeLimit
       audioThumbUrl = thumbUrl
       PlayerHelper.shared.startAudioWithLocalFile(url: url)
       self.timerValue = timeLimit
       
       totalTime = timeLimit
       
       DispatchQueue.main.async {
           self.addSoundBtn.setTitle(name, for: .normal)
           self.sliderValue.text = "\(timeLimit) sec"
           self.slider.maximumValue = Float(timeLimit)
           self.slider.value = Float(timeLimit)
       }
   }
   
}

extension RecordVideoVC: GalleryVideoDelegate{
   // func onVideoPicked(_ asset: AVAsset) {
    func onVideoPicked(_ asset: AVAsset, start:CGFloat ,endTime:CGFloat) {
        
        let savePathUrl : URL = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/\(Int64(Date().timeIntervalSince1970))pickZone.mp4")

         let assetExport: AVAssetExportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
         assetExport.outputFileType = AVFileType.mp4
         assetExport.outputURL = savePathUrl
         assetExport.shouldOptimizeForNetworkUse = true
        let timeRange = CMTimeRange(start: CMTime(seconds: Double(start), preferredTimescale: 1000), duration: CMTime(seconds: Double(endTime - start), preferredTimescale: 1000))
        assetExport.timeRange = timeRange
        
        Themes.sharedInstance.activityView(View: self.view)
        
         assetExport.exportAsynchronously { () -> Void in
             DispatchQueue.main.async {
                 Themes.sharedInstance.RemoveactivityView(View: self.view)
             }
             switch assetExport.status {
             case AVAssetExportSession.Status.completed:
                if self.audioURL.length == 0{
                    DispatchQueue.main.async {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
                        vc.url = savePathUrl
                        vc.onCancel = self
                        vc.onDone = self
                        vc.soundID = ""
                       // vc.parentVC = self
                        vc.fileName = "\(Int64(Date().timeIntervalSince1970))pickZone.mp4"
                        vc.modalPresentationStyle = .fullScreen
                        self.navigationController?.presentView(vc, animated: true)
                    }
                }else {
                    
                    let a =   self.audioURL
                    //let audioUrl = URL(string: a.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? "")
                    let audioUrl = URL(fileURLWithPath: self.audioURL)
                    if audioUrl != nil{
                        DispatchQueue.main.async {
                           /* //Check Network connection
                            if (UIApplication.shared.delegate as! AppDelegate).IsInternetconnected  == true{
                                Themes.sharedInstance.activityView(View: self.view)
                                self.mergeFilesWithUrl(videoUrl: savePathUrl, audioUrl: audioUrl, time: Int32(self.timerValue ?? 30))
                                
                            }else {
                                Themes.sharedInstance.RemoveactivityView(View: self.view)
                                let message = "No Network Connection: Unable to save the video"
                                //DispatchQueue.main.async {
                                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                                //}
                            }*/
                            
                           /* Themes.sharedInstance.activityView(View: self.view)
                            self.mergeFilesWithUrl(videoUrl: savePathUrl, audioUrl: audioUrl, time: Int32(self.timerValue ?? 30))
                            */
                            
                            self.mergeVideoAndAudio(videoUrl: savePathUrl, audioUrl: audioUrl) { error, url in
                                if url != nil {
                                    DispatchQueue.main.async {
                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
                                        vc.url = url
                                        vc.onCancel = self
                                        vc.onDone = self
                                        vc.soundID = self.audioId
                                        vc.fileName = "\(Int64(Date().timeIntervalSince1970))pickZone.mp4"
                                        vc.modalPresentationStyle = .fullScreen
                                        self.navigationController?.presentView(vc, animated: true)
                                    }
                                    
                                }
                            }
                            
                        }
                        
                    }
                    
                }


             case  AVAssetExportSession.Status.failed:
                 DispatchQueue.main.async {
                     Themes.sharedInstance.RemoveactivityView(View: self.view)
                     self.view.makeToast("Failed to save..")
                 }
             case AVAssetExportSession.Status.cancelled:
                 DispatchQueue.main.async {
                     Themes.sharedInstance.RemoveactivityView(View: self.view)
                     self.view.makeToast("Cancelled..")
                 }
             default:
                 print("complete")
             }
         }
    }
}


extension RecordVideoVC{
    
    @objc
    private func didTapRecordActionButton() {
        currentRecordingMode = .video

        if (isRecordingInProcess) {
            deepAR.finishVideoRecording()
            isRecordingInProcess = false
            addSoundBtn.isEnabled = true
            btnFlipCamera.isEnabled = true
            btnTimer.isEnabled = true
            btnGallery.isEnabled = true
            btnBack.isEnabled = true
            btnFilter.isEnabled = true

            self.timer?.invalidate()
            self.totalTime = 0
            self.progresswidth.constant = 0.0
            //self.timerProgress.setProgress(0, animated: false)
            PlayerHelper.shared.pausePlayer()
            captureBtn.backgroundColor = .systemRed
            Themes.sharedInstance.activityView(View: self.view)
            return
        }
        
        addSoundBtn.isEnabled = false
        btnFlipCamera.isEnabled = false
        btnTimer.isEnabled = false
        btnGallery.isEnabled = false
        btnBack.isEnabled = false
        btnFilter.isEnabled = false
        
        DispatchQueue.main.async { [weak self] in
            self?.startTimer()
        }
        
        if audioURL.length > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.10)
            {
                PlayerHelper.shared.startAudioWithLocalFile(url: self.audioURL)
                PlayerHelper.shared.playPlayer()
            }
        }
        
       
        
        captureBtn.backgroundColor = .clear
//      removeTempFile()
                
        let width: Int32 = Int32(deepAR.renderingResolution.width)
        let height: Int32 =  Int32(deepAR.renderingResolution.height)
        
        if (currentRecordingMode == RecordingMode.video) {
            if(deepAR.videoRecordingWarmupEnabled) {
                deepAR.resumeVideoRecording()
            } else {
                deepAR.startVideoRecording(withOutputWidth: width, outputHeight: height)
            }
            deepAR.delegate = self
            isRecordingInProcess = true
            return
        }
        
        if (currentRecordingMode == RecordingMode.lowQualityVideo) {
            if(deepAR.videoRecordingWarmupEnabled) {
                NSLog("Can't change video recording settings when video recording warmap enabled")
                return
            }
            let videoQuality = 0.1
            let bitrate =  1250000
            let videoSettings:[AnyHashable : AnyObject] = [
                AVVideoQualityKey : (videoQuality as AnyObject),
                AVVideoAverageBitRateKey : (bitrate as AnyObject)
            ]
            
            let frame = CGRect(x: 0, y: 0, width: 1, height: 1)
            
            deepAR.startVideoRecording(withOutputWidth: width, outputHeight: height, subframe: frame, videoCompressionProperties: videoSettings, recordAudio: true)
            isRecordingInProcess = true
        }
        
    }
    
}

// MARK: - ARViewDelegate -

extension RecordVideoVC: DeepARDelegate {
  
    func didFinishPreparingForVideoRecording() {
        NSLog("didFinishPreparingForVideoRecording!!!!!")
    }
    
    func didStartVideoRecording() {
        NSLog("didStartVideoRecording!!!!!")

    }
    
    func didFinishVideoRecording(_ videoFilePath: String!) {
        

        NSLog("didFinishVideoRecording!!!!!")
       
        removeTempFile()

        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let components = videoFilePath.components(separatedBy: "/")
        guard let last = components.last else { return }
        let destination = URL(fileURLWithPath: String(format: "%@/%@", documentsDirectory, last))
    
        
        Themes.sharedInstance.RemoveactivityView(View: self.view)
        let asset = AVAsset(url: destination)
        let seconds = CMTimeGetSeconds(asset.duration)
        if seconds < 3.0 {
            
            let alert = UIAlertController(title: "PickZon", message: "Video length must be  at least 3 seconds duration.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                }))
                self.present(alert, animated: true, completion: nil)
            
            return
            
        }else if self.audioURL.length == 0{
                   
           
           /* DispatchQueue.main.async {
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.navigationBar.backgroundColor = UIColor.clear

            
            
            let objVideo = YPMediaVideo(thumbnail: thumbnailFromVideoPath(destination),
                                        videoURL: destination,
                                        fromCamera: true)
            objVideo.originalUrl = destination
            
            let videoFiltersVC = YPVideoFiltersVC.initWith(video: objVideo,
                                                           isFromSelectionVC: true)
            videoFiltersVC.coverBottomItem.isHidden(value: false)
            videoFiltersVC.didSave = { [weak self] outputMedia in
                self?.navigationController?.navigationBar.isHidden = true
                print(outputMedia)
                switch(outputMedia){
                case .video(let video):
                    print(video.url)
                        let fileName = "\(Int64(Date().timeIntervalSince1970))pickZone.mp4"
                        self?.onDone(soundID:"", url:video.url, fileName:fileName)
                    
                    case .photo(p: let p):
                        print("Photo")
                    }
                }
                videoFiltersVC.didCancel = { [weak self] in
                    self?.navigationController?.navigationBar.isHidden = true
                    videoFiltersVC.navigationController?.popViewController(animated: true)
                }
                self.navigationController?.pushViewController(videoFiltersVC, animated: true)
                
            }
            */
            
            
            DispatchQueue.main.async {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
                vc.url = destination
                vc.onCancel = self
                vc.onDone = self
                vc.soundID = ""
               // vc.parentVC = self
                vc.fileName = "\(Int64(Date().timeIntervalSince1970))pickZone.mp4"
                vc.modalPresentationStyle = .fullScreen
             self.navigationController?.presentView(vc, animated: true)
             
            }
        }else {
            
          //  let a =   self.audioURL
            //let audioUrl = URL(string: a.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? "")
            let audioUrl = URL(fileURLWithPath: self.audioURL)
            if audioUrl != nil{
                DispatchQueue.main.async {
                 
                    self.mergeVideoAndAudio(videoUrl: destination, audioUrl: audioUrl) { error, url in
                        DispatchQueue.main.async {
                            Themes.sharedInstance.RemoveactivityView(View: self.view)
                        }
                        if url != nil {
                            DispatchQueue.main.async {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
                                vc.url = url
                                vc.onCancel = self
                                vc.onDone = self
                                vc.soundID = self.audioId
                               // vc.parentVC = self
                                vc.fileName = "\(Int64(Date().timeIntervalSince1970))pickZone.mp4"
                                vc.modalPresentationStyle = .fullScreen
                                self.navigationController?.presentView(vc, animated: true)
                            }
                            
                        }else {
                            let alert = UIAlertController(title: "PickZon", message: "Video could not be generated using selected audio file.", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                                }))
                                self.present(alert, animated: true, completion: nil)
                            
                            return
                        }
                    }
                    
                }
                
            }
            
        }
    }
    
    
    func recordingFailedWithError(_ error: Error!) {
        Themes.sharedInstance.RemoveactivityView(View: self.view)

    }
    
    func didTakeScreenshot(_ screenshot: UIImage!) {
        UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil)
        
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
        }
    }
    
    func didInitialize() {
        if (deepAR.videoRecordingWarmupEnabled) {
            DispatchQueue.main.async { [self] in
                let width: Int32 = Int32(deepAR.renderingResolution.width)
                let height: Int32 =  Int32(deepAR.renderingResolution.height)
                deepAR.startVideoRecording(withOutputWidth: width, outputHeight: height)
            }
        }
    }
 
    func didFinishShutdown (){
        NSLog("didFinishShutdown!!!!!")
    }
    
    func faceVisiblityDidChange(_ faceVisible: Bool) {}
}


extension RecordVideoVC:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    //MARK: APi Methods
    func getFilterListAPI(){
       
            Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)

        
        URLhandler.sharedinstance.makeGetAPICall(url:Constant.sharedinstance.getFiltersURL, param: NSMutableDictionary(), completionHandler: {(responseObject, error) ->  () in
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
                           
                            Constant.sharedinstance.arrFilterEffect.append(FilterEffects(dict: obj as! Dictionary<String,Any>))
                        }
                        self.vwFilter.isHidden = false
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
    
    //MARK: UICollectionview Delegate & Datasource methods
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

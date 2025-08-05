//
//  YPVideoVC.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 27/10/16.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit

//internal class YPVideoCaptureVC: UIViewController, YPPermissionCheckable {

 class YPVideoCaptureVC: UIViewController, YPPermissionCheckable {

    var didCaptureVideo: ((URL) -> Void)?
    
    public var videoHelper = YPVideoCaptureHelper()
     public let v = YPCameraView(overlayView: nil)
    private var viewState = ViewState()
     
     //var audioURL = ""
     
     /*var audioThumbUrl = ""
     var audioId = "0"
     
     var audioOriginalURL = ""
     var audioName = ""
     var audioLength = 0
     */

    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    required init() {
        super.init(nibName: nil, bundle: nil)
       
        title = YPConfig.wordings.videoTitle
        videoHelper.didCaptureVideo = { [weak self] videoURL in
            
            self?.didCaptureVideo?(videoURL)
            self?.resetVisualState()
        }
        videoHelper.videoRecordingProgress = { [weak self] progress, timeElapsed in
            self?.updateState {
                $0.progress = progress
                $0.timeElapsed = timeElapsed
            }
        }
    }
    
  
    // MARK: - View LifeCycle
    
    override func loadView() { view = v }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        v.timeElapsedLabel.isHidden = false // Show the time elapsed label since we're in the video screen.
     
        setupButtons()
        linkButtons()
        
        // Focus
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(focusTapped(_:)))
        v.previewViewContainer.addGestureRecognizer(tapRecognizer)
        
        // Zoom
        let pinchRecongizer = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(_:)))
        v.previewViewContainer.addGestureRecognizer(pinchRecongizer)
        
        initializeFilterView()
        

        
    }
     
     override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         v.addSongButton.isHidden(value: false)
     }
     
     override func viewDidDisappear(_ animated: Bool) {
         if  videoHelper.deepAR == nil {
             
         }else{
             videoHelper.deepAR?.shutdown()
             //             videoHelper.deepAR = nil
             //             videoHelper.cameraController = nil
         }
     }
     
     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         
         if  videoHelper.deepAR == nil {
             
         }else{
             videoHelper.deepAR?.shutdown()
             //             videoHelper.deepAR = nil
             //             videoHelper.cameraController = nil
         }
         videoHelper.removeLoader()
         
         if AppDelegate.sharedInstance.soundInfoSelected.audioLocalURL.length > 0 {
             PlayerHelper.shared.pausePlayer()
         }
      
     }
    
     deinit{
         videoHelper.cameraController?.deepAR.shutdown()
         if  videoHelper.deepAR == nil {
             
         }else{
             videoHelper.deepAR?.shutdown()
//             videoHelper.deepAR = nil
//             videoHelper.cameraController = nil
         }
         
         self.v.shotButton.isHidden = false
         self.v.filterBgview.isHidden = true
         
     }
     
     
    func initializeFilterView(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 88, height: 94)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        v.filterCollectionView.collectionViewLayout = layout
        v.filterCollectionView.delegate = self
        v.filterCollectionView.dataSource = self
        v.filterCollectionView.register(UINib(nibName: "FilterCVCell", bundle: nil), forCellWithReuseIdentifier: "FilterCVCell")
        v.filterBgview.isHidden = true

    }

    func start() {
            
//        self.videoHelper.cameraController.startCamera()
            if  self.videoHelper.deepAR == nil {
                
            }else{
               /* self.videoHelper.deepAR?.shutdown()*/
              //  self.videoHelper.deepAR = nil
               // self.videoHelper.cameraController = nil
                
                self.videoHelper.deepAR?.resume()
            }
        
        self.videoHelper.start(previewView: v.previewViewContainer,
                               withVideoRecordingLimit: YPConfig.video.recordingTimeLimit) { [weak self] in
            DispatchQueue.main.async {
                self?.refreshState()
            }
        }
    }
    
    func refreshState() {
        // Init view state with video helper's state
        updateState {
            $0.isRecording = self.videoHelper.isRecording
            $0.flashMode = self.flashModeFrom(videoHelper: self.videoHelper)
        }
    }
    
    // MARK: - Setup
    
    private func setupButtons() {
        v.flashButton.setImage(YPConfig.icons.flashOffIcon, for: .normal)
        v.flipButton.setImage(YPConfig.icons.loopIcon, for: .normal)
        v.shotButton.setImage(YPConfig.icons.captureVideoImage, for: .normal)
        v.filterButton.setImage(YPConfig.icons.filterImage, for: .normal)
        if AppDelegate.sharedInstance.soundInfoSelected.name.length > 0 {
            v.addSongButton.setTitle(AppDelegate.sharedInstance.soundInfoSelected.name, for: .normal)
        }else {
            v.addSongButton.setTitle("Add Song", for: .normal)
        }
    }
    
    private func linkButtons() {
        v.flashButton.addTarget(self, action: #selector(flashButtonTapped), for: .touchUpInside)
        v.shotButton.addTarget(self, action: #selector(shotButtonTapped), for: .touchUpInside)
        v.flipButton.addTarget(self, action: #selector(flipButtonTapped), for: .touchUpInside)
        v.filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        v.addSongButton.addTarget(self, action: #selector(addSongButtonTapped), for: .touchUpInside)
    }
    
    
  private  func getFilterListAPI(){
       
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
                        self.v.filterBgview.isHidden = false
                        self.v.shotButton.isHidden = true
                        self.v.filterCollectionView.reloadData()
                    }
                    
                } else  {
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                    
                }
                
                
            }
        })
        
    }
    
    // MARK: - Flip Camera
    
    
    @objc
    func filterButtonTapped() {
        print("filterButtonTapped")
        
        if Constant.sharedinstance.arrFilterEffect.count == 0 {
            self.getFilterListAPI()
            
        }else {
            v.filterBgview.isHidden = v.filterBgview.isHidden==true ? false : true
            v.filterCollectionView.reloadData()
        }
        
        if  v.filterBgview.isHidden == true {
            self.v.shotButton.isHidden = false
        }else{
            self.v.shotButton.isHidden = true
        }
    }
     
     
     
    @objc
    func flipButtonTapped() {
        videoHelper.flipCamera {
            self.updateState {
                $0.flashMode = self.flashModeFrom(videoHelper: self.videoHelper)
            }
        }
    }
    
     
    // MARK: - Toggle Flash
    
    @objc
    func flashButtonTapped() {
        videoHelper.toggleTorch()
        updateState {
            $0.flashMode = self.flashModeFrom(videoHelper: self.videoHelper)
        }
    }
    
    // MARK: - Toggle Recording
    
    @objc
    func shotButtonTapped() {
        doAfterCameraPermissionCheck { [weak self] in
            self?.toggleRecording()
        }
    }
    
    private func toggleRecording() {
        videoHelper.isRecording ? stopRecording() : startRecording()
    }
    
    private func startRecording() {
        // Stop the screen from going to sleep while recording video
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        
        videoHelper.startRecording()
        
        if AppDelegate.sharedInstance.soundInfoSelected.audioLocalURL.length > 0 {
            //DispatchQueue.main.asyncAfter(deadline: .now()+0.10)
            //{
                PlayerHelper.shared.startAudioWithLocalFile(url: AppDelegate.sharedInstance.soundInfoSelected.audioLocalURL)
                PlayerHelper.shared.playPlayer()
            //}
        }
        
        updateState {
            $0.isRecording = true
        }
    }
    
    private func stopRecording() {
        // Reset screen always on to false since the need no longer exists
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        
        videoHelper.stopRecording()
        if AppDelegate.sharedInstance.soundInfoSelected.audioLocalURL.length > 0 {
            PlayerHelper.shared.pausePlayer()
        }
        
        updateState {
            $0.isRecording = false
        }
    }

    public func stopCamera() {
        videoHelper.stopCamera()
        videoHelper.isVideoRecording = false
        videoHelper.deepAR?.pauseVideoRecording()
        videoHelper.timer.invalidate()
        self.resetVisualState()
        
        if AppDelegate.sharedInstance.soundInfoSelected.audioLocalURL.length > 0 {
            PlayerHelper.shared.pausePlayer()
        }
        
    }
    
    // MARK: - Focus
    
    @objc
    func focusTapped(_ recognizer: UITapGestureRecognizer) {
        
        self.v.filterBgview.isHidden = true
        self.v.shotButton.isHidden = false
        
        let point = recognizer.location(in: v.previewViewContainer)
        let viewsize = v.previewViewContainer.bounds.size
        let newPoint = CGPoint(x: point.x/viewsize.width, y: point.y/viewsize.height)
        videoHelper.focus(onPoint: newPoint)
        v.focusView.center = point
        YPHelper.configureFocusView(v.focusView)
        v.addSubview(v.focusView)
        YPHelper.animateFocusView(v.focusView)
    }
    
    // MARK: - Zoom
    
    @objc
    func pinch(_ recognizer: UIPinchGestureRecognizer) {
        self.zoom(recognizer: recognizer)
    }
    
    func zoom(recognizer: UIPinchGestureRecognizer) {
        videoHelper.zoom(began: recognizer.state == .began, scale: recognizer.scale)
    }
    
    // MARK: - UI State
    
    enum FlashMode {
        case noFlash
        case off
        case on
        case auto
    }
    
    struct ViewState {
        var isRecording = false
        var flashMode = FlashMode.noFlash
        var progress: Float = 0
        var timeElapsed: TimeInterval = 0
    }
    
    private func updateState(block: (inout ViewState) -> Void) {
        block(&viewState)
        updateUIWith(state: viewState)
    }
    
    private func updateUIWith(state: ViewState) {
        func flashImage(for torchMode: FlashMode) -> UIImage {
            switch torchMode {
            case .noFlash: return UIImage()
            case .on: return YPConfig.icons.flashOnIcon
            case .off: return YPConfig.icons.flashOffIcon
            case .auto: return YPConfig.icons.flashAutoIcon
            }
        }
        v.flashButton.setImage(flashImage(for: state.flashMode), for: .normal)
        v.flashButton.isEnabled = !state.isRecording
        v.flashButton.isHidden = state.flashMode == .noFlash
        v.shotButton.setImage(state.isRecording ? YPConfig.icons.captureVideoOnImage : YPConfig.icons.captureVideoImage,
                              for: .normal)
        v.flipButton.isEnabled = !state.isRecording
        v.progressBar.progress = state.progress
        v.timeElapsedLabel.text = YPHelper.formattedStrigFrom(state.timeElapsed)
        
        // Animate progress bar changes.
        UIView.animate(withDuration: 1, animations: v.progressBar.layoutIfNeeded)
    }
    
    private func resetVisualState() {
        updateState {
            $0.isRecording = self.videoHelper.isRecording
            $0.flashMode = self.flashModeFrom(videoHelper: self.videoHelper)
            $0.progress = 0
            $0.timeElapsed = 0
        }
    }
    
    private func flashModeFrom(videoHelper: YPVideoCaptureHelper) -> FlashMode {
        if videoHelper.hasTorch() {
            switch videoHelper.currentTorchMode() {
            case .off: return .off
            case .on: return .on
            case .auto: return .auto
            @unknown default:
                ypLog("unknown default reached. Check code.")
                return .noFlash
            }
        } else {
            return .noFlash
        }
    }
}



extension YPVideoCaptureVC:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
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
        if v.filterIndex == indexPath.row {
            cell.lblTitle.textColor = .label
        }else {
            cell.lblTitle.textColor = UIColor.lightGray
        }
        
        cell.imgImage.kf.setImage(with: URL(string: objFilter.icon), placeholder: nil, options:nil, progressBlock: nil, completionHandler: { (resp) in
         })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        v.filterIndex = indexPath.item
        v.filterCollectionView.reloadData()
        self.addFilter()
    }
    
    func addFilter() {
        if v.filterIndex == 0 {
            videoHelper.deepAR?.switchEffect(withSlot: "effect", path: nil)
        }else {
            let obj = Constant.sharedinstance.arrFilterEffect[v.filterIndex]
            let url = URL(string: obj.url)
            Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
            DownloadHandler.loadFileAsync(url: url!) { (path, error) in
                DispatchQueue.main.async {
                     Themes.sharedInstance.RemoveactivityView(View: self.view)
                }
                if error == nil {
                    print("File downloaded to : \(path!)")
                    self.videoHelper.deepAR?.switchEffect(withSlot: "effect", path: path)
                }
            }
        }
    }
    
}

extension YPVideoCaptureVC: onSongSelectionDelegate {
    @objc func addSongButtonTapped() {
        print("addSongButtonTapped")
        let viewController:SpotifyCategoriesVC = StoryBoard.spotify.instantiateViewController(withIdentifier: "SpotifyCategoriesVC") as! SpotifyCategoriesVC
        viewController.onSongSelection = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    //MARK: Song Selected Delegate Methods
    func onSelection(id: String, url: String,name:String, timeLimit: Int,thumbUrl:String,originalUrl:String) {
        /*audioId = id
        audioURL = url
        audioOriginalURL = originalUrl
        audioName = name
        self.audioLength = timeLimit
        audioThumbUrl = thumbUrl
        */
        
        
        //self.timerValue = timeLimit
       // totalTime = timeLimit
        
        AppDelegate.sharedInstance.soundInfoSelected = SoundInfo(dict: [:])
        AppDelegate.sharedInstance.soundInfoSelected.id = id
        AppDelegate.sharedInstance.soundInfoSelected.name = name
        AppDelegate.sharedInstance.soundInfoSelected.audio = originalUrl
        AppDelegate.sharedInstance.soundInfoSelected.thumb = thumbUrl
        AppDelegate.sharedInstance.soundInfoSelected.audioLocalURL = url
        
        PlayerHelper.shared.startAudioWithLocalFile(url: AppDelegate.sharedInstance.soundInfoSelected.audioLocalURL)
        
        
        DispatchQueue.main.async {
            self.v.addSongButton.setTitle(name, for: .normal)
        }
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

//
//  StoryViewController.swift
//  SCIMBO
//
//  Created by Getkart on 04/08/21.
//  Copyright © 2021 Radheshyam Yadav. All rights reserved.
//

import UIKit
import AVKit
import ContentSheet
import Photos
import MMMaterialDesignSpinner
import CoreGraphics
import Kingfisher
import OnlyPictures
import IQKeyboardManager
import MarqueeLabel
import IHKeyboardAvoiding

protocol StoryViewControllerDelegate : AnyObject {
    func currentStoryEnded()
    func backButtonClicked()
    func didClickDelete(_ messageFrame :  WallStatus.StoryStaus)
    func didClickViewStatusUsers(statusId:String)
    func previewPreviousStory()
}


class StoryViewController:  UIViewController,SegmentedProgressBarDelegate, ContentSheetDelegate, UIScrollViewDelegate{
  
    @IBOutlet weak var lblMarquee: MarqueeLabel!
    @IBOutlet weak var imgVwSong: UIImageView!
    @IBOutlet weak var btnRepostYourTag: UIButton!
    @IBOutlet weak var bgVwSongName: UIView!
    @IBOutlet weak var onlyPictures: OnlyHorizontalPictures!
    @IBOutlet weak var textStatusLabel: UILabel!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var statusReplayView: UIView!
    @IBOutlet weak var blureView: WaveEmitterView!
    @IBOutlet weak var CaptionLbl: ExpandableLabel!
    @IBOutlet weak var CaptionView: UIView!
    @IBOutlet weak var CaptionViewline: UIView!
    @IBOutlet weak var bottomViewbottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var currentUserName: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView:UIView!
    @IBOutlet weak var swipeUpbutton:UIButton!
    @IBOutlet weak var blurImageView:UIImageView!
    @IBOutlet weak var imgVwCelebrity:UIImageView!
    @IBOutlet weak var replyLbl: UILabel!
   // @IBOutlet weak var btnProfilePic: UIButtonX!
    @IBOutlet weak var profileImgView:ImageWithFrameImgView!

    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgViewCount:UIView!
    @IBOutlet weak var viewBackTxtMSG:UIView!
    @IBOutlet weak var cnstrnt_HtViewCount:NSLayoutConstraint!
    @IBOutlet weak var scrollVwTxtFd:TPKeyboardAvoidingScrollView!
    @IBOutlet weak var cnstrnt_TableBottom:NSLayoutConstraint!
     var progressBar: SegmentedProgressBar!

    private let viewImgs = UIView()
    private let scrollView = UIScrollView()
    private let statusImgView = UIImageView()
    private let statusGifView = UIImageView()
   
    private var timeObserver : Any?
    private var playerLayerReadyForDisplayObservation: NSKeyValueObservation?
    
    private var isAppInForeground = true
    private var isViewDisplayed = false
    private var isDisplayedForFirstTime = true
    var isMyStatus = false
    private var fromBottomView = false
    private var initialFrame: CGRect?
    private var initialTouchPoint: CGPoint?
    weak var delegate: StoryViewControllerDelegate?
    var startIndex : Int = Int()
    var isFromView : Bool = Bool()
    var spinnerView:MMMaterialDesignSpinner=MMMaterialDesignSpinner()
    var spinner:UIView=UIView()
    
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = { [unowned self] in
        let gesture = UIPanGestureRecognizer()
        gesture.addTarget(self, action: #selector(panGestureRecognizerHandler(_:)))
        return gesture
        }()
    
    var videoView: VideoPlayerView = VideoPlayerView()
    var wallStatusObj = WallStatus(responseDict: NSDictionary())


    //MARK: Controller Life cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        topViewHeightConstraint.constant = (UIDevice().hasNotch) ? 105 : 75
        backButton.setImageTintColor(UIColor.white)
        self.CaptionLbl.isUserInteractionEnabled = false
        self.imgVwSong.layer.cornerRadius = 5.0
        self.imgVwSong.clipsToBounds = true
        
        profileImgView.initializeView()
        addNotificationListener()
        self.view.backgroundColor = UIColor.black
        messageTextField.placeholder = "Comment"
                
        viewImgs.frame = view.bounds
        viewImgs.backgroundColor = UIColor.clear
        
        scrollView.frame = view.bounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        
        statusImgView.frame = view.bounds
        statusImgView.contentMode = .scaleAspectFit
        statusImgView.frame.center = scrollView.frame.center
        scrollView.addSubview(statusImgView)
        
        viewImgs.addSubview(scrollView)
        
        statusGifView.frame = view.bounds
        statusGifView.contentMode = .scaleAspectFit
        statusGifView.isHidden = true
        viewImgs.addSubview(statusGifView)
        view.addSubview(viewImgs)
        
        spinner.frame = CGRect(x: statusImgView.center.x - 30, y: statusImgView.center.y - 30, width: 60, height: 60)
        spinner.backgroundColor = UIColor(red: 242/255, green: 241/255, blue: 237/255, alpha: 1.0);
        spinner.layer.masksToBounds = true
        spinner.layer.cornerRadius = spinner.frame.width / 2
        spinnerView.frame=CGRect(x: 2.5, y: 2.5, width: 55, height: 55)
        spinnerView.lineWidth = 2.5;
        spinnerView.tintColor = UIColor(red: 90/255, green: 88/255, blue: 85/255, alpha: 1.0);
        spinnerView.startAnimating()
        spinner.addSubview(spinnerView)
        viewImgs.addSubview(spinner)
        spinner.isHidden = true
       
        self.initializeHorizontalPhoto()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewDidTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(viewDidPressed(_:)))
        self.view.addGestureRecognizer(longGesture)
        
        var durationArr = [TimeInterval]()
        self.wallStatusObj.statusArray.forEach { message in
            if checkMediaTypes(strUrl: message.media) == 1{
                durationArr.append(TimeInterval(5))
            }else{
                if message.durationTime ?? 0.0 < 1{
                    durationArr.append(TimeInterval(5))
                }else{
                    durationArr.append(TimeInterval(message.durationTime ?? 0.0))
                }
            }
        }
        
        progressBar = SegmentedProgressBar(numberOfSegments: self.wallStatusObj.statusArray.count, duration: durationArr)
        
        if UIDevice().hasNotch{
            progressBar.frame = CGRect(x: 15, y: 48, width: view.frame.width - 30, height: 4)
        } else {
            progressBar.frame = CGRect(x: 15, y: 15, width: view.frame.width - 30, height: 4)
        }
        progressBar.delegate = self
        progressBar.topColor = UIColor.white
        progressBar.bottomColor = UIColor.white.withAlphaComponent(0.25)
        progressBar.padding = 2
        view.addSubview(progressBar)
        
        let blureTapGesture = UITapGestureRecognizer(target: self, action: #selector(blurGestureTapped(_:)))
        blureTapGesture.numberOfTapsRequired = 1
        blureView.addGestureRecognizer(blureTapGesture)
        
        bottomView.addGestureRecognizer(panGestureRecognizer)
        setupView()
        if(isFromView)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.replayViewShower()
            })
        }
        bgViewCount.isHidden = true
        if(Themes.sharedInstance.Getuser_id() == self.wallStatusObj.userInfo?.id)
        {
            self.view.bringSubviewToFront(bgViewCount)
            bgViewCount.isHidden = false
            bottomView.isHidden = true
            self.onlyPictures.reloadData()
        }
        
        lblMarquee.type = .continuous
        lblMarquee.speed = .duration(5.0)
        lblMarquee.animationCurve = .easeInOut
        lblMarquee.fadeLength = 10.0
        lblMarquee.leadingBuffer = 5.0
        lblMarquee.trailingBuffer = 20.0
        
        self.btnRepostYourTag.layer.cornerRadius = btnRepostYourTag.frame.size.height/2.0
        btnRepostYourTag.layer.borderColor = CustomColor.sharedInstance.newThemeColor.cgColor
        btnRepostYourTag.layer.borderWidth = 1.5
        btnRepostYourTag.clipsToBounds = true
        self.CaptionLbl.textAlignment = .center
        
        self.profileImgView?.imgVwProfile?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                      action:#selector(self
                                                                        .handleProfilePicTap(_:))))
        
        
        self.view.insertSubview(videoView, belowSubview: self.topView)

    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("UIViewController: StoryViewController")
//        if !fromBottomView{
//            viewIsDisplayed()
//        }
        self.viewIsDisplayed()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().keyboardDistanceFromTextField = (UIDevice().hasNotch)  ? 0 : 5

        if !fromBottomView{
            initialFrame = bottomView.frame
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 10

        DispatchQueue.main.async {
            self.progressBar.isPaused = true
            self.videoView.player?.pause()
            
            self.deallocPlayer()
            self.removeNotificationListener()
            
            
            self.blureView.isHidden = true
            self.messageTextField.text = ""
            self.messageTextField.resignFirstResponder()
        }
    }
   
  
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !fromBottomView{
            viewIsHiding()
        }
    }
    
    //MARK: Zoomin/Zoomout
  
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return statusImgView
    }
    
    @objc func panGestureRecognizerHandler(_ gesture: UIPanGestureRecognizer) {
        let _ = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        let locationinView = gesture.location(in: view)
        guard let initFrame = initialFrame else{return}
        
        if locationinView.y >  (initFrame.origin.y) - self.view.bounds.height*0.2 {
            gesture.state == .began ? panGestureDidStart(locationinView) : panGestureDidChange(locationinView)
        }else{
            print("greater")
            bottomView.alpha = 0
        }
        
        if gesture.state == .ended {
            panGestureDidEnd(locationinView, velocity: velocity)
        }
    }
    
    func panGestureDidStart(_ location: CGPoint){
        initialTouchPoint = location
    }
    
    func panGestureDidChange(_ translation: CGPoint) {
        guard initialFrame != nil else { return }
        guard let initialPoint = initialTouchPoint else { return }
        
        let bottomHeight = (initialPoint.y - translation.y)
        
        bottomViewbottomConstraint.constant = -bottomHeight
    }
    
    func panGestureDidEnd(_ translation: CGPoint, velocity: CGPoint) {
        if bottomView.alpha == 0{
            replayViewShower()
        }
        
        bottomViewbottomConstraint.constant = 0
        bottomView.alpha = 1
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        videoView.player?.play()
        progressBar.isPaused = false
        topView.isHidden = false
        bottomView.isHidden = false
        self.scrollView.setZoomScale(0.0, animated: true)
        statusGifView.startAnimatingGif()
    }
   
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        progressBar.isPaused = true
        self.videoView.player?.pause()
        topView.isHidden = true
        bottomView.isHidden = true
        statusGifView.stopAnimatingGif()
    }
    
    
    func refreshItemswhenBack(){
        print("refreshItemswhenBack startIndex===\(startIndex)")
        self.progressBar.isPaused = true
//        if  self.startIndex > 0 {
//            self.startIndex = self.startIndex - 1
//        }
        updateImage(index: startIndex)
    }
    
    //MARK: Other Helpful Methods
    func viewIsDisplayed(){
        if isDisplayedForFirstTime{
            isDisplayedForFirstTime = false
            self.progressBar.startAnimation()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1, execute: { [weak self] in
                self?.progressBar.rewind()
            })
        }else{
            progressBar.isPaused = false
            progressBar.reAnimate()
        }
                
        isViewDisplayed = true
        videoView.player?.play()
//        if(startIndex < self.wallStatusObj.statusArray.count){
//            
//            let messageFrame = self.wallStatusObj.statusArray[startIndex]
//            
//            if checkMediaTypes(strUrl: messageFrame.media) == 1{
//                
//            }else{
//                videoView.player?.play()
//                
//            }
//        }
    }
    
    func viewIsHiding(){
        isViewDisplayed = false
        self.videoView.player?.pause()
        progressBar.isPaused = true
    }
    
    func setupView(){
        view.bringSubviewToFront(topView)
        view.bringSubviewToFront(bottomView)
        view.bringSubviewToFront(progressBar)
        view.bringSubviewToFront(CaptionView)
        view.bringSubviewToFront(onlyPictures)
        view.bringSubviewToFront(btnRepostYourTag)
        view.bringSubviewToFront(bgVwSongName)
    }
 
    func segmentedProgressBarChangedIndex(index: Int) {
        print("Now showing index: \(index)")

        if(self.startIndex > index)
        {
            self.progressBar.skip()

        }else
        {
            updateImage(index: index)
        }
    }
    
    @objc func playerEnd(){
       // progressBar.skip()
    }
    
   
    @objc func viewDidTapped(_ sender: UIGestureRecognizer) {
      // statusImgView.image = nil
        let point = sender.location(ofTouch: 0, in: view)
         progressBar.isPaused = !progressBar.isPaused
        if (point.x) < self.view.bounds.width/2{
            if startIndex == 0{
                self.progressBar.isPaused = true
                self.startIndex = 0
                self.delegate?.previewPreviousStory()
            }else{
                self.startIndex = self.startIndex - 1
                self.progressBar.isPaused = false
                progressBar.rewind()
            }
            
        }else{
            
            if(self.startIndex == self.progressBar.currentAnimationIndex)
            {
                self.startIndex = self.startIndex + 1
            }
            progressBar.skip()

        }
    }
    
    @objc func viewDidPressed(_ sender: UIGestureRecognizer) {
       
        if sender.state == .ended {
            videoView.player?.play()
            progressBar.isPaused = false
            topView.isHidden = false
            bottomView.isHidden = false
            statusGifView.startAnimatingGif()
       
        }else if sender.state == .began {
            progressBar.isPaused = true
            self.videoView.player?.pause()
            topView.isHidden = true
            bottomView.isHidden = true
            statusGifView.stopAnimatingGif()
        }
    }
    
    
   
    
    @objc func viewSwipedDown(){
        self.pop(animated: true)
    }
    
    @objc func appEnterBackGround(){
        
        if isViewDisplayed && isAppInForeground{
            isAppInForeground = false
            self.videoView.player?.pause()
            progressBar.isPaused = true
        }
    }
    
    @objc func appEnterForeground(){
        
//        if isViewDisplayed && !isAppInForeground{
//            isAppInForeground = true
////            if player != nil{
////                player?.play()
////            }
//            progressBar.isPaused = false
//        }
    }
    
    
    
    @objc @IBAction func blurGestureTapped(_ sender : UITapGestureRecognizer)
    {
        if(sender.location(in: statusReplayView.superview).y < statusReplayView.frame.origin.y) {
            blureViewTapped()
        }
    }
    
    @objc func blureViewTapped(){
       
        videoView.player?.play()
        progressBar.isPaused = false
        blureView.isHidden = true
        self.messageTextField.text = ""
        //messageButton.isEnabled = false
        messageTextField.resignFirstResponder()
    }
    
    func segmentedProgressBarFinished() {
        print("Finished!")
        progressBar.isPaused = true
        self.videoView.player?.pause()
        self.deallocPlayer()
        delegate?.currentStoryEnded()
    }
    
    
    func playVideo(videoStrUrl : String){
        
        self.spinner.isHidden = true
        progressBar.isPaused = true
        
        //videoView.player?.isMuted = !UserDefaults.standard.bool(forKey: videosStartWithSound)
        
        videoView.contentMode = .scaleAspectFit
        videoView.pausedReason = .userInteraction
        if videoStrUrl.length > 0 {
            videoView.setURLToPlay(for: URL(string:videoStrUrl)!)
            videoView.player?.play()
        }
        videoView.isHidden = false
        videoView.frame = self.view.bounds
        
        videoView.backgroundColor = UIColor.clear
        
//        self.view.insertSubview(videoView, belowSubview: self.topView)
      
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.playerEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
        
        playerLayerReadyForDisplayObservation = nil
        playerLayerReadyForDisplayObservation = videoView.playerLayer.observe(\.isReadyForDisplay) { [unowned self, unowned player = videoView.player] playerLayer, _ in
            if playerLayer.isReadyForDisplay, videoView.player?.rate ?? 0.0 > 0 {
//              self.statusImgView.isHidden = true
//               self.statusImgView.image = nil

            }
        }
        
        timeObserver = nil
        timeObserver = videoView.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) {[weak self] (timer) in
            
            var playerCurrentTime = 0.0
            if(self?.videoView.player?.currentItem != nil)
            {
                playerCurrentTime = Double((self?.videoView.player?.currentItem?.currentTime().seconds)!)
               // print(playerCurrentTime)
            }
            
         if playerCurrentTime > 0 {
                if self?.videoView.player?.isPlaying == true , self?.progressBar.isPaused == true
                {
                      self?.progressBar.isPaused = false
                    /* self?.statusImgView.isHidden = true*/
                }
             /*  self?.viewImgs.isHidden = true
                self?.videoView.isHidden = false
            */
                self?.spinner.isHidden = true
            }
        }
        
        videoView.stateDidChanged = { state in
            switch state {
            case .none:
                print("none")
            case .error(let error):
                print("error - \(error.localizedDescription)")
            case .loading:
                print("loading")
            case .paused(let playing, let buffering):
                print("paused - progress \(Int(playing * 100))% buffering \(Int(buffering * 100))%")
                self.statusImgView.isHidden = false
                self.videoView.isHidden = true
            case .playing:
                print("playing")
                self.statusImgView.isHidden = true
                self.videoView.isHidden = false
            }
        }
        
    }
    
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            switch keyPath {
            case "playbackBufferEmpty"?:
                print("buffer")
                break
                // Show loader
                
            case "playbackLikelyToKeepUp"?:
                print("buffer hide")
                statusImgView.isHidden = true
                break
                // Hide loader
                
            case "playbackBufferFull"?:
                print("buffer hide")
                statusImgView.isHidden = true
                break
            // Hide loader
            default :
                //print("\(String(describing: player?.status))")
                break
            }
        }
        
        if keyPath == "status" {
           // print("\(String(describing: player?.status))")
        }
    }
    
    

    
//MARK: UIBUtton Action Methods
    @IBAction func menuButtonDidTapped(_ sender: UIButton) {
        
        self.videoView.player?.pause()
        
        progressBar.isPaused = true
        
        if(Themes.sharedInstance.Getuser_id() == self.wallStatusObj.userInfo?.id)
        {
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let DeleteAction = UIAlertAction(title: "Delete", style: .destructive) {[weak self] (alert: UIAlertAction) in
                
                if( (self?.progressBar.currentAnimationIndex ?? 0) < (self?.wallStatusObj.statusArray.count ?? 0))
                {
                    self?.delegate?.didClickDelete(self?.wallStatusObj.statusArray[self?.progressBar.currentAnimationIndex ?? 0] ?? WallStatus.StoryStaus(statusDict: [:]))
                    self?.delegate = nil
                }
            }
            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) {[weak self] (alert: UIAlertAction) in
                if !(self?.fromBottomView ?? false){
                    self?.viewIsDisplayed()
                }
            }
            alertController.addAction(DeleteAction)
            alertController.addAction(CancelAction)
            self.presentView(alertController, animated: true, completion: nil)
        }
    }
    
   
    @IBAction func messageButtonDidTapped(_ sender: Any) {
        
        let objStoryStatus = self.wallStatusObj.statusArray[self.progressBar.currentAnimationIndex]
        let message = self.messageTextField.text!
      
        if message.trim().count > 0 {
            if (wallStatusObj.userInfo?.isFollowBack ?? 0) == 1{
                let message = message.trimmingCharacters(in: .whitespaces)
                sendMediaToSocket(mainUrl: objStoryStatus.media, thumbUrl: objStoryStatus.thumbnail, caption: message, duration: "\(objStoryStatus.durationTime ?? 0.0)")
                self.blureViewTapped()
            }
        }else {
            //Like the status
            messageTextField.isHidden = false
            messageButton.isHidden = false
            viewBackTxtMSG.isHidden = false
            self.likeStoryAPIAction()
        }
    }
    
 
    @IBAction func repostStoryButtonTapped(_ sender: UIButton) {
        
        repostTaggedStoryApi()
    }

     
    //MARK: Emit Socket
    func sendMediaToSocket(mainUrl:String,thumbUrl:String,caption:String,duration:String){
        
        var params = [String : Any]()
        
        params["authToken"] = Themes.sharedInstance.getAuthToken()
        params["fcrId"] = ""
        params["receiverId"] = self.wallStatusObj.userInfo?.id ?? ""
        let timeStamp = Date.timeStamp*1000
        let docId = "\(Themes.sharedInstance.Getuser_id())-\(self.wallStatusObj.userInfo?.id ?? "")-\(timeStamp)"
        params["messageDocId"] = docId
        /* 0-Text, 1-Media (Image,video,GIF, Document), 2-Link, 3-Contact, 4-Location,*/
        params["payload"] = caption.trimmingCharacters(in: .whitespaces)
        params["type"] = 7
        params["storyId"] = self.wallStatusObj.statusArray[ self.progressBar.currentAnimationIndex].statusId
 
        SocketIOManager.sharedInstance.emitChaWithCallBack(params: params as NSDictionary, eventName: Constant.sharedinstance.sio_feed_send_chat_message)
    }
    
    
    //MARK: Like Api
        
    func repostTaggedStoryApi(){
        let objStoryStatus = self.wallStatusObj.statusArray[ self.progressBar.currentAnimationIndex]
       
        let param:NSDictionary = ["storyId":objStoryStatus.statusId,"tagStory":[]]
        // Themes.sharedInstance.activityView(View: self.view)
     
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.repostTaggedStory as String, param: param, completionHandler: {[weak self] (responseObject, error) ->  () in
            //  Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self?.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                self?.view.makeToast(message: message, duration: 3, position: HRToastPositionCenter)
            }
        })
    }
    
    
    func likeStoryAPIAction() {
        
        var objStoryStatus = self.wallStatusObj.statusArray[ self.progressBar.currentAnimationIndex]
        let isLike = (objStoryStatus.isLike == 1 ? 0 : 1)
        if isLike == 1 {
            self.showEmitterHeartView()
        }
        
        let param:NSDictionary = ["wallStatusId":objStoryStatus.statusId,"action":"\(isLike)"]
        // Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.wallStatusLikeDislikeURL as String, param: param, completionHandler: {[weak self](responseObject, error) ->  () in
            //  Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self?.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    
                    objStoryStatus.isLike = isLike
                    self?.wallStatusObj.statusArray[self?.progressBar.currentAnimationIndex ?? 0] = objStoryStatus
                   /* if isLike == 1 {
                        self.showEmitterHeartView()
                    }*/
                    self?.messageButton.setImage((objStoryStatus.isLike == 1) ? PZImages.heart_Filled :  PZImages.heartWhite_blank, for: .normal)
                }else
                {
                    self?.view.makeToast(message: message, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    func showEmitterHeartView(){
        self.blureView.duration = 2.0
        self.blureView.amplitude = 80
        self.blureView.emitImage(R.image.heart()!)
        self.blureView.emitImage(R.image.heart()!)
        self.blureView.emitImage(R.image.heart()!)
        self.blureView.emitImage(R.image.heart()!)
    }
    
    @objc  func handleProfilePicTap(_ sender: UITapGestureRecognizer? = nil){
        self.videoView.player?.pause()
        progressBar.isPaused = true
        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.otherMsIsdn = self.wallStatusObj.userInfo?.id ?? ""
        self.navigationController?.pushViewController(profileVC, animated: true)
    }

    @IBAction func profilePicButtonDidTapped(_ sender: UIButton) {
        self.videoView.player?.pause()
        
        progressBar.isPaused = true
        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.otherMsIsdn = self.wallStatusObj.userInfo?.id ?? ""
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
  

    @IBAction func backButtonDidTapped(_ sender: UIButton) {
        delegate?.backButtonClicked()
    }
    
    
    //MARK: TEXTFIELD COMMENT
    
    fileprivate func replayViewShower() {
        
        self.videoView.player?.pause()
        
        progressBar.isPaused = true
        if isMyStatus{
        
        
            
        }else{
         //   replayViewSetter()
            blureView.isHidden = false
            self.view.sendSubviewToBack(videoView)
            
            self.view.bringSubviewToFront(blureView)
            messageTextField.isHidden = false
            messageButton.isHidden = false
            viewBackTxtMSG.isHidden = false
            self.messageTextField.becomeFirstResponder()
            
            if (messageTextField.text?.count ?? 0) == 0 {
                let objStoryStatus = self.wallStatusObj.statusArray[ self.progressBar.currentAnimationIndex]
                self.messageButton.setImage((objStoryStatus.isLike == 1) ? PZImages.heart_Filled :  PZImages.heartWhite_blank, for: .normal)
            }else {
                messageButton.setImage(UIImage(named: "send"), for: .normal)
            }
        }
    }
    
    func contentSheetDidDisappear(_ sheet: ContentSheet) {
        fromBottomView = false
        blureViewTapped()
        progressBar.skip()
    }
    
    @objc fileprivate func swipeUpButtonTapped() {
        replayViewShower()
    }
    
    @IBAction func swipUpButtonDidTapped(_ sender: UIButton) {
        swipeUpButtonTapped()
    }
    
    private func deallocPlayer() {
        self.videoView.player?.pause()
       // self.videoView.player = nil
        self.videoView.isHidden = true
       // self.videoView.removeFromSuperview()
//        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
//        timeObserver = nil
//        playerLayerReadyForDisplayObservation = nil
    }
    
    
    private func updateImage(index: Int) {
        
         print("Next! == \(index)")
       // statusImgView.image = nil
        deallocPlayer()
        spinner.isHidden = true
        messageTextField.text = ""
        self.statusImgView.isHidden = false
        
        _ = self.statusImgView.subviews.map {
            if $0.tag == 100 {
                $0.removeFromSuperview()
            }
        }
         
        if(index < self.wallStatusObj.statusArray.count){
            
            let messageFrame = self.wallStatusObj.statusArray[index]
            textStatusLabel.isHidden = true
            self.view.bringSubviewToFront(textStatusLabel)
            textStatusLabel.text = "" //messageFrame.message.payload!
            self.view.backgroundColor = UIColor.black
            self.moreButton.isHidden = true
            self.btnRepostYourTag.isHidden = (messageFrame.taggedStoryStatus == 1) ? false : true
            self.lblMarquee.isHidden = true
            self.imgVwSong.isHidden = true
            if (messageFrame.soundTitle.length > 0 || messageFrame.soundThumbUrl.length > 0){
              
                self.lblMarquee.text = messageFrame.soundTitle
                self.lblMarquee.isHidden = false
                self.imgVwSong.isHidden = false
                self.imgVwSong.kf.setImage(with: URL(string: messageFrame.soundThumbUrl) ,placeholder:UIImage(named: "Song"),options: [.processor(DownsamplingImageProcessor(size:  imgVwSong.frame.size)),                                                                                        .scaleFactor(UIScreen.main.scale)])
            }
            SocketIOManager.sharedInstance.viewOtherStoryStatus(userId: Themes.sharedInstance.Getuser_id(), statusId: messageFrame.statusId)
            bgViewCount.isHidden = true

            self.profileImgView.setImgView(profilePic: self.wallStatusObj.userInfo?.profilePic ?? "", frameImg: self.wallStatusObj.userInfo?.avatar ?? "")
            
            if Themes.sharedInstance.Getuser_id() == self.wallStatusObj.userInfo?.id{
                self.currentUserName.text = "Me"
                self.moreButton.isHidden = false
                bgViewCount.isHidden = false
                self.CaptionViewline.isHidden = true
                self.view.bringSubviewToFront(bgViewCount)
                self.onlyPictures.reloadData()
                if messageFrame.statusMessage.count > 0{
                    self.CaptionViewline.isHidden = false
                }
                view.bringSubviewToFront(onlyPictures)
                if messageFrame.viewCount == 0 {
                    bgViewCount.isHidden = true
                }
                replyLbl.isHidden = true
                swipeUpbutton.isHidden = true
           
            }else{
                
                self.currentUserName.text = self.wallStatusObj.userInfo?.pickzonId ?? ""
                self.CaptionViewline.isHidden = false
                self.view.sendSubviewToBack(bgViewCount)
                self.view.bringSubviewToFront(viewBackTxtMSG)
                replyLbl.isHidden = false
                swipeUpbutton.isHidden = false
            }

            imgVwCelebrity.isHidden =  true
            if self.wallStatusObj.userInfo?.celebrity == 1 {
                imgVwCelebrity.isHidden = false
                imgVwCelebrity.image = PZImages.greenVerification
            }else if self.wallStatusObj.userInfo?.celebrity == 4{
                imgVwCelebrity.isHidden = false
                imgVwCelebrity.image = PZImages.goldVerification
            }else if self.wallStatusObj.userInfo?.celebrity == 5{
                imgVwCelebrity.isHidden = false
                imgVwCelebrity.image = PZImages.blueVerification
            }
            self.currentTimeLabel.text = messageFrame.statusTime
             //self.statusImgView.image = nil
            if checkMediaTypes(strUrl: messageFrame.media) == 1{
                
                statusImgView.isHidden = false
                statusGifView.isHidden = true
                self.viewImgs.isHidden = false
                self.statusImgView.kf.setImage(with: URL(string:  messageFrame.media),  options: nil, progressBlock: nil) { response in
                }
                self.progressBar.isPaused = false
                self.videoView.isHidden = true

            }else {
                self.videoView.isHidden = false
                statusImgView.isHidden = false
                statusGifView.isHidden = true
                self.viewImgs.isHidden = false
                statusImgView.kf.setImage(with: URL(string:  messageFrame.thumbnail), options:nil, progressBlock: nil) { response in
                }
                self.progressBar.isPaused = false
                DispatchQueue.main.async {
                    self.spinner.isHidden = false
                    self.playVideo(videoStrUrl: messageFrame.media)
                }
            }
            
           // self.videoView.backgroundColor = .red
           // self.statusImgView.backgroundColor = .green
           /* var str:String = ""
            if messageFrame.taggedUserPickzonId.count > 0{
                str =  "@" + messageFrame.taggedUserPickzonId.joined(separator:  " @") + "\n"
            }*/
      
            if messageFrame.statusMessage.count > 0{
                self.CaptionLbl.attributedText = (messageFrame.statusMessage + "\n").convertAttributtedColorText(isCenter: true,linkAndMentionColor:.white)
                self.CaptionLbl.isHidden = false
            }else{
                self.CaptionLbl.isHidden = true
            }
            self.CaptionLbl.textAlignment = .center
        }
 }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if (scrollView.panGestureRecognizer.translation(in: scrollView.superview).y >= 0) {
            self.blureViewTapped()
        } else {
        }
    }
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.appEnterBackGround()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.appEnterBackGround()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.appEnterForeground()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.appEnterForeground()
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver( UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver( UIResponder.keyboardWillHideNotification)
    }
  
    deinit {
        print("Deinit Storyviewcontroller")
        DispatchQueue.main.async {
            /*self.player = nil
            self.playerLayer = nil
            self.playerIteam = nil
            if self.player != nil{
                self.deallocPlayer()
            }*/
            self.deallocPlayer()
            self.progressBar.isPaused = true
            self.removeNotificationListener()
        }
    }
}


//extension StoryViewController : PersonViewedStatusViewDelegate {
//
//    func delete() {
//        if(self.progressBar.currentAnimationIndex < self.wallStatusObj.statusArray.count)
//        {
//            self.delegate?.backButtonClicked()
//           // self.delegate?.backButtonClicked()
//            // self.delegate?.DidClickDelete(self.statusArray.object(at: self.progressBar.currentAnimationIndex) as! UUMessageFrame)
//            self.delegate = nil
//        }
//    }
//
//    func forward() {
//        if(self.progressBar.currentAnimationIndex < self.wallStatusObj.statusArray.count)
//        {
//            self.delegate?.backButtonClicked()
//          //  self.delegate?.backButtonClicked()
//            // self.delegate?.DidClickForward(self.statusArray.object(at: self.progressBar.currentAnimationIndex) as! UUMessageFrame)
//            self.delegate = nil
//        }
//    }
//
//    func passSelectedPerson(data: NSDictionary) {
//
//    }
//
//    func closeContentSheed() {
//
//    }
//}

extension StoryViewController : UITextFieldDelegate,OnlyPicturesDataSource,OnlyPicturesDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
                
        IQKeyboardManager.shared().keyboardDistanceFromTextField = (UIDevice().hasNotch)  ? 0 : 5
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        self.blureViewTapped()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("shouldChangeCharactersIn")
        if  (wallStatusObj.userInfo?.isFollowBack ?? 0) == 0{
           
            self.view.makeToast(message: "You have to follow each other to send comments." , duration: 3, position: HRToastPositionCenter)
            return false
        }
        
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            if updatedText.count > 50{
                return false
            }
            
            if updatedText.trim().count == 0 {
                let objStoryStatus = self.wallStatusObj.statusArray[ self.progressBar.currentAnimationIndex]
                messageButton.setImage((objStoryStatus.isLike == 1) ? PZImages.heart_Filled :  PZImages.heartWhite_blank, for: .normal)
            }else {
                messageButton.setImage(UIImage(named: "send"), for: .normal)
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        if textField.text?.count == 0 {
            let objStoryStatus = self.wallStatusObj.statusArray[ self.progressBar.currentAnimationIndex]
            messageButton.setImage((objStoryStatus.isLike == 1) ? PZImages.heart_Filled :  PZImages.heartWhite_blank, for: .normal)

        }else {
            messageButton.setImage(UIImage(named: "send"), for: .normal)
        }
        self.blureViewTapped()
        return true
    }

    //MARK: PhotoView Delegate
    func initializeHorizontalPhoto(){
        
        bgViewCount.backgroundColor = UIColor.clear
        onlyPictures.backgroundColor = UIColor.clear
        onlyPictures.layer.cornerRadius = 0.0
        onlyPictures.layer.masksToBounds = true
        onlyPictures.clipsToBounds = true
        onlyPictures.dataSource = self
        onlyPictures.delegate = self
        onlyPictures.order = .descending
        onlyPictures.alignment = .center
        onlyPictures.countPosition = .right
        onlyPictures.contentMode = .bottomRight
        //onlyPictures.recentAt = .right
        onlyPictures.spacingColor = UIColor.white
        onlyPictures.backgroundColorForCount = .blue
        onlyPictures.gap = 35
        onlyPictures.fontForCount = UIFont(name: "HelveticaNeue", size: 18)!
        onlyPictures.textColorForCount = .white
        onlyPictures.isHiddenVisibleCount = false
    }
   
    func numberOfPictures() -> Int {
        return self.wallStatusObj.statusArray[self.progressBar.currentAnimationIndex].viewCount
    }
    
    func visiblePictures() -> Int {
        return  self.wallStatusObj.statusArray[self.progressBar.currentAnimationIndex].seenUserInfoArray.count
    }
   
    func visiblePictures(onlyPictureView: OnlyPictures) -> Int {
        
        return  self.wallStatusObj.statusArray[self.progressBar.currentAnimationIndex].seenUserInfoArray.count
    }
    
   
    func pictureViews(_ imageView: UIImageView, index: Int){
        if self.wallStatusObj.statusArray[self.progressBar.currentAnimationIndex].seenUserInfoArray.count > index {
            let url = URL(string: self.wallStatusObj.statusArray[self.progressBar.currentAnimationIndex].seenUserInfoArray[index].profilePic)
            imageView.kf.setImage(with: url, placeholder: PZImages.avatar , options: [.processor(DownsamplingImageProcessor(size:  imageView.frame.size)),                                                                                        .scaleFactor(UIScreen.main.scale)], progressBlock: nil, completionHandler: { response in        })
        }
    }
    
    func pictureView(_ imageView: UIImageView, didSelectAt index: Int) {
        if  self.wallStatusObj.statusArray[self.progressBar.currentAnimationIndex].viewCount > 0 {
            
            self.videoView.player?.pause()
            progressBar.isPaused = true
            let messageFrame  = self.wallStatusObj.statusArray[ self.progressBar.currentAnimationIndex]
            let profileVC:LikeUsersVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LikeUsersVC") as! LikeUsersVC
            profileVC.controllerType = .storyView
            profileVC.postId = messageFrame.statusId
            self.pushView(profileVC, animated: true)
        }
    }
   
    func pictureViewCountDidSelect() {
        if  self.wallStatusObj.statusArray[self.progressBar.currentAnimationIndex].viewCount > 0 {
            
            self.videoView.player?.pause()
            
            progressBar.isPaused = true
            let messageFrame  = self.wallStatusObj.statusArray[ self.progressBar.currentAnimationIndex]
            
            let profileVC:LikeUsersVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LikeUsersVC") as! LikeUsersVC
            profileVC.controllerType = .storyView
            profileVC.postId = messageFrame.statusId
            self.pushView(profileVC, animated: true)
            //        self.delegate?.didClickViewStatusUsers(statusId: messageFrame.statusId)
            //        self.delegate = nil
        }
    }
}

extension StoryViewController:ExpandableLabelDelegate{
    // MARK: ExpandableLabel Delegate

    func numberTextClicked(_ label: ExpandableLabel, number: String) {
        self.videoView.player?.pause()
        
        progressBar.isPaused = true
        if let url = URL(string: "tel://\(number)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func hashTagTextClicked(_ label: ExpandableLabel, hashTag: String) {
        self.videoView.player?.pause()
        
        progressBar.isPaused = true
        let destVc:WallPostViewVC = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
        destVc.controllerType = .hashTag
        destVc.hashTag = hashTag
        AppDelegate.sharedInstance.navigationController?.pushViewController(destVc, animated: true)
    }
    
    func willExpandLabel(_ label: ExpandableLabel) {
        //tblFeeds.beginUpdates()
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        //        let point = label.convert(CGPoint.zero, to: tblFeeds)
        //        if let indexPath = tblFeeds.indexPathForRow(at: point) as IndexPath? {
        //            states[indexPath.row] = false
        //            DispatchQueue.main.async { [weak self] in
        //                //  self?.tblFeeds.scrollToRow(at: indexPath, at: .none, animated: false)
        //            }
        //        }
        //        tblFeeds.endUpdates()
    }
    
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        //tblFeeds.beginUpdates()
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        //        let point = label.convert(CGPoint.zero, to: tblFeeds)
        //        if let indexPath = tblFeeds.indexPathForRow(at: point) as IndexPath? {
        //            states[indexPath.row] = true
        //            DispatchQueue.main.async { [weak self] in
        //                self?.tblFeeds.reloadRows(at: [indexPath], with: .none)
        //                // self?.tblFeeds.scrollToRow(at: indexPath, at: .bottom, animated: false)
        //            }
        //        }
        //        tblFeeds.endUpdates()
    }
    
    func mentionTextClicked(_ label: ExpandableLabel,mentionText:String){
        print("mentionTextClicked \(mentionText)")
        self.videoView.player?.pause()
        
        progressBar.isPaused = true
        let viewController:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        let mention:String = String(mentionText.dropFirst())
        guard let index =  self.wallStatusObj.statusArray[ self.progressBar.currentAnimationIndex].taggedUserPickzonId.firstIndex(of: mention) else{
            return
        }
        viewController.otherMsIsdn = self.wallStatusObj.statusArray[ self.progressBar.currentAnimationIndex].taggedUserId[index]
        self.navigationController?.pushView(viewController, animated: true)
    }
    
    func urlTextClicked(_ label: ExpandableLabel,strURL:String) {
        self.videoView.player?.pause()
        
        progressBar.isPaused = true
        let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
        vc.urlString = strURL
        AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
    }
}


//
//  ClipAudioVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 2/6/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire

class ClipAudioVC: UIViewController {
    
   
    @IBOutlet weak var labelOverallDuration: UILabel!
    @IBOutlet weak var labelCurrentTime: UILabel!
    @IBOutlet weak var playbackSlider: UISlider!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var imgVwAudio:UIImageView!
    @IBOutlet weak var btnPickzonId:UIButton!
    @IBOutlet weak var lblAudioName:UILabel!
    @IBOutlet weak var lblClipsCpunt:UILabel!
    @IBOutlet weak var btnUseAudio:UIButton!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var btnBottomUseAudio:UIButton!

    var clipObj = WallPostModel(dict: [:])
    var isDataMoreAvailable = false
    var listArray = [WallPostModel]()
    var isDataLoading = false
    var player: AVPlayer?
    var playerItem:AVPlayerItem?
    fileprivate let seekDuration: Float64 = 10
    var clipDuration = 0
    var pageNo = 1

    //MARK: Controller Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        registerCell()
        updateData()
        getClipsBySongIdApi(showLoader: true)
        initAudioPlayer()
        self.btnBottomUseAudio.isHidden = true
        registerObjservers()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        btnPlay.setImage(UIImage(named: "play_triangle"), for: .normal)

    }
    
    
    deinit{
        NotificationCenter.default.removeObserver(self)

        NotificationCenter.default.removeObserver(self, name:
                                                    NSNotification.Name(notif_FeedFollowed.rawValue), object: nil)
        
        NotificationCenter.default.removeObserver(self, name:
                                                    NSNotification.Name(PickZon.notif_FeedLiked.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(PickZon.notif_TagRemoved.rawValue), object: nil)
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(PickZon.nofit_CommentAdded.rawValue), object: nil)
    }
    
    //MARK: Other Helpful Methods
    
    func registerObjservers(){
        // Register to receive notification
        NotificationCenter.default.removeObserver(self)
                
        //check player has completed playing audio
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying(_:)), name:.AVPlayerItemDidPlayToEndTime, object: nil)
   
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedsLikedReceivedNotification(notification:)), name: notif_FeedLiked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedRemovedNotification(notification:)), name: notif_FeedRemoved, object: nil)
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.feedTagRemovedNotification(notification:)), name: notif_TagRemoved, object: nil)
      
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedFollwedNotification(notification:)), name: notif_FeedFollowed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedCommentAddedNotification(notification:)), name: nofit_CommentAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedSavedNotification(notification:)), name: nofit_FeedSaved, object: nil)
    }
    

    //MARKK: Other Helpful Methods
    func registerCell(){
        tblView.register(UINib(nibName: "BusinessMediaTblCell", bundle: nil), forCellReuseIdentifier: "BusinessMediaTblCell")
    }
    
    func updateData(){
        
        if clipObj.soundInfo!.isOriginal == 1 {
            self.lblAudioName.text = (clipObj.soundInfo?.name ?? "") + " - Original Audio"
        }else {
            self.lblAudioName.text = clipObj.soundInfo?.name ?? ""
        }
        
        self.btnPickzonId.setTitle("", for: .normal)
       //f self.lblClipsCpunt.text = clipObj.soundInfo?.clipCount.asFormatted_k_String
        self.imgVwAudio.kf.setImage(with: URL(string: clipObj.soundInfo?.thumb ?? ""), placeholder: nil, options:nil,  progressBlock: nil, completionHandler: { (resp) in
        })
        self.imgVwAudio.layer.cornerRadius = 5.0
        self.imgVwAudio.clipsToBounds = true
        
        self.btnUseAudio.layer.cornerRadius = 5.0
        self.btnUseAudio.clipsToBounds = true
        
        self.btnBottomUseAudio.layer.cornerRadius = self.btnBottomUseAudio.frame.size.height/2.0
        self.btnBottomUseAudio.clipsToBounds = true
    }
    
   
    //call this mehtod to init audio player
    func initAudioPlayer(){
        if clipObj.soundInfo?.audio.length ?? 0 > 0 {
             playerItem = AVPlayerItem(url: URL(string: clipObj.soundInfo?.audio ?? "")!)
            player = AVPlayer(playerItem: playerItem)
            playbackSlider.minimumValue = 0.0
            self.playbackSlider.value = 0.0
            
            //To get overAll duration of the audio
            let duration : CMTime = playerItem!.asset.duration
            let seconds : Float64 = CMTimeGetSeconds(duration)
            labelOverallDuration.text = self.stringFromTimeInterval(interval: seconds)
            //Added as duration was not available in the object for old clips in the system.
            self.clipDuration = Int(seconds)
            
            //To get the current duration of the audio
            let currentDuration : CMTime = playerItem!.currentTime()
            let currentSeconds : Float64 = CMTimeGetSeconds(currentDuration)
            labelCurrentTime.text = self.stringFromTimeInterval(interval: currentSeconds)
            
            playbackSlider.maximumValue = Float(seconds)
            playbackSlider.isContinuous = true
            
            player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
                if self.player!.currentItem?.status == .readyToPlay {
                    let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                    self.playbackSlider.value = Float ( time );
                    self.labelCurrentTime.text = self.stringFromTimeInterval(interval: time)
                }
                let playbackLikelyToKeepUp = self.player?.currentItem?.isPlaybackLikelyToKeepUp
                if playbackLikelyToKeepUp == false{
                    print("IsBuffering")
                    // self.btnPlay.isHidden = true
                    //self.loadingView.isHidden = false
                } else {
                    //stop the activity indicator
                    //print("Buffering completed")
                    //  self.btnPlay.isHidden = false
                    // self.loadingView.isHidden = true
                }
            }
            
            //change the progress value
            playbackSlider.addTarget(self, action: #selector(playbackSliderValueChanged(_:)), for: .valueChanged)
            
            //check player has completed playing audio
           // NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            
            //playButton(btnPlay)
        }
    }
    
    
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider) {
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        player!.seek(to: targetTime)
        if player!.rate == 0 {
            player?.play()
        }
    }
    
    @objc func finishedPlaying( _ myNotification:NSNotification) {
        btnPlay.setImage(UIImage(named: "play_triangle"), for: .normal)
        //reset player when finish
       // btnPlay.setImageTintColor(.blue)
        playbackSlider.value = 0
       // btnPlay.setImageTintColor(.blue)
        let targetTime:CMTime = CMTimeMake(value: 0, timescale: 1)
        player!.seek(to: targetTime)
    }
    
    @IBAction func playButton(_ sender: UIButton) {
        print("play Button")
        if player?.rate == 0
        {
            player!.play()
           // self.btnPlay.isHidden = true
            //self.loadingView.isHidden = false
            btnPlay.setImage(UIImage(named: "pause"), for: .normal)
        } else {
            player!.pause()
            btnPlay.setImage(UIImage(named: "play_triangle"), for: .normal)
            
            
        }
       // btnPlay.setImageTintColor(.blue)

    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
//      return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        return String(format: "%02d:%02d", minutes, seconds)
    }
   
    //MARK: Api Methods
    func getClipsBySongIdApi(showLoader:Bool) {
        
        if pageNo == 1{
            DispatchQueue.main.async {
                Themes.sharedInstance.activityView(View: self.view)
            }
        }
        let urlStr = Constant.sharedinstance.clip_fetch_clip_by_songId + "?soundId=\(clipObj.soundInfo?.id ?? "")&pageNumber=\(self.pageNo)"
        self.isDataLoading = true

        URLhandler.sharedinstance.makeGetAPICall(url: urlStr, param: NSMutableDictionary()) { responseObject, error in
                 
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
            }
            if(error != nil)
            {
                DispatchQueue.main.async {
                    
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    print(error ?? "defaultValue")
                    self.isDataLoading = false
                }
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                let totalRecords = result["totalRecords"] as? Int ?? 0

                if status == 1{
                    
                        self.lblClipsCpunt.text = totalRecords.asFormatted_k_String
                    
                    if let data = result.value(forKey: "payload") as? NSArray {
                        
                        if self.pageNo == 1{
                            self.listArray.removeAll()
                        }
                        
                        for obj in data {
                            self.listArray.append( WallPostModel(dict: obj as! NSDictionary))
                        }
                    }
     
                    self.tblView.reloadData({
                        self.isDataLoading = false
                        self.pageNo = self.pageNo + 1
                    })
                    
                }else{
                    self.isDataLoading = false
                }
            }
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
            }
        }
    }
    
    
    func downloadAndPush(){
        
        DispatchQueue.main.async {
            
            if URLhandler.sharedinstance.isConnectedToNetwork() == true {
                
                if let url = URL(string:self.clipObj.soundInfo?.audio ?? ""){
                    
                    let documentsURL = Themes.sharedInstance.getLocalURLForAudioFileServerURL(Url: url)
                    print("Audio File URL :",documentsURL)
                    if !FileManager.default.fileExists(atPath: documentsURL.path)
                    {
                        let destination: DownloadRequest.Destination = { _, _ in
                            return (documentsURL, [.removePreviousFile])
                        }
                        
                        Themes.sharedInstance.activityView(View: self.view)
                        
                        AF.download(self.clipObj.soundInfo?.audio ?? "", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil, to: destination).downloadProgress(queue: DispatchQueue.global(qos: .background)) {
                            (progress) in
                            // print("Completed Progress: \(progress.fractionCompleted)")
                            //print("Totaldddd Progress: \(progress.completedUnitCount)....\(url)")
                            
                            
                        }.validate().responseData { ( response ) in
                            Themes.sharedInstance.RemoveactivityView(View: self.view)
                            DispatchQueue.main.async {
                                switch response.result {
                                    
                                case .success(_):
                                    print("success")
                                    
                                    /*let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "RecordVideoVC") as! RecordVideoVC
                                    destVC.audioId = self.clipObj.soundInfo?.id ?? ""
                                    destVC.audioName = self.clipObj.soundInfo?.name ?? ""
                                    destVC.audioURL = documentsURL.path
                                    destVC.audioOriginalURL = self.clipObj.soundInfo?.audio ?? ""
                                    destVC.timerValue = Int(self.clipDuration)
                                    self.navigationController?.pushViewController(destVC, animated: true)
                                    */
                                    self.clipObj.soundInfo?.audioLocalURL = documentsURL.path
                                    self.cameraAllowsAccessToApplicationCheck()
                                case let .failure(error):
                                    print("\(error.localizedDescription)")
                                }
                            }
                        }
                    }
                    else
                    {
                       /* let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "RecordVideoVC") as! RecordVideoVC
                        destVC.audioId = self.clipObj.soundInfo?.id ?? ""
                        destVC.audioName = self.clipObj.soundInfo?.name ?? ""
                        destVC.audioURL = documentsURL.path
                        destVC.audioOriginalURL = self.clipObj.soundInfo?.audio ?? ""
                        destVC.timerValue = Int(self.clipDuration)
                        self.navigationController?.pushViewController(destVC, animated: true)
                        */
                        self.cameraAllowsAccessToApplicationCheck()
                    }
                }
                else
                {
                    
                }
                
            }else {
                
            }
        }
        
    }
    
    
    
    //MARK: UIButton Action Methods
    @IBAction func backBtnAction(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func useAudioBtnAction(_ sender:UIButton){
        downloadAndPush()
        /*let documentsURL = Themes.sharedInstance.getLocalURLForAudioFileServerURL(Url: URL(string: clipObj.songInfo?.audioPath ?? ""))
        let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "RecordVideoVC") as! RecordVideoVC
        destVC.audioId = clipObj.songInfo?.id ?? ""
        destVC.audioName = clipObj.songInfo?.name ?? ""
        destVC.audioURL = documentsURL.path
        destVC.timerValue = Int(clipDuration)
        self.navigationController?.pushViewController(destVC, animated: true)*/
        }
    
   
    @IBAction func useAudioBottomBtnAction(_ sender:UIButton){
        downloadAndPush()
        /*let documentsURL = Themes.sharedInstance.getLocalURLForAudioFileServerURL(Url: URL(string: clipObj.songInfo?.audioPath ?? ""))
        let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "RecordVideoVC") as! RecordVideoVC
        destVC.audioId = clipObj.songInfo?.id ?? ""
        destVC.audioName = clipObj.songInfo?.name ?? ""
        destVC.audioURL = documentsURL.path
        destVC.timerValue = Int(clipDuration)
        self.navigationController?.pushViewController(destVC, animated: true)*/
        }
    
}


extension ClipAudioVC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath.section == 0) {
            let width = CGFloat(self.view.frame.size.width/3.0 + 100)
            
            let divide =  CGFloat(listArray.count/3) * width
            var  remainder = CGFloat(listArray.count % 3) * width
            if  (listArray.count % 3) > 0 && listArray.count % 3 < 3{
                remainder = width
            }else{
                remainder = 0
            }
            return  CGFloat(divide + remainder)
            
        }
        
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return 1
        }
        else if section == 1{
            return (listArray.count == 0) ?  0 : checkNumberOfRowType()
        }
        return 0
    }
    
    func checkNumberOfRowType() -> Int{
        
        if (listArray.count > 14) && isDataMoreAvailable == true {
            return 2
        }
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessMediaTblCell") as! BusinessMediaTblCell
        cell.setCollectionLayout()
        cell.isClipsVideo = true
        cell.isToHideOption = true
        cell.wallPostArray = listArray
        cell.delegate = self
        cell.cllctnVw.reloadWithoutAnimation()
        cell.cllctnVw.isScrollEnabled = false
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if !(URLhandler.sharedinstance.isConnectedToNetwork()){
            
            self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
            
        }else  if isDataLoading == false {
            isDataLoading = true
            self.getClipsBySongIdApi(showLoader: true)
        }
    }
//    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        
//        if ((scrollView.contentOffset.y + scrollView.frame.size.height + 100) >= scrollView.contentSize.height){
//            
//            if isDataLoading == false {
//                if !(URLhandler.sharedinstance.isConnectedToNetwork()){
//                    self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
//                    return
//                }
//                if !isDataLoading {
//                    self.isDataLoading = true
//                    self.getClipsBySongIdApi(showLoader: false)
//                }
//            }
//        }
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // print("scrollView.contentOffset.y ==\(scrollView.contentOffset.y)")
        if scrollView.contentOffset.y > 245{
            self.btnBottomUseAudio.isHidden = false
            self.btnUseAudio.isHidden = true
        }else{
            self.btnBottomUseAudio.isHidden = true
            self.btnUseAudio.isHidden = false
        }
    }
}



extension ClipAudioVC {
    
    // MARK: Cell delegate methods Notification Received
    @objc func feedCommentAddedNotification(notification: Notification) {
        
        //print("Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            let commentText = objDict["commentText"] as? String ?? ""
            let isFromShared = objDict["isFromShared"] as? Bool ?? false
            let isFromDelete = objDict["isFromDelete"] as? Bool ?? false
            let commentCount = objDict["commentCount"] as? Int16 ?? 0

            if let selPostIndex = listArray.firstIndex(where:{$0 .id == feedId}) {
                guard  var objWallPost = listArray[selPostIndex] as? WallPostModel else{
                    return
                }
                let count =  (isFromDelete == true ) ? (objWallPost.totalComment - 1) : (objWallPost.totalComment + 1)
                objWallPost.totalComment = count
                //objWallPost.commentCount = commentCount
                listArray[selPostIndex] = objWallPost
            }
        }
        
        
    }
    
    @objc func feedsLikedReceivedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            let isLike = objDict["isLike"] as? Int16 ?? 0
            let likeCount = objDict["likeCount"] as? UInt ?? 0

            if let objIndex = listArray.firstIndex(where:{$0.id == feedId}) {
                var objWallPost = listArray[objIndex] as! WallPostModel
                objWallPost.isLike = isLike
                objWallPost.totalLike = likeCount
                self.listArray[objIndex] = objWallPost
            }
        }
    }
    @objc func feedRemovedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            
            if let objIndex = listArray.firstIndex(where:{$0.id == feedId}) {
                
                DispatchQueue.main.async {
                    self.listArray.remove(at: objIndex)
                    self.tblView.reloadData()
                }
                
            }
        }
    }
    
    @objc func feedTagRemovedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            
            if let objIndex = listArray.firstIndex(where:{$0.id == feedId}) {
                
                if var objWallpost = listArray[objIndex] as? WallPostModel {
                    objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "@\(Themes.sharedInstance.getPickzonId())", with: "")
                    objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "  ", with: " ")
                    self.listArray[objIndex] = objWallpost
                    DispatchQueue.main.async {
                        self.tblView.reloadData()
                    }
                }
            }
        }
    }  
    
    @objc func feedFollwedNotification(notification: Notification) {

        print("FeedsVideoViewController : Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            let userId = objDict["userId"] as? String ?? ""
            let isFollowed = objDict["isFollowed"] as? Int ?? 0
            
            for index in 0..<listArray.count {
                autoreleasepool {
                    var  objWallPost = listArray[index]
                    
                    if objWallPost.userInfo?.id == userId {
                        objWallPost.isFollowed = isFollowed
                        listArray[index] = objWallPost
                    }
                    
                    if objWallPost.sharedWallData != nil && objWallPost.sharedWallData.userInfo?.id == userId{
                        objWallPost.sharedWallData.isFollowed = isFollowed
                        listArray[index] = objWallPost
                    }
                }
            }
        }
    }
    
    
    @objc func feedSavedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            
            let feedId = objDict["feedId"] as? String ?? ""
            let isSave = objDict["isSave"] as? Int16 ?? 0
            
            if let objIndex = listArray.firstIndex(where:{$0.id == feedId}) {
               
                listArray[objIndex].isSave = isSave
            }
        }
    }
}

extension ClipAudioVC: BusinessMediaDelegate{
    
    func clickedMediaWith(index:Int, parentIndex:Int){
        let vc =
        StoryBoard.feeds.instantiateViewController(withIdentifier: "FeedsVideoViewController") as! FeedsVideoViewController
        vc.firstVideoIndex = index
        vc.playingIndex = index
        vc.arrFeedsVideo = listArray
        vc.videoType = .audio
        vc.isClipVideo = true
        vc.pageNo = self.pageNo
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: NSNotification Observers methods
    
   
}



// Support methods
extension ClipAudioVC:YPImagePickerDelegate {
       // MARK: - Configuration
    @objc func showPicker() {
        
       
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .video
        config.library.itemOverlayType = .grid
        config.shouldSaveNewPicturesToAlbum = false
        config.video.compression = AVAssetExportPresetPassthrough
        // config.video.compression = AVAssetExportPresetMediumQuality
        config.albumName = "PickZon"
        
        config.startOnScreen = .library
        
        config.screens = [.library, .video]//[.library, .photo, .video]
        config.isToCompressUsingThirdPartyLibrary = true
        
        if Settings.sharedInstance.isCompressRequired == 0{
            config.isToCompressUsingThirdPartyLibrary = false
        }
        /* Can forbid the items with very big height with this property */
        // config.library.minWidthForItem = UIScreen.main.bounds.width * 0.5
        
        /* Defines the time limit for recording videos.
         Default is 30 seconds. */
        config.video.recordingTimeLimit = Settings.sharedInstance.clipDurationCam
       
       
        
        /* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
        config.showsCrop = .none
        /* Customize wordings */
        config.wordings.libraryTitle = "Gallery"
        /* Defines if the status bar should be hidden when showing the picker. Default is true */
        config.hidesStatusBar = false
        
        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false
        config.maxCameraZoomFactor = 2.0
        
        
        config.library.maxNumberOfItems =  1
        config.gallery.hidesRemoveButton = false
        config.video.fileType = .mp4
        
        config.video.trimmerMaxDuration = Settings.sharedInstance.feedVideoDuration
        config.video.trimmerMinDuration = 3.0
        /* Defines the time limit for videos from the library.
         Defaults to 60 seconds. */
        config.video.libraryTimeLimit = 60 * 30
        config.video.minimumTimeLimit = 3.0
        
        //config.library.preselectedItems = selectedItems
        config.onlySquareImagesFromCamera = false
        
        let picker = YPImagePicker(configuration: config)
        picker.imagePickerDelegate = self
        
        
        
        picker.didFinishPicking { [weak picker] items, cancelled in
            
            if cancelled {
                AppDelegate.sharedInstance.soundInfoSelected = SoundInfo(dict: [:])
                print("Picker was canceled")
                picker?.dismiss(animated: true, completion: nil)
                return
            }
            _ = items.map { print("🧀 \($0)") }
            
            for value in items {
                switch value {
                case .photo(let photo):
                    
                    let fileName = "file\(Date().currentTimeInMiliseconds()).jpeg"
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileURL = documentsDirectory.appendingPathComponent(fileName)
                    if let data = photo.image.jpegData(compressionQuality: 1.0) {
                        do {
                            try data.write(to: fileURL)
                            
                            let imageSize: Int = data.count
                            print("actual size of image in MB: %f ", Double(imageSize) / 1024.0 / 1024.0)
                            
                            /*self.arrUrlDimension.append(["height":"\(Int(photo.image.size.height))", "width":"\(Int(photo.image.size.width))"])
                            self.urlSelectedItemsArray.append(fileURL)
                            self.urlThumnailSelectedItemsArray.append(fileURL)
                            self.updateCVHeight(image: photo.image)
                            self.audioWithImageArr.append(false)
                            self.arrSoundInfo.append(SoundInfo())
                             */
                            
                        } catch {
                            print("error saving file to documents:", error)
                        }
                    }
                    
                case .video(let video):
                    print("Video picked")
                    
                    //DispatchQueue.main.async {
                        if let vc = StoryBoard.main.instantiateViewController(withIdentifier: "PostClipVC") as? PostClipVC {
                            vc.url = video.url
                            //vc.fileName = fileName
                            vc.clipObj = WallPostModel(dict: [:])
                            vc.clipObj.soundInfo =  AppDelegate.sharedInstance.soundInfoSelected
                            //vc.clipObj.payload = self.hashTag
                            vc.delegate = self
                            self.pushView(vc, animated: true)
                            
                            AppDelegate.sharedInstance.soundInfoSelected = SoundInfo(dict: [:])
                        }
                    //}
                        /*self.fileSizeinMB(filePath: video.url.path)
                    
                        self.arrUrlDimension.append(["height":"\(Int(video.url.getVideoSize()?.height ?? 0))", "width":"\(Int(video.url.getVideoSize()?.width ?? 0))"])
                        self.urlSelectedItemsArray.append(video.url)
                        self.urlThumnailSelectedItemsArray.append(video.thumbnail)
                        self.arrHeight.append(self.view.frame.width)
                        self.audioWithImageArr.append(false)
                        self.arrSoundInfo.append(SoundInfo())
                        DispatchQueue.main.async {
                            self.updatetaggedLabel()
                        }*/
                    
                }
                
            }
            picker?.dismiss(animated: true, completion: nil)
           /* DispatchQueue.main.async {
                if Settings.sharedInstance.confidenceThreshold < 0.80 {
                    self.checkNudityContent()
                }
            }*/
        }
        present(picker, animated: true, completion: nil)
        
        
    }
    
    
 
    func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker) {
        // PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
    }

    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true // indexPath.row != 2
    }
    
    
    
    func itemsPicked() {
        print("Items Picked")
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
    
    
     func alertToEncourageCameraAccessWhenApplicationStarts(){
        
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
            
            if self.clipObj.soundInfo != nil {
                AppDelegate.sharedInstance.soundInfoSelected = self.clipObj.soundInfo ?? SoundInfo(dict: [:])
            }
            self.showPicker()
            
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
    
    
    
    func onDone(soundID:String,url:URL,fileName:String){
      
        DispatchQueue.main.async {
            if let vc = StoryBoard.main.instantiateViewController(withIdentifier: "PostClipVC") as? PostClipVC {
                
                var soundInfo =  SoundInfo(dict: [:])
                soundInfo.id =  soundID
                soundInfo.thumb =  ""
                soundInfo.name =  ""
                soundInfo.audio = ""
                
                 vc.url = url
                //vc.fileName = fileName
                vc.clipObj = WallPostModel(dict: [:])
                vc.clipObj.soundInfo =  soundInfo
                //vc.clipObj.payload = self.hashTag
                vc.delegate = self
                self.pushView(vc, animated: true)
                
                
            }
        }
    }
    
}


extension ClipAudioVC:PostClipDelegate{
    func onSuccessClipUpload(clipObj: WallPostModel, selectedIndex: Int) {
        
    }
}


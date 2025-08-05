//
//  FeedsVideoViewController.swift
//  SCIMBO
//
//  Created by gurmukh singh on 11/28/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import FittedSheets
import MKVideoCacher
import Kingfisher
import Foundation
import Alamofire
import Network


enum VideoType {
    case page
    case feed
    case user
    case audio
}

class FeedsVideoViewController: UIViewController{
    
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var cnstntTablleYAxis:NSLayoutConstraint!
    @IBOutlet weak var spinnerVw:UIActivityIndicatorView!
    @IBOutlet weak var tblVideos:UITableView!
    var arrFeedsVideo:Array<WallPostModel> = Array()
    var objWallPost:WallPostModel!
    var playingIndex = -1
    var isFirstTime = true
    var pageNo:Int = 1
    var userId = ""
    var feedId = ""
    var isDataLoading = false
    var firstVideoIndex = 0
    var states : Array<Bool> = Array()
    var videoType:VideoType = .feed
    var delegate:CallBackProfileDelegate? = nil
    var videoView: VideoPlayerView!
    var isRandomVideos = false
    var isHashTagVideos = false
    var hashTag = ""
    var isClipVideo = true
    var isTohideBackButton = false

    @IBOutlet weak var btnCamera:UIButton!
    lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemBlue
        return refreshControl
    }()
    
    // MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isClipVideo == true {
            btnBack.isHidden = true
        }
        
        btnBack.setImageTintColor(UIColor.white)
        self.btnBack.isHidden = (isTohideBackButton == true) ? true : false
        tblVideos.refreshControl = topRefreshControl

        //if UIDevice().hasNotch {
            var topPadding:CGFloat = 0.0
            var bottomPadding:CGFloat = 0.0
            if #available(iOS 13.0, *) {
                let window = UIApplication.shared.windows.first
                topPadding = window?.safeAreaInsets.top ?? 0.0
                bottomPadding = window?.safeAreaInsets.bottom ?? 0.0
            }else{
                bottomPadding  = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
                topPadding  = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0.0
            }
            
           // self.cnstntTablleYAxis.constant = -(UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0.0)
            //First time issue
            self.tblVideos.contentInset = UIEdgeInsets(top: topPadding * -1 , left: 0, bottom: bottomPadding , right: 0)
        //}
        tblVideos.register(UINib(nibName: "FeedsVideoViewCell", bundle: nil), forCellReuseIdentifier: "FeedsVideoViewCell")
        self.view.backgroundColor = UIColor.black
        self.tblVideos.insetsContentViewsToSafeArea = false
        spinnerVw.bringSubviewToFront(self.tblVideos)
        
        spinnerVw.isHidden = true
        
        if videoType == .audio {
            self.states = [Bool](repeating: true, count: self.arrFeedsVideo.count)
            self.tblVideos.reloadData()


            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.tblVideos.scrollToRow(at: IndexPath(row: self.playingIndex, section: 0), at: .top, animated: false)
            }
            
        }else{
            if objWallPost != nil {
                userId = (self.objWallPost.sharedWallData == nil) ? objWallPost.userInfo?.id ?? ""  : objWallPost.sharedWallData.userInfo?.id ?? ""
                feedId = (self.objWallPost.sharedWallData == nil) ? objWallPost.id  : objWallPost.sharedWallData.id
            }
            
            if objWallPost == nil {
                // self.getFeedsVideosAPI(showLoader: true)
                self.pageNo = 2
                self.arrFeedsVideo = Themes.sharedInstance.arrFeedsVideo
                self.states = [Bool](repeating: true, count: self.arrFeedsVideo.count)
                
                if  self.arrFeedsVideo.count > 0 {
                    self.downloadNextThumbnails(index: 0)
                    self.preBufferNextFeedVideos(currentIndex: 0)
                }else {
                    self.pageNo = 1
                    self.getFeedsVideosAPI(showLoader: true)
                }
                
            }else if self.arrFeedsVideo.count == 0 {
                self.arrFeedsVideo.append(self.objWallPost)
                self.states = [Bool](repeating: true, count: self.arrFeedsVideo.count)
                self.getFeedsVideosAPI(showLoader: false)
            }else {
                self.pageNo = 2
                self.arrFeedsVideo.insert(self.objWallPost, at: 0)
                self.states = [Bool](repeating: true, count: self.arrFeedsVideo.count)
                self.downloadNextThumbnails(index: 0)
                self.preBufferNextFeedVideos(currentIndex: 0)
            }
            self.tblVideos.reloadData()
        }
  
        self.registerObjservers()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.errorInVideoPlaying(notification:)), name: nofit_VideoPlayerError, object: nil)
        
        
        if isClipVideo == true {
            if self.arrFeedsVideo.count > self.playingIndex  && self.playingIndex != -1{
                self.playVideoForIndex(pageIndex:CGFloat(self.playingIndex))
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: nofit_VideoPlayerError, object: nil)
        self.pauseAllVisiblePlayers()
        PlayerHelper.shared.pause()
        super.viewWillDisappear(animated)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: notif_FeedLiked, object: nil)
        NotificationCenter.default.removeObserver(self, name: notif_FeedRemoved, object: nil)
        NotificationCenter.default.removeObserver(self, name: notif_TagRemoved, object: nil)
        NotificationCenter.default.removeObserver(self, name: notif_feedExpanded, object: nil)
        NotificationCenter.default.removeObserver(self, name: notif_FeedFollowed, object: nil)
        NotificationCenter.default.removeObserver(self, name: nofit_CommentAdded, object: nil)
        NotificationCenter.default.removeObserver(self, name: nofit_FeedSaved, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Constant.sharedinstance.app_PausePlayer), object: nil)
    }
    
    
    @objc func errorInVideoPlaying(notification: Notification) {
        if let objDict = notification.object as? Dictionary<String, Any> {
            let playingIndex = objDict["playingIndex"] as? Int ?? 0
            if  let visibleIndexPaths = self.tblVideos.indexPathsForVisibleRows {
                for indexPath in visibleIndexPaths {
                    if indexPath.section == 0  && indexPath.row == playingIndex {
                        DispatchQueue.main.async { [weak self] in
                            self?.tblVideos.reloadRows(at: [indexPath], with: .none)
                        }
                    }
                }
            }
        }
    }
    
    
    //MARK: Pull to refresh
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
        if !isDataLoading{
            if videoType == .audio
            {
                
            }else{
                self.isDataLoading = true
                pageNo = 1
                self.pauseAllVisiblePlayers()
                self.getFeedsVideosAPI(showLoader: true)
            }
        }
        refreshControl.endRefreshing()
    }
    
    
    //MARK: Other Helpful Methods
    
    func registerObjservers(){
        // Register to receive notification
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedsLikedReceivedNotification(notification:)), name: notif_FeedLiked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedRemovedNotification(notification:)), name: notif_FeedRemoved, object: nil)
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.feedTagRemovedNotification(notification:)), name: notif_TagRemoved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedExpandedNotification(notification:)), name: notif_feedExpanded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedFollwedNotification(notification:)), name: notif_FeedFollowed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedCommentAddedNotification(notification:)), name: nofit_CommentAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedSavedNotification(notification:)), name: nofit_FeedSaved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(app_Minimize_PausePlayer), name: NSNotification.Name(Constant.sharedinstance.app_PausePlayer), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(appForeground), name: NSNotification.Name(Constant.sharedinstance.app_Foreground), object: nil)
    }
    
   
    //MARK: Observer method
    @objc func appForeground() {
        if let cell = tblVideos.visibleCells.first as? FeedsVideoViewCell{
            cell.videoView.player?.play()
        }
    }
    
    @objc func app_Minimize_PausePlayer() {
        self.pauseAllVisiblePlayers()

    }
    
    //MARK: - Button Action Methods
    @IBAction func backButtonAction()
    {
        self.pauseAllVisiblePlayers()
        PlayerHelper.shared.pausePlayer()
        let objDict = ["playingIndex":self.playingIndex] as [String : Any]
        NotificationCenter.default.post(name: nofit_BackFromVideos, object: objDict)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cameraBtnAction(_ sender : UIButton){
        
        /*let vc = StoryBoard.main.instantiateViewController(withIdentifier: "RecordVideoVC") as! RecordVideoVC
        self.navigationController?.pushViewController(vc, animated: true)
        */
        self.pauseAllVisiblePlayers()
        self.cameraAllowsAccessToApplicationCheck()
    }
    
    //MARK: -  API's Methods
    func getFeedsVideosAPI(showLoader:Bool = true){
        self.isDataLoading = true
        self.spinnerVw.isHidden = false
        
        //   if showLoader == true {
        //    Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
        //  }
        var url = ""
        var mediaId:String = ""
        if self.objWallPost != nil {
            if self.objWallPost.sharedWallData == nil {
//                mediaId =  (self.objWallPost.mediaArr.count > 0) ? (self.objWallPost.mediaArr.first ?? "") : ""
                
                mediaId =  self.objWallPost.id

            }else {
                //mediaId =  (self.objWallPost.sharedWallData.mediaArr.count > 0) ? (self.objWallPost.sharedWallData.mediaArr.first ?? "") : ""
                mediaId =  self.objWallPost.sharedWallData.id
            }
        }
        
        if self.isHashTagVideos == true {
            if mediaId.length == 0 {
                url = "\(Constant.sharedinstance.getFeedVideosURL as String)?pageNumber=\(self.pageNo)&hashtag=\(hashTag)"
            }else {
                url = "\(Constant.sharedinstance.getFeedVideosURL as String)?pageNumber=\(self.pageNo)&hashtag=\(hashTag)&mediaId=\(mediaId)"
            }
        }else if self.isRandomVideos == true {
            if mediaId.length == 0 {
                url = "\(Constant.sharedinstance.getFeedVideosURL as String)?pageNumber=\(self.pageNo)"
            }else {
                url = "\(Constant.sharedinstance.getFeedVideosURL as String)?pageNumber=\(self.pageNo)&mediaId=\(mediaId)"
            }
        }else {
            //Random videos for the selected user
            if mediaId.length == 0 {
                url = "\(Constant.sharedinstance.getFeedVideosURL as String)?pageNumber=\(self.pageNo)&userId=\(self.userId)"
            }else {
                url = "\(Constant.sharedinstance.getFeedVideosURL as String)?pageNumber=\(self.pageNo)&userId=\(self.userId)&mediaId=\(mediaId)"
            }
        }
        
        URLhandler.sharedinstance.makeGetAPICall(url:url, param: NSMutableDictionary(), completionHandler: {(responseObject, error) ->  () in
            //self.isDataLoading = false
            DispatchQueue.main.async {
                // Themes.sharedInstance.RemoveactivityView(View: self.view)
                self.spinnerVw.isHidden = true
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
                    
                    var index = self.arrFeedsVideo.count - 1
                    if let data = result["payload"] as? NSArray {
                        for obj in data {
                            autoreleasepool {
                                let objWallpostata = WallPostModel(dict: obj as! NSDictionary)
                                self.arrFeedsVideo.append(objWallpostata)
                                self.states.append(true)
                                self.tblVideos.beginUpdates()
                                self.tblVideos.insertRows(at: [IndexPath(row: self.arrFeedsVideo.count - 1, section: 0)], with: .bottom)
                                self.tblVideos.endUpdates()
                            }
                        }
                    }
                    
                    self.pageNo = self.pageNo + 1
                    if index == -1 && self.arrFeedsVideo.count > 0 {
                        index = 0
                    }
                    self.downloadNextThumbnails(index: index)
                    self.preBufferNextFeedVideos(currentIndex: index)
                    
                    //self.tblVideos.reloadData {
                        self.isDataLoading = false
                    //}
                } else  {
//                    DispatchQueue.main.async {
//                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
//                    }
                    self.isDataLoading = false

                }
                
                
            }
        })
        
    }
    
    
    
    func getClipsBySongIdApi(showLoader:Bool) {
        
        if pageNo == 1{
            DispatchQueue.main.async {
                Themes.sharedInstance.activityView(View: self.view)
            }
        }
        
        guard let obj = arrFeedsVideo.first  else{
            return
        }
                
        let urlStr = Constant.sharedinstance.clip_fetch_clip_by_songId + "?soundId=\(obj.soundInfo?.id ?? "")&pageNumber=\(self.pageNo)"
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
               // let message = result["message"] as? String ?? ""

                if status == 1{
                    

                    if let data = result.value(forKey: "payload") as? NSArray {
                        
                        if self.pageNo == 1{
                            self.arrFeedsVideo.removeAll()
                        }
                        
                        for obj in data {
                            self.arrFeedsVideo.append( WallPostModel(dict: obj as! NSDictionary))
                        }
                        self.states = [Bool](repeating: true, count: self.arrFeedsVideo.count)
                    }
     
                    self.tblVideos.reloadData({
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
    
    
}

extension FeedsVideoViewController: UITableViewDelegate, UITableViewDataSource  {
    
    // MARK: - UITableviewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFeedsVideo.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.pauseAllVisiblePlayers()
        let cell:FeedsVideoViewCell = tableView.dequeueReusableCell(withIdentifier: "FeedsVideoViewCell", for: indexPath) as! FeedsVideoViewCell
        cell.selectionStyle = .none
        cell.isClipVideo = self.isClipVideo
        cell.isTohideBackButton = self.isTohideBackButton
        let obj = arrFeedsVideo[indexPath.row]
          var strThumbUrl = ""
        var url = ""
        if obj.sharedWallData == nil {
            cell.configureWallPostItem(objWallPost: obj, indexPath: indexPath, states:states[indexPath.row] )
            url =  (obj.urlArray.count > 0) ? obj.urlArray[0] : ""
              strThumbUrl = (obj.thumbUrlArray.count > 0) ? obj.thumbUrlArray[0] : ""
            if obj.userInfo?.id ?? "" == Themes.sharedInstance.Getuser_id(){
                cell.btnFolow.isHidden = true
            }
        }else{
            cell.configureSharedWallDataPost(objWallPost: obj, indexPath: indexPath, states: states[indexPath.row])
            url =  (obj.sharedWallData.urlArray.count > 0) ? obj.sharedWallData.urlArray[0] : ""
             strThumbUrl = (obj.sharedWallData.thumbUrlArray.count > 0) ? obj.sharedWallData.thumbUrlArray[0] : ""
            if obj.sharedWallData.userInfo?.id ?? "" == Themes.sharedInstance.Getuser_id(){
                cell.btnFolow.isHidden = true
            }
        }
        
        
        cell.controlView.thumbImageView.kf.setImage(with: URL(string: strThumbUrl), placeholder: nil, options:[.processor(DownsamplingImageProcessor(size: cell.controlView.thumbImageView.frame.size)),.scaleFactor(UIScreen.main.scale)], progressBlock: nil, completionHandler: { (resp) in
            
           // cell.videoView.backgroundColor = cell.controlView.thumbImageView.image?.getAverageColour
            cell.videoView.backgroundColor = .black
         
         })
        cell.videoView.tag = indexPath.row
        cell.imgVwThumb.isHidden = true
        cell.url = url
        cell.addTargetButtons()
        
        
        if indexPath.row == 0 && isFirstTime == true {
            
            if isRandomVideos{
                if self.videoView != nil {
                    if isFirstTime == true && self.videoView.player?.currentItem?.asset != nil {
                        cell.configurePlayer(indexPath: indexPath, isLoadPrevious: true)
                        if (self.videoView.player?.currentTime() ?? CMTime.zero) > CMTimeMake(value: 0, timescale: 1) {
                            cell.videoView.player?.seek(to: self.videoView.player?.currentTime() ?? CMTime.zero)
                            cell.videoView.resume()
                        }else {
                            cell.configurePlayer(indexPath: indexPath)
                            cell.videoView.resume()
                        }
                    }else {
                        cell.configurePlayer(indexPath: indexPath)
                        cell.videoView.resume()
                    }
                }else {
                    cell.configurePlayer(indexPath: indexPath)
                    cell.videoView.resume()
                }
                
            }else {
                cell.configurePlayer(indexPath: indexPath)
                cell.videoView.resume()
            }
            
            if videoType == .audio{
                
            }else{
                self.playingIndex = 0

            }
            
        }else {
            isFirstTime = false
            cell.configurePlayer(indexPath: indexPath)
        }
        
        cell.lblDescription.delegate = self
        cell.lblDescription.textReplacementType = .word
        cell.lblDescription.shouldCollapse = true
        cell.lblDescription.numberOfLines = 4
        
        if states.count > indexPath.row{
            cell.lblDescription.shouldCollapse = states[indexPath.row]
        }
        
        cell.btnSound.tag = indexPath.row
        cell.btnSound.addTarget(self, action: #selector(useAudioBtnAction(_ : )), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tblVideos.frame.height
    }
    
    

    //MARK: - UITableviewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if (indexPath.row == arrFeedsVideo.count - 2)  && self.isDataLoading == false{
            
            if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
                return
            }
            
            if videoType == .audio{
                self.isDataLoading = true
                self.getClipsBySongIdApi(showLoader: true)
            }else{
                if !isDataLoading {
                    self.isDataLoading = true
                    self.getFeedsVideosAPI(showLoader: false)
                }
            }
        }
        
        if arrFeedsVideo.count > indexPath.row {
            if arrFeedsVideo[indexPath.row].isSeen == 0 {
                if !AppDelegate.sharedInstance.seenArray.contains(arrFeedsVideo[indexPath.row].id){
                    AppDelegate.sharedInstance.seenArray.append(arrFeedsVideo[indexPath.row].id)
                    if arrFeedsVideo[indexPath.row].sharedWallData != nil {
                        AppDelegate.sharedInstance.seenArray.append(arrFeedsVideo[indexPath.row].sharedWallData.id)
                    }
                }
                
                if  AppDelegate.sharedInstance.seenArray.count >= 10 {
                    AppDelegate.sharedInstance.updateFeedsSeenArrayNew()
                }
                arrFeedsVideo[indexPath.row].isSeen = 1
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isFirstTime == false {
            if let cell1 = cell as? FeedsVideoViewCell {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0001) {
                    cell1.videoView.pause(reason: .userInteraction)
                }
            }
        }
    }
    
    
    
    @objc func pauseAllVisiblePlayers(){
        if  let visibleIndexPaths = self.tblVideos.indexPathsForVisibleRows {
            for indexPath in visibleIndexPaths {
                if let cell = tblVideos.cellForRow(at: indexPath) as? FeedsVideoViewCell {
                    cell.videoView.pause(reason: .userInteraction)
                }
            }
        }
    }
    
    
    func playVideoForIndex(pageIndex:CGFloat){
        
        if self.playingIndex == Int(pageIndex) {
            if let cell = self.tblVideos.visibleCells.first as? FeedsVideoViewCell{
                if cell.videoView.player?.isPlaying == false {
                    cell.videoView.player?.play()
                    cell.controlView.updateSpeakerImage()
                }
            }
            return
        }
        
        DispatchQueue.main.async {
            self.pauseAllVisiblePlayers()
        }
        self.playingIndex = Int(pageIndex)
        if pageIndex >= 0.0 && arrFeedsVideo.count > Int(pageIndex) {
            DispatchQueue.main.async {
                if let cell = self.tblVideos.visibleCells.first as? FeedsVideoViewCell{
                    cell.videoView.player?.play()
                    cell.controlView.updateSpeakerImage()
                }
            }
        }
        
        self.downloadNextThumbnails(index: self.playingIndex)
        if playingIndex % 3 == 0 {
            self.preBufferNextFeedVideos(currentIndex: playingIndex)
        }
    }
    
   func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == self.tblVideos
        {
            let pageIndex = round(scrollView.contentOffset.y/self.tblVideos.frame.height)
            self.pauseAllVisiblePlayers()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                self.playVideoForIndex(pageIndex: pageIndex)
            }
        }
    }
    
    //MARK: Selectors
    
    @objc func useAudioBtnAction(_ sender : UIButton){
        if arrFeedsVideo[sender.tag].soundInfo?.audio.length ?? 0 > 0 {
            self.pauseAllVisiblePlayers()
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "ClipAudioVC") as? ClipAudioVC{
                destVC.clipObj = arrFeedsVideo[sender.tag]
                self.navigationController?.pushViewController(destVC, animated: true)
            }
        }else {
            self.view.makeToast(message: "Audio not avialable." , duration: 3, position: HRToastActivityPositionDefault)
        }
    }
}


extension FeedsVideoViewController: URLSessionDelegate, URLSessionDownloadDelegate{
    //MARK: - Download clip video file
    
    /* func downloadNextClipVideos(index:Int) {
     /*var limit = 5
      if index == 0 {
      limit = 2
      }
      for index1 in 0...limit{
      if (index1 + index) < arrFeedsVideo
      .count  {
      
      let obj = arrFeedsVideo[index1 + index]
      var url = ""
      if obj.sharedWallData == nil {
      url = obj.urlArray[0]
      }else {
      url = obj.sharedWallData.urlArray[0] ?? ""
      }
      self.createDownloadTask(serverUrl: url, index: (index1 + index))
      }
      }
      */
     self.downloadNextThumbnails(index: index)
     }*/
    
    func downloadNextThumbnails(index:Int) {
        return
        for index1 in 0...4{
            autoreleasepool {
                if (index1 + index) < arrFeedsVideo.count  {
                    let obj:WallPostModel = arrFeedsVideo[index1 + index]
                    var url = ""
                    if obj.sharedWallData == nil {
                        if obj.thumbUrlArray.count > 0 {
                            url = obj.thumbUrlArray[0]
                        }
                    }else {
                        if obj.sharedWallData.thumbUrlArray.count > 0 {
                            url = obj.sharedWallData.thumbUrlArray[0]
                        }
                    }
                    
                    
                    if let cell = tblVideos.cellForRow(at: IndexPath(row: index1 + index, section: 0)) as? FeedsVideoViewCell{
                        cell.controlView.thumbImageView.kf.setImage(with: URL(string: url), placeholder: UIImage(named: "video_thumbnail"), options:[.processor(DownsamplingImageProcessor(size: cell.controlView.thumbImageView.frame.size)),.scaleFactor(UIScreen.main.scale)], progressBlock: nil, completionHandler: { (resp) in
                        })
                    }else{
                        let imgView = UIImageView()
                        imgView.kf.setImage(with: URL(string: url), placeholder: UIImage(named: "video_thumbnail"), options:[.cacheOriginalImage], progressBlock: nil, completionHandler: { (resp) in
                        })
                    }
                    
                }
            }
        }
    }
    
    
    func createLocalUrl(with url : URL) -> URL?{
        if let filename = (url.absoluteString as NSString?)?.lastPathComponent {
            
            PlayerHelper.shared.manager = VideoCache(limit : VideoCacheLimit)
            let url : URL =  PlayerHelper.shared.manager!.createLocalUrl(with: url)!
            return url
        }
        return nil
    }
    
    func preBufferNextFeedVideos(currentIndex:Int) {
        if (UIApplication.shared.delegate as! AppDelegate).IsInternetconnected == true {
            var urlArray:Array<URL> = Array()
            //for index in currentIndex..<arrFeedsVideo.count {
            for index in currentIndex..<(currentIndex + 3) {
                
                //let index = ind + currentIndex
                if index < arrFeedsVideo.count{
                    autoreleasepool {
                        if let objWallPost = arrFeedsVideo[index] as? WallPostModel {
                            var strURL = ""
                            if objWallPost.sharedWallData == nil {
                                if objWallPost.urlArray.count > 0{
                                    strURL = objWallPost.urlArray[0]
                                }
                            }else {
                                if objWallPost.sharedWallData.urlArray.count > 0{
                                    strURL = objWallPost.sharedWallData.urlArray[0]
                                }
                            }
                            if strURL.length > 0 {
                                if checkMediaTypes(strUrl:strURL ) == 3  {
                                    urlArray.append(URL(string: strURL)!)
                                }
                            }
                        }
                    }
                }else {
                    break
                }
                
            }
            //   print(" urlArray :\(urlArray)")
            if urlArray.count > 0 {
                VideoPreloadManager.shared.set(waiting: urlArray)
            }
        }else {
            self.view.makeToast(message: "No Network Connection", duration: 2, position: HRToastActivityPositionDefault)
        }
    }
    
    
    func createDownloadTask(serverUrl: String, index:Int) {
        let localUrl: URL = self.createLocalUrl(with: URL(string: serverUrl )!)!
        if !FileManager.default.fileExists(atPath: localUrl.path) {
            if (UIApplication.shared.delegate as! AppDelegate).IsInternetconnected == true {
                var downloadTask: URLSessionDownloadTask?
                let url = URL(string: serverUrl)!
                let downloadRequest = NSMutableURLRequest(url: url)
                let session = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: .none)
                downloadTask = session.downloadTask(with: downloadRequest as URLRequest)
                downloadTask!.resume()
            }else {
                DispatchQueue.main.async {
                    self.view.makeToast(message: "No Network Connection", duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        print("progress : ", progress)
        /*if progress >= 0.5 {
         downloadTask.suspend()
         }*/
        
        let downloadFile = downloadTask.dictionaryWithValues(forKeys: ["_downloadFile"])
        var localPath = ""
        let objValues = downloadFile.values
        for v in objValues{
            
                localPath = (v as AnyObject).value(forKey: "_path") as? String ?? ""
                if localPath.count > 0 {
                    autoreleasepool {
                        let serverUrl = downloadTask.response!.url?.absoluteString ?? ""
                        let localUrl: URL = self.createLocalUrl(with: URL(string: serverUrl )!)!
                        
                        do {
                            if FileManager.default.fileExists(atPath: localUrl.path) {
                                try FileManager.default.removeItem(atPath: localUrl.path)
                            }
                            try FileManager.default.copyItem(atPath: localPath, toPath: localUrl.path)
                            //print("Success")
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    break
                }
            
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("didFinishDownloading : ",downloadTask.response?.suggestedFilename) // Gives file name
        //print(downloadTask.response!.url)
    }
    
    
    func URLSession(session: URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            print("Download failed")
            let serverUrl = task.response?.url?.absoluteString ?? ""
            let localUrl: URL = self.createLocalUrl(with: URL(string: serverUrl )!)!
            do {
                if FileManager.default.fileExists(atPath: localUrl.path) {
                    try FileManager.default.removeItem(atPath: localUrl.path)
                }
            } catch {
                print(error.localizedDescription)
            }
            DispatchQueue.main.async {
                self.view.makeToast(message: "No Network Connection", duration: 3, position: HRToastActivityPositionDefault)
            }
        } else {
            print("Download finished")
            //Manage the cache memory for videos stored
            PlayerHelper.shared.manager!.manageCachedDataStorage(with : VideoCacheLimit)
        }
    }
}


extension FeedsVideoViewController:ExpandableLabelDelegate{
    
    // MARK: ExpandableLabel Delegate
    
    func numberTextClicked(_ label: ExpandableLabel, number: String) {
        
        let point = label.convert(CGPoint.zero, to: tblVideos)
        if let indexPath = tblVideos.indexPathForRow(at: point) as IndexPath? {
            if let objWallPost = arrFeedsVideo[indexPath.row] as? WallPostModel {
                if objWallPost.sharedWallData == nil {
                    if objWallPost.userInfo?.celebrity == 1 || objWallPost.userInfo?.celebrity == 4 {
                        if let url = URL(string: "tel://\(number)"),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }else {
                    if objWallPost.sharedWallData.userInfo?.celebrity == 1 || objWallPost.sharedWallData.userInfo?.celebrity == 4{
                        if let url = URL(string: "tel://\(number)"),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
            }
        }
    }
    
    func hashTagTextClicked(_ label: ExpandableLabel, hashTag: String) {
        
        if  isClipVideo == true {
            
            let sectionVideoVC:SectionVideosVC = StoryBoard.main.instantiateViewController(withIdentifier: "SectionVideosVC") as! SectionVideosVC
            sectionVideoVC.hashtagKeyword =  "#\(hashTag)"
            self.navigationController?.pushView(sectionVideoVC, animated: true)
       
        }else{
            let destVc:WallPostViewVC = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
            destVc.controllerType = .hashTag
            destVc.hashTag = hashTag
            AppDelegate.sharedInstance.navigationController?.pushViewController(destVc, animated: true)
        }
    }
    
    
    
    func willExpandLabel(_ label: ExpandableLabel) {
        // tblVideos.beginUpdates()
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        let point = label.convert(CGPoint.zero, to: tblVideos)
        if let indexPath = tblVideos.indexPathForRow(at: point) as IndexPath? {
            if states.count > indexPath.row {
                states[indexPath.row] = false
            }
            DispatchQueue.main.async { [weak self] in
                label.collapsed = false
                //  self?.tblFeeds.scrollToRow(at: indexPath, at: .none, animated: false)
            }
        }
        // tblVideos.endUpdates()
    }
    
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        //  tblVideos.beginUpdates()
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        let point = label.convert(CGPoint.zero, to: tblVideos)
        if let indexPath = tblVideos.indexPathForRow(at: point) as IndexPath? {
            states[indexPath.row] = true
            DispatchQueue.main.async {  [weak self] in
                //  self?.tblVideos.reloadRows(at: [indexPath], with: .none)
                label.collapsed = true
                // self?.tblFeeds.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
        // tblVideos.endUpdates()
    }
    
    func mentionTextClicked(_ label: ExpandableLabel,mentionText:String){
        
        print("mentionTextClicked \(mentionText)")
        
        let mentionString:String = mentionText
        self.getUserIdFromPickzonId(pickzonId: mentionString.replacingOccurrences(of: "@", with: ""))
    }
    
        
        func getUserIdFromPickzonId(pickzonId:String){

        Themes.sharedInstance.activityView(View: self.view)
        
        let params = NSMutableDictionary()
        let url:String = Constant.sharedinstance.getmsisdn + "?pickzonId=\(pickzonId)"
        
        URLhandler.sharedinstance.makeGetAPICall(url:url, param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
                let message = result["message"] as? String ?? ""
                if status == 1{
                    let payload = result["payload"] as? Dictionary<String, Any> ?? [:]
                    DispatchQueue.main.async {
                        let viewController:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                        viewController.otherMsIsdn = payload["userId"] as? String ?? ""
                        self.navigationController?.pushView(viewController, animated: true)
                    }
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    func urlTextClicked(_ label: ExpandableLabel,strURL:String) {
        let point = label.convert(CGPoint.zero, to: tblVideos)
        if let indexPath = tblVideos.indexPathForRow(at: point) as IndexPath? {
            if let objWallPost = arrFeedsVideo[indexPath.row] as? WallPostModel {
                if objWallPost.sharedWallData == nil {
                    if objWallPost.userInfo?.celebrity == 1 || objWallPost.userInfo?.celebrity == 4{
                        let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
                        vc.urlString = strURL
                        AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
                    }
                }else {
                    if objWallPost.sharedWallData.userInfo?.celebrity == 1 || objWallPost.sharedWallData.userInfo?.celebrity == 4{
                        let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
                        vc.urlString = strURL
                        AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
}


extension FeedsVideoViewController {
    
    // MARK: Cell delegate methods Notification Received
    @objc func feedCommentAddedNotification(notification: Notification) {
        
        //print("Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            let commentText = objDict["commentText"] as? String ?? ""
            let isFromShared = objDict["isFromShared"] as? Bool ?? false
            let isFromDelete = objDict["isFromDelete"] as? Bool ?? false
            let commentCount = objDict["commentCount"] as? Int16 ?? 0

            if let selPostIndex = arrFeedsVideo.firstIndex(where:{$0 .id == feedId}) {
                guard  var objWallPost = arrFeedsVideo[selPostIndex] as? WallPostModel else{
                    return
                }
                
                let count =  (isFromDelete == true ) ? (objWallPost.totalComment - 1) : (objWallPost.totalComment + 1)
                
                objWallPost.totalComment = count
                arrFeedsVideo[selPostIndex] = objWallPost
                let indexPth:IndexPath = IndexPath(row: selPostIndex, section: 0)
                
                var cell:FeedsVideoViewCell?
                if isFromShared == true {
                    cell = tblVideos.cellForRow(at: indexPth) as? FeedsVideoViewCell
                }else{
                    cell = tblVideos.cellForRow(at: indexPth) as? FeedsVideoViewCell
                }
                cell?.objWallPost = objWallPost
                cell?.btnCommentCount.setTitle(objWallPost.totalComment.asFormatted_k_String, for: .normal)
                cell?.lblLikesCountClip.text = objWallPost.totalComment.asFormatted_k_String
                cell?.btnCommentCountClip.setTitle(objWallPost.totalComment.asFormatted_k_String, for: .normal)
                
                self.delegate?.getUpdatedData( postbj: objWallPost)
            }
        }
        
        
    }
    
    @objc func feedsLikedReceivedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            let isLike = objDict["isLike"] as? Int16 ?? 0
            let likeCount = objDict["likeCount"] as? UInt ?? 0

            if let objIndex = arrFeedsVideo.firstIndex(where:{$0.id == feedId}) {
                arrFeedsVideo[objIndex].isLike = isLike
                arrFeedsVideo[objIndex].totalLike = likeCount
        
                let cell = self.tblVideos.cellForRow(at: IndexPath(row: objIndex, section: 0)) as? FeedsVideoViewCell
                cell?.lblLikesCount.text = likeCount.asFormatted_k_String
                cell?.lblLikesCountClip.text = likeCount.asFormatted_k_String
                
                if arrFeedsVideo[objIndex].isLike == 1 {
                   
                    cell?.btnLike.setImage( PZImages.heart_Filled, for: .normal)
                }else {
                    cell?.btnLike.setImage( PZImages.heartWhite_blank, for: .normal)
                }
                
                self.delegate?.getUpdatedData( postbj: arrFeedsVideo[objIndex])
            }
        }
    }
    
    @objc func feedRemovedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            
            if let objIndex = arrFeedsVideo.firstIndex(where:{$0.id == feedId}) {
                
                DispatchQueue.main.async {
                    self.arrFeedsVideo.remove(at: objIndex)
                    self.tblVideos.beginUpdates()
                    let indexPath = IndexPath(row: objIndex, section: 0)
                    self.tblVideos.deleteRows(at: [indexPath] , with: .fade)
                    self.tblVideos.endUpdates()
                    self.tblVideos.reloadData()
                }
                
            }
        }
    }
    
    @objc func feedTagRemovedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
       
        if let objDict = notification.object as? Dictionary<String, Any> {
                let feedId = objDict["feedId"] as? String ?? ""
                
            if let objIndex = arrFeedsVideo.firstIndex(where:{$0.id == feedId}) {

               // if let objIndex = arrFeedsVideo.firstIndex(where:{($0 as? WallPostModel)?.feedId == feedId}) {
                   
                    if var objWallpost = arrFeedsVideo[objIndex] as? WallPostModel {
                        objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "@\(Themes.sharedInstance.getPickzonId())", with: "")
                        objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "  ", with: " ")
                        self.arrFeedsVideo[objIndex] = objWallpost
                        DispatchQueue.main.async {
                            self.tblVideos.reloadData()
                        }
                    }
                    
            }
        }
    }
    
    
    @objc func feedExpandedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            let isExpanded = objDict["isExpanded"] as? Bool ?? false
            
            if let objIndex = arrFeedsVideo.firstIndex(where:{$0.id == feedId}) {
                arrFeedsVideo[objIndex].isExpanded = isExpanded
                tblVideos.reloadRows(at: [IndexPath(row: objIndex, section: 0)], with: .none)
            }
        }
    }
    
    @objc func feedFollwedNotification(notification: Notification) {

        print("FeedsVideoViewController : Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            let userId = objDict["userId"] as? String ?? ""
            let isFollowed = objDict["isFollowed"] as? Int ?? 0
            
            for index in 0..<arrFeedsVideo.count {
                autoreleasepool {
                    var  objWallPost = arrFeedsVideo[index]
                    
                    if objWallPost.userInfo?.id == userId {
                        objWallPost.isFollowed = isFollowed
                        arrFeedsVideo[index] = objWallPost
                        if let  cell = self.tblVideos.cellForRow(at: IndexPath(row: index, section: 0)) as? FeedsVideoViewCell{
                            cell.btnFolow.isHidden = objWallPost.isFollowed == 1 ? true : false
                        }
                        self.delegate?.getUpdatedData( postbj: objWallPost)
                        
                    }
                    
                    if objWallPost.sharedWallData != nil && objWallPost.sharedWallData.userInfo?.id == userId{
                        objWallPost.sharedWallData.isFollowed = isFollowed
                        arrFeedsVideo[index] = objWallPost
                        if objWallPost.sharedWallData == nil {
                            if let cell = self.tblVideos.cellForRow(at: IndexPath(row: index, section: 0)) as? FeedsVideoViewCell{
                                cell.btnFolow.isHidden = objWallPost.sharedWallData.isFollowed == 1 ? true : false
                            }
                        }
                        self.delegate?.getUpdatedData( postbj: objWallPost)
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
            
            if let objIndex = arrFeedsVideo.firstIndex(where:{$0.id == feedId}) {
                
                arrFeedsVideo[objIndex].isSave = isSave
                                
                if let cell = self.tblVideos.cellForRow(at: IndexPath(row: objIndex, section: 0)) as? FeedsVideoViewCell{
                    
                    cell.btnSavePost.setImage((arrFeedsVideo[objIndex].isSave == 1) ? PZImages.feedsSavePostRed : PZImages.feedsSavePost, for: .normal)
                }
                self.delegate?.getUpdatedData( postbj: arrFeedsVideo[objIndex])
            }
            
        }
    }
}

extension FeedsVideoViewController:UploadFilesDelegate{
    
    func uploadSelectedFilesDuringPost(thumbUrlArray:Array<Any>,mediaArray : [URL],mediaName:String, url:String, params:NSMutableDictionary,method:HTTPMethod?){
       
        DispatchQueue.global().async {

            URLhandler.sharedinstance.uploadArrayOfMediaWithParameters(thumbUrlArray:thumbUrlArray,mediaArray: mediaArray, mediaName: "media", url: url, params: params,method: method ?? .post) {(responseObject, error) ->  () in
                if(error != nil)
                {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    print(error ?? "defaultValue")
                    
                }else{
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int ?? 0
                    let message = result["message"] as? String ?? ""
                    mediaArray.removeSavedURLFiles()
                    thumbUrlArray.removeSavedURLFiles()
                    if status == 1{
                        
                    }else
                    {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        }
    }
}


// Support methods
extension FeedsVideoViewController:YPImagePickerDelegate {
    
    
        
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
        config.maxCameraZoomFactor = 3.0
        
        
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
                            vc.clipObj.payload = self.hashTag
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
                vc.clipObj.payload = self.hashTag
                vc.delegate = self
                self.pushView(vc, animated: true)
                
                
            }
        }
    }
    
}


extension FeedsVideoViewController:PostClipDelegate{
    func onSuccessClipUpload(clipObj: WallPostModel, selectedIndex: Int) {
        
    }
}

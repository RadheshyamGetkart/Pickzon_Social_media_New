//
//  FeedsVideoViewCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 11/29/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import UIKit
import ActiveLabel
import Kingfisher
import FittedSheets
import AudioToolbox
import Photos
import Alamofire
import MarqueeLabel

class ClipTblCell:UITableViewCell, OptionDelegate {

    
    @IBOutlet weak var profilePicView:ImageWithFrameImgView!

    @IBOutlet weak var cnstrntHtBottomVw: NSLayoutConstraint!
    @IBOutlet weak var cnstrntBottomBottomVw: NSLayoutConstraint!

    @IBOutlet weak var controlView: GSPlayerControlUIView!
    @IBOutlet weak var videoView: VideoPlayerView!
    @IBOutlet weak var btnFolow: UIButton!
  //  @IBOutlet weak var btnUserImage: UIButton!
   // @IBOutlet weak var btnUserName: UIButton!
    @IBOutlet weak var constPickZonIDHeight: NSLayoutConstraint!
   // @IBOutlet weak var constUserNameHeight: NSLayoutConstraint!
    @IBOutlet weak var btnTikTokName: UIButton!
    @IBOutlet weak var lblDescription: ExpandableLabel!
    @IBOutlet weak var imgVwThumb: UIImageView!
    @IBOutlet weak var imgVwCelebrity: UIImageView!
    @IBOutlet weak var viewUser: UIView!
    @IBOutlet weak var bgVwSound: UIView!
    @IBOutlet weak var bgVwComment: UIView!
    @IBOutlet weak var bgVwLike: UIView!
    @IBOutlet weak var bgVwShare: UIView!
    @IBOutlet weak var bgVwCoinUp: UIView!
    @IBOutlet weak var bgVwOption: UIView!
    @IBOutlet weak var btnLikeClip: SparkButton!
    @IBOutlet weak var lblLikesCountClip: UILabel!
    @IBOutlet weak var btnCoinUpClip:UIButton!
    @IBOutlet weak var btnOptionClip:UIButton!
    @IBOutlet weak var btnCommentClip: UIButton!
    @IBOutlet weak var btnCommentCountClip:UIButton!
    @IBOutlet weak var btnShareClip: UIButton!
    @IBOutlet weak var btnShareCountClip: UIButton!
    @IBOutlet weak var bgVwView: UIView!
    @IBOutlet weak var lblViewCount: UILabel!
    
    @IBOutlet weak var stackViewRightBar:UIStackView!
    @IBOutlet weak var viewMuteUnmute: UIView!
    @IBOutlet weak var btnMuteUnmute: UIButton!
    @IBOutlet weak var btnSound: UIButton!
    @IBOutlet weak var lblSoundName: MarqueeLabel!
    @IBOutlet weak var imgVwSongIcon: UIImageView!
    @IBOutlet weak var constVideoBottom: NSLayoutConstraint!

    var url:String = ""
    var urlArray:Array<String> = Array<String>()
    var thumbArray:Array<String> = Array<String>()
    var urlDimensionArray:Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()
    var objWallPost:ClipModel!
    var isSeenApiCalled = false
    var clipType:ClipVideosType = .all
    
    override func awakeFromNib() {
        // Initialization code
        self.btnLikeClip.sparkView.stop()

        btnFolow.layer.cornerRadius =  5.0
        btnFolow.layer.borderColor = UIColor.white.cgColor
        btnFolow.layer.borderWidth = 1.0
        videoView.backgroundColor = UIColor.clear
        lblDescription.numberOfLines = 3
        lblDescription.collapsed = true
        lblDescription.collapsedAttributedLink = NSAttributedString(string: " Read more" ,attributes:  [.foregroundColor:UIColor.systemBlue])
        
        viewMuteUnmute.layer.cornerRadius = viewMuteUnmute.frame.height / 2.0
        viewMuteUnmute.isHidden = true
        
        self.btnSound.layer.cornerRadius =  5.0
        self.btnSound.clipsToBounds = true
        self.profilePicView.initializeView()
        
        self.btnShareClip.setImageTintColor(.white)
        self.btnCommentClip.setImageTintColor(.white)
        self.btnLikeClip.setImageTintColor(.white)
        
        
        
        
    }
    
    
    func configurePlayer(indexPath:IndexPath, isLoadPrevious:Bool = false){
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        self.controlView.addGestureRecognizer(tap)
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap1.numberOfTapsRequired = 2
        self.controlView.addGestureRecognizer(tap1)
        tap.require(toFail: tap1)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        longPressRecognizer.allowableMovement = 50
        self.controlView.addGestureRecognizer(longPressRecognizer)
        videoView.isClipVideo = true
        videoView.setURLToPlay(for: URL(string:url)!)
        
        videoView.pausedReason = .userInteraction
        self.imgVwThumb.isHidden = true
        controlView.populate(with: videoView)
        
        stackViewRightBar.isHidden = false
        
        self.controlView.btnSpeaker.isHidden = true
        self.controlView.play_Button.isHidden = true
        self.controlView.currentDuration_Label.isHidden = true
        self.controlView.totalDuration_Label.isHidden = true
        
        self.controlView.duration_Slider.thumbTintColor = .clear
        self.controlView.duration_Slider.setThumbImage(UIImage(), for: .normal)
        
        self.btnOptionClip.setImageTintColor(.white)
        controlView.setNeedsDisplay()
        
        if (clipType == .hashtag || clipType == .single || clipType == .user) && UIDevice().hasNotch{
            //cnstrntHtBottomVw.constant = 18
            cnstrntBottomBottomVw.constant = 30
            controlView.constBottom.constant =  -2
            
        }else{
            //cnstrntHtBottomVw.constant = 1
            cnstrntBottomBottomVw.constant = 20
            controlView.constBottom.constant =  -18
            
        }
        
        if Double(objWallPost.dimension?.height ?? 0) > Double(objWallPost.dimension?.width ?? 0) * 1.7 {
            
           // if UIDevice().hasNotch {
                videoView.contentMode =  .scaleAspectFill
                controlView.thumbImageView.contentMode = .scaleAspectFill
//            }else {
//                videoView.contentMode =  .scaleAspectFit
//                controlView.thumbImageView.contentMode = .scaleAspectFit
//            }
            
        }else{
            videoView.contentMode =   .scaleAspectFit
            controlView.thumbImageView.contentMode = .scaleAspectFit
        }
        self.view.bringSubviewToFront(controlView)
        
        controlView.videoPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.3, preferredTimescale: 60), using: { [weak self] _ in
            if self != nil
            {
                if (self?.controlView.videoPlayer.currentDuration ?? 0)  > 0.5  && (self?.isSeenApiCalled ?? false)  == false {
                    print("seconds=\((self?.controlView.videoPlayer.currentDuration ?? 0))")
                    self?.isSeenApiCalled = true
                    self?.seenClipsApi()
                }else{
                    
                }
            }
        })
    }
       
    
    func configureWallPostItem(objWallPost:ClipModel,indexPath:IndexPath,states:Bool){
        self.btnLikeClip.sparkView.stop()
        self.objWallPost = objWallPost
        self.lblDescription.setLessLinkWith(lessLink: "Read less", attributes: [.foregroundColor:UIColor.red], position: .left)
       
        self.btnTikTokName.setTitle( objWallPost.userInfo?.pickzonId ?? "" , for: .normal)
            
     /*   let strUserName = self.getUpdatedHeadlineAndPosoition(isShared: false)
            if strUserName.count > 0 {
                constPickZonIDHeight.constant = 25
                constUserNameHeight.constant = 20
                
            }else {
                constPickZonIDHeight.constant = 45
                constUserNameHeight.constant = 0
            }
        self.btnUserName.setTitle(strUserName , for: .normal)
            */
        self.bgVwShare.isHidden = false
        self.bgVwComment.isHidden = false
       
        if objWallPost.commentType == 0{
            self.bgVwComment.isHidden = true
        }
        
        if objWallPost.shareType == 0{
            self.bgVwShare.isHidden = true
        }
        
       
        self.btnFolow.isHidden = (objWallPost.isFollow == 0) ? false : true
        self.btnFolow.tag = indexPath.row
        
        if Themes.sharedInstance.Getuser_id() == (objWallPost.userInfo?.userId ?? ""){
            self.btnFolow.isHidden = true
        }
        
        if objWallPost.description.count == 0  {
            self.lblDescription.attributedText =  NSAttributedString(string: "")
        }else{
            self.lblDescription.attributedText =  objWallPost.description.convertAttributtedColorText()
        }
        
        self.btnFolow.setTitle("+ Follow", for: .normal)
        
//        self.btnUserImage.kf.setImage(with:  URL(string: objWallPost.userInfo?.profilePic ?? "") , for: .normal, placeholder:PZImages.avatar , options: nil)
//        self.btnUserImage.contentMode = .scaleAspectFit
//        self.btnUserImage.imageView?.contentMode = .scaleAspectFill
        
        self.profilePicView.setImgView(profilePic: objWallPost.userInfo?.profilePic ?? "", frameImg: objWallPost.userInfo?.avatar ?? "")
      
        
        self.btnLikeClip.setImage((objWallPost.isLike == 1) ? PZImages.heart_Filled : PZImages.heartWhite_blank, for: .normal)

        self.profilePicView.imgVwProfile?.tag = indexPath.row
      //  self.btnUserImage.tag = indexPath.row
        //self.btnUserName.tag = indexPath.row
        self.btnCommentCountClip.tag = indexPath.row
        self.btnCommentCountClip.setTitle(objWallPost.commentCount.asFormatted_k_String, for: .normal)
        self.lblLikesCountClip.tag = indexPath.row
        self.lblLikesCountClip.text =  objWallPost.likeCount.asFormatted_k_String
        self.btnShareCountClip.setTitle(objWallPost.shareCount.asFormatted_k_String, for: .normal)
        self.lblViewCount.text =  objWallPost.viewCount.asFormatted_k_String
        
        self.imgVwCelebrity.isHidden = true
        
            if objWallPost.userInfo?.celebrity == 1 {
                self.imgVwCelebrity.isHidden = false
                self.imgVwCelebrity.image = PZImages.greenVerification
            }else if objWallPost.userInfo?.celebrity == 4 {
                self.imgVwCelebrity.isHidden = false
                self.imgVwCelebrity.image = PZImages.goldVerification
            }else if objWallPost.userInfo?.celebrity == 5 {
                self.imgVwCelebrity.isHidden = false
                self.imgVwCelebrity.image = PZImages.blueVerification
            }
     
        self.bgVwCoinUp.isHidden = (objWallPost.isCoinUp == 0 || Themes.sharedInstance.Getuser_id() == objWallPost.userInfo?.userId ?? "") ? true : false
        
        if (objWallPost.songInfo?.name.count ?? 0) > 0{
            self.imgVwSongIcon.isHidden = false
            if objWallPost.isOriginal == 1 {
                self.lblSoundName.text =  "\(objWallPost.songInfo?.name ?? "") - Original sound"
            }else {
                self.lblSoundName.text =  "\(objWallPost.songInfo?.name ?? "")"
            }
            
            self.bgVwSound.isHidden = false
            self.btnSound.kf.setImage(with: URL(string: objWallPost.songInfo?.thumbUrl ?? "") , for: .normal, placeholder:PZImages.avatar , options: nil)
        }else{
            self.imgVwSongIcon.isHidden = true
            self.lblSoundName.text = ""
            self.bgVwSound.isHidden = true
        }

    }
    
    
    func getUpdatedHeadlineAndPosoition(isShared:Bool)->String{
     
            if (objWallPost.userInfo?.headlines ?? "").count > 0 && (objWallPost.userInfo?.jobProfile ?? "").count > 0 {
                return "\(objWallPost.userInfo?.jobProfile ?? "") | \(objWallPost.userInfo?.headlines ?? "")"
                
            }else if (objWallPost.userInfo?.headlines ?? "").count > 0 && (objWallPost.userInfo?.jobProfile ?? "").count == 0 {
                return "\(objWallPost.userInfo?.headlines ?? "")"
                
            }else if (objWallPost.userInfo?.headlines ?? "").count == 0 && (objWallPost.userInfo?.jobProfile ?? "").count > 0 {
                return "\(objWallPost.userInfo?.jobProfile ?? "")"
            }else{
//                if objWallPost.userInfo?.showName == 1 {
//                    return "\(objWallPost.userInfo?.name ?? "")"
//                }else {
                    return ""
               // }
            }
        }
}


extension ClipTblCell {
    //MARK: Selector Methods
    
    
  @objc func coinUpBtnAction() {
      if #available(iOS 13.0, *) {
          
          let controller = StoryBoard.feeds.instantiateViewController(identifier: "CheerCoinVC")
          as! CheerCoinVC
        //  controller.objWallPost = self.objWallPost
          
          controller.postId = self.objWallPost.id
          controller.userId = self.objWallPost.userInfo?.userId ?? ""
          controller.pickzonId = self.objWallPost.userInfo?.pickzonId ?? ""
          controller.type = 1
          
          let useInlineMode = view != nil
          controller.title = "Cheer Coins"
          controller.delegate = self
          let nav = UINavigationController(rootViewController: controller)
      
          var fixedSize =  300 //365
          if UIDevice().hasNotch{
              fixedSize =  320 //380
          }
          
          let sheet = SheetViewController(
              controller: nav,
              sizes: [.fixed(CGFloat(fixedSize)),.intrinsic],
              options: SheetOptions(pullBarHeight : 0, presentingViewCornerRadius : 0 , useInlineMode: useInlineMode))
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
  

    @objc  func handleTap() {
        /*if self.videoView.state == .playing {
         videoView.pause(reason:.userInteraction)
         }else {
         if videoView.isEndPlaying == true {
         videoView.isEndPlaying  = false
         videoView.player?.seek(to: CMTime.zero)
         videoView.resume()
         }else if videoView.state != .playing {
         videoView.resume()
         }
         }
         controlView.updateSpeakerImage()
         */
        
        controlView.speakerBtnAction(sender: UIButton())
        
        self.showHideSpeakerButton()
    }
    
    func showHideSpeakerButton(){
        
        if self.controlView.videoPlayer?.player?.isMuted == true {
            btnMuteUnmute.setImage(UIImage(named: "mutePlayer"), for: .normal)
        }else {
            btnMuteUnmute.setImage(UIImage(named: "unMutePlayer"), for: .normal)
        }
        
        UIView.transition(with: self.viewMuteUnmute, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.viewMuteUnmute.isHidden = false
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.transition(with: self.viewMuteUnmute, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.viewMuteUnmute.isHidden = true
            })
        }
    }
    
    
    @objc func doubleTapped() {
        if objWallPost.isLike == 0{
            likeDislikePostAPICall()
        }else{
            self.handleTap()
        }
    }
    
    
    @objc func longPressed(sender: UILongPressGestureRecognizer)
    {
        print("longpressed")
        //Different code
        if sender.state != UIGestureRecognizer.State.ended {
            //When lognpress is start or running
            if self.videoView.state == .playing {
                videoView.pause(reason:.userInteraction)
                self.viewUser.isHidden = true
                self.stackViewRightBar.isHidden = true

            }
        }else {
            if sender.state == UIGestureRecognizer.State.ended {
                //When lognpress is start or running
                if videoView.isEndPlaying == true {
                    videoView.isEndPlaying  = false
                    videoView.player?.seek(to: CMTime.zero)
                    videoView.resume()
                }else if videoView.state != .playing {
                    videoView.resume()
                }
                self.viewUser.isHidden = false
                self.stackViewRightBar.isHidden = false
            }
        }
        controlView.updateSpeakerImage()
    }
    
    
    @objc func addTargetButtons() {
           
            self.profilePicView?.imgVwProfile?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                      action:#selector(self.handleProfilePicTap(_:))))
            btnFolow.addTarget(self, action: #selector(self.followBtnAction), for: .touchUpInside)
          //  btnUserImage.addTarget(self, action: #selector(self.openProfile), for: .touchUpInside)
           // btnUserName.addTarget(self, action: #selector(self.openProfile), for: .touchUpInside)
            btnLikeClip.addTarget(self, action: #selector(self.likeDislikePostAPICall), for: .touchUpInside)
            btnOptionClip.addTarget(self, action: #selector(self.optionBtnAction), for: .touchUpInside)
            btnShareClip.addTarget(self, action: #selector(self.sharePostAPI), for: .touchUpInside)
            lblLikesCountClip.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickedonLikeCount(_ : ))))
            btnCommentClip.addTarget(self, action: #selector(self.openComments(sender:)), for: .touchUpInside)
            btnCommentCountClip.addTarget(self, action: #selector(self.openComments(sender:)), for: .touchUpInside)
            btnCoinUpClip.addTarget(self, action: #selector(self.coinUpBtnAction), for: .touchUpInside)
    }
    
    
    @objc func savePostAPI() {
        
       /* if objWallPost.isSave == 0 {
            saveWallPost()
        }else{
            AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to remove selected post from saved list?", buttonTitles: ["Yes","No"], onController: (AppDelegate.sharedInstance.navigationController?.topViewController)!) { title, index in
                if index == 0{
                    self.saveWallPost()
                }
            }
        }*/
    }
    
    func saveWallPost() {
      /*
        Themes.sharedInstance.activityView(View: self.view)
        let url = Constant.sharedinstance.savePostURL
        
        let params = NSMutableDictionary()
        if objWallPost.sharedWallData == nil {
            params.setValue("\(objWallPost.id)", forKey: "feedId")
        }else{
            params.setValue("\(objWallPost.sharedWallData.id)", forKey: "feedId")
        }
        
        URLhandler.sharedinstance.makePostAPICall(url:url as String, param: params, completionHandler: {(responseObject, error) ->  () in
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
                    let payload = result["payload"] as? Dictionary<String,Any> ?? [:]
                    self.objWallPost.isSave = payload["isSave"] as? Int16 ?? 0
                    
                    
//                    if self.objWallPost.isSave == 1 {
//                        self.btnSavePost.setImage(UIImage(named: "feedsSavePostRed"), for: .normal)
//                    }else {
//                        
//                        self.btnSavePost.setImage(UIImage(named: "feedsSavePost"), for: .normal)
//                    }
                    let objDict = ["feedId":self.objWallPost.feedId, "isSave":self.objWallPost.isSave] as [String : Any]
                    
                    NotificationCenter.default.post(name: nofit_FeedSaved, object: objDict)
                    
                    
                    (AppDelegate.sharedInstance.navigationController?.topViewController)!.view.makeToast(message: message , duration: 2, position: HRToastActivityPositionDefault)
                    
                }else{
                    (AppDelegate.sharedInstance.navigationController?.topViewController)!.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
        */
    }
    
    
    func seenClipsApi(){
        
        let params = NSMutableDictionary()
        params.setValue("\(objWallPost.id)", forKey: "clipId")
        URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.clip_clip_seen, param: params, completionHandler: {(responseObject, error) ->  () in
            if(error != nil)
            {
               // self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                
            }
        })
    }
    
    
    @objc func likeDislikePostAPICall() {
        
        let params = NSMutableDictionary()
        params.setValue("\(objWallPost.id)", forKey: "clipId")
        params.setValue(((objWallPost.isLike == 0) ? 1 : 0), forKey: "action")
        
        if objWallPost.isLike == 0 {
            self.btnLikeClip.setImage(PZImages.heart_Filled, for: .normal)
            self.btnLikeClip.likeBounce(0.6)
            self.btnLikeClip.animate()
        }else {
            self.btnLikeClip.setImage(PZImages.heartWhite_blank, for: .normal)
            self.btnLikeClip.likeBounce(0.4)
        }
        
        URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.clip_like_dislike, param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1 {
                    let payload = result["payload"] as? Dictionary<String,Any> ?? [:]
                    let isLike = payload["isLike"] as? Int ?? 0
                    
                    self.objWallPost.isLike = isLike
                    
                    if isLike == 1 {
                        self.objWallPost.likeCount =  self.objWallPost.likeCount + 1
                    }else {
                        if self.objWallPost.likeCount > 0 {
                            self.objWallPost.likeCount =  self.objWallPost.likeCount - 1
                        }
                    }
                    self.lblLikesCountClip.text = self.objWallPost.likeCount.asFormatted_k_String
                
                   // var likeCount = payload["likeCount"] as? String  ?? "0"
                    let objDict = ["clipId":self.objWallPost.id, "isLike":isLike, "likeCount":self.objWallPost.likeCount ] as [String : Any]
                     NotificationCenter.default.post(name: notif_ClipLiked, object: objDict)
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
        
    }
    
    
    @objc func clickedonLikeCount(_ sender:UITapGestureRecognizer){
        let profileVC:LikeUsersVC = StoryBoard.main.instantiateViewController(withIdentifier: "LikeUsersVC") as! LikeUsersVC
        //profileVC.postId = objWallPost.id
        profileVC.postId = objWallPost.sharedWallData == nil ? objWallPost.id : objWallPost.sharedWallData.id
        profileVC.controllerType = .clipLikeList
        (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(profileVC, animated: true)
    }
    
   
    @objc func openComments(sender:UIButton)
    {
        if #available(iOS 13.0, *) {
            
            let storyBord:UIStoryboard = UIStoryboard(name: "ClipComment", bundle: nil)

            let controller = storyBord.instantiateViewController(identifier: "ClipCommentVC")
            as! ClipCommentVC
            controller.clipId = objWallPost.id
             controller.delegate = self
            let useInlineMode = view != nil
            
            let nav = UINavigationController(rootViewController: controller)
            
            let sheet = SheetViewController(
                controller: nav,
                sizes: [.percent(0.90),.fullscreen],
                options: SheetOptions(presentingViewCornerRadius : 0 , useInlineMode: useInlineMode))
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
    
    
    @objc func sharePostAPI() {
        
        ShareMedia.shareMediafrom(type: .clips, mediaId: objWallPost.id, controller: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
    }
    
    
    
    
    @objc func blockPostApi(postIndex:Int){
        /*
        Themes.sharedInstance.activityView(View: self.view)
        
        let params = NSMutableDictionary()
        params.setValue("\(objWallPost.id)", forKey: "feedId")
        
        URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.blockPost as String, param: params, completionHandler: {(responseObject, error) ->  () in
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
                if status == 1{
                    
                    let objDict = ["feedId":self.objWallPost.feedId]
                    NotificationCenter.default.post(name: notif_FeedRemoved, object: objDict)
                    
                    AlertView.sharedManager.displayMessage(title: "PickZon", msg: message, controller: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
        */
    }
    
    
    @objc func deleteClipApi(){
       
        let param:NSDictionary = ["clipId":objWallPost.id]
       
        URLhandler.sharedinstance.makeCall(url: Constant.sharedinstance.deleteClipVideo, param: param, completionHandler: {(responseObject, error) ->  () in
                   Themes.sharedInstance.RemoveactivityView(View: self.view)
                   if(error != nil)
                   {
                       self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                   }
                   else{
                       let result = responseObject! as NSDictionary
                       let status = result["status"] as? Int ?? 0
                       let message = result["message"] as? String ?? ""
                      
                       if status == 1{
                          
                           let objDict = ["clipId":self.objWallPost.id]
                           NotificationCenter.default.post(name: notif_ClipRemoved, object: objDict)
                           
                           AlertView.sharedManager.displayMessage(title: "Pickzon", msg: message, controller: AppDelegate.sharedInstance.navigationController!.topViewController!)
                       }
                       else
                       {
                           self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                       }
                   }
        })
    }
    
    
    
    @objc func optionBtnAction() {
        
        let controller = UIStoryboard(name: "TableViewDemo", bundle: nil).instantiateInitialViewController()! as! TableViewDemo
       
        if (objWallPost.userInfo?.userId ?? "") == Themes.sharedInstance.Getuser_id(){
            
            if objWallPost.downloadType == 1 {
                controller.listArray =  ["Download","Edit","Delete"]
                controller.iconArray =  ["DownloadVideo","EditIcon","Delete1"]
            }else{
                controller.listArray =  ["Edit","Delete"]
                controller.iconArray =  ["EditIcon","Delete1"]
            }
            
        }else {
            if objWallPost.downloadType == 1 {
                controller.listArray =  ["Download","Report"]
                controller.iconArray =  ["DownloadVideo","Report"]
            }else {
                controller.listArray =  ["Report"]
                controller.iconArray =  ["Report"]
            }
        }
       
        let percentage:Double = (controller.listArray.count > 1)  ? 0.25 : 0.20
        
        //controller.videoIndex = sender.tag
        controller.delegate = self
        let useInlineMode = AppDelegate.sharedInstance.navigationController!.topViewController!.view != nil
        
        let sheet = SheetViewController(
            controller: controller,
            sizes: [.percent(Float(percentage)), .intrinsic],
            options: SheetOptions(useFullScreenMode:false, shrinkPresentingViewController:false, useInlineMode: useInlineMode))
        sheet.allowPullingPastMaxHeight = false
        if let view = AppDelegate.sharedInstance.navigationController?.topViewController?.view {
            sheet.animateIn(to: view, in: AppDelegate.sharedInstance.navigationController!.topViewController!)
        } else {
            AppDelegate.sharedInstance.navigationController?.topViewController!.present(sheet, animated: true, completion: nil)
        }
    }
    
    
    //MARK: Delegete method of bottom sheet view
    func selectedOption(index:Int,videoIndex:Int,title:String) {
        
        if title == "Share"{
            ShareMedia.shareMediafrom(type: .clips, mediaId: objWallPost.id, controller: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
            
        }else  if title == "Download"{
            
            self.downloadVideosAPI(type: 1)
            
        }else  if title == "Delete"{
            
            AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to delete selected clip?", buttonTitles: ["Yes","No"], onController: (AppDelegate.sharedInstance.navigationController?.topViewController)!) { title, index in
                
                if index == 0{
                    self.deleteClipApi()
                }
            }
            
        }else  if title == "Edit"{
            
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "PostClipVC") as? PostClipVC{
                destVC.isEditVideoPost = true
               // destVC.clipObj = objWallPost
                destVC.delegate = self
                destVC.selectedIndex = videoIndex
                AppDelegate.sharedInstance.navigationController?.pushViewController(destVC, animated: true)
            }
            
        }else  if title == "Block Post"{
            
            self.blockPostApi(postIndex: videoIndex)
            
        }else  if title == "Report"{
            
             let destVc:ReportUserVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ReportUserVC") as! ReportUserVC
             destVc.modalPresentationStyle = .overCurrentContext
             destVc.modalTransitionStyle = .coverVertical
             destVc.reportType = .clip
             destVc.reportingId = objWallPost.id
             AppDelegate.sharedInstance.navigationController?.topViewController?.present(destVc, animated: true, completion: nil)
        }
        
    }
    
    
    func downloadVideosAPI(type:Int){
        
        //"type":1 // type –1 download | 0-delete
        
        Themes.sharedInstance.showActivityViewTop(View: (AppDelegate.sharedInstance.navigationController?.topViewController?.view)!, isTop: true)
       
        let params:NSDictionary = ["url":objWallPost.url,"type":type]
        
        URLhandler.sharedinstance.makeCall(url: Constant.sharedinstance.clip_download_clip, param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
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
               
                if type == 1{
                    
                    if status == 1 {
                        
                        let data = result["payload"] as? NSDictionary ?? [:]
                        self.downloadMedia(mediaUrl: data["url"] as? String ?? "")
                        
                    } else  {
                        DispatchQueue.main.async {
                            self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        AppDelegate.sharedInstance.navigationController?.topViewController?.view?.makeToast(message: "Downloaded successfully" , duration: 2, position: HRToastPositionCenter)
                    }
                }
            }
        })
        
    }
    
    func downloadMedia(mediaUrl:String){
        
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: mediaUrl), let urlData = NSData(contentsOf: url) {
                let galleryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let fileName = url.lastPathComponent
                let filePath="\(galleryPath)/\(Int(Date().timeIntervalSince1970))\(fileName)"
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        
                        if checkMediaTypes(strUrl:mediaUrl) == 1{
                            PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL:
                                                                                    URL(fileURLWithPath: filePath))
                        }else {
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL:
                                                                                    URL(fileURLWithPath: filePath))
                        }
                        DispatchQueue.main.async {
                            self.downloadVideosAPI(type: 0)

                          //  self.downloadCleanAPI(mediaURL: mediaUrl)
                        }
                        
                        
                    }) {
                        
                        success, error in
                        if success {
                            print("Succesfully Saved")
                            
                            if FileManager.default.fileExists(atPath: filePath) {
                                // delete file
                                do {
                                    try FileManager.default.removeItem(atPath: filePath)
                                } catch {
                                    print("Could not delete file, probably read-only filesystem")
                                }
                            }
                            
                        } else {
                            print(error?.localizedDescription ?? "")
                        }
                    }
                    
                }
                
            }
        }
        
    }
    
    
    func downloadCleanAPI(mediaURL:String){
        
        let params:NSDictionary = ["url":mediaURL]
        URLhandler.sharedinstance.makeCall(url: Constant.sharedinstance.getDownloadCleanURL, param: params, completionHandler: {(responseObject, error) ->  () in
            
            if(error != nil)
            {
                DispatchQueue.main.async {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    print(error ?? "defaultValue")
                }
            }else{
                DispatchQueue.main.async {
                    AppDelegate.sharedInstance.navigationController?.topViewController?.view?.makeToast(message: "Downloaded successfully" , duration: 2, position: HRToastPositionCenter)
                }
            }
        })
        
    }
    
    @objc  func handleProfilePicTap(_ sender: UITapGestureRecognizer? = nil){
        
        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.otherMsIsdn = objWallPost.userInfo?.userId ?? ""
        AppDelegate.sharedInstance.navigationController?.pushViewController(profileVC, animated: true)
        
    }

    
@objc func openProfile(){
    
    let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
    profileVC.otherMsIsdn = objWallPost.userInfo?.userId ?? ""
    AppDelegate.sharedInstance.navigationController?.pushViewController(profileVC, animated: true)
}
    
    @objc func followBtnAction(){
     
        let userId = objWallPost.userInfo?.userId ?? ""
       
        let param:NSDictionary = ["followedUserId":userId,"status":"1"]
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.follow as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                let payloadDict = result["payload"] as? NSDictionary ?? [:]
//              let statusType = payloadDict["statusType"] as? String ?? ""
//              let followStatus = payloadDict["status"] as? Int ?? 0
                
                if status == 1{
                    DispatchQueue.main.async {
                        self.objWallPost.isFollow = 1
                        self.btnFolow.isHidden = true
                        AppDelegate.sharedInstance.navigationController?.view.makeToast(message: message , duration: 1, position: HRToastActivityPositionDefault)
                    }
                    let objDict:Dictionary<String, Any> = [ "userId":userId, "isFollowed":1]
                    NotificationCenter.default.post(name: notif_FeedFollowed, object: objDict)
                    
                    
                }else{
                    AppDelegate.sharedInstance.navigationController?.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
}


extension ClipTblCell : CommentAddDelegate, UploadFilesDelegate,CoinUpDelegate,PostClipDelegate {
    
    func onSuccessClipUpload(clipObj:WallPostModel,selectedIndex:Int){
       // objWallPost = clipObj
    }
   
    func addedDelegate(index:Int,count:Int,commentCount:String){
        
        let objDict = ["clipId":self.objWallPost.id,"commentCount": (objWallPost.commentCount + count )] as [String : Any]
        NotificationCenter.default.post(name: notif_ClipCommentCount, object: objDict)
        
        self.objWallPost.commentCount =  self.objWallPost.commentCount + count
        self.btnCommentCountClip.setTitle(self.objWallPost.commentCount.asFormatted_k_String, for: .normal)
    }
    
    func cheerCoinClickedOnAvailableTokens(){
        let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
        AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
    }
    
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




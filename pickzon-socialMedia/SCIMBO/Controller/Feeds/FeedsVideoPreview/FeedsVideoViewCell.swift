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

class FeedsVideoViewCell:UITableViewCell, OptionDelegate {
    
    
    
    @IBOutlet weak var cnstrntBottomViewBgVw: NSLayoutConstraint!

    
    @IBOutlet weak var profilePicView:ImageWithFrameImgView!
    @IBOutlet weak var cnstrntLeadingNameBgVw: NSLayoutConstraint!
    @IBOutlet weak var btnCoinUp:UIButton!
    @IBOutlet weak var btnSavePost:UIButton!
    @IBOutlet weak var controlView: GSPlayerControlUIView!
    @IBOutlet weak var videoView: VideoPlayerView!
    @IBOutlet weak var btnFolow: UIButton!
    @IBOutlet weak var btnUserImage: UIButton!
    @IBOutlet weak var btnUserName: UIButton!
    @IBOutlet weak var constPickZonIDHeight: NSLayoutConstraint!
    @IBOutlet weak var constUserNameHeight: NSLayoutConstraint!
    @IBOutlet weak var btnTikTokName: UIButton!
    @IBOutlet weak var btnLike: SparkButton!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var lblLikesCount: UILabel!
    @IBOutlet weak var lblDescription: ExpandableLabel!
    @IBOutlet weak var btnOption:UIButton!
    @IBOutlet weak var btnCommentCount:UIButton!
    @IBOutlet weak var btnShareCount: UIButton!
    @IBOutlet weak var lblViewCount: UILabel!
    @IBOutlet weak var bgVwViewCount: UIView!
    @IBOutlet weak var bgVwComment: UIView!
    @IBOutlet weak var bgVwLike: UIView!
    @IBOutlet weak var bgVwShare: UIView!
    @IBOutlet weak var imgVwThumb: UIImageView!
    @IBOutlet weak var imgVwCelebrity: UIImageView!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var viewUser: UIView!
    
    @IBOutlet weak var btnLikeClip: SparkButton!
    @IBOutlet weak var lblLikesCountClip: UILabel!
    @IBOutlet weak var btnCoinUpClip:UIButton!
    @IBOutlet weak var btnOptionClip:UIButton!
    @IBOutlet weak var btnCommentClip: UIButton!
    @IBOutlet weak var btnCommentCountClip:UIButton!
    @IBOutlet weak var btnShareClip: UIButton!
    @IBOutlet weak var btnShareCountClip: UIButton!
    
    @IBOutlet weak var imgVwSongIcon: UIImageView!
    @IBOutlet weak var lblSoundName: MarqueeLabel!
    @IBOutlet weak var btnSound: UIButton!
    @IBOutlet weak var bgVwSoundClip: UIView!

    @IBOutlet weak var bgVwCoinUpClip: UIView!
    @IBOutlet weak var bgVwCommentClip: UIView!
    @IBOutlet weak var bgVwLikeClip: UIView!
    @IBOutlet weak var bgVwShareClip: UIView!
    @IBOutlet weak var stackViewRightBar:UIStackView!
    @IBOutlet weak var constViewUserBottom: NSLayoutConstraint!
    @IBOutlet weak var viewMuteUnmute: UIView!
    @IBOutlet weak var btnMuteUnmute: UIButton!
    
    var url:String = ""
    var urlArray:Array<String> = Array<String>()
    var thumbArray:Array<String> = Array<String>()
    var urlDimensionArray:Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()
    var objWallPost:WallPostModel!
    
    @IBOutlet weak var constVideoBottom: NSLayoutConstraint!
    var isClipVideo = true
    var isTohideBackButton = false

    override func awakeFromNib() {
        // Initialization code
        self.profilePicView.initializeView()
        self.btnLike.sparkView.stop()
        btnUserImage.layer.cornerRadius = btnUserImage.frame.height / 2.0
       
        btnUserImage.clipsToBounds = true
        btnFolow.layer.cornerRadius = 5.0
        btnFolow.layer.borderColor = UIColor.white.cgColor
        btnFolow.layer.borderWidth = 1.5
        videoView.backgroundColor = UIColor.clear
        lblDescription.numberOfLines = 3
        lblDescription.collapsed = true
        lblDescription.collapsedAttributedLink = NSAttributedString(string: " Read more" ,attributes:  [.foregroundColor:UIColor.systemBlue])
        btnCoinUp.layer.cornerRadius = btnCoinUp.frame.size.height/2.0
        btnCoinUp.clipsToBounds = true
        bgVwSoundClip.isHidden = true
        viewMuteUnmute.layer.cornerRadius = viewMuteUnmute.frame.height / 2.0
        viewMuteUnmute.isHidden = true
        
        self.btnSound.layer.cornerRadius =  5.0
        self.btnSound.clipsToBounds = true
        
        self.btnShareClip.setImageTintColor(.white)
        self.btnCommentClip.setImageTintColor(.white)
        self.btnLikeClip.setImageTintColor(.white)
        self.btnOptionClip.setImageTintColor(.white)
        
        self.btnLike.setImageTintColor(.white)
        self.btnComment.setImageTintColor(.white)
        self.btnShare.setImageTintColor(.white)
        self.btnOption.setImageTintColor(.white)
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
        longPressRecognizer.minimumPressDuration = 0.10
        self.controlView.addGestureRecognizer(longPressRecognizer)
        
        videoView.setURLToPlay(for: URL(string:url)!)
        videoView.isClipVideo = true
        
        videoView.pausedReason = .userInteraction
        self.imgVwThumb.isHidden = true
        controlView.populate(with: videoView)
        
        if isClipVideo == true {
            stackViewRightBar.isHidden = false
            viewBottom.isHidden = true
            self.controlView.duration_Slider.minimumTrackTintColor = UIColor.white
            self.controlView.duration_Slider.maximumTrackTintColor = UIColor.black.withAlphaComponent(0.1)
            
            if isTohideBackButton == false {
                if  UIDevice().hasNotch{
                    controlView.constBottom.constant = 20
                    constViewUserBottom.constant = 10
                    self.controlView.duration_Slider.trackHeight = 2.0
                }else {
                    controlView.constBottom.constant = -18
                    constViewUserBottom.constant = -40
                }
            }else {
                controlView.constBottom.constant = -18
                constViewUserBottom.constant = -40
            }
            
            self.controlView.btnSpeaker.isHidden = true
            self.controlView.play_Button.isHidden = true
            self.controlView.currentDuration_Label.isHidden = true
            self.controlView.totalDuration_Label.isHidden = true
            self.controlView.duration_Slider.thumbTintColor = .clear
            
            self.controlView.duration_Slider.setThumbImage(UIImage(), for: .normal)
            self.cnstrntLeadingNameBgVw.constant = 40
        }else {
            stackViewRightBar.isHidden = true
            viewBottom.isHidden = false
            self.cnstrntLeadingNameBgVw.constant = 0
            
            
            if  UIDevice().hasNotch{
                cnstrntBottomViewBgVw.constant = 21
                controlView.constBottom.constant = 60

            }else {
                cnstrntBottomViewBgVw.constant = 10
                controlView.constBottom.constant = 45
            }
        }
        
        controlView.setNeedsDisplay()
        
        var height = 0
        var width = 0
        if objWallPost.sharedWallData == nil {
            if objWallPost.urlDimensionArray.count > 0{
                let objDictDimension = objWallPost.urlDimensionArray[0]
                height = objDictDimension["height"] as? Int ?? 0
                width = objDictDimension["width"] as? Int ?? 0
            }
        }else {
            if objWallPost.sharedWallData.urlDimensionArray.count > 0{
                let objDictDimension = objWallPost.sharedWallData.urlDimensionArray[0]
                 height = objDictDimension["height"] as? Int ?? 0
                 width = objDictDimension["width"] as? Int ?? 0
            }
        }
                
        if Double(height) > Double(width) * 1.7 {
           
            if UIDevice().hasNotch {
                videoView.contentMode =  .scaleAspectFill
                controlView.thumbImageView.contentMode = .scaleAspectFill
                let ratio:CGFloat = CGFloat(height) / CGFloat(width)
                if isClipVideo == true {
                    constVideoBottom.constant = 0
                }else {
                    constVideoBottom.constant = UIScreen.main.bounds.height - UIScreen.main.bounds.width * ratio - 50
                }
                
                controlView.constThumbImageBottom.constant = constVideoBottom.constant
            }else {
                videoView.contentMode =  .scaleAspectFit
                controlView.thumbImageView.contentMode = .scaleAspectFit
                if isClipVideo == true {
                    constVideoBottom.constant = -50
                }else {
                    constVideoBottom.constant = 0
                }
                controlView.constThumbImageBottom.constant = constVideoBottom.constant
            }

        }else {
            videoView.contentMode =   .scaleAspectFit
            controlView.thumbImageView.contentMode = .scaleAspectFit
            constVideoBottom.constant = 0
            controlView.constThumbImageBottom.constant = constVideoBottom.constant
          
        }
        
        self.view.bringSubviewToFront(controlView)
    }
    
    
    func configureWallPostItem(objWallPost:WallPostModel,indexPath:IndexPath,states:Bool){
        self.btnLike.sparkView.stop()
        self.objWallPost = objWallPost
        self.lblDescription.setLessLinkWith(lessLink: "Read less", attributes: [.foregroundColor:UIColor.red], position: .left)
        var txtFeeling = ""
        if objWallPost.feeling.count > 0 {
            txtFeeling = (objWallPost.feeling["image"] as? String ?? "") + " " +  (objWallPost.feeling["name"]  as? String ?? "")
        }else if objWallPost.activities.count > 0 {
            txtFeeling = (objWallPost.activities["image"] as? String ?? "") + " " +  (objWallPost.activities["name"] as? String ?? "")
        }
        
        
        self.btnTikTokName.setTitle( objWallPost.userInfo?.pickzonId ?? "" , for: .normal)
        let strUserName = self.getUpdatedHeadlineAndPosoition(isShared: false)
        if strUserName.count > 0 {
            constPickZonIDHeight.constant = 25
            constUserNameHeight.constant = 20
        }else {
            constPickZonIDHeight.constant = 45
            constUserNameHeight.constant = 0
        }
        self.btnUserName.setTitle(strUserName , for: .normal)
        
        
        self.bgVwShare.isHidden = false
        self.bgVwComment.isHidden = false
        self.bgVwCommentClip.isHidden = false
        self.bgVwShare.isHidden = false
        self.bgVwShareClip.isHidden = false

//        if ((objWallPost.userInfo?.userProfileType.lowercased() == "private") || (objWallPost.postType.lowercased() == "friend" || objWallPost.postType.lowercased() == "private")) && Themes.sharedInstance.Getuser_id() != objWallPost.userInfo?.fromId{
//            self.bgVwShare.isHidden = true
//            self.bgVwShareClip.isHidden = true
//        }
        
        
        if ( (objWallPost.postType.lowercased() == "friend" || objWallPost.postType.lowercased() == "private")){
            /* if ((objWallPost.userInfo?.profileType.lowercased() == "private") || (objWallPost.postType.lowercased() == "friend" || objWallPost.postType.lowercased() == "private")) { */
            self.bgVwShare.isHidden = true
            self.bgVwShareClip.isHidden = true
        }
        
        if objWallPost.commentType == 1{
            self.bgVwComment.isHidden = true
            self.bgVwCommentClip.isHidden = true
        }
        
        if objWallPost.isShare == 0{
            self.bgVwShare.isHidden = true
            self.bgVwShareClip.isHidden = true
        }
        
        self.btnFolow.isHidden = (objWallPost.isFollowed == 0) ? false : true
        self.btnFolow.tag = indexPath.row
        
        if Themes.sharedInstance.Getuser_id() == objWallPost.userInfo?.id ?? "" {
            self.btnFolow.isHidden = true
        }
        
        if objWallPost.taggedPeople.count == 0 && objWallPost.payload.count == 0  && txtFeeling.count == 0 && objWallPost.taggedPeople.count == 0 {
            self.lblDescription.attributedText =  NSAttributedString(string: "")
        }else{
            self.lblDescription.attributedText =  (objWallPost.payload + txtFeeling + ((objWallPost.taggedPeople.count > 0) ? "\n\(objWallPost.taggedPeople)" : "")).convertAttributtedColorText(linkAndMentionColor: .white)
        }
        
        self.btnFolow.setTitle("+ Follow", for: .normal)
        profilePicView.setImgView(profilePic: objWallPost.userInfo!.profilePic, frameImg: objWallPost.userInfo!.avatar)
        self.btnUserImage.contentMode = .scaleAspectFit
        self.btnUserImage.imageView?.contentMode = .scaleAspectFill
        self.btnLike.setImage((objWallPost.isLike == 1) ? PZImages.heart_Filled : PZImages.heartWhite_blank, for: .normal)
        self.btnLikeClip.setImage((objWallPost.isLike == 1) ? PZImages.heart_FilledBig : PZImages.heartEmptyBig, for: .normal)
        self.btnUserImage.tag = indexPath.row
        self.btnUserName.tag = indexPath.row
        self.btnLike.tag = indexPath.row
        self.btnShare.tag = indexPath.row
        self.btnComment.tag = indexPath.row
        self.btnCommentCount.tag = indexPath.row
        self.btnCommentCount.setTitle(objWallPost.totalComment.asFormatted_k_String, for: .normal)
        self.btnCommentCountClip.tag = indexPath.row
        self.btnCommentCountClip.setTitle(objWallPost.totalComment.asFormatted_k_String, for: .normal)
        self.lblLikesCount.tag = indexPath.row
        self.lblLikesCount.text = objWallPost.totalLike.asFormatted_k_String
        self.lblLikesCountClip.tag = indexPath.row
        self.lblLikesCountClip.text = objWallPost.totalLike.asFormatted_k_String
        self.btnShareCount.setTitle(objWallPost.totalShared.asFormatted_k_String, for: .normal)
        self.btnShareCountClip.setTitle(objWallPost.totalShared.asFormatted_k_String, for: .normal)
        self.btnOption.tag = indexPath.row
        lblViewCount.text = objWallPost.viewCount.asFormatted_k_String
      
        if objWallPost.sharedWallData == nil {
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
        }else{
            self.imgVwCelebrity.isHidden = true
            if objWallPost.sharedWallData.userInfo?.celebrity == 1 {
                self.imgVwCelebrity.isHidden = false
                self.imgVwCelebrity.image = PZImages.greenVerification
            }else if objWallPost.sharedWallData.userInfo?.celebrity == 4 {
                self.imgVwCelebrity.isHidden = false
                self.imgVwCelebrity.image = PZImages.goldVerification
            }else if objWallPost.sharedWallData.userInfo?.celebrity == 5 {
                self.imgVwCelebrity.isHidden = false
                self.imgVwCelebrity.image = PZImages.blueVerification
            }
        }
        if isClipVideo == true {
            self.btnCoinUp.isHidden = true
            self.btnOption.isHidden = true
            self.bgVwCoinUpClip.isHidden = (objWallPost.isCoinUp == 0 || Themes.sharedInstance.Getuser_id() == objWallPost.userInfo?.id ?? "") ? true : false
        }else {
            self.btnCoinUp.isHidden = (objWallPost.isCoinUp == 0 || Themes.sharedInstance.Getuser_id() == objWallPost.userInfo?.id ?? "") ? true : false
        }
        
        
        if (objWallPost.soundInfo?.id ?? "").count > 0{
            
            self.bgVwSoundClip.isHidden = false
            self.lblSoundName.isHidden = false
            self.imgVwSongIcon.isHidden = false
            self.btnSound.kf.setImage(with:  URL(string: objWallPost.soundInfo!.thumb) , for: .normal, placeholder:PZImages.avatar , options: nil)
            if (objWallPost.soundInfo?.isOriginal ?? 0) == 1 {
                self.lblSoundName.text =  "\(objWallPost.soundInfo?.name ?? "") - Original sound"
            }else {
                self.lblSoundName.text =  "\(objWallPost.soundInfo?.name ?? "")"
            }
        }else{
            self.bgVwSoundClip.isHidden = true
            self.lblSoundName.isHidden = true
            self.imgVwSongIcon.isHidden = true
        }
    }
    
    
    func configureSharedWallDataPost(objWallPost:WallPostModel,indexPath:IndexPath,states:Bool){
        self.btnLike.sparkView.stop()
        self.objWallPost = objWallPost
        
        var sharedTxtFeeling = ""
        if objWallPost.sharedWallData.feeling.count > 0 {
            sharedTxtFeeling = (objWallPost.sharedWallData.feeling["image"] as? String ?? "") + " " +  (objWallPost.sharedWallData.feeling["name"]  as? String ?? "")
        }else if objWallPost.sharedWallData.activities.count > 0 {
            sharedTxtFeeling = (objWallPost.sharedWallData.activities["image"] as? String ?? "") + " " +  (objWallPost.sharedWallData.activities["name"] as? String ?? "")
        }
        
        if objWallPost.sharedWallData.taggedPeople.count == 0 && objWallPost.sharedWallData.payload.count == 0  && sharedTxtFeeling.count == 0 && objWallPost.sharedWallData.taggedPeople.count == 0 {
            self.lblDescription.attributedText =  NSAttributedString(string: "")
        }else{
            self.lblDescription.attributedText =  (objWallPost.sharedWallData.payload + sharedTxtFeeling + ((objWallPost.sharedWallData.taggedPeople.count > 0) ? "\n\(objWallPost.sharedWallData.taggedPeople)" : "")).convertAttributtedColorText( linkAndMentionColor: .white)
        }
        
        self.urlArray = objWallPost.sharedWallData.urlArray
        self.thumbArray = objWallPost.sharedWallData.thumbUrlArray
        self.urlDimensionArray = objWallPost.sharedWallData.urlDimensionArray
        
        self.btnFolow.setTitle("+ Follow", for: .normal)
        
        
        self.bgVwComment.isHidden = false
        self.bgVwCommentClip.isHidden = false
        self.bgVwShare.isHidden = false
        self.bgVwShareClip.isHidden = false
       
        if objWallPost.commentType == 1{
            self.bgVwComment.isHidden = true
            self.bgVwCommentClip.isHidden = true
        }
        
        if objWallPost.isShare == 0{
            self.bgVwShare.isHidden = true
            self.bgVwShareClip.isHidden = true
        }
        
//        if ((objWallPost.userInfo?.userProfileType.lowercased() == "private") || (objWallPost.postType.lowercased() == "friend" || objWallPost.postType.lowercased() == "private")) && Themes.sharedInstance.Getuser_id() != objWallPost.userInfo?.fromId{
//            self.bgVwShare.isHidden = true
//            self.bgVwShareClip.isHidden = true
//        }
//        
       // if ((objWallPost.userInfo?.profileType.lowercased() == "private") || (objWallPost.postType.lowercased() == "friend" || objWallPost.postType.lowercased() == "private")){
            
            if ( (objWallPost.postType.lowercased() == "friend" || objWallPost.postType.lowercased() == "private")){

            self.bgVwShare.isHidden = true
            self.bgVwShareClip.isHidden = true
        }
        
        
        self.btnFolow.isHidden = (objWallPost.sharedWallData.isFollowed == 0) ? false : true
        if Themes.sharedInstance.Getuser_id() == objWallPost.sharedWallData.userInfo?.id ?? ""{
            self.btnFolow.isHidden = true
        }
        
        profilePicView.setImgView(profilePic: objWallPost.sharedWallData.userInfo!.profilePic, frameImg: objWallPost.sharedWallData.userInfo!.avatar)
        
        self.btnUserImage.contentMode = .scaleAspectFit
        self.btnUserImage.imageView?.contentMode = .scaleAspectFill
        
        self.btnLike.setImage((objWallPost.isLike == 1) ? PZImages.heart_Filled : PZImages.heartWhite_blank , for: .normal)
        
        self.btnLikeClip.setImage((objWallPost.isLike == 1) ? PZImages.heart_FilledBig : PZImages.heartEmptyBig , for: .normal)

        
        self.btnTikTokName.setTitle( (objWallPost.sharedWallData.userInfo?.pickzonId ?? "") , for: .normal)
        
        let strUserName = self.getUpdatedHeadlineAndPosoition(isShared: true)
        if strUserName.count > 0 {
            constPickZonIDHeight.constant = 25
            constUserNameHeight.constant = 20
        }else {
            constPickZonIDHeight.constant = 45
            constUserNameHeight.constant = 0
        }
        
        self.btnUserName.setTitle(strUserName , for: .normal)
        
        self.btnCommentCount.setTitle(objWallPost.totalComment.asFormatted_k_String, for: .normal)
        self.btnCommentCountClip.setTitle(objWallPost.totalComment.asFormatted_k_String, for: .normal)
        
        self.btnShareCount.setTitle(objWallPost.totalShared.asFormatted_k_String, for: .normal)
        self.btnShareCountClip.setTitle(objWallPost.totalShared.asFormatted_k_String, for: .normal)
        
        
        
        lblViewCount.text = objWallPost.viewCount.asFormatted_k_String
        
        if objWallPost.sharedWallData == nil {
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
            
        }else{
            self.imgVwCelebrity.isHidden = true
            if objWallPost.sharedWallData.userInfo?.celebrity == 1 {
                self.imgVwCelebrity.isHidden = false
                self.imgVwCelebrity.image = PZImages.greenVerification
            }else if objWallPost.sharedWallData.userInfo?.celebrity == 4 {
                self.imgVwCelebrity.isHidden = false
                self.imgVwCelebrity.image = PZImages.goldVerification
            }else if objWallPost.sharedWallData.userInfo?.celebrity == 5 {
                self.imgVwCelebrity.isHidden = false
                self.imgVwCelebrity.image = PZImages.blueVerification
            }
        }
        
        self.btnUserName.tag = indexPath.row
        self.btnUserImage.tag = indexPath.row
        self.btnLike.tag = indexPath.row
        self.btnShare.tag = indexPath.row
        self.btnFolow.tag = indexPath.row
        self.btnComment.tag = indexPath.row
        self.btnCommentCount.tag = indexPath.row
        self.btnCommentCountClip.tag = indexPath.row
        self.lblLikesCount.tag = indexPath.row
        self.lblLikesCount.text = objWallPost.totalLike.asFormatted_k_String
        self.lblLikesCountClip.tag = indexPath.row
        self.lblLikesCountClip.text = objWallPost.totalLike.asFormatted_k_String
        self.btnOption.tag = indexPath.row
        
        if isClipVideo == true {
            self.btnCoinUp.isHidden = true
            self.bgVwCoinUpClip.isHidden = (objWallPost.isCoinUp == 0 || Themes.sharedInstance.Getuser_id() == objWallPost.userInfo?.id ?? "") ? true : false

            
        }else {
            self.btnCoinUp.isHidden = (objWallPost.isCoinUp == 0 || Themes.sharedInstance.Getuser_id() == objWallPost.userInfo?.id ?? "") ? true : false
        }
        
        
        
        if (objWallPost.sharedWallData.soundInfo?.id ?? "").count > 0{
            self.bgVwSoundClip.isHidden = false
            self.lblSoundName.isHidden = false
            self.imgVwSongIcon.isHidden = false
            self.btnSound.kf.setImage(with:  URL(string: objWallPost.sharedWallData.soundInfo!.thumb) , for: .normal, placeholder:PZImages.avatar , options: nil)
            if (objWallPost.sharedWallData.soundInfo?.isOriginal ?? 0) == 1 {
                self.lblSoundName.text =  "\(objWallPost.sharedWallData.soundInfo?.name ?? "") - Original sound"
            }else {
                self.lblSoundName.text =  "\(objWallPost.sharedWallData.soundInfo?.name ?? "")"
            }
        }else{
            self.bgVwSoundClip.isHidden = true
            self.lblSoundName.isHidden = true
            self.imgVwSongIcon.isHidden = true
        }
        
    }
    
    func getUpdatedHeadlineAndPosoition(isShared:Bool)->String{
        
        if isShared{
            
            if (objWallPost.sharedWallData.userInfo?.headline ?? "").count > 0 && (objWallPost.sharedWallData.userInfo?.jobProfile ?? "").count > 0 {
                return "\(objWallPost.sharedWallData.userInfo?.jobProfile ?? "") |  \(objWallPost.sharedWallData.userInfo?.headline ?? "")"
                
            }else if (objWallPost.sharedWallData.userInfo?.headline ?? "").count > 0 && (objWallPost.sharedWallData.userInfo?.jobProfile ?? "").count == 0 {
                return "\(objWallPost.sharedWallData.userInfo?.headline ?? "")"
                
            }else if (objWallPost.sharedWallData.userInfo?.headline ?? "").count == 0 && (objWallPost.sharedWallData.userInfo?.jobProfile ?? "").count > 0 {
                return "\(objWallPost.sharedWallData.userInfo?.jobProfile ?? "")"
            }else{
                   
                return "\(objWallPost.sharedWallData.userInfo?.name ?? "")"
            }
        }else{
            if (objWallPost.userInfo?.headline ?? "").count > 0 && (objWallPost.userInfo?.jobProfile ?? "").count > 0 {
                return "\(objWallPost.userInfo?.jobProfile ?? "") | \(objWallPost.userInfo?.headline ?? "")"
                
            }else if (objWallPost.userInfo?.headline ?? "").count > 0 && (objWallPost.userInfo?.jobProfile ?? "").count == 0 {
                return "\(objWallPost.userInfo?.headline ?? "")"
                
            }else if (objWallPost.userInfo?.headline ?? "").count == 0 && (objWallPost.userInfo?.jobProfile ?? "").count > 0 {
                return "\(objWallPost.userInfo?.jobProfile ?? "")"
            }else{
                    return "\(objWallPost.userInfo?.name ?? "")"
               
            }
        }
    }
}



extension FeedsVideoViewCell {
    
    //MARK: Selector Methods
    
  @objc func coinUpBtnAction() {
      if #available(iOS 13.0, *) {
          
          let controller = StoryBoard.feeds.instantiateViewController(identifier: "CheerCoinVC")
          as! CheerCoinVC
          //controller.objWallPost = self.objWallPost
          
          controller.postId = self.objWallPost.id
          controller.userId = self.objWallPost.userInfo?.id ?? ""
          controller.pickzonId = self.objWallPost.userInfo?.pickzonId ?? ""
          controller.type = 0
          
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
        if videoView.state != .playing {
            videoView.resume()
        }else {
            controlView.speakerBtnAction(sender: UIButton())
            self.showHideSpeakerButton()
        }
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
        
        //Different code
        if sender.state != UIGestureRecognizer.State.ended {
            //When lognpress is start or running
            if self.videoView.state == .playing {
                videoView.pause(reason:.userInteraction)
                self.viewUser.isHidden = true
                
                
                self.stackViewRightBar.isHidden = true
                
                /*if self.isClipVideo == true {
                    self.stackViewRightBar.isHidden = true
                }else {
                    viewBottom.isHidden = true
                    controlView.stackViewBottom.isHidden = true
                    self.btnCoinUp.isHidden = true
                }*/
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
                
                /*if self.isClipVideo == true {
                    self.stackViewRightBar.isHidden = false
                }else {
                    self.viewBottom.isHidden = false
                    self.btnCoinUp.isHidden = (objWallPost.isCoinUp == 1) ? false : true
                    controlView.stackViewBottom.isHidden = false
                }*/
            }
        }
        controlView.updateSpeakerImage()
    }
    
    
    @objc func addTargetButtons() {
        if objWallPost.sharedWallData == nil {
            btnFolow.addTarget(self, action: #selector(self.followBtnAction), for: .touchUpInside)
            btnUserImage.addTarget(self, action: #selector(self.openProfile), for: .touchUpInside)
            btnUserName.addTarget(self, action: #selector(self.openProfile), for: .touchUpInside)
        }else {
            btnFolow.addTarget(self, action: #selector(self.followSharedBtnAction(_ :)), for: .touchUpInside)
            btnUserImage.addTarget(self, action: #selector(self.openProfileSharedUser), for: .touchUpInside)
            btnUserName.addTarget(self, action: #selector(openProfileSharedUser), for: .touchUpInside)
        }
        if isClipVideo == true {
            btnLikeClip.addTarget(self, action: #selector(self.likeDislikePostAPICall), for: .touchUpInside)
            btnOptionClip.addTarget(self, action: #selector(self.optionBtnAction), for: .touchUpInside)
            btnShareClip.addTarget(self, action: #selector(self.sharePostThirdPartMedia), for: .touchUpInside)
            lblLikesCountClip.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickedonLikeCount(_ : ))))
            btnCommentClip.addTarget(self, action: #selector(self.openComments(sender:)), for: .touchUpInside)
            btnCommentCountClip.addTarget(self, action: #selector(self.openComments(sender:)), for: .touchUpInside)
            btnCoinUpClip.addTarget(self, action: #selector(self.coinUpBtnAction), for: .touchUpInside)
        }else {
            
            btnLike.addTarget(self, action: #selector(self.likeDislikePostAPICall), for: .touchUpInside)
            btnOption.addTarget(self, action: #selector(self.optionBtnAction), for: .touchUpInside)
            btnShare.addTarget(self, action: #selector(self.sharePostThirdPartMedia), for: .touchUpInside)
            lblLikesCount.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickedonLikeCount(_ : ))))
            btnComment.addTarget(self, action: #selector(self.openComments(sender:)), for: .touchUpInside)
            btnCommentCount.addTarget(self, action: #selector(self.openComments(sender:)), for: .touchUpInside)
            btnCoinUp.addTarget(self, action: #selector(self.coinUpBtnAction), for: .touchUpInside)
        }
        
    }
    
    
    @objc func savePostAPI() {
        
        if objWallPost.isSave == 0 {
            saveWallPost()
        }else{
            AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to remove selected post from saved list?", buttonTitles: ["Yes","No"], onController: (AppDelegate.sharedInstance.navigationController?.topViewController)!) { title, index in
                if index == 0{
                    self.saveWallPost()
                }
            }
        }
    }
    
    func saveWallPost() {
        
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
                 
                    self.btnSavePost.setImage((self.objWallPost.isSave == 1) ? PZImages.feedsSavePostRed : PZImages.feedsSavePost, for: .normal)
                    
                    let objDict = ["feedId":self.objWallPost.id, "isSave":self.objWallPost.isSave] as [String : Any]
                    
                    NotificationCenter.default.post(name: nofit_FeedSaved, object: objDict)
                    
                    
                    (AppDelegate.sharedInstance.navigationController?.topViewController)!.view.makeToast(message: message , duration: 2, position: HRToastActivityPositionDefault)
                    
                }else{
                    (AppDelegate.sharedInstance.navigationController?.topViewController)!.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
        
    }
    
    
    
    @objc func likeDislikePostAPICall() {
        
        let params = NSMutableDictionary()
        //params.setValue("\(objWallPost.feedId)", forKey: "feedId")
        params.setValue("\(objWallPost.sharedWallData == nil ? objWallPost.id : objWallPost.sharedWallData.id)", forKey: "feedId")
        var  isLike:Int16 = 0
        if objWallPost.isLike == 0 {
            isLike = 1
        }
        params.setValue(isLike, forKey: "action")
        
        if isLike == 1 {
            //AudioServicesPlayAlertSound(SystemSoundID(1352))
            AudioServicesPlayAlertSound(SystemSoundID(1519))
            if self.isClipVideo == true {
                self.btnLikeClip.setImage(PZImages.heart_FilledBig, for: .normal)
                self.btnLikeClip.likeBounce(0.6)
                self.btnLikeClip.animate()
            }else {
                self.btnLike.setImage(PZImages.heart_Filled, for: .normal)
                self.btnLike.likeBounce(0.6)
                self.btnLike.animate()
            }
        }else {
            if self.isClipVideo == true {
                self.btnLikeClip.setImage(PZImages.heartEmptyBig, for: .normal)
                self.btnLikeClip.likeBounce(0.4)
            }else {
                self.btnLike.setImage(PZImages.heartWhite_blank, for: .normal)
                self.btnLike.likeBounce(0.4)
            }
        }
        
        URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.likeDislikePostURL, param: params, completionHandler: {(responseObject, error) ->  () in
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
                    self.objWallPost.totalLike = payload["likeCount"] as? UInt  ?? 0
                    self.objWallPost.isLike = isLike

                    let objDict = ["feedId":self.objWallPost.id, "isLike":isLike, "likeCount": self.objWallPost.totalLike ] as [String : Any]
                    NotificationCenter.default.post(name: notif_FeedLiked, object: objDict)
                    
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
        profileVC.postId = objWallPost.sharedWallData == nil ? objWallPost.id : objWallPost.sharedWallData.id
        profileVC.controllerType = .feedLikeList
        (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(profileVC, animated: true)
    }
    
   
    @objc func openComments(sender:UIButton)
    {
        if #available(iOS 13.0, *) {
            
            let controller = StoryBoard.main.instantiateViewController(identifier: "FeedsCommentViewController")
            as! FeedsCommentViewController
            controller.wallpostid = (objWallPost.sharedWallData == nil) ? objWallPost.id : objWallPost.sharedWallData.id
            
            controller.isFeedsShared = (objWallPost.sharedWallData != nil)  ? true : false
            controller.selPostIndex = sender.tag
            controller.commentDelegate = self
            controller.postOwnerUserId = (objWallPost.sharedWallData != nil)  ? objWallPost.sharedWallData.userInfo?.id ?? "" : objWallPost.userInfo?.id ?? ""
            
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
        
        
        let storyboard = UIStoryboard(name: "Feeds", bundle: nil)
        let viewController:ShareFeedPostViewController = storyboard.instantiateViewController(withIdentifier: "ShareFeedPostViewController") as! ShareFeedPostViewController
        if objWallPost.sharedWallData == nil {
            viewController.urlSelectedItemsArray = objWallPost.urlArray.map({ urlstr in
                return (URL(string: urlstr) ?? URL(string: ""))!
            })
            viewController.objPost = objWallPost
        }else{
            viewController.urlSelectedItemsArray = objWallPost.sharedWallData.urlArray.map({ urlstr in
                return (URL(string: urlstr) ?? URL(string: ""))!
            })
            viewController.objPost = objWallPost
        }
        
        viewController.isFromEdit = true
        (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(viewController, animated: true)
    }
    
    @objc func sharePostThirdPartMedia() {
        ShareMedia.shareMediafrom(type: .post, mediaId: objWallPost.id, controller: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
    }
    
    
    @objc func reportPostApi(message:String)  {
        videoView.pause(reason:.userInteraction)
        
        let param:NSDictionary = ["feedId":"\(objWallPost.id)","message":message]
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.reportWallPost as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
                if status == 1{
                    let objDict = ["feedId":self.objWallPost.id]
                    NotificationCenter.default.post(name: notif_FeedRemoved, object: objDict)
                    AlertView.sharedManager.displayMessage(title: "PickZon", msg: message as! String, controller: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    @objc func blockPostApi(postIndex:Int){
        videoView.pause(reason:.userInteraction)
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
                    
                    let objDict = ["feedId":self.objWallPost.id]
                    NotificationCenter.default.post(name: notif_FeedRemoved, object: objDict)
                    
                    AlertView.sharedManager.displayMessage(title: "PickZon", msg: message, controller: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
        
    }
    
    
    @objc func deleteWallPostApi(){
        videoView.pause(reason:.userInteraction)
        Themes.sharedInstance.activityView(View: self.view)
        
        
        URLhandler.sharedinstance.makeDeleteAPICall(url: Constant.sharedinstance.deleteWallPost + "/\(objWallPost.id)", param: NSDictionary()) { responseObject, error in
            
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
                    
                    let objDict = ["feedId":self.objWallPost.id]
                    NotificationCenter.default.post(name: notif_FeedRemoved, object: objDict)
                    
                    AlertView.sharedManager.displayMessage(title: "Pickzon", msg: message, controller: AppDelegate.sharedInstance.navigationController!.topViewController!)
                    
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
        
    }
    
    @objc func optionBtnAction() {
        
        let controller = UIStoryboard(name: "TableViewDemo", bundle: nil).instantiateInitialViewController()! as! TableViewDemo
        
        var isMedia = false
        
        if (objWallPost.sharedWallData == nil && objWallPost.urlArray.count > 0){
            isMedia = true
        }else if (objWallPost.sharedWallData != nil && objWallPost.sharedWallData.urlArray.count > 0){
            isMedia = true
        }
        
        var percentage:Float = 0.30
        
        if objWallPost.userInfo?.id == Themes.sharedInstance.Getuser_id() {
            
            if objWallPost.sharedWallData == nil {
                if Settings.sharedInstance.isDownload == 1 {
                    controller.listArray = (isMedia) ? ["Download","Share"] : ["Share"]
                    controller.iconArray = (isMedia) ? ["DownloadVideo","Shareicon"] : ["Shareicon"]
                }else{
                    controller.listArray = (isMedia) ? ["Share"] : ["Share"]
                    controller.iconArray = (isMedia) ? ["Shareicon"] : ["Shareicon"]
                }
                percentage = 0.20
                
            
        }else {
            if Settings.sharedInstance.isDownload == 1 {
                controller.listArray = (isMedia) ? ["Download","Share"] : ["Share"]
                controller.iconArray = (isMedia) ? ["DownloadVideo","Shareicon"] : ["Shareicon"]
            }else {
                
                controller.listArray = (isMedia) ? ["Share"] : ["Share"]
                controller.iconArray = (isMedia) ? ["Shareicon"] : ["Shareicon"]
            }
            percentage = 0.20
            
            }
            
        }else{
            if Settings.sharedInstance.isDownload == 1 {
                 controller.listArray =  (isMedia) ? ["Download","Share","Block Post","Report"] : ["Share","Block Post","Report"]
                controller.iconArray = (isMedia) ? ["DownloadVideo","Shareicon","BlockAccount","Report"] : ["Shareicon","BlockAccount","Report"]
            }else {
                controller.listArray =  (isMedia) ? ["Share","Block Post","Report"] : ["Share","Block Post","Report"]
                controller.iconArray = (isMedia) ? ["Shareicon","BlockAccount","Report"] : ["Shareicon","BlockAccount","Report"]
            }
            percentage = 0.30
        }
        
        //controller.videoIndex = sender.tag
        controller.delegate = self
        let useInlineMode = AppDelegate.sharedInstance.navigationController!.topViewController!.view != nil
        
        let sheet = SheetViewController(
            controller: controller,
            sizes: [.percent(percentage), .intrinsic],
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
        if objWallPost.sharedWallData == nil {
            urlArray = objWallPost.urlArray
        }else {
            urlArray = objWallPost.sharedWallData.urlArray
        }
        
        
        if title == "Share"{
            
            self.sharePostAPI()
            
        }else  if title == "Download"{
            
            self.downloadVideosAPI()
            
        }else  if title == "Delete"{
            
            AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to delete selected post?", buttonTitles: ["Yes","No"], onController: (AppDelegate.sharedInstance.navigationController?.topViewController)!) { title, index in
                
                if index == 0{
                    self.deleteWallPostApi()
                }
            }
            
        }else  if title == "Edit"{
            
            let viewController:CreateWallPostViewController = StoryBoard.feeds.instantiateViewController(withIdentifier: "CreateWallPostViewController") as! CreateWallPostViewController
            
            viewController.urlSelectedItemsArray = objWallPost.urlArray.map({ urlstr in
                return (URL(string: urlstr) ?? URL(string: ""))!
            })
            viewController.objPost = objWallPost
            viewController.isFromEdit = true
            viewController.isFromProfile = false
            viewController.uploadDelegate = self
            AppDelegate.sharedInstance.navigationController?.pushViewController(viewController, animated: true)
            
        }else  if title == "Block Post"{
            self.blockPostApi(postIndex: videoIndex)
        }else  if title == "Report"{
            videoView.pause(reason:.userInteraction)
            let destVc:ReportUserVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ReportUserVC") as! ReportUserVC
            destVc.modalPresentationStyle = .overCurrentContext
            destVc.modalTransitionStyle = .coverVertical
            destVc.reportType = .post
            destVc.reportingId = objWallPost.id
            AppDelegate.sharedInstance.navigationController?.topViewController?.present(destVc, animated: true, completion: nil)
        }
    }
    
    func downloadVideosAPI(){
        Themes.sharedInstance.showActivityViewTop(View: (AppDelegate.sharedInstance.navigationController?.topViewController?.view)!, isTop: true)
        let params:NSDictionary = ["url":self.url]
        
        URLhandler.sharedinstance.makeCall(url: Constant.sharedinstance.getDownloadMediaURL, param: params, completionHandler: {(responseObject, error) ->  () in
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
               
                if status == 1 {
                    let data = result["payload"] as? NSDictionary ?? [:]
                    self.downloadMedia(mediaUrl: data["url"] as? String ?? "")
                } else  {
                    DispatchQueue.main.async {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
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
                        
                    }) {
                        
                        success, error in
                        
                    DispatchQueue.main.async{
                        self.downloadCleanAPI(mediaURL: mediaUrl,filePath:filePath)
            
                   }
                      
                        if FileManager.default.fileExists(atPath: filePath) {
                            // delete file
                            do {
                                try FileManager.default.removeItem(atPath: filePath)
                            } catch {
                                print("Could not delete file, probably read-only filesystem")
                            }
                        }
                        
                        if success {
                            print("Succesfully Saved")
                            DispatchQueue.main.async{
                                self.sharePostThirdPartMedia()
                            }
                        } else {
                            print(error?.localizedDescription ?? "")
                        }
                    }
                }
            }
        }
    }
    
    
    func downloadCleanAPI(mediaURL:String,filePath:String){
        
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
    
    func messageAlertWithReport(postIndex:Int) {
        
        let alertController = UIAlertController(title: "Report", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Submit", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            if (firstTextField.text?.trim().count ?? 0 > 0){
                self.reportPostApi(message: firstTextField.text!)}
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in })
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Report message"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        AppDelegate.sharedInstance.navigationController?.topViewController!.present(alertController, animated: true, completion: nil)
    }
    
    @objc func openProfile(){
        
        
            
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn = objWallPost.userInfo?.id ?? ""
            AppDelegate.sharedInstance.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc func openProfileSharedUser(){
        if objWallPost.sharedWallData != nil {
                let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                profileVC.otherMsIsdn = objWallPost.sharedWallData?.userInfo?.id ?? ""
                AppDelegate.sharedInstance.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    
    @objc func followBtnAction(){
            followFeedsUser(isShared: false)
    }
    
    @objc func followSharedBtnAction(_ sender:UIButton){
            followFeedsUser(isShared: true, isSharingUser: true)
    }
    
    
    
    
    
    
    func followFeedsUser(isShared:Bool, isSharingUser:Bool = false) {
        var userId:String = ""
        if isShared && objWallPost.sharedWallData != nil {
          userId = objWallPost.sharedWallData.userInfo?.id ?? ""

        }else{
          userId = objWallPost.userInfo?.id ?? ""
        }
      
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
                let isFollow = payloadDict["isFollow"] as? Int ?? 0
                
                if status == 1{
                    DispatchQueue.main.async {
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


extension FeedsVideoViewCell : FeedsCommentDelegate, UploadFilesDelegate,CoinUpDelegate{
      
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
    

    //MARK: Comment Delegate
    func commentAdded(commentText: String, selPostIndex: Int, isFromShared: Bool, isFromDelete:Bool,commentCount:Int16) {
        
        let objDict = ["feedId":self.objWallPost.id, "commentText":commentText, "isFromShared":isFromShared, "isFromDelete":isFromDelete, "commentCount":commentCount] as [String : Any]
        
        NotificationCenter.default.post(name: nofit_CommentAdded, object: objDict)
        
    }
}




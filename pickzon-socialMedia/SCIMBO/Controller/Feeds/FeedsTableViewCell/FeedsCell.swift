//
//  FeedsCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 7/17/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import AVKit
import Kingfisher
import ActiveLabel
import FittedSheets
import Alamofire

class FeedsCell: UITableViewCell, OptionDelegate {

    @IBOutlet weak var bgVwBoost:UIView!
    @IBOutlet weak var btnBoost:UIButton!
    
    @IBOutlet weak var profilePicView:ImageWithFrameImgView!
    @IBOutlet weak var profilePicViewShared:ImageWithFrameImgView!

    var isFromSavedList = false
    var isVideoActive = false
    var tableIndexPath:IndexPath?
    @IBOutlet weak var lblPosition: UILabel!
    @IBOutlet weak var lblSharingUserPosition: UILabel!
    @IBOutlet weak var btnFolow: UIButton!
    @IBOutlet weak var btnPromote: UIButton!
    @IBOutlet weak var imgGlobe:UIImageView!
    @IBOutlet weak var btnSharedFollow: UIButton!
    @IBOutlet weak var btnUserName: UIButton!
    @IBOutlet weak var btnTikTokName: UIButton!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblSharedContents: ExpandableLabel!
    @IBOutlet weak var btnUserNameShared: UIButton!
    @IBOutlet weak var lblLocationShared: UILabel!
    @IBOutlet weak var cvFeedsPost:UICollectionView!
    @IBOutlet weak var btnLike: SparkButton!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnAddClip: UIButton!
    @IBOutlet weak var lblDescription: ExpandableLabel!
    @IBOutlet weak var lblPlace: UILabel!
    @IBOutlet weak var lblFeelingActivity: UILabel!
    @IBOutlet weak var btnSavePost:UIButton!
    @IBOutlet weak var btnOption:UIButton!
    @IBOutlet weak var cnstrnt_CelebrityWidth: NSLayoutConstraint!
    @IBOutlet weak var cnstrnt_SharedCelebrityWidth: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var btnBuyNow:UIButton!
    @IBOutlet weak var btnCommentCount:UIButton!
    @IBOutlet weak var btnShareCount: UIButton!
    @IBOutlet weak var lblPostDate: UILabel!
    @IBOutlet weak var txtVwDesc: ReadMoreTextView!
    @IBOutlet weak var cnstrnt_CllctnHeight: NSLayoutConstraint!
    @IBOutlet weak var imgVwCelecbrity: UIImageView!
    @IBOutlet weak var imgVwSharedCelecbrity: UIImageView!
    @IBOutlet weak var postTypeSahreImgVw:UIImageView!
    @IBOutlet weak var btnViewCount: UIButton!
    @IBOutlet weak var btnView: UIButton!
    @IBOutlet weak var lblMediaCount: UILabelX!
    @IBOutlet weak var bgVwViewCount: UIView!
    @IBOutlet weak var bgVwComment: UIView!
    @IBOutlet weak var bgVwLike: UIView!
    @IBOutlet weak var bgVwShare: UIView!
    @IBOutlet weak var btnLikedCount: UIButton!
    @IBOutlet weak var btnCoinUp: UIButton!
    @IBOutlet weak var btnCoinUpText: UIButton!
    @IBOutlet weak var lblViewCount: UILabel!
    @IBOutlet weak var btnViewsCount:UIButton!
    
    var urlArray:Array<String> = Array<String>()
    var thumbArray:Array<String> = Array<String>()
    var mediaArr:Array<String> = Array<String>()
    var urlDimensionArray:Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()
    var objWallPost:WallPostModel!
    var delegate:ExpandableLabelDelegate!
    var isRandomVideos = false
    var controllerType:PostType = .isFromPost
    var hashTag = ""

    
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: Configure items
    func configureWallPostItem(objWallPost:WallPostModel,indexPath:IndexPath,states:Bool){
    
        self.objWallPost = objWallPost
        if objWallPost.urlArray.count == 0 {
            self.btnCoinUp.isHidden = true
            self.btnCoinUpText.isHidden = true
        }else{
            self.btnCoinUp.isHidden = false
            self.btnCoinUpText.isHidden = false
        }
        
        if objWallPost.userInfo?.id == Themes.sharedInstance.Getuser_id() {
            self.bgVwBoost.isHidden = false
            /*
             0 default
            1 pending boost post
            2 approved boost post
            3 rejected boost post
             */
            switch objWallPost.boost{
                
            case 0:
                self.btnBoost.setTitle("Boost Post", for: .normal)
                break
            case 1:
                self.btnBoost.setTitle("In Review", for: .normal)
                break
            case 2:
                self.btnBoost.setTitle("Boosted", for: .normal)
                break
            case 3:
                self.btnBoost.setTitle("Rejected", for: .normal)
                break
                
            default :
                self.bgVwBoost.isHidden = true

                break
                
            }
            
        }else{
            self.bgVwBoost.isHidden = true
        }
        
        
        self.btnLike.sparkView.stop()
        
        self.lblDescription.setLessLinkWith(lessLink: "Read less", attributes: [.foregroundColor:UIColor.red], position: .left)
        var txtFeeling = ""
        
        if objWallPost.feeling.count > 0 {
            txtFeeling = (objWallPost.feeling["image"] as? String ?? "") + " " +  (objWallPost.feeling["name"]  as? String ?? "")
        }else if objWallPost.activities.count > 0 {
            txtFeeling = (objWallPost.activities["image"] as? String ?? "") + " " +  (objWallPost.activities["name"] as? String ?? "")
        }
        
        
        self.btnUserName.setTitle(objWallPost.userInfo?.pickzonId ?? "" , for: .normal)
        
        self.lblLocation.text = objWallPost.place
        self.lblPostDate.text = objWallPost.feedTime
        self.urlArray = objWallPost.urlArray
        if self.urlArray.count > 0 {
            self.lblMediaCount.text = "\(1)/\(self.urlArray.count)"
        }
        self.thumbArray = objWallPost.thumbUrlArray
       //self.mediaArr = objWallPost.mediaArr
        self.urlDimensionArray = objWallPost.urlDimensionArray
        self.cnstrnt_CllctnHeight.constant = 0
        self.btnSavePost.isHidden = true
        self.lblMediaCount.isHidden = true
        self.cnstrnt_CllctnHeight.constant = objWallPost.clnViewHeight
        
        self.bgVwShare.isHidden = false
        self.bgVwComment.isHidden = false
        
        if ( (objWallPost.postType.lowercased() == "friend" || objWallPost.postType.lowercased() == "private")){
            
            self.bgVwShare.isHidden = true
        }
        
        if objWallPost.commentType == 1{
            self.bgVwComment.isHidden = true
        }
        

        switch objWallPost.userInfo?.celebrity{
        case 1:
            self.imgVwCelecbrity.isHidden = false
            self.imgVwCelecbrity.image = PZImages.greenVerification
            self.cnstrnt_CelebrityWidth.constant = 17

        case 4:
            self.imgVwCelecbrity.isHidden = false
            self.imgVwCelecbrity.image = PZImages.goldVerification
            self.cnstrnt_CelebrityWidth.constant = 17
        case 5:
            self.imgVwCelecbrity.isHidden = false
            self.imgVwCelecbrity.image = PZImages.blueVerification
            self.cnstrnt_CelebrityWidth.constant = 17

        default:
            self.imgVwCelecbrity.isHidden = true
            self.cnstrnt_CelebrityWidth.constant = 0
        }
        
        self.btnFolow.tag = indexPath.row
        self.btnFolow.isHidden = false
        if (Themes.sharedInstance.Getuser_id() == objWallPost.userInfo?.id ?? "") || (objWallPost.isFollowed > 0){
            self.btnFolow.isHidden = true
        }
        
        if Themes.sharedInstance.Getuser_id() == objWallPost.userInfo?.id  ?? "" {
            self.btnPromote.isHidden = true
            self.btnPromote.tag = indexPath.row
        }else {
            self.btnPromote.isHidden = true
        }
                 
        if objWallPost.payload.count == 0 && txtFeeling.count == 0 && objWallPost.taggedPeople.count == 0 && objWallPost.taggedPeople.count == 0{
            self.lblDescription.attributedText = NSAttributedString(string: "")
        }else{
            self.lblDescription.attributedText =  convertAttributtedColorText(text: objWallPost.payload + " " + txtFeeling + ((objWallPost.taggedPeople.count > 0) ? "\n \(objWallPost.taggedPeople)" : ""))
        }
                
        
        self.btnFolow.setTitle("Follow", for: .normal)
        self.btnFolow.setImage(PZImages.followPlus, for: .normal)
            
              
         switch objWallPost.postType.lowercased(){
         case "public":
             self.imgGlobe.image = PZImages.publicPost
         case "friend":
             self.imgGlobe.image = PZImages.friendPost
         case "private":
             self.imgGlobe.image = PZImages.privatePost
         default:
             self.imgGlobe.image = PZImages.publicPost
         }
        
        self.btnSavePost.setImage((objWallPost.isSave == 0) ? PZImages.feedsSavePost : PZImages.feedsSavePostRed , for: .normal)
        self.btnLike.setImage((objWallPost.isLike == 1) ? PZImages.heart_Filled : PZImages.heart_blank, for: .normal)
        
        self.profilePicView.setImgView(profilePic: objWallPost.userInfo!.profilePic, frameImg: objWallPost.userInfo!.avatar,changeValue: (objWallPost.userInfo!.avatar.count > 0) ? 9 : 5)
        self.btnSavePost.isHidden = (objWallPost.clnViewHeight > 0.0) ? false : true
      
        self.btnViewsCount.setTitle(objWallPost.viewCount > 0 ? objWallPost.viewCount.asFormatted_k_String : "0", for: .normal)
        self.bgVwViewCount.isHidden = (objWallPost.isCoinUp == 0 || Themes.sharedInstance.Getuser_id() == objWallPost.userInfo?.id ?? "") ? true : false
        self.updatedCommentLikeAndShareCount(objwallpost: objWallPost)
        self.lblDescription.textReplacementType = .word
        self.lblDescription.shouldCollapse = objWallPost.isExpanded
        self.lblDescription.numberOfLines = 4
        self.lblPosition.text = getUpdatedHeadlineAndPosoition(obj: objWallPost, isShared: false)
        
        self.profilePicView.imgVwProfile?.tag = indexPath.row
        self.tableIndexPath = indexPath
        self.btnUserName.tag = indexPath.row
        self.btnLike.tag = indexPath.row
        self.btnShare.tag = indexPath.row
        self.btnSavePost.tag = indexPath.row
        self.btnCoinUp.tag = indexPath.row
        self.btnComment.tag = indexPath.row
        self.btnOption.tag = indexPath.row
        self.btnLikedCount.tag = indexPath.row
        self.btnBoost.tag = indexPath.row
    }
    
    
    func configureSharedWallDataPost(objWallPost:WallPostModel,indexPath:IndexPath,states:Bool){
        self.bgVwBoost.isHidden = true

        self.objWallPost = objWallPost
        self.btnCoinUp.isHidden = true
        self.btnCoinUpText.isHidden = true
        self.btnLike.sparkView.stop()
        
        var txtFeeling = ""
        
        if objWallPost.feeling.count > 0 {
            txtFeeling = (objWallPost.feeling["image"] as? String ?? "") + " " +  (objWallPost.feeling["name"]  as? String ?? "")
        }else if objWallPost.activities.count > 0 {
            txtFeeling = (objWallPost.activities["image"] as? String ?? "") + " " +  (objWallPost.activities["name"] as? String ?? "")
        }
        self.lblDescription.setLessLinkWith(lessLink: "Read less", attributes: [.foregroundColor:UIColor.red], position: .left)
       
        switch objWallPost.postType.lowercased(){
            
        case "public":
            self.imgGlobe.image = PZImages.publicPost
        case "friend":
            self.imgGlobe.image = PZImages.friendPost
        case "private":
            self.imgGlobe.image = PZImages.privatePost
        default:
            self.imgGlobe.image = PZImages.publicPost
        }
        
        switch objWallPost.userInfo?.celebrity{
        case 1:
            self.imgVwCelecbrity.isHidden = false
            self.imgVwCelecbrity.image = PZImages.greenVerification
            self.cnstrnt_CelebrityWidth.constant = 17
        case 4:
            self.imgVwCelecbrity.isHidden = false
            self.imgVwCelecbrity.image = PZImages.goldVerification
            self.cnstrnt_CelebrityWidth.constant = 17
        case 5:
            self.imgVwCelecbrity.isHidden = false
            self.imgVwCelecbrity.image = PZImages.blueVerification
            self.cnstrnt_CelebrityWidth.constant = 17
        default:
            self.imgVwCelecbrity.isHidden = true
            self.cnstrnt_CelebrityWidth.constant = 0
        }
        
        switch objWallPost.sharedWallData.postType.lowercased(){
            
        case "public":
            self.postTypeSahreImgVw.image = PZImages.publicPost
        case "friend":
            self.postTypeSahreImgVw.image = PZImages.friendPost
        case "private":
            self.postTypeSahreImgVw.image = PZImages.privatePost
        default:
            self.postTypeSahreImgVw.image = PZImages.publicPost
        }
        
        switch objWallPost.sharedWallData.userInfo?.celebrity{
        case 1:
            self.imgVwSharedCelecbrity.isHidden = false
            self.imgVwSharedCelecbrity.image = PZImages.greenVerification
            self.cnstrnt_SharedCelebrityWidth.constant = 17
        case 4:
            self.imgVwSharedCelecbrity.isHidden = false
            self.imgVwSharedCelecbrity.image = PZImages.goldVerification
            self.cnstrnt_SharedCelebrityWidth.constant = 17
        case 5:
            self.imgVwSharedCelecbrity.isHidden = false
            self.imgVwSharedCelecbrity.image = PZImages.blueVerification
            self.cnstrnt_SharedCelebrityWidth.constant = 17
        default:
            self.imgVwSharedCelecbrity.isHidden = true
            self.cnstrnt_SharedCelebrityWidth.constant = 0
        }
        
        
        self.btnSharedFollow.setTitle("Follow", for: .normal)
        self.btnSharedFollow.setImage(PZImages.followPlus, for: .normal)
        
        
        self.btnSharedFollow.isHidden = false
        self.btnFolow.isHidden = false
        
        if (Themes.sharedInstance.Getuser_id() == objWallPost.sharedWallData.userInfo?.id ?? "") || (objWallPost.userInfo?.id  ?? "" == objWallPost.sharedWallData.userInfo?.id  ?? "") || (objWallPost.sharedWallData.isFollowed > 0){
            self.btnSharedFollow.isHidden = true
        }
        
        if (Themes.sharedInstance.Getuser_id() == objWallPost.userInfo?.id  ?? "") || (objWallPost.isFollowed > 0){
            self.btnFolow.isHidden = true
        }
        
        self.btnFolow.tag = indexPath.row
        self.btnSharedFollow.tag = indexPath.row
        var sharedTxtFeeling = ""
        if objWallPost.sharedWallData.feeling.count > 0 {
            sharedTxtFeeling = (objWallPost.sharedWallData.feeling["image"] as? String ?? "") + " " +  (objWallPost.sharedWallData.feeling["name"]  as? String ?? "")
        }else if objWallPost.sharedWallData.activities.count > 0 {
            sharedTxtFeeling = (objWallPost.sharedWallData.activities["image"] as? String ?? "") + " " +  (objWallPost.sharedWallData.activities["name"] as? String ?? "")
        }
        
        
        self.profilePicViewShared.setImgView(profilePic: objWallPost.sharedWallData.userInfo!.profilePic, frameImg: objWallPost.sharedWallData.userInfo!.avatar,changeValue:(objWallPost.sharedWallData.userInfo!.avatar.count > 0) ? 9 : 5)
      
        if objWallPost.payload.count == 0 && txtFeeling.count == 0 && objWallPost.taggedPeople.count == 0 && objWallPost.taggedPeople.count == 0{
            self.lblDescription.attributedText = NSAttributedString(string: "")
        }else{
            self.lblSharedContents.attributedText =  convertAttributtedColorText(text: objWallPost.payload + txtFeeling + ((objWallPost.taggedPeople.count > 0) ? "\n\(objWallPost.taggedPeople)" : ""))
        }
                
        
        self.btnUserName.setTitle("\(objWallPost.userInfo?.pickzonId ?? "")", for: .normal)
        self.btnUserNameShared.setTitle("\( objWallPost.sharedWallData.userInfo?.pickzonId ?? "")", for: .normal)
        
        
        self.lblLocation.text = "Shared a post " +  objWallPost.feedTime
        self.lblPostDate.text =  objWallPost.sharedWallData.feedTime
        self.lblLocationShared.text = objWallPost.sharedWallData.place
        
        if objWallPost.sharedWallData.payload.count == 0 && sharedTxtFeeling.count == 0 && objWallPost.sharedWallData.taggedPeople.count == 0 && objWallPost.sharedWallData.taggedPeople.count == 0{
            self.lblDescription.attributedText = NSAttributedString(string: "")
        }else{
            self.lblDescription.attributedText =  convertAttributtedColorText(text: objWallPost.sharedWallData.payload + " " + sharedTxtFeeling + ((objWallPost.sharedWallData.taggedPeople.count > 0) ? "\n\(objWallPost.sharedWallData.taggedPeople)" : ""))
        }
        self.urlArray = objWallPost.sharedWallData.urlArray
        if self.urlArray.count > 0 {
            self.lblMediaCount.text = "\(1)/\(self.urlArray.count)"
        }
        self.thumbArray = objWallPost.sharedWallData.thumbUrlArray
       // self.mediaArr = objWallPost.sharedWallData.mediaArr
        self.urlDimensionArray = objWallPost.sharedWallData.urlDimensionArray
        self.cnstrnt_CllctnHeight.constant = 0
        self.btnSavePost.isHidden = true
        self.lblMediaCount.isHidden = true
       
        self.cnstrnt_CllctnHeight.constant = objWallPost.clnViewHeight
        self.bgVwShare.isHidden = false
        self.bgVwComment.isHidden = false
        
        if objWallPost.commentType == 1{
            self.bgVwComment.isHidden = true
        }
     
        self.profilePicView.setImgView(profilePic: objWallPost.userInfo!.profilePic, frameImg: objWallPost.userInfo!.avatar,changeValue: (objWallPost.userInfo!.avatar.count > 0) ? 9 : 5)

       
        self.btnSavePost.isHidden = (objWallPost.sharedWallData.urlArray.count > 0) ? false : true
        self.btnLike.setImage((objWallPost.isLike == 1) ? PZImages.heart_Filled : PZImages.heart_blank , for: .normal)
        
        self.btnSavePost.setImage((objWallPost.isSave == 0) ? PZImages.feedsSavePost : PZImages.feedsSavePostRed , for: .normal)
        
        self.btnFolow.setTitle("Follow", for: .normal)
        self.btnFolow.setImage(PZImages.followPlus, for: .normal)

        self.lblDescription.textReplacementType = .word
        self.lblDescription.shouldCollapse = objWallPost.isExpanded
        self.lblDescription.numberOfLines = 4
        self.btnViewsCount.setTitle(objWallPost.viewCount > 0 ? objWallPost.viewCount.asFormatted_k_String : "0", for: .normal)
        self.bgVwViewCount.isHidden = (objWallPost.isCoinUp == 0 || Themes.sharedInstance.Getuser_id() == objWallPost.userInfo?.id ?? "") ? true : false
        
        self.updatedCommentLikeAndShareCount(objwallpost: objWallPost)
        
        self.lblSharingUserPosition.text =  getUpdatedHeadlineAndPosoition(obj: objWallPost, isShared: false)
        self.lblPosition.text =  getUpdatedHeadlineAndPosoition(obj: objWallPost, isShared: true)
        
        if objWallPost.userInfo?.id ?? "" == objWallPost.sharedWallData.userInfo?.id ?? ""{
            self.btnSharedFollow.isHidden = true
        }
        
        self.profilePicView.imgVwProfile?.tag = indexPath.row
        self.profilePicViewShared.imgVwProfile?.tag = indexPath.row

        self.tableIndexPath = indexPath
        self.btnUserName.tag = indexPath.row
        self.btnLike.tag = indexPath.row
        self.btnShare.tag = indexPath.row
        self.btnSavePost.tag = indexPath.row
        self.btnCoinUp.tag = indexPath.row
        self.btnComment.tag = indexPath.row
        self.btnOption.tag = indexPath.row
        self.btnUserNameShared.tag = indexPath.row
        self.btnLikedCount.tag = indexPath.row
        
    }
    
    
    //MARK: Helpful Methods
    func updatedCommentLikeAndShareCount(objwallpost:WallPostModel) {
       
        if objWallPost.totalLike > 0 {
            self.btnLikedCount.setTitle(objWallPost.totalLike.asFormatted_k_String, for: .normal)
        }else {
            self.btnLikedCount.setTitle("", for: .normal)
        }
        if objWallPost.totalComment > 0 {
            self.btnComment.setTitle( objWallPost.totalComment.asFormatted_k_String, for: .normal)
        }else {
            self.btnComment.setTitle("", for: .normal)
        }
        
        if objWallPost.totalShared > 0 {
            self.btnShare.setTitle( objWallPost.totalShared.asFormatted_k_String, for: .normal)
        }else {
            self.btnShare.setTitle( "", for: .normal)
        }
    }
    
   
    func getUpdatedHeadlineAndPosoition(obj:WallPostModel,isShared:Bool)->String{
        
        if isShared{
            if (obj.sharedWallData.userInfo?.headline ?? "").count > 0 && (obj.sharedWallData.userInfo?.jobProfile ?? "").count > 0 {
                return "\(obj.sharedWallData.userInfo?.jobProfile ?? "") |  \(obj.sharedWallData.userInfo?.headline ?? "")"
                
            }else if (obj.sharedWallData.userInfo?.headline ?? "").count > 0 && (obj.sharedWallData.userInfo?.jobProfile ?? "").count == 0 {
                return "\(obj.sharedWallData.userInfo?.headline ?? "")"
                
            }else if (obj.sharedWallData.userInfo?.headline ?? "").count == 0 && (obj.sharedWallData.userInfo?.jobProfile ?? "").count > 0 {
                return "\(obj.sharedWallData.userInfo?.jobProfile ?? "")"
            }else{
                return ""
            }
        }else{
            
            if (obj.userInfo?.headline ?? "").count > 0 && (obj.userInfo?.jobProfile ?? "").count > 0 {
                return "\(obj.userInfo?.jobProfile ?? "") | \(obj.userInfo?.headline ?? "")"
                
            }else if (obj.userInfo?.headline ?? "").count > 0 && (obj.userInfo?.jobProfile ?? "").count == 0 {
                return "\(obj.userInfo?.headline ?? "")"
                
            }else if (obj.userInfo?.headline ?? "").count == 0 && (obj.userInfo?.jobProfile ?? "").count > 0 {
                return "\(obj.userInfo?.jobProfile ?? "")"
            }else{
                return ""
            }
        }
    }
    
    //MARK: Selector methods
    @objc func addTargetButtons() {
        
        btnCoinUp.addTarget(self, action: #selector(self.coinUpBtnAction), for: .touchUpInside)
        btnCoinUpText.addTarget(self, action: #selector(self.coinUpBtnAction), for: .touchUpInside)
        
        btnFolow.addTarget(self, action: #selector(self.followBtnAction), for: .touchUpInside)
        btnLike.addTarget(self, action: #selector(self.likeDislikePostAPICall), for: .touchUpInside)
        btnOption.addTarget(self, action: #selector(self.optionBtnAction), for: .touchUpInside)
        btnShare.addTarget(self, action: #selector(self.sharePostThirdPartMedia), for: .touchUpInside)
        
        btnUserName.addTarget(self, action: #selector(self.openProfile), for: .touchUpInside)
        
        self.profilePicView?.imgVwProfile?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                      action:#selector(self.handleProfilePicTap(_:))))
     
        btnComment.addTarget(self, action: #selector(self.openComments(sender:)), for: .touchUpInside)
        btnSavePost.addTarget(self, action: #selector(self.savePostAPI), for: .touchUpInside)
        
        btnLikedCount.addTarget(self, action: #selector(self.likedCountBtnAction), for: .touchUpInside)
        
        btnBoost.addTarget(self, action: #selector(self.boostPostBtnAction), for: .touchUpInside)


    }
    
    
    @objc func addTargetSharedWallButtons() {
        
        btnSharedFollow.addTarget(self, action: #selector(self.followSharedBtnAction(_ :)), for: .touchUpInside)
        btnUserNameShared.addTarget(self, action: #selector(self.openProfileSharedUser), for: .touchUpInside)
        self.profilePicViewShared?.imgVwProfile?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                                             action:#selector(self.handleSharedProfilePicTap(_:))))
    }
    
    @objc func boostPostBtnAction(sender:UIButton){
        /*
        0 default
        1 pending boost post
        2 approved boost post
        3 rejected boost post
         */
        
        
        if Settings.sharedInstance.usertype == 1{
           
            AlertView.sharedManager.presentAlertWith(title: "", msg: "Your account is private. Please update your account privacy to public to boost your post.", buttonTitles: ["Yes","No"], onController: (AppDelegate.sharedInstance.navigationController?.topViewController)!) { title, index in
                if index == 0 {
                    
                    let editProfileVC:ProfileEditVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "ProfileEditVC") as! ProfileEditVC
                    editProfileVC.isCreatingNewPost = true
                    AppDelegate.sharedInstance.navigationController?.pushViewController(editProfileVC, animated: true)
                }
            }
            
        }else{
            
            
            if objWallPost.boost == 0{
                //NOT BOOSTED
                let destVC:BoostPostVC = StoryBoard.promote.instantiateViewController(withIdentifier: "BoostPostVC") as! BoostPostVC
                destVC.objWallpost = objWallPost
                AppDelegate.sharedInstance.navigationController?.pushViewController(destVC, animated: true)
                
            }else if objWallPost.boost == 2{
                //BOOSTED
                let destVC:PostInsightsVC = StoryBoard.promote.instantiateViewController(withIdentifier: "PostInsightsVC") as! PostInsightsVC
                destVC.feedId = objWallPost.id
                AppDelegate.sharedInstance.navigationController?.pushViewController(destVC, animated: true)
                
            } else if objWallPost.boost == 3{
                //REJECTED
                let destVC:PopupVC = StoryBoard.promote.instantiateViewController(withIdentifier: "PopupVC") as! PopupVC
                destVC.modalPresentationStyle = .overCurrentContext
                destVC.modalTransitionStyle = .crossDissolve
                AppDelegate.sharedInstance.navigationController?.presentView(destVC, animated: false)
            }
        }
    }
    
    
    @objc func commentedCountBtnAction(sender:UIButton){
        if #available(iOS 13.0, *) {
            
            let controller = StoryBoard.main.instantiateViewController(identifier: "FeedsCommentViewController")
            as! FeedsCommentViewController
            
            controller.wallpostid = objWallPost.sharedWallData == nil ? objWallPost.id : objWallPost.sharedWallData.id
            
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

    @objc func likedCountBtnAction() {
        let profileVC:LikeUsersVC = StoryBoard.main.instantiateViewController(withIdentifier: "LikeUsersVC") as! LikeUsersVC
        
        profileVC.postId = objWallPost.sharedWallData == nil ? objWallPost.id : objWallPost.sharedWallData.id
        
        profileVC.controllerType = .feedLikeList
        (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(profileVC, animated: true)
    }
    
    @objc func sharedCountBtnAction() {
        
    }
    
  
    @objc func coinUpBtnAction() {
        if #available(iOS 13.0, *) {
            
            let controller = StoryBoard.feeds.instantiateViewController(identifier: "CheerCoinVC")
            as! CheerCoinVC
            
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
        
  
    func deleteSavedPostApi(index:Int) {
        
        let param:NSDictionary = ["savePostId":objWallPost.id]

        Themes.sharedInstance.activityView(View: (AppDelegate.sharedInstance.navigationController?.topViewController)!.view)
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.removeSavePost as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: (AppDelegate.sharedInstance.navigationController?.topViewController)!.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
                let message = result["message"] as? String ?? ""
                if status == 1{
                    let objDict = ["feedId":self.objWallPost.id]
                    //NotificationCenter.default.post(name: notif_FeedRemoved, object: objDict)
                    NotificationCenter.default.post(name: nofit_FeedSaved, object: objDict)
                }
                (AppDelegate.sharedInstance.navigationController?.topViewController)!.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
            }
        })
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
        
        Themes.sharedInstance.activityView(View: (AppDelegate.sharedInstance.navigationController?.topViewController)!.view)
        let url = Constant.sharedinstance.savePostURL
        
        let params = NSMutableDictionary()
        if objWallPost.sharedWallData == nil {
            params.setValue("\(objWallPost.id)", forKey: "feedId")
        }else{
            params.setValue("\(objWallPost.sharedWallData.id)", forKey: "feedId")
        }
        
        URLhandler.sharedinstance.makePostAPICall(url:url as String, param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: (AppDelegate.sharedInstance.navigationController?.topViewController)!.view)
            if(error != nil)
            {
                (AppDelegate.sharedInstance.navigationController?.topViewController)!.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
                let message = result["message"] as? String ?? ""
                if status == 1{
                    let payload = result["payload"] as? Dictionary<String,Any> ?? [:]
                    self.objWallPost.isSave = payload["isSave"] as? Int16 ?? 0
                   
                    self.btnSavePost.setImage( (self.objWallPost.isSave == 1) ? PZImages.feedsSavePostRed : PZImages.feedsSavePost , for: .normal)

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
            params.setValue("\(objWallPost.sharedWallData == nil ? objWallPost.id : objWallPost.sharedWallData.id)", forKey: "feedId")

            var  isLike:Int16 = 0
            if objWallPost.isLike == 0 {
                isLike = 1
            }
            params.setValue(isLike, forKey: "action")
           // Themes.sharedInstance.activityView(View: self.view)
       
       
       if isLike == 1 {
           //AudioServicesPlayAlertSound(SystemSoundID(1352))
           AudioServicesPlayAlertSound(SystemSoundID(1519))
           self.btnLike.setImage(PZImages.heart_Filled, for: .normal)
           self.btnLike.likeBounce(0.6)
           self.btnLike.animate()
       }else {
           self.btnLike.setImage(PZImages.heart_blank, for: .normal)
           self.btnLike.likeBounce(0.4)
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
                        var urlArrayCount = 0
                        if self.objWallPost.sharedWallData == nil {
                            urlArrayCount = self.objWallPost.urlArray.count
                        }else {
                            urlArrayCount = self.objWallPost.sharedWallData.urlArray.count
                        }
                        
                        if urlArrayCount > 0 {
                            let visibleRect = CGRect(origin: self.cvFeedsPost.contentOffset, size: self.cvFeedsPost.bounds.size)
                            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
                            let visibleIndexPath = self.cvFeedsPost.indexPathForItem(at: visiblePoint)
                            if let cell = self.cvFeedsPost.cellForItem(at: visibleIndexPath!) as? FeedsCollectionViewCell {
                                cell.objWallPost = self.objWallPost
                            }
                        }
                                            
                        let objDict = ["feedId":self.objWallPost.id, "isLike":isLike, "likeCount":self.objWallPost.totalLike] as [String : Any]
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
            
            controller.wallpostid = (objWallPost.sharedWallData == nil) ? objWallPost.id :  objWallPost.sharedWallData.id
            
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
                let message = result["message"] as? String ?? ""
                if status == 1{
                    let objDict = ["feedId":self.objWallPost.id]
                    NotificationCenter.default.post(name: notif_FeedRemoved, object: objDict)
                   
                    AlertView.sharedManager.displayMessage(title: "PickZon", msg: message , controller: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    @objc func blockPostApi(postIndex:Int){
        
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
    
    @objc func removeTagFromPostApi(){
        
        Themes.sharedInstance.activityView(View: self.view)
        
        let params = NSMutableDictionary()
        params.setValue("\(objWallPost.id)", forKey: "feedId")
        params.setValue("\(Themes.sharedInstance.getPickzonId())", forKey: "pickzonId")
        
        URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.removeTagUserURL as String, param: params, completionHandler: {(responseObject, error) ->  () in
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
                    
                    NotificationCenter.default.post(name: notif_TagRemoved, object: objDict)
                    
                    AlertView.sharedManager.displayMessage(title: "", msg: message, controller: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
                  
                    
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
        
    }
    
    
    @objc func deleteWallPostApi(){
        
        let indexpaths =  self.cvFeedsPost.indexPathsForVisibleItems
        for indPath in indexpaths {
            let cell = cvFeedsPost.cellForItem(at: indPath) as? FeedsCollectionViewCell
            cell?.pauseVideo()
        }
                
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
                    

                    AppDelegate.sharedInstance.navigationController?.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)

                //  AlertView.sharedManager.displayMessage(title: "Pickzon", msg: message, controller: AppDelegate.sharedInstance.navigationController!.topViewController!)
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
        
    }
    
    @objc func doubleTapped() {
        if objWallPost.isLike == 0{
            likeDislikePostAPICall()
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
       
        //let isDownload  = Settings.sharedInstance.isDownload
         let isDownload  =  0
        
        if objWallPost.userInfo?.id == Themes.sharedInstance.Getuser_id() {
          
            if objWallPost.sharedWallData == nil {
                if Calendar.current.dateComponents([.hour], from: objWallPost.createdAt, to: Date()).hour ?? 0 < 24 {
                    if isDownload == 1 {
                        controller.listArray = (isMedia) ? ["Download","Share","Edit","Delete"] : ["Share","Edit","Delete"]
                        controller.iconArray = (isMedia) ? ["DownloadVideo","Shareicon","Edit-1","Delete1"] : ["Shareicon","Edit-1","Delete1"]
                    }else {
                        controller.listArray = (isMedia) ? ["Share","Edit","Delete"] : ["Share","Edit","Delete"]
                        controller.iconArray = (isMedia) ? ["Shareicon","Edit-1","Delete1"] : ["Shareicon","Edit-1","Delete1"]
                    }
                }else {
                    if isDownload == 1 {
                        controller.listArray = (isMedia) ? ["Download","Share","Delete"] : ["Share","Delete"]
                        controller.iconArray = (isMedia) ? ["DownloadVideo","Shareicon","Delete1"] : ["Shareicon","Delete1"]
                    }else {
                        controller.listArray = (isMedia) ? ["Share","Delete"] : ["Share","Delete"]
                        controller.iconArray = (isMedia) ? ["Shareicon","Delete1"] : ["Shareicon","Delete1"]
                    }
                }

            }else {
                if isDownload == 1 {
                    controller.listArray = (isMedia) ? ["Download","Share","Delete"] : ["Share","Delete"]
                    controller.iconArray = (isMedia) ? ["DownloadVideo","Shareicon","Delete1"] : ["Shareicon","Delete1"]
                }else {
                    controller.listArray = (isMedia) ? ["Share","Delete"] : ["Share","Delete"]
                    controller.iconArray = (isMedia) ? ["Shareicon","Delete1"] : ["Shareicon","Delete1"]
                }
            }
            
        }else{
            if isDownload == 1 {
                 controller.listArray =  (isMedia) ? ["Download","Share","Block Post","Report"] : ["Share","Block Post","Report"]
                controller.iconArray = (isMedia) ? ["DownloadVideo","Shareicon","BlockAccount","Report"] : ["Shareicon","BlockAccount","Report"]
            }else {
                
                controller.listArray =  (isMedia) ? ["Share","Block Post","Report"] : ["Share","Block Post","Report"]
                controller.iconArray = (isMedia) ? ["Shareicon","BlockAccount","Report"] : ["Shareicon","BlockAccount","Report"]
            }
        }
        
        if (isFromSavedList == true){
            controller.listArray.add("Remove")
            //controller.iconArray.add("feedsSavePost")
            controller.iconArray.add("feedsSavePostRed")
        }
            
        if  objWallPost.boost == 1 ||  objWallPost.boost == 2 || objWallPost.boost == 3 {
            controller.listArray.remove("Edit")
            controller.iconArray.remove("Edit-1")
        }
        
        if Settings.sharedInstance.isSuperUser == 1 && Themes.sharedInstance.Getuser_id() != objWallPost.userInfo?.id as? String ?? ""{
            controller.listArray.add("Warning")
            controller.iconArray.add("caution")
        }
        
       // var isTagAvailable = false
        let pickzonId = Themes.sharedInstance.getPickzonId()
      
        if objWallPost.taggedPeople.contains("@\(pickzonId)") == true && pickzonId.trim().count > 0{
            controller.listArray.add("Remove Tag")
            controller.iconArray.add("Tag")
        }
        
        //controller.videoIndex = sender.tag
        controller.delegate = self
        let useInlineMode = AppDelegate.sharedInstance.navigationController!.topViewController!.view != nil
        
        let sheet = SheetViewController(
            controller: controller,
            sizes: [.percent(0.30), .intrinsic],
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
        
        var urlArray:Array<String> = Array<String>()
        
        if objWallPost.sharedWallData == nil {
            urlArray = objWallPost.urlArray
        }else {
            urlArray = objWallPost.sharedWallData.urlArray
        }
        
        if title == "Remove"{
            self.deleteSavedPostApi(index: index)
        }else if title == "Share"{
            self.sharePostAPI()
       
         }else  if title == "Download"{
             AppDelegate.sharedInstance.navigationController?.topViewController!.downloadAllMedia(urlArray: urlArray)
             
         }else  if title == "Delete"{
             
             AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to delete selected post?", buttonTitles: ["Yes","No"], onController: (AppDelegate.sharedInstance.navigationController?.topViewController)!) { title, index in
                 
                 if index == 0{
                     
                     self.deleteWallPostApi()
                 }
             }
             
         }else if title == "Edit"{
           
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
             
             let destVc:ReportUserVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ReportUserVC") as! ReportUserVC
             destVc.modalPresentationStyle = .overCurrentContext
             destVc.modalTransitionStyle = .coverVertical
             destVc.reportType = .post
             destVc.reportingId = objWallPost.id
             AppDelegate.sharedInstance.navigationController?.topViewController?.present(destVc, animated: true, completion: nil)
            
         }else if title == "Warning"{
             /* self.messageAlertWithReason(postIndex: index)
            AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to warn user?", buttonTitles: ["No","Yes"], onController:  AppDelegate.sharedInstance.navigationController?.topViewController!, dismissBlock:{ title, index in
                 if index == 1{
                    
                 }
             }
             )*/
             
             let destVc:ReportUserVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ReportUserVC") as! ReportUserVC
             destVc.modalPresentationStyle = .overCurrentContext
             destVc.modalTransitionStyle = .coverVertical
             destVc.reportType = .warnUser
             destVc.reportingId = objWallPost.id
             destVc.toReportedUserId = objWallPost.userInfo?.id ?? ""
             AppDelegate.sharedInstance.navigationController?.topViewController?.present(destVc, animated: true, completion: nil)
             
         }else  if title == "Remove Tag"{
             self.removeTagFromPostApi()
         }
    }
    
    
    
    
    func messageAlertWithReason(postIndex:Int) {
        
        let alertController = UIAlertController(title: "Reason", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Submit", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            if (firstTextField.text?.count ?? 0 > 0){
                self.warnUserRegardingPostApi(reason: firstTextField.text!)}
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in })
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Reason"
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
    
    @objc  func handleProfilePicTap(_ sender: UITapGestureRecognizer? = nil){
        
        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.otherMsIsdn = objWallPost.userInfo?.id ?? ""
        AppDelegate.sharedInstance.navigationController?.pushViewController(profileVC, animated: true)
        
        
    }
    
    @objc func openProfileSharedUser(){
          let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn = objWallPost.sharedWallData.userInfo?.id ?? ""
            AppDelegate.sharedInstance.navigationController?.pushViewController(profileVC, animated: true)
    }

    
    @objc  func handleSharedProfilePicTap(_ sender: UITapGestureRecognizer? = nil){
        
        
            
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn = objWallPost.sharedWallData.userInfo?.id ?? ""
            AppDelegate.sharedInstance.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc func followBtnAction(){
            followFeedsUser(isShared: false)
    }
    
    @objc func followSharedBtnAction(_ sender:UIButton){
        
        followFeedsUser(isShared: true, isSharingUser: true)
    }
    
    
  
    func warnUserRegardingPostApi(reason:String){
        
        let params = ["to":objWallPost.userInfo?.id as? String ?? "","reason":reason,"feedId":objWallPost.id] as [String : Any]
        
        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.userWarn, param: params as NSDictionary, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1 {
                    
                }
                AppDelegate.sharedInstance.navigationController?.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
            }
        })
    }
    

    
    
    
    
    
    
    func followFeedsUser(isShared:Bool, isSharingUser:Bool = false) {
                
        let  userId:String = (isShared) ? (objWallPost.sharedWallData.userInfo?.id ?? "") : (objWallPost.userInfo?.id ?? "")
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
                let message = result["message"]
              //  let payloadDict = result["payload"] as? NSDictionary ?? [:]
              /*  let statusType = payloadDict["statusType"] as? String ?? ""
                let followStatus = payloadDict["isFollow"] as? Int ?? 0
                */
                if status == 1{
                                                        
                    var objDict:Dictionary<String, Any> = [:]
                    if isShared == false {
                        objDict = ["userId":self.objWallPost.userInfo?.id ?? "", "isFollowed":1]
                    }else {
                        objDict = [ "userId":self.objWallPost.sharedWallData.userInfo?.id ?? "", "isFollowed":1]
                    }
                    
                    NotificationCenter.default.post(name: notif_FeedFollowed, object: objDict)
                  
                }
                DispatchQueue.main.async {
                    
                    AppDelegate.sharedInstance.navigationController?.view.makeToast(message: message as! String, duration: 2, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
}


extension FeedsCell{
    
    //MARK: convertAttributtedColorText
    func convertAttributtedColorText(text:String) -> NSAttributedString {
        
        let  originalStr = text
        let att = NSMutableAttributedString(string: originalStr);
        let detectorType: NSTextCheckingResult.CheckingType = [.link, .phoneNumber]
        
        let mentionPattern = "\\B@[A-Za-z0-9_.]+"
        let mentionRegex = try? NSRegularExpression(pattern: mentionPattern, options: [.caseInsensitive])
        let mentionMatches  = mentionRegex?.matches(in: originalStr, options: [], range: NSMakeRange(0, originalStr.utf16.count
                                                                                                    ))
        
        for result in mentionMatches! {
            if let range1 = Range(result.range, in: originalStr) {
                let matchResult = originalStr[range1]
                
                if matchResult.count > 0  {
                    //                  att.addAttributes([NSAttributedString.Key.foregroundColor:Themes.sharedInstance.tagAndLinkColor(),NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 18.0)], range: result.range)
                    att.addAttributes([NSAttributedString.Key.foregroundColor:Themes.sharedInstance.tagAndLinkColor()], range: result.range)
                }
            }
        }
                
        let hashtagPattern =  "#[^\\s!@#\\$%^&*()=+.\\/,\\[{\\]};:'\"?><]+" //(^|\\s)#([A-Za-z_][A-Za-z0-9_]*)"
        let regex = try? NSRegularExpression(pattern: hashtagPattern, options: [.caseInsensitive])
        let matches  = regex?.matches(in: originalStr, options: [], range: NSMakeRange(0, originalStr.utf16.count))
        
        for result in matches! {
            if let range1 = Range(result.range, in: originalStr) {
                let matchResult = originalStr[range1]
                
                if matchResult.count > 0  {
                    att.addAttributes([NSAttributedString.Key.foregroundColor:Themes.sharedInstance.tagAndLinkColor()], range: result.range)
                }
            }
        }
        
        do {
            let detector = try NSDataDetector(types: detectorType.rawValue)
            let results = detector.matches(in: originalStr, options: [], range: NSRange(location: 0, length:
                                                                                            originalStr.utf16.count))
            for result in results {
                if let range1 = Range(result.range, in: originalStr) {
                    let matchResult = originalStr[range1]
                    
                    if matchResult.count > 0  {
                        att.addAttributes([NSAttributedString.Key.foregroundColor:Themes.sharedInstance.tagAndLinkColor()], range: result.range)
                    }
                }
            }
        } catch {
            print("handle error")
        }
        return att
    }
    
}

extension FeedsCell : FeedsCommentDelegate,UploadFilesDelegate,CoinUpDelegate{
    
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
                        AppDelegate.sharedInstance.navigationController?.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                       // self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        }
    }
    
    func commentAdded(commentText: String, selPostIndex: Int, isFromShared: Bool, isFromDelete:Bool,commentCount:Int16) {
        
        let objDict = ["feedId":self.objWallPost.id, "commentText":commentText, "isFromShared":isFromShared, "isFromDelete":isFromDelete, "commentCount":commentCount] as [String : Any]
        NotificationCenter.default.post(name: nofit_CommentAdded, object: objDict)
    }
}




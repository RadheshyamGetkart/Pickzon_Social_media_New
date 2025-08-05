//
//  ProfileHeaderTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 12/21/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher
import OnlyPictures


protocol SuggestionsDelegate: AnyObject{
    
    func clickedUserIndex(index: Int, section: Int)
    func clickedFollowUser(index: Int, section: Int)
    func cancelSuggestionUser(index: Int, section: Int)
    
    func getSelectedUser()
}



class ProfileHeaderTblCell: UITableViewCell {

    @IBOutlet weak var bgVwBtnOption:UIViewX!
    @IBOutlet weak var profilePicView:ImageWithSvgaFrame!
    @IBOutlet weak var btnOption:MIBadgeButton!
    @IBOutlet weak var btnBack:UIButtonX!
    @IBOutlet weak var lblPickzonId:UILabel!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var lblHeadline:UILabel!
    @IBOutlet weak var lblLocation:UILabel!
    @IBOutlet weak var lblDescription:ExpandableLabel!
    @IBOutlet weak var lblPostCount:UILabel!
    @IBOutlet weak var btnPostCount:UIButton!
    @IBOutlet weak var lblFollowersCount:UILabel!
    @IBOutlet weak var btnFollowerCount:UIButton!
    @IBOutlet weak var lblFollowingCount:UILabel!
    @IBOutlet weak var btnFollowingCount:UIButton!
    @IBOutlet weak var btnFollow:UIButtonX!
    @IBOutlet weak var btnMessage:UIButtonX!
    @IBOutlet weak var btnContact:UIButtonX!
    @IBOutlet weak var cnstrntHt_FollowMessageBgVw:NSLayoutConstraint!
    @IBOutlet weak var imgVwCelecbrity:UIImageView!
    @IBOutlet weak var btnEditProfile:UIButton!
    @IBOutlet weak var imgVwBanner:UIImageViewX!
    @IBOutlet weak var collectioVwSuggestion:UICollectionView!
    @IBOutlet weak var btnSeeMoreSuggestion:UIButton!
    @IBOutlet weak var cnstrntHt_SuggestionCollectionVw :NSLayoutConstraint!
    @IBOutlet weak var bgViewMutualFriends:UIView!
    @IBOutlet weak var lblSuggestionTitle :UILabel!
    @IBOutlet weak var btnWallet:UIButton!
    
    @IBOutlet weak var bgVwAngel:UIView!
    @IBOutlet weak var btnAngel:UIButton!
    @IBOutlet weak var lblAngelCount :UILabel!
    @IBOutlet weak var talentCategoryImageVw :UIImageView!

    @IBOutlet weak var cnstrntHt_MutualFriendVw :NSLayoutConstraint!
    @IBOutlet weak var pictureView :UIView!
    @IBOutlet weak var lblMutualFriendMessage :UILabel!
    @IBOutlet weak var cnstrntHt_SeeAll :NSLayoutConstraint!

    @IBOutlet weak var imgViewMutualUser1:UIImageViewX!
    @IBOutlet weak var imgViewMutualUser2:UIImageViewX!
    @IBOutlet weak var cnstrntHt_MutualUser1 :NSLayoutConstraint!
    @IBOutlet weak var cnstrntHt_MutualUser2 :NSLayoutConstraint!

    @IBOutlet weak var imgVwGiftingLevel:UIImageViewX!

    
    @IBOutlet weak var btnMutualFriend:UIButton!
    weak var delegate:SuggestionsDelegate? = nil

    @IBOutlet weak var btnCopy:UIButton!

    var picturesArray = Array<Dictionary<String, Any>>()
    var suggestionArray = Array<Dictionary<String, Any>>()
    
    var userId = ""
    @IBOutlet weak var lblSeperatorAngel:UIView!
    @IBOutlet weak var btnNotVerified:UIButton!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profilePicView.initializeView()

        btnEditProfile.layer.cornerRadius = btnEditProfile.layer.frame.size.width/2.0
        btnEditProfile.clipsToBounds = true
        
        collectioVwSuggestion.register(UINib(nibName: "SuggestionCollectionCell", bundle: nil),
                                       forCellWithReuseIdentifier: "SuggestionCollectionCell")
        collectioVwSuggestion.delegate = self
        collectioVwSuggestion.dataSource = self
        self.btnContact.setImageTintColor(UIColor.systemBlue)
        imgVwGiftingLevel.isUserInteractionEnabled = true
        lblDescription.numberOfLines = 3
        lblDescription.collapsed = true
        lblDescription.collapsedAttributedLink = NSAttributedString(string: " Read more" ,attributes:  [.foregroundColor:UIColor.systemBlue])
       

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    override func prepareForReuse() {
            super.prepareForReuse()
        lblDescription.collapsed = true
        lblDescription.text = nil
        }
    
    func setProfileInfoData(userObj:PickzonUser){
      
        self.profilePicView.setImgView(profilePic: userObj.profilePic, remoteSVGAUrl: userObj.avatarSVGA,changeValue: 18)

        btnOption.badgeBackgroundColor = UIColor.systemRed
        self.btnContact.isHidden = true
       
      //  self.btnWallet.isHidden = (userObj.isWallet == 1 && Themes.sharedInstance.Getuser_id() == userObj.id) ? false : true
        self.btnWallet.isHidden  = true
        self.btnOption.badgeString = ""
        self.btnEditProfile.isHidden = true
        
        if (userObj.id == Themes.sharedInstance.Getuser_id() || userId == Themes.sharedInstance.Getuser_id()){
            self.btnEditProfile.isHidden = false
            self.cnstrntHt_FollowMessageBgVw.constant = 0
          //  btnOption.badgeString = (userObj.requestCount == "" || userObj.requestCount == "0") ?  "" : userObj.requestCount
        }else{
            self.cnstrntHt_FollowMessageBgVw.constant = 45
            self.btnEditProfile.isHidden = true
            
            if (userObj.showEmail == 1 || userObj.showMobile == 1) && (userObj.email.count > 0 || userObj.mobileNo.count > 0){
                self.btnContact.isHidden = false
            }
        }
        
        self.pictureView.updateConstraints()
        if userObj.mutualFriend.count == 0{
            self.cnstrntHt_MutualFriendVw.constant = 0
            self.cnstrntHt_MutualUser1.constant = 0
            self.cnstrntHt_MutualUser2.constant = 0
        }else{
           
            self.cnstrntHt_MutualFriendVw.constant = 50
            var nameUser = [String]()
            var index = 0
            self.imgViewMutualUser1.isHidden = true
            self.imgViewMutualUser2.isHidden = true
            self.pictureView.isHidden = true
            for userDict in userObj.mutualFriend{

                nameUser.append(userDict["pickzonId"] as? String ?? "")
                var profilePic = (userDict["profilePic"] as? String ?? "")
                
                if profilePic.length > 0  && !profilePic.contains("http"){
                    if profilePic.prefix(1) == "." {
                        profilePic = String(profilePic.dropFirst(1))
                    }
                    profilePic = Themes.sharedInstance.getURL() + profilePic
                }
                if index == 1{
                    self.cnstrntHt_MutualUser1.constant = 30
                    self.imgViewMutualUser1.isHidden = false
                    self.imgViewMutualUser1.kf.setImage(with: URL(string: profilePic), placeholder: PZImages.avatar, options: [.processor(DownsamplingImageProcessor(size: self.imgViewMutualUser1.frame.size)),
                                                                                                                               .scaleFactor(UIScreen.main.scale)], progressBlock: nil) { result in }
                }else if index == 0{
                    self.cnstrntHt_MutualUser2.constant = 30
                    self.pictureView.isHidden = false
                    self.imgViewMutualUser2.isHidden = false
                    self.imgViewMutualUser2.kf.setImage(with: URL(string: profilePic), placeholder: PZImages.avatar, options: [.processor(DownsamplingImageProcessor(size: self.imgViewMutualUser2.frame.size)),
                                                                                                                               .scaleFactor(UIScreen.main.scale)], progressBlock: nil) { result in }
                }
                index = index + 1
            }
            
            
            let  message =  (index <= 1 ) ?  "" : " and others"

            if nameUser.count == 0 {
                lblMutualFriendMessage.setAttributedText(firstText: "Followed by ", firstcolor: .secondaryLabel, seconText: "\(nameUser.joined(separator: ","))\(message)" , secondColor: .label)
            }else if nameUser.count > 0 {
                lblMutualFriendMessage.setAttributedText(firstText: "Followed by ", firstcolor: .secondaryLabel, seconText: "\(nameUser.joined(separator: ","))\(message)" , secondColor: .label)
            }

        }
              
        if userObj.suggestedUsers.count == 0{
            self.btnSeeMoreSuggestion.setTitle("", for: .normal)
            self.lblSuggestionTitle.text = ""
            self.cnstrntHt_SuggestionCollectionVw.constant = 0
            self.cnstrntHt_SeeAll.constant = 0
        }else{
            self.cnstrntHt_SuggestionCollectionVw.constant = 200
            self.btnSeeMoreSuggestion.setTitle("See All", for: .normal)
            self.lblSuggestionTitle.text = "Suggested for you"
            self.cnstrntHt_SeeAll.constant = 30
        }
        
     
        
        
        self.imgVwBanner.kf.setImage(with: URL(string: userObj.coverImage), placeholder: PZImages.defaultCover, options: nil, progressBlock: nil) { result in
            switch result {
            case .success(let value):
               
                self.imgVwBanner.contentMode =  .scaleAspectFill
                if let averageColor = value.image.getAverageColour {
                    self.imgVwBanner.backgroundColor = averageColor
                }
            case .failure(let error):
                // Handle error case
                print("Error loading image: \(error)")
            }
            
        }
    
                
//        self.btnFollow.setImage((userObj.followStatus == 0) ? PZImages.followPlus : PZImages.followCheckWhite, for: .normal)
        
        self.btnFollow.setImage((userObj.isFollow == 0 || userObj.isFollow == 3) ? PZImages.followPlus : PZImages.followCheckWhite, for: .normal)

        self.lblPickzonId.text = "@\(userObj.pickzonId)"
        self.lblLocation.text = userObj.livesIn
        self.lblPostCount.text = userObj.postCount
        self.lblFollowersCount.text = userObj.followerCount
        self.lblFollowingCount.text = userObj.followingCount
        
        switch userObj.celebrity{
            
        case 1:
            self.imgVwCelecbrity.isHidden = false
            self.imgVwCelecbrity.image = PZImages.greenVerification
        case 4:
            self.imgVwCelecbrity.isHidden = false
            self.imgVwCelecbrity.image = PZImages.goldVerification
        case 5:
            self.imgVwCelecbrity.isHidden = false
            self.imgVwCelecbrity.image = PZImages.blueVerification
        default:
            self.imgVwCelecbrity.isHidden = true
        }
        
        
        if userObj.isBlock == 1 {
            self.btnFollow.setTitle("Unblock", for: .normal)
        }else {
            
            self.btnFollow.setTitle(getFollowUnfollowRequestedText(isFollowValue: userObj.isFollow) , for: .normal)
            
                if userObj.isFollow == 1  {
                    
                  //  self.btnFollow.setTitle("Followed", for: .normal)
                    self.btnFollow.setImageTintColor(UIColor.black)
                    self.btnFollow.backgroundColor = Themes.sharedInstance.colorWithHexString(hex: "#D9D9D9") 
                    self.btnFollow.setTitleColor(UIColor.black, for: .normal)
                    self.btnMessage.setImageTintColor(UIColor.systemBlue)
                    self.btnMessage.backgroundColor = .clear // CustomColor.sharedInstance.newThemeColor
                  //  self.btnMessage.setTitleColor(UIColor.white, for: .normal)
               
                }else{

                    self.btnFollow.setImageTintColor(UIColor.white)
                    self.btnFollow.backgroundColor = CustomColor.sharedInstance.newThemeColor
                    self.btnFollow.setTitleColor(UIColor.white, for: .normal)
                   // self.btnMessage.setTitleColor(CustomColor.sharedInstance.newThemeColor, for: .normal)
                    self.btnMessage.setImageTintColor(UIColor.systemBlue)
                    self.btnMessage.backgroundColor =  .clear //UIColor.white
                    self.btnMessage.layer.borderColor = CustomColor.sharedInstance.newThemeColor.cgColor
                }
        }
        
        if userObj.website.count > 0 && userObj.description.count > 0{
            
        let isNewLIneLast = userObj.description.hasSuffix("\n") ? "" : "\n"
            
        self.lblDescription.attributedText = convertAttributtedColorText(text: "\(userObj.description)\(isNewLIneLast)\(userObj.website)")
            

        }else if userObj.website.count > 0{
            self.lblDescription.attributedText = convertAttributtedColorText(text: userObj.website)
        }else{
            self.lblDescription.attributedText = convertAttributtedColorText(text:userObj.description)
        }
        
        if userObj.headline.count > 0 && userObj.jobProfile.count > 0 {
            self.lblHeadline.text = "\(userObj.jobProfile) | \(userObj.headline)"
            
        }else if userObj.headline.count > 0 && userObj.jobProfile.count == 0 {
            self.lblHeadline.text = "\(userObj.headline)"
            
        }else if userObj.headline.count == 0 && userObj.jobProfile.count > 0 {
            self.lblHeadline.text = "\(userObj.jobProfile)"
        }else{
            self.lblHeadline.text = ""
        }
        
        if userObj.showName == 0{
            self.lblName.text = ""
        }else{
            self.lblName.text = userObj.name
        }
        
        if userObj.giftingLevel.count > 0{
            self.imgVwGiftingLevel.isHidden = false
            self.imgVwGiftingLevel.kf.setImage(with: URL(string: userObj.giftingLevel),  progressBlock: nil) { result in }
        }else{
            self.imgVwGiftingLevel.isHidden = true
        }
        
        if userObj.talentCategory.count > 0{
            self.talentCategoryImageVw.isHidden = false
            self.talentCategoryImageVw.kf.setImage(with: URL(string: userObj.talentCategory),  progressBlock: nil) { result in }
        }else{
            self.talentCategoryImageVw.isHidden = true
        }
        
        self.lblAngelCount.text = userObj.angelsCount
        
        if userObj.angelsCount == "0" || userObj.angelsCount.count == 0 {
            self.bgVwAngel.isHidden = true
            self.lblSeperatorAngel.isHidden = true
        }else{
            self.bgVwAngel.isHidden = false
            self.lblSeperatorAngel.isHidden = false
        }
    }
    
    
    func convertAttributtedColorText(text:String) -> NSAttributedString{
        
        let  originalStr = text
        let myAttribute = [NSAttributedString.Key.font: UIFont(name: "Roboto-Regular", size: 16.0)!]
       
        let att = NSMutableAttributedString(string: originalStr, attributes: myAttribute)
        
        let detectorType: NSTextCheckingResult.CheckingType = [.link, .phoneNumber]
        
        
        let mentionPattern = "\\B@[A-Za-z0-9_.]+"
        let mentionRegex = try? NSRegularExpression(pattern: mentionPattern, options: [.caseInsensitive])
        let mentionMatches  = mentionRegex?.matches(in: originalStr, options: [], range: NSMakeRange(0, originalStr.utf16.count))
        
        for result in mentionMatches! {
            if let range1 = Range(result.range, in: originalStr) {
                let matchResult = originalStr[range1]
                
                if matchResult.count > 0  {
                    att.addAttributes([NSAttributedString.Key.foregroundColor:Themes.sharedInstance.tagAndLinkColor(),NSAttributedString.Key.font: UIFont(name: "Roboto-Regular", size: 16.0)!], range: result.range)
                }
            }
        }
        
        
        let hashtagPattern = "#[^\\s!@#\\$%^&*()=+.\\/,\\[{\\]};:'\"?><]+" //"(^|\\s)#([A-Za-z_][A-Za-z0-9_]*)"
        let regex = try? NSRegularExpression(pattern: hashtagPattern, options: [.caseInsensitive])
        let matches  = regex?.matches(in: originalStr, options: [], range: NSMakeRange(0, originalStr.utf16.count))
        
        for result in matches! {
            if let range1 = Range(result.range, in: originalStr) {
                let matchResult = originalStr[range1]
                
                if matchResult.count > 0  {
                    att.addAttributes([NSAttributedString.Key.foregroundColor:Themes.sharedInstance.tagAndLinkColor(),NSAttributedString.Key.font: UIFont(name: "Roboto-Regular", size: 16.0)!], range: result.range)
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
                        att.addAttributes([NSAttributedString.Key.foregroundColor:Themes.sharedInstance.tagAndLinkColor(),NSAttributedString.Key.font: UIFont(name: "Roboto-Regular", size: 16.0)!], range: result.range)
                    }
                }
            }
        } catch {
            print("handle error")
        }
        return att
    }
}



//MARK: - UICollectionview delegate and datasource

extension ProfileHeaderTblCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return suggestionArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestionCollectionCell", for: indexPath) as! SuggestionCollectionCell
       
          if let userDict = suggestionArray[indexPath.item] as? NSDictionary {
            
            cell.lblName.text = (userDict["name"] as? String ?? "").capitalized
            cell.lblUserName.text =  (userDict["jobProfile"] as? String ?? "") //"Suggested for you"
            
            var profilePic = (userDict["profilePic"] as? String ?? "")
            if profilePic.length > 0  && !profilePic.contains("http"){
                if profilePic.prefix(1) == "." {
                    profilePic = String(profilePic.dropFirst(1))
                    profilePic = Themes.sharedInstance.getURL() + profilePic
                }
            }
            
            cell.profileImgView.setImgView(profilePic: profilePic, frameImg: userDict["avatar"] as? String ?? "")
            cell.btnFollow.setTitle("Follow", for: .normal)
            cell.imgVwCelebrity.isHidden = ((userDict["celebrity"] as? Int ?? 0) == 1) ? false : true
           
              let jobProfile =  userDict["jobProfile"] as? String ?? ""
              let livesIn =  userDict["livesIn"] as? String ?? ""
              let pickzonId =  userDict["pickzonId"] as? String ?? ""
              
              if jobProfile.length > 0 {
                cell.lblUserName.text =   jobProfile
              }else if  livesIn.length > 0  {
                cell.lblUserName.text =  livesIn
              }else {
                  cell.lblUserName.text =  "@\(pickzonId)"
              }
              
        }
        cell.btnFollow.tag = indexPath.item
        cell.btnFollow.addTarget(self, action: #selector(followBtnAction(_ : )), for: .touchUpInside)
        cell.btnClose.tag = indexPath.item
        cell.btnClose.addTarget(self, action: #selector(closeBtnAction(_ : )), for: .touchUpInside)
        cell.btnClose.isHidden = true
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.frame.size.width/3.0 , height: 160)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.clickedUserIndex(index: indexPath.row, section: 0)
    }
    
    //MARK: - Follow Btn Action
    
    @objc func followBtnAction(_ sender : UIButton){
        delegate?.clickedFollowUser(index: sender.tag, section: 0)
        
    }
    
    @objc func closeBtnAction(_ sender : UIButton){
       // delegate?.cancelSuggestionUser(index: sender.tag, section: sectionIndex)
    }
        
}

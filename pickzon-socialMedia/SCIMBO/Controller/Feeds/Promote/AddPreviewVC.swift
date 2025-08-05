//
//  AddPreviewVC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 5/24/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//


import UIKit
import FittedSheets
import IHKeyboardAvoiding
import IQKeyboardManager
import SCIMBOEx
import RxSwift
class AddPreviewVC: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    var states : Array<Bool>!

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnNext:UIButton!
    
    var arrwallPost:Array<WallPostModel> = Array<WallPostModel>()
    var selRowIndex = 0
    var postId = ""
    

    
    //MARK: - Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.register(UINib(nibName: "FeedsPromoteTblCell", bundle: nil), forCellReuseIdentifier: "FeedsPromoteTblCell")
        tblView.register(UINib(nibName: "FeedsSharedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedsSharedTableViewCell")
        
        KeyboardAvoiding.avoidingView = self.tblView
        tblView.rowHeight = 200 + self.view.frame.size.width
        tblView.estimatedRowHeight = UITableView.automaticDimension

        
        getSingleWallPost()
        
        
        self.states = [Bool](repeating: true, count: self.arrwallPost.count)

        self.tblView.separatorStyle = .none

        self.tblView.reloadData()

        btnNext.layer.cornerRadius = btnNext.frame.height / 2.0

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
       
        
    }
    
    //MARK: - UIButton Action Methods
    @IBAction func backBtnAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtnAction(_ sender: Any) {
        let viewController:WalletInfoVC = StoryBoard.promote.instantiateViewController(withIdentifier: "WalletInfoVC") as! WalletInfoVC
        viewController.postId = self.postId
        self.navigationController?.pushView(viewController, animated: true)
        
    }
    //MARK: - API Implementation
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
                
            }
            else{
                
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
    
    
    func getSingleWallPost(){
        
        let param:NSDictionary = ["wallPostId":postId]
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.getSingleWallPost as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }
            else{
                let result = responseObject! as NSDictionary
                let errNo = result["errNum"] as? String ?? ""
                let message = result["message"]
                if errNo == "99"{
                    let data = result.value(forKey: "wallPost") as? NSArray ?? []
                    self.arrwallPost.removeAll()
                    for d in data
                    {
                        let objPost = WallPostModel(dict: d as? NSDictionary ?? [:])
                        self.arrwallPost.append(objPost)
                        
                    }
                    self.states = [Bool](repeating: true, count: self.arrwallPost.count)
                    
                    DispatchQueue.main.async {
                        self.tblView.reloadData()
                    }
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
                
                
            }
        })
    }
    
    
    
       
    
    
   
    
   
    
    
    
  
    
    
    
   
    
    
    //MARK: - TableviewDataSource
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrwallPost.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: noti_PausePlayer), object:nil,userInfo: ["tag":indexPath.row])
        
        let objWallPost = arrwallPost[indexPath.row]
        
        var txtFeeling = ""
        if objWallPost.feeling.count > 0 {
            txtFeeling = (objWallPost.feeling["image"] as? String ?? "") + " " +  (objWallPost.feeling["name"]  as? String ?? "")
        }else if objWallPost.activities.count > 0 {
            txtFeeling = (objWallPost.activities["image"] as? String ?? "") + " " +  (objWallPost.activities["name"] as? String ?? "")
        }
        
        var cell: FeedsCell!
        var cvSize:CGFloat = 0

        if objWallPost.sharedWallData == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "FeedsPromoteTblCell", for: indexPath) as! FeedsPromoteTblCell
            cell.backgroundColor = UIColor(red: 46.0/255.0, green: 27.0/255.0, blue: 138.0/255.0, alpha: 1.0)
            cell.btnPromote.isHidden = true
            cell.lblDescription.delegate = self
            cell.lblPostDate.text = objWallPost.feedTime
            cell.lblDescription.textReplacementType = .word
            cell.lblDescription.shouldCollapse = true
            cell.lblDescription.numberOfLines = 4
            cell.lblDescription.setLessLinkWith(lessLink: "Read less", attributes: [.foregroundColor:UIColor.red], position: .left)
            

            cell.btnUserName.setTitleColor(UIColor.white, for: .normal)
            cell.lblPostDate.textColor = UIColor.white
            cell.lblLocation.textColor = UIColor.white
            cell.lblDescription.textColor = UIColor.white
            //cell.lblTagPeople.textColor = UIColor.white
            //cell.lblLikesCount.textColor = UIColor.white
            cell.btnShareCount.setTitleColor(UIColor.white, for: .normal)
            cell.btnCommentCount.setTitleColor(UIColor.white, for: .normal)
            
            cell.btnLike.setImageTintColor(UIColor.white)
            cell.btnShare.setImageTintColor(UIColor.white)
            cell.btnComment.setImageTintColor(UIColor.white)
            cell.btnOption.setImageTintColor(UIColor.white)
            cell.imgGlobe.setImageColor(color: UIColor.white)
            
            if states.count > indexPath.row {
                cell.lblDescription.collapsed = states[indexPath.row]
            }
            
            if objWallPost.urlArray.count > 0 {
                cvSize = self.view.frame.width
                cell.cnstrnt_CllctnHeight.constant = self.view.frame.width
            }
            cell.btnUserName.setTitle(objWallPost.userInfo?.name, for: .normal)
            cell.lblLocation.text = objWallPost.place

            cell.lblDescription.attributedText =  (objWallPost.payload + txtFeeling).convertAttributtedColorText()
            
            cell.urlArray = objWallPost.urlArray
            
            if objWallPost.urlArray.count > 0 {
                cell.btnSavePost.isHidden = false
                
                
                if objWallPost.urlArray.count == 1  && objWallPost.urlDimensionArray.count == 1{
                    let objDictDimension = objWallPost.urlDimensionArray[0]
                    let height = objDictDimension["height"] as? Int ?? 0
                    let width = objDictDimension["width"] as? Int ?? 0
                    if width == 0 && height == 0 {
                        cell.cnstrnt_CllctnHeight.constant = self.view.frame.width
                        cvSize = self.view.frame.width
                    }else if width > height {
                        let ratio =  CGFloat(width) / CGFloat(height)
                        cell.cnstrnt_CllctnHeight.constant = self.view.frame.width / ratio
                        cvSize = self.view.frame.width
                    }else {
                        let ratio =  CGFloat(height) / CGFloat(width)
                        
                        cell.cnstrnt_CllctnHeight.constant = self.view.frame.width * ratio
                        cvSize = self.view.frame.width * ratio
                    }
                
                }else  {
                    cell.cnstrnt_CllctnHeight.constant = self.view.frame.width
                    cvSize = self.view.frame.width
                }
                
                
            }else{
                cell.btnSavePost.isHidden = true
                cell.cnstrnt_CllctnHeight.constant = 0
            }
            cell.btnShareCount.isHidden = false
            //cell.imgVwCelecbrity.isHidden = (objWallPost.userInfo?.celebrity == 1) ? false : true
            cell.imgVwCelecbrity.isHidden = true
            if objWallPost.userInfo?.celebrity == 1 {
                cell.imgVwCelecbrity.isHidden = false
                cell.imgVwCelecbrity.image = PZImages.greenVerification
            }else if objWallPost.userInfo?.celebrity == 4 {
                cell.imgVwCelecbrity.isHidden = false
                cell.imgVwCelecbrity.image = PZImages.goldVerification
            }else if objWallPost.userInfo?.celebrity == 5 {
                cell.imgVwCelecbrity.isHidden = false
                cell.imgVwCelecbrity.image = PZImages.blueVerification
            }
            
            cell.cnstrnt_CelebrityWidth.constant = (objWallPost.userInfo?.celebrity == 1 || objWallPost.userInfo?.celebrity == 4) ? 17 : 0
            cell.btnFolow.isHidden = (objWallPost.isFollowed == 0) ? false : true
            
            cell.btnFolow.tag = indexPath.row

            
            if Themes.sharedInstance.Getuser_id() == objWallPost.userInfo?.id  ?? ""{
                cell.btnFolow.isHidden = true
            }
           // if ((objWallPost.userInfo?.profileType.lowercased() == "private") || (objWallPost.postType.lowercased() == "friend" || objWallPost.postType.lowercased() == "private")){
                
                if ( (objWallPost.postType.lowercased() == "friend" || objWallPost.postType.lowercased() == "private")){

                cell.btnShare.isHidden = true
                cell.btnShareCount.isHidden = true
            }
            
            
           
           
        }else {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "FeedsSharedTableViewCell", for: indexPath) as! FeedsSharedTableViewCell
            cell.backgroundColor = UIColor(red: 46.0/255.0, green: 27.0/255.0, blue: 138.0/255.0, alpha: 1.0)
            cell.lblDescription.setLessLinkWith(lessLink: "Read less", attributes: [.foregroundColor:UIColor.red], position: .left)

//            if objWallPost.sharedWallData.userInfo!.profile_pic.count > 0 {
//                cell.btnUserImageShared.kf.setBackgroundImage(with:  URL(string: objWallPost.sharedWallData.userInfo!.profile_pic) , for: .normal)
//            }else {
//              //  cell.btnUserImage.setBackgroundImage(UIImage(named: "avatar")!, for: .normal)
//            }
            
            cell.profilePicViewShared.setImgView(profilePic: objWallPost.sharedWallData.userInfo!.profilePic, frameImg: objWallPost.sharedWallData.userInfo!.avatar)
            
            var sharedtxtfeeling  = ""
            if objWallPost.sharedWallData.feeling.count > 0 {
                sharedtxtfeeling = (objWallPost.sharedWallData.feeling["image"] as? String ?? "") + " " +  (objWallPost.sharedWallData.feeling["name"]  as? String ?? "")
            }else if objWallPost.sharedWallData.activities.count > 0 {
                sharedtxtfeeling = (objWallPost.sharedWallData.activities["image"] as? String ?? "") + " " +  (objWallPost.sharedWallData.activities["name"] as? String ?? "")
            }
            
            
            cell.btnUserName.setTitle(objWallPost.userInfo?.name, for: .normal)
      
            cell.lblLocation.text = "Shared a post " +  objWallPost.feedTime

            cell.imgVwCelecbrity.isHidden = (objWallPost.userInfo?.celebrity == 1) ? false : true
            cell.imgVwCelecbrity.isHidden = true
            if objWallPost.userInfo?.celebrity == 1 {
                cell.imgVwCelecbrity.isHidden = false
                cell.imgVwCelecbrity.image = PZImages.greenVerification
            }else if objWallPost.userInfo?.celebrity == 4 {
                cell.imgVwCelecbrity.isHidden = false
                cell.imgVwCelecbrity.image = PZImages.goldVerification
            }else if objWallPost.userInfo?.celebrity == 5 {
                cell.imgVwCelecbrity.isHidden = false
                cell.imgVwCelecbrity.image = PZImages.blueVerification
            }
            cell.imgVwSharedCelecbrity.isHidden = (objWallPost.sharedWallData.userInfo?.celebrity == 1) ? false : true
            cell.imgVwSharedCelecbrity.isHidden = true
            if objWallPost.sharedWallData.userInfo?.celebrity == 1 {
                cell.imgVwSharedCelecbrity.isHidden = false
                cell.imgVwSharedCelecbrity.image = PZImages.greenVerification
            }else if  objWallPost.sharedWallData.userInfo?.celebrity == 4 {
                cell.imgVwSharedCelecbrity.isHidden = false
                cell.imgVwSharedCelecbrity.image = PZImages.goldVerification
            }else if  objWallPost.sharedWallData.userInfo?.celebrity == 5 {
                cell.imgVwSharedCelecbrity.isHidden = false
                cell.imgVwSharedCelecbrity.image = PZImages.blueVerification
            }
            cell.cnstrnt_CelebrityWidth.constant = (objWallPost.userInfo?.celebrity == 1 || objWallPost.userInfo?.celebrity == 4) ? 17 : 0
            cell.cnstrnt_SharedCelebrityWidth.constant = (objWallPost.sharedWallData.userInfo?.celebrity == 1 || objWallPost.sharedWallData.userInfo?.celebrity == 4) ? 13 : 0
            cell.btnFolow.isHidden = (objWallPost.sharedWallData.isFollowed == 0) ? false : true
            cell.btnSharedFollow.isHidden = (objWallPost.isFollowed == 0) ? false : true
           
            if Themes.sharedInstance.Getuser_id() == objWallPost.sharedWallData.userInfo?.id  ?? ""{
                cell.btnFolow.isHidden = true
            }
            if Themes.sharedInstance.Getuser_id() == objWallPost.userInfo?.id  ?? ""{
                cell.btnSharedFollow.isHidden = true
            }
            cell.btnFolow.tag = indexPath.row
            cell.btnSharedFollow.tag = indexPath.row
            cell.lblPostDate.text = objWallPost.sharedWallData.feedTime
            cell.btnUserNameShared.setTitle(objWallPost.sharedWallData.userInfo?.name, for: .normal)
            cell.btnUserNameShared.tag = indexPath.row
//             cell.btnUserImageShared.tag = indexPath.row
            cell.profilePicViewShared.imgVwProfile?.tag = indexPath.row
            cell.lblLocationShared.text = objWallPost.sharedWallData.place
            cell.lblSharedContents.textReplacementType = .word
            cell.lblSharedContents.shouldCollapse = true
            cell.lblSharedContents.numberOfLines = 4
            cell.lblSharedContents.delegate = self
            cell.lblSharedContents.attributedText =  (objWallPost.payload + txtFeeling).convertAttributtedColorText()
            cell.urlArray = objWallPost.sharedWallData.urlArray
            if objWallPost.sharedWallData.urlArray.count > 0 {
                cell.btnSavePost.isHidden = false
                
                if objWallPost.sharedWallData.urlArray.count == 1  && objWallPost.sharedWallData.urlDimensionArray.count == 1{
                    let objDictDimension = objWallPost.sharedWallData.urlDimensionArray[0]
                    let height = objDictDimension["height"] as? Int ?? 0
                    let width = objDictDimension["width"] as? Int ?? 0
                    if width == 0 && height == 0 {
                        cell.cnstrnt_CllctnHeight.constant = self.view.frame.width
                        cvSize = self.view.frame.width
                    }else if width > height {
                        let ratio =  CGFloat(width) / CGFloat(height)
                        cell.cnstrnt_CllctnHeight.constant = self.view.frame.width / ratio
                        cvSize = self.view.frame.width
                    }else {
                        let ratio =  CGFloat(height) / CGFloat(width)
                        cell.cnstrnt_CllctnHeight.constant = self.view.frame.width * ratio
                        cvSize = self.view.frame.width * ratio
                    }
                    
                }else{
                    cell.cnstrnt_CllctnHeight.constant = self.view.frame.width
                    cvSize = self.view.frame.width
                }
            }else{
                cell.btnSavePost.isHidden = true
                cell.cnstrnt_CllctnHeight.constant = 0

            }
            cell.lblPostDate.text = objWallPost.feedTime
            cell.lblDescription.textReplacementType = .word
            cell.lblDescription.shouldCollapse = true
            cell.lblDescription.numberOfLines = 4
            cell.lblDescription.delegate = self
            if states.count > indexPath.row {
                cell.lblDescription.collapsed = states[indexPath.row]
                cell.lblSharedContents.collapsed = states[indexPath.row]
            }
            
            if objWallPost.urlArray.count > 0 {
                cvSize = self.view.frame.width
                cell.cnstrnt_CllctnHeight.constant = self.view.frame.width
            }

            cell.lblDescription.attributedText =   (objWallPost.sharedWallData.payload + sharedtxtfeeling).convertAttributtedColorText()
        }
        
        cell.profilePicView.setImgView(profilePic: objWallPost.userInfo!.profilePic, frameImg: "")
        cell.btnUserName.tag = indexPath.row
        cell.profilePicView.imgVwProfile?.tag = indexPath.row
        cell.btnLike.setImage((objWallPost.isLike == 1) ? PZImages.heart_Filled : PZImages.heart_blank , for: .normal)
        cell.btnLike.tag = indexPath.row
        cell.btnShare.setImage(UIImage(named: "Shareicon"), for: .normal)
        cell.btnShare.tag = indexPath.row
        cell.btnSavePost.tag = indexPath.row
        if objWallPost.isSave == 0{
            cell.btnSavePost.setImage(PZImages.feedsSavePost, for: .normal)
        }else{
            cell.btnSavePost.setImage(PZImages.feedsSavePostRed, for: .normal)
        }
        cell.btnComment.setImage(UIImage(named: "CommentIcon"), for: .normal)
        cell.btnComment.tag = indexPath.row
        cell.btnCommentCount.tag = indexPath.row
        cell.btnCommentCount.setTitle(objWallPost.totalComment.asFormatted_k_String , for: .normal)
        cell.btnShareCount.setTitle(objWallPost.totalShared.asFormatted_k_String , for: .normal)
        cell.tableIndexPath = indexPath
        cell.cvFeedsPost.updateConstraints()
        cell.selectionStyle = .none
        cell.cvFeedsPost.reloadData()
        cell.btnSavePost.isHidden = true
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        return UITableView.automaticDimension
        
        
        let objWallPost = arrwallPost[indexPath.row]
        let lblFont =  UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        
        var sharedUpperUserContentSize:CGFloat = 0
       // var userContentSize:CGFloat = 73
        var userContentSize:CGFloat = 59
        var descSize:CGFloat = 0
        var tagSize:CGFloat = 0
        var cvSize:CGFloat = 0.0
        
        //For Like, comment and share in bottom of Feed
        let bottomViewSize:CGFloat = 45.0
        
       
        var locationHeight:CGFloat = 0.0
        if objWallPost.place.length > 0 {
            
            locationHeight = URLhandler.sharedinstance.heightForView(text: objWallPost.place, font: lblFont, width: tableView.frame.width - 80)
        }
        if locationHeight < 20{
            locationHeight = 25
        }
        userContentSize = userContentSize + locationHeight
        
        
        var txtfeeling  = ""
        if objWallPost.feeling.count > 0 {
            txtfeeling = (objWallPost.feeling["image"] as? String ?? "") + " " +  (objWallPost.feeling["name"]  as? String ?? "")
        }else if objWallPost.activities.count > 0 {
            txtfeeling = (objWallPost.activities["image"] as? String ?? "") + " " +  (objWallPost.activities["name"] as? String ?? "")
        }
       
        if objWallPost.sharedWallData != nil {
            if (objWallPost.sharedWallData.payload + txtfeeling).trim().length > 0{
                
                let attributedString = NSAttributedString(html: objWallPost.sharedWallData.payload + txtfeeling)

                descSize = URLhandler.sharedinstance.heightForView(text: attributedString?.string ?? "" , font: lblFont, width: tableView.frame.width - 20)
        }
            
            var sharedtxtfeeling  = ""
            if objWallPost.sharedWallData.feeling.count > 0 {
                sharedtxtfeeling = (objWallPost.sharedWallData.feeling["image"] as? String ?? "") + " " +  (objWallPost.sharedWallData.feeling["name"]  as? String ?? "")
            }else if objWallPost.sharedWallData.activities.count > 0 {
                sharedtxtfeeling = (objWallPost.sharedWallData.activities["image"] as? String ?? "") + " " +  (objWallPost.sharedWallData.activities["name"] as? String ?? "")
            }
            
            
            if (objWallPost.payload + sharedtxtfeeling).trim().length > 0{
                
                let attributedString = NSAttributedString(html: objWallPost.sharedWallData.payload + txtfeeling)

                descSize =  descSize + URLhandler.sharedinstance.heightForView(text: attributedString?.string ?? "" , font: lblFont, width: tableView.frame.width - 20)
        }

            
            if objWallPost.sharedWallData.taggedPeople.trim().length > 0 {
            tagSize = URLhandler.sharedinstance.heightForView(text: objWallPost.sharedWallData.taggedPeople, font: lblFont, width: tableView.frame.width - 20)
            }
            
            if objWallPost.taggedPeople.length > 0 {
            tagSize =  tagSize + URLhandler.sharedinstance.heightForView(text: objWallPost.taggedPeople, font: lblFont, width: tableView.frame.width - 20)
            }
            
            sharedUpperUserContentSize = 68
            
           
            if objWallPost.sharedWallData.urlArray.count > 0 {
                cvSize = self.view.frame.width
            }
        }else {
            sharedUpperUserContentSize = 0
            if (objWallPost.payload + txtfeeling).trim().length > 0 {
                let attributedString = NSAttributedString(html: objWallPost.payload + txtfeeling)

                descSize = URLhandler.sharedinstance.heightForView(text: attributedString?.string ?? "", font: lblFont, width: tableView.frame.width - 20)
            }
            
            if objWallPost.taggedPeople.trim().length > 0 {
            tagSize = URLhandler.sharedinstance.heightForView(text: objWallPost.taggedPeople, font: lblFont, width: tableView.frame.width - 20)
            }
            
           
            if objWallPost.urlArray.count > 0 {
                cvSize = self.view.frame.width
            }
        }
        
        var yAxisExtra = 5
        
//        if objWallPost.isAd == 1{
//            yAxisExtra = 0
//        }
        
        if descSize > 0 {
            descSize =  descSize + CGFloat(yAxisExtra)
        }else {
            descSize =  5
        }
        
        if tagSize > 0 {
            tagSize =  tagSize + CGFloat(yAxisExtra)
        }else {
            tagSize =  5
        }
        
        var height = sharedUpperUserContentSize + userContentSize +  (descSize + tagSize) + cvSize + bottomViewSize
        
//        if objWallPost.isAd == 1{
//            height = height - 35
//        }
        return height
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {

       
 
    }
    
  
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
     
       
    }

}




extension AddPreviewVC:ExpandableLabelDelegate{
   
    
    func numberTextClicked(_ label: ExpandableLabel, number: String) {
        
        let point = label.convert(CGPoint.zero, to: tblView)
        if let indexPath = tblView.indexPathForRow(at: point) as IndexPath? {
            if let objWallPost = arrwallPost[indexPath.row] as? WallPostModel {
                if objWallPost.sharedWallData == nil {
                    if objWallPost.userInfo?.celebrity == 1  || objWallPost.userInfo?.celebrity == 4{
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
        
        let destVc:WallPostViewVC = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
        destVc.controllerType = .hashTag
            destVc.hashTag = hashTag
        AppDelegate.sharedInstance.navigationController?.pushViewController(destVc, animated: true)
    }
    
    
    // MARK: ExpandableLabel Delegate
    func willExpandLabel(_ label: ExpandableLabel) {
        tblView.beginUpdates()
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        let point = label.convert(CGPoint.zero, to: tblView)
        if let indexPath = tblView.indexPathForRow(at: point) as IndexPath? {
            if states.count > indexPath.row {
                states[indexPath.row] = false
            }
         //   DispatchQueue.main.async { [weak self] in
              //  self?.tblView.scrollToRow(at: indexPath, at: .none, animated: false)
           // }
        }
        tblView.endUpdates()
    }
    
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        tblView.beginUpdates()
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        let point = label.convert(CGPoint.zero, to: tblView)
        if let indexPath = tblView.indexPathForRow(at: point) as IndexPath? {
            states[indexPath.row] = true
            DispatchQueue.main.async { [weak self] in
                self?.tblView.reloadRows(at: [indexPath], with: .none)
               // self?.tblView.scrollToRow(at: indexPath, at: .none, animated: false)
            }
        }
        tblView.endUpdates()
    }
    
    
    func mentionTextClicked(_ label: ExpandableLabel,mentionText:String){
        
        print("mentionTextClicked \(mentionText)")
        
        let mentionString:String = mentionText
        self.getUserIdFromPickzonId(pickzonId: mentionString.replacingOccurrences(of: "@", with: ""))
    }
    
    func urlTextClicked(_ label: ExpandableLabel,strURL:String) {
        let point = label.convert(CGPoint.zero, to: tblView)
        if let indexPath = tblView.indexPathForRow(at: point) as IndexPath? {
            if arrwallPost.count > indexPath.row {
                
                if arrwallPost[indexPath.row].sharedWallData == nil {
                    //if objWallPost.userInfo?.celebrity == 1 {
                        let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
                        vc.urlString = strURL
                        AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
                   // }
                }else {
                    //if objWallPost.sharedWallData.userInfo?.celebrity == 1 {
                        let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
                        vc.urlString = strURL
                    AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
                    //}
                }
            }
            
        }
    }
}





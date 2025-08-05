//
//  UserInfoVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 10/11/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher


protocol GoliveUserDelegate{
    
    func selectedOption(index:Int,title:String)
    
}

class UserInfoVC: UIViewController {

   // @IBOutlet weak var imgVwProfile:UIImageViewX!
    @IBOutlet weak var profilePicView:ImageWithSvgaFrame!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var btnProfile:UIButton!
    @IBOutlet weak var btnFollow:UIButton!
    @IBOutlet weak var bgView:UIView!
    @IBOutlet weak var imgVwCelebrity:UIImageView!
    @IBOutlet weak var btnOption:UIButton!
    @IBOutlet weak var lblFolloweCount:UILabel!
    @IBOutlet weak var lblFollowingCount:UILabel!
    @IBOutlet weak var imgVwGiftingLevel:UIImageView!

    var istoHideProfile = 0

    var selIndex = 0
    var delegate:GoliveUserDelegate?
    var followStatus = 0
    var isFollowBack = 0
    var userObj = UserModal(dict: [:])
    
    var goLivefromId = ""
    var goLiveToId = ""

    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
//        imgVwProfile.layer.borderColor = UIColor.white.cgColor
//        imgVwProfile.layer.borderWidth = 1.0
//        imgVwProfile.clipsToBounds = true
        
        profilePicView.initializeView()
        btnProfile.layer.cornerRadius = btnProfile.frame.size.height/2.0
        btnProfile.layer.borderWidth = 1.0
        btnProfile.layer.borderColor = UIColor.systemBlue.cgColor
        btnProfile.clipsToBounds = true
        btnProfile.backgroundColor = .white
        
        btnFollow.layer.cornerRadius = btnFollow.frame.size.height/2.0
        btnFollow.clipsToBounds = true
        
        bgView.layer.cornerRadius = 10.0
        bgView.clipsToBounds = true
        
        updateUI(svgaAvatar:"")
        getUserInfoApi()
        
        if istoHideProfile == 1{
            self.btnOption.isHidden = true
            self.btnProfile.isHidden = true
        }
        
        if goLivefromId == Themes.sharedInstance.Getuser_id() ||  goLiveToId == Themes.sharedInstance.Getuser_id(){
            self.btnProfile.isHidden = true

        }else{
            self.btnOption.isHidden = true
        }
        
        
        if Themes.sharedInstance.Getuser_id() == userObj.userId{
            self.btnFollow.isHidden = true
        }
    }
    
    func updateUI(svgaAvatar:String = "") {
      
        let name = userObj.name.count>0 ? userObj.name : userObj.pickzonId
        self.lblName.text = name
      
        self.profilePicView.setImgView(profilePic: userObj.profilePic, remoteSVGAUrl: svgaAvatar,changeValue: 20)
        
        switch userObj.celebrity{
        case 1:
            imgVwCelebrity.isHidden = false
            imgVwCelebrity.image = PZImages.greenVerification
            
        case 4:
            imgVwCelebrity.isHidden = false
            imgVwCelebrity.image = PZImages.goldVerification
        case 5:
            imgVwCelebrity.isHidden = false
            imgVwCelebrity.image = PZImages.blueVerification
            
        default:
            imgVwCelebrity.isHidden = true
        }

}

    //MARK: Api Methods
    
    func getUserInfoApi(){
        
        //   Themes.sharedInstance.showActivityViewTop(View: self.parent!.view, isTop: true)
        let urlStr = Constant.sharedinstance.get_user_information + "?userId=\(userObj.userId)"
        URLhandler.sharedinstance.makeGetCall(url: urlStr, param: [:]) { (responseObject, error) ->  () in
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let msg = result["message"] as? String ?? ""
                
                if status == 1 {
                    if let payload = result["payload"] as? Dictionary<String, Any> {
                        
                        self.lblFolloweCount.text = payload["followerCount"] as? String ?? ""
                        self.lblFollowingCount.text = payload["followingCount"] as? String ?? ""
                        self.followStatus = payload["isFollow"] as? Int ?? 0
                        self.isFollowBack = payload["isFollowBack"] as? Int ?? 0
                        let pickzonId =  payload["pickzonId"] as? String ?? ""
                        self.userObj.name = payload["name"] as? String ?? ""
                        self.userObj.pickzonId = pickzonId
                        self.userObj.profilePic = payload["profilePic"] as? String ?? ""
                        self.userObj.celebrity = payload["celebrity"] as? Int ?? 0
                        self.userObj.avatar = payload["avatar"] as? String ?? ""
                        let avatarSVGA = payload["avatarSVGA"] as? String ?? ""
                        let giftingLevel = payload["giftingLevel"] as? String ?? ""
                        
                        self.updateUI(svgaAvatar: avatarSVGA)
                        
                        if giftingLevel.count > 0{
                            self.imgVwGiftingLevel.isHidden = false

                            self.imgVwGiftingLevel.kf.setImage(with: URL(string: giftingLevel) , options: nil, progressBlock: nil, completionHandler: { response in  })
                        }else{
                            self.imgVwGiftingLevel.isHidden = true
                        }
                        
                        if pickzonId.lowercased() == "pickzon"{
                            self.btnOption.isHidden = true
                        }
                        self.btnFollow.isHidden = false
                        if self.followStatus == 0{
                            self.btnFollow.setTitle("Follow", for: .normal)
                        }else if self.followStatus == 1{
                            self.btnFollow.setTitle("Unfollow", for: .normal)
                        }else if self.followStatus == 2{
                            self.btnFollow.setTitle("Requested", for: .normal)
                        }
                    }
                    
                }else{
                    self.view.makeToast(message: msg , duration: 3, position: HRToastActivityPositionDefault)
                    
                }
            }
        }
    }
    
    
    func followUnfollowApi(){
        
        if (followStatus == 2) {
            //Requested
            self.cancelFriendRequestApi()
        }else{
            
            Themes.sharedInstance.activityView(View: self.view)
            
            let status =  (followStatus == 0) ? "1" : "0"
            
            let param:NSDictionary = ["followedUserId":userObj.userId,"status":status]
            
            URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.follow as String, param: param, completionHandler: {(responseObject, error) ->  () in
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                if(error != nil)
                {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    
                }else{
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int ?? 0
                    let message = result["message"]
                    //  let payloadDict = result["payload"] as? NSDictionary ?? [:]
                    //  let isFollow = payloadDict["isFollow"] as? Int ?? 0
                    
                    if status == 1{
                        
                        self.getUserInfoApi()
                        
                    }else
                    {
                        self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            })
        }
    }
    
    
    
    func cancelFriendRequestApi(){
        Themes.sharedInstance.activityView(View: self.view)
            
        let param:NSDictionary = ["followedUserId":userObj.userId]
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.cancelRequest as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
               // let payloadDict = result["payload"] as? NSDictionary ?? [:]
                //let isFollow = payloadDict["isFollow"] as? Int ?? 0
                
                if status == 1{
                    self.getUserInfoApi()

                }else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
   
    
    //MARK: UIButton Action Methods
     
    @IBAction func profileBtnAction(_ sender : UIButton){
        
        self.delegate?.selectedOption(index: selIndex, title: "profile")
        if self.sheetViewController?.options.useInlineMode == true {
            self.sheetViewController?.attemptDismiss(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
        
    @IBAction func followBtnAction(_ sender : UIButton){
        if followStatus == 0 ||  followStatus == 1{
            self.followUnfollowApi()
        }
    }
    
    @IBAction func optionBtnAction(_ sender : UIButton){
        
        self.delegate?.selectedOption(index: selIndex, title: "option")
        if self.sheetViewController?.options.useInlineMode == true {
            self.sheetViewController?.attemptDismiss(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func closeBtnAction(_ sender : UIButton){
        
        if self.sheetViewController?.options.useInlineMode == true {
            self.sheetViewController?.attemptDismiss(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}




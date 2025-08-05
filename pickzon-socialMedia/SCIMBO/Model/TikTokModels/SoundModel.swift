//
//  SoundModel.swift
//  SCIMBO
//
//  Created by SachTech on 29/07/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import Foundation


struct SoundModel {
    
    var id:AnyObject?
    var section_name:AnyObject?
    var thum : AnyObject?
    var sections_sounds:AnyObject?

    init(dict:NSDictionary){
        self.id = dict.value(forKey: "id") as AnyObject
        self.section_name = dict.value(forKey: "section_name") as AnyObject
        self.thum = dict.value(forKey: "thum") as AnyObject
        self.sections_sounds = dict.value(forKey: "sections_sounds") as AnyObject
    }
}



struct BlockUserModel {
    var _id:String = ""
    var name :String = ""
    var pickzonId:String = ""
    var profilePic:String = ""
    var userId:String = ""
    var actualProfileImage:String = ""
    var celebrity:Int = 0
    var avatar:String = ""

    
    init(dict:NSDictionary){
        
        self._id = dict.value(forKey: "_id") as? String ?? ""
        self.name = dict.value(forKey: "name") as? String ?? ""
        self.celebrity = dict.value(forKey: "celebrity") as? Int ?? 0
        self.pickzonId = dict.value(forKey: "pickzonId") as? String ?? ""
        self.profilePic = dict.value(forKey: "profilePic") as? String ?? ""
        self.actualProfileImage = dict.value(forKey: "actualProfileImage") as? String ?? ""
        self.userId = dict.value(forKey: "userId") as? String ?? ""
        self.avatar = dict.value(forKey: "avatar") as? String ?? ""
        
        if profilePic.length > 0 {
            if profilePic.prefix(1) == "." {
                profilePic = String(profilePic.dropFirst(1))
            }
            
            if !profilePic.starts(with: "http"){
                profilePic = Constant.sharedinstance.ImgBaseURL + profilePic
            }
        }
        
        if actualProfileImage.length > 0 {
            if actualProfileImage.prefix(1) == "." {
                actualProfileImage = String(actualProfileImage.dropFirst(1))
            }
            
            if !actualProfileImage.starts(with: "http"){
                actualProfileImage = Constant.sharedinstance.ImgBaseURL + actualProfileImage
            }
        }
    }
}




struct UserModel {
    
    var fb_id:AnyObject?
    var user_info:AnyObject?
    var follow_Status : AnyObject?
    var total_heart:AnyObject?
    var total_fans:AnyObject?
    var total_following:AnyObject?
    var user_videos:AnyObject?
    var total_post:AnyObject?
    var user_post:AnyObject?
    var isBlock = 0
    var userType = 0
    var description = ""
    var webLink = ""
    var email = ""
    var mobile = ""
    var gender = ""
    var dob = ""
    var referalCode = ""
    var job = ""
    var location = ""
    var interest = ""
    var tiktokName = ""
    var fullName = ""
    var isToShowEmail = 0
    var isToSHowDob = 0
    var isToShowMob = 0
    var headline = ""
    var position = ""
    var showName = 1
    var password = ""
    var confirmPassword = ""
    var isEmailVerified = 0
    var isMobileVerified = 0

    init(dict:NSDictionary){
        
        self.fb_id = dict.value(forKey: "fb_id") as AnyObject
        self.user_info = dict.value(forKey: "user_info") as AnyObject
        self.follow_Status = dict.value(forKey: "follow_Status") as AnyObject
        self.total_heart = dict.value(forKey: "total_heart") as AnyObject
        self.total_fans = dict.value(forKey: "total_fans") as AnyObject
        self.total_following = dict.value(forKey: "total_following") as AnyObject
        self.user_videos = dict.value(forKey: "user_videos") as AnyObject
        self.total_post = dict.value(forKey: "total_post") as AnyObject
        self.user_post = dict.value(forKey: "user_post") as AnyObject
        self.isBlock = dict.value(forKey: "isBlock") as? Int ?? 0
        self.userType = dict.value(forKey: "usertype") as? Int ?? 0
        self.isToShowEmail = dict.value(forKey: "showEmail") as? Int ?? 0
        self.isToSHowDob = dict.value(forKey: "showDob") as? Int ?? 0
        self.showName = dict.value(forKey: "showName") as? Int ?? 1
        self.isToShowMob = dict.value(forKey: "showMobile") as? Int ?? 0


    }
}


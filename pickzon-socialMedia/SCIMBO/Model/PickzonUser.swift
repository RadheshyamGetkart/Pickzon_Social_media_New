//
//  UserClass.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 12/21/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import UIKit

struct PickzonUser{
    
    var actualProfileImage = ""
    var celebrity = 0
    var pickzonId = ""
    var coverImage = ""
    var description = ""
    var dob = ""
    var email = ""
    var name = ""
    var isFollow = 0
    var gender = ""
    var headline = ""
    var id = ""
    var interest = ""
    var isBlock = 0
    var jobProfile = ""
    var livesIn = ""
    var profilePic = ""
    var mutualFriend = [Dictionary<String,Any>]()
    var showDob = 0
    var showEmail = 0
    var showMobile = 0
    var suggestedUsers = [Dictionary<String,Any>]()
    var followerCount = ""
    var talentCategory = ""
    var followingCount = ""
    var postCount = ""
    var mobileNo = ""
    var usertype = 0
    var website = ""
    var requestCount = 0
   // var mutualFriendCount = "0"
    var isWallet = 0
    var showName = 0
    var isEmailVerified = 0
    var isMobileVerified = 0
    var isFollowBack = 0
    var giftingLevel = ""
    var angelsCount = "0"
    var avatar = ""
    var allGiftedCoins = 0
    var avatarSVGA = ""
    var isBoostedPost = 0
    
    init(respdict:NSDictionary){
        
        self.id = respdict["id"] as? String ?? ""
        self.website = respdict["website"] as? String ?? ""
        self.usertype = respdict["usertype"] as? Int ?? 0
        self.mobileNo = respdict["mobile"] as? String ?? ""
        self.actualProfileImage = respdict["actualProfileImage"] as? String ?? ""
        self.profilePic = respdict["profilePic"] as? String ?? ""
        self.pickzonId = respdict["pickzonId"] as? String ?? ""
        self.celebrity = respdict["celebrity"] as? Int ?? 0
        self.coverImage = respdict["coverImage"] as? String ?? ""
        self.description = respdict["description"] as? String ?? ""
        self.dob = respdict["dob"] as? String ?? ""
        self.email = respdict["email"] as? String ?? ""
        self.name = respdict["name"] as? String ?? ""
        self.gender = respdict["gender"] as? String ?? ""
        self.headline = respdict["headline"] as? String ?? ""
        self.interest = respdict["interest"] as? String ?? ""
        self.isBlock = respdict["isBlock"] as? Int ?? 0
        self.isWallet = respdict["isWallet"] as? Int ?? 0
        self.isEmailVerified = respdict["isEmailVerified"] as? Int ?? 0
        self.isMobileVerified = respdict["isMobileVerified"] as? Int ?? 0
        self.giftingLevel = respdict["giftingLevel"] as? String ?? ""
        self.angelsCount = respdict["angelsCount"] as? String ?? "0"
        self.requestCount = respdict["requestCount"] as? Int ?? 0
        self.avatar = respdict["avatar"] as? String ?? ""
        self.allGiftedCoins = respdict["allGiftedCoins"] as? Int ?? 0
        self.avatarSVGA = respdict["avatarSVGA"] as? String ?? ""
        self.isFollowBack = respdict["isFollowBack"] as? Int ?? 0
        self.isFollow = respdict["isFollow"] as? Int ?? 0
        self.jobProfile = respdict["jobProfile"] as? String ?? ""
        self.livesIn = respdict["livesIn"] as? String ?? ""
        self.interest = respdict["interest"] as? String ?? ""
        self.postCount = respdict["postCount"] as? String ?? ""
        self.followingCount = respdict["followingCount"] as? String ?? ""
        self.followerCount = respdict["followerCount"] as? String ?? ""
        self.talentCategory = respdict["talentCategory"] as? String ?? ""
        self.isBoostedPost = respdict["isBoostedPost"] as? Int ?? 0
      
        if let  suggestedUsers = respdict["suggestedUsers"] as?  Array<Dictionary<String,Any>>{
            self.suggestedUsers = suggestedUsers
        }

        self.showDob = respdict["showDob"] as? Int ?? 0
        self.showEmail = respdict["showEmail"] as? Int ?? 0
        self.showMobile = respdict["showMobile"] as? Int ?? 0
        self.showName = respdict["showName"] as? Int ?? 0
        
        if profilePic.prefix(1) == "." {
            profilePic =   "\(Themes.sharedInstance.getURL())\(String(profilePic.dropFirst(1)))"
        }
     
    }

}



struct FriendModal{
    
    var name = ""
    var profilePic = ""
    var msisdn = ""
    var id = ""
    var celebrity = 0
    var isSelected = false
    var actualProfileImage = ""
    var pickzonId = ""
    var mobile = ""
    var avatar = ""
    
    init(respDict:NSDictionary) {
        
        self.name = respDict["Name"] as? String ?? ""
        
        if let name = respDict["first_name"] as? String{
            
            self.name = name
        }
        self.msisdn = respDict["msisdn"] as? String ?? ""
        self.id = respDict["_id"] as? String ?? ""
        self.pickzonId = respDict["Tiktokname"] as? String ?? ""
        self.profilePic = respDict["ProfilePic"] as? String ?? ""
        self.celebrity = respDict["celebrity"] as? Int ?? 0
        self.actualProfileImage = respDict["actualProfileImage"] as? String ?? ""
        self.avatar = respDict["avatar"] as? String ?? ""
        
        if let name = respDict["name"] as? String{
            self.name = name
        }
        
        if let msisdn = respDict["msisdn"] as? String{
            
            self.mobile = msisdn
        }
        if let pickzonId = respDict["pickzonId"] as? String{
            
            self.pickzonId = pickzonId
        }
        
        if let userId =  respDict["id"] as? String{
                self.id = userId
        }
        
        if let profile_pic = respDict["profile_pic"] as? String{
            
            self.profilePic = profile_pic
        }

        if let profilePic = respDict["profilePic"] as? String{
            
            self.profilePic = profilePic
        }
        
        if profilePic.prefix(1) == "." {
            self.profilePic = String(profilePic.dropFirst(1))
            self.profilePic = Themes.sharedInstance.getURL() + self.profilePic
        }
    }
    
}


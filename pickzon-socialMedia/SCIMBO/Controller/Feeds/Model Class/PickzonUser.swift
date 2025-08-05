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
    var followStatus = 0
    var followStatusButton = ""
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
    var totalFans = ""
    var totalFollowing = ""
    var totalPost = ""
    var mobileNo = ""
    var usertype = 0
    var website = ""
    var isClip = 0
    var friendRequestCount = ""
    var mutualFriendCount = "0"
    
    init(respdict:NSDictionary){
        
        self.id = respdict["id"] as? String ?? ""
        self.website = respdict["website"] as? String ?? ""
        self.usertype = respdict["usertype"] as? Int ?? 0
        self.mobileNo = respdict["username"] as? String ?? ""
        self.totalPost = respdict["total_post"] as? String ?? ""
        self.totalFollowing = respdict["total_following"] as? String ?? ""
        self.totalFans = respdict["total_fans"] as? String ?? ""
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
        self.isClip = respdict["isClip"] as? Int ?? 0
        self.friendRequestCount = respdict["friendRequestCount"] as? String ?? ""
        
        if let  follow_Status = respdict["follow_Status"] as? NSDictionary {
            self.followStatus = follow_Status["follow"] as? Int ?? 0
            self.followStatusButton = follow_Status["follow_status_button"] as? String ?? ""
        }

        self.jobProfile = respdict["jobProfile"] as? String ?? ""
        self.livesIn = respdict["livesIn"] as? String ?? ""
        self.interest = respdict["interest"] as? String ?? ""
        
        if let  mutualFriend = respdict["mutualFriend"] as?  Array<Dictionary<String,Any>>{
            self.mutualFriend = mutualFriend
        }
        if let  suggestedUsers = respdict["suggestedUsers"] as?  Array<Dictionary<String,Any>>{
            self.suggestedUsers = suggestedUsers
        }

        self.showDob = respdict["showDob"] as? Int ?? 0
        self.showEmail = respdict["showEmail"] as? Int ?? 0
        self.showMobile = respdict["showMobile"] as? Int ?? 0
        
        
        if profilePic.prefix(1) == "." {
            profilePic =   "\(Themes.sharedInstance.getURL())\(String(profilePic.dropFirst(1)))"
        }

        self.mutualFriendCount =  respdict["mutualFriendCount"] as? String ?? "0"
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


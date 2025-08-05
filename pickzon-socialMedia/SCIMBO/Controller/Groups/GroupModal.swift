//
//  GroupModal.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 5/28/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit



struct GroupModal{
    
    var groupName = ""
    var aboutGroup = ""
    var category = ""
    var location = ""
    var groupId = ""
    var privacy = ""
    var groupImage = ""
    var groupBannerImage = ""
    var tagUserArray = [String]()
    var id = ""
    var images = ""
    var groupFollowerCount = 0
    var userId = ""
    var profile_pic = ""
    var groupMemberCount = "0"
    var commonFriendCount = "0"
    var followUser = [UserModal]()
    var subAdmin = [String]()
    var isLike = 0
    var status = 0
    var statusType = ""
    var website = ""
    var userName = ""
    var createdDate = ""
    var isBlock = 0
    var actualImages = ""
    var isVerified = 0
    
    init(respDict:NSDictionary) {
        
        self.groupName = respDict["name"] as? String ?? ""
        self.category = respDict["category"] as? String ?? ""
        self.aboutGroup = respDict["description"] as? String ?? ""
        self.id = respDict["id"] as? String ?? ""
        self.groupId = respDict["groupId"] as? String ?? ""
        self.userId = respDict["userId"] as? String ?? ""
        self.location = respDict["location"] as? String ?? ""
        self.groupImage = respDict["images"] as? String ?? ""
        self.groupFollowerCount = respDict["groupFollowerCount"] as? Int ?? 0
        self.privacy = "\(respDict["privacy"] as? Int ?? 0)"
        self.groupBannerImage = respDict["coverImages"] as? String ?? ""
        self.subAdmin = respDict["subAdmin"] as? Array ?? [String]()
        self.statusType = respDict["statusType"] as? String ?? ""
        self.status = respDict["status"] as? Int ?? 0
        self.website = respDict["website"] as? String ?? ""
        self.userName = respDict["userName"] as? String ?? ""
        self.createdDate = respDict["createdDate"] as? String ?? ""
        self.isBlock = respDict["isBlock"] as? Int ?? 0
        self.actualImages = respDict["actualImages"] as? String ?? ""

        self.profile_pic = respDict.value(forKey: "profile_pic") as? String ?? ""
        
        if let profilePic = respDict.value(forKey: "profilePic") as? String{
            self.profile_pic = profilePic
        }
      
        if self.profile_pic.length > 0  && !self.profile_pic.contains("http"){

        if self.profile_pic.prefix(1) == "." {
            self.profile_pic = String(profile_pic.dropFirst(1))
        }
            self.profile_pic = Themes.sharedInstance.getURL() + self.profile_pic

        }
        self.groupMemberCount = respDict["groupMemberCount"] as? String ?? "0"
        self.commonFriendCount = respDict["commonFriendCount"] as? String ?? "0"
      
        self.isLike = respDict["isLike"] as? Int ?? 0

        
        
        if let followUserArr = respDict["followUser"] as? NSArray{
            
            for userDict in followUserArr{
                self.followUser.append(UserModal(dict: userDict as? NSDictionary ?? NSDictionary()))
            }
        }
    }

  
}


struct GroupInvite{
    
    var userId = ""
    var userName = ""
    var profile_pic = ""
    var groupName = ""
    var groupId = ""
    var aboutGroup = ""
    var privacy = ""
    var followUser = [UserModal]()
    var groupFollowerCount = ""
    var groupImage = ""
    
    init(respDict:NSDictionary){
        
        self.userId = respDict.value(forKey: "userId") as? String ?? ""
        self.userName = respDict.value(forKey: "userName") as? String ?? ""
        self.profile_pic = respDict.value(forKey: "profilePic") as? String ?? ""
        self.groupName = respDict.value(forKey: "name") as? String ?? ""
        self.groupId = respDict.value(forKey: "groupId") as? String ?? ""
        self.aboutGroup = respDict.value(forKey: "description") as? String ?? ""

        if self.profile_pic.length > 0  && !self.profile_pic.contains("http"){

        if self.profile_pic.prefix(1) == "." {
            self.profile_pic = String(profile_pic.dropFirst(1))
        }
            self.profile_pic = Themes.sharedInstance.getURL() + self.profile_pic

        }
        
        if let followUserArr = respDict["followUser"] as? NSArray{
            
            for userDict in followUserArr{
                self.followUser.append(UserModal(dict: userDict as? NSDictionary ?? NSDictionary()))
            }
        }
        
        if let id = respDict.value(forKey: "id") as? String{
            self.groupId = id
        }
        
        self.groupFollowerCount = respDict["groupFollowerCount"] as? String ?? "0"
        self.privacy = "\(respDict["privacy"] as? Int ?? 0)"
        
        self.groupImage = respDict["images"] as? String ?? ""


    }
}


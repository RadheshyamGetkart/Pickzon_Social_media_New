//
//  FollowersModel.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/3/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import Foundation

struct Followers {
    
    var id:String = ""
    var isFollow = 0
    var avatar = ""
    var profilePic = ""
    var name = ""
    var pickzonId = ""
    var celebrity = 0
    var headline = ""
    var jobProfile = ""
    var isSelected = 0
    var isFollowBack = 0
        

    init(respDict:NSDictionary) {
        
        self.id = respDict["id"] as? String ?? ""
        self.name = respDict["name"] as? String ?? ""
        self.avatar = respDict["avatar"] as? String ?? ""
        self.pickzonId = respDict["pickzonId"] as? String ?? ""
        self.profilePic = respDict["profilePic"] as? String ?? ""
        self.celebrity = respDict["celebrity"] as? Int ?? 0
        self.headline = respDict["headline"] as? String ?? ""
        self.jobProfile = respDict["jobProfile"] as? String ?? ""
        self.isFollowBack = respDict["isFollowBack"] as? Int ?? 0
        self.isFollow = respDict["isFollow"] as? Int ?? 0
        
        if self.profilePic.prefix(1) == "." {
            self.profilePic = String(profilePic.dropFirst(1))
            self.profilePic = Themes.sharedInstance.getURL() + self.profilePic
        }
    }
    
}

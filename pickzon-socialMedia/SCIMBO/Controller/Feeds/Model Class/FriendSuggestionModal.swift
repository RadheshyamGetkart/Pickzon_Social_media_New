//
//  FrienSuggestionModal.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 9/14/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import UIKit



struct FriendSuggestionModal {
   
    var payload = [FriendUser]()
    
    init(respDict:NSDictionary) {
        
        if let mallArray = respDict["friendSuggestionData"] as? NSArray{
            for item in mallArray{
                self.payload.append(FriendUser(dict: (item as! NSDictionary)))
            }

        }
    }
    
    mutating func removeAtIndex(index:Int) {
        self.payload.remove(at: index)
    }
}


struct FriendUser {
    
    var id = ""
    var first_name = ""
    var profile_pic = ""
    var celebrity:Int64 = 0
    var status:Int64 = 0
    var statusType:String
    var jobProfile = ""
    var livesIn = ""
    var pickzonId = ""
    
    init(dict:NSDictionary) {
        
        id = dict["id"] as? String ?? ""
        first_name = dict["first_name"] as? String ?? ""
        profile_pic = dict["profile_pic"] as? String ?? ""
        pickzonId = dict["Tiktokname"] as? String ?? ""
        celebrity = dict["celebrity"] as? Int64 ?? 0
        status = dict["status"] as? Int64 ?? 0
        statusType = dict["statusType"] as? String ?? ""
       
        
        if let  jobProfile = dict["jobProfile"] as? String {
            self.jobProfile =  jobProfile
        }
        
        if let  livesIn = dict["livesIn"] as? String {
            self.livesIn =  livesIn
        }
        
        if let  pickzonId = dict["pickzonId"] as? String {
            self.pickzonId = pickzonId
        }
        
        
        if self.profile_pic.length > 0  && !self.profile_pic.contains("http"){
            if self.profile_pic.prefix(1) == "." {
                self.profile_pic = String(profile_pic.dropFirst(1))
            }
            self.profile_pic = Themes.sharedInstance.getURL() + self.profile_pic
        }
    }
}


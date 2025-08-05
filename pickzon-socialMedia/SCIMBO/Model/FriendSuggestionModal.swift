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
    
    init(arrFriendsSuggestion:Array<Dictionary<String,Any>>) {
        
        for item in arrFriendsSuggestion{
            self.payload.append(FriendUser(dict: (item as NSDictionary)))
        }
    }
    
    
    mutating func removeAtIndex(index:Int) {
        self.payload.remove(at: index)
    }
}


struct FriendUser {
    
    var id = ""
    var name = ""
    var profilePic = ""
    var celebrity:Int = 0
    var isFollow:Int = 0
    var jobProfile = ""
    var livesIn = ""
    var pickzonId = ""
    var avatar = ""
    
    init(dict:NSDictionary) {
        
        id = dict["id"] as? String ?? ""
        name = dict["name"] as? String ?? ""
        profilePic = dict["profilePic"] as? String ?? ""
        pickzonId = dict["pickzonId"] as? String ?? ""
        celebrity = dict["celebrity"] as? Int ?? 0
        isFollow = dict["isFollow"] as? Int ?? 0
        avatar = dict["avatar"] as? String ?? ""
        jobProfile = dict["jobProfile"] as? String ?? ""
        livesIn = dict["livesIn"] as? String ?? ""
        
        if self.profilePic.length > 0  && !self.profilePic.contains("http"){
            if self.profilePic.prefix(1) == "." {
                self.profilePic = String(profilePic.dropFirst(1))
            }
            self.profilePic = Themes.sharedInstance.getURL() + self.profilePic
        }
    }
}


struct ClipSuggestionModel {
   
    var payload = [WallPostModel]()
    
    init(arrWallPostModel:Array<WallPostModel>) {
        self.payload = arrWallPostModel
    }
}

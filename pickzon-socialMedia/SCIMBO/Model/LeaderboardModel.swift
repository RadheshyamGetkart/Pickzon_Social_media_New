//
//  LeaderboardModel.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 7/5/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import Foundation

struct LeaderboardModel{
    
    var profilePic = ""
    var pickzonId = ""
    var name = ""
    var celebrity = 0
    var topGifter = ""
    var userId = ""
    var totalCoins = 0
    var gifterUserId = ""
    var gifterImage = ""
    var gifterAvatar = ""
    var gifterPickzonId = ""
    var gifterCelebrity = 0
    var totalViews = ""
    var avatar = ""
    var avatarSVGA = ""
    
    init(respDict:Dictionary<String,Any>){
        
        self.profilePic = respDict["profilePic"]  as? String ?? ""
        self.pickzonId = respDict["pickzonId"]  as? String ?? ""
        self.name = respDict["name"]  as? String ?? ""
        self.celebrity = respDict["celebrity"]  as? Int ?? 0
        self.topGifter = respDict["topGifter"]  as? String ?? ""
        self.userId = respDict["userId"]  as? String ?? ""
        self.totalCoins = respDict["totalCoins"]  as? Int ?? 0
        self.totalViews = respDict["totalViews"]  as? String ?? ""
        self.avatar = respDict["avatar"]  as? String ?? ""
        self.avatarSVGA = respDict["avatarSVGA"]  as? String ?? ""
        if let gifterInfoDict = respDict["gifterInfo"]  as? Dictionary<String,Any>{
            self.gifterUserId = gifterInfoDict["id"]  as? String ?? ""
            self.gifterImage = gifterInfoDict["profilePic"]  as? String ?? ""
            self.gifterAvatar = gifterInfoDict["avatar"]  as? String ?? ""
            self.gifterPickzonId = gifterInfoDict["pickzonId"]  as? String ?? ""
            self.gifterCelebrity = gifterInfoDict["celebrity"]  as? Int ?? 0
        }
    }
}



 

struct GiftersInfo{
    
    var profilePic = ""
    var userId = ""
    var pickzonId = ""
    var celebrity = 0
    var avatar = ""
    var avatarSVGA = ""

    init(respDict:Dictionary<String,Any>){
        self.profilePic = respDict["profilePic"] as? String ?? ""
        self.userId = respDict["userId"] as? String ?? ""
        self.pickzonId = respDict["pickzonId"] as? String ?? ""
        self.celebrity = respDict["celebrity"]  as? Int ?? 0
        self.avatar = respDict["avatar"] as? String ?? ""
        self.avatarSVGA = respDict["avatarSVGA"] as? String ?? ""
    }

}


struct GiftLeaderboardModel{
    
    var profilePic = ""
    var pickzonId = ""
    var name = ""
    var userId = ""
    var gifterObj:GiftersInfo?
    var totalCoins = 0
    var celebrity = 0
    var avatar = ""
    var avatarSVGA = ""
    
    init(respDict:Dictionary<String,Any>){
        
        self.profilePic = respDict["profilePic"]  as? String ?? ""
        self.pickzonId = respDict["pickzonId"]  as? String ?? ""
        self.name = respDict["name"]  as? String ?? ""
        self.userId = respDict["userId"]  as? String ?? ""
        self.totalCoins = respDict["totalCoins"]  as? Int ?? 0
        self.celebrity = respDict["celebrity"]  as? Int ?? 0
        self.avatar = respDict["avatar"]  as? String ?? ""
        self.avatarSVGA = respDict["avatarSVGA"]  as? String ?? ""

        if let gifterDict = respDict["gifterInfo"]  as? Dictionary<String,Any>{
            
         //   for dict in gifterInfoArray{
                self.gifterObj = GiftersInfo(respDict: gifterDict)
           // }
        }
    }
}

struct TrendingHashTags {
    var title = ""
    var topViewCount = ""
    var type = 0
    var wallPostArray = [WallPostModel]()
    init(dict:NSDictionary){
        self.title = dict["title"] as? String ?? ""
        self.topViewCount = dict["topViewCount"] as? String ?? ""
        self.type = dict["type"] as? Int ?? 0
        for obj in (dict["data"] as? NSArray ?? []) {
            self.wallPostArray.append(WallPostModel(dict: obj as? NSDictionary ?? [:]))
        }
    }
}

struct  TrendingLeaderBoard{
    var index = 0
    var title = ""
    var arrLeaderboard = [LeaderboardModel]()
    var typeVal = 0

    init(dict:NSDictionary){
        self.title = dict["title"] as? String ?? ""
        self.index = dict["index"] as? Int ?? 0
         //type -"Pickzon star" -->1 || "PK Leaderboard" -->2 || "Go Live" --> 3
        self.typeVal = dict["type"] as? Int ?? 0
        let arrData = dict["data"] as? Array<Dictionary<String, Any>> ?? []
        for dict in arrData {
            self.arrLeaderboard.append(LeaderboardModel(respDict:dict))
        }
    }
}

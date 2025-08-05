//
//  BoostModel.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/13/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import Foundation



struct BoostPlans{
    
    var id = ""
    var coins = 0
    var description = ""
    var discount = 0
    var isRecommended = 0
    var views = 0
    
    init(respDict:Dictionary<String,Any>){
        self.id = respDict["id"] as? String ?? ""
        self.description = respDict["description"] as? String ?? ""
        self.coins = respDict["coins"] as? Int ?? 0
        self.discount = respDict["discount"] as? Int ?? 0
        self.isRecommended = respDict["isRecommended"] as? Int ?? 0
        self.views = respDict["views"] as? Int ?? 0
        
    }
    
}


struct BoostedPost{
    
    var id = ""
    var feedId = ""
    var profileActivity = 0
    var profileVisit = 0
    var thumbUrl = ""
    var coinsSpent = 0
    var boostDate = ""
    var likes = 0
    var comments = 0
    var shares = 0
    var saves = 0
    var followers = 0
    var postInteractions = 0
    var postReached = 0
    var status = 0   // 1 means show 0 means hide


    init(respDict:Dictionary<String,Any>){
        
        self.id = respDict["id"] as? String ?? ""
        self.feedId = respDict["feedId"] as? String ?? ""
        self.profileActivity = respDict["profileActivity"] as? Int ?? 0
        self.profileVisit = respDict["profileVisit"] as? Int ?? 0
        self.thumbUrl = respDict["thumbUrl"] as? String ?? ""
        self.coinsSpent = respDict["coinsSpent"] as? Int ?? 0
        self.boostDate = respDict["boostDate"] as? String ?? ""
        self.likes = respDict["likes"] as? Int ?? 0
        self.comments = respDict["comments"] as? Int ?? 0
        self.shares = respDict["shares"] as? Int ?? 0
        self.saves = respDict["saves"] as? Int ?? 0
        self.followers = respDict["followers"] as? Int ?? 0
        self.postInteractions = respDict["postInteractions"] as? Int ?? 0
        self.postReached = respDict["postReached"] as? Int ?? 0
        self.status = respDict["status"] as? Int ?? 0


    }
}

//
//  CoinModel.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/17/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

struct CoinModel {
    
    var amount = "0"
    var label = ""
    var icon = ""
    var id = 0
    var giftId = ""

    init(respDict:Dictionary<String,Any>) {
        self.amount = respDict["amount"] as? String ?? "0"
        self.label = respDict["label"] as? String ?? ""
        self.icon = respDict["icon"] as? String ?? ""
        self.giftId = respDict["giftId"] as? String ?? ""
        self.id = respDict["id"] as? Int ?? 0
    }
}


struct CoinOfferModel {
    
    var country = ""
    var currencySymbol = ""
    var coins = 0
    var oldCoins = 0
    var amount = 0
    var discount = 0
    var status = 0
    var _id = ""
    var currency = ""
    var coinOrderId = ""
    var productId = ""
    var isSelected = false
  

    init(respDict:Dictionary<String,Any>) {
        
        self._id = respDict["_id"] as? String ?? ""
        self.country = respDict["country"] as? String ?? ""
        self.currencySymbol = respDict["currencySymbol"] as? String ?? ""
        self.coins = respDict["coins"] as? Int ?? 0
        self.oldCoins = respDict["oldCoins"] as? Int ?? 0
        self.amount = respDict["amount"] as? Int ?? 0
        self.discount = respDict["discount"] as? Int ?? 0
        self.status = respDict["status"] as? Int ?? 0
        self.currency = respDict["currency"] as? String ?? ""
        self.productId = respDict["productId"] as? String ?? ""
    }
}



struct CoinTransactionModel {
    
    var _id = ""
    var createdAt = ""
    var coins = 0
    var title = ""
    var amount = 0
    var country = ""
    var currency = ""
    var currencySymbol = ""
    var discount = 0
    var status = 0
    var transactionId = ""
    
    init(respDict:Dictionary<String,Any>) {
        
        self._id = respDict["_id"] as? String ?? ""
        self.title = respDict["title"] as? String ?? ""
        self.createdAt = respDict["createdAt"] as? String ?? ""
        self.coins = respDict["coins"] as? Int ?? 0
        self.amount = respDict["amount"] as? Int ?? 0
        self.country = respDict["country"] as? String ?? ""
        self.currency = respDict["currency"] as? String ?? ""
        self.currencySymbol = respDict["currencySymbol"] as? String ?? ""
        self.discount = respDict["discount"] as? Int ?? 0
        self.status = respDict["status"] as? Int ?? 0   //
        if let transactionId = respDict["transactionId"] as? String{
            
            self.transactionId =  transactionId

        }else  if let transactionId = respDict["transactionId"] as? Int{
            self.transactionId =  "\(transactionId)"

        }
            //  self.transactionId =  "\(respDict["transactionId"] as? String ?? "")"
    }
}




struct CheerCoinModel {
    
    var _id = ""
    var createdAt = ""
    var coins = 0
    var profilePic = ""
    var userId = ""
    var feedId = ""
    var storyId = ""
    var pickzonId = ""
    var title = ""
    var coinsType = 0
    var exchangeCoins = 0
    var referenceId = 0
    var status = 0
    var coinsDollar = ""
    
    
    init(respDict:Dictionary<String,Any>) {
        
        self._id = respDict["_id"] as? String ?? ""
        self.title = respDict["title"] as? String ?? ""
        self.createdAt = respDict["createdAt"] as? String ?? ""
        self.coins = respDict["coins"] as? Int ?? 0
        self.storyId = respDict["storyId"] as? String ?? ""
        self.feedId = respDict["feedId"] as? String ?? ""
        self.coinsType = respDict["coinsType"] as? Int ?? 0
        self.exchangeCoins = respDict["exchangeCoins"] as? Int ?? 0
        self.referenceId = respDict["referenceId"] as? Int ?? 0
        self.status = respDict["status"] as? Int ?? 0
        self.coinsDollar = respDict["coinsDollar"] as? String ?? ""
        
        if let userInfo =  respDict["userInfo"] as? Dictionary<String, Any>{
            pickzonId = userInfo["pickzonId"] as? String ?? ""
            profilePic = userInfo["profilePic"] as? String ?? ""
            userId = userInfo["userId"] as? String ?? ""
        }
        
    }
}



struct ReferralCoinModel {
    
    var _id = ""
    var createdAt = ""
    var coins = 0
    var title = ""
   
    init(respDict:Dictionary<String,Any>) {
        
        self._id = respDict["_id"] as? String ?? ""
        self.title = respDict["title"] as? String ?? ""
        self.createdAt = respDict["createdAt"] as? String ?? ""
        self.coins = respDict["coins"] as? Int ?? 0
    }
}


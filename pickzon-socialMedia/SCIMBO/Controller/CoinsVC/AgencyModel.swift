//
//  AgencyModel.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 8/29/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import Foundation


struct AgencyDetailModel {
    
    var arrAgencyPayDetails:Array<PayDetailsModel> = Array()
    var paymentOptions = ""
    var id = ""
    var country = ""
    var pickzonId = ""
    var profilePic = ""
    var agencyName = ""
    var businessPhone = ""
    var avatar = ""
    
    init(respDict:NSDictionary) {
        let arr = respDict["agencyPayDetails"] as? Array<Dictionary<String,Any>> ?? []
        for dict in arr {
            self.arrAgencyPayDetails.append(PayDetailsModel(respDict: dict))
            if self.paymentOptions.length == 0 {
                self.paymentOptions = "\(dict["method"] as? String ?? "")"
            }else {
                self.paymentOptions = paymentOptions + ", \(dict["method"] as? String ?? "")"
            }
        }
        
        self.id = respDict["id"] as? String ?? ""
        self.country = respDict["country"] as? String ?? ""
        self.pickzonId = respDict["pickzonId"] as? String ?? ""
        self.profilePic = respDict["profilePic"] as? String ?? ""
        self.agencyName = respDict["agencyName"] as? String ?? ""
        self.businessPhone = respDict["businessPhone"] as? String ?? ""
        self.avatar = respDict["avatar"] as? String ?? ""
    }
    
    struct PayDetailsModel {
        var method = ""
        var referenceId = ""
        var icon = ""
        init(respDict:Dictionary<String,Any>) {
            self.method = respDict["method"] as? String ?? ""
            self.referenceId = respDict["referenceId"] as? String ?? ""
            self.icon = respDict["icon"] as? String ?? ""            
        }
    }
}





struct CoinDetail{
    var agencyId = ""
    var agencyName = ""
    var amount = 0
    var businessPhone = ""
    var coin = 0
    var currency = ""
    var currencySymbol = ""
    var message  = ""
    
    var mobileNo = ""
    var pickzonId = ""
    var profilePic = ""
    

    init(respDict:NSDictionary){
        
        self.agencyId = respDict["agencyId"] as? String ?? ""
        self.agencyName = respDict["agencyName"] as? String ?? ""
        self.amount = respDict["amount"] as? Int ?? 0
        self.businessPhone = respDict["businessPhone"] as? String ?? ""
        self.coin = respDict["coin"] as? Int ?? 0
        self.currency = respDict["currency"] as? String ?? ""
        self.currencySymbol = respDict["currencySymbol"] as? String ?? ""
        self.message = respDict["message"] as? String ?? ""
        self.mobileNo = respDict["mobileNo"] as? String ?? ""
        self.pickzonId = respDict["pickzonId"] as? String ?? ""
        self.profilePic = respDict["profilePic"] as? String ?? ""
        
    }

}

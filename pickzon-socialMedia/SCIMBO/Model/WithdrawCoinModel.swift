//
//  WithdrawCoinModel.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/21/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

struct WithdrawCoinModel {
    
    var panNumber:String
    var bankName:String
    var accountNo:String
    var acccountHolderName:String
    var ifscCode:String
    var withdrawalLimit:Int
    var isPancardSaved:Bool = true
    var isBankSaved:Bool = true
    var confirmAccountNo:String
    var availableGiftCoin = 0
    var accReferenceImage = ""


    init(respDict:Dictionary<String,Any>){
        self.bankName = respDict["bankName"] as? String ?? ""
        self.panNumber = respDict["panCard"] as? String ?? ""
        self.ifscCode = respDict["ifsc"] as? String ?? ""
        self.accountNo = respDict["accountNumber"] as? String ?? ""
        self.acccountHolderName = respDict["name"] as? String ?? ""
        self.withdrawalLimit = 0
        self.confirmAccountNo = respDict["accountNumber"] as? String ?? ""
        self.accReferenceImage = respDict["accReferenceImage"] as? String ?? ""
    }
}

//
//  DBUser.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 3/17/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import Foundation
import RealmSwift

class DBUser:Object{
    
    @Persisted(primaryKey: true) var userId:String?
    @Persisted var name:String = ""
    @Persisted var pickzonId:String = ""
    @Persisted var profilePic:String = ""
    @Persisted var actualProfilePic:String = ""
    @Persisted var jobProfile:String = ""
    @Persisted var organization:String = ""
    @Persisted var dob:String = ""
    @Persisted var emailId:String = ""
    @Persisted var gender:String = ""
    @Persisted var livesIn:String = ""
    @Persisted var mobileNo:String = ""
    @Persisted var usertype:Int = 0
    @Persisted var website:String = ""
    @Persisted var totalFans:String = ""
    @Persisted var totalFollowing:String = ""
    @Persisted var totalPost:String = ""
    @Persisted var celebrity:Int = 0
    @Persisted var coverImage:String = ""
    @Persisted var desc:String = ""
   
    //New keys added
    @Persisted var avatar:String = ""
    @Persisted var allGiftedCoins:Int = 0
    @Persisted var angelsCount:String = ""
    @Persisted var giftingLevel:String = ""
    
}


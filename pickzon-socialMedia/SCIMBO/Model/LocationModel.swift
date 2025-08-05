//
//  LocationModel.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 5/6/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import Foundation


struct LocationModal{
    
    var locationName = ""
    var city = ""
    var state = ""
    var streetAddress = ""
    var apartment = ""
    var postalCode = ""
    var country = ""
    var locationType = ""
    var long:CGFloat = 0.0
    var lat:CGFloat = 0.0
    var fullAddress = ""
    
    init(locationDict:NSDictionary){
        
        locationName = locationDict["locationName"] as? String  ?? ""
        city = locationDict["city"] as? String  ?? ""
        state = locationDict["state"] as? String  ?? ""
        streetAddress = locationDict["streetAddress"] as? String  ?? ""
        apartment = locationDict["apartment"] as? String  ?? ""
        postalCode = "\(locationDict["postalCode"] as? Int  ?? 0)"
        if postalCode == "0"{
            postalCode = ""
        }
        country = locationDict["country"] as? String  ?? ""
        long = locationDict["longitude"] as? CGFloat  ?? 0.0
        lat = locationDict["latitude"] as? CGFloat  ?? 0.0
    }
}



struct UserModal{
    
    var id = ""
    var profilePic = ""
    var username = ""
    var celebrity:Int = 0
    var name = ""
    var pickzonId = ""
    var actualProfileImage = ""
    var userId = ""
    var avatar = ""

    init(dict:NSDictionary){
        
        self.pickzonId = dict.value(forKey: "Tiktokname") as? String ?? ""
        self.name = dict.value(forKey: "first_name") as? String ?? ""
        self.id = dict.value(forKey: "id") as? String ?? ""
        self.userId = dict.value(forKey: "userId") as? String ?? ""
        self.avatar = dict.value(forKey: "avatar") as? String ?? ""
        
        name = dict.value(forKey: "name") as? String ?? ""
       
        if let pickzonId = dict.value(forKey: "pickzonId") as? String {
            self.pickzonId = pickzonId
        }
        actualProfileImage = dict.value(forKey: "actualProfileImage") as? String ?? ""

        self.profilePic = dict.value(forKey: "profile_pic") as? String ?? ""
       
        if let profilePic = dict.value(forKey: "profilePic") as? String {
            self.profilePic =  profilePic
        }

        if self.profilePic.prefix(1) == "."{
            self.profilePic = String(profilePic.dropFirst(1))
        }
        
        if !self.profilePic.contains("http")  && !self.profilePic.contains("https"){
            
            self.profilePic = Themes.sharedInstance.getURL() + self.profilePic
        }
        
        self.username = dict.value(forKey: "username") as? String ?? ""
        self.celebrity = dict.value(forKey: "celebrity") as? Int ?? 0
        
        if let userInfoDict = dict.value(forKey: "userInfo") as? Dictionary<String,Any>{

            self.pickzonId = userInfoDict["pickzonId"] as? String ?? ""
            self.name = userInfoDict["name"] as? String ?? ""
            self.id = userInfoDict["id"] as? String ?? ""
            self.profilePic = userInfoDict["profilePic"] as? String ?? ""
        }
    }
}

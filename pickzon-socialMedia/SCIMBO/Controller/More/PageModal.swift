//
//  PageModal.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 4/4/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import Foundation



struct PageModel{
  
    var id = ""
    var pageId = ""
    var pageName = ""
    var pageCategory = ""
    var aboutPage = ""
    var privacy = ""
    var tagUserArray = [String]()
    var image = ""
    var coverImages = ""
    var countFollower = ""
    var countLike = ""
    var userId = ""
    var pageFollowerCount = 0
    var followUser = [UserModal]()
    var websiteLink = ""
    var emailId = ""
    var statusType = ""
    var status = 0
    var isLike = 0
    var profilePic = ""
    var subAdmin = [String]()
    var description = ""
    var name = ""
    var createdDate = ""
    var isBlock = 0
    var actualImages = ""
    
    var tagLine = ""
    var companySize = ""
    var companyType = ""
    var phone = ""
    var yearFounded = ""
    var location = ""
    var mobileNo = ""
    var locationObj = LocationModal(locationDict: [:])
    
    var isVerified:Int = 0
    var rejectedReason = ""
    var phoneCode = ""
    var pickzonId = ""
    
    init(respDict:NSDictionary) {
        
        self.id = respDict["id"] as? String ?? ""
        self.pageId = respDict["pageId"] as? String ?? ""
        self.pageName = respDict["pageName"] as? String ?? ""
        self.privacy = "\(respDict["privacy"] as? Int ?? 0)"
        self.aboutPage = respDict["description"] as? String ?? ""
        self.image = respDict["images"] as? String ?? ""
        self.coverImages = respDict["coverImages"] as? String ?? ""
        self.pageCategory = respDict["category"] as? String ?? ""
        self.countFollower = respDict["countFollower"] as? String ?? ""
        self.countLike = respDict["countLike"] as? String ?? ""
        self.userId = respDict["userId"] as? String ?? ""
        self.pageFollowerCount = respDict["pageFollowerCount"] as? Int ?? 0
        self.statusType = respDict["statusType"] as? String ?? ""
        self.status = respDict["status"] as? Int ?? 0
        self.emailId = respDict["emailId"] as? String ?? ""
        self.websiteLink = respDict["websiteLink"] as? String ?? ""
        self.subAdmin = respDict["subAdmin"] as? Array ?? [String]()
        self.createdDate = respDict["createdDate"] as? String ?? ""
        self.isBlock = respDict["isBlock"] as? Int ?? 0
        self.actualImages = respDict["actualImages"] as? String ?? ""
        self.pickzonId = respDict["pagePickzonId"] as? String ?? ""
        if pageId.count > 0{
            self.id = pageId
        }else{
            self.pageId = id
        }
        
        if let verifyDict = respDict["verify"] as? NSDictionary{
            self.isVerified = verifyDict["status"] as? Int ?? 0
            self.rejectedReason = verifyDict["rejectedReason"] as? String ?? "" // 0 => Not Applied , 1 => verified,2 => Pending , 3 => rejected
        }
        
        if let verify = respDict["verify"] as? Int {
            self.isVerified = verify
        }
        
        self.name = respDict["name"] as? String ?? ""
        self.isLike = respDict["isLike"] as? Int ?? 0
        self.description = respDict["description"] as? String ?? ""
        self.profilePic = respDict.value(forKey: "profilePic") as? String ?? ""
        if self.profilePic.length > 0  && !self.profilePic.contains("http"){

        if self.profilePic.prefix(1) == "." {
            self.profilePic = String(profilePic.dropFirst(1))
        }
            self.profilePic = Themes.sharedInstance.getURL() + self.profilePic

        }
        if let followUserArr = respDict["followUser"] as? NSArray{
            
            for userDict in followUserArr{
                self.followUser.append(UserModal(dict: userDict as? NSDictionary ?? NSDictionary()))
            }
        }
        
        if let locationDict = respDict["location"] as? Dictionary<String,Any>{
            self.locationObj = LocationModal(locationDict: locationDict as NSDictionary)
           //self.location =  "\(locationObj.locationName),\(locationObj.city) \(locationObj.state) \(locationObj.apartment) \(locationObj.postalCode)"
        }
        
        self.companySize = respDict["companySize"] as? String ?? ""
        self.companyType = respDict["companyType"] as? String ?? ""
        self.emailId = respDict["emailId"] as? String ?? ""
        self.mobileNo = respDict["phone"] as? String ?? ""
        self.tagLine = respDict["title"] as? String ?? ""
        self.yearFounded = respDict["yearFounded"] as? String ?? ""
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

    init(dict:NSDictionary){
        
        self.pickzonId = dict.value(forKey: "Tiktokname") as? String ?? ""
        self.name = dict.value(forKey: "first_name") as? String ?? ""
        self.id = dict.value(forKey: "id") as? String ?? ""
        self.userId = dict.value(forKey: "userId") as? String ?? ""

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
    }
}

struct PageInvite{
    
    var userId = ""
    var userName = ""
    var profile_pic = ""
    var pageName = ""
    var pageId = ""
    var isVerified = 0
    
    init(respDict:NSDictionary){
        
        self.userId = respDict.value(forKey: "userId") as? String ?? ""
        self.userName = respDict.value(forKey: "userName") as? String ?? ""
        self.profile_pic = respDict.value(forKey: "profile_pic") as? String ?? ""
        if self.profile_pic.length == 0 {
            self.profile_pic = respDict.value(forKey: "profilePic") as? String ?? ""
        }
        self.pageName = respDict.value(forKey: "pageName") as? String ?? ""
        self.pageId = respDict.value(forKey: "pageId") as? String ?? ""
        if self.profile_pic.length > 0  && !self.profile_pic.contains("http"){

        if self.profile_pic.prefix(1) == "." {
            self.profile_pic = String(profile_pic.dropFirst(1))
        }
        self.profile_pic = Themes.sharedInstance.getURL() + self.profile_pic
        }
        if let verify = respDict["verify"] as? Int {
            self.isVerified = verify
        }
    }
}




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




//
//  FeedsModal.swift
//  SCIMBO
//
//  Created by Getkart on 19/07/21.
//  Copyright © 2021 GETKART. All rights reserved.
//

import UIKit

struct FeedsPost{
    
}




struct SharedWallData {
    
    var createdAt:Date = Date()
    var id:String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var payload:String = ""
    var feedTime:String = ""
    var place:String = ""
    var tagArray:Array<String> = Array<String>()
    var taggedPeople:String = ""
    var urlArray:Array<String> = Array<String>()
    var thumbUrlArray:Array<String> = Array<String>()
   
    var isFollowed = 1
    var totalLike:UInt = 0
    var totalShared:UInt = 0
    var viewCount:UInt = 0
    var totalComment: UInt = 0
    var urlDimensionArray:Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()
    var userInfo:UserInfo?
    var activities:NSDictionary = NSDictionary()
    var feeling:NSDictionary = NSDictionary()
    var postType:String = ""
    var isCoinUp = 0 // 1 for show & 0 for hide
    var soundInfo:SoundInfo?
    var isShare = 1
    var isDownload = 1
    var commentType = 0  // 0 for all & 1 for no one

    init(dict:NSDictionary){
       
        self.createdAt = postCreatedDateToDate(date: dict.value(forKey: "createdAt") as? String ?? "")
        
        
        self.feedTime = dict.value(forKey: "feedTime") as? String ?? ""
        self.isFollowed = dict.value(forKey: "isFollow") as? Int ?? 0

        self.totalLike = dict.value(forKey: "totalLike") as? UInt ?? 0
        self.totalShared = dict.value(forKey: "totalShared") as? UInt ?? 0
        self.viewCount = dict.value(forKey: "viewCount") as? UInt ?? 0
        self.totalComment = dict.value(forKey: "totalComment") as? UInt ?? 0
        
        self.id = dict.value(forKey: "id") as? String ?? ""
        self.latitude = dict.value(forKey: "latitude") as? Double ?? 0.0
        self.longitude = dict.value(forKey: "longitude") as? Double ?? 0.0
        self.payload = dict.value(forKey: "payload") as? String ?? ""
        self.place = dict.value(forKey: "place") as? String ?? ""
        self.tagArray = dict.value(forKey: "tag") as? Array<String> ?? []
        self.isCoinUp = dict.value(forKey: "isCoinUp") as? Int ?? 0
        self.isShare = dict.value(forKey: "isShare") as? Int ?? 1
        self.isDownload = dict.value(forKey: "isDownload") as? Int ?? 1
        
        //remove the tage array tag if tag already contains in the payload strin
        var tagCount = self.tagArray.count
        var index = 0
        while index < tagCount {
            
            let tag = self.tagArray[index]
            if self.payload.contains("@\(tag)") {
                self.tagArray.remove(at: index)
                tagCount = tagCount - 1
                index = index - 1
            }
            index = index + 1
        }
        
        self.taggedPeople = (tagArray.count>0 ? "@" : "") + tagArray.joined(separator: " @")

        /*
         var  isFirst = true
         for obj in self.tagArray {
            if self.taggedPeople.length == 0 || isFirst {
                self.taggedPeople = "@" + obj
                isFirst = false
            }else {
                self.taggedPeople = self.taggedPeople + " @" + obj
            }
        }*/
        
        
         if let soundInfo = dict.value(forKey: "soundInfo") as? NSDictionary {
             self.soundInfo = SoundInfo(dict:soundInfo)
         }
        
        self.postType = dict.value(forKey: "postType") as? String ?? ""
        self.urlArray = dict.value(forKey: "url") as? Array<String> ?? []
        self.thumbUrlArray = dict.value(forKey: "thumbUrl") as? Array<String> ?? []
        self.urlDimensionArray = dict.value(forKey: "dimension") as? Array<Dictionary<String, Any>> ?? []
        self.userInfo = UserInfo(dict: dict.value(forKey: "userInfo") as? NSDictionary ?? [:])
        self.activities = dict.value(forKey: "activities") as? NSDictionary ?? [:]
        self.feeling = dict.value(forKey: "feeling") as? NSDictionary ?? [:]
        
    }
    
    
    struct UserInfo:Codable {
        
        var pickzonId = ""
        var name = ""
        var id = ""
        var profilePic = ""
        var profileType = ""
        var celebrity:Int = 0
        var isStatus: Int = 0
        var isStatusSeen: Int = 0
        var headline = ""
        var jobProfile = ""
        var avatar = ""
        
        init(dict:NSDictionary){
            self.pickzonId = dict.value(forKey: "pickzonId") as? String ?? ""
            self.name = dict.value(forKey: "name") as? String ?? ""
            self.id = dict.value(forKey: "id") as? String ?? ""
            self.profilePic = dict.value(forKey: "profilePic") as? String ?? ""
            if self.profilePic.prefix(1) == "." {
                self.profilePic = String(profilePic.dropFirst(1))
                self.profilePic = Themes.sharedInstance.getURL() + self.profilePic
            }
           // self.profileType = dict.value(forKey: "profileType") as? String ?? ""
            self.celebrity = dict.value(forKey: "celebrity") as? Int ?? 0
            self.isStatus = dict.value(forKey: "isStatus") as? Int ?? 0
            self.isStatusSeen = dict.value(forKey: "isStatusSeen") as? Int ?? 0
            self.headline = dict.value(forKey: "headline") as? String ?? ""
            self.jobProfile = dict.value(forKey: "jobProfile") as? String ?? ""
            self.avatar = dict.value(forKey: "avatar") as? String ?? ""
        }
    }
}

//Modal class
struct WallPostModel {
    
    var activities:NSDictionary = NSDictionary()
    var commentUser:Array<NSDictionary> = Array<NSDictionary>()
    var createdAt:Date = Date()
    var feeling:NSDictionary = NSDictionary()
    var id:String = ""
    var isLike:Int16 = 0
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var totalLike:UInt = 0
    var totalShared:UInt = 0
    var viewCount:UInt = 0
    var totalComment: UInt = 0
    var isSeen:Int = 0
    var payload:String = ""
    var isSave:Int16 = 0
    var place:String = ""
    var postType:String = ""
    var tagArray:Array<String> = Array<String>()
    var taggedPeople:String = ""
    var isFollowed = 1
    var urlArray:Array<String> = Array<String>()
    var thumbUrlArray:Array<String> = Array<String>()
    var urlDimensionArray:Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()
    var userInfo:UserInfo?
    var sharedWallData:SharedWallData!
    var feedTime:String = ""
    var isExpanded = true
    var commentType = 0  // 0 for all & 1 for no one
    var isCoinUp = 0 //0 for hide & 1 for show
    var clnViewHeight = 0.0
    var soundInfo:SoundInfo?
    var isShare = 1
    var isDownload = 1
    var boost = 0
    /*
     boost: { type: Number }
      
                 0 default
                 1 pending boost post
                 2 approved boost post
                 3 rejected boost post
      
     If any post boost value is 1 or 2  - User can not edit that post even in the 24 hours of time period.
     */
    init(dict:NSDictionary){
      
        self.activities = dict.value(forKey: "activities") as? NSDictionary ?? [:]
        self.commentUser = dict.value(forKey: "commentUser") as? Array<NSDictionary> ?? []
        self.createdAt = postCreatedDateToDate(date: dict.value(forKey: "createdAt") as? String ?? "")
        self.feeling = dict.value(forKey: "feeling") as? NSDictionary ?? [:]
        self.id = dict.value(forKey: "id") as? String ?? ""
        self.commentType = dict.value(forKey: "commentType") as? Int ?? 0
        self.isCoinUp = dict.value(forKey: "isCoinUp") as? Int ?? 0
        self.isShare = dict.value(forKey: "isShare") as? Int ?? 1
        self.isDownload = dict.value(forKey: "isDownload") as? Int ?? 1
        self.boost = dict.value(forKey: "boost") as? Int ?? 0
        self.isLike = dict.value(forKey: "isLike") as? Int16 ?? 0
        self.latitude = dict.value(forKey: "latitude") as? Double ?? 0.0
        self.longitude = dict.value(forKey: "longitude") as? Double ?? 0.0
        self.totalLike = dict.value(forKey: "totalLike") as? UInt ?? 0
        self.totalComment = dict.value(forKey: "totalComment") as? UInt ?? 0
        self.totalShared = dict.value(forKey: "totalShared") as? UInt ?? 0
        self.isSave = dict.value(forKey: "isSave") as? Int16 ?? 0
        self.feedTime = dict.value(forKey: "feedTime") as? String ?? ""
        self.isFollowed = dict.value(forKey: "isFollow") as? Int ?? 0
        self.viewCount = dict.value(forKey: "viewCount") as? UInt ?? 0
        self.payload = dict.value(forKey: "payload") as? String ?? ""
        self.place = dict.value(forKey: "place") as? String ?? ""
        self.postType = dict.value(forKey: "postType") as? String ?? ""
        
        self.tagArray = dict.value(forKey: "tag") as? Array<String> ?? []
        //remove the tage array tag if tag already contains in the payload strin
        var tagCount = self.tagArray.count
        var index = 0
        while index < tagCount {
            
            let tag = self.tagArray[index]
            if self.payload.contains("@\(tag)") {
                self.tagArray.remove(at: index)
                tagCount = tagCount - 1
                index = index - 1
            }
            index = index + 1
        }
        
        self.taggedPeople = (tagArray.count>0 ? "@" : "") + tagArray.joined(separator: " @")
        self.urlArray = dict.value(forKey: "url") as? Array<String> ?? []
        self.thumbUrlArray = dict.value(forKey: "thumbUrl") as? Array<String> ?? []
        urlDimensionArray = dict.value(forKey: "dimension") as? Array<Dictionary<String, Any>> ?? []

        self.userInfo = UserInfo(dict: dict.value(forKey: "userInfo") as? NSDictionary ?? [:])
       
        if let soundInfo = dict.value(forKey: "soundInfo") as? NSDictionary {
            self.soundInfo = SoundInfo(dict:soundInfo)
        }
        
        if  (dict.value(forKey: "sharedWallData") as? NSDictionary ?? [:]).count > 0 {
        self.sharedWallData = SharedWallData(dict: dict.value(forKey: "sharedWallData") as? NSDictionary ?? [:])
        }
       
        if self.sharedWallData == nil {
            if self.urlArray.count > 0 {
                if self.urlArray.count == 1  && self.urlDimensionArray.count == 1{
                    let objDictDimension = self.urlDimensionArray[0]
                    let height = objDictDimension["height"] as? Int ?? 0
                    let width = objDictDimension["width"] as? Int ?? 0
                    
                    if width == 0 && height == 0 {
                        self.clnViewHeight = (AppDelegate.sharedInstance.window?.frame.width ?? 0.0) * 0.5
                        
                    }else if width > height {
                        let ratio =  CGFloat(width) / CGFloat(height)
                        self.clnViewHeight = (AppDelegate.sharedInstance.window?.frame.width ?? 0.0) / ratio
                    }else {
                        var ratio =  CGFloat(height) / CGFloat(width)
                        if ratio > 1.25 {
                            ratio = 1.25
                        }
                        self.clnViewHeight = (AppDelegate.sharedInstance.window?.frame.width ?? 0.0) * ratio
                    }
                }else{
                    self.clnViewHeight = (AppDelegate.sharedInstance.window?.frame.width ?? 0.0) * 1.0
                }
            }
        }else {
            if self.sharedWallData.urlArray.count > 0 {
                
                if self.sharedWallData.urlArray.count == 1  && self.sharedWallData.urlDimensionArray.count == 1{
                    let objDictDimension = self.sharedWallData.urlDimensionArray[0]
                    let height = objDictDimension["height"] as? Int ?? 0
                    let width = objDictDimension["width"] as? Int ?? 0
                    if width == 0 && height == 0 {
                        clnViewHeight = (AppDelegate.sharedInstance.window?.frame.width ?? 0.0) * 0.5
                    }else if width > height {
                        let ratio =  CGFloat(width) / CGFloat(height)
                        clnViewHeight = (AppDelegate.sharedInstance.window?.frame.width ?? 0.0) / ratio
                        
                    }else {
                        var ratio =  CGFloat(height) / CGFloat(width)
                        if ratio > 1.25 {
                            ratio = 1.25
                        }
                        self.clnViewHeight = (AppDelegate.sharedInstance.window?.frame.width ?? 0.0) * ratio
                    }
                    
                }else  {
                    self.clnViewHeight = (AppDelegate.sharedInstance.window?.frame.width ?? 0.0) * 1.0
                }
            }
        }
        
    }
    
    
    struct UserInfo:Codable {
        
        var pickzonId = ""
        var name = ""
        var id = ""
        var profilePic = ""
        var celebrity:Int = 0
        var headline = ""
        var jobProfile = ""
        var showName:Int = 1
        var avatar = ""
       
        
        init(dict:NSDictionary){
            
            self.pickzonId = dict.value(forKey: "pickzonId") as? String ?? ""
            self.name = dict.value(forKey: "name") as? String ?? ""
            self.id = dict.value(forKey: "id") as? String ?? ""
            self.profilePic = dict.value(forKey: "profilePic") as? String ?? ""
            if self.profilePic.length > 0  && !self.profilePic.contains("http"){
                if self.profilePic.prefix(1) == "." {
                    self.profilePic = String(profilePic.dropFirst(1))
                }
                self.profilePic = Themes.sharedInstance.getURL() + self.profilePic
            }else{
                
            }
            self.avatar = dict.value(forKey: "avatar") as? String ?? ""
            self.celebrity = dict.value(forKey: "celebrity") as? Int ?? 0
            self.headline = dict.value(forKey: "headline") as? String ?? ""
            self.jobProfile = dict.value(forKey: "jobProfile") as? String ?? ""
            self.showName = dict.value(forKey: "showName") as? Int ?? 1
        }
    }
}


struct SoundInfo {
    
    var id:String = ""
    var name:String = ""
    var audio:String = ""
    var thumb:String = ""
    var isOriginal:Int = 0
    var audioLocalURL:String = ""
    init() {
    }
    init(dict:NSDictionary){
        
        self.id = dict.value(forKey: "id") as? String ?? ""
        self.name = dict.value(forKey: "name") as? String ?? ""
        self.audio = dict.value(forKey: "audio") as? String ?? ""
        self.thumb = dict.value(forKey: "thumb") as? String ?? ""
        self.isOriginal = dict.value(forKey: "original") as? Int ?? 0
    }
}


//MARK: Notification Model
struct PostNotificationModal {
    
    var created = ""
    var id = ""
    var message = ""
    var userInfo:UserInfo?
    var type = ""
    var feedTime = ""
    var feedId = ""
    var clipId = ""
    var notificationType = 0
    var storyId = ""
    var isSelect = false
    
    init(respDict:NSDictionary) {
        
        self.message = respDict["message"] as? String ?? ""
        self.type = respDict["type"] as? String ?? ""
        self.id = respDict["id"] as? String ?? ""
        self.feedId = respDict["feedId"] as? String ?? ""
        if self.feedId.length == 0{
            self.feedId = self.id
        }
       
        self.clipId = respDict["clipId"] as? String ?? ""
        self.storyId = respDict["storyId"] as? String ?? ""
        self.feedTime = respDict["feedTime"] as? String ?? ""
        self.type = respDict["type"] as? String ?? ""
        self.notificationType = respDict["notificationType"] as? Int ?? 0
        self.userInfo = UserInfo(dict: respDict["userInfo"] as? NSDictionary ?? [:])
    }
    
    
    struct UserInfo {
     
        var pickzonId = ""
        var name = ""
        var profilePic = ""
        var userId = ""
        var celebrity = 0
        var actualProfileImage = ""
        var showName:Int = 1
        var avatar = ""
        init(dict:NSDictionary){
            
            self.actualProfileImage = dict.value(forKey: "actualProfileImage") as? String ?? ""
            self.pickzonId = dict.value(forKey: "pickzonId") as? String ?? ""
            self.name = dict.value(forKey: "name") as? String ?? ""
            self.userId = dict.value(forKey: "userId") as? String ?? ""
            self.profilePic = dict.value(forKey: "profilePic") as? String ?? ""
            self.pickzonId = dict.value(forKey: "pickzonId") as? String ?? ""
            self.celebrity = dict.value(forKey: "celebrity") as? Int ?? 0
            self.showName = dict.value(forKey: "showName") as? Int ?? 1
            self.avatar = dict.value(forKey: "avatar") as? String ?? ""

            if self.profilePic.length > 0  && !self.profilePic.contains("http"){
                if self.profilePic.prefix(1) == "." {
                    self.profilePic = String(profilePic.dropFirst(1))
                    self.profilePic = Themes.sharedInstance.getURL() + self.profilePic
                }
            }else{
            }
        }
    }
}


struct Users {
 
    var pickzonId = ""
    var name = ""
    var profilePic = ""
    var isFollow:Int = 0
    var id = ""
    var celebrity:Int = 0
    var isStoryLike = 0
    var avatar = ""
    
    init(dict:NSDictionary){
        self.celebrity = dict.value(forKey: "celebrity") as? Int ?? 0
        self.id = dict.value(forKey: "id") as? String ?? ""
        self.name = dict.value(forKey: "name") as? String ?? ""
        self.profilePic = dict.value(forKey: "profilePic") as? String ?? ""
        self.avatar = dict.value(forKey: "avatar") as? String ?? ""
        self.isFollow = dict.value(forKey: "isFollow") as? Int ?? 0
        self.pickzonId = dict.value(forKey: "pickzonId") as? String ?? ""
        self.isStoryLike = dict.value(forKey: "isLike") as? Int ?? 0

       
        if self.profilePic.length > 0  && !self.profilePic.contains("http"){
            if self.profilePic.prefix(1) == "." {
                self.profilePic = String(profilePic.dropFirst(1))
            }
            self.profilePic = Themes.sharedInstance.getURL() + self.profilePic
        }
    }
}



struct SuggestedUser{
    
    var pickzonId = ""
    var name = ""
    var profilePic = ""
    var id = ""
    var isFollow:Int = 0
    var celebrity:Int = 0
    var livesIn:String = ""
    var jobProfile:String = ""
    var headline:String = ""
    var mutualArray = [Users(dict: [:])]
    var avatar = ""
    
    init(dict:NSDictionary,isNew:Bool = false){
        
        self.id = dict.value(forKey: "id") as? String ?? ""
        self.isFollow = dict.value(forKey: "isFollow") as? Int ?? 0
        self.jobProfile = dict.value(forKey: "jobProfile") as? String ?? ""
        self.headline = dict.value(forKey: "headline") as? String ?? ""
        self.avatar = dict.value(forKey: "avatar") as? String ?? ""
        self.celebrity = dict.value(forKey: "celebrity") as? Int ?? 0
        self.pickzonId = dict.value(forKey: "pickzonId") as? String ?? ""
        self.name = dict.value(forKey: "name") as? String ?? ""
        self.profilePic = dict.value(forKey: "profilePic") as? String ?? ""
        self.livesIn = dict.value(forKey: "livesIn") as? String ?? ""
        
        if self.profilePic.length > 0  && !self.profilePic.contains("http"){
            if self.profilePic.prefix(1) == "." {
                self.profilePic = String(profilePic.dropFirst(1))
            }
            self.profilePic = Themes.sharedInstance.getURL() + self.profilePic
        }else{
        }
        
        if let mutualFriends =  dict.value(forKey: "mutualFriends") as? Array<Any>{
            for dict in mutualFriends{
                if let userDict = dict as? NSDictionary{
                    self.mutualArray.append(Users(dict: userDict))
                }
            }
        }
    }
}



func postCreatedDateToDate(date: String) -> Date{
    
    if date.length > 0 {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        
        let newDdate = dateFormatter.date(from: date)!
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter1.locale = .autoupdatingCurrent
        dateFormatter1.timeZone = NSTimeZone.local
        let dateString = dateFormatter1.string(from: newDdate)
        
        let convDate = dateFormatter1.date(from: dateString) ?? Date()
        
        return convDate
    }else {
        return Date()
    }
}


struct FeedBannerModel{
    
    var bannerArray = [BannerModel]()
    
    init(respDict:Dictionary<String, Any>){
        
        if  let payload =  respDict["payload"] as? Array<Dictionary<String,Any>> {
            
            for dict in payload{
                self.bannerArray.append(BannerModel(respDict: dict))
            }
        }
    }
}



struct BannerModel{
    
    var bannerLink = ""
    var id = ""
    var imageCdn = ""
    var title = ""
    var type = 0
    var isLeaderboard = 0

    init(respDict:Dictionary<String, Any>){
        
        self.id = respDict["id"] as? String ?? ""
        self.bannerLink = respDict["bannerLink"] as? String ?? ""
        self.imageCdn = respDict["imageCdn"] as? String ?? ""
        self.title = respDict["title"] as? String ?? ""
        self.type = respDict["type"] as? Int ?? 0
        self.isLeaderboard = respDict["isLeaderboard"] as? Int ?? 0
    }

}


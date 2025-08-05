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

struct WallStatus {
    
    var statusArray:Array<StoryStaus> = Array<StoryStaus>()
    var userInfo:UserInfo?
    
    init(responseDict:NSDictionary) {
        
        if let statusArray = responseDict["status"] as? NSArray {
            
            for statDict in statusArray {
                
                self.statusArray.append(StoryStaus(statusDict: statDict as? NSDictionary ?? [:]))
            }
        }
        
        self.userInfo = UserInfo(dict: responseDict["user_info"] as? NSDictionary ?? [:])
        }
    
     class StoryStaus {

        var createdAt = ""
        var statusId = ""
        var thumbnail = ""
        var durationTime:Float64? = 0.0
        var statusTime = ""
        var isSeen = 0
         var isLike = 0
        var media = ""
        var viewCount = 0
         var likeCount = 0
         var statusMessage = ""
         var seenUserInfoArray = [UserInfo]()
        
         init(statusDict:NSDictionary) {
             self.createdAt = statusDict["createdAt"] as? String ?? ""
             self.statusId = statusDict["statusId"] as? String ?? ""
             self.statusTime = statusDict["statusTime"] as? String ?? ""
             self.isSeen = statusDict["isSeen"] as? Int ?? 0
             self.isLike = statusDict["isLike"] as? Int ?? 0
             self.viewCount = statusDict["viewCount"] as? Int ?? 0
             self.likeCount = statusDict["likeCount"] as? Int ?? 0
             self.statusMessage = statusDict["statusMessage"] as? String ?? ""
             
             if let duration = statusDict["duration"] as? String {
                 
                 if duration.count > 0{
                     self.durationTime = Float64(duration)
                     
                 }else{
                     self.durationTime = 5.0
                     
                 }
             }
             
             self.thumbnail = statusDict.value(forKey: "thumbnail") as? String ?? ""
             
             if self.thumbnail.prefix(1) == "." {
                 self.thumbnail = String(thumbnail.dropFirst(1))
                 self.thumbnail = Themes.sharedInstance.getURL() + self.thumbnail
                 
                 //                let a =  URL(string: self.thumbnail )!
                 //                let asset = AVAsset(url: a)
                 //                let duration = asset.duration
                 //                self.durationTime = CMTimeGetSeconds(duration)
             }
             //            self.thumbnail = statusDict["thumbnail"] as? String ?? ""
             
             self.media = statusDict.value(forKey: "media") as? String ?? ""
             
             if self.media.length > 0  && !self.media.contains("http"){
                 
                 if self.media.prefix(1) == "." {
                     self.media = String(media.dropFirst(1))
                     self.media = Themes.sharedInstance.getURL() + self.media
                     
                     
                 }
             }
             
             
             if let seenUserInfo = statusDict.value(forKey: "seenUserInfo") as? NSArray{
                 for dict in seenUserInfo{
                     self.seenUserInfoArray.append(UserInfo(dict: dict as! NSDictionary))
                 }
             }
         }
          
    }
    
    struct UserInfo {
        
        var tiktokname = ""
        var first_name = ""
        var id = ""
        var profile_pic = ""
        var username = ""
        var celebrity:Int = 0
        
        
        init(dict:NSDictionary){
            self.tiktokname = dict.value(forKey: "Tiktokname") as? String ?? ""
            self.first_name = dict.value(forKey: "first_name") as? String ?? ""
            self.id = dict.value(forKey: "id") as? String ?? ""
            self.profile_pic = dict.value(forKey: "profile_pic") as? String ?? ""
            
            if let profilePic = dict.value(forKey: "profilePic") as? String{
                self.profile_pic = profilePic
            }
            
            if self.profile_pic.prefix(1) == "." {
                self.profile_pic = String(profile_pic.dropFirst(1))
                self.profile_pic = Themes.sharedInstance.getURL() + self.profile_pic
            }
            self.username = dict.value(forKey: "username") as? String ?? ""
            self.celebrity = dict.value(forKey: "celebrity") as? Int ?? 0
        }
        
    }
    
}

  


struct SharedWallData {
    
    var createdAt:AnyObject?
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
    var mediaArr:Array<String> = Array<String>()
    var s3UrlArray:Array<String> = Array<String>()
    var isFollowed = 1

    var commentCount = ""
    var likeCount = ""
    var shareCount = ""
    var isPage:Int16 = 0
    var isGroup:Int16 = 0

    var urlDimensionArray:Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()
    var userInfo:UserInfo?

    var activities:NSDictionary = NSDictionary()
    var feeling:NSDictionary = NSDictionary()
    var adminUser = ""
    var subAdminUser = [String]()
    var groupPrivacy = 0
    var postType:String = ""
    
    init(dict:NSDictionary){
       
        self.createdAt = dict.value(forKey: "createdAt") as AnyObject
        
        self.feedTime = dict.value(forKey: "feedTime") as? String ?? ""
        self.isFollowed = dict.value(forKey: "isFollow") as? Int ?? 0

        self.commentCount = dict.value(forKey: "commentCount") as? String ?? ""
        self.likeCount = dict.value(forKey: "likeCount") as? String ?? ""
        self.shareCount = dict.value(forKey: "shareCount") as? String ?? ""
        
        self.id = dict.value(forKey: "id") as? String ?? ""
        self.latitude = dict.value(forKey: "latitude") as? Double ?? 0.0
        self.longitude = dict.value(forKey: "longitude") as? Double ?? 0.0
        self.payload = dict.value(forKey: "payload") as? String ?? ""
        self.place = dict.value(forKey: "place") as? String ?? ""
        self.tagArray = dict.value(forKey: "tag") as? Array<String> ?? []

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
        
        self.postType = dict.value(forKey: "postType") as? String ?? ""
        self.urlArray = dict.value(forKey: "url") as? Array<String> ?? []
        self.thumbUrlArray = dict.value(forKey: "thumbUrl") as? Array<String> ?? []
        self.mediaArr = dict.value(forKey: "mediaArr") as? Array<String> ?? []
        self.s3UrlArray = dict.value(forKey: "s3url") as? Array<String> ?? []

        self.urlDimensionArray = dict.value(forKey: "dimension") as? Array<Dictionary<String, Any>> ?? []
        let dictUserinfo = dict.value(forKey: "user_info") as? NSDictionary ?? [:]
        self.userInfo = UserInfo(dict:dictUserinfo)
        self.activities = dict.value(forKey: "activities") as? NSDictionary ?? [:]
        self.feeling = dict.value(forKey: "feeling") as? NSDictionary ?? [:]
        self.isPage = dict.value(forKey: "isPage") as? Int16 ?? 0
        self.isGroup = dict.value(forKey: "isGroup") as? Int16 ?? 0
        
        self.subAdminUser = dict.value(forKey: "subAdminUser") as? Array<String> ?? []
        self.adminUser = dict.value(forKey: "adminUser") as? String ?? ""
        self.groupPrivacy = dict.value(forKey: "groupPrivacy") as? Int ?? 0

    }
    
    
    struct UserInfo:Codable {
        var tiktokname = ""
        var first_name = ""
        var id = ""
        var profile_pic = ""
        var username = ""
        var userProfileType = ""
        var celebrity:Int = 0
        var isStatus: Int = 0
        var isStatusSeen: Int = 0
        var fromId = ""
        var headline = ""
        var position = ""
        
        init(dict:NSDictionary){
            self.tiktokname = dict.value(forKey: "Tiktokname") as? String ?? ""
            self.first_name = dict.value(forKey: "first_name") as? String ?? ""
            self.id = dict.value(forKey: "id") as? String ?? ""
            self.profile_pic = dict.value(forKey: "profile_pic") as? String ?? ""
            if self.profile_pic.prefix(1) == "." {
                self.profile_pic = String(profile_pic.dropFirst(1))
                self.profile_pic = Themes.sharedInstance.getURL() + self.profile_pic
            }
            self.username = dict.value(forKey: "username") as? String ?? ""
            self.userProfileType = dict.value(forKey: "userProfileType") as? String ?? ""
            self.celebrity = dict.value(forKey: "celebrity") as? Int ?? 0
            self.isStatus = dict.value(forKey: "isStatus") as? Int ?? 0
            self.isStatusSeen = dict.value(forKey: "isStatusSeen") as? Int ?? 0
            self.fromId = dict.value(forKey: "fromId") as? String ?? ""
            self.headline = dict.value(forKey: "headline") as? String ?? ""
            self.position = dict.value(forKey: "jobProfile") as? String ?? ""
        }
        
    }
    
}

//Modal class
struct WallPostModel {
    
    var activities:NSDictionary = NSDictionary()
    var commentUser:Array<NSDictionary> = Array<NSDictionary>()
    var createdAt:AnyObject?
    var feeling:NSDictionary = NSDictionary()
    
    var postId:String = ""
    var id:String = ""
    var feedId = ""
    var isLike:Int16 = 0
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var totalLike:Int16 = 0
    var totalShared:Int16 = 0
    var isSeen:Int = 0
    
    var totalComment: Int16 = 0
    var payload:String = ""
    var isAd:Int16 = 0
    var redirectUrl = ""
    var adLabel = ""
    var isSave:Int16 = 0
    
    var place:String = ""
    var postType:String = ""
    var tagArray:Array<String> = Array<String>()
    var taggedPeople:String = ""
    var isFollowed = 1
    var urlArray:Array<String> = Array<String>()
    var thumbUrlArray:Array<String> = Array<String>()
    var mediaArr:Array<String> = Array<String>()
    
    var s3UrlArray:Array<String> = Array<String>()

    var commentCount = ""
    var likeCount = ""
    var shareCount = ""
    
    var urlDimensionArray:Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()
    var userInfo:UserInfo?
    var sharedWallData:SharedWallData!
    var feedTime:String = ""
    var strTxtComment = ""
    var isPage:Int16 = 0
    var isGroup:Int16 = 0
    var adminUser = ""
    var subAdminUser = [String]()
    var groupPrivacy = 0
    var viewCount = ""
    var mediaId = ""
    var isExpanded = true
    var commentType = 0  // 0 for all & 1 for no one
    
    init(dict:NSDictionary){
        self.activities = dict.value(forKey: "activities") as? NSDictionary ?? [:]
        self.commentUser = dict.value(forKey: "commentUser") as? Array<NSDictionary> ?? []
        self.createdAt = dict.value(forKey: "createdAt") as AnyObject
        self.feeling = dict.value(forKey: "feeling") as? NSDictionary ?? [:]
        self.adLabel = dict.value(forKey: "adLabel") as? String ?? ""
        self.isAd = dict.value(forKey: "isAd") as? Int16 ?? 0
        self.id = dict.value(forKey: "id") as? String ?? ""
        self.mediaId = dict.value(forKey: "mediaId") as? String ?? ""
        self.feedId = dict.value(forKey: "feedId") as? String ?? ""
        self.postId = dict.value(forKey: "postId") as? String ?? ""
        self.postId = self.postId.length > 0  ? self.postId : self.id
        self.commentType = dict.value(forKey: "commentType") as? Int ?? 0

        if feedId.count == 0{
            self.feedId =  self.id
        }
        
        if feedId.count == 0{
            self.feedId =  self.postId
        }
       // self.feedId = self.feedId.length > 0  ? self.feedId : self.id
        
        if feedId.count > 0{
            self.postId = feedId
            self.id = feedId
        }
        
        self.redirectUrl = dict.value(forKey: "redirectUrl") as? String ?? ""
        self.isLike = dict.value(forKey: "isLike") as? Int16 ?? 0
        self.latitude = dict.value(forKey: "latitude") as? Double ?? 0.0
        self.longitude = dict.value(forKey: "longitude") as? Double ?? 0.0
        self.totalLike = dict.value(forKey: "totalLike") as? Int16 ?? 0
        self.totalComment = dict.value(forKey: "totalComment") as? Int16 ?? 0
        self.totalShared = dict.value(forKey: "totalShared") as? Int16 ?? 0
        self.isSave = dict.value(forKey: "isSave") as? Int16 ?? 0
        self.feedTime = dict.value(forKey: "feedTime") as? String ?? ""
        self.isFollowed = dict.value(forKey: "isFollow") as? Int ?? 0
        self.commentCount = dict.value(forKey: "commentCount") as? String ?? ""
        self.likeCount = dict.value(forKey: "likeCount") as? String ?? ""
        self.shareCount = dict.value(forKey: "shareCount") as? String ?? ""
        self.viewCount =  dict.value(forKey: "viewCount") as? String ?? ""
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
        self.mediaArr = dict.value(forKey: "mediaArr") as? Array<String> ?? []
        
        self.s3UrlArray = dict.value(forKey: "s3url") as? Array<String> ?? []
        
        urlDimensionArray = dict.value(forKey: "dimension") as? Array<Dictionary<String, Any>> ?? []
        let dictUserinfo = dict.value(forKey: "user_info") as? NSDictionary ?? [:]
        self.userInfo = UserInfo(dict:dictUserinfo)
        
        if  (dict.value(forKey: "sharedWallData") as? NSDictionary ?? [:]).count > 0 {
        self.sharedWallData = SharedWallData(dict: dict.value(forKey: "sharedWallData") as? NSDictionary ?? [:])
        }
        self.isPage = dict.value(forKey: "isPage") as? Int16 ?? 0
        self.isGroup = dict.value(forKey: "isGroup") as? Int16 ?? 0
        
        self.subAdminUser = dict.value(forKey: "subAdminUser") as? Array<String> ?? []
        self.adminUser = dict.value(forKey: "adminUser") as? String ?? ""
        self.groupPrivacy = dict.value(forKey: "groupPrivacy") as? Int ?? 0
        
    }
    
    struct UserInfo:Codable {
        var tiktokname = ""
        var first_name = ""
        var id = ""
        var profile_pic = ""
        var username = ""
        var userProfileType = ""
        var celebrity:Int = 0
        var isStatus: Int = 0
        var isStatusSeen: Int = 0
        var fromId = ""
        var headline = ""
        var position = ""

        init(dict:NSDictionary){
            self.tiktokname = dict.value(forKey: "Tiktokname") as? String ?? ""
            self.first_name = dict.value(forKey: "first_name") as? String ?? ""
            self.id = dict.value(forKey: "id") as? String ?? ""
            self.profile_pic = dict.value(forKey: "profile_pic") as? String ?? ""
            if self.profile_pic.length > 0  && !self.profile_pic.contains("http"){
                if self.profile_pic.prefix(1) == "." {
                    self.profile_pic = String(profile_pic.dropFirst(1))
                }
                self.profile_pic = Themes.sharedInstance.getURL() + self.profile_pic
            }else{
                
            }
            self.username = dict.value(forKey: "username") as? String ?? ""
            self.userProfileType = dict.value(forKey: "userProfileType") as? String ?? ""
            self.celebrity = dict.value(forKey: "celebrity") as? Int ?? 0
            self.isStatus = dict.value(forKey: "isStatus") as? Int ?? 0
            self.isStatusSeen = dict.value(forKey: "isStatusSeen") as? Int ?? 0
            self.fromId = dict.value(forKey: "fromId") as? String ?? ""
            self.headline = dict.value(forKey: "headline") as? String ?? ""
            self.position = dict.value(forKey: "jobProfile") as? String ?? ""
        }
        
    }
    
}

//MARK: Notification Model
struct PostNotificationModal {
    
    var created = ""
    var id = ""
    var message = ""
    var userInfo:UserInfo?
    var type = ""
    var mallId = ""
    var feedTime = ""
    var feedId = ""
    var clipId = ""
    var pageId = ""
    var groupId = ""
    var isGroup = 0
    var isPage = 0
    var notificationType = 0
    
    var isSelect = false
    
    init(respDict:NSDictionary) {
        
        self.message = respDict["message"] as? String ?? ""
        self.type = respDict["type"] as? String ?? ""
        self.id = respDict["id"] as? String ?? ""
        self.feedId = respDict["feedId"] as? String ?? ""
        if self.feedId.length == 0{
            self.feedId = self.id
        }
        self.feedTime = respDict["feedTime"] as? String ?? ""
        self.pageId = respDict["pageId"] as? String ?? ""
        self.groupId = respDict["groupId"] as? String ?? ""
        self.type = respDict["type"] as? String ?? ""
        self.mallId = respDict["mallId"] as? String ?? ""
        self.isGroup = respDict["isGroup"] as? Int ?? 0
        self.isPage = respDict["isPage"] as? Int ?? 0
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

        init(dict:NSDictionary){
            
            self.actualProfileImage = dict.value(forKey: "actualProfileImage") as? String ?? ""
            self.pickzonId = dict.value(forKey: "pickzonId") as? String ?? ""
            self.name = dict.value(forKey: "name") as? String ?? ""
            self.userId = dict.value(forKey: "userId") as? String ?? ""
            self.profilePic = dict.value(forKey: "profilePic") as? String ?? ""
            self.pickzonId = dict.value(forKey: "pickzonId") as? String ?? ""
            self.celebrity = dict.value(forKey: "celebrity") as? Int ?? 0
            
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
 
    var tiktokname = ""
    var first_name = ""
    var profile_pic = ""
    var username = ""
    var statusType = ""
    var status:Int = 0
    var id = ""
    var celebrity:Int = 0
    var isPage = 0
    var isGroup = 0
    var isStoryLike = 0

    init(dict:NSDictionary){
        self.celebrity = dict.value(forKey: "celebrity") as? Int ?? 0
        self.id = dict.value(forKey: "id") as? String ?? ""
        self.first_name = dict.value(forKey: "name") as? String ?? ""
        self.profile_pic = dict.value(forKey: "profilePic") as? String ?? ""
        
        self.username = dict.value(forKey: "username") as? String ?? ""
        self.status = dict.value(forKey: "status") as? Int ?? 0
        self.statusType = dict.value(forKey: "statusType") as? String ?? ""
        self.tiktokname = dict.value(forKey: "tiktokName") as? String ?? ""
        
        if let pickzonId = dict.value(forKey: "pickzonId") as? String {
            self.tiktokname = pickzonId
        }
        
         if let name = dict.value(forKey: "Name") as? String {
             self.first_name = name
         }
       
        if let profilePic = dict.value(forKey: "ProfilePic") as? String {
            self.profile_pic = profilePic
        }
        
        self.isPage = dict.value(forKey: "isPage") as? Int ?? 0
        self.isGroup = dict.value(forKey: "isPage") as? Int ?? 0
        self.isStoryLike = dict.value(forKey: "isLike") as? Int ?? 0

        if self.profile_pic.length > 0  && !self.profile_pic.contains("http"){
            if self.profile_pic.prefix(1) == "." {
                self.profile_pic = String(profile_pic.dropFirst(1))
            }
            self.profile_pic = Themes.sharedInstance.getURL() + self.profile_pic
        }else{
        }
    }
}

struct SuggestedUser{
    
    var tiktokname = ""
    var name = ""
    var profile_pic = ""
    var id = ""
    var statusType = ""
    var status:Int = 0
    var celebrity:Int = 0
    var mobileNumber:String = ""
    
    var livesIn:String = ""
    var jobProfile:String = ""
    var mutualArray = [Users(dict: [:])]
    
    init(dict:NSDictionary,isNew:Bool = false){
        
        if isNew {
            
            self.tiktokname = dict.value(forKey: "tiktokName") as? String ?? ""
            self.name = dict.value(forKey: "name") as? String ?? ""
            self.profile_pic = dict.value(forKey: "profilePic") as? String ?? ""
            self.id = dict.value(forKey: "userId") as? String ?? ""
            self.statusType = dict.value(forKey: "statusType") as? String ?? ""
            self.status = dict.value(forKey: "status") as? Int ?? 0
            self.mobileNumber = dict.value(forKey: "mobileNumber") as? String ?? ""
            if self.profile_pic.length > 0  && !self.profile_pic.contains("http"){
                if self.profile_pic.prefix(1) == "." {
                    self.profile_pic = String(profile_pic.dropFirst(1))
                }
                self.profile_pic = Themes.sharedInstance.getURL() + self.profile_pic
            }else{
            }
            if let userId = dict.value(forKey: "id") as? String{
                self.id = userId
            }

            
            self.celebrity = dict.value(forKey: "celebrity") as? Int ?? 0
            
        }else{
            self.tiktokname = dict.value(forKey: "Tiktokname") as? String ?? ""
            self.name = dict.value(forKey: "first_name") as? String ?? ""
            self.profile_pic = dict.value(forKey: "profile_pic") as? String ?? ""
            self.id = dict.value(forKey: "id") as? String ?? ""
            self.statusType = dict.value(forKey: "statusType") as? String ?? ""
            self.status = dict.value(forKey: "status") as? Int ?? 0
            
            if self.profile_pic.length > 0  && !self.profile_pic.contains("http"){
                if self.profile_pic.prefix(1) == "." {
                    self.profile_pic = String(profile_pic.dropFirst(1))
                }
                self.profile_pic = Themes.sharedInstance.getURL() + self.profile_pic
            }else{
            }
            
            self.celebrity = dict.value(forKey: "celebrity") as? Int ?? 0
        }
        
        if let jobProfile =  dict.value(forKey: "jobProfile") as? String{
            self.jobProfile = jobProfile
        }
        
        if let livesIn =  dict.value(forKey: "livesIn") as? String{
            self.livesIn = livesIn
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


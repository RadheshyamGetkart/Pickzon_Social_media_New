//
//  StoryModal.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 5/30/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit


struct StoryUploadModel{
    
    var mediaUrl:URL
    var musicTitle:String = ""
    var musicId:String = ""
    var musicUrl:String = ""
    var musicThumbUrl:String = ""
    var statusMessage:String = ""
    var tagStory:Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()
    var originalUrl = ""
    
    init(mediaUrl:URL,musicTitle:String,musicId:String,musicUrl:String,musicThumbUrl:String,statusMessage:String,tagStory:Array<Dictionary<String, Any>>){
        
        self.mediaUrl = mediaUrl
        self.musicTitle = musicTitle
        self.musicId = musicId
        self.musicUrl = musicUrl
        self.musicThumbUrl = musicThumbUrl
        self.statusMessage = statusMessage
        self.tagStory = tagStory
    }
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
        self.userInfo = UserInfo(dict: responseDict["userInfo"] as? NSDictionary ?? [:])
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
        var taggedStoryStatus = 0
        var taggedUserPickzonId = [String]()
        var taggedUserId = [String]()
        
        var soundId = ""
        var soundThumbUrl = ""
        var soundTitle = ""
        var soundUrl = ""
        
        
        init(statusDict:NSDictionary) {
           
            self.createdAt = statusDict["createdAt"] as? String ?? ""
            self.statusId = statusDict["statusId"] as? String ?? ""
            self.statusTime = statusDict["statusTime"] as? String ?? ""
            self.isSeen = statusDict["isSeen"] as? Int ?? 0
            self.isLike = statusDict["isLike"] as? Int ?? 0
            self.viewCount = statusDict["viewCount"] as? Int ?? 0
            self.likeCount = statusDict["likeCount"] as? Int ?? 0
            self.statusMessage = statusDict["statusMessage"] as? String ?? ""
            self.taggedStoryStatus = statusDict["taggedStoryStatus"] as? Int ?? 0
            if let tagUserInfoArray = statusDict["tagUserInfo"] as? Array<Dictionary<String,Any>> {
                
                for userDict in tagUserInfoArray{
                    self.taggedUserId.append(userDict["id"] as? String ?? "")
                    self.taggedUserPickzonId.append(userDict["tiktokName"] as? String ?? "")
                    
                }
            }
            
            
            if let soundInfoDict = statusDict["soundInfo"] as? Dictionary<String,Any> {
                
                self.soundId = soundInfoDict["soundId"] as? String ?? ""
                self.soundThumbUrl = soundInfoDict["soundThumbUrl"] as? String ?? ""
                self.soundTitle = soundInfoDict["soundTitle"] as? String ?? ""
                self.soundUrl = soundInfoDict["soundUrl"] as? String ?? ""
            }
            
            
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
                
                //   let a =  URL(string: self.thumbnail )!
                //   let asset = AVAsset(url: a)
                //   let duration = asset.duration
                //   self.durationTime = CMTimeGetSeconds(duration)
            }
            //  self.thumbnail = statusDict["thumbnail"] as? String ?? ""
            
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
        
        var pickzonId = ""
        var name = ""
        var id = ""
        var profilePic = ""
        var celebrity:Int = 0
        var isFollowBack = 0
        var avatar = ""

        init(dict:NSDictionary){
           
            self.pickzonId = dict.value(forKey: "pickzonId") as? String ?? ""
            self.name = dict.value(forKey: "name") as? String ?? ""
            self.id = dict.value(forKey: "id") as? String ?? ""
            self.profilePic = dict.value(forKey: "profilePic") as? String ?? ""
            self.avatar = dict.value(forKey: "avatar") as? String ?? ""
            self.celebrity = dict.value(forKey: "celebrity") as? Int ?? 0
            self.isFollowBack = dict.value(forKey: "isFollowBack") as? Int ?? 0
           
            if self.profilePic.prefix(1) == "." {
                self.profilePic = String(profilePic.dropFirst(1))
                self.profilePic = Themes.sharedInstance.getURL() + self.profilePic
            }
        }
    }
}

  

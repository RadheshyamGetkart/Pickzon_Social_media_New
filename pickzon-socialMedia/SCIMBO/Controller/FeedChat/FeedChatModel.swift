//
//  FeedChatModel.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 11/29/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import UIKit


struct FeedChatModel:Codable{
    
    var _id = ""
    var createdAt = ""
    var createdAtFCM = ""
    var fcrId = ""
    var lastMessage = ""
    var messageStatus = 1
    var status = 0
    var timeStamp = 0
    var unreadCount = 0
    var userInfo:ChatUser?
    var requestedUser = 0
    var blockStatus = 0
    var type = 0
    
    init(respDict:NSDictionary){
        
        _id = respDict["_id"] as? String ?? ""
        createdAt = respDict["createdAt"] as? String ?? ""
        createdAtFCM = respDict["createdAtFCM"] as? String ?? ""
        fcrId = respDict["fcrId"] as? String ?? ""
        lastMessage = respDict["lastMessage"] as? String ?? ""
        messageStatus = respDict["messageStatus"] as? Int ?? 1
        status = respDict["status"] as? Int ?? 0
        timeStamp = respDict["timeStamp"] as? Int ?? 0
        unreadCount = respDict["unreadCount"] as? Int ?? 0
        requestedUser = respDict["requestedUser"] as? Int ?? 0
        blockStatus = respDict["blockStatus"] as? Int ?? 0
        type = respDict["type"] as? Int ?? 0
        lastMessage = lastMessage.replacingOccurrences(of: "\"", with: "")

        if let userInfoDict = respDict["userInfo"] as? NSDictionary{
            userInfo = ChatUser(userDict: userInfoDict)
        }
    }
}


struct ChatUser:Codable{
    
    var actualProfileImage = ""
    var celebrity = 0
    var name = ""
    var onlineOfflineStatus = 0
    var onlineOfflineTime = 0
    var pickzonId = ""
    var profilePic = ""
    var userId = ""
    var avatar = ""

    init(userDict:NSDictionary){
        actualProfileImage = userDict["actualProfileImage"] as? String ?? ""
        celebrity = userDict["celebrity"] as? Int ?? 0
        name = userDict["name"] as? String ?? ""
        onlineOfflineStatus = userDict["onlineOfflineStatus"] as? Int ?? 0
        onlineOfflineTime = userDict["onlineOfflineTime"] as? Int ?? 0
        pickzonId = userDict["pickzonId"] as? String ?? ""
        profilePic = userDict["profilePic"] as? String ?? ""
        userId = userDict["userId"] as? String ?? ""
        avatar = userDict["avatar"] as? String ?? ""

    }
}

struct ChatHIstory:Codable{
    
    var _id = ""
    var createdAt = ""
    var messageForward = 0
    var fcrId = ""
    var payload = ""
    var receiverId = ""
    var status = 0
    var timeStamp = 0
    var senderId = ""
    var type = 0
    var messageStatus = 1
    var contactObj = ContactInfo(respDict: [:])
    var locationObj = LocationInfo(respDict: [:])
    var replyObj = ReplyInfo(respDict: [:])
    var url = ""
    var thumbUrl = ""
    var messageDocId = ""
    var reply = ""
    var duration = ""
    
    var storyId = ""
    var storyPayload = ""
    var storyThumb = ""

    
    init(respDict:NSDictionary){
        
        _id = respDict["_id"] as? String ?? ""
        createdAt = respDict["createdAt"] as? String ?? ""
        messageForward = respDict["messageForward"] as? Int ?? 0
        fcrId = respDict["fcrId"] as? String ?? ""
        payload = respDict["payload"] as? String ?? ""
        senderId = respDict["senderId"] as? String ?? ""
        status = respDict["status"] as? Int ?? 0
        timeStamp = respDict["timeStamp"] as? Int ?? 0
        messageStatus = respDict["messageStatus"] as? Int ?? 1
        type = respDict["type"] as? Int ?? 0
        receiverId = respDict["receiverId"] as? String ?? ""
        messageDocId = respDict["messageDocId"] as? String ?? ""
        reply = respDict["reply"] as? String ?? ""
        
        if let media = respDict["media"] as? Array<Any>{
            
            if let mediaDict = media.first as? NSDictionary{
                url = mediaDict["url"] as? String ?? ""
                thumbUrl = mediaDict["thumbUrl"] as? String ?? ""
                duration = mediaDict["duration"] as? String ?? ""
            }
        }
        
        if let payloadDict = respDict["contactDetails"] as? NSDictionary{
            contactObj = ContactInfo(respDict: payloadDict)
        }
        
        if let payloadDict = respDict["location"] as? NSDictionary{
            
            locationObj = LocationInfo(respDict: payloadDict)
        }
        
        if let replyDetails = respDict["replyDetails"] as? NSDictionary{
            
            replyObj = ReplyInfo(respDict: replyDetails)
            
        }
        
        if let storyData = respDict["storyData"] as? NSDictionary{
            //type = 7
            self.storyId = storyData["storyId"] as? String ?? ""
            self.storyPayload = storyData["statusMessage"] as? String ?? ""
            self.storyThumb = storyData["thumbnail"] as? String ?? ""
        }
    }
}
    
    class ReplyInfo:Codable{
        
        //var media = [String]
        var payload = ""
        var type = 0
        var contactObj = ContactInfo(respDict: [:])
        var locationObj = LocationInfo(respDict: [:])
        var url = ""
        var thumbUrl = ""
        var fromId = ""
        var fromName = ""
        var duration = ""
        
        init(respDict:NSDictionary){
            
            payload = respDict["payload"] as? String ?? ""
            type = respDict["type"] as? Int ?? 0
            fromId = respDict["userId"] as? String ?? ""
            fromName = respDict["name"] as? String ?? ""

            if let media = respDict["media"] as? Array<Any>{
                
                if let mediaDict = media.first as? NSDictionary{
                    url = mediaDict["url"] as? String ?? ""
                    thumbUrl = mediaDict["thumbUrl"] as? String ?? ""
                    duration = mediaDict["duration"] as? String ?? ""
                }
            }
            
            if let payloadDict = respDict["contactDetails"] as? NSDictionary{
                contactObj = ContactInfo(respDict: payloadDict)
            }
            
            if let payloadDict = respDict["location"] as? NSDictionary{
                locationObj = LocationInfo(respDict: payloadDict)
            }
        }
    }
    
    struct LocationInfo:Codable{
        
        var description = ""
        var image = ""
        var link = ""
        var title = ""
        var latitude = ""
        var longitude = ""

        init(respDict:NSDictionary){
            
            description = respDict["description"] as? String ?? ""
            image = respDict["image"] as? String ?? ""
            link = respDict["link"] as? String ?? ""
            title = respDict["title"] as? String ?? ""
            latitude = respDict["latitude"] as? String ?? ""
            longitude = respDict["longitude"] as? String ?? ""
        }
    }
    
    struct ContactInfo:Codable{
        
        var mobileNumber = ""
        var name = ""
        init(respDict:NSDictionary){
            
            mobileNumber = respDict["mobileNumber"] as? String ?? ""
            name = respDict["name"] as? String ?? ""

        }
    }

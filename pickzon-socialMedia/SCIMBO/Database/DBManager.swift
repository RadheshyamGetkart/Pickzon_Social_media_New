//
//  DBManager.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 8/27/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import Foundation
import RealmSwift

class DBManager {
    
    static let shared = DBManager()
    
    private init() {
        
    }
    
    static func openRealm() -> Realm? {
        return try? Realm()
    }
    
    
    public  func clearDB() {
        guard let realm = DBManager.openRealm() else {
            return
        }
        try? realm.write {
            
            realm.deleteAll()
        }
    }
    
    
    //MARK: Save User Detail
    
    func insertOrUpdateUSerDetail(userId:String,userObj:PickzonUser){
        
        guard let realm = DBManager.openRealm() else { return }
        
        try? realm.write{
            
            if let existingUser =  realm.object(ofType: DBUser.self, forPrimaryKey: userId) {
                
                existingUser.name = userObj.name
                existingUser.emailId = userObj.email
                existingUser.pickzonId = userObj.pickzonId
                existingUser.desc = userObj.description
                existingUser.dob = userObj.dob
                existingUser.organization = userObj.headline
                existingUser.gender = userObj.gender
                existingUser.jobProfile = userObj.jobProfile
                existingUser.livesIn = userObj.livesIn
                existingUser.totalFans = userObj.followerCount
                existingUser.totalFollowing = userObj.followingCount
                existingUser.totalPost = userObj.postCount
                existingUser.mobileNo = userObj.mobileNo
                existingUser.usertype = userObj.usertype
                existingUser.website = userObj.website
                existingUser.coverImage = userObj.coverImage
                existingUser.actualProfilePic = userObj.actualProfileImage
                existingUser.profilePic = userObj.profilePic
                existingUser.celebrity = userObj.celebrity
                
                existingUser.avatar = userObj.avatar
                existingUser.angelsCount = userObj.angelsCount
                existingUser.allGiftedCoins = userObj.allGiftedCoins
                existingUser.giftingLevel = userObj.giftingLevel

            }else if realm.object(ofType: DBUser.self, forPrimaryKey: userId) == nil {
                
                let newUser = DBUser()
                newUser.userId = userId
                newUser.name = userObj.name
                newUser.emailId = userObj.email
                newUser.pickzonId = userObj.pickzonId
                newUser.desc = userObj.description
                newUser.dob = userObj.dob
                newUser.organization = userObj.headline
                newUser.gender = userObj.gender
                newUser.jobProfile = userObj.jobProfile
                newUser.livesIn = userObj.livesIn
                newUser.totalFans = userObj.followerCount
                newUser.totalFollowing = userObj.followingCount
                newUser.totalPost = userObj.postCount
                newUser.mobileNo = userObj.mobileNo
                newUser.usertype = userObj.usertype
                newUser.website = userObj.website
                newUser.coverImage = userObj.coverImage
                newUser.actualProfilePic = userObj.actualProfileImage
                newUser.profilePic = userObj.profilePic
                newUser.celebrity = userObj.celebrity
                
                newUser.avatar = userObj.avatar
                newUser.angelsCount = userObj.angelsCount
                newUser.allGiftedCoins = userObj.allGiftedCoins
                newUser.giftingLevel = userObj.giftingLevel

                realm.add(newUser)
                
            }
        }
    }
    
    
    func deleteChatList(fcrId:String){
        
        guard  let realm = DBManager.openRealm() else { return }
      
        if let msgObj = realm.object(ofType: ChatDetail.self, forPrimaryKey: fcrId ){
            if msgObj.isInvalidated == false{
                realm.beginWrite()
                realm.delete(msgObj.messageArray)
                realm.delete(msgObj)
                try? realm.commitWrite()
                
            }
        }
        realm.refresh()
        
        if let chatObj = realm.object(ofType: FeedChat.self, forPrimaryKey: fcrId ){
            
            if chatObj.isInvalidated == false {
                
                if let userObj = realm.object(ofType: LastMessageUserInfo.self, forPrimaryKey: chatObj.chatUserId){
                    if userObj.isInvalidated == false{
                        realm.beginWrite()
                        realm.delete(userObj)
                        try? realm.commitWrite()
                    }
                }
                realm.beginWrite()
                realm.delete(chatObj)
                try? realm.commitWrite()
                
            }
            realm.refresh()
        }
    }
    
    func insertChatList(chatArray:[FeedChatModel],isInitial:Bool){
        
        guard  let realm = DBManager.openRealm() else { return }
        
        try? realm.write {
            
            if isInitial == true{
                for obj in realm.objects(FeedChat.self) {
                    
                    if let userObj = realm.object(ofType: LastMessageUserInfo.self, forPrimaryKey: obj.chatUserId ){
                        realm.delete(userObj)
                    }
                    realm.delete(obj)
                }
                
            }
            
            for chatObj in chatArray {
                
                if realm.object(ofType: LastMessageUserInfo.self, forPrimaryKey: chatObj.userInfo?.userId ?? "") == nil {
                    
                    let userObj = LastMessageUserInfo()
                    userObj.actualProfileImage = chatObj.userInfo?.actualProfileImage ?? ""
                    userObj.name = chatObj.userInfo?.name ?? ""
                    userObj.onlineOfflineStatus = Int64(chatObj.userInfo?.onlineOfflineStatus ?? 0)
                    userObj.onlineOfflineTime = Int64(chatObj.userInfo?.onlineOfflineTime ?? 0)
                    userObj.pickzonId = chatObj.userInfo?.pickzonId ?? ""
                    userObj.profilePic = chatObj.userInfo?.profilePic ?? ""
                    userObj.userId = chatObj.userInfo?.userId ?? ""
                    userObj.celebrity = Int64(chatObj.userInfo?.celebrity ?? 0)
                    realm.add(userObj)
                }
                
                
                if realm.object(ofType: FeedChat.self, forPrimaryKey: chatObj.fcrId) == nil {
                    
                    let chat = FeedChat()
                    chat.fcrId = chatObj.fcrId
                    chat.createdAt = chatObj.createdAt
                    chat.createdAtFCM = chatObj.createdAtFCM
                    chat.blockStatus = chatObj.blockStatus
                    chat.unreadcount = chatObj.unreadCount
                    chat.lastMessage = chatObj.lastMessage
                    chat.requestedUser = Int64(chatObj.requestedUser)
                    chat.messageStatus = chatObj.messageStatus
                    chat.timeStamp = Int64(chatObj.timeStamp)
                    chat.chatUserId = chatObj.userInfo?.userId ?? ""
                    chat.userObj = realm.object(ofType: LastMessageUserInfo.self, forPrimaryKey: chatObj.userInfo?.userId ?? "")
                    chat.type = chatObj.type
                    
                    realm.add(chat)
                    
                }else{
                    
                    if  let chat = realm.object(ofType: FeedChat.self, forPrimaryKey: chatObj.fcrId){
                        
                        chat.fcrId = chatObj.fcrId
                        chat.createdAt = chatObj.createdAt
                        chat.createdAtFCM = chatObj.createdAtFCM
                        chat.blockStatus = chatObj.blockStatus
                        chat.unreadcount = chatObj.unreadCount
                        chat.lastMessage = chatObj.lastMessage
                        chat.requestedUser = Int64(chatObj.requestedUser)
                        chat.messageStatus = chatObj.messageStatus
                        chat.timeStamp = Int64(chatObj.timeStamp)
                        chat.chatUserId = chatObj.userInfo?.userId ?? ""
                        chat.type = chatObj.type
                        chat.userObj?.actualProfileImage = chatObj.userInfo?.actualProfileImage ?? ""
                        chat.userObj?.name = chatObj.userInfo?.name ?? ""
                        chat.userObj?.onlineOfflineStatus = Int64(chatObj.userInfo?.onlineOfflineStatus ?? 0)
                        chat.userObj?.onlineOfflineTime = Int64(chatObj.userInfo?.onlineOfflineTime ?? 0)
                        chat.userObj?.pickzonId = chatObj.userInfo?.pickzonId ?? ""
                        chat.userObj?.profilePic = chatObj.userInfo?.profilePic ?? ""
                        chat.userObj?.userId = chatObj.userInfo?.userId ?? ""
                        chat.userObj?.celebrity = Int64(chatObj.userInfo?.celebrity ?? 0)
                        
                    }
                }
            }
        }
    }
    
    
    
    func insertChatDetail(chatArray:[ChatHIstory],fcrId:String,isInitial:Bool){
        
        guard  let realm = DBManager.openRealm() else { return }
        
        if isInitial == true{
            if let userObj = realm.object(ofType: ChatDetail.self, forPrimaryKey: fcrId ){
                realm.beginWrite()
                realm.delete(userObj.messageArray)
                realm.delete(userObj)
                try? realm.commitWrite()
            }
            realm.refresh()
        }
        
        let messageArray = List<Message>()
        
        for chatObj in chatArray {
            
            if realm.object(ofType: ChatDetail.self, forPrimaryKey: chatObj.fcrId ) == nil {
                
                let messageObj = Message()
                messageObj.fcrId = chatObj.fcrId
                messageObj.msgId = chatObj._id
                messageObj.createdAt = chatObj.createdAt
                messageObj.messageForward = chatObj.messageForward
                messageObj.payload = chatObj.payload
                messageObj.receiverId = chatObj.receiverId
                messageObj.status = chatObj.status
                messageObj.timeStamp = chatObj.timeStamp
                messageObj.type = chatObj.type
                messageObj.senderId = chatObj.senderId
                messageObj.messageStatus = chatObj.messageStatus
                messageObj.url = chatObj.url
                messageObj.thumbUrl = chatObj.thumbUrl
                messageObj.messageDocId = chatObj.messageDocId
                messageObj.reply = chatObj.reply
                
                if chatObj.type == 1 || chatObj.type == 6 {
                    messageObj.url = chatObj.url
                    messageObj.thumbUrl = chatObj.thumbUrl
                    messageObj.mediaDuration = chatObj.duration
                    
                }else  if chatObj.type == 3 {
                    
                    messageObj.contactName = chatObj.contactObj.name
                    messageObj.contactMobileNo = chatObj.contactObj.mobileNumber
                    
                }else  if chatObj.type == 4 {
                    
                    messageObj.locationLat = chatObj.locationObj.latitude
                    messageObj.locationLong = chatObj.locationObj.longitude
                    messageObj.locationDesc = chatObj.locationObj.description
                    messageObj.locationLink = chatObj.locationObj.link
                    messageObj.locationTitle = chatObj.locationObj.title
                    messageObj.locationImage = chatObj.locationObj.image
                }
                
                if chatObj.reply.length > 0 {
                    
                    messageObj.replyFromId = chatObj.replyObj.fromId
                    messageObj.replyFromName = chatObj.replyObj.fromName
                    messageObj.replyType = chatObj.replyObj.type
                    messageObj.replyPayload = chatObj.replyObj.payload
                    
                    if chatObj.replyObj.type == 1 || chatObj.replyObj.type == 6 {
                        messageObj.replyUrl = chatObj.replyObj.url
                        messageObj.replyThumb = chatObj.replyObj.thumbUrl
                        messageObj.replyMediaDuration = chatObj.replyObj.duration
                    }else  if chatObj.replyObj.type == 3 {
                        
                        messageObj.replyContactName = chatObj.replyObj.contactObj.name
                        messageObj.replyContactMobileNo = chatObj.replyObj.contactObj.mobileNumber
                        
                    }else  if chatObj.replyObj.type == 4 {
                        
                        messageObj.replyLocationLat = chatObj.replyObj.locationObj.latitude
                        messageObj.replyLocationLong = chatObj.replyObj.locationObj.longitude
                        messageObj.replyLocationDesc = chatObj.replyObj.locationObj.description
                        messageObj.replyLocationLink = chatObj.replyObj.locationObj.link
                        messageObj.replyLocationTitle = chatObj.replyObj.locationObj.title
                        messageObj.replyLocationImage = chatObj.replyObj.locationObj.image
                    }
                }
                realm.beginWrite()
                messageArray.append(messageObj)
                try? realm.commitWrite()
                
            }else{
                
                if  let chat = realm.object(ofType: ChatDetail.self, forPrimaryKey: chatObj.fcrId){
                    
                    let messageObj = Message()
                    messageObj.fcrId = chatObj.fcrId
                    messageObj.msgId = chatObj._id
                    messageObj.createdAt = chatObj.createdAt
                    messageObj.messageForward = chatObj.messageForward
                    messageObj.payload = chatObj.payload
                    messageObj.receiverId = chatObj.receiverId
                    messageObj.status = chatObj.status
                    messageObj.timeStamp = chatObj.timeStamp
                    messageObj.type = chatObj.type
                    messageObj.senderId = chatObj.senderId
                    messageObj.messageStatus = chatObj.messageStatus
                    messageObj.url = chatObj.url
                    messageObj.thumbUrl = chatObj.thumbUrl
                    messageObj.messageDocId = chatObj.messageDocId
                    messageObj.reply = chatObj.reply
                    
                    if chatObj.type == 1 || chatObj.type == 6 {
                        messageObj.url = chatObj.url
                        messageObj.thumbUrl = chatObj.thumbUrl
                        messageObj.mediaDuration = chatObj.duration
                        
                    }else  if chatObj.type == 3 {
                        
                        messageObj.contactName = chatObj.contactObj.name
                        messageObj.contactMobileNo = chatObj.contactObj.mobileNumber
                        
                    }else  if chatObj.type == 4 {
                        
                        messageObj.locationLat = chatObj.locationObj.latitude
                        messageObj.locationLong = chatObj.locationObj.longitude
                        messageObj.locationDesc = chatObj.locationObj.description
                        messageObj.locationLink = chatObj.locationObj.link
                        messageObj.locationTitle = chatObj.locationObj.title
                        messageObj.locationImage = chatObj.locationObj.image
                    }
                    
                    if chatObj.reply.length > 0 {
                        
                        messageObj.replyFromId = chatObj.replyObj.fromId
                        messageObj.replyFromName = chatObj.replyObj.fromName
                        messageObj.replyType = chatObj.replyObj.type
                        messageObj.replyPayload = chatObj.replyObj.payload
                        
                        if chatObj.replyObj.type == 1 || chatObj.replyObj.type == 6 {
                            messageObj.replyUrl = chatObj.replyObj.url
                            messageObj.replyThumb = chatObj.replyObj.thumbUrl
                            messageObj.replyMediaDuration  = chatObj.replyObj.duration
                            
                        }else  if chatObj.replyObj.type == 3 {
                            
                            messageObj.replyContactName = chatObj.replyObj.contactObj.name
                            messageObj.replyContactMobileNo = chatObj.replyObj.contactObj.mobileNumber
                            
                        }else  if chatObj.replyObj.type == 4 {
                            
                            messageObj.replyLocationLat = chatObj.replyObj.locationObj.latitude
                            messageObj.replyLocationLong = chatObj.replyObj.locationObj.longitude
                            messageObj.replyLocationDesc = chatObj.replyObj.locationObj.description
                            messageObj.replyLocationLink = chatObj.replyObj.locationObj.link
                            messageObj.replyLocationTitle = chatObj.replyObj.locationObj.title
                            messageObj.replyLocationImage = chatObj.replyObj.locationObj.image
                        }
                    }
                    realm.beginWrite()
                    chat.messageArray.append(messageObj)
                    try? realm.commitWrite()
                    
                }
            }
        }
        
        if messageArray.count > 0{
            realm.beginWrite()
            let chat = ChatDetail()
            chat.fcrId = fcrId
            chat.messageArray = messageArray
            realm.add(chat)
            try? realm.commitWrite()
        }
    }
}

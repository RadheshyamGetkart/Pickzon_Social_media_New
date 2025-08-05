//
//  FeedChatList.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 8/27/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import Foundation
import RealmSwift


//MARK: New Chat

class FeedChat:Object,Identifiable{
    
    @Persisted(primaryKey: true) var fcrId: String?
    @Persisted var createdAt: String = ""
    @Persisted var createdAtFCM: String = ""
    @Persisted var lastMessage: String = ""
    @Persisted var blockStatus: Int = 0
    @Persisted var unreadcount: Int = 0
    @Persisted var messageStatus: Int = 0
    @Persisted var timeStamp: Int64 = 0
    @Persisted var type: Int = 0
    @Persisted var status: Int = 0
    @Persisted var requestedUser: Int64 = 0
    @Persisted var userObj:LastMessageUserInfo?
    @Persisted var chatUserId: String = ""
}


class LastMessageUserInfo:Object{
    
    @Persisted(primaryKey: true) var userId: String?
    @Persisted var celebrity:Int64 = 0
    @Persisted var onlineOfflineStatus:Int64 = 0
    @Persisted var actualProfileImage:String = ""
    @Persisted var name:String = ""
    @Persisted var onlineOfflineTime:Int64 = 0
    @Persisted var pickzonId:String = ""
    @Persisted var profilePic:String = ""
}


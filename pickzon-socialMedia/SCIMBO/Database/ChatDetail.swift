//
//  ChatDetail.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 2/27/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import Foundation
import RealmSwift




class ChatDetail: Object {
    @Persisted(primaryKey: true) var fcrId: String?
    @Persisted var messageArray:List<Message>
}
    
    

class Message:EmbeddedObject{

    @Persisted var msgId: String = ""
    @Persisted var createdAt: String = ""
    @Persisted var messageForward: Int = 0
    @Persisted var fcrId: String = ""
    @Persisted var payload: String = ""
    @Persisted var receiverId: String = ""
    @Persisted var status: Int = 0
    @Persisted var timeStamp: Int = 0
    @Persisted var type: Int = 0
    @Persisted var senderId: String = ""
    @Persisted var messageStatus: Int = 0
    @Persisted var url: String = ""
    @Persisted var thumbUrl: String = ""
    @Persisted var messageDocId: String = ""
    @Persisted var reply: String = ""
    @Persisted var mediaDuration: String = ""

    @Persisted var locationImage: String = ""
    @Persisted var locationLink: String = ""
    @Persisted var locationTitle: String = ""
    @Persisted var locationDesc: String = ""
    @Persisted var locationLat: String = ""
    @Persisted var locationLong: String = ""
    
    @Persisted var contactMobileNo: String = ""
    @Persisted var contactName: String = ""
    
    //Reply
    @Persisted var replyThumb: String = ""
    @Persisted var replyUrl: String = ""
    @Persisted var replyType: Int = 0
    @Persisted var replyPayload: String = ""
    @Persisted var replyFromId: String = ""
    @Persisted var replyFromName: String = ""
    @Persisted var replyMessageId: String = ""
    @Persisted var replyMediaDuration: String = ""

    @Persisted var replyContactMobileNo: String = ""
    @Persisted var replyContactName: String = ""
    
    @Persisted var replyLocationTitle: String = ""
    @Persisted var replyLocationImage: String = ""
    @Persisted var replyLocationLink: String = ""
    @Persisted var replyLocationDesc: String = ""
    @Persisted var replyLocationLat: String = ""
    @Persisted var replyLocationLong: String = ""
}





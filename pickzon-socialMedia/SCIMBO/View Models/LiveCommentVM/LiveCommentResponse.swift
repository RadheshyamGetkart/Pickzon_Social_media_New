//
//  LiveCommentResponse.swift
//  SCIMBO
//
//  Created by Sachtech on 23/10/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import Foundation

//struct LiveCommentResponse: JsonDeserilizer {
//    
//    var errNum: Int = 0
//    var message: String = ""
//    var comment: LiveComment = LiveComment()
//    var comments: [LiveComment] = []
//    
//    mutating func deserilize(values: Dictionary<String, Any>?) {
//        errNum = values?["err"] as? Int ?? 0
//        message = values?["msg"] as? String ?? ""
//        
//        if let detail = values?["result"] as? NSDictionary{
//            comment.deserilize(values: detail as? Dictionary<String, Any>)
//        }
//        
//        if let commentList = values?["result"] as? NSArray{
//            for comment in commentList{
//                var item = LiveComment.init()
//                item.deserilize(values: comment as? Dictionary<String,Any>)
//                comments.append(item)
//            }
//        }
//    }
//}

struct LiveComment {
    
    var roomId: String = ""
    var userId: String = ""
    var message: String = ""
    var profilePic: String = ""
    var pickzonId: String = ""
    var name: String = ""
    var celebrity: Int = 0
    var type = 0
    var avatar: String = ""
    var giftingLevel = ""
    var gifterLevel = 0
    
    init(respDict:Dictionary<String, Any>?){
        
        roomId = respDict?["roomId"] as? String ?? ""
        userId = respDict?["userId"] as? String ?? ""
        message = respDict?["message"] as? String ?? ""
        name = respDict?["name"] as? String ?? ""
        pickzonId = respDict?["pickzonId"] as? String ?? ""
        profilePic = respDict?["profilePic"] as? String ?? ""
        celebrity = respDict?["celebrity"] as? Int ?? 0
        //type =  1 // 1=  Normal message, 2= Gift Message
        type = respDict?["type"] as? Int ?? 0
        avatar = respDict?["avatar"] as? String ?? ""
        giftingLevel = respDict?["giftingLevel"] as? String ?? ""
        
        gifterLevel = respDict?["gifterLevel"] as? Int ?? 0 //gifterLevel -- 1,2,3  top 3 gifter 

    }
}


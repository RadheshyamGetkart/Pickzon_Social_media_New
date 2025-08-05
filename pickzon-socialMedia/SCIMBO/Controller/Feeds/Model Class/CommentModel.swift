//
//  CommentModel.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 3/10/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import Foundation


struct CommentClass: Codable{
    
    var status:Int?
    var totalRecords:Int?
    var message:String?
    var totalPages:Int?
    var payload:CommentPayloadModel?
}

struct CommentReplyResponse: Codable{
    
    var status:Int?
    var message:String?
    var payload:ReplyPayloadModel?
}


struct CommentLikeDislike: Codable{
    
    var status:Int?
    var message:String?
    var payload:PayloadResponse?
}

struct PayloadResponse:Codable{
   
    var commentLikeCount:String?
}


struct AddCommentResponse: Codable{

    var status:Int?
    var message:String?
    var payload:PayloadModel?
}


struct PayloadModel:Codable{
    
    var commentCount:String?
    var comment:CommentModel?
}


struct ReplyPayloadModel:Codable{
    
    var commentCount:String?
    var comment:CommentReply?
}


struct CommentPayloadModel:Codable{
    
    var commentCount:String?
    var comment:[CommentModel]?
}

struct CommentModel : Codable {
    
    var comment:String?
    var createdAt:String?
    var id:String?
    var feedTime:String?
    var reply = [CommentReply]()
    var userInfo:UserInfoComment?
    var isExpanded = false
    var commentLikeCount:String? = "0"
    var isLike:Int?

    enum CodingKeys : String, CodingKey {
        
        case comment
        case createdAt
        case id
        case feedTime
        case reply
        case userInfo
        case isLike
        case commentLikeCount

    }
    
}

struct CommentReply : Codable {
    
    var  comment:String?
    var  createdAt:String?
    var  feedTime:String?
    var  id:String?
    var userInfo:UserInfoComment?
    var replyTo:String?
    var commentLikeCount:String? = "0"
    var isLike:Int?
}


struct UserInfoComment : Codable {
    
    var celebrity:Int?
    var id:String?
    var profilePic:String?
    var pickzonId:String?
    var name:String?
    var isPage:Int? = 0
    var isGroup:Int? = 0
    var userId:String?
    var actualProfileImage:String?
    var userType:Int = 0
    
    enum CodingKeys : String, CodingKey {

        case pickzonId
        case celebrity
        case id
        case profilePic
        case name
        case isPage
        case isGroup
        case userId
        case actualProfileImage
        case userType
    }
}




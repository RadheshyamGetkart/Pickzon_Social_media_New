//
//  CommentModel.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 3/10/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import Foundation


struct CommentClass: Codable {
    
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
   
    var commentLikeCount:Int?
}


struct AddCommentResponse: Codable{

    var status:Int?
    var message:String?
    var payload:PayloadModel?
}


struct PayloadModel:Codable{
    
    var commentCount:Int16?
    var comment:CommentModel?
}


struct ReplyPayloadModel:Codable{
    
    var commentCount:Int16?
    var comment:CommentReply?
}


struct CommentPayloadModel:Codable{
    
    var commentCount:Int16?
    var comment:[CommentModel]?
}

struct CommentModel : Codable {
    
    var comment:String?
    var id:String?
    var feedTime:String?
    var reply = [CommentReply]()
    var userInfo:UserInfoComment?
    var isExpanded = false
    var commentLikeCount:Int? = 0
    var isLike:Int?

    enum CodingKeys : String, CodingKey {
        
        case comment
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
    var  feedTime:String?
    var  id:String?
    var userInfo:UserInfoComment?
    var replyTo:String?
    var commentLikeCount:Int? = 0
    var isLike:Int?
}


struct UserInfoComment : Codable {
    
    var id:String?
    var celebrity:Int?
    var profilePic:String?
    var pickzonId:String?
    var name:String?
    var avatar:String?
    var jobProfile:String?
    var headline:String?
    
    enum CodingKeys : String, CodingKey {
        case pickzonId
        case celebrity
        case id
        case profilePic
        case name
        case avatar
        case jobProfile
        case headline
    }
    
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.celebrity = try container.decodeIfPresent(Int.self, forKey: .celebrity) ?? 0
        self.pickzonId = try container.decodeIfPresent(String.self, forKey: .pickzonId) ?? ""
        self.profilePic = try container.decodeIfPresent(String.self, forKey: .profilePic) ?? ""
        self.jobProfile = try container.decodeIfPresent(String.self, forKey: .jobProfile) ?? ""
        self.avatar = try container.decodeIfPresent(String.self, forKey: .avatar) ?? ""
        self.jobProfile = try container.decodeIfPresent(String.self, forKey: .jobProfile) ?? ""
        self.headline = try container.decodeIfPresent(String.self, forKey: .headline) ?? ""
        
    }
    
}




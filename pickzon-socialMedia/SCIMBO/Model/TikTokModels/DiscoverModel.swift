//
//  DiscoverModel.swift
//  SCIMBO
//
//  Created by SachTech on 02/09/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import Foundation
struct DiscoverModel {
    var section_name:AnyObject?
    var sections_videos:AnyObject?
    
    init(dict:NSDictionary){
        self.sections_videos = dict.value(forKey: "sections_videos") as AnyObject
        self.section_name = dict.value(forKey: "section_name") as AnyObject
       
    }
}


struct SearchUserModel {
    var _id:AnyObject?
    var Name:AnyObject?
    var ProfilePic:AnyObject?
    var username:AnyObject?
    var video:AnyObject?
    var Tiktokname:AnyObject?
    var celebrity:Int?
    var avatar: String = ""
    
    init(dict:NSDictionary){
        self._id = dict.value(forKey: "_id") as AnyObject
        self.Name = dict.value(forKey: "Name") as AnyObject
        self.ProfilePic = dict.value(forKey: "ProfilePic") as AnyObject
        self.username = dict.value(forKey: "username") as AnyObject
        self.video = dict.value(forKey: "video") as AnyObject
        self.Tiktokname = dict.value(forKey: "Tiktokname") as AnyObject
        self.celebrity = dict.value(forKey: "celebrity") as? Int ?? 0
        self.avatar = dict.value(forKey: "avatar") as? String ?? ""
    }
}


struct SearchedUser{
   
    var id : String = ""
    var celebrity :Int = 0
    var name:String = ""
    var pickzonId:String = ""
    var profilePic:String = ""
    var headline: String = ""
    var jobProfile: String = ""
    var location: String = ""
    var isBlock: Int
    var avatar: String = ""
    var isFollow = 0
    /*
     isFollow -->>      0 - No follow any one  1-Follow   2-Request
     */
   
    init(dict:NSDictionary){
        self.id = dict.value(forKey: "id") as? String ?? ""
        self.celebrity = dict.value(forKey: "celebrity") as? Int ?? 0
        self.name = dict.value(forKey: "name") as? String ?? ""
        self.profilePic = dict.value(forKey: "profilePic") as? String ?? ""
        self.isFollow = dict.value(forKey: "isFollow") as? Int ?? 0

        if self.profilePic.length > 0 {
            if self.profilePic.prefix(1) == "." {
                self.profilePic = String(self.profilePic.dropFirst(1))
            }
            if !self.profilePic.starts(with: "http"){
                self.profilePic = Constant.sharedinstance.ImgBaseURL + self.profilePic
            }
        }
        self.pickzonId = dict.value(forKey: "pickzonId") as? String ?? ""
        self.headline = dict.value(forKey: "headline") as? String ?? ""
        self.jobProfile = dict.value(forKey: "jobProfile") as? String ?? ""
        self.location = dict.value(forKey: "location") as? String ?? ""
        self.isBlock = dict.value(forKey: "isBlock") as? Int ?? 0
        self.avatar = dict.value(forKey: "avatar") as? String ?? ""
    }
}

struct SearchHistory{
    var id : String = ""
    var text : String = ""
    init(dict:NSDictionary){
        self.id = dict.value(forKey: "id") as? String ?? ""
        self.text = dict.value(forKey: "text") as? String ?? ""
    }
}


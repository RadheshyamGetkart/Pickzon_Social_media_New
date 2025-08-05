//
//  NotificationModel.swift
//  SCIMBO
//
//  Created by SachTech on 03/09/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import Foundation

struct NotificationModel {
    var id:AnyObject?
    var fb_id:AnyObject?
    var type : AnyObject?
    var message:AnyObject?
    var created:AnyObject?
    var user_info:AnyObject?
    var video_data : AnyObject?
 
    init(dict:NSDictionary){
        self.id = dict.value(forKey: "id") as AnyObject
        self.fb_id = dict.value(forKey: "fb_id") as AnyObject
        self.type = dict.value(forKey: "type") as AnyObject
        self.message = dict.value(forKey: "message") as AnyObject
        self.created = dict.value(forKey: "created") as AnyObject
        self.user_info = dict.value(forKey: "user_info") as AnyObject
        self.video_data = dict.value(forKey: "video_data") as AnyObject
           }
}

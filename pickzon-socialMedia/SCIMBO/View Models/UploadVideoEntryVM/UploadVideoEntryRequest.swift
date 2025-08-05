//
//  UploadVideoEntryRequest.swift
//  SCIMBO
//
//  Created by Sachtech on 30/09/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import Foundation

struct UploadVideoEntryRequest: JsonSerilizer {
    
    var msisdn: String = ""
    var description: String = ""
    var videourl: String = ""
    var soundId: String = ""
    var tags: String = ""
    var videoType: String = ""
    var s3VideoUrl: String = ""
    var commenttype:String = ""
    var sharetype: String = ""
    var downloadtype: String = ""
    var tagsArray:Array = Array<String>()
    var isWallpost:Int = 0
    var thumbUrl:String = ""
    
    func serilize() -> Dictionary<String, Any> {
        return [
            "msisdn": msisdn,
            "description": description,
            "videourl": videourl,
            "sound_id": soundId,
            "tags": tags,
            "tagsArray":tagsArray,
            "videotype": videoType,
            "s3VideoUrl":s3VideoUrl,
            "commenttype":commenttype,
            "sharetype":sharetype,
            "downloadtype":downloadtype,
            "isWallpost":isWallpost,
            "thumbUrl":thumbUrl
        ]
    }
}

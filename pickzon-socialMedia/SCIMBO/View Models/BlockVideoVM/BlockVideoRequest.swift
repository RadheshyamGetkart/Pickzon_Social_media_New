//
//  BlockVideoRequest.swift
//  SCIMBO
//
//  Created by Getkart on 27/05/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit
import RxSwift


struct BlockVideoRequest: JsonSerilizer {
    
    var videoId: String = ""
    var msisdn: String = ""
    
    func serilize() -> Dictionary<String, Any> {
        return [
            //"Id": videoId
            "video_id":videoId,
            "msisdn":msisdn
        ]
    }
}

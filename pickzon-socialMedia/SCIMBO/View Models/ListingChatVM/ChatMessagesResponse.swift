//
//  ChatMessagesResponse.swift
//  SCIMBO
//
//  Created by Sachtech on 06/10/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import Foundation

struct ChatMessagesResponse: JsonDeserilizer {
    
    var error: Int = 0
    var message: String = ""
    var chatDetails: ChatDetails = ChatDetails()
    
    mutating func deserilize(values: Dictionary<String, Any>?) {

        error = values?["errNum"] as? Int ?? 0
        message = values?["message"] as? String ?? ""
        
        if let detail = values?["result"] as? NSDictionary{
            chatDetails.deserilize(values: detail as? Dictionary<String, Any>)
        }
    }
}

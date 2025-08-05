//
//  Config.swift
//
//  Created by Rahul Tiwari on 3/5/20.
//  Copyright © 2020 CASPERON. All rights reserved.

import Foundation

struct Config {   
    
    
    /*
     static var rtmpPushUrl:String  {
        get {
        return "wss://live.pickzon.com:443/WebRTCAppEE/websocket"
           // return "wss://test.antmedia.io:5443/WebRTCAppEE/websocket"

            if devEnvironment == .live {
                return "rtmp://live.pickzon.com/live/"
            }else if devEnvironment == .staging {
                return "rtmp://live.getkart.ca/live/"
            }else {
                return "rtmp://live.getkart.com/live/"
            }
        }
    }
    
   
    
    static var rtmpPlayUrl:String  {
        get {
            
            return "wss://live.pickzon.com:5443/WebRTCAppEE/websocket"
           // return "wss://test.antmedia.io:5443/WebRTCAppEE/websocket"
            if devEnvironment == .live {
                return "https://d1mb02l5ll2dge.cloudfront.net/live/"
            }else if devEnvironment == .staging {
                return "https://live.getkart.ca/live/"
            }else {
                return "http://live.getkart.com/live/"
            }
        }
    }*/
     
   
    

    static var serverUrl = "\(Themes.sharedInstance.getURL())"

}


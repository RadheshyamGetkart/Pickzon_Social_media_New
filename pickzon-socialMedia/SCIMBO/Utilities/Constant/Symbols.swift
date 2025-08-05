//
//  Symbols.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 3/29/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import Foundation
import UIKit


 func shoulAutoplayVideo() ->Bool{
    
    let enumVal = UserDefaults.standard.value(forKey: autoPlaySettingType) as? Int ?? 0
    
    if   enumVal == 0 {
        return true
    }
    
    if enumVal == 1{
        return true
    
    }else if enumVal == 3{
        
        return false
    }
    
    return true
}

func shouldContactSync() ->Bool {
    if UserDefaults.standard.object(forKey: contactSyncSettingsType) == nil {
        return true
    }else if UserDefaults.standard.bool(forKey: contactSyncSettingsType) == true{
        return true
    }else{
        return false
    }
}

public func checkMediaTypes(strUrl:String)->Int{
    
    let imageExtension = ["png","gif","jpg","jpeg","raw","tiff","bmp","webp","heif","jfif"]
    let documentExtension = ["pdf","doc","docx","xls","xlsx","txt","html","htm","psd","ppt","pptx","odp","data"]
    let videoExtension = ["mp4","avi","mov","flv","avchd","webm"]
    let audioExtension = ["m4a","wav","mp3"]
    let svgaExtension = ["svg","svga"]
    
    if let objUrl = strUrl as? NSString {
        
        if imageExtension.contains(objUrl.pathExtension.lowercased()){
            //Image
            return 1
        }else if documentExtension.contains(objUrl.pathExtension.lowercased()){
            //Document
            return 2
        }else if videoExtension.contains(objUrl.pathExtension.lowercased()){
            //video
            return 3
        }else if audioExtension.contains(objUrl.pathExtension.lowercased()){
            //Audio
            return 4
        }else if svgaExtension.contains(objUrl.pathExtension.lowercased()){
            //SVG
            return 5
        }
    }
    return 0
}



func getFollowUnfollowRequestedText(isFollowValue:Int)->String{
    /*
     isFollow -->>
     0 - No follow any one
     1-Follow
     2-Request
     3-isFollowBack
     */
    switch isFollowValue{
    case 1:
        return "Unfollow"
    case 2:
        return "Requested"
    case 3:
        return "Follow Back"
    default:
        return "Follow"
    }
        
}

public enum FeedSettingEnum: Int{

    case nothing 
    case onMobileDataAndWifi
    case wifiOnly
    case neverAutoPlay
}

public enum FeedCommentsSettingEnum: Int{
    case none
    case anyOne
    case yourFollower
    case youFollow
    
}

enum CreatePostType{
    
    case feedPost
    case pageFeedPost
    case groupFeedPost
}

enum WallPostFrom{
    
    case feeds
    case groups
    case pages
}


enum StoryBoard{
    
    static let main = UIStoryboard(name: "Main", bundle: nil)
    static let feeds = UIStoryboard(name: "Feeds", bundle: nil)
    static let letGo = UIStoryboard(name: "LetGo", bundle: nil)
    static let promote = UIStoryboard(name: "Promote", bundle: nil)
    static let spotify = UIStoryboard(name: "Spotify", bundle: nil)
    static let chat = UIStoryboard(name: "Chat", bundle: nil)
    static let premium = UIStoryboard(name: "Premium", bundle: nil)
    static let job = UIStoryboard(name: "Job", bundle: nil)
    static let coin = UIStoryboard(name: "Coin", bundle: nil)
    static let prelogin = UIStoryboard(name: "PreLogin", bundle: nil)
}





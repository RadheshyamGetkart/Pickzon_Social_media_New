//
//  Global.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 6/3/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import Foundation
import UIKit

//MARK: Constant Observers  Named values

let noti_PausePlayer = "noti_PausePlayerpauseMMPlayer"
let noti_PlayPlayer = "noti_PlayPlayerplayeMMPlayer"
let noti_RefreshProfile = "RefreshProfile"
let noti_RefreshFeed = "refreshFeed"
let noti_RefreshChatCount = "refreshChatCount"
let noti_RecieveFeedPostData = "noti_RecieveFeedPostData"
let noti_SccrollFeedsToTop = "noti_SccrollFeedsToTop"
let noti_PauseAllFeedsVideos = "noti_PauseAllFeedsVideos"
let noti_RefreshClips = "refreshClips"
let noti_ClipUpdateData = "noti_ClipUpdateData"
let videosStartWithSound = "videosStartWithSound"
let autoPlaySettingType = "autoPlaySettingType"
let darkModeSettings = "darkModeSettings"
let feedCommentSettingsType = "feedCommentSettingsType"
let contactSyncSettingsType = "contactSyncSettingsType"
let noti_RefreshStory = "noti_RefreshStory"
let notif_ViewScrolled = "viewScrolled"
let notif_Badgecount = "notif_Badgecount"
let noti_UploadProgress = "uploadProgressFeedsPost"


//Feeds Notifications
let notif_FeedLiked = Notification.Name("notif_FeedLiked")
let notif_FeedRemoved = Notification.Name("notif_FeedRemoved")
let notif_TagRemoved = Notification.Name("notif_TagRemoved")
let notif_feedExpanded = Notification.Name("notif_feedExpanded")
let notif_FeedFollowed = Notification.Name("notif_FeedFollowed")
let nofit_CommentAdded = Notification.Name("nofit_CommentAdded")
let nofit_FeedSaved = Notification.Name("nofit_FeedSaved")
let nofit_BackFromVideos = Notification.Name("nofit_BackFromVideos")
let noti_Boosted = Notification.Name("noti_Boosted")
let nofit_VideoPlayerError = Notification.Name("nofit_VideoPlayerError")

//Clip Notifications
let notif_ClipLiked = Notification.Name("notif_ClipLiked")
let notif_ClipRemoved = Notification.Name("notif_ClipRemoved")
let notif_ClipCommentCount = Notification.Name("notif_ClipCommentCount")


//MARK: Functions
func estimatedLabelHeight(text: String, width: CGFloat, font: UIFont) -> CGFloat {
    
    let size = CGSize(width: width, height: 1000)
    
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    
    let attributes = [NSAttributedString.Key.font: font]
    
    let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height
    
    return rectangleHeight
 }


enum MediaShareType{
    
    case clips
    case post
    case product
    case profile
    case page
    case group
    case pkGolive
    case golive
}


class ShareMedia{
    
   static func shareMediafrom(type:MediaShareType,mediaId:String,controller:UIViewController){
        
       var baseUrl = "https://www.pickzon.com"
      
       
     /*   "https://gupsup.com"
       
       if devEnvironment == .staging{
           baseUrl = "https://getkart.ca"

       }else  if devEnvironment == .live{
            baseUrl = "https://www.pickzon.com"
       }
       */
        if type == .post{
            
            baseUrl = "\(baseUrl)/post/\(mediaId)"
            
        }else if type == .clips{
            baseUrl = "\(baseUrl)/clip/\(mediaId)"
            
        }else if type == .product{
            baseUrl = "\(baseUrl)/product/\(mediaId)"
        
        }else if type == .profile{
            baseUrl = "\(baseUrl)/profile/\(mediaId)"
        }else if type == .page{
            baseUrl = "\(baseUrl)/page/\(mediaId)"
        }else if type == .group{
            baseUrl = "\(baseUrl)/group/\(mediaId)"
        }else if type == .golive{
            baseUrl = "\(baseUrl)/golive/\(mediaId)"
        }else if type == .pkGolive{
            baseUrl = "\(baseUrl)/pkgolive/\(mediaId)"
        }
      
        print("Deep link ==\(baseUrl)")
        let activityController = UIActivityViewController(activityItems: [baseUrl, ActionExtensionBlockerItem()], applicationActivities: nil)
      // let activityController = UIActivityViewController(activityItems: [baseUrl], applicationActivities: nil)

       let excludedActivities = [UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToTencentWeibo]
        activityController.excludedActivityTypes = excludedActivities
        controller.presentView(activityController, animated: true)
    }
    
}



class ActionExtensionBlockerItem: NSObject, UIActivityItemSource {
    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "group.NHBQDLLJN4.com.PickZonGroup"
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return NSObject()
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return String()
    }

    func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivity.ActivityType?, suggestedSize size: CGSize) -> UIImage? {
        return nil
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return String()
    }
}


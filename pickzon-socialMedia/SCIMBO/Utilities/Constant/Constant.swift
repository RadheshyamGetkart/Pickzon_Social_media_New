//
//  Constant.swift
//
//
//  Created by CASPERON on 29/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.

import Foundation


enum DevEnvironment {
    case development
    case staging
    case live
}

var ISDEBUG = true
var devEnvironment: DevEnvironment = .live

var BaseURLArray :Array<String> {
    get {
        if devEnvironment == .live {
            return ["https://app.pickzon.com"]
        }else if devEnvironment == .staging {
            return ["https://getkart.ca"]
        }else{
            //Development Base URL
            return ["https://apps.getkart.com"]
        }
    }
}

var BaseUrl : String {
    get {
        return Themes.sharedInstance.getURL() + "/api"
    }
}


//New Base URL For API's
var NewBaseUrl : String {
    get {
        if devEnvironment == .live {
            return "https://apps.pickzon.com"
        }else if devEnvironment == .staging {
            return "https://getkart.ca"
        }else {
            //Development
            return "https://apps.getkart.com"
        }
    }
}

var ImgUrl : String {
    get {
        return Themes.sharedInstance.getURL()
    }
}

var SocketCreateRoomUrl : String {
    get {
        if devEnvironment == .live {
            return "https://chat.pickzon.com"
        }else if devEnvironment == .staging {
            return "https://chat.getkart.ca"
        }else  {
            //Development
            return "https://chat.getkart.com"
        }
    }
}


var webUrl : String {
    get {
        return "https://www.pickzon.com/login"
    }
}


@objc class Constant : NSObject {
    
    var feedChatCount = 0
    var requestedChatCount = 0
    var notificationCount = 0
    
    static let sharedinstance = Constant()
    private override init() {
        
    }
    
    var rtmpPushUrl:String = "wss://live.pickzon.com:443/WebRTCAppEE/websocket"
    var rtmpPlayUrl:String = "wss://live.pickzon.com:5443/WebRTCAppEE/websocket"

    var arrFilterEffect:Array<FilterEffects> = Array()
    
    //MARK: PUblic
    
    
    var get_agency_pk :String {
        get{
            return "\(NewBaseUrl)/agency/get-agency-pk"
        }
    }
    
    
    var get_pk_legend :String {
        get{
            return "\(NewBaseUrl)/agency/get-pk-legend"
        }
    }
    
    
    
    var hash_tag_got_talent :String {
        get{
            return "\(NewBaseUrl)/search/hash-tag-got-talent"
        }
    }
    
    
    
    var guidelines_hashTagPgtGuidelines :String {
        get{
            return "\(NewBaseUrl)/public/guidelines/hashTagPgtGuidelines"
        }
    }
    
    
    
    
    
    var get_pk_time_slot :String {
        get{
            return "\(NewBaseUrl)/public/get-pk-time-slot"
        }
    }
    var getFiltersURL:String {
        get{
            return "\(NewBaseUrl)/public/get-filters"
        }
    }
    
    
    //MARK: Premium & Coins
    
    
    var weekEvents_fetch_week_events :String {
        get{
            return "\(NewBaseUrl)/weekEvents/fetch-week-events"
        }
    }
    
    var weekEvents_add_week_events :String {
        get{
            return "\(NewBaseUrl)/weekEvents/add-week-events"
        }
    }
    var  get_valentine_leaderboard :String {
        get{
            return "\(NewBaseUrl)/valentineLeaderboard/get-valentine-leaderboard"
        }
    }
    
    var  get_live_users :String {
        get{
            return "\(NewBaseUrl)/live/get-live-users"
            
        }
    }
    
    var  get_live_user_list :String {
        get{
            return "\(NewBaseUrl)/live/get-live-user-list"
        }
    }
    
    var get_referral_content :String {
        get{
            return "\(NewBaseUrl)/coin/get-referral-content"
        }
    }
    
    var get_coin_referral_history :String {
        get{
            return "\(NewBaseUrl)/coin/get-coin-referral-history"
        }
    }
    
    
    var get_weekly_host_leaderboard :String {
        get{
            return "\(NewBaseUrl)/live/get-weekly-host-leaderboard"
        }
    }
  
    
    var get_liveleaderboard_data :String {
        get{
            return "\(NewBaseUrl)/liveleaderboard/get-live-leaderboard-data"
        }
    }
    
    var go_live_access_request :String {
        get{
            return "\(NewBaseUrl)/user/go-live-access-request"
        }
    }
    
    
    var get_leaderboard_data :String {
        get{
            return "\(NewBaseUrl)/v1/leaderboard/get-leaderboard-data"
        }
    }
    
    var get_leaderboard_topper :String {
        get{
            return "\(NewBaseUrl)/leaderboard/get-leaderboard-topper"
        }
    }
    
    var premiumBenefits :String {
        get{
            return "\(NewBaseUrl)/premium/premium-benefits"
        }
    }
    
    
    var guidelines_boost :String {
        get{
            return "\(NewBaseUrl)/public/guidelines/boost"
        }
    }
    
    
    var guidelines_professionalDashboard :String {
        get{
            return "\(NewBaseUrl)/public/guidelines/professionalDashboard"
        }
    }
    
    
    var guidelines_weeklyLeaderboard :String {
        get{
            return "\(NewBaseUrl)/public/guidelines/weeklyLeaderboard"
        }
    }
    
    
    var  hash_tag_guidelines :String {
        get{
            return "\(NewBaseUrl)/public/hash-tag-guidelines"
        }
    }
    
    
    var agencyPlanOffersURL :String {
        get{
            return "\(NewBaseUrl)/agency/get-agency-plan-offers-list"
        }
    }
    
    var agency_coin_order :String {
        get{
            return "\(NewBaseUrl)/agency/agency-coin-order"
        }
    }
    
    var get_retailer_guidelines :String {
        get{
            return "\(NewBaseUrl)/agency/get-retailer-guidelines"
        }
    }
    
    var agency_send_cheer_coins :String {
        get{
            return "\(NewBaseUrl)/agency/agency-send-cheer-coins"
        }
    }
    
    var send_otp_transfer_coin :String {
        get{
            return "\(NewBaseUrl)/coin/send-otp-transfer-coin"
        }
    }
        
    
    var verify_otp_transfer_coin :String {
        get{
            return "\(NewBaseUrl)/coin/verify-otp-transfer-coin"
        }
    }
    
    
    var agencyListURL :String {
        get{
            return "\(NewBaseUrl)/agency/get-agency-list"
        }
    }
    
    var cheersCoinsList :String {
        get{
            return "\(NewBaseUrl)/coin/get-cheers-coins-list"
        }
    }
    
    var buy_avatar:String{
        get{
            return "\(NewBaseUrl)/avatar/buy-avatar"
        }
        
    }
    
    
    var get_boost_performance_overview :String {
        get{
            return "\(NewBaseUrl)/boost/get-boost-performance-overview"
        }
    }
    
    
    var get_boost_post_history :String {
        get{
            return "\(NewBaseUrl)/boost/get-boost-post-history"
        }
    }
    
    var boost_boost_post :String {
        get{
            return "\(NewBaseUrl)/boost/boost-post"
        }
    }
    
    
    
    var get_boost_post_details :String {
        get{
            return "\(NewBaseUrl)/boost/get-boost-post-details"
        }
    }
    
    var get_boost_plan_list :String {
        get{
            return "\(NewBaseUrl)/boost/get-boost-plan-list"
        }
    }
    
    var userCoinInfo :String {
        get{
            return "\(NewBaseUrl)/coin/get-user-coins-info"
        }
    }
    
    
    var agency_get_agency_plans :String {
        get{
            return "\(NewBaseUrl)/agency/get-agency-plans"
        }
    }
    
    var coinPlanOffersList :String {
        get{
            return "\(NewBaseUrl)/coin/get-coin-plan-offers-list"
        }
    }
    
    var get_coins_transaction_history :String {
        get{
            return "\(NewBaseUrl)/coin/get-coins-transaction-history"
        }
    }
    
    var coin_get_purchase_coins_transaction_history :String {
        get{
            return "\(NewBaseUrl)/coin/get-purchase-coins-transaction-history"
        }
    }
    
    
    var give_coins_to_user :String {
        get{
            return "\(NewBaseUrl)/coin/give-coins-to-user"
        }
    }
    
    var coin_withdraw_request  :String {
        get{
            return "\(NewBaseUrl)/coin/withdraw-request"
        }
    }
    
    var coin_purchase_coins  :String {
        get{
            return "\(NewBaseUrl)/coin/purchase-coins"
        }
    }
    
    var user_bank_details  :String {
        get{
            return "\(NewBaseUrl)/user/bank-details"
        }
    }
    
    var exchange_gift_coins_to_cheer_coins  :String {
        get{
            return "\(NewBaseUrl)/coin/exchange-gift-coins-to-cheer-coins"
        }
    }
        
    var agency_coin_transfer  :String {
        get{
            return "\(NewBaseUrl)/agency/agency-coin-transfer"
        }
    }
    
    
    var coin_generate_coin_payment_order  :String {
        get{
            return "\(NewBaseUrl)/coin/generate-coin-payment-order"
        }
    }
    
    
    //MARK: - FEEDS API's URL
    
    var repostTaggedStory :String {
        get{
            return "\(NewBaseUrl)/story/add-story"
        }
    }
    
    var authMatchQRImage :String {
        get{
            return "\(SocketCreateRoomUrl)/auth/match-QRImage"
        }
    }
    
    var addNewPost :String {
        get{
            return "\(NewBaseUrl)/feed/add-feed"
        }
    }
     
     var updateFeedPost :String {
         get{
             return "\(NewBaseUrl)/v1/feed/update-feed"
         }
     }
     
     var getAllWallPostURL :String {
         get{

             return "\(NewBaseUrl)/feed/get-feeds-listing"
         }
     }
     
     var getFeedVideosURL :String {
         get{
             return "\(NewBaseUrl)/feed/get-random-feed-videos"
         }
     }
    
    var getSuggestedRandomVideosURL :String {
        get{
            return "\(NewBaseUrl)/feed/get-suggested-random-videos"
        }
    }
    
    var getUserSuggestionListURL :String {
        get{
            return "\(NewBaseUrl)/v1/suggestion/get-user-suggestion-list"
        }
    }
    
     
     var getFeelingsURL: String {
         get{
             return "\(NewBaseUrl)/feed/get-all-feeling"
         }
     }
     
     var getActivitiesURL: String {
         get{
             return "\(NewBaseUrl)/feed/get-all-activity"
         }
     }
     
     var savePostList: String {
         get{
             return "\(NewBaseUrl)/feed/get-saved-feed"
             
         }
     }
     
     
     var getSingleWallPost: String {
         get{
             return "\(NewBaseUrl)/v1/feed/get-feed"
         }
     }
     
    var user_event_pass: String {
        get{
            return "\(NewBaseUrl)/user/event-pass"
        }
    }
    
    
    var performance_dashboard: String {
        get{
            return "\(NewBaseUrl)/user/performance-dashboard"
        }
    }
     var reportWallPost: String {
         get{
             return "\(NewBaseUrl)/feed/report-post"
         }
     }
     
     var likeDislikePostURL: String {
         get{
             return "\(NewBaseUrl)/v1/feed/like-dislike-feed"
         }
     }
     
     var searchHashTagWallpost: String {
         get{
             return "\(NewBaseUrl)/feed/hashtag-feeds-listing"
         }
     }
    
     
     var getCommentURL: String {
         get{
             return "\(NewBaseUrl)/v1/feed/get-all-feed-comment"

         }
     }
     
     
     var addFeedCommentURL: String {
         get{
             return "\(NewBaseUrl)/v1/feed/add-feed-comment"
             
         }
     }
     
     var getAllPageWallPost:String {
         get{
             
             return "\(NewBaseUrl)/feed/get-page-feeds-listing"

             
         }
     }
    
    var getDownloadMediaURL:String {
        get{
            return "\(NewBaseUrl)/feed/download"
        }
    }
    
    var getDownloadCleanURL:String {
        get{
            return "\(NewBaseUrl)/feed/download-clean"
        }
    }
    
    var getAllPageVideosWallPost:String {
        get{
            return "\(NewBaseUrl)/page/get-page-videos"
        }
    }
    
    var getAllPagePhotoWallPost:String {
        get{
            return "\(NewBaseUrl)/page/get-page-photos"
        }
    }
    
    
     var deleteFeedCommentURL: String {
         get{
             return "\(NewBaseUrl)/v1/feed/delete-feed-comment"

             
         }
     }
     
     
     var savePostURL: String {
         get{
             return "\(NewBaseUrl)/feed/save-feed-post"
         }
     }
     
     
     var sharePost: String {
         get{
             return "\(NewBaseUrl)/feed/share-feed"

         }
     }
     
     
     var blockPost: String {
         get{
             return "\(NewBaseUrl)/feed/block-post"
             
         }
     }
    
    var removeTagUserURL: String {
        get{
            return "\(NewBaseUrl)/feed/remove-tag-user"
            
        }
    }
     
     
     var deleteWallPost: String {
         get{
             return "\(NewBaseUrl)/feed/delete-feed"

         }
     }
     
     
     var clearParticularNotification: String {
         get{
             return "\(NewBaseUrl)/feed/clear-particular-notification"
         }
     }
     
     var clearAllNotification: String {
         get{
             return "\(NewBaseUrl)/feed/clear-all-notification"
         }
     }
     
     var postLikeList: String {
         get{
             return "\(NewBaseUrl)/v1/feed/feed-like-users"
         }
     }
     
     var getCommentLikes: String {
         get{
             
             return "\(NewBaseUrl)/v1/feed/get-all-feed-comment-like"
        }
     }
     
     var commentlikeDislike:String {
         get{
             return "\(NewBaseUrl)/v1/feed/like-dislike-feed-comment"

         }
     }
    
     
    
     
     var getFrienSuggestionFeed:String {
         get{
             return "\(NewBaseUrl)/feed/get-Friend-Suggestion"
         }
     }
     
     var updateFeedSeenURL:String {
         get{
             return "\(NewBaseUrl)/feed/update-seen-feeds"
         }
     }
    
    
    //MARK: - USER's API URL
    
    
    var user_angel_list : String {
        get {
            return "\(NewBaseUrl)/user/get-angel-list"
        }
    }
    
    var get_user_information : String {
        get {
            return "\(NewBaseUrl)/v1/user/get-user-information"
        }
    }
    
    var change_user_online_offline_status : String {
        get {
            return "\(NewBaseUrl)/user/change-user-online-offline-status"
        }
    }
    var generateUserProfileQrImage : String {
        get {
            return "\(NewBaseUrl)/public/generate-user-profile-qr-image"
        }
    }
    
    
    var get_user_referral_qr_image : String {
        get {
            return "\(NewBaseUrl)/referral/get-user-referral-qr-image"
        }
    }
    
    
    var warnUserRead : String {
        get {
            return "\(NewBaseUrl)/user/warn-user-read"
        }
    }
    var userWarn : String {
        get {
            return "\(NewBaseUrl)/user/warn-user"
        }
    }
    
    
    var vipVerificationRequest : String {
        get {
            return "\(NewBaseUrl)/user/vip-verification-request"
        }
    }
    
    var showUserProfile : String {
        get {
            return "\(NewBaseUrl)/user/show-user-profile"
        }
    }
    
    
    var showUserFeedsList : String {
        get {
            return "\(NewBaseUrl)/user/show-user-feeds"
        }
    }

    var get_user_mutual : String {
        get {
            return "\(NewBaseUrl)/user/get-user-mutual"
        }
    }
    
    var showUserInfo : String {
        get {
            return "\(NewBaseUrl)/user/show-user-info"
        }
    }
    
    var follow : String {
        get {
            return "\(NewBaseUrl)/user/follow-user"
        }
    }
    
    
    var cancelRequest : String {
        get {
            return "\(NewBaseUrl)/v1/user/cancel-request"
        }
    }
        
    var acceptFriend : String {
        get {
            return "\(NewBaseUrl)/v1/user/accept-friend"

        }
    }
    
    var SearchKeyWord : String {
        get {
            return "\(NewBaseUrl)/user/search"
        }
    }
    
    var SearchMediaURL : String {
        get {
            return "\(NewBaseUrl)/user/search-media"
        }
    }
    
    var friendRequestList:String {
        get{
            return "\(NewBaseUrl)/user/get-user-friend-request-list"
        }
    }
    
    var getMutualFriend:String {
        get{
            return "\(NewBaseUrl)/user/get-mutual-friends"
        }
    }
  
    var getFollowersDetails:String {
        get{
            return "\(NewBaseUrl)/v1/user/get-followers-details"
        }
    }
    
    var getFollowingsDetails:String {
        get{
            return "\(NewBaseUrl)/v1/user/get-followings-details"
        }
    }
    
    
    var get_forward_chat_friend_list:String {
        get{
            return "\(NewBaseUrl)/user/get-forward-chat-friend-list"
        }
    }
    
    
    
    var suggestedFriendsList :String {
        get{
            return "\(NewBaseUrl)/user/suggested-friends-list"
        }
    }
    
    var getFriendsURL: String {
        get{
            return "\(NewBaseUrl)/user/get-user-friends"
        }
    }
    
    var editUserProfile: String {
        get{
            return "\(NewBaseUrl)/user/update-user-profile"
        }
    }
    
    var getmsisdn: String {
        get{
            return "\(NewBaseUrl)/user/get-user-info-by-pickzon-id"
        }
    }
    
    var getProfileCategoryURL:String {
        get{
           return "\(NewBaseUrl)/user/get-profile-category"
        }
    }
    
    
    var authSendOTPUrl:String {
        get{
            return "\(NewBaseUrl)/v1/auth/send-otp"
        }
    }
    
    
    var authVerifyOTPUrl:String {
        get{
            return "\(NewBaseUrl)/v1/auth/verify-otp"
        }
    }
    
    
    var sendEmailOTP:String {
        get{
            return "\(NewBaseUrl)/user/send-email-otp"
        }
    }
    
    
    
    var verifyEmailOTP:String {
        get{
            return "\(NewBaseUrl)/user/verify-email-otp"
        }
    }
    
    var authSendEmailOTP:String {
        get{
            return "\(NewBaseUrl)/v1/auth/send-email-otp"
        }
    }
    
    var authVerifyEmailOTP:String {
        get{
            return "\(NewBaseUrl)/v1/auth/verify-email-otp"
        }
    }
    
    
    var removeSuggestedFriend:String {
        get{
            return "\(NewBaseUrl)/user/remove-suggested-friend"
        }
    }
    
    var referralHistory:String {
        get{
            return "\(NewBaseUrl)/user/get-referral-history"
        }
    }
    
    var getClipSetting:String {
        get{
            return "\(NewBaseUrl)/user/setting"
        }
    }
        
    
    var get_badge_cert:String {
        get{
            return "\(NewBaseUrl)/public/get-badge-cert"
        }
    }
    
    var getPopupSeen:String {
        get{
            return "\(NewBaseUrl)/user/popup-seen"
        }
    }
    
    var deleteUserAccountURL:String {
        get{
            return "\(NewBaseUrl)/user/delete-user-account-permanently"
        }
    }
    var deleteAccountURL:String {
        get{
            return "\(NewBaseUrl)/user/delete-user-account"
        }
    }
    
    var deleteReasonListURL:String {
        get{
            return "\(NewBaseUrl)/public/delete-reason-list"
        }
    }
    
   
    var getBannerURL:String {
        get{
            return "\(NewBaseUrl)/search/get-banner"
        }
    }
    
    
    var getTopCreatorsURL:String {
        get{
            return "\(NewBaseUrl)/search/get-top-creators"
        }
    }
    var getHashTagVideosURL:String {
        get{
            return "\(NewBaseUrl)/v1/search/get-hash-tag-videos"
        }
    }
    var globalSearchListingURL:String {
        get{
            return "\(NewBaseUrl)/user/global-search-listing"
        }
    }
    
    var clearSearchHistory:String {
        get{
            return "\(NewBaseUrl)/user/clear-search-history"
        }
    }
    
    var searchSuggestionURL:String {
        get{
            return "\(NewBaseUrl)/user/search-suggestion"
        }
    }
    
    
   //MARK: - AUTH's API URL
    var createNewUser : String {
        get {
            return "\(NewBaseUrl)/v1/auth/create-new-user"
        }
    }
    var hashingCreator:String {
        get{
            return "\(NewBaseUrl)/auth/hash-code"
        }
    }
    
    
    var sendMobileOtpURL:String {
        get{
            return "\(NewBaseUrl)/auth/send-mobile-otp"
        }
    }
    
    var sendForgetOtpURL:String {
        get{
            return "\(NewBaseUrl)/v1/auth/send-forget-otp"
        }
    }
    
    var sendEmailMobileOtpURL:String {
        get{
            return "\(NewBaseUrl)/auth/send-email-mobile-otp"
        }
    }
    
    
    var verifyForgetOtpURL:String {
        get{
            return "\(NewBaseUrl)/v1/auth/verify-forget-otp"
        }
    }
    
    
    var createNewPasswordURL:String {
        get{
            return "\(NewBaseUrl)/v1/auth/create-new-password"
        }
    }
    
    
    var changePasswordURL:String {
        get{
            return "\(NewBaseUrl)/v1/auth/change-password"
        }
    }
       
    var rootUserAPIURL:String {
        get{
            return "\(NewBaseUrl)/auth/root-user"
        }
    }
    
    var acceptTermConditionURL:String {
        get{
            return "\(NewBaseUrl)/auth/accept-term-condition"
        }
    }
    var verifyMobileOtp:String {
        get{
            return "\(NewBaseUrl)/auth/verify-mobile-otp"
        }
    }
    
    var verifyEmailMobileOtp:String {
        get{
            return "\(NewBaseUrl)/auth/verify-email-mobile-otp"
        }
    }
    
    var mobileOTP : String {
        get {
            return "\(NewBaseUrl)/auth/send-mobile-otp"
        }
    }
    
  //MARK: - CLIP's API URL
  
    var  clip_fetch_clip_by_songId  :String{
        get{
            return "\(NewBaseUrl)/feed/fetch-video-by-soundId"
        }
        
    }
 
    var getSharedPost: String {
        get {
            return "\(NewBaseUrl)/user/get-share-post"
        }
    }
    var getTagUserPost : String {
        get {
            return "\(NewBaseUrl)/user/get-tag-user-post"
        }
    }
    
    var getUserClip : String {
        get {
            return "\(NewBaseUrl)/clip/get-user-clip"
        }
    }
    
    var getComments : String {
        get {
            return "\(NewBaseUrl)/clip/get-clip-comment"
        }
    }
    
    var addComments : String {
        get {
            return "\(NewBaseUrl)/clip/add-clip-comment"
        }
    }
    
    var editClipVideoURL:String {
        get{
            return "\(NewBaseUrl)/clip/edit-clip-video"
        }
    }
   
    var uploadReelVideoURL:String {
        get{
            return "\(NewBaseUrl)/clip/upload-reel-video"
        }
    }
    
    var deleteClipCommentURL: String {
        get{
            return "\(NewBaseUrl)/clip/delete-clip-comment"
        }
    }
    
    var deleteClipVideo: String {
        get{
            return "\(NewBaseUrl)/clip/delete-clip"
        }
    }
   
    var getAllVideos : String {
        get {
            return "\(NewBaseUrl)/clip/fetch-clip-listing"
        }
    }
    var getVideoDetail : String {
        get {
            return "\(NewBaseUrl)/clip/get-clip-by-clipId"
        }
    }
    
    var videoByTagName : String {
        get {
            return "\(NewBaseUrl)/clip/get-clip-hashTag"
        }
    }
    

    var Settings : String {
        get {
            return "\(BaseUrl)/settings"
        }
    }
    var RegisterNo : String {
        get {
            return "\(BaseUrl)/Login"
        }
    }
    
    var authLogin : String {
        get {
            return "\(NewBaseUrl)/v1/auth/login"
        }
    }
    var updateNo : String {
        get {
            return "\(NewBaseUrl)/user/update-mobile-number"

        }
    }
    var verifyMsisdn : String {
        get {
            return "\(BaseUrl)/VerifyMsisdn"
        }
    }
    
    var UpdateData : String {
        get {
            return "\(BaseUrl)/UpdateData"
        }
    }
    var ResendInvitecode : String {
        get {
            return "\(BaseUrl)/ResendInvitecode"
        }
    }
    
    var getFollowingVideos : String {
        get {
            return "\(BaseUrl)/getAllFollowingVideos"
        }
    }
    
    var discoverTags : String {
        get {
            return "\(BaseUrl)/discoverTag"
        }
    }
    
    var categoryVideo : String {
        get {
            return "\(BaseUrl)/CategoryVideo"
        }
    }
    
    
    var completeUserProfile : String {
        get {
            return "\(BaseUrl)/completeUserProfile"
        }
    }
    
    var uploadProfileImage : String {
        get {
            return "\(NewBaseUrl)/user/upload-profile-image"
        }
    }
    
    var  coin_get_acc_reference_url : String {
        get {
            return "\(NewBaseUrl)/coin/get-acc-reference-url"
        }
    }
    
    var updateProfileImage : String {
        get {
            return "\(NewBaseUrl)/user/update-profile-image"
        }
    }
    
    var saveLiveVideo : String {
        get {
            return "\(BaseUrl)/saveLiveVideo"
        }
    }
    
    var postViews : String {
        get {
            return "\(BaseUrl)/postViews"
        }
    }
    
    var searchHashTag : String {
        get {
            return "\(NewBaseUrl)/user/search-hashTag"
        }
    }
   
    var getAllLivePost : String {
        get {
            return "\(BaseUrl)/getAllLivePost"
        }
    }
    
    
    var getUserVideos : String {
        get {
            return "\(BaseUrl)/showMyAllVideos"
        }
    }
    var getBlockUserList : String {
        get {
            return "\(NewBaseUrl)/user/block-user-list"

        }
    }
    var blockVideo : String {
        get {
            return "\(BaseUrl)/blockvideo"
        }
    }
    var blockUser : String {
        get {
            return "\(BaseUrl)/blockuser"
        }
    }
    var insertreport : String {
        get {
            return "\(BaseUrl)/insertreport"
        }
    }
    var unblockUser : String {
        get {
            return "\(BaseUrl)/unblockuser"
        }
    }
    var blockUnblockuser : String {
        get {
            return "\(NewBaseUrl)/user/block-unblock-user"

        }
    }

    var getReportList : String {
        get {
            return "\(BaseUrl)/GetReportList"
        }
    }
    
    
    
    var getAllSounds : String {
        get {
            return "\(BaseUrl)/allSounds"
        }
    }
    
    var getSavedAudioURL : String {
        get {
            return "\(BaseUrl)/getAudio"
        }
    }
    var getsearchSong : String {
        get {
            return "\(BaseUrl)/searchSong"
        }
    }
    
    var UploadSongEntry : String {
        get {
            return "\(BaseUrl)/UploadSongEntry"
        }
    }
    
    var notificationData : String {
        get {
            return "\(BaseUrl)/getNotifications"
        }
    }
    
    var UploadVideoEntry : String {
        get {
            return "\(BaseUrl)/UploadVideoEntry"
        }
    }
    
    var likeVideo : String {
        get {
            return "\(BaseUrl)/changeVideoLike"
            
        }
    }
    
    var wallStatusLikeDislikeURL : String {
        get {
            return "\(NewBaseUrl)/story/story-like-dislike"
            
        }
    }
    var clipSeen : String {
        get {
            return "\(BaseUrl)/clipSeen"
            
        }
    }
    
    var startFileuploadNotification : String {
        get {
            return "\(BaseUrl.replacingOccurrences(of: "/api", with: ""))/startFileuploadNotification"
        }
    }
    var downloadVideo:String{
        get {
            return "\(BaseUrl)/downloadVideo"
        }
    }
        
    var getoptionbysubcategory:String {
        get {
            return "\(BaseUrl)/getoptionbysubcategory"
        }
    }
   
    var picUploadURL:String {
        get {
            return "\(BaseUrl)/picUpload"
        }
    }
    
    var privacyURL:String {
        get {
            return "https://www.pickzon.com/app-privacy-policy"
        }
    }
    
    var userGreenBadgePolicyURL:String {
        get {
            return "https://www.pickzon.com/app-user-green-badge-policy"
        }
    }
    
    var pageVerificationPolicyURL:String {
        get {
            return "https://www.pickzon.com/app-page-verification-badge-policy"
        }
    }
    
    
    var faqURL:String {
        get {
            return "https://www.pickzon.com/app-faq"
        }
    }
    
    
    var termsURL:String {
        get {
            return "https://www.pickzon.com/app-terms"
        }
    }
    
    var howToEarnURL:String {
        get {
            return "https://www.pickzon.com/app-refer-and-earn"
        }
    }
    var getFollowing:String {
        get{
            return "\(BaseUrl)/getFollowings"
            
        }
    }
        
    var getFollowers:String {
        get{
            return "\(BaseUrl)/getFollowers"
            
        }
    }
    
    var getAllTagsURL:String {
        get{
            return "\(BaseUrl)/getAllTags"
        }
    }
    
    var friendRequestListURL :String {
        get{
            return "\(BaseUrl)/friendRequestList"
        }
    }
    
    
    var acceptFriendURL :String {
        get{
            return "\(BaseUrl)/acceptFriend"
        }
    }
    
    var wallPostByUserURL :String {
        get{
            return "\(BaseUrl)/wallPostByUser"
        }
    }
    
    var uploadMediaURL :String {
        get{
            return "\(BaseUrl)/uploadMedia"
        }
    }
    
    var wallPostURL :String {
        get{
            return "\(BaseUrl)/wallPost"
        }
    }
    
    var editWallPostURL :String {
        get{
            return "\(BaseUrl)/editWallPost"
        }
    }
    
    var clearLiveUser :String {
        get{
            return "\(BaseUrl)/clearLiveUser"
        }
    }
    
    
    var contactSuggestedFriendsList :String {
        get{
            return "\(NewBaseUrl)/suggestion/get-contact-friends-suggestion"
        }
    }
    
    var removeSavePost: String {
        get{
            return "\(NewBaseUrl)/feed/remove-save-post"
        }
    }
    
    
    
    var deleteStoryStatus: String {
        get{
            return "\(NewBaseUrl)/story/deleteStatus"
        }
    }
    
    var changeUserTypeURL: String {
        get{
            return "\(NewBaseUrl)/user/change-user-type"
        }
    }
    
    var deleteUserProfileImageURL: String {
        get{
            return "\(BaseUrl)/deleteUserProfileImage"
        }
    }
        
    var updateName: String {
        get{
            return "\(BaseUrl)/UpdateName"
        }
    }
    
    var getAllJob: String {
        get{
            return "\(NewBaseUrl)/user/get-all-job"
        }
    }
    
    
    var getContactUsCategory: String {
        get{
            return "\(NewBaseUrl)/public/contactus-category"
            
        }
    }
    
    var updateUserProfileURL: String {
        get{
            return "\(BaseUrl)/updateUserProfile"
        }
    }
    
    //MARK: - PAGE API's URL
 
    
    var updatePickzonName: String {
        get{
            return "\(NewBaseUrl)/user/update-pickzon-name"
        }
    }
    
    var searchUserBuPickZonIdUrl: String {
        get{
          
            return "\(NewBaseUrl)/user/search-user-by-pickzon-id"

        }
    }
    
    var getAllFeedsStatus: String {
        get{
            return "\(NewBaseUrl)/story/getAllStatus"
        }
    }
    
    var wallPostNotification: String {
        get{
            return "\(NewBaseUrl)/notif/get-all-notifications"
            
        }
    }
    
    var clearMultipleNotificationURL: String {
        get{
            return "\(NewBaseUrl)/notif/clear-multiple-notification"
            
        }
    }
    
    var activeUserPlan: String {
        get{
            return "\(BaseUrl)/activeUserPlan"
        }
    }
    
    var storyStatusView: String {
        get{
            return "\(NewBaseUrl)/v1/story/status-view"

        }
    }
    
    var uploadFeedMedia: String {
        get{
            return "\(SocketCreateRoomUrl)/feed/upload-media"
        }
    }
    
    
    var uploadWallStatus: String {
        get{
            return "\(NewBaseUrl)/story/uploadWallStatus"
        }
    }
    
    var feedFriendList: String {
        get{
            return "\(BaseUrl)/friendList"
        }
    }
    
    var saveAudioURL: String {
        get {
            return "\(BaseUrl)/saveAudio"
        }
    }
    
    var deleteAudioURL: String {
        get {
            return "\(BaseUrl)/deleteAudio"
        }
    }
    
  
    
    var removeContactFriendsSuggestionURL:String {
        get{
            return "\(NewBaseUrl)/v1/suggestion/remove-contact-friends-suggestion"
        }
    }
    
    
    var submitContactUsURL:String {
        get{
            return "\(NewBaseUrl)/public/submit-contactus"
        }
    }
    
    var likeDislikePostTesting:String {
        get{
            return "\(BaseUrl)/getAllPageWallPost"
        }
    }
    
    var checkCoinRedeem:String {
        get{
            return "\(NewBaseUrl)/referral/check-coin-redeem"
        }
    }
    
    var requestRedeemCoin:String {
        get{
            return "\(NewBaseUrl)/referral/request-redeem-coin"
        }
    }
    
       
   
    
    var userLogin:String {
        get{
            return "\(BaseUrl)/userLogin"
        }
    }
    
   

    var logout:String {
        get{
            return "\(NewBaseUrl)/auth/logout"
        }
    }
    
    
    
    //MARK: Notifications API URL
    
    var getNotificationSettingsURL:String {
        get{
            return "\(NewBaseUrl)/notif/notification-setting"
        }
    }
    
    var updateNotificationSettingsURL:String {
        get{
            return "\(NewBaseUrl)/notif/update-notification-setting"
        }
    }
    
    
        
   
    //MARK: User Api
    var  change_user_entry_effect:String {
        get{
            return "\(NewBaseUrl)/avatar/change-user-entry-effect/"
        }
    }
    
    var  get_user_entry_ffect_list:String {
        get{
            return "\(NewBaseUrl)/avatar/get-user-entry-effect-list"
        }
    }
    
    var  change_user_avatar_frame:String {
        get{
            return "\(NewBaseUrl)/avatar/change-user-avatar-frame/"
        }
    }
    
    var  get_user_avatar_list:String {
        get{
            return "\(NewBaseUrl)/avatar/get-user-avatar-list"
        }
    }
    
    
    var  get_paid_avatar_list:String {
        get{
            return "\(NewBaseUrl)/avatar/get-paid-avatar-list"
        }
    }
    
   
    var reportList:String {
        get{
            return "\(NewBaseUrl)/public/report-suggested-list?"
        }
    }
    
    var reportUserProfile:String {
        get{
            return "\(NewBaseUrl)/user/report-user-profile"
        }
    }
   
    var getCountries:String {
        get{
            return "\(NewBaseUrl)/user/get-countries"
        }
    }
    
    
    
    var getUserVideosList:String {
        get{
            return "\(NewBaseUrl)/user/get-user-videos"
        }
    }
   
    var getUserPhotosList:String {
        get{
            return "\(NewBaseUrl)/user/get-user-photos"
        }
    }
    
    
    var groupWallpost:String {
        get{
            return "\(BaseUrl)/groupWallpost"
        }
    }
    
    
   
    
//MARK:-Spotify URL's
    var spotifyCategoriesURL:String {
        get{
            return "\(NewBaseUrl)/music-spotify/get-music-category"
        }
    }
    
    var spotifyCategoriesPlaylistURL:String {
        get{
            return "\(NewBaseUrl)/music-spotify/get-music-category-playlist"
        }
    }
    
    
    var spotifyTrackByPlaylistIdURL:String {
        get{
            return "\(NewBaseUrl)/music-spotify/get-music-track-by-play-list-id"
        }
    }
    var spotifySearchURL:String {
        get{
            return "\(NewBaseUrl)/music-spotify/get-music-search"
        }
    }
    
    //
    var getmusictokenURL:String {
        get{
            return "\(NewBaseUrl)/music-spotify/get-music-token"
        }
    }
    var featuredPlaylistURL:String {
        get{
            return "\(NewBaseUrl)/music-spotify/get-music-featured-playlist"
        }
    }
    
    var spotyNewReleaseURL:String {
        get{
            return "\(NewBaseUrl)/music-spotify/get-music-new-release"
        }
    }
    
    var spotifyRecommendationOnSeedURL:String {
        get{
            return "\(NewBaseUrl)/music-spotify/get-music-recommendation-on-seed "
        }
    }
    
    
    
    var spotifynewReleaseURL:String {
        get{
            return "\(BaseUrl)/spotifynewRelease"
        }
    }
    
   
   
    //Mark: - Jobs
    var getSuggestedJobsURL:String{
        
        get{
            return "\(NewBaseUrl)/job/get-suggested-jobs"
        }
        
    }
    
    var getjobformURL:String{
        
        get{
            return "\(NewBaseUrl)/job/get-job-form"
        }
        
    }
    
    var getJobSkillsURL:String{
        get{
            return "\(NewBaseUrl)/job/get-job-skills"
        }
    }
    
    
    var createJobURL:String{
        get{
            return "\(NewBaseUrl)/job/create-job"
        }
    }
    
    //
    var getPremiumBenefits:String{
        get{
            return "\(NewBaseUrl)/premium/premium-benefits"
        }
    }
    
     //MARK: Feeds New Socket
    let sio_feed_send_chat_message = "sio-feed-send-chat-message"
    let sio_feed_receive_chat_message = "sio-feed-receive-chat-message"
    let sio_feed_chat_typing = "sio-feed-chat-typing"
    let sio_feed_delete_user_chat = "sio-feed-delete-user-chat"
    let sio_feed_chat_acknowledge_chat =  "sio-feed-chat-acknowledge-message"
    let feed_chat_list =  "sio-feed-fetch-chat-list"
    let sio_feed_accept_chat_request = "sio-feed-accept-chat-request"
    let sio_fetch_user_info = "sio-fetch-user-info"
    let sio_feed_clear_user_chat_list = "sio-feed-clear-user-chat-list"
    let sio_feed_receive_new_user_list = "sio-feed-receive-new-user-list"
    let sio_feed_send_forward_message = "sio-feed-send-forward-message"
    let sio_change_online_offline_status = "sio-change-online-offline-status"
    let sio_fetch_online_offline_status  = "sio-fetch-online-offline-status"
    let sio_feed_fetch_user_chat_list:String = "sio-feed-fetch-user-chat-list"
    let sio_check_block_unblock_user:String = "sio-check-block-unblock-user"
    let socketConnected = "socketConnected"
    let sio_logout_from_all_device:String = "sio-logout-from-all-device"
    let sio_get_phone_contact:String = "sio-get-phone-contact"
    let socketCnnected = "socketCnnected"
    let socket_error =  "sio-feed-socket-error"
    let sc_feed_notification:String = "sc_feed_notification"
    let sc_feed_notification_ack:String = "sc_feed_notification_ack"
    
    //let AppGroupID = "group.com.PickZonGroup"
    
    let AppGroupID = "group.NHBQDLLJN4.com.PickZonGroup"
    let GoogleMapKey = "AIzaSyBJkky3R5AzhiINV-_WhxSCWYi4K69jyBU"
    let Connect:String = "connect"
    let network_disconnect:String = "disconnect"
    let network_error:String = "error"
    let create_user:String = "create_user"
    let usercreated:String = "usercreated"
    let userauthenticated:String = "userauthenticated"
  
    let sc_online_status:String = "getCurrentTimeStatus"
    let sc_change_online_status:String = "sc_change_online_status"
    let sc_uploadImage = "app"+"/"+"fileUpload"
    let getFilesizeInBytes = "app"+"/"+"getFilesizeInBytes"
    let remove_user:String = "remove_user"
    let qrdata:String = "qrdata"
    let sc_get_server_time:String = "sc_get_server_time"
    let sc_get_user_Details:String = "sc_get_user_Details"
    let checkMobileLoginKey:String = "checkMobileLoginKey"
    let updateMobilePushNotificationKey:String = "updateMobilePushNotificationKey"
    let updatelocation:String = "updatelocation"
    let sc_see_status:String = "sc_see_status"
    
    //MARK: For live streaming
 
    let sio_join_user_room  = "sio_join_user_room"
    let sio_leave_user_room = "sio_leave_user_room"
    let sio_get_join_user_list = "sio_get_join_user_list"
    let sio_send_comment_message = "sio_send_comment_message"
    let sio_get_comment_message_list = "sio_get_comment_message_list"
    let sio_like_live_broadcast = "sio_like_live_broadcast"
    let sio_get_user_info = "sio_get_user_info"
    let sio_get_all_live_friend_list = "sio_get_all_live_friend_list"
    let sio_live_pk_time_slot = "sio_live_pk_time_slot"
    let sio_get_live_join_user_count = "sio_get_live_join_user_count"
    let sio_send_live_pk_request = "sio_send_live_pk_request"
    let sio_get_all_user_pk_request_list  = "sio_get_all_user_pk_request_list"
    let sio_accept_live_pk_request  = "sio_accept_live_pk_request"
    let sio_reject_live_pk_request = "sio_reject_live_pk_request"
    let sio_start_live_pk = "sio_start_live_pk"
    let sio_get_live_pk_info = "sio_get_live_pk_info"
    let sio_exit_go_live_host_user = "sio_exit_go_live_host_user"
    let sio_get_all_live_user_list = "sio_get_all_live_user_list"
    let sio_pk_request_count = "sio_pk_request_count"
    let sio_kick_out = "sio_kick_out"
    let sio_send_gift_pk = "sio_send_gift_pk"
    let sio_block_user = "sio_block_user"
    let sio_pk_result = "sio_pk_result"
    let sio_feed_live_users = "sio_feed_live_users"
    let sio_top_gifters = "sio_top_gifters"
    let sio_get_live_status = "sio_get_live_status"
    let sio_play_random_pk = "sio_play_random_pk"
    let sio_leave_random_pk = "sio_leave_random_pk"
    let sio_report_live_pk = "sio_report_live_pk"
    let sio_restart_pk  = "sio_restart_pk"
    let sio_action_on_live = "sio_action_on_live"
    
    let sio_exit_force_live_user = "sio_exit_force_live_user"
    let sio_get_followers_live_list = "sio_get_followers_live_list"
    let sio_get_golive_endlive_user_info = "sio_get_golive_endlive_user_info"
    
    let sio_block_unblock_user_chat = "sio-block-unblock-user-chat"

    
    
    
    
    //Chat Entity Name
    let Chat_one_one:String="Chat_one_one"
    let Contact_add:String="Contact_add"
    let User_detail:String="User_detail"
    let isProfileInfoAvailable = "isProfileInfoAvailable"
    let Favourite_Contact:String = "Favourite_Contact"
    let Contact_details:String = "Contact_details"
    let Upload_Details:String = "Upload_Details"
    let Reply_detail:String = "Reply_detail"
    
    let Login_details:String = "Login_details"
    let BaseURL:String="BaseURL"
    let ImgBaseURL:String="\(Themes.sharedInstance.getURL())"
    
    //Notificationname
    let loaderdata:String="loaderdata"
    let reconnect: String = "reconnect"
    let qrResponse:String = "qrResponse"
    let reloadData = "reload_data"
    let pushView = "pushView"
    let RemoveActivity = "RemoveActivity"
    let VoicePlayHasInterrupt = "VoicePlayHasInterrupt"
    let NoContacts = "NoContacts"
    let getPageIndex = "getPageIndex"
    let getPageIndex1 = "getPageIndex1"
    
    let reconnectInternet: String = "reconnectInternet"
    let noInternet: String = "NoInternetConnection"
    
    let app_terminated = "app_terminated"
    let reloadFeedData = "reload_feed_data"
    
    let app_Background = "app_Background"
    let app_Foreground = "app_Foreground"
    let app_PausePlayer = "app_PausePlayer"

    //Error Message
    let ErrorMessage:String = "Network connection failed"
    
    //DelayTiming
    let UploadImageDelayTime:Int = 80
    let SocketWaitDelaytime:Int = 10
    let ContactCount:Int = 100
    let CallWaitTime:Int = 60
    let ConnectCallWaitTime:Int = 20
    
    //Split MultiformData
    let MultiFormDataSplitCount:Int = 7
    let VideoMultiFormDataSplitCount:Int = 30
    let UploadSize:Float = 15.0
    let DocumentUploadSize:Float = 30.0
    let SendbyteCount:Int = 30000
    let documentCompressionCount : Int = 5000000
    
    let photopath = Themes.sharedInstance.GetAppname() + "_photos"
    let videopathpath = Themes.sharedInstance.GetAppname() + "_video"
    let docpath = Themes.sharedInstance.GetAppname() + "_document"
    let voicepath = Themes.sharedInstance.GetAppname() + "_voice"
    let wallpaperpath = Themes.sharedInstance.GetAppname() + "_wallpaper"
    let statuspath = Themes.sharedInstance.GetAppname() + "_status"
        
    
    //Notification observer for socket
    let ScMessage = "ScMessage"
    let ScMessageResponse = "ScMessageResponse"
    
    var ShareText : String {
        get {
            return "Check out \(Themes.sharedInstance.GetAppname()) messenger for your smartphone. Download it today from \(Themes.sharedInstance.getURL())"
        }
    }
    
    let Subtext = "Check out \(Themes.sharedInstance.GetAppname()) messenger : iPhone+Android"
    
    let NavigationBarHeight_iPhoneX: CGFloat = 90
    let NavigationBarHeight: CGFloat = 70
    
    //Toggle encryption
    var isEncryptionEnabled:Bool = Bool()
    var razorpay_api_key: String = ""
}


//MARK:  Global Variable

var FontRoboto = "Roboto"
var FontRobotoItalic = "Roboto-Italic"
var FontRobotoLight = "Roboto-Light"
var FontRobotoLightItalic = "Roboto-LightItalic"
var FontRobotoBold = "Roboto-Bold"
var FontRobotoBoldItalic = "Roboto-BoldItalic"
var FontRobotoRegular = "Roboto-Regular"
var FontRobotoMedium = "Roboto-Medium"


struct FilterEffects {
    
    var isActive :Int =  1
    var title:String =  ""
    var icon:String =  ""
    var url: String = ""
    
    init(dict:Dictionary<String, Any>) {
        self.isActive = dict["isActive"] as? Int ?? 1
        self.title = dict["title"] as? String ?? ""
        self.icon = dict["icon"] as? String ?? ""
        self.url = dict["url"] as? String ?? ""
    }
}

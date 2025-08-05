//
//  SettingsApi.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/13/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import Foundation

public class Settings: NSObject {
   
    static let sharedInstance = Settings()
    var IsAppForceUpdate = 0
    var appLogo = ""
    var isVerifiedUser = 0
    var deviceLoggedCount = 0
    var isLeaderboard = 0
    var clipDuration:Double = 300
    var clipDurationCam:Double = 90
    var feedVideoDuration:Double = 300.0
    var feedVideoDurationCam:Double = 90
    var maxPostUpload = 5
    var statusDuration:Double = 45
    var maxStatusUpload = 5
    var confidenceThreshold:Double = 0.7
    var shareUrl = ""
    var usertype = 0
    var isCoinReferAvailable = 0
    var isCompressRequired = 1
    var isPickzonIdChange = 1
    var isSuperUser = 0
    var minBitrate = 3
    var isVerifiedMessage = ""
    var giftingLevelDesc = ""
    var deepARLicenseKey = "00d69096a5676fc63bf4c4d21910371afc0ba5f771140459876c9db3108971ccd10ea3df60ce8ce7"
    
    //userActivity: 1, // 0=user can't upload anything, 1= upload post, story, page-post, 2= upload post/story only, 3= upload page-post only
    var userActivity = 1
    var userActivityMessage = ""
    var warningDict:NSDictionary?
    var webLoginUrl = ""
    var profileUpdateConfigMsg = ""
    var isAppRatingAvailable = 0
    var isAgency = 0
    var isMobileVerified = 0
    var isEmailVerified = 0
    var isDownload = 0
    var isLiveAllowed = 0
    var isPassword = 0
    var auditionVideoEx = ""
    var isPremium = 0
    var goLiveStream = -1
    var pickzonIdChangeCharge = 0
    
    func initWithDict(payload:NSDictionary) {
        self.isSuperUser = payload["isSuperUser"] as? Int ?? 0
        self.minBitrate = payload["minBitrate"] as? Int ?? 3
        self.isCompressRequired = payload["isCompress"] as? Int ?? 1
        
        if let warningDict = payload["warning"] as? NSDictionary{
            self.warningDict = warningDict
            // self.openViolationPreview()
        }

        if let setting = payload["setting"] as? NSDictionary{
            self.clipDuration = setting["clipDuration"] as? Double ?? 60.0
            self.clipDurationCam = setting["clipDurationCam"] as? Double ?? 90
            self.maxPostUpload = setting["maxPostUpload"] as? Int ?? 5
            self.feedVideoDuration = setting["feedVideoDuration"] as? Double ?? 60.0
            self.feedVideoDurationCam = setting["feedVideoDurationCam"] as? Double ?? 90
            
            self.statusDuration = setting["statusDuration"] as? Double ?? 45.0
            self.maxStatusUpload = setting["maxStatusUpload"] as? Int ?? 5
        }
        self.isPremium = payload["isPremium"] as? Int ?? 0
        self.confidenceThreshold = payload["confidenceThreshold"] as? Double ?? 0.7
        self.usertype = payload["userType"] as? Int ?? 0
        self.webLoginUrl = payload["webLogin"] as? String ?? ""
        self.deepARLicenseKey = payload["deepARLicenseKey"] as? String ?? "00d69096a5676fc63bf4c4d21910371afc0ba5f771140459876c9db3108971ccd10ea3df60ce8ce7"
        
        self.auditionVideoEx = payload["auditionVideoEx"] as? String ?? ""

        
        if let goLiveURLs = payload["goLiveURLs"] as? NSDictionary{
            Constant.sharedinstance.rtmpPushUrl = goLiveURLs["originWS"] as? String ?? ""
            Constant.sharedinstance.rtmpPlayUrl = goLiveURLs["edgeWS"] as? String ?? ""
            print(Constant.sharedinstance.rtmpPushUrl)
            print(Constant.sharedinstance.rtmpPlayUrl)
        }
        /*if let logoStr = payload["appLogo"] as? String{
         self.setLogoWithDynamic(logoUrl: logoStr)
         }*/
        self.appLogo = payload["appLogo"] as? String ?? ""
        self.profileUpdateConfigMsg = payload["profileUpdateConfMsg"] as? String ?? ""
        self.deviceLoggedCount = payload["deviceLoggedCount"] as? Int ?? 0
        
        self.pickzonIdChangeCharge = payload["pickzonIdChangeCharge"] as? Int ?? 0
        self.isLeaderboard = payload["isLeaderboard"] as? Int ?? 0
        self.isAppRatingAvailable = payload["isAppRatingAvailable"] as? Int ?? 0
        self.isAgency = payload["isAgency"] as? Int ?? 0
        self.isMobileVerified = payload["isMobileVerified"] as? Int ?? 0
        self.isEmailVerified = payload["isEmailVerified"] as? Int ?? 0
        self.isDownload = payload["isDownload"] as? Int ?? 0
        self.isPassword = payload["isPassword"] as? Int ?? 0
        Themes.sharedInstance.savePickZonID(pickzonId: payload["pickzonId"] as? String ?? "")
        Themes.sharedInstance.saveIsReferAvailable(status: payload["isReferAvailable"] as? Int ?? 0)
        Themes.sharedInstance.saveIsCoinReferAvailable(status: payload["isCoinReferAvailable"] as? Int ?? 0)
        
        self.giftingLevelDesc = payload["giftingLevelDesc"] as? String ?? ""
        self.goLiveStream = payload["goLiveStream"] as? Int ?? -1
        self.isLiveAllowed = payload["isLiveAllowed"] as? Int ?? 0
        
        if let celebrity = payload["celebrity"] as? Int {
            
            self.isVerifiedUser = celebrity
            
            if let unverifiedUserMsg = payload["unverifiedUserMsg"] as? String {
                
                self.isVerifiedMessage = unverifiedUserMsg
            }
        }
        
        //userActivity: 1, // 0=user can't upload anything, 1= upload post, story, page-post, 2= upload post/story only, 3= upload page-post only
        self.userActivity =  payload["userActivity"] as? Int ?? 1
        self.userActivityMessage =  payload["userActivityMessage"] as? String ?? ""
        
        //To display the welcome popup
        let popUpUrl = payload["popup"] as? String ?? ""
        if popUpUrl.length > 0 {
            UserDefaults.standard.set(popUpUrl, forKey: "popUpUrl")
            UserDefaults.standard.set(true, forKey: "isDisplayWelcomePointAlert")
            //self.isDisplayWelcomePointAlert = true
            //self.showPromoAlert()
            //UserDefaults.standard.set(false, forKey: "isDisplayWelcomePointAlert")
        }else {
            
            UserDefaults.standard.set(false, forKey: "isDisplayWelcomePointAlert")
        }
        UserDefaults.standard.synchronize()
        
        
        if let profilePic = payload["profilePic"] as? String {
            
            if  profilePic.count > 0 {
                let user_ID = Themes.sharedInstance.Getuser_id()
                let CheckUser:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString:user_ID as String?)
                if (!CheckUser){
                    
                }else{
                    let UpdateDict:[String:Any]=["profilepic": profilePic]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail , FetchString: user_ID, attribute:"user_id" , UpdationElements: UpdateDict as NSDictionary?)
                }
                
                if let pickzonId = payload["pickzonId"] as? String {
                    guard let realm = DBManager.openRealm() else { return }
                    
                    try? realm.write{
                        
                        if let existingUser =  realm.object(ofType: DBUser.self, forPrimaryKey: user_ID) {
                            existingUser.pickzonId = pickzonId
                            existingUser.profilePic = profilePic
                            existingUser.celebrity =  self.isVerifiedUser
                        }
                    }
                    Themes.sharedInstance.savePickZonID(pickzonId: pickzonId)
                }
            }
        }
    }
}



//Added to test for git commit

//  AppDelegate.swift
//https://www.hackingwithswift.com/example-code/system/how-to-identify-an-ios-device-uniquely-with-identifierforvendor

import SwiftRater
import UIKit
import CoreData
import UserNotifications
import PushKit
import JSSAlertView
import Contacts
import SDWebImage
import Intents
import SwiftyGiphy
import GLNotificationBar
import Firebase
import IQKeyboardManager
import Alamofire
import MKVideoCacher
import SwiftyRSA
import SCIMBOEx
import BackgroundTasks
import Realm
import RealmSwift
import AVFoundation
import Kingfisher

var languageHandler = Languagehandler()
var filter_ContactRec = NSMutableArray()
var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid

@available(iOS 10.0, *)

@objc protocol AppDelegateDelegates : AnyObject {
    
    @objc optional  func ReceivedBuffer(Status : String, imagename : String)
    @objc optional  func ReceivedBuffer(Status: String, imagename: String, responseDict: NSDictionary)
    @objc optional  func passTurnMessage(payload : String)
    @objc optional  func receiveMessageInfo(response : [String : Any])
}

@available(iOS 10.0, *)
@UIApplicationMain



@objc class AppDelegate: NSObject,  UIApplicationDelegate, UNUserNotificationCenterDelegate {
@objc static let sharedInstance = UIApplication.shared.delegate as! AppDelegate
    var pageNo = 1
    @objc var window: UIWindow?
    let reachability = Reachability()!
    var IsInternetconnected:Bool=Bool()
    var byreachable : String = String()
    var isVideoViewPresented:Bool = Bool()
    var active:Bool = Bool()
    var navigationController : RootNavController?
    var currentOpponentId : String = String()
    weak var Delegate : AppDelegateDelegates?
    var notificationBar = GLNotificationBar()
    var IsKeyboardVisible = false
    var socketConnected:Bool=false
    var KeyboardFrame = CGRect.zero
    var seenArray: Array<String> = Array()
    var isUpdatingFeedsSeen = false
    var isSemaPhoreWaiting = false
    var sem = DispatchSemaphore(value: 0)
    var soundInfoSelected =  SoundInfo(dict: [:])
    
  
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Feeds")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    override init() {
        super.init()
    }

    //MARK: Realm Versionining
    func updateRealmVersioning(){
        
        let config = Realm.Configuration(
        // Set the new schema version. This must be greater than the previously used
        // version (if you've never set a schema version before, the version is 0).
        schemaVersion: 1,

        // Set the block which will be called automatically when opening a Realm with
        // a schema version lower than the one set above
        migrationBlock: { migration, oldSchemaVersion in
            // We haven’t migrated anything yet, so oldSchemaVersion == 0
            if (oldSchemaVersion < 1) {
                migration.enumerateObjects(ofType:"DBUser") { oldObject, newObject in
                   
                    newObject!["allGiftedCoins"] = 0
                    newObject!["avatar"] = ""
                    newObject!["angelsCount"] = "0"
                    newObject!["giftingLevel"] = ""
                    
//                    let totalFans = oldObject!["totalFans"] as? String ?? ""
//                    newObject!["totalFans"] = UInt(totalFans) ?? 0
//                    
//                    let totalFollowing = oldObject!["totalFollowing"] as? String ?? ""
//                    newObject!["totalFollowing"] = UInt(totalFollowing) ?? 0
//                    
//                    let totalPost = oldObject!["totalPost"] as? String ?? ""
//                    newObject!["totalPost"] = UInt(totalPost) ?? 0                    
                }
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    
    //MARK: - AppDelegate Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool{
        
        //Realm Versioning
        updateRealmVersioning()

        //To check and update the theme appearance
        window = UIWindow(frame: UIScreen.main.bounds)
        
        self.ReachabilityListener()
        
        SwiftRater.appID = "1560097730"
        SwiftRater.daysUntilPrompt = 7
        SwiftRater.usesUntilPrompt = 10
        SwiftRater.significantUsesUntilPrompt = 3
        SwiftRater.daysBeforeReminding = 7
        SwiftRater.showLaterButton = true
        SwiftRater.debugMode = false
        SwiftRater.appLaunched()
        
        /*for family: String in UIFont.familyNames
        {
            print(family)
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }*/
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        rootUSerApi()
        if Themes.sharedInstance.Getuser_id().length > 0{
            if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected)
            {
                SocketIOManager.sharedInstance.establishConnection(Nickname: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()) as NSString, isLogin: true)
            }
        }
        

        
       UIFont.overrideInitialize()
        
        setupKingfisherSettings()
        
        //Remove all saved audio files
        Themes.sharedInstance.removeallAudioFiles()
        
        application.setMinimumBackgroundFetchInterval(3600)
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        //UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalNever)
               
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
      
        FirebaseApp.configure()
        
    /*  

     UINavigationBar.appearance().tintColor = CustomColor.sharedInstance.newThemeColor/* Change tint color using Xcode default vales */
        UIBarButtonItem.appearance().tintColor = CustomColor.sharedInstance.newThemeColor
        UIToolbar.appearance().tintColor = CustomColor.sharedInstance.newThemeColor
        UITabBar.appearance().tintColor = CustomColor.sharedInstance.newThemeColor
        UITextField.appearance().tintColor = CustomColor.sharedInstance.newThemeColor
        UITextView.appearance().tintColor = CustomColor.sharedInstance.newThemeColor
      self.logUser()
     //Fabric.with([Crashlytics.self])
     Fabric.sharedSDK().debug = true

     */
        //Themes.sharedInstance.showWaitingNetwork(true, state: false)
        self.addNotificationListener()
        self.MovetoRooVC()
        Themes.sharedInstance.getCurrentLocationCountryCode()
       
        self.pushnotificationSetup()
     
        SwiftyGiphyAPI.shared.apiKey = SwiftyGiphyAPI.publicBetaKey
      
        NotificationCenter.default.addObserver(self, selector: #selector(self.sio_exit_go_live_host_user(notification:)),
                                               name: NSNotification.Name(rawValue: Constant.sharedinstance.sio_exit_go_live_host_user ), object: nil)
        
        
        return true
        
        
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        print("applicationDidReceiveMemoryWarning")
        KingfisherManager.shared.cache.clearCache()
        KingfisherManager.shared.cache.cleanExpiredMemoryCache()
        KingfisherManager.shared.cache.cleanExpiredDiskCache()
        
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        
        // remove all video Cached data
        do{
            try VideoCacheManager.cleanAllCache()
        }catch {
            
        }
    }
    
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        
    
        return true
    }

    //func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
    func application(
        _ application: UIApplication,
        shouldRestoreSecureApplicationState coder: NSCoder
    ) -> Bool{
        return true
    }

    
    func application(_ application: UIApplication, willEncodeRestorableStateWith coder: NSCoder) {
        // Encode any state information you want to preserve
    }

    func application(_ application: UIApplication, didDecodeRestorableStateWith coder: NSCoder) {
        // Decode and restore the preserved state
    }

   

    
    
    fileprivate func setupKingfisherSettings() {
       
        // Limit memory cache size to 300 MB.
        //KingfisherManager.shared.cache.memoryStorage.config.totalCostLimit = 300 * 1024 * 1024

        // Limit memory cache to hold 150 images at most.
        //KingfisherManager.shared.cache.memoryStorage.config.countLimit = 150
        
        // Limit disk cache size to 1 GB.
        //KingfisherManager.shared.cache.diskStorage.config.sizeLimit = 1000 * 1024 * 1024
      
        // Check memory clean up every 30 seconds.
        KingfisherManager.shared.cache.memoryStorage.config.cleanInterval = 5
        
        // ImageCache.default.diskStorage.config.expiration = .days(5)
       // KingfisherManager.shared.cache.cleanExpiredMemoryCache()
       // KingfisherManager.shared.cache.cleanExpiredDiskCache()
        
        // Constrain Disk Cache to 100 MB
        ImageCache.default.diskStorage.config.sizeLimit = 1024 * 1024 * 100
        
    }
    
    
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Msg Background")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
        if self.seenArray.count > 0 {
            self.updateFeedsSeenArrayNew()
        }
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game
        active = false
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.soloAmbient)
        } catch {
            print("AVAudioSessionCategorySoloAmbient not work")
        }
        print("applicationWillResignActive")
        PlayerHelper.shared.pause()
        
        NotificationCenter.default.post(Notification(name: Notification.Name(Constant.sharedinstance.app_PausePlayer)))
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        NotificationCenter.default.post(Notification(name: Notification.Name(Constant.sharedinstance.app_PausePlayer)))
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        PlayerHelper.shared.pause()
        
        
        backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler:{
            application.setMinimumBackgroundFetchInterval(3600)
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        })
        assert(backgroundTask != UIBackgroundTaskIdentifier.invalid)
        
        if Themes.sharedInstance.Getuser_id() != "" {
            SocketIOManager.sharedInstance.online(from: Themes.sharedInstance.Getuser_id(), status: "0")
            self.changeUserOnlineOfflineStatus(status: 0)
        }
        self.setBadgeCount()
        NotificationCenter.default.post(Notification(name: Notification.Name(Constant.sharedinstance.app_Background)))
        
        //Done to end background task so that app does not restart. 08 Apr 2024
        //self.endBackgroundTask()
    }
        
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
        
        PlayerHelper.shared.pause()
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        // To remove all pending notifications which are not delivered yet but scheduled.
        center.removeAllDeliveredNotifications()
        self.endBackgroundTask()
        self.setBadgeCount()
        // To remove all delivered notifications
        SocketIOManager.sharedInstance.socket.connect()
        
        NotificationCenter.default.post(Notification(name: Notification.Name(Constant.sharedinstance.app_Foreground)))

    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        PlayerHelper.shared.pause()
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //player?.stop()
        let state = UIApplication.shared.applicationState
        if(state == .active)
        {
            
            if Themes.sharedInstance.Getuser_id() != "" {
                
                self.changeUserOnlineOfflineStatus(status: 1)

                
                if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected)
                {
                    if(IsInternetconnected)
                    {
                        self.IntitialiseSocket()
                        
                    }
                }else  if(SocketIOManager.sharedInstance.socket.status == .connected )
                {
                    SocketIOManager.sharedInstance.online(from: Themes.sharedInstance.Getuser_id(), status: "1")
                    
                }
            }
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }
    
    func application(
      _ application: UIApplication,
      continue userActivity: NSUserActivity,
      restorationHandler: @escaping ([UIUserActivityRestoring]?
    ) -> Void) -> Bool {
        print(" UIApplication, continue userActivity")
       
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            
            let myUrl: String? = userActivity.webpageURL?.absoluteString
            let urlArray = myUrl?.components(separatedBy: "/")
            if Themes.sharedInstance.Getuser_id().count > 0 {
                if myUrl?.range(of: "/post/") != nil {
                    if AppDelegate.sharedInstance.navigationController?.topViewController?.isKind(of: WallPostViewVC.self) == true {
                        self.navigationController?.popViewController(animated: false)
                    }
                    let postId = urlArray?.last ?? ""
                    let vc = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
                    vc.postId = postId
                    vc.controllerType = .isFromNotification
                    self.navigationController?.pushView(vc, animated: true)
                }
                
               /* else if myUrl?.range(of: "/clip/") != nil {
                    
                }*/
                else if myUrl?.range(of: "/profile/") != nil {
                    if AppDelegate.sharedInstance.navigationController?.topViewController?.isKind(of: ProfileVC.self) == true {
                        self.navigationController?.popViewController(animated: false)
                    }
                    let userId = urlArray?.last ?? ""
                    let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                    profileVC.otherMsIsdn = userId
                    self.navigationController?.pushView(profileVC, animated: true)
               /* } else if myUrl?.range(of: "/page/") != nil {
                   
                }else if myUrl?.range(of: "/group/") != nil {
                */
                }else if myUrl?.range(of: "/golive/") != nil {
                    let userId = urlArray?.last ?? ""
                    let destVc:PKAudienceVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "PKAudienceVC") as! PKAudienceVC
                    destVc.leftRoomId = userId
                    self.navigationController?.pushView(destVc, animated: true)
                    
                }else if myUrl?.range(of: "/pkgolive/") != nil {
                    let mergedIdArr = (urlArray?.last ?? "").components(separatedBy: "_")

                    if mergedIdArr.count > 2{
                        let destVc:PKAudienceVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "PKAudienceVC") as! PKAudienceVC
                        destVc.leftRoomId = mergedIdArr.first ?? ""
                        destVc.rightRoomId = mergedIdArr[1]
                        destVc.livePKId = mergedIdArr.last ?? ""
                        self.navigationController?.pushView(destVc, animated: true)
                    }
                }
            }
        }else{
            
        }

        return true
    }
    
   
    
   
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url)
        if url == URL.init(string: "pickzon://") {
            var CheckLogin = false
            if(Themes.sharedInstance.Getuser_id() != "")
            {
                CheckLogin = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
            }
            
            let isProfileInfoAvailable = UserDefaults.standard.bool(forKey:Constant.sharedinstance.isProfileInfoAvailable)
            
            if(CheckLogin && isProfileInfoAvailable == true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    Themes.sharedInstance.isSharingData = false
                    let destVc:CreateWallPostViewController = StoryBoard.feeds.instantiateViewController(withIdentifier: "CreateWallPostViewController") as! CreateWallPostViewController
                    destVc.isSharingData = true
                    destVc.uploadDelegate = self
                    self.navigationController?.pushView(destVc, animated: true)
                }
                
            }else {
                Themes.sharedInstance.isSharingData = true
            }
        }
        
        //Google Sign in
      /*  var handled: Bool
          handled = GIDSignIn.sharedInstance.handle(url)
          if handled {
            return true
          }*/

        
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
        PlayerHelper.shared.pause()
        NotificationCenter.default.post(Notification(name: Notification.Name(Constant.sharedinstance.app_PausePlayer)))
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
                
        NotificationCenter.default.post(Notification(name: Notification.Name(Constant.sharedinstance.app_terminated)))
       
       
        if self.seenArray.count > 0 {
            self.updateFeedsSeenArrayNew()
        }
        
        if Themes.sharedInstance.Getuser_id() != "" {
            
            sem = DispatchSemaphore(value: 0)
            isSemaPhoreWaiting = true
          /*  if Settings.sharedInstance.isLiveAllowed == 1{
                let param = ["authToken": Themes.sharedInstance.getAuthToken(),"roomId":Themes.sharedInstance.Getuser_id(),"type":"0"] as [String : Any]
                SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_exit_go_live_host_user, param)
            }
            */
            SocketIOManager.sharedInstance.online(from: Themes.sharedInstance.Getuser_id(), status: "0")
            
                        
             if self.currentOpponentId.count > 0{
                let param = [
                    "authToken": Themes.sharedInstance.getAuthToken(),
                    "roomId":  AppDelegate.sharedInstance.currentOpponentId
                ]
                SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_leave_user_room, param)
                self.currentOpponentId = ""
            }
            
          //  SocketIOManager.sharedInstance.socket.disconnect()

            sem.wait()
            
        }
    }
    
    
    @objc func sio_exit_go_live_host_user(notification: Notification) {
        if isSemaPhoreWaiting == true {
            sem.signal()//When task complete then signal will call
        }
    }
    
    
    
    //MARK: - Apple Push Notification Methods
    func application(_ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
         print("Token: \(token)")
         Themes.sharedInstance.saveDeviceToken(DeviceToken: token)
         
         Messaging.messaging().apnsToken = deviceToken
         print("------------\(deviceToken)")
        
        Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
        
}
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("I am not available in simulator \(error)")
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //OTP handling through firebase
        if Auth.auth().canHandleNotification(userInfo) {
          completionHandler(.noData)
          return
        }
    }
    
    
    func setBadgeCount(){
        
        UIApplication.shared.applicationIconBadgeNumber = Constant.sharedinstance.requestedChatCount + Constant.sharedinstance.feedChatCount
    }
    
    func endBackgroundTask(){
        PlayerHelper.shared.pause()
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskIdentifier.invalid
    }
    
    func addNotificationListener() {
        addcontactChangeobserver()
    }
    
 
    
    func addcontactChangeobserver()
    {
        var CheckLogin = false
        if(Themes.sharedInstance.Getuser_id() != "")
        {
            CheckLogin = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
        }
        if(CheckLogin)
        {
            ContactHandler.sharedInstance.GetPermission()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateContact(_:)), name: .CNContactStoreDidChange, object: nil)
    }
    
    
    @objc func updateContact(_ notify: Notification)
    {
        print("updateContact Called")
        
        //self.IntitialiseSocket()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            self.addcontactChangeobserver()
        }
        DispatchQueue.global(qos: .background).async {
            if(!ContactHandler.sharedInstance.StorecontactInProgress)
            {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.StoreContacts), object: nil)
                self.perform(#selector(self.StoreContacts), with: nil, afterDelay: 0.0)
                NotificationCenter.default.removeObserver(self, name: .CNContactStoreDidChange, object: nil)
            }
        }
    }
    
    @objc func StoreContacts()
    {
       print("StoreContacts Called")
        if(SocketIOManager.sharedInstance.socket.status == .connected ) {
            var CheckLogin = false
            if(Themes.sharedInstance.Getuser_id() != "")
            {
                CheckLogin = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
            }
            if(CheckLogin)
            {
                ContactHandler.sharedInstance.StoreContacts()
            }
        }else {
            NotificationCenter.default.addObserver(self, selector: #selector(self.socketConnected(notification:)), name: NSNotification.Name(rawValue: Constant.sharedinstance.socketCnnected), object: nil)
            
            self.IntitialiseSocket()
        }
    }
    
    @objc func socketConnected(notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.sharedinstance.socketCnnected), object: nil)
        self.StoreContacts()
    }
    
    
    
    func logUser() {
        if(Themes.sharedInstance.Getuser_id() != "")
        {
//            Crashlytics.sharedInstance().setUserIdentifier(Themes.sharedInstance.Getuser_id())
//            Crashlytics.sharedInstance().setUserName(Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), ""))
//            Crashlytics.sharedInstance().setUserEmail(Themes.sharedInstance.GetMyPhonenumber())
        }
    }
    
        
    
    func waitingForNetwork(_ isNetwork:Bool , state:Bool){
        
        if((self.navigationController?.topViewController?.isKind(of: LoginVCNew.self))!  || (self.navigationController?.topViewController?.isKind(of: ProfileInfoViewController.self))!){
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                    for view in (AppDelegate.sharedInstance.window?.subviews)! where view.tag == 12 {
                        view.removeFromSuperview()
                    }
                }) { success in
                }
            }
        }else
        {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                    for view in (AppDelegate.sharedInstance.window?.subviews)! where view.tag == 12 {
                        view.removeFromSuperview()
                    }
                }) { success in
                }
            }
            var height:CGFloat = 0
            if UIDevice.isIphoneX {
                height = Constant.sharedinstance.NavigationBarHeight_iPhoneX
            } else {
                height = Constant.sharedinstance.NavigationBarHeight
            }
            if isNetwork {
                if !state {
                    /*
                    DispatchQueue.main.async {
                        let nibView = Bundle.main.loadNibNamed("ConnectingView", owner: self, options: nil)![0] as! ConnectingView
                        nibView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
                        nibView.hint_lbl.text = "Waiting for network.."
                        nibView.activity_view.startAnimating()
                        nibView.alpha = 0.0
                        nibView.tag = 12
                        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                            nibView.alpha = 1.0
                            AppDelegate.sharedInstance.window?.addSubview(nibView)
                        }) { success in
                        }
                    }
                    */
                }else{
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                            for view in (AppDelegate.sharedInstance.window?.subviews)! where view.tag == 12 {
                                view.removeFromSuperview()
                            }
                        }) { success in
                        }
                    }
                }
            }else{
                if !state {
                    
                    /*
                    DispatchQueue.main.async {
                        let nibView = Bundle.main.loadNibNamed("ConnectingView", owner: self, options: nil)![0] as! ConnectingView
                        nibView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
                        nibView.hint_lbl.text = "Connecting.."
                        nibView.activity_view.startAnimating()
                        nibView.alpha = 0.0
                        nibView.tag = 12
                        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                            nibView.alpha = 1.0
                            AppDelegate.sharedInstance.window?.addSubview(nibView)
                        }) { success in
                        }
                    }*/
                }else{
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                            for view in (AppDelegate.sharedInstance.window?.subviews)! where view.tag == 12 {
                                view.removeFromSuperview()
                            }
                        }) { success in
                        }
                    }
                }
            }
        }
    }
    
    
    func setNotificationSound(){
        
       /* let CheckSettings:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Notification_Setting, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
        if(CheckSettings)
        {
            let NotificationArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Notification_Setting, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! NSArray
            for i in 0..<NotificationArr.count
            {
                let objRecord:NSManagedObject = NotificationArr[i] as! NSManagedObject
                let group_sound:String = objRecord.value(forKey: "group_sound") as! String
                let  is_sound = objRecord.value(forKey: "is_sound")  as! Bool
                
                let is_vibrate = objRecord.value(forKey: "is_vibrate")  as! Bool
                let single_sound = objRecord.value(forKey: "single_sound") as! String
                let iShowSingleNotification = objRecord.value(forKey: "is_show_notification_single") as! Bool
                let iShowgroupNotification = objRecord.value(forKey: "is_show_notification_group")  as! Bool
                if(is_sound)
                {
                    if(chat_type == "single" || chat_type == "secret")
                    {
                        if(iShowSingleNotification)
                        {
                            let GetSoundID:UInt32 = UInt32(single_sound)!
                            playNotificationSound(vibrate: is_vibrate, systemSound: UInt(GetSoundID))
                        }
                    }
                    else  if(chat_type == "group")
                    {
                        if(iShowgroupNotification)
                        {
                            let GetSoundID:UInt32 = UInt32(group_sound)!
                            playNotificationSound(vibrate: is_vibrate, systemSound: UInt(GetSoundID))
                        }
                    }
                }
                else if(is_vibrate)
                {
                    playNotificationSound(vibrate: is_vibrate, systemSound: 0)
                }
                else
                {
                    playNotificationSound(vibrate: is_vibrate, systemSound: 0)
                }
                
            }
        }
        */
    }
    
    func playNotificationSound(vibrate : Bool, systemSound:UInt)
    {
        if vibrate {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        }
        if(systemSound == 0){
            
        }else{
            AudioServicesPlaySystemSound(SystemSoundID(systemSound));
            
        }
    }
    
    
    @objc func userDeleted(){
        let alertview = JSSAlertView().show(
            (self.navigationController?.topViewController)!,
            title: Themes.sharedInstance.GetAppname(),
            text: "Your account has been deleted by admin.",
            buttonText: "Ok",
            cancelButtonText: nil
        )
        alertview.addAction {
            self.Logout(istocallApi: true)
        }
       // alertview.addAction(self.Logout)
    }
    
    @objc func userCleared(){
        let alertview = JSSAlertView().show(
            (self.navigationController?.topViewController)!,
            title: Themes.sharedInstance.GetAppname(),
            text: "Your have been logged out by admin.",
            buttonText: "Ok",
            cancelButtonText: nil
        )
      //  alertview.addAction(self.Logout)
        alertview.addAction {
            self.Logout(istocallApi: true)

        }
    }
    
    
    // MARK: - PKPushRegistryDelegate
    
    
    func SockedConnected(isConnected: Bool){
        
      /* var status = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "status")
        if(status != "")
        {
            status = Themes.sharedInstance.base64ToString(status)
        }
      //  SocketIOManager.sharedInstance.changeStatus(status: status, from:Themes.sharedInstance.Getuser_id())
        
        if(responseDict.allKeys.count > 0)
        {
            SocketIOManager.sharedInstance.EmitGetCallStatus(param: responseDict as! [String : Any])
        }
        
        if(callactivity != nil)
        {
            self.launchActivity(callactivity!)
            callactivity = nil
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: ["hit" : "1"] , userInfo: nil)*/
    }
    
    
   
    func PlayAudio(tone: String, type: String, isrepeat : Bool = true){
      /*  let session = AVAudioSession.sharedInstance()

        if(!isVideoViewPresented) {
            try? session.setCategory(AVAudioSession.Category.playAndRecord)
            
            try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            
            try? session.setActive(true)
        }
        
        let path = Bundle.main.path(forResource: tone, ofType:type)!
        let url = URL(fileURLWithPath: path)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = isrepeat ? -1 : 0
            player?.prepareToPlay()
            player?.volume = 10.0
            player?.play()
        } catch
        {
            print("error loading file")
            // couldn't load file :(
        }*/
        
    }
    
    func updateLatestAppearance() {
        var enumVal = UserDefaults.standard.value(forKey: darkModeSettings) as? Int ?? 0
        //First time if there is no theme selected than select dark theme by default
        if enumVal == 0 {
            enumVal = 1
            UserDefaults.standard.setValue(1, forKey: darkModeSettings)
            UserDefaults.standard.synchronize()
        }
        
        if enumVal == 1 {
            AppDelegate.sharedInstance.window?.overrideUserInterfaceStyle = .dark
        }else if enumVal == 2 {
            AppDelegate.sharedInstance.window?.overrideUserInterfaceStyle = .light
        }
    }
    
   /*func updateAppearance(){
        var enumVal:Int = 3
        if AppDelegate.sharedInstance.window?.traitCollection.userInterfaceStyle == .dark {
            print("Appearance updated: dark Mode")
        enumVal = 1
        }else if AppDelegate.sharedInstance.window?.traitCollection.userInterfaceStyle == .light {
            print("Appearance updated: Light Mode")
            enumVal = 2
        }else if AppDelegate.sharedInstance.window?.traitCollection.userInterfaceStyle == .unspecified {
            print("Appearance updated: Unspecified Mode")
            enumVal = 3
        }
        UserDefaults.standard.setValue(enumVal, forKey: darkModeSettings)
        UserDefaults.standard.synchronize()
    }*/
    
   
    func MovetoRooVC(){
        
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        navigationController = mainStoryBoard.instantiateViewController(withIdentifier: "RootNavControllerID") as? RootNavController
        navigationController?.navigationBar.isHidden = true
    
        var CheckLogin = false
        if(Themes.sharedInstance.Getuser_id() != "")
        {
            CheckLogin = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
        }
        
        let isProfileInfoAvailable = UserDefaults.standard.bool(forKey:Constant.sharedinstance.isProfileInfoAvailable)
       
        self.updateLatestAppearance()
        
        if(CheckLogin && isProfileInfoAvailable == true){
                
            let updateChecker : ATAppUpdater =  ATAppUpdater.sharedUpdater() as! ATAppUpdater
            updateChecker.delegate = self
            updateChecker.showUpdateWithForce()

            let name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.photopath);
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.videopathpath);
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.docpath);
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.voicepath);
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.wallpaperpath)
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.statuspath);

            let user_dict:NSDictionary = ["current_call_status":0,"call_id":""]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: user_dict)

            SDWebImageDownloader.shared().setValue(Themes.sharedInstance.getToken(), forHTTPHeaderField: "authorization")
            SDWebImageDownloader.shared().setValue(Themes.sharedInstance.Getuser_id(), forHTTPHeaderField: "userid")
            SDWebImageDownloader.shared().setValue("site", forHTTPHeaderField: "requesttype")
            SDWebImageDownloader.shared().setValue(ImgUrl, forHTTPHeaderField: "referer")
           
            
            if(name != ""){
                let signinVC = mainStoryBoard.instantiateViewController(withIdentifier: "HomeBaseViewController") as! HomeBaseViewController
                navigationController?.viewControllers = [signinVC]
                self.window?.setRootViewController(self.navigationController!, options: .init(direction: .fade, style: .easeOut))
            }else{
                let signinVC = StoryBoard.prelogin.instantiateViewController(withIdentifier: "ProfileInfoID") as! ProfileInfoViewController
                navigationController?.viewControllers = [signinVC]
                self.window?.setRootViewController(self.navigationController!, options: .init(direction: .fade, style: .easeOut))
            }
        }
        else
        {
            /*let signinVC = mainStoryBoard.instantiateViewController(withIdentifier: "LoginVCID") as! LoginVC
            navigationController?.viewControllers = [signinVC]
            self.window?.setRootViewController(self.navigationController!, options: .init(direction: .fade, style: .easeOut))*/
            
            let signinVC = StoryBoard.prelogin.instantiateViewController(withIdentifier: "LoginVCNew") as! LoginVCNew
            navigationController?.viewControllers = [signinVC]
            self.window?.setRootViewController(self.navigationController!, options: .init(direction: .fade, style: .easeOut))
        }
    }
    

    func pushnotificationSetup(){
        registerForNotifications()
        setBadgeCount()
    }
    
    func ReachabilityListener()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        if reachability.isReachable {
            IsInternetconnected=true
          //  Themes.sharedInstance.showWaitingNetwork(true, state: true)
            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
                byreachable = "1"
            } else {
                print("Reachable via Cellular")
                byreachable = "2"
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reconnectInternet), object: nil , userInfo: nil)
        } else {
            IsInternetconnected=false
            //Themes.sharedInstance.showWaitingNetwork(true, state: false)
            print("Network not reachable")
            byreachable = ""
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.noInternet), object: nil , userInfo: nil)
        }
    }
    
    
    
    
    @objc func IntitialiseSocket(){
        if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected)
        {
            if(IsInternetconnected)
            {
                SocketIOManager.sharedInstance.establishConnection(Nickname: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()) as NSString, isLogin: true)
                
            }
        }
        
    }

}

extension AppDelegate:MessagingDelegate{
   
    //MARK: -  Getting FCM Token
    func registerForNotifications(){
        if #available(iOS 10.0, *)
        {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {(stat,err) in })
            Messaging.messaging().delegate = self
            
            //**********//
            let openAction = UNNotificationAction(identifier: "OpenNotification", title: NSLocalizedString("PickZon", comment: ""), options: UNNotificationActionOptions.foreground)
            let deafultCategory = UNNotificationCategory(identifier: "content_added_notification", actions: [openAction], intentIdentifiers: [], options: [])
            UNUserNotificationCenter.current().setNotificationCategories(Set([deafultCategory]))
            
            // ************** //
        }else{
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
  
    
    //MARK: - Notifications Handlers
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage){
        print("Message ---- \(remoteMessage)")
    }
        
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String)
    {
        print("fcm ---------\(fcmToken)")
        UserDefaults.standard.set(fcmToken, forKey: "fcm_token")
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("NOTIFICATION TAPPED === \(response.notification.request.content.userInfo)")
        
        if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected)
        {
            SocketIOManager.sharedInstance.establishConnection(Nickname: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()) as NSString, isLogin: true)
        }
    
        
        var  notificationType =  response.notification.request.content.userInfo["gcm.notification.notificationType"] as? String ?? ""
        var  userId =  response.notification.request.content.userInfo["gcm.notification.userId"] as? String ?? ""
        var  listingId =  response.notification.request.content.userInfo["gcm.notification.listingId"] as? String ?? ""
        
        
        if let notificationTypes =  response.notification.request.content.userInfo["notificationType"] as? String{
            
            notificationType = notificationTypes
        }
        
        if let userIds =  response.notification.request.content.userInfo["userId"] as? String{
            userId = userIds
        }
        
        if let listingIds =  response.notification.request.content.userInfo["listingId"] as? String{
            listingId = listingIds
        }
        
        if self.navigationController?.topViewController is BroadcasterViewController{
            //Because you are on live
          return
        }
        
        switch notificationType{
                    
        case "refer":
            let destVC:ReferalsViewController = StoryBoard.feeds.instantiateViewController(withIdentifier: "ReferalsViewController") as! ReferalsViewController
            self.navigationController?.pushViewController(destVC, animated: true)
            
        case "profile":
            
            if  (self.navigationController?.topViewController?.isKind(of: ProfileVC.self)) == false{
                let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                profileVC.otherMsIsdn = userId
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
        case  "followingUser","followUser","following_you":
            
            if (self.navigationController?.topViewController?.isKind(of: ProfileVC.self) == false){
                let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                profileVC.otherMsIsdn = userId
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
        case "request","requestedUser":
            
            if (self.navigationController?.topViewController?.isKind(of: SuggestionListVC.self) == false){
                let viewController:SuggestionListVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "SuggestionListVC") as! SuggestionListVC
                viewController.isSuggestedSelected = false
                viewController.isContactSelected = false
                viewController.isRequestSelected = true
                self.navigationController?.pushView(viewController, animated: true)
            }
        case  "live":
            
            if (self.navigationController?.topViewController?.isKind(of: BroadcasterViewController.self) == false){
                self.IntitialiseSocket()
                let vc = StoryBoard.letGo.instantiateViewController(withIdentifier: "BroadcasterViewController") as! BroadcasterViewController
                // vc.from = userId
                self.navigationController?.pushView(vc, animated: true)
            }
            
        case "feedChat":
            if let destVc = self.navigationController?.topViewController as? FeedChatVC{
                
                if destVc.toChat == userId{
                    
                }else{
                    self.navigationController?.popViewController(animated: false)
                    let vc = StoryBoard.chat.instantiateViewController(withIdentifier: "FeedChatVC") as! FeedChatVC
                    vc.toChat = userId
                    vc.fcrId = listingId
                    vc.fromName = ""
                    self.navigationController?.pushView(vc, animated: true)
                }
            }else{
                let vc = StoryBoard.chat.instantiateViewController(withIdentifier: "FeedChatVC") as! FeedChatVC
                vc.toChat = userId
                vc.fcrId = listingId
                vc.fromName = ""
                self.navigationController?.pushView(vc, animated: true)
            }
        case "feed","post","postLike","postComment","postCommentLike","pagePost","pagePostLike","pagePostComment","pagePostCommentLike":
            if self.navigationController?.topViewController is WallPostViewVC{
                
                self.navigationController?.popViewController(animated: false)
            }
            
            let vc = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
            vc.postId = userId
            vc.controllerType = .isFromNotification
            self.navigationController?.pushView(vc, animated: true)
 
        case "referral":
            if (self.navigationController?.topViewController?.isKind(of: ReferalsViewController.self) == false){
                let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "ReferalsViewController") as! ReferalsViewController
                self.navigationController?.pushView(vc, animated: true)
            }
     
        case "leaderboard":
            let viewController = StoryBoard.premium.instantiateViewController(withIdentifier: "LeaderBoardVC") as! LeaderBoardVC
            viewController.isLastMonth = true
            self.navigationController?.pushView(viewController, animated: true)
        case "goLive":
            if self.navigationController?.topViewController is BroadcasterViewController{
                
                
            }else if let destVc = self.navigationController?.topViewController as? PKAudienceVC{
                
                if destVc.leftRoomId == userId{
                    
                }else{
                    self.navigationController?.popViewController(animated: false)
                    let destVc:PKAudienceVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "PKAudienceVC") as! PKAudienceVC
                    destVc.leftRoomId = userId
                    destVc.is_FROM_NOTIFICATION = true
                    self.navigationController?.pushView(destVc, animated: true)

                }
            }else{
                let destVc:PKAudienceVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "PKAudienceVC") as! PKAudienceVC
                destVc.leftRoomId = userId
                destVc.is_FROM_NOTIFICATION = true
                self.navigationController?.pushView(destVc, animated: true)
            }
            
        case "pkLive":
            
            let userIdArray = listingId.components(separatedBy: ",")
            
            if userIdArray.count > 1{
                if self.navigationController?.topViewController is BroadcasterViewController{
                    
                    
                }else if let destVc = self.navigationController?.topViewController as? PKAudienceVC{
                    
                    if destVc.livePKId == userId {
                        
                        
                    }else{
                        self.navigationController?.popViewController(animated: false)
                        let destVc:PKAudienceVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "PKAudienceVC") as! PKAudienceVC
                        destVc.leftRoomId = userIdArray.first ?? ""
                        destVc.rightRoomId = userIdArray[1]
                        destVc.livePKId = userId
                        destVc.is_FROM_NOTIFICATION = true
                        self.navigationController?.pushView(destVc, animated: true)
                    }
                }else{
                    let destVc:PKAudienceVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "PKAudienceVC") as! PKAudienceVC
                    destVc.leftRoomId = userIdArray.first ?? ""
                    destVc.rightRoomId = userIdArray[1]
                    destVc.livePKId = userId
                    destVc.is_FROM_NOTIFICATION = true
                    self.navigationController?.pushView(destVc, animated: true)
                }
            }
            
        case "live-access":
            let destVc:GoLiveVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "GoLiveVC") as! GoLiveVC
            Settings.sharedInstance.isLiveAllowed = 1
            self.navigationController?.pushView(destVc, animated: true)
            
        case "scheduledPk":
            let destVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "AgencyPkVC") as! AgencyPkVC
            self.navigationController?.pushView(destVC, animated: true)

        default:
            break
        }
        
        print(response.notification.request.identifier)
        print(response.notification.request.identifier)
        print(response.notification.request.content.userInfo)
        print("Tapped in notification")
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void)
    {
        //Handle the notification
        completionHandler(
            [UNNotificationPresentationOptions.alert,
             UNNotificationPresentationOptions.sound,
             UNNotificationPresentationOptions.badge])
    }
    
    //This is key callback to present notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //print("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications
       // print(notification.request.content.userInfo)
        
        if notification.request.identifier == "VideoCallRequest"{
            
            completionHandler( [.alert,.sound,.badge])
            
        }else {
            print(notification.request.content)
            // completionHandler( [.alert,.sound,.badge])
            // let  notificationType =  notification.request.content.userInfo["gcm.notification.notificationType"] as? String ?? ""
            let  userId =  notification.request.content.userInfo["gcm.notification.userId"] as? String ?? ""
            // let  listingId =  notification.request.content.userInfo["gcm.notification.listingId"] as? String ?? ""
            
            if ((self.navigationController?.topViewController?.isKind(of: FeedChatVC.self)) != nil) && Themes.sharedInstance.chattingUSerId == userId {
            }else{
                completionHandler( [.alert,.sound,.badge])
            }
        }
        
        let media = notification.request.content.userInfo["media"] ?? ""
        if (media as AnyObject).length > 0 {
            completionHandler([.alert, .badge, .sound])
        }
        
        //Count on feed page
        SocketIOManager.sharedInstance.emitChatAndNotificationCount(userId: Themes.sharedInstance.Getuser_id())
    }
    
    
    func OpenAudience(Delay:Double,id:String){
       
    }
}


extension AppDelegate : ATAppUpdaterDelegate{
    
    func appUpdaterDidShowUpdateDialog(){
        
    }
    func appUpdaterUserDidLaunchAppStore(){

    }
    
    func appUpdaterUserDidCancel(){
        
    }
    
    //MARK: Api Methods

    func Logout(istocallApi:Bool = true){
        if istocallApi{
            logoutApi()
        }
        //update the appearance setting to dark
        UserDefaults.standard.setValue(1, forKey: darkModeSettings)
        self.updateLatestAppearance()
        
        Constant.sharedinstance.feedChatCount = 0
        Constant.sharedinstance.notificationCount = 0
        UIApplication.shared.applicationIconBadgeNumber = 0
        UIApplication.shared.unregisterForRemoteNotifications()
        SocketIOManager.sharedInstance.online(from: Themes.sharedInstance.Getuser_id(), status: "0")
        
        KeychainService.removePassword()
        Themes.sharedInstance.savepublicKey(DeviceToken: "")
        Themes.sharedInstance.savesPrivatekey(DeviceToken: "")
        Themes.sharedInstance.savesecurityToken(DeviceToken: "")
        
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        //remove the isuser profile available
        UserDefaults.standard.setValue(false, forKey: Constant.sharedinstance.isProfileInfoAvailable)
        UserDefaults.standard.synchronize()

       // let Dict:NSDictionary = ["from":Themes.sharedInstance.Getuser_id()]
       // SocketIOManager.sharedInstance.mobileToWebLogout(Param: Dict as! [String : Any])
        
      //  SocketIOManager.sharedInstance.LeaveRoom(providerid: Themes.sharedInstance.Getuser_id())
        
        SocketIOManager.sharedInstance.socket.removeAllHandlers()
        SocketIOManager.sharedInstance.socket.disconnect()

        DispatchQueue.main.async {
            let entities = [Constant.sharedinstance.Chat_one_one,
                            Constant.sharedinstance.Contact_add,
                            Constant.sharedinstance.User_detail,
                            Constant.sharedinstance.Favourite_Contact,
                            Constant.sharedinstance.Contact_details,
                            Constant.sharedinstance.Upload_Details,
                            Constant.sharedinstance.Reply_detail,
                            Constant.sharedinstance.Login_details
                            ]
            
            DatabaseHandler.sharedInstance.truncateDataForTables(entities)
            
            Filemanager.sharedinstance.DeleteFile(foldername: Constant.sharedinstance.photopath)
            Filemanager.sharedinstance.DeleteFile(foldername: Constant.sharedinstance.videopathpath)
            Filemanager.sharedinstance.DeleteFile(foldername: Constant.sharedinstance.docpath)
            Filemanager.sharedinstance.DeleteFile(foldername: Constant.sharedinstance.voicepath)
            Filemanager.sharedinstance.DeleteFile(foldername: Constant.sharedinstance.wallpaperpath)
            Filemanager.sharedinstance.DeleteFile(foldername: Constant.sharedinstance.statuspath)

           // UIApplication.shared.applicationIconBadgeNumber = Themes.sharedInstance.getUnreadChatCount(true)
            
            UIApplication.shared.applicationIconBadgeNumber = Constant.sharedinstance.requestedChatCount + Constant.sharedinstance.feedChatCount

           
            //Deleteing previous fcm token
            let instance = InstanceID.instanceID()
            instance.deleteID { (error) in
                print(error.debugDescription)
            }
            
            //Firebase authentication logout
            let firebaseAuth = Auth.auth()
            do {
              try firebaseAuth.signOut()
            } catch let signOutError as NSError {
              print("Error signing out: %@", signOutError)
            }
            
            //show first time email verifcation alert if email is not verified
            UserDefaults.standard.setValue(true, forKey: "showVerifyEmailPopup")
            UserDefaults.standard.synchronize()
            
            self.MovetoRooVC()
           
            
        }
    }
    
    
    func rootUSerApi(){
        if AppDelegate.sharedInstance.IsInternetconnected == true {
            let param:NSDictionary = [:]
            
            URLhandler.sharedinstance.makeGetCallRootUser(url: Constant.sharedinstance.rootUserAPIURL, param: param, completionHandler: {(responseObject, error) ->  () in
                
                if(error != nil)
                {
                } else{
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int ?? 0
                   // let message = result["message"]
                    if status == 1 {
                        let payload = result["payload"] as? NSDictionary ?? [:]
                        let userName = payload["userName"] as? String ?? ""
                        let password = payload["password"] as? String ?? ""
                        let authToken = payload["authToken"] as? String ?? ""
                        
                        Themes.sharedInstance.saveBasicAuthorization(userName: userName, password: password)
                        if authToken.length > 0 {
                            Themes.sharedInstance.saveAuthToken(authToken: authToken)
                        }
                        SocketIOManager.sharedInstance.establishConnection(Nickname: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()) as NSString, isLogin: true)
                    }
                    else
                    {
                    }
                }
            })
        }else{
            
        }
    }
    
    
    func changeUserOnlineOfflineStatus(status:Int){
        // type 0 = Offline, type 1 = online
        let params = ["type":status] as [String:Any]
        
        URLhandler.sharedinstance.makeCall(url: Constant.sharedinstance.change_user_online_offline_status, param: params as NSDictionary) {(responseObject, error) ->  () in
        }
    }
    
    
    func updateFeedsSeenArrayNew(){
        
        if isUpdatingFeedsSeen == true {
            return
        }else {
            DispatchQueue.global(qos: .background).async {
                self.isUpdatingFeedsSeen = true
                let params = ["seenFeeds":self.seenArray] as [String : Any]
                URLhandler.sharedinstance.makeCall(url: Constant.sharedinstance.updateFeedSeenURL, param: params as NSDictionary) {(responseObject, error) ->  () in
                    
                    if(error != nil)
                    {
                        
                    }else{
                        if (responseObject! as NSDictionary)["status"] as? Int16 ?? 0 == 1{
                            self.seenArray.removeAll()
                        }
                    }
                    self.isUpdatingFeedsSeen = false
                }
            }
        }
    }
 
    

    func logoutApi(){
        
        let strUrl = "\(Constant.sharedinstance.logout)?deviceId=\(Themes.sharedInstance.getDeviceToken())"
        
        URLhandler.sharedinstance.makeGetCall(url: strUrl, param: [:]) {(responseObject, error) ->  () in
            
            if(error != nil)
            {
                self.navigationController?.topViewController?.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            } else{
                if let result = responseObject{
                    let message = result["message"] as? String ?? ""
                    
                    self.navigationController?.topViewController?.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
    }
}

extension AppDelegate:UploadFilesDelegate{
    
    func uploadSelectedFilesDuringPost(thumbUrlArray:Array<Any>,mediaArray : [URL],mediaName:String, url:String, params:NSMutableDictionary,method:HTTPMethod?){
        DispatchQueue.global().async {
            
            URLhandler.sharedinstance.uploadArrayOfMediaWithParameters(thumbUrlArray:thumbUrlArray,mediaArray: mediaArray, mediaName: "media", url: url, params: params,method: method ?? .post) {(responseObject, error) ->  () in
                if(error != nil)
                {
                    
                    self.navigationController?.topViewController?.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    print(error ?? "defaultValue")
                    
                }else{
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int ?? 0
                    let message = result["message"] as? String ?? ""
                    mediaArray.removeSavedURLFiles()
                    thumbUrlArray.removeSavedURLFiles()
                    if status == 1{
                        
                    }else
                    {
                        self.navigationController?.topViewController?.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        }
    }
}


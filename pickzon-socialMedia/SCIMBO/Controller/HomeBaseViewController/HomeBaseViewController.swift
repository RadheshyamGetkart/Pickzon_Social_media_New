//
//  HomeBaseViewController.swift
//
//
//  Created by CASPERON on 16/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit
import Alamofire
import MKVideoCacher
import AVFoundation

class HomeBaseViewController: SwiftBaseViewController{
    
    @IBOutlet var containerStackView: UIStackView!
    let controller = NSVAnimatedTabController()
    var viewHeight = 0.0
    var previousIndex = 0
    var statusBarHide = false

    
    //MARK: Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationController()
        UIView.animate(withDuration: 0.3, animations: {
            if (UIDevice().hasNotch){
                self.controller.centerItemBottomConstraint?.constant = -8
            }else{
                self.controller.centerItemBottomConstraint?.constant = -8
            }
        })
        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.viewScrolled(notification:)), name: NSNotification.Name(rawValue: notif_ViewScrolled), object: nil)
        
       // NotificationCenter.default.addObserver(self, selector: #selector(self.badgeCountUpdate(notification:)), name: NSNotification.Name(rawValue: notif_Badgecount), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshCount),
                                               name: NSNotification.Name(rawValue: noti_RefreshChatCount),
                                               object: nil)

        let param = ["authToken":Themes.sharedInstance.getAuthToken(),"userId":Themes.sharedInstance.Getuser_id(),"gcmId":"\(UserDefaults.standard.string(forKey: "fcm_token") ?? "")","deviceId":"\(Themes.sharedInstance.getDeviceUUIDString())"]
        SocketIOManager.sharedInstance.emitEvent("initiateSocket", param)
    }
    
  

    override func viewWillAppear(_ animated: Bool) {
        if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected)
        {
            SocketIOManager.sharedInstance.establishConnection(Nickname: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()) as NSString, isLogin: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHide
    }
    
    func isStatusBarHidden(_ value: Bool) {
        statusBarHide = value
        setNeedsStatusBarAppearanceUpdate()
    }
    
    
    //MARK: NSNotification Observer Methods
    
    
    
func badgeCountUpdateInTabBar(){

    /*  for item  in  controller.animatedTab.containerView.subviews{
        
        if let  itemss = item as? AnimatedTabItem{
            if  itemss.tag == 11002 &&  Constant.sharedinstance.notificationCount > 0 {
                itemss.badgebtn.badgeString = "\(Constant.sharedinstance.notificationCount)"
                controller.updateViewConstraints()
                itemss.badgebtn.edgeInsetLeft = 5
                itemss.badgebtn.edgeInsetRight = 25
                itemss.badgebtn.edgeInsetBottom = 15
            }else{
                itemss.badgebtn.badgeString = ""
                controller.updateViewConstraints()
            }
        }
    }
    */
}


@objc func badgeCountUpdate(notification: Notification) {
    badgeCountUpdateInTabBar()
}


@objc func refreshCount(notification: Notification) {
   
    if let indexData = notification.userInfo?["count"] as? Int {
        //DispatchQueue.main.async {
           // self.btnNotification.badgeString =   (indexData == 0) ? "" :"\(indexData)"
            Constant.sharedinstance.notificationCount = (indexData == 0) ? 0 : indexData
       // }
    }
    
    if let feedChatCount = notification.userInfo?["feedChatCount"] as? Int {
       // DispatchQueue.main.async {
          //  self.btnChat.badgeString =  (feedChatCount == 0) ? "" :"\(feedChatCount)"
            Constant.sharedinstance.feedChatCount = feedChatCount
        //}
    }
    
    if let requestedChatCount = notification.userInfo?["requestedChatCount"] as? Int {
        //DispatchQueue.main.async {

            Constant.sharedinstance.requestedChatCount = requestedChatCount
        //}
    }
    
    badgeCountUpdateInTabBar()
}

     
    @objc func viewScrolled(notification: Notification) {
        
        guard let isHideTabBar = notification.userInfo!["isHide"] else {
            return
        }
        if isHideTabBar as! Int == 1 {
            DispatchQueue.main.async {
                self.controller.removeConverView()
            }
        }else {
            DispatchQueue.main.async {
                self.controller.addConverView()
            }
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }

    //MARK: Other Helpful Methods
    
    func getController(index: Int, color: UIColor) -> UIViewController {
        
        if index == 0 {
            let feedsVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "FeedsViewController") as! FeedsViewController
            feedsVC.title = "Feeds"
            return feedsVC
        }else  if index == 1 {
   
            let clipsVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "AllLiveUserListVC") as! AllLiveUserListVC
            clipsVC.title = "Go Live"
            
            return clipsVC

        }else  if index == 2 {
          
            
            let vc =
            StoryBoard.feeds.instantiateViewController(withIdentifier: "FeedsVideoViewController") as! FeedsVideoViewController
            vc.videoType = .feed
            vc.isRandomVideos = true
            vc.isClipVideo = true
            vc.isTohideBackButton = true
            
            return vc
                        
        }else  if index == 3 {
        
             let vc = StoryBoard.main.instantiateViewController(withIdentifier: "SearchHomeVC") as! SearchHomeVC
            return vc
            
        }
     
        return UIViewController()
    }
    
    func setNavigationController(){
        
        controller.delegate = self
        controller.configure(tabControllers: [getController(index: 0, color: .white),getController(index: 1, color: .white),getController(index: 2, color: .white),getController(index: 3, color: .white)],
                             with: DefaultAnimatedTabOptions(tabHeight: 50))
        containerStackView.addArrangedSubview(controller.view)
        addChild(controller)
        controller.didMove(toParent: self)
    }
   
    func checkSocketStatus(){
        
        print("socket.status",SocketIOManager.sharedInstance.socket.status)
        if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected)
        {
            SocketIOManager.sharedInstance.establishConnection(Nickname: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()) as NSString, isLogin: true)
        }else{
            SocketIOManager.sharedInstance.emitChatAndNotificationCount(userId: Themes.sharedInstance.Getuser_id())
        }
    }
    
    //MARK: Api Methods
    func rootUSerApi(){
        if AppDelegate.sharedInstance.IsInternetconnected == true {
            let param:NSDictionary = [:]
            
            URLhandler.sharedinstance.makeGetCallRootUser(url: Constant.sharedinstance.rootUserAPIURL, param: param, completionHandler: {(responseObject, error) ->  () in
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                
                if(error != nil)
                {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                } else{
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int ?? 0
                    let message = result["message"]
                    if status == 1 {
                        let payload = result["payload"] as? NSDictionary ?? [:]
                        let userName = payload["userName"] as? String ?? ""
                        let password = payload["password"] as? String ?? ""
                        let authToken = payload["authToken"] as? String ?? ""
                        
                        Themes.sharedInstance.saveBasicAuthorization(userName: userName, password: password)
                        if authToken.length > 0 {
                            Themes.sharedInstance.saveAuthToken(authToken: authToken)
                        }
                        self.setNavigationController()

                    }
                    else
                    {
                        self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            })
        }else  {
            if Themes.sharedInstance.getBasicAuthorizationUserName().length > 0 {
                self.setNavigationController()
            }else {
                self.view.makeToast(message: "No Network Connection", duration: 3, position: HRToastActivityPositionDefault)
            }
        }
    }
   
}



// Support methods


extension HomeBaseViewController: NSVAnimatedTabControllerDelegate,StoriesDelegate {
  
    func getSelectedStoriesIndex(index: Int) {
        
    }
      
    
    func handleLongPressed(sender: UILongPressGestureRecognizer)
    {
        if (sender.state == UIGestureRecognizer.State.ended) {
            print("no longer pressing...")
           // self.captureSession.stopRunning()
            //previewLayer.removeFromSuperlayer()
            
        } else if (sender.state == UIGestureRecognizer.State.began) {
            print("started pressing")
           // self.setupAndStartCaptureSession()
        }
    }
    
   
    func selectCenter() {
        print("center selected")
        
        let frame = CGRect(x: 0, y: 0, width: UIScreen.ft_width(), height: UIScreen.ft_height())

        PlayerHelper.shared.pause()
        /*
         (isLiveAllowed=0)  // Nothing to show, User will redirect to upload post
         (isLiveAllowed=1)  // To show button Go Live
         (isLiveAllowed=2)  // To show button Request for Live
         */
        if Settings.sharedInstance.isLiveAllowed > 0 {
            if let addNewView = Bundle.main.loadNibNamed("AddPostView", owner: self, options: nil)?.first as? AddPostView {
//                addNewView.initializeMethods(frame: self.view.frame)
                addNewView.initializeMethods(frame: frame)

                addNewView.delegate = self
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                    appDelegate.window?.addSubview(addNewView)
                }
            }
        }else{
            
            let destVC:CreateWallPostViewController = StoryBoard.feeds.instantiateViewController(withIdentifier: "CreateWallPostViewController") as! CreateWallPostViewController
            destVC.fromType = .feedPost
            destVC.uploadDelegate = self
            self.navigationController?.pushView(destVC, animated: true)
        }
    }
    
   
   /* func selectCenter() {
        print("center selected")
        PlayerHelper.shared.pause()
        let viewController:CreateWallPostViewController = StoryBoard.feeds.instantiateViewController(withIdentifier: "CreateWallPostViewController") as! CreateWallPostViewController
            viewController.fromType = .feedPost
            viewController.uploadDelegate = self
            self.navigationController?.pushView(viewController, animated: true)
        
    }
    */
    func shouldOpenSubOptions() -> Bool {
        return false
    }
    
    func shouldSelect(at index: Int, item: CenterItemSubOptionItem) -> Bool {
        return true
    }
    
    func didSelect(at index: Int, item: CenterItemSubOptionItem) {
        print(index)
    }
    
    func shouldSelect(at index: Int, item: AnimatedTabItem, tabController: UIViewController) -> Bool {
        return true
    }
    
    func didSelect(at index: Int, item: AnimatedTabItem, tabController: UIViewController) {
        self.checkSocketStatus()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            if let vw =  appDelegate.window?.subviews as? AddPostView{
                vw.removeFromSuperview()
            }
        }

        if previousIndex == 0 &&  index == 0{
            print("Scroll top")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: noti_SccrollFeedsToTop), object:nil)
        }else{
            print("Selection")
        }
        Themes.sharedInstance.selectedTabIndex = index
        previousIndex = index
        print(index)
    }
    
    
    func selectedHeaderOptionsInFeeds(selectionType:OptionFeedType){
      
        if selectionType == .postFeed{
           
            PlayerHelper.shared.pause()
            let viewController:CreateWallPostViewController = StoryBoard.feeds.instantiateViewController(withIdentifier: "CreateWallPostViewController") as! CreateWallPostViewController
                viewController.fromType = .feedPost
                viewController.uploadDelegate = self
                self.navigationController?.pushView(viewController, animated: true)
            
        }else if selectionType == .postFeedWithCamera{
            
            let viewController:CreateWallPostViewController = StoryBoard.feeds.instantiateViewController(withIdentifier: "CreateWallPostViewController") as! CreateWallPostViewController
            viewController.isDisplayVideos = true
            viewController.fromType = .feedPost
            self.navigationController?.pushView(viewController, animated: true)
            
        }else if selectionType == .saved{
            let viewController:WallPostViewVC = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
            viewController.controllerType = .isFromSaved
            self.navigationController?.pushView(viewController, animated: true)
            
            
        }else if selectionType == .createPage{
      
        }else if selectionType == .reels{
            
            let viewController:RecordVideoVC = StoryBoard.main.instantiateViewController(withIdentifier: "RecordVideoVC") as! RecordVideoVC
            self.navigationController?.pushView(viewController, animated: true)
            
        }else if selectionType == .golive{
            
           if Settings.sharedInstance.isLiveAllowed == 2 {
             
             let changeNoVC = StoryBoard.main.instantiateViewController(withIdentifier:"RequestGoLiveVC" ) as! RequestGoLiveVC
             self.pushView(changeNoVC, animated: true)
            
           }else{
               
               let broadCasterVC:GoLiveVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "GoLiveVC") as! GoLiveVC
               self.navigationController?.pushView(broadCasterVC, animated: true)
               
           }
            
        }else if selectionType == .creategroup{
            

        }else if selectionType == .postAds{
            
            
        }
        
    }
}

extension HomeBaseViewController:UploadFilesDelegate{
    
    func uploadSelectedFilesDuringPost(thumbUrlArray:Array<Any>,mediaArray : [URL],mediaName:String, url:String, params:NSMutableDictionary,method:HTTPMethod?){
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: noti_SccrollFeedsToTop), object:nil)

        DispatchQueue.global().async {
            
            URLhandler.sharedinstance.uploadArrayOfMediaWithParameters(thumbUrlArray:thumbUrlArray,mediaArray: mediaArray, mediaName: "media", url: url, params: params,method: method ?? .post) {(responseObject, error) ->  () in
                if(error != nil)
                {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    print(error ?? "defaultValue")
                    
                }else{
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int ?? 0
                    let message = result["message"] as? String ?? ""
                   //Removing localy stored files while uploading
                    mediaArray.removeSavedURLFiles()
                    thumbUrlArray.removeSavedURLFiles()
                    if status == 1{
                        
                    }else
                    {
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        }
    }
}




final class MyWindow: UIWindow {
    private var userInterfaceStyle = UITraitCollection.current.userInterfaceStyle

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let currentTraitCollection = self.traitCollection
        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // handle theme change here.
            AppDelegate.sharedInstance.updateLatestAppearance()
        }
    }
}





//
//  FeedsViewController.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 6/9/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit
import AVKit
import Kingfisher
import IHKeyboardAvoiding
import ActiveLabel
import SCIMBOEx
import Intents
import SwiftyGif
import Alamofire
import Realm
import RealmSwift
import SVGAPlayer
import WebKit

class FeedsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Database handling
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Feeds")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemBlue
        return refreshControl
    }()
    
    @IBOutlet weak var tblFeeds:UITableView!
    @IBOutlet weak var btnChat:MIBadgeButton!
    @IBOutlet weak var btnNotification:MIBadgeButton!
    @IBOutlet weak var btnSearch:UIButton!
    @IBOutlet weak var btnLogo:UIButton!
    @IBOutlet weak var imgVwLogo:UIImageView!
    
    var wallStatusArray:Array<WallStatus> = Array<WallStatus>()
    var arrwallPost:Array<Any> = Array<Any>()
    var indexFriendSuggestion = -1
    var indexClipSuggestion = -1
    var isDataLoading = false
    var availableStatus = 0
    var states : Array<Bool>!
    var feedSectionNo = 1
    var pageNo = 1
    var isUploadingPost = false
    var progress = 0.0
    var managedContext: NSManagedObjectContext?
    var isDisplayWelcomePointAlert = false
    
    var viewAlert:UIView?
    var viewAlertCenter:UIView?
    var btnCloseAlert:UIButton?
    var popupType: Int = 1
    var popUpID: String = ""
    var goLiveSuggestionIndex = -1
    var goLiveExitcommited = false
    var remoteSVGAPlayer:SVGAPlayer?
    var webView:WKWebView?
    var bannerIndex = -1
    var isAutopPlayFirstIndex = false
    
    @IBOutlet weak var profilePicView:ImageWithFrameImgView!
    
    
    // MARK: - ViewController Life cycle
    override func loadView(){
        super.loadView()
        registerTableviewCell()
        NotificationCenter.default.removeObserver(self)
        tblFeeds.rowHeight = 200 + self.view.frame.size.width
        tblFeeds.estimatedRowHeight = UITableView.automaticDimension
        tblFeeds.allowsSelection = false
        imgVwLogo.setImageViewTintColor(color: UIColor.label)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        getClipSettingApi()
        
        self.isDisplayWelcomePointAlert = UserDefaults.standard.object(forKey: "isDisplayWelcomePointAlert") as? Bool ?? false
        self.showPromoAlert()
        UserDefaults.standard.set(false, forKey: "isDisplayWelcomePointAlert")
        UserDefaults.standard.synchronize()
        setUserProfile()
        tblFeeds.refreshControl = topRefreshControl
        profilePicView.initializeView()
        isDataLoading = true
        if self.arrwallPost.count == 0 {
            
            DispatchQueue.main.async { [weak self] in
                if let data = self?.fetchFeedsDataFromDB() {
                    self?.states = [Bool](repeating: true, count: data.count )
                    for obj in data {
                        autoreleasepool {
                            if (obj as! NSDictionary)["viewType"] as? Int ?? 0 == 0 {
                                
                                let objWallpostata = WallPostModel(dict: obj as! NSDictionary)
                                self?.arrwallPost.append(objWallpostata)
                                
                            }else if (obj as! NSDictionary)["viewType"] as? Int ?? 0 == 2 {
                                
                                self?.arrwallPost.append(FriendSuggestionModal(respDict: (obj as! NSDictionary)))
                            }
                        }
                    }
                    self?.tblFeeds.reloadData()
                }
            }
        }
        
        if self.wallStatusArray.count == 0 {
            
            DispatchQueue.main.async { [weak self] in
                if let data = self?.fetchStoryDataFromDB() {
                    
                    for obj in data {
                        autoreleasepool {
                            let objStatus = WallStatus(responseDict: obj as! NSDictionary)
                            self?.wallStatusArray.append(objStatus)
                        }
                    }
                    self?.tblFeeds.reloadData()
                }
            }
        }
        
        getAllWallPostAPIImplementation(pageNo: self.pageNo)
        
        
        if Themes.sharedInstance.isSharingData == true {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                Themes.sharedInstance.isSharingData = false
                let destVc:CreateWallPostViewController = StoryBoard.feeds.instantiateViewController(withIdentifier: "CreateWallPostViewController") as! CreateWallPostViewController
                destVc.isSharingData = true
                destVc.uploadDelegate = self
                self.navigationController?.pushView(destVc, animated: true)
            })
        }
        addObservers()
        
        self.getFeedsVideosAPI()
        
        self.profilePicView.imgVwProfile?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                                      action:#selector(self.handleProfilePicTap)))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.errorInVideoPlaying(notification:)), name: nofit_VideoPlayerError, object: nil)
        
        Themes.sharedInstance.isClipVideo = 0
        Themes.sharedInstance.isFeedsView = 1
        self.openViolationPreview()
        setUserProfile()
        
        if SocketIOManager.sharedInstance.socket.status == .connected && goLiveExitcommited == false && Settings.sharedInstance.isLiveAllowed == 1{
            let param = ["authToken": Themes.sharedInstance.getAuthToken(),"roomId":Themes.sharedInstance.Getuser_id(),"type":"0"] as [String : Any]
            SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_exit_go_live_host_user, param)
            goLiveExitcommited = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.checkSocketStatus()
        }
        
        if let cell = tblFeeds.visibleCells.first as? FeedsBannerCell{
            cell.startTimer()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: nofit_VideoPlayerError, object: nil)
        Themes.sharedInstance.isFeedsView = 0
        DispatchQueue.main.async { [weak self] in
            //Pause all visible players
            self?.pauseAllVisiblePlayers()
        }
        super.viewWillDisappear(animated)
        
        if let cell = tblFeeds.cellForRow(at: IndexPath(row: 0, section: feedSectionNo)) as? FeedsBannerCell{
            
            cell.stopTimer()
        }
    }
    
    
    
    
    
    //MARK: Initial Setup Methods
    func registerTableviewCell(){
        
        
        tblFeeds.register(UINib(nibName: "FeedsBannerCell", bundle: nil),
                          forCellReuseIdentifier: "FeedsBannerCell")
        tblFeeds.register(UINib(nibName: "StoriesTableViewCell", bundle: nil),
                          forCellReuseIdentifier: "StoriesTableViewCell")
        tblFeeds.register(UINib(nibName: "FeedsTableViewCell", bundle: nil),
                          forCellReuseIdentifier: "FeedsTableViewCell")
        tblFeeds.register(UINib(nibName: "FeedsSharedTableViewCell", bundle: nil),
                          forCellReuseIdentifier: "FeedsSharedTableViewCell")
        
        tblFeeds.register(UINib(nibName: "SponserTblCell", bundle: nil),
                          forCellReuseIdentifier: "SponserTblCell")
        tblFeeds.register(UINib(nibName: "FeedSuggestionTblCell", bundle: nil),
                          forCellReuseIdentifier: "FeedSuggestionTblCell")
        tblFeeds.register(UINib(nibName: "LoadMoreTblCell", bundle: nil),
                          forCellReuseIdentifier: "LoadMoreTblCell")
        tblFeeds.register(UINib(nibName: "FileUploadProgressTblCell",
                                bundle: nil), forCellReuseIdentifier: "FileUploadProgressTblCell")
        tblFeeds.register(UINib(nibName: "ClipSuggestionTVCell",
                                bundle: nil), forCellReuseIdentifier: "ClipSuggestionTVCell")
        
    }
    
    
    func addObservers() {
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.backFromVideosScreen(notification:)), name: nofit_BackFromVideos, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshWallPost),
                                               name: NSNotification.Name(rawValue: noti_RefreshFeed),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshStoryList),
                                               name: NSNotification.Name(rawValue: noti_RefreshStory),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshCount),
                                               name: NSNotification.Name(rawValue: noti_RefreshChatCount),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.recieveFeedPostData),
                                               name: NSNotification.Name(rawValue: noti_RecieveFeedPostData),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sccrollFeedsToTop),
                                               name: NSNotification.Name(rawValue: noti_SccrollFeedsToTop),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.pauseAllVisiblePlayers),
                                               name: NSNotification.Name(rawValue: noti_PauseAllFeedsVideos),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.feedsLikedReceivedNotification(notification:)),
                                               name: notif_FeedLiked, object: nil)
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.feedRemovedNotification(notification:)), name: notif_FeedRemoved, object: nil)
        
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.feedTagRemovedNotification(notification:)), name: notif_TagRemoved, object: nil)
        
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.feedExpandedNotification(notification:)), name: notif_feedExpanded, object: nil)
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.feedFollwedNotification(notification:)), name: notif_FeedFollowed, object: nil)
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.feedCommentAddedNotification(notification:)), name: nofit_CommentAdded, object: nil)
        
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.feedSavedNotification(notification:)), name: nofit_FeedSaved, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(uploadingProgeress(notification:)), name: Notification.Name(rawValue: noti_UploadProgress), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(app_Minimize_PausePlayer), name: NSNotification.Name(Constant.sharedinstance.app_PausePlayer), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.noti_BoostedPost(notification:)), name: noti_Boosted, object: nil)
        
    }
    
    
    deinit{
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: notif_FeedLiked, object: nil)
        NotificationCenter.default.removeObserver(self, name: notif_FeedRemoved, object: nil)
        NotificationCenter.default.removeObserver(self, name: notif_TagRemoved, object: nil)
        NotificationCenter.default.removeObserver(self, name: notif_feedExpanded, object: nil)
        NotificationCenter.default.removeObserver(self, name: notif_FeedFollowed, object: nil)
        NotificationCenter.default.removeObserver(self, name: nofit_CommentAdded, object: nil)
        NotificationCenter.default.removeObserver(self, name: nofit_FeedSaved, object: nil)
        NotificationCenter.default.removeObserver(self, name: nofit_BackFromVideos, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Constant.sharedinstance.app_PausePlayer), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:Constant.sharedinstance.sio_logout_from_all_device),
                                                  object: nil)
    }
    
    
    @objc func app_Minimize_PausePlayer() {
        print("app_Minimize_PausePlayer")
        self.pauseAllVisiblePlayers()
    }
    
    //MARK: - Socket emit for Notification
    func checkSocketStatus(){
        if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected)
        {
            SocketIOManager.sharedInstance.establishConnection(Nickname: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()) as NSString, isLogin: true)
        }else{
            SocketIOManager.sharedInstance.emitChatAndNotificationCount(userId: Themes.sharedInstance.Getuser_id())
        }
    }
    
    
    func showpopUp(url: String){
        self.pauseAllVisiblePlayers()
        
        self.viewAlertCenter?.removeFromSuperview()
        self.viewAlert?.removeFromSuperview()
        
        viewAlert = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        viewAlert?.backgroundColor = UIColor.black
        viewAlert?.alpha = 0.8
        
        let height = self.view.frame.width - 20
        viewAlertCenter = UIView(frame: CGRect(x: 10, y: (self.view.frame.height / 2 - height/2) + 30, width: height, height: height))
        viewAlertCenter?.backgroundColor = UIColor.clear
        
        let imgViewaAck = UIImageView(frame: CGRect(x: 0, y: 0, width: (viewAlertCenter?.frame.width ?? 0), height: (viewAlertCenter?.frame.height ?? 0 ) ))
        let imgURL = url
        if checkMediaTypes(strUrl: url) == 1{
            if imgURL.deletingLastPathComponent == "gif" {
                imgViewaAck.setGifFromURL(URL(string: url), manager: .defaultManager, loopCount: -1, showLoader: true)
            }else {
                imgViewaAck.kf.setImage(with: URL(string: url), placeholder:PZImages.dummyCover)
            }
            viewAlertCenter?.addSubview(imgViewaAck)
        }else if checkMediaTypes(strUrl: url) == 5 {
            remoteSVGAPlayer = SVGAPlayer(frame: CGRect(x: 0, y: 0, width: (viewAlertCenter?.frame.size.width ?? 0), height: (viewAlertCenter?.frame.size.height ?? 0)))
            remoteSVGAPlayer?.backgroundColor = .clear
            viewAlertCenter?.addSubview(remoteSVGAPlayer!)
            remoteSVGAPlayer?.loops = 0 //1   // repeat count，0 means infinite
            remoteSVGAPlayer?.clearsAfterStop = true
            // remoteSVGAPlayer.contentMode = .scaleToFill
            
            let remoteSVGAUrl = url
            if let url = URL(string: remoteSVGAUrl) {
                let remoteSVGAParser = SVGAParser()
                remoteSVGAParser.enabledMemoryCache = true
                
                remoteSVGAParser.parse(with: url, completionBlock: { (svgaItem) in
                    self.remoteSVGAPlayer?.videoItem = svgaItem
                    self.remoteSVGAPlayer?.startAnimation()
                }, failureBlock: { (error) in
                    print("--------------------- \(String(describing: error))")
                })
            }
        }else {
            webView = WKWebView(frame: CGRect(x: 0, y: 0, width: (viewAlertCenter?.frame.size.width ?? 0), height: (viewAlertCenter?.frame.size.height ?? 0)))
            let webURL = URL(string: url)!
            webView?.load(URLRequest(url: webURL))
            viewAlertCenter?.addSubview(webView!)
        }
        
        
        /*viewAlertCenter.layer.cornerRadius = 10.0
         viewAlertCenter.layer.borderColor = UIColor.lightGray.cgColor
         viewAlertCenter.layer.borderWidth = 1.0
         viewAlertCenter.layer.shadowColor = UIColor.black.cgColor
         viewAlertCenter.layer.shadowOffset = CGSize(width: 2, height: 2)
         viewAlertCenter.layer.shadowOpacity = 0.7
         viewAlertCenter.layer.shadowRadius = 5.0
         viewAlertCenter.clipsToBounds = true
         */
        
        btnCloseAlert = UIButton(frame: CGRect(x: (viewAlertCenter?.frame.width ?? 0) - 30, y: 0, width: 30, height: 30))
        btnCloseAlert?.setBackgroundImage(UIImage(named: "crossCircle"), for: .normal)
        btnCloseAlert?.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        viewAlertCenter?.addSubview(btnCloseAlert!)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handlePopUptype(_:)))
        viewAlertCenter?.addGestureRecognizer(tap)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.closePopup))
        viewAlert?.addGestureRecognizer(tap1)
        
        self.view.addSubview(viewAlert!)
        self.view.addSubview(viewAlertCenter!)
    }
    
    
    
    func getPickzonUserFromDatabase()->PickzonUser{
        
        var pickzonUser = PickzonUser(respdict: [:])
        
        guard let realm = DBManager.openRealm() else {
            return pickzonUser
        }
        
        
        if let existingUser =  realm.object(ofType: DBUser.self, forPrimaryKey: Themes.sharedInstance.Getuser_id()) {
            
            pickzonUser.name = existingUser.name
            pickzonUser.email = existingUser.emailId
            pickzonUser.pickzonId = existingUser.pickzonId
            pickzonUser.description =  existingUser.desc
            pickzonUser.dob = existingUser.dob
            pickzonUser.headline = existingUser.organization
            pickzonUser.gender = existingUser.gender
            pickzonUser.jobProfile = existingUser.jobProfile
            pickzonUser.livesIn = existingUser.livesIn
            pickzonUser.followerCount = existingUser.totalFans
            pickzonUser.followingCount = existingUser.totalFollowing
            pickzonUser.postCount = existingUser.totalPost
            pickzonUser.mobileNo = existingUser.mobileNo
            pickzonUser.usertype = existingUser.usertype
            pickzonUser.website = existingUser.website
            pickzonUser.coverImage = existingUser.coverImage
            pickzonUser.actualProfileImage = existingUser.actualProfilePic
            pickzonUser.profilePic = existingUser.profilePic
            pickzonUser.avatar = existingUser.avatar
            pickzonUser.allGiftedCoins = existingUser.allGiftedCoins
            pickzonUser.angelsCount = existingUser.angelsCount
            pickzonUser.giftingLevel = existingUser.giftingLevel
        }
        
        return pickzonUser
    }
    
    
    
    
    @objc func handlePopUptype(_ sender: UITapGestureRecognizer? = nil) {
        
        /*
         popupType
         type = 1  // no need to redirect (badges and more popups)
         type = 2  // redirect to avatar frames screen
         type = 3  // redirect to entry effect screen
         type = 4  // redirect to coins buy screen while showing discounts in popup
         type = 5  // redirect to Boost  screen
         */
        self.closePopup()
        if popupType != 1 {
            
            //take appropriate action for popupType
            if popupType == 2 {
                let vc =  StoryBoard.feeds.instantiateViewController(withIdentifier: "FrameSelectionVC") as! FrameSelectionVC
                
                vc.pickzonUser = getPickzonUserFromDatabase()
                self.navigationController?.pushViewController(vc, animated: true)
            }else if popupType == 3 {
                let vc =  StoryBoard.feeds.instantiateViewController(withIdentifier: "EntryStyleSelectionVC") as! EntryStyleSelectionVC
                vc.pickzonUser = getPickzonUserFromDatabase()
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else if popupType == 4 {
                let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
                AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
           
            }else if popupType == 5 {
                
                let destVC:WallPostViewVC = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
                destVC.controllerType = .isFromPost
                (AppDelegate.sharedInstance.navigationController?.topViewController)!.pushView(destVC, animated: true)
            }
        }
    }
    
    
    @objc  func closePopup() {
        
        self.callPopupSeenAPI()
        self.btnCloseAlert?.removeFromSuperview()
        self.remoteSVGAPlayer?.stopAnimation()
        self.remoteSVGAPlayer?.clear()
        self.remoteSVGAPlayer?.removeFromSuperview()
        webView?.removeFromSuperview()
        self.viewAlertCenter?.removeFromSuperview()
        self.viewAlert?.removeFromSuperview()
    }
    
    func showPromoAlert(){
        
        // isDisplayWelcomePointAlert = true
        if isDisplayWelcomePointAlert == true {
            self.viewAlertCenter?.removeFromSuperview()
            self.viewAlert?.removeFromSuperview()
            
            viewAlert = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            viewAlert?.backgroundColor = UIColor.black
            viewAlert?.alpha = 0.8
            
            let height = self.view.frame.width - 100
            viewAlertCenter = UIView(frame: CGRect(x: 50, y: (self.view.frame.height / 2 - height/2), width: height, height: height))
            viewAlertCenter?.backgroundColor = UIColor.white
            
            let imgViewaAck = UIImageView(frame: CGRect(x: 0, y: 0, width: viewAlertCenter!.frame.width, height: viewAlertCenter!.frame.height))
            var imgURL = UserDefaults.standard.object(forKey:"popUpUrl") as? String ?? ""
            
            if imgURL.length > 0  && !imgURL.contains("http"){
                if imgURL.prefix(1) == "." {
                    imgURL = String(imgURL.dropFirst(1))
                }
                imgURL = Themes.sharedInstance.getURL() + imgURL
            }
            
            imgViewaAck.kf.setImage(with: URL(string: imgURL), placeholder:PZImages.dummyCover)
            viewAlertCenter?.addSubview(imgViewaAck)
            
            viewAlertCenter?.layer.cornerRadius = 10.0
            viewAlertCenter?.layer.borderColor = UIColor.lightGray.cgColor
            viewAlertCenter?.layer.borderWidth = 1.0
            viewAlertCenter?.layer.shadowColor = UIColor.black.cgColor
            viewAlertCenter?.layer.shadowOffset = CGSize(width: 2, height: 2)
            viewAlertCenter?.layer.shadowOpacity = 0.7
            viewAlertCenter?.layer.shadowRadius = 5.0
            viewAlertCenter?.clipsToBounds = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            viewAlert?.addGestureRecognizer(tap)
            let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.showReferalsScreen))
            viewAlertCenter?.addGestureRecognizer(tap1)
            
            self.view.addSubview(viewAlert!)
            self.view.addSubview(viewAlertCenter!)
            
        }else {
            
            if Themes.sharedInstance.getIsReferAvailable() as? Int ?? 0 == 0{
                return
            }
            let todaysDate = Date()
            let lastdisplayedPromoDate = UserDefaults.standard.value(forKey: "last_Promo_Display_Date") as? Date ?? todaysDate
            let numberOFDays =  Calendar.current.dateComponents([.day], from: lastdisplayedPromoDate, to: todaysDate).day ?? 0
            
            if numberOFDays  >= 7 ||  todaysDate == lastdisplayedPromoDate {
                UserDefaults.standard.set(todaysDate, forKey: "last_Promo_Display_Date")
                UserDefaults.standard.synchronize()
                
                self.viewAlertCenter?.removeFromSuperview()
                self.viewAlert?.removeFromSuperview()
                
                viewAlert = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                viewAlert?.backgroundColor = UIColor.black
                viewAlert?.alpha = 0.8
                
                let height = self.view.frame.width - 100
                viewAlertCenter = UIView(frame: CGRect(x: 50, y: (self.view.frame.height / 2 - height/2), width: height, height: height))
                viewAlertCenter?.backgroundColor = UIColor.white
                
                let imgViewaAck = UIImageView(frame: CGRect(x: 0, y: 0, width: viewAlertCenter!.frame.width, height: viewAlertCenter!.frame.height))
                imgViewaAck.image = UIImage(named: "referBack")
                viewAlertCenter?.addSubview(imgViewaAck)
                
                let imgView = UIImageView(frame: CGRect(x: (height / 2 - 65), y: 30, width: 130, height: 130))
                imgView.image = UIImage(named: "gift")
                viewAlertCenter?.addSubview(imgView)
                
                let imgCurrency = UIImageView(frame: CGRect(x: (height / 2 - 30), y: imgView.frame.origin.y + imgView.frame.height - 20, width: 20, height: 20))
                imgCurrency.layer.cornerRadius = imgCurrency.frame.height / 2.0
                imgCurrency.layer.borderColor = UIColor.yellow.cgColor
                imgCurrency.layer.borderWidth = 1.0
                imgCurrency.image = UIImage(named:"referralStar")
                viewAlertCenter?.addSubview(imgCurrency)
                
                
                let lblCoinQty = UILabel(frame: CGRect(x: imgCurrency.frame.x + imgCurrency.frame.width + 5, y: imgView.frame.origin.y + imgView.frame.height - 20, width: 100, height: 20))
                lblCoinQty.text = "100"
                lblCoinQty.textColor = UIColor.white
                viewAlertCenter?.addSubview(lblCoinQty)
                
                let lblMsg = UILabel(frame: CGRect(x: 10, y: height - 120, width: height - 20, height: 50))
                lblMsg.text = "Win rewards on every successful referral. The more you REFER, the more you EARN..."
                lblMsg.textColor = UIColor.white
                lblMsg.font = UIFont.boldSystemFont(ofSize: 13)
                lblMsg.numberOfLines = 0
                lblMsg.textAlignment = .center
                viewAlertCenter?.addSubview(lblMsg)
                
                let btnSuccess = UIButton(frame: CGRect(x: 0, y: viewAlertCenter!.frame.height - 60, width: viewAlertCenter!.frame.width, height: 60))
                btnSuccess.setTitle("Get the coins", for: .normal)
                btnSuccess.titleLabel?.textColor = UIColor.white
                btnSuccess.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                btnSuccess.titleLabel?.numberOfLines = 0
                btnSuccess.backgroundColor = UIColor(red: 0/255.0, green: 11.0/255.0, blue: 67.0/255.0, alpha: 0.5)
                btnSuccess.addTarget(self, action: #selector(self.showReferalsScreen), for: .touchUpInside)
                viewAlertCenter?.addSubview(btnSuccess)
                
                viewAlertCenter?.layer.cornerRadius = 10.0
                viewAlertCenter?.layer.borderColor = UIColor.lightGray.cgColor
                viewAlertCenter?.layer.borderWidth = 1.0
                viewAlertCenter?.layer.shadowColor = UIColor.black.cgColor
                viewAlertCenter?.layer.shadowOffset = CGSize(width: 2, height: 2)
                viewAlertCenter?.layer.shadowOpacity = 0.7
                viewAlertCenter?.layer.shadowRadius = 5.0
                viewAlertCenter?.clipsToBounds = true
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                viewAlert?.addGestureRecognizer(tap)
                
                let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.showReferalsScreen))
                viewAlertCenter?.addGestureRecognizer(tap1)
                
                self.view.addSubview(viewAlert!)
                self.view.addSubview(viewAlertCenter!)
            }
        }
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        self.viewAlertCenter?.removeFromSuperview()
        self.viewAlert?.removeFromSuperview()
        //self.navigationController?.popViewController(animated: true)
    }
    
    @objc func showReferalsScreen(){
        self.viewAlertCenter?.removeFromSuperview()
        self.viewAlert?.removeFromSuperview()
        //        let destVC:ReferalsViewController = StoryBoard.feeds.instantiateViewController(withIdentifier: "ReferalsViewController") as! ReferalsViewController
        //        self.navigationController?.pushView(destVC, animated: true)
        //
        let viewController:WalletVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
        viewController.isGiftedCoinsTabOpen = false
        self.navigationController?.pushView(viewController, animated: true)
    }
    
    
    func setUserProfile(){
        
        guard let realm = DBManager.openRealm() else {
            return
        }
        if let existingUser =  realm.object(ofType: DBUser.self, forPrimaryKey: Themes.sharedInstance.Getuser_id()) {
            
            if  existingUser.profilePic.length == 0{
                let  profilePic = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "profilepic")
                profilePicView.setImgView(profilePic: profilePic, frameImg: existingUser.avatar,changeValue:5)
                
            }else{
                profilePicView.setImgView(profilePic: existingUser.profilePic, frameImg: existingUser.avatar,changeValue:5)
            }
        }else{
            let  profilePic = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "profilepic")
            profilePicView.setImgView(profilePic: profilePic, frameImg: "",changeValue:5)
        }
        
    }
    
    //MARK: Pull to refresh
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
        if !isDataLoading{
            self.isDataLoading = true
            pageNo = 1
            feedSectionNo = 1
            self.getAllWallPostAPIImplementation(pageNo: self.pageNo)
        }
        refreshControl.endRefreshing()
        topRefreshControl.endRefreshing()
    }
    
    
    //MARK: - User defined functions
    
    @IBAction func logoBtnAction(_ sender: Any)  {
   
        if !isDataLoading{
            
            isDataLoading = true
            pageNo = 1
            self.indexFriendSuggestion = -1
            // arrwallPost.removeAll()
            //self.tblFeeds.reloadData()
            self.getAllWallPostAPIImplementation(pageNo: pageNo , isShowLoader: true)
        }
    }
    
    @IBAction func searchBtnAction(_ sender: Any) {
        
        
     /*   if let vc = StoryBoard.main.instantiateViewController(withIdentifier: "SearchHomeVC") as? SearchHomeVC{
            navigationController?.pushViewController(vc, animated: false)
        }*/
        
    }
    
    
    @IBAction func notificationBtnAction(_ sender: Any) {
        //Menu button action
        let moreVC:MoreSettingVC = StoryBoard.main.instantiateViewController(withIdentifier: "MoreSettingVC") as! MoreSettingVC
        self.pushView(moreVC, animated: true)
        
    }
    
    @IBAction func messageBtnAction(_ sender: Any) {
        //Message button action
        Themes.sharedInstance.isChatListRefresh = 0
        let viewController:ChatListVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatListVC") as! ChatListVC
        self.navigationController?.pushView(viewController, animated: true)
    }
    
    
    @objc  func handleProfilePicTap(){
        
        if  let viewController:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
            viewController.otherMsIsdn = Themes.sharedInstance.Getuser_id()
            self.navigationController?.pushView(viewController, animated: true)
        }
    }
    
    
    
    //MARK: -  Tableview Delegate && DataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section{
            
        case 0:
            return (isUploadingPost == true) ? 2 : 1
            
        case 2:
            return 1
            
        default:
            return arrwallPost.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section{
            
        case 0:
            if indexPath.row == 0 {
                //Story cell
                let cell = tableView.dequeueReusableCell(withIdentifier: "StoriesTableViewCell", for: indexPath) as! StoriesTableViewCell
                cell.selectionStyle = .none
                cell.statusArray = wallStatusArray
                cell.isAvailable = availableStatus
                cell.delegate = self
                cell.cvStories.reloadData()
                return cell
                
            }else{
                //Upload progress cell
                let cell = tableView.dequeueReusableCell(withIdentifier: "FileUploadProgressTblCell", for: indexPath) as! FileUploadProgressTblCell
                cell.progreessVw.progress = Float(progress)
                cell.progreessVw.progressViewStyle = .bar
                cell.setDataInProgress(progress: progress, mediaArray: Array())
                return cell
            }
            
        case 2:
            //Loading cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreTblCell", for: indexPath) as! LoadMoreTblCell
            cell.activityIndicator.startAnimating()
            return cell
            
        default:
            if let objWallPost =  arrwallPost[indexPath.row] as? WallPostModel {
                var cell: FeedsCell!
                
                
                if objWallPost.sharedWallData == nil {
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "FeedsTableViewCell") as! FeedsTableViewCell
                    
                    cell.configureWallPostItem(objWallPost: objWallPost, indexPath: indexPath,states: (states.count > indexPath.row) ? states[indexPath.row] : false)
                    cell.lblDescription.delegate = self
                    cell.lblDescription.textReplacementType = .word
                    cell.lblDescription.shouldCollapse = true
                    cell.lblDescription.numberOfLines = 4
                    
                    if states.count > indexPath.row{
                        cell.lblDescription.shouldCollapse = states[indexPath.row]
                    }
                }else{
                    cell = tableView.dequeueReusableCell(withIdentifier: "FeedsSharedTableViewCell") as! FeedsSharedTableViewCell
                    
                    
                    cell.configureSharedWallDataPost(objWallPost: objWallPost, indexPath: indexPath, states: (states.count > indexPath.row) ? states[indexPath.row] : false)
                    cell.lblSharedContents.delegate = self
                    cell.lblDescription.delegate = self
                    cell.lblDescription.numberOfLines = 4
                    cell.lblDescription.textReplacementType = .word
                    cell.lblDescription.shouldCollapse = true
                    cell.lblSharedContents.textReplacementType = .word
                    cell.lblSharedContents.shouldCollapse = true
                    cell.lblSharedContents.numberOfLines = 4
                    
                    if states.count > indexPath.row{
                        cell.lblDescription.shouldCollapse = states[indexPath.row]
                        cell.lblSharedContents.shouldCollapse = states[indexPath.row]
                    }
                    cell.addTargetSharedWallButtons()
                }
                
                cell.addTargetButtons()
                cell.isRandomVideos = true
                
                cell.superview?.updateConstraints()
                
                cell.cvFeedsPost.updateConstraints()
                cell.cvFeedsPost.reloadData()
                
                cell.selectionStyle = .none
                
                return cell
                
            }else if let friendObj =  arrwallPost[indexPath.row] as? FriendSuggestionModal {
                
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "FeedSuggestionTblCell", for: indexPath) as! FeedSuggestionTblCell
                
                cell.selectionStyle = .none
                cell.sectionIndex = indexPath.row
                cell.friendSugesstionArray = friendObj.payload
                cell.cllctnView.reloadData()
                cell.delegate = self
                if friendObj.payload.count > 0 {
                    cell.viewBack.isHidden = false
                    cell.lblTitle.isHidden = false
                    cell.btnSeeAll.isHidden = false
                    cell.cllctnView.isHidden = false
                }else {
                    cell.viewBack.isHidden = true
                    cell.lblTitle.isHidden = true
                    cell.btnSeeAll.isHidden = true
                    cell.cllctnView.isHidden = true
                    
                }
                return cell
                
            }else if let objClipSuggestions =  arrwallPost[indexPath.row] as? ClipSuggestionModel {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ClipSuggestionTVCell") as! ClipSuggestionTVCell
                cell.wallPostArray = objClipSuggestions.payload
                cell.parentIndex = indexPath.row
                cell.delegate = self
                cell.cllctnVw.reloadWithoutAnimation()
                if let layout = cell.cllctnVw.collectionViewLayout as? UICollectionViewFlowLayout {
                    layout.scrollDirection = .horizontal
                }
                
                if objClipSuggestions.payload.count > 0 {
                    cell.viewBack.isHidden = false
                    cell.cllctnVw.isHidden = false
                    cell.viewBorder.isHidden = false
                }else {
                    cell.viewBack.isHidden = true
                    cell.cllctnVw.isHidden = true
                    cell.viewBorder.isHidden = true
                }
                return cell
            }else if let objLive =  arrwallPost[indexPath.row] as? FeedBannerModel {
                //Banner cell
                let cell = tableView.dequeueReusableCell(withIdentifier:"FeedsBannerCell") as! FeedsBannerCell
                cell.bannerArray = objLive.bannerArray
                cell.cnstrntHtCllctnVw.constant = (objLive.bannerArray.count == 0) ? 0 : 140 // 174
                cell.stopTimer()
                cell.startTimer()
                cell.cllctnViewBanner.reloadData()
                return cell
            }else if let objLive =  arrwallPost[indexPath.row] as? GoLiveUser {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "LiveUsersFeedTblCell") as! LiveUsersFeedTblCell
                cell.liveUsersArray = objLive.liveUsers
                cell.cllctnView.reloadWithoutAnimation()
                cell.delegate = self
                if let layout = cell.cllctnView.collectionViewLayout as? UICollectionViewFlowLayout {
                    layout.scrollDirection = .horizontal
                }
                
                if objLive.liveUsers.count > 0 {
                    cell.viewBack.isHidden = false
                    cell.cllctnView.isHidden = false
                    cell.titleStackView.isHidden = false
                    cell.cnstrntTopSeperatorHt.constant = 2
                    cell.cnstrntBottomSeperatorHt.constant = 2.5
                    
                }else {
                    cell.viewBack.isHidden = true
                    cell.cllctnView.isHidden = true
                    cell.titleStackView.isHidden = true
                    cell.cnstrntTopSeperatorHt.constant = 0
                    cell.cnstrntBottomSeperatorHt.constant = 0
                }
                return cell
            }
            
        }
        
        
        
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == feedSectionNo  && indexPath.row < arrwallPost.count{
            
            if let bannerCell = cell as? FeedsBannerCell {
                bannerCell.stopTimer()
            }
            
            if let objWallPost = arrwallPost[indexPath.row] as? WallPostModel {
                if (objWallPost.sharedWallData == nil){
                    if let tblCell1 =  (cell as? FeedsTableViewCell)?.cvFeedsPost.visibleCells.first as? FeedsCollectionViewCell {
                        tblCell1.pauseVideoHidden()
                    }
                }else {
                    if  let tblCell1 =  (cell as? FeedsSharedTableViewCell)?.cvFeedsPost.visibleCells.first as? FeedsCollectionViewCell {
                        tblCell1.pauseVideoHidden()
                    }
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == feedSectionNo {
            if arrwallPost.count > indexPath.row {
                if var objWallPost =  arrwallPost[indexPath.row] as? WallPostModel {
                    if objWallPost.isSeen == 0 {
                        if !AppDelegate.sharedInstance.seenArray.contains(objWallPost.id){
                            AppDelegate.sharedInstance.seenArray.append(objWallPost.id)
                            if objWallPost.sharedWallData != nil {
                                AppDelegate.sharedInstance.seenArray.append(objWallPost.sharedWallData.id)
                            }
                        }
                        
                        if  AppDelegate.sharedInstance.seenArray.count >= 10 {
                            AppDelegate.sharedInstance.updateFeedsSeenArrayNew()
                        }
                        objWallPost.isSeen = 1
                        arrwallPost[indexPath.row] = objWallPost
                    }
                }
            }
            
            //Call API befor the end of all records
            if indexPath.row == arrwallPost.count - 1 {
                if !isDataLoading {
                    if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                        
                        self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
                        
                    }else {
                        self.isDataLoading = true
                        //   self.pageNo = self.pageNo + 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                            
                            self?.getAllWallPostAPIImplementation(pageNo: self?.pageNo ?? 0, isShowLoader: true)
                            
                        }
                        
                    }
                }
            }
            
            if indexPath.row % 3 == 0{
                preBufferNextFeedVideos(currentIndex: indexPath.row)
            }
        }
        
        if let bannerCell = cell as? FeedsBannerCell {
            bannerCell.startTimer()
        }
    }
    
    func preBufferNextFeedVideos(currentIndex:Int) {
        if (UIApplication.shared.delegate as! AppDelegate).IsInternetconnected == true {
            var urlArray:Array<URL> = Array()
            for index in currentIndex..<(currentIndex + 3) {
                
                if index < arrwallPost.count{
                    autoreleasepool {
                        if let objWallPost = arrwallPost[index] as? WallPostModel {
                            var strURL = ""
                            if objWallPost.sharedWallData == nil {
                                if objWallPost.urlArray.count > 0{
                                    strURL = objWallPost.urlArray[0]
                                }
                            }else {
                                if objWallPost.sharedWallData.urlArray.count > 0{
                                    strURL = objWallPost.sharedWallData.urlArray[0]
                                }
                            }
                            if strURL.length > 0 {
                                if checkMediaTypes(strUrl:strURL ) == 3  {
                                    urlArray.append(URL(string: strURL)!)
                                }
                            }
                        }
                    }
                }else {
                    break
                }
                
            }
            if urlArray.count > 0 {
                VideoPreloadManager.shared.set(waiting: urlArray)
            }
            
            //self.downloadNextThumbnails(index: currentIndex)
        }else {
            self.view.makeToast(message: "No Network Connection", duration: 2, position: HRToastActivityPositionDefault)
        }
    }
    
    func downloadNextThumbnails(index:Int) {
        
        for index1 in 0..<(index + 6){
            autoreleasepool {
                if (index1 + index) < arrwallPost.count  {
                    if let obj:WallPostModel = arrwallPost[index1 + index] as? WallPostModel {
                        var url = ""
                        if obj.sharedWallData == nil {
                            if obj.thumbUrlArray.count > 0 {
                                url = obj.thumbUrlArray[0]
                            }
                        }else {
                            if obj.sharedWallData.thumbUrlArray.count > 0 {
                                url = obj.sharedWallData.thumbUrlArray[0]
                            }
                        }
                        
                        let imgView = UIImageView()
                        imgView.kf.setImage(with: URL(string: url), placeholder: UIImage(named: "video_thumbnail"), options:[.cacheOriginalImage], progressBlock: nil, completionHandler: { (resp) in
                        })
                    }
                }
            }
        }
    }
    
    
    
    @objc func pauseAllVisiblePlayers(){
        if  let visibleIndexPaths = self.tblFeeds.indexPathsForVisibleRows {
            for indexPath in visibleIndexPaths {
                
                if indexPath.section == feedSectionNo {
                    let tblCell = tblFeeds.cellForRow(at: indexPath)
                    if let objWallPost = arrwallPost[indexPath.row] as? WallPostModel {
                        if (objWallPost.sharedWallData == nil){
                            if let tblCell1 =  (tblCell as? FeedsTableViewCell)?.cvFeedsPost.visibleCells.first as? FeedsCollectionViewCell {
                                tblCell1.pauseVideo()
                            }
                        }else {
                            if  let tblCell1 =  (tblCell as? FeedsSharedTableViewCell)?.cvFeedsPost.visibleCells.first as? FeedsCollectionViewCell {
                                tblCell1.pauseVideo()
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let y = max(0.0, tblFeeds.contentOffset.y)
        
        // point for the top visible content
        let pt: CGPoint = CGPoint(x: 0, y: y + 200)
        
        if let idx = tblFeeds.indexPathForRow(at: pt) {
            if shoulAutoplayVideo() == true {
                let cellRect = tblFeeds.rectForRow(at: idx)
                if let superview = tblFeeds.superview {
                    let convertedRect = tblFeeds.convert(cellRect, to:superview)
                    let intersect = tblFeeds.frame.intersection(convertedRect)
                    let visibleHeight = intersect.height
                    let cellHeight = cellRect.height
                    
                    
                    if visibleHeight <= cellHeight/4 && arrwallPost.count > idx.row{
                        if idx.section == feedSectionNo {
                            if  let tblCell = tblFeeds.cellForRow(at: idx) {
                                guard let objWallPost = arrwallPost[idx.row] as? WallPostModel else {
                                    return
                                }
                                
                                self.pauseAllVisiblePlayers()
                                
                                /* if (objWallPost.sharedWallData == nil){
                                 
                                 if let tblCell1 =  (tblCell as? FeedsTableViewCell)?.cvFeedsPost.visibleCells.first as? FeedsCollectionViewCell {
                                 if tblCell1.videoView.state == .playing {
                                 self.pauseAllVisiblePlayers()
                                 }
                                 }
                                 }else {
                                 if let tblCell1 =  (tblCell as? FeedsSharedTableViewCell)?.cvFeedsPost.visibleCells.first as? FeedsCollectionViewCell {
                                 if tblCell1.videoView.state == .playing {
                                 self.pauseAllVisiblePlayers()
                                 }
                                 }
                                 }*/
                            }
                        }
                    }else {
                        playVideoAtIndexPath(selIndexPath: idx)
                    }
                }
            }
        }
    }
    
    
    func playVideoAtIndexPath(selIndexPath:IndexPath)  {
        
        let cellRect = tblFeeds.rectForRow(at: selIndexPath)
        
        if let superview = tblFeeds.superview {
            
            let convertedRect = tblFeeds.convert(cellRect, to:superview)
            let intersect = tblFeeds.frame.intersection(convertedRect)
            let visibleHeight = intersect.height
            let cellHeight = cellRect.height
            
            if ((visibleHeight + 20.0) >= cellRect.width || (visibleHeight + 20.0) >= cellHeight || isAutopPlayFirstIndex == true) && (arrwallPost.count > selIndexPath.row){
                self.isAutopPlayFirstIndex = false
                guard  let objWallPost = arrwallPost[selIndexPath.row] as? WallPostModel else{
                    return
                }
                
                if shoulAutoplayVideo() == true {
                    
                    if  selIndexPath.section == feedSectionNo && isDataLoading == false{
                        if  let tblCell = tblFeeds.cellForRow(at: selIndexPath) {
                            
                            let isTrue = (objWallPost.sharedWallData == nil) ? (tblCell as? FeedsTableViewCell)?.isVideoActive ?? false : (tblCell as? FeedsSharedTableViewCell)?.isVideoActive ?? false
                            if  isTrue {
                                if (objWallPost.sharedWallData == nil){
                                    let tblCell1 =  (tblCell as! FeedsTableViewCell).cvFeedsPost.visibleCells.first as? FeedsCollectionViewCell
                                    if tblCell1?.videoView.state != .playing {
                                        pauseAllVisiblePlayers()
                                        tblCell1?.playVideo()
                                    }
                                }else {
                                    let tblCell1 =  (tblCell as! FeedsSharedTableViewCell).cvFeedsPost.visibleCells.first as? FeedsCollectionViewCell
                                    if tblCell1?.videoView.state != .playing {
                                        pauseAllVisiblePlayers()
                                        tblCell1?.playVideo()
                                        
                                    }
                                }
                                
                            }
                        }
                    }
                }
                
            }else  if visibleHeight <= cellHeight/2   && arrwallPost.count > selIndexPath.row{
                if shoulAutoplayVideo() == true {
                    
                }
                
            }
            
        }
    }
}

extension FeedsViewController:BusinessMediaDelegate,LiveUsersFeedDelegate {
    
    func getLiveUserSelectedIndex(index:Int){
        self.emitLiveUSersList()
    }
    
    
    func clickedMediaWith(index:Int, parentIndex:Int){
        
        if let objClipSuggestions =  arrwallPost[parentIndex] as? ClipSuggestionModel {
            if let objWallPost =  objClipSuggestions.payload[index] as? WallPostModel{
                self.pauseAllVisiblePlayers()
                let vc =
                StoryBoard.feeds.instantiateViewController(withIdentifier: "FeedsVideoViewController") as! FeedsVideoViewController
                
                vc.objWallPost = objWallPost
                vc.firstVideoIndex = 0
                vc.videoType = .feed
                vc.isRandomVideos = true
                vc.arrFeedsVideo = objClipSuggestions.payload
                vc.arrFeedsVideo.remove(at: index)
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
        
        
    }
}


extension FeedsViewController:StoriesDelegate,FeedsCommentDelegate,StoryPageViewControllerDelegate {
    
    
    //MARK: Comment Delegate
    func commentAdded(commentText: String, selPostIndex: Int, isFromShared: Bool, isFromDelete:Bool,commentCount:Int16) {
        
        guard  var objWallPost = arrwallPost[selPostIndex] as? WallPostModel else{
            return
        }
        
        let count =  (isFromDelete == true ) ? (objWallPost.totalComment - 1) : (objWallPost.totalComment + 1)
        
        objWallPost.totalComment = count
        arrwallPost[selPostIndex] = objWallPost
        let indexPth:IndexPath = IndexPath(row: selPostIndex, section: feedSectionNo)
        
        var cell:FeedsCell?
        if isFromShared == true {
            cell = tblFeeds.cellForRow(at: indexPth) as? FeedsSharedTableViewCell
        }else{
            cell = tblFeeds.cellForRow(at: indexPth) as? FeedsTableViewCell
        }
        cell?.btnCommentCount.setTitle(objWallPost.totalComment.asFormatted_k_String, for: .normal)
        
    }
    
    
    //MARK: - Delegate method of Stories cell
    
    func addNewStoryInFeeds(count:Int){
        if availableStatus == 1 && wallStatusArray.count == 0 {
            return
        }
        
        //userActivity: 1, // 0=user can't upload anything, 1= upload post, story, page-post, 2= upload post/story only, 3= upload page-post only
        if Settings.sharedInstance.userActivity == 1 || Settings.sharedInstance.userActivity == 2{
            let viewController:CreateWallStatusVC = StoryBoard.main.instantiateViewController(withIdentifier: "CreateWallStatusVC") as! CreateWallStatusVC
            viewController.isDisplayPhotos = true
            viewController.uploadedCount = count
            self.navigationController?.pushView(viewController, animated: true)
        }else {
            
            AlertView.sharedManager.displayMessage(title: "", msg: Settings.sharedInstance.userActivityMessage, controller: self)
        }
    }
    
    func selectedHeaderOptionsInFeeds(selectionType:OptionFeedType){
        /*
         if selectionType == .postFeed{
         
         let viewController:CreateWallPostViewController = StoryBoard.feeds.instantiateViewController(withIdentifier: "CreateWallPostViewController") as! CreateWallPostViewController
         viewController.fromType = .feedPost
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
         
         
         let viewController:BusinessPageListingVC = StoryBoard.page.instantiateViewController(withIdentifier: "BusinessPageListingVC") as! BusinessPageListingVC
         self.navigationController?.pushView(viewController, animated: true)
         
         }else if selectionType == .reels{
         
         let viewController:RecordVideoVC = StoryBoard.main.instantiateViewController(withIdentifier: "RecordVideoVC") as! RecordVideoVC
         self.navigationController?.pushView(viewController, animated: true)
         
         }else if selectionType == .golive{
         
         let broadCasterVC:BroadcasterViewController = StoryBoard.main.instantiateViewController(withIdentifier: "BroadcasterViewController") as! BroadcasterViewController
         self.navigationController?.pushView(broadCasterVC, animated: true)
         
         }else if selectionType == .creategroup{
         
         let viewController:GroupListVC = StoryBoard.groups.instantiateViewController(withIdentifier: "GroupListVC") as! GroupListVC
         self.navigationController?.pushView(viewController, animated: true)
         }
         */
    }
    
    
    func  getSelectedStoriesIndex(index: Int){
        
        if wallStatusArray.count <= ((availableStatus == 1) ? index : index - 1) {
            return
        }
        
        let vc = StoryBoard.main.instantiateViewController(withIdentifier: "StoryPageViewVC") as! StoryPageViewVC
        vc.isMyStatus = false
        vc.wallStatusArray  =  wallStatusArray
        vc.currentStatusIndex = (availableStatus == 1) ? index : index - 1
        
        vc.view.backgroundColor = .black
        //  vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
        vc.customDelegate = self
        // statusBarHidden = true
        setNeedsStatusBarAppearanceUpdate()
        //delegate?.isStatusBarHidden(true)
        //  self.presentView(vc, animated: true)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func DidDismiss() {
        
        
        self.getAllStatusListApi(isToShowLoader: true)
        
    }
    
    func didclickedViewCount(){
        let profileVC:LikeUsersVC = StoryBoard.main.instantiateViewController(withIdentifier: "LikeUsersVC") as! LikeUsersVC
        profileVC.controllerType = .storyView
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func didClickDelete(_ messageFrame: WallStatus.StoryStaus) {
        
        let param:NSDictionary = ["statusId":messageFrame.statusId]
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeDeleteAPICall(url:Constant.sharedinstance.deleteStoryStatus as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"]  as? Int64  ?? 0
                
                let message = result["message"]
                
                if status == 1{
                    self.getAllStatusListApi(isToShowLoader: false)
                    AlertView.sharedManager.displayMessage(title: "PickZon", msg: message as! String, controller: self)
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    //MARK: Delegete method of bottom sheet view
    /*  func selectedOption(index:Int,videoIndex:Int,title:String) {
     
     guard let objPost = arrwallPost[videoIndex] as? WallPostModel else{
     return
     }
     
     
     var urlArray:Array<String> = Array<String>()
     
     if objPost.sharedWallData == nil {
     urlArray = objPost.urlArray
     }else {
     urlArray = objPost.sharedWallData.urlArray
     }
     
     if objPost.userInfo?.fromId == Themes.sharedInstance.Getuser_id() {
     //Logged in user post
     
     switch index {
     case 0:
     AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to delete selected post?", buttonTitles: ["Yes","No"], onController: self) { title, index in
     
     if index == 0{
     self.deleteWallPostApi(postIndex: videoIndex)
     }
     }
     break
     case 1:
     if objPost.sharedWallData == nil {
     //Edit Post
     let viewController:CreateWallPostViewController = StoryBoard.feeds.instantiateViewController(withIdentifier: "CreateWallPostViewController") as! CreateWallPostViewController
     viewController.urlSelectedItemsArray = objPost.urlArray.map({ urlstr in
     return (URL(string: urlstr) ?? URL(string: ""))!
     })
     viewController.uploadDelegate = self
     viewController.objPost = objPost
     viewController.isFromEdit = true
     viewController.isFromProfile = false
     self.navigationController?.pushViewController(viewController, animated: true)
     
     }else {
     if urlArray.count == 0 || title == "Share"{
     ShareMedia.shareMediafrom(type: .post, mediaId: objPost.id, controller: self)
     }else{
     self.downloadAllMedia(urlArray: urlArray)
     }
     }
     break
     case 2:
     if urlArray.count == 0 || title == "Share"{
     ShareMedia.shareMediafrom(type: .post, mediaId: objPost.id, controller: self)
     }else{
     self.downloadAllMedia(urlArray: urlArray)
     }
     break
     
     case 3:
     ShareMedia.shareMediafrom(type: .post, mediaId: objPost.id, controller: self)
     break
     
     default:
     break
     }
     
     }else{
     switch index {
     case 0:
     self.blockPostApi(postIndex: videoIndex)
     break
     case 1:
     self.messageAlertWithReport(postIndex: videoIndex)
     break
     case 2:
     if urlArray.count == 0 || title == "Share"{
     ShareMedia.shareMediafrom(type: .post, mediaId: objPost.id, controller: self)
     }else{
     self.downloadAllMedia(urlArray: urlArray)
     }
     break
     case 3:
     ShareMedia.shareMediafrom(type: .post, mediaId: objPost.id, controller: self)
     break
     
     default:
     break
     }
     
     }
     
     }
     
     func messageAlertWithReport(postIndex:Int) {
     
     let alertController = UIAlertController(title: "Report", message: "", preferredStyle: .alert)
     
     let saveAction = UIAlertAction(title: "Submit", style: .default, handler: { alert -> Void in
     let firstTextField = alertController.textFields![0] as UITextField
     if (firstTextField.text?.trim().count ?? 0 > 0){
     self.reportPostApi(postIndex: postIndex,message: firstTextField.text!)}
     
     })
     let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
     (action : UIAlertAction!) -> Void in })
     alertController.addTextField { (textField : UITextField!) -> Void in
     textField.placeholder = "Report message"
     }
     
     alertController.addAction(saveAction)
     alertController.addAction(cancelAction)
     
     self.present(alertController, animated: true, completion: nil)
     }
     */
}


//Database implementation
extension FeedsViewController {
    
    func saveFeedsDataInDB(objDataArray:Array<Dictionary<String,Any>>){
        
        managedContext = self.persistentContainer.viewContext
        
        let entity =  NSEntityDescription.entity(forEntityName: "FeedsModel",
                                                 in:managedContext!)
        let device = NSManagedObject(entity: entity!,
                                     insertInto: managedContext)
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: objDataArray, requiringSecureCoding: true)
            device.setValue(data, forKey: "feedsDataArray")
        }
        catch {
            print("Couldn't save to file")
        }
        do {
            try managedContext?.save()
        } catch let error as NSError  {
            print("Could not save: saveFeedsDataInDB \(error), \(error.localizedDescription)")
        }
    }
    
    func fetchFeedsDataFromDB()->Array<Any> {
        managedContext = self.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FeedsModel")
        var arrayOfObj: Array<Any> = []
        do {
            let results   = try managedContext!.fetch(fetchRequest)
            for result in results as! [FeedsModel] {
                autoreleasepool {
                    let data = result.feedsDataArray! as NSData
                    let unarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: data as Data)
                    let arrayObject = unarchiveObject as AnyObject? as! Array<Any>
                    arrayOfObj.append(contentsOf: arrayObject)
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error.localizedDescription)")
        }
        return arrayOfObj
    }
    
    
    func removeFeedsDataFromDB(){
        
        managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FeedsModel")
        do {
            let results   = try managedContext!.fetch(fetchRequest)
            for result in results {
                autoreleasepool {
                    managedContext?.delete(result as! NSManagedObject)
                }
                
            }

        } catch let error as NSError {
          print("Could not fetch \(error)")
        }
        
        do {
            try managedContext?.save()
        } catch let error as NSError  {
            print("Could not save: removeFeedsDataFromDB \(error), \(error.localizedDescription)")
        }
        
        
    }
    
    func removeFeedsFriendSuggestionDataFromDB(){
        
        managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FeedsModel")
        do {
            let results   = try managedContext!.fetch(fetchRequest)
            for result in results as! [FeedsModel]{
                autoreleasepool {
                    let data = result.feedsDataArray! as NSData
                    let unarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: data as Data)
                    var arrayObject = unarchiveObject as AnyObject? as! Array<Any>
                    for obj in arrayObject as! [NSDictionary]{
                        autoreleasepool {
                            if obj["viewType"] as? Int ?? 0 == 2 {
                                if let index = (arrayObject as? [NSDictionary])?.index(where: {$0["viewType"] as? Int ?? 0 == 2}){
                                    arrayObject.remove(at: index)
                                }
                            }
                        }
                    }
                    do {
                        let data1 = try NSKeyedArchiver.archivedData(withRootObject: arrayObject, requiringSecureCoding: true)
                        result.setValue(data1, forKey: "feedsDataArray")
                    }catch let error as NSError {
                        print("Could not fetch \(error)")
                    }
                }
            }
        
        
    } catch let error as NSError {
        print("Could not fetch \(error)")
    }
    
        do {
            try managedContext?.save()
        } catch let error as NSError  {
            print("Could not save: removeFeedsDataFromDB \(error), \(error.localizedDescription)")
        }
        
    }
    
    func removeFeedsFriendSuggestionWithId(id:String){
        
        managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FeedsModel")
        do {
            let results   = try managedContext!.fetch(fetchRequest)
            for result in results as! [FeedsModel]{
                autoreleasepool {
                    let data = result.feedsDataArray! as NSData
                    let unarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: data as Data)
                    var arrayObject = unarchiveObject as AnyObject? as! Array<Any>
                    for var obj in arrayObject as! [Dictionary<String, Any>]{
                        autoreleasepool {
                            
                            if obj["viewType"] as? Int ?? 0 == 2 {
                                
                                var arrFriendSuggestion = obj["friendSuggestionData"] as? Array<Any> ?? []
                                if let ind = (arrayObject as? [NSDictionary])?.index(where: {$0["viewType"] as? Int ?? 0 == 2}){
                                    if let index = (arrFriendSuggestion as? [NSDictionary])?.index(where: {$0["id"] as? String ?? "" == id }){
                                        
                                        arrFriendSuggestion.remove(at: index)
                                        
                                    }
                                    
                                    obj["friendSuggestionData"] = arrFriendSuggestion
                                    arrayObject[ind] = obj
                                }
                                
                            }
                        }
                    }
                    do {
                        let data1 = try NSKeyedArchiver.archivedData(withRootObject: arrayObject, requiringSecureCoding: true)
                        result.setValue(data1, forKey: "feedsDataArray")
                    }catch let error as NSError {
                        print("Could not fetch \(error)")
                    }
                    
                    do {
                        try managedContext?.save()
                    } catch let error as NSError  {
                        print("Could not save: removeFeedsDataFromDB \(error), \(error.localizedDescription)")
                    }
                }
                
            }
        
        
    } catch let error as NSError {
        print("Could not fetch \(error)")
    }
        
        
    }
    
  
    func saveStoryDataInDB(objDataDict:Dictionary<String, Any>){
        
        
        managedContext = self.persistentContainer.viewContext
        let entity =  NSEntityDescription.entity(forEntityName: "StoryDataModel",
                                                 in:managedContext!)
        let objManaged = NSManagedObject(entity: entity!,
                                         insertInto: managedContext)
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: objDataDict)
            objManaged.setValue(data, forKey: "stortyDataArray")
        }
        catch {
            print("Couldn't save to file")
        }
        do {
            try managedContext?.save()
        } catch let error as NSError  {
            print("Could not save: saveStoryDataInDB \(error), \(error.localizedDescription)")
        }
        
    }
    
  
    func fetchStoryDataFromDB()->Array<Any> {
        
        managedContext = self.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StoryDataModel")
        var arrayOfObj: Array<Any> = []
        do {
            let results   = try managedContext!.fetch(fetchRequest)
            
            for result in results as! [StoryDataModel] {
                autoreleasepool {
                    if let data = result.stortyDataArray as? NSData{
                        
                        let unarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: data as Data)
                        if  let payloadDict = unarchiveObject as? Dictionary<String,Any>{
                            self.availableStatus = payloadDict["availableStatus"] as? Int ?? 0
                            if let arrayObject = payloadDict["wallstatus"]  as? Array<Any>{
                                arrayOfObj = arrayObject
                            }
                        }
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error.localizedDescription)")
        }
        
        return arrayOfObj
    }
    
    
    func removeStoryDataFromDB(){
        
        managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StoryDataModel")
        do {
            let results   = try managedContext!.fetch(fetchRequest)
            if results.count > 0 {
                for result in results {
                    autoreleasepool {
                        managedContext?.delete(result as! NSManagedObject)
                    }
                    
                }
                
                DispatchQueue.main.async { [weak self] in
                    do {
                        try? self?.managedContext?.save()
                    } catch let error as NSError  {
                        print("Could not save: removeStoryDataFromDB \(error), \(error.localizedDescription)")
                    }
                }
                
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
        
        
    }
    
}

extension FeedsViewController:ExpandableLabelDelegate,SuggestionDelegate{
  
    func numberTextClicked(_ label: ExpandableLabel, number: String) {
        
        let point = label.convert(CGPoint.zero, to: tblFeeds)
        if let indexPath = tblFeeds.indexPathForRow(at: point) as IndexPath? {
            if let objWallPost = arrwallPost[indexPath.row] as? WallPostModel {
                if objWallPost.sharedWallData == nil {
                    if objWallPost.userInfo?.celebrity == 1 || objWallPost.userInfo?.celebrity == 4{
                        if let url = URL(string: "tel://\(number)"),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }else {
                    if objWallPost.sharedWallData.userInfo?.celebrity == 1 || objWallPost.sharedWallData.userInfo?.celebrity == 4{
                        if let url = URL(string: "tel://\(number)"),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
            }
        }
    }
    
    func hashTagTextClicked(_ label: ExpandableLabel, hashTag: String) {
        
        let destVc:WallPostViewVC = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
        destVc.controllerType = .hashTag
        destVc.hashTag = hashTag
        AppDelegate.sharedInstance.navigationController?.pushViewController(destVc, animated: true)
    }
    

    //MARK: Suggestion Delegate
    func seeAllList(){
        let storyboard = UIStoryboard(name: "Feeds", bundle: nil)
        let viewController:SuggestionListVC = storyboard.instantiateViewController(withIdentifier: "SuggestionListVC") as! SuggestionListVC
        self.navigationController?.pushView(viewController, animated: true)
    }
    
    func clickedUserIndex(index:Int, section: Int){
        if let obj = self.arrwallPost[section] as? FriendSuggestionModal {
            let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            profileVC.otherMsIsdn = obj.payload[index].id
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    func cancelSuggestionUser(index:Int,section:Int){
        print("cancelSuggestionUser")
        
//        AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: "Are you sure want to remove selected user from suggestion ?", buttonTitles: ["Yes","No"], onController: self) { title, btnIndex in
//            
           // if btnIndex == 0{
                self.removeSuggestionApi(index: index,section:section)
           // }
       // }
    }
    
    func clickedFollowUser(index:Int,section:Int){
        
        followUnfollowApi(index: index,isFromSuggestion:true,section:section)
    }
    
   
    // MARK: ExpandableLabel Delegate
    func willExpandLabel(_ label: ExpandableLabel) {
        tblFeeds.beginUpdates()
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        let point = label.convert(CGPoint.zero, to: tblFeeds)
        if let indexPath = tblFeeds.indexPathForRow(at: point) as IndexPath? {
            if states.count > indexPath.row {
                states[indexPath.row] = false
            }
           
        }
        tblFeeds.endUpdates()
    }
    
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        tblFeeds.beginUpdates()
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        let point = label.convert(CGPoint.zero, to: tblFeeds)
        if let indexPath = tblFeeds.indexPathForRow(at: point) as IndexPath? {
            states[indexPath.row] = true
            DispatchQueue.main.async { [weak self] in
                self?.tblFeeds.reloadRows(at: [indexPath], with: .none)
            }
        }
        tblFeeds.endUpdates()
    }
    
    func mentionTextClicked(_ label: ExpandableLabel,mentionText:String){
        
        print("mentionTextClicked \(mentionText)")
        
        let mentionString:String = mentionText
        self.getUserIdFromPickzonId(pickzonId: mentionString.replacingOccurrences(of: "@", with: ""))

    }
    
    func urlTextClicked(_ label: ExpandableLabel,strURL:String) {
        let point = label.convert(CGPoint.zero, to: tblFeeds)
        if let indexPath = tblFeeds.indexPathForRow(at: point) as IndexPath? {
            if let objWallPost = arrwallPost[indexPath.row] as? WallPostModel {
                if objWallPost.sharedWallData == nil {
                   if objWallPost.userInfo?.celebrity == 1 || objWallPost.userInfo?.celebrity == 4{
                        let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
                        vc.urlString = strURL
                        AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
                    }
                }else {
                    if objWallPost.sharedWallData.userInfo?.celebrity == 1 || objWallPost.sharedWallData.userInfo?.celebrity == 4{
                        let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
                        vc.urlString = strURL
                    AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
}


extension FeedsViewController {
    
    //MARK: Notification Observers

    
    @objc func sccrollFeedsToTop(notification: Notification) {
        
        self.tblFeeds.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
        
    }
    
    @objc func uploadingProgeress(notification: Notification) {
        
        if let messageDict = notification.object as? NSDictionary {

            if let progress = messageDict.object(forKey: "progress") as? Double {
                self.progress = progress
                self.isUploadingPost = true
                if let cell = tblFeeds.cellForRow(at: IndexPath(row: 1, section: 0)) as? FileUploadProgressTblCell{
                    if let mediaArray = messageDict.object(forKey: "url") as? Array<Any>  {
                        cell.setDataInProgress(progress: progress, mediaArray:  mediaArray)
                    }else{
                        cell.setDataInProgress(progress: progress, mediaArray: Array<Any>())
                    }
                }else{
                    self.tblFeeds.reloadData()
                }

            }else{
                
                if let cell = tblFeeds.cellForRow(at: IndexPath(row: 1, section: 0)) as? FileUploadProgressTblCell{
                    cell.imgVw.image = nil
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.isUploadingPost = false
                    self?.tblFeeds.reloadSections(IndexSet(integer: 0), with: .none)
                }
              
                let status = messageDict.object(forKey: "status") as? Int ?? 0
                let message = messageDict.object(forKey: "message") as? String ?? ""
                
                if isDataLoading == false && status == 1 {
                    let payloadDict = messageDict.object(forKey: "payload") as?  Dictionary<String,Any> ?? [:]
                    let updateFeed = payloadDict["updateFeed"] as? Int ?? 0

                    if payloadDict.count > 0  && updateFeed == 0{
                        
                        var index =  0
                        
                        if self.arrwallPost.count > 0 {
                            if ((arrwallPost[0] as? FriendSuggestionModal) != nil){
                                index = 1
                            }else  if ((arrwallPost[0] as? FeedBannerModel) != nil){
                                index = 1
                            }
                        }
                       
                        self.arrwallPost.insert(WallPostModel(dict: payloadDict as NSDictionary), at: index)
                        self.states.append(true)
                        self.tblFeeds.beginUpdates()
                        self.tblFeeds.insertRows(at: [IndexPath(row: index, section: feedSectionNo)], with: .top)
                        self.tblFeeds.endUpdates()
                        
                    }else if payloadDict.count > 0   && updateFeed == 1 {
                        
                        let objWallpost = WallPostModel(dict: payloadDict as NSDictionary)
                        if let editPostIndex = arrwallPost.firstIndex(where:{($0 as? WallPostModel)? .id == objWallpost.id}) {
                            self.arrwallPost[editPostIndex] = objWallpost
                            self.tblFeeds.reloadRows(at: [IndexPath(row: editPostIndex, section: feedSectionNo)], with: .none)
                        }
                    }
                    (AppDelegate.sharedInstance.navigationController?.topViewController)!.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    
                    //remove the draft
                    UserDefaults.standard.removeObject(forKey: "WallPostDraft")
                    UserDefaults.standard.synchronize()
                }
                
               
                
                
            }
        }
    }
    
    
    @objc func logoutNotification(notification: Notification) {
        
        if let messageDict = notification.userInfo as? NSDictionary {
            
            if let payloadDict = messageDict.object(forKey: "payload") as? NSDictionary {
                
                if payloadDict["userId"] as? String ?? "" == Themes.sharedInstance.Getuser_id(){
                    
                    if let message = messageDict.object(forKey: "message") as? String {
                        
                        AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["Ok"], onController: self) { title, index in
                            DBManager.shared.clearDB()
                            (UIApplication.shared.delegate as! AppDelegate).Logout(istocallApi: false)
                        }
                    }
                }
                
            }
        }
    }
    
    
    @objc func recieveFeedPostData(notification: Notification) {
        
        DispatchQueue.main.async { [weak self] in
            
            if let  delg =    UIApplication.shared.delegate as? AppDelegate {
                self?.pageNo =  delg.pageNo
            }
            self?.arrwallPost.removeAll()
            
            if self?.arrwallPost.count == 0{
                
                if let data = self?.fetchFeedsDataFromDB() {
                self?.states = [Bool](repeating: true, count: data.count)
                
                for obj in data {
                    autoreleasepool {
                        if (obj as! NSDictionary)["viewType"] as? Int ?? 0 == 0 {
                            
                            let objWallpostata = WallPostModel(dict: obj as! NSDictionary)
                            self?.arrwallPost.append(objWallpostata)
                        }else if (obj as! NSDictionary)["viewType"] as? Int ?? 0 == 2 {
                            
                            self?.arrwallPost.append(FriendSuggestionModal(respDict: (obj as! NSDictionary)))
                        }
                    }
                    
                }
                self?.tblFeeds.reloadData()
            }
            }
            self?.isDataLoading = false
            
        }
    }
    
    @objc func refreshWallPost(notification: Notification) {
        pageNo = 1
        self.indexFriendSuggestion = -1
        self.getAllWallPostAPIImplementation(pageNo: pageNo)
    }
    
    @objc func refreshCount(notification: Notification) {

        if let indexData = notification.userInfo?["count"] as? Int {
                Constant.sharedinstance.notificationCount = (indexData == 0) ? 0 : indexData
        }
        
        if let feedChatCount = notification.userInfo?["feedChatCount"] as? Int {
                Constant.sharedinstance.feedChatCount = feedChatCount
        }
        
        if let requestedChatCount = notification.userInfo?["requestedChatCount"] as? Int {
            
                if (Constant.sharedinstance.feedChatCount) == 0 {
                    self.btnChat.badgeString =  ""
                }
                Constant.sharedinstance.requestedChatCount = requestedChatCount
        }
        
        
        if  Constant.sharedinstance.notificationCount > 0 || Constant.sharedinstance.feedChatCount > 0{
            self.btnChat.badgeString =  "•"
        }else{
            self.btnChat.badgeString =  ""
        }
        
        self.btnChat.badgeLabel.font = UIFont.boldSystemFont(ofSize: 40)
        self.btnChat.badgeLabel.textAlignment = .left

    }
    
    
    @objc func refreshStoryList(notification: Notification) {
        feedSectionNo = 1
        self.getAllStatusListApi(isToShowLoader: false)
    }
    
    @objc func errorInVideoPlaying(notification: Notification) {
        if let objDict = notification.object as? Dictionary<String, Any> {
            let playingIndex = objDict["playingIndex"] as? Int ?? 0
            if  let visibleIndexPaths = self.tblFeeds.indexPathsForVisibleRows {
                for indexPath in visibleIndexPaths {
                    if indexPath.section == feedSectionNo  && indexPath.row == playingIndex {
                        DispatchQueue.main.async { [weak self] in
                            self?.tblFeeds.reloadRows(at: [indexPath], with: .none)
                        }
                    }
                }
            }
        }
    }
    @objc func backFromVideosScreen(notification: Notification) {
        
        if let objDict = notification.object as? Dictionary<String, Any> {
            let playingIndex = objDict["playingIndex"] as? Int ?? 0
            if playingIndex != 0 {
                self.getFeedsVideosAPI()
            }
        }
    }
    
    //Cell delegate methods Notification Received
    @objc func feedCommentAddedNotification(notification: Notification) {
        
        //print("Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
           // let commentText = objDict["commentText"] as? String ?? ""
            let isFromShared = objDict["isFromShared"] as? Bool ?? false
            let isFromDelete = objDict["isFromDelete"] as? Bool ?? false
            let commentCount = objDict["commentCount"] as? Int16 ?? 0
           // let isCollageView = objDict["isCollageView"] as? Bool ?? false
            
            if let selPostIndex = arrwallPost.firstIndex(where:{($0 as? WallPostModel)? .id == feedId}) {
                guard  var objWallPost = arrwallPost[selPostIndex] as? WallPostModel else{
                    return
                }
                
                let count =  (isFromDelete == true ) ? (objWallPost.totalComment - 1) : (objWallPost.totalComment + 1)
                
                objWallPost.totalComment = count
                arrwallPost[selPostIndex] = objWallPost
                let indexPth:IndexPath = IndexPath(row: selPostIndex, section: feedSectionNo)
                
                var cell:FeedsCell?
                if isFromShared == true {
                    if let cell1  = tblFeeds.cellForRow(at: indexPth) as? FeedsSharedTableViewCell {
                        cell = cell1
                    }
                }else{
                    if let cell1 = tblFeeds.cellForRow(at: indexPth) as? FeedsTableViewCell {
                        cell = cell1
                    }
                }
               cell?.objWallPost = objWallPost
               cell?.updatedCommentLikeAndShareCount(objwallpost: objWallPost)
            }
        }
         
        
    }
    
    @objc func feedsLikedReceivedNotification(notification: Notification) {
        
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            let isLike = objDict["isLike"] as? Int16 ?? 0
            let likeCount = objDict["likeCount"] as? UInt ?? 0
            
            
            if let objIndex = arrwallPost.firstIndex(where:{($0 as? WallPostModel)?.id == feedId}) {
                var objWallPost = arrwallPost[objIndex] as! WallPostModel
                objWallPost.isLike = isLike
                objWallPost.totalLike = likeCount
                self.arrwallPost[objIndex] = objWallPost
                
                var cell:FeedsCell?
                //var urlArrayCount = 0
                
                if objWallPost.sharedWallData == nil {
                    if let cell1 = self.tblFeeds.cellForRow(at: IndexPath(row: objIndex, section: self.feedSectionNo)) as? FeedsTableViewCell {
                        cell = cell1
                    }
                   // urlArrayCount = objWallPost.urlArray.count
                }else{
                    if let cell1  = self.tblFeeds.cellForRow(at: IndexPath(row: objIndex, section: self.feedSectionNo)) as? FeedsSharedTableViewCell {
                        cell = cell1
                    }
                   // urlArrayCount = objWallPost.sharedWallData.urlArray.count
                }
                
                cell?.updatedCommentLikeAndShareCount(objwallpost: objWallPost)
                cell?.objWallPost = objWallPost
                cell?.btnLike.setImage( (objWallPost.isLike == 1) ? PZImages.heart_Filled : PZImages.heart_blank, for: .normal)
                
                let visibleRect = CGRect(origin: (cell?.cvFeedsPost.contentOffset) ?? .zero, size: (cell?.cvFeedsPost.bounds.size) ?? .zero)
                let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
                if let visibleIndexPath = cell?.cvFeedsPost.indexPathForItem(at: visiblePoint) {
                    if let cvCell = cell?.cvFeedsPost.cellForItem(at: visibleIndexPath) as? FeedsCollectionViewCell {
                        cvCell.objWallPost = objWallPost
                    }
                }
            }
        }
    }
    
    @objc func feedRemovedNotification(notification: Notification) {
        
        if let objDict = notification.object as? Dictionary<String, Any> {
                let feedId = objDict["feedId"] as? String ?? ""
                
                if let objIndex = arrwallPost.firstIndex(where:{($0 as? WallPostModel)?.id == feedId}) {
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.arrwallPost.remove(at: objIndex)
                        self?.tblFeeds.beginUpdates()
                        let indexPath = IndexPath(row: objIndex, section: self?.feedSectionNo ?? 1)
                        self?.tblFeeds.deleteRows(at: [indexPath] , with: .fade)
                        self?.tblFeeds.endUpdates()
                        self?.tblFeeds.reloadData()
                    }
            }
        }
    }
    
    @objc func feedTagRemovedNotification(notification: Notification) {
       
        if let objDict = notification.object as? Dictionary<String, Any> {
                let feedId = objDict["feedId"] as? String ?? ""
                
                if let objIndex = arrwallPost.firstIndex(where:{($0 as? WallPostModel)?.id == feedId}) {
                    if var objWallpost = arrwallPost[objIndex] as? WallPostModel {
                        objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "@\(Themes.sharedInstance.getPickzonId())", with: "")
                        objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "  ", with: " ")
                        self.arrwallPost[objIndex] = objWallpost
                        DispatchQueue.main.async { [weak self] in
                            self?.tblFeeds.reloadData()
                        }
                    }
                    
            }
        }
    }
    
    
    @objc func feedExpandedNotification(notification: Notification) {
        
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            let isExpanded = objDict["isExpanded"] as? Bool ?? false
            
            if let objIndex = arrwallPost.firstIndex(where:{($0 as? WallPostModel)?.id == feedId}) {
                
                var objWallPost = arrwallPost[objIndex] as! WallPostModel
                objWallPost.isExpanded = isExpanded
                arrwallPost[objIndex] = objWallPost
                tblFeeds.reloadRows(at: [IndexPath(row: objIndex, section: feedSectionNo)], with: .none)
            }
        }
    }
    
    @objc func feedFollwedNotification(notification: Notification) {

        if let objDict = notification.object as? Dictionary<String, Any> {
            let userId = objDict["userId"] as? String ?? ""
            let isFollowed = objDict["isFollowed"] as? Int ?? 0
          //  let isCollageView = objDict["isCollageView"] as? Bool ?? false
            
            for index in 0..<arrwallPost.count {
                autoreleasepool {
                    if var  objWallPost = arrwallPost[index] as? WallPostModel{
                        
                        if objWallPost.sharedWallData == nil {
                            if objWallPost.userInfo?.id == userId{
                                
                                objWallPost.isFollowed = isFollowed
                                arrwallPost[index] = objWallPost
                                
                                var cell:FeedsCell?
                                
                                if let cell1 = self.tblFeeds.cellForRow(at: IndexPath(row: index, section: self.feedSectionNo)) as? FeedsTableViewCell{
                                    cell = cell1
                                }
                                cell?.btnFolow.isHidden = objWallPost.isFollowed >= 1 ? true : false
                                cell?.objWallPost = objWallPost
                            }
                        }else {
                            
                            var cell:FeedsCell?
                            if let cell1 = self.tblFeeds.cellForRow(at: IndexPath(row: index, section: self.feedSectionNo)) as? FeedsSharedTableViewCell {
                                cell = cell1
                            }
                            if objWallPost.userInfo?.id == userId{
                                objWallPost.isFollowed = isFollowed
                                cell?.btnFolow.isHidden = objWallPost.isFollowed >= 1 ? true : false
                            }
                            if objWallPost.sharedWallData.userInfo?.id == userId{
                                objWallPost.sharedWallData.isFollowed = isFollowed
                                cell?.btnSharedFollow.isHidden = objWallPost.sharedWallData.isFollowed == 1 ? true : false
                            }
                            arrwallPost[index] = objWallPost
                            cell?.objWallPost = objWallPost
                            
                        }
                    }
                }
                
            }
        }
    }
    
    @objc func feedSavedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            
            
            let feedId = objDict["feedId"] as? String ?? ""
            let isSave = objDict["isSave"] as? Int16 ?? 0
           // let isCollageView = objDict["isCollageView"] as? Bool ?? false
            if let objIndex = arrwallPost.firstIndex(where:{($0 as? WallPostModel)?.id == feedId}) {
                
                var objWallPost = arrwallPost[objIndex] as! WallPostModel
                objWallPost.isSave = isSave
                arrwallPost[objIndex] = objWallPost
                
                var cell:FeedsCell?
                
                if objWallPost.sharedWallData == nil {
                    cell = self.tblFeeds.cellForRow(at: IndexPath(row: objIndex, section: self.feedSectionNo)) as? FeedsTableViewCell
                    
                }else{
                    cell = self.tblFeeds.cellForRow(at: IndexPath(row: objIndex, section: self.feedSectionNo)) as? FeedsSharedTableViewCell
                    
                }
                
                cell?.btnSavePost.setImage( (objWallPost.isSave == 1) ? PZImages.feedsSavePostRed : PZImages.feedsSavePost, for: .normal)

            }
            
        }
        
    }
    
    @objc func noti_BoostedPost(notification: Notification) {
        
        if let objDict = notification.object as? Dictionary<String, Any> {
            
            let feedId = objDict["feedId"] as? String ?? ""
            let boost = objDict["boost"] as? Int ?? 0
            
            if let selPostIndex = arrwallPost.firstIndex(where:{($0 as? WallPostModel)?.id == feedId}) {

                var objWallPost = arrwallPost[selPostIndex] as! WallPostModel
                objWallPost.boost = boost
                arrwallPost[selPostIndex] = objWallPost
                
                let indexPth:IndexPath = IndexPath(row: selPostIndex, section: feedSectionNo)
                if let cell1 = tblFeeds.cellForRow(at: indexPth) as? FeedsTableViewCell {
                    cell1.objWallPost = objWallPost
                    cell1.btnBoost.setTitle("In Review", for: .normal)
                }
            }
        }
    }

}


extension FeedsViewController : UploadFilesDelegate {
    
    func uploadSelectedFilesDuringPost(thumbUrlArray:Array<Any>,mediaArray : [URL],mediaName:String, url:String, params:NSMutableDictionary,method:HTTPMethod?){
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
                    
                    mediaArray.removeSavedURLFiles()
                    thumbUrlArray.removeSavedURLFiles()
                    if status == 1{
                        
                    }else{
                        AppDelegate.sharedInstance.navigationController?.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)

                       // self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            }
        }
    }
}

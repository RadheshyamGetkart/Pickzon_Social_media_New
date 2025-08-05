//
//  WallPostViewVC.swift
//  SCIMBO
//
//  Created by Getkart on 07/07/21.
//  Copyright © 2021 GETKART. All rights reserved.
//

import UIKit
import FittedSheets
import IHKeyboardAvoiding
import IQKeyboardManager
import SCIMBOEx
import RxSwift


enum PostType{

    case isFromNotification
    case isFromSaved
    case isFromPost
    case isFromTaggedPost
    case isFromSharedPost
    case isFromLiveVideos
    case hashTag
    case isFromRandomMedia
    case hashTagSearched
}


protocol CallBackProfileDelegate: AnyObject{
    
    func getUpdatedData(postbj:WallPostModel)
    func getNewPageList(listArray:Array<WallPostModel>,pageNo:Int,postType:PostType)
}




class WallPostViewVC: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblNavTitle: UILabel!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    var controllerType:PostType = .isFromPost
    var arrwallPost:Array<WallPostModel> = Array<WallPostModel>()
    var selRowIndex = 0
    var postId = ""
    var emptyView:EmptyList?
    var fromType:CreatePostType?
    var pageNo = 1
    var pageLimit = 18
    var isDataLoading = false
    var followMsIsdn = ""
    var hashTag = ""
    var states : Array<Bool>!
    weak var delegate:CallBackProfileDelegate? = nil
    var isDataMoreAvailable = false
    
    //used to pause the video when there is scrolling at the time of back button pressed.
    var isBackBtnPressed = false
    
    
    lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemBlue
        return refreshControl
    }()
    
    
    //MARK: - Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        tblView.register(UINib(nibName: "FeedsTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedsTableViewCell")
        tblView.register(UINib(nibName: "FeedsCollageTblCell", bundle: nil), forCellReuseIdentifier: "FeedsCollageTblCell")
        tblView.register(UINib(nibName: "FeedsSharedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedsSharedTableViewCell")
        tblView.register(UINib(nibName: "FeedsCollageSharedTblCell", bundle: nil), forCellReuseIdentifier: "FeedsCollageSharedTblCell")
        tblView.register(UINib(nibName: "LoadMoreTblCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTblCell")
        KeyboardAvoiding.avoidingView = self.tblView
        tblView.rowHeight = 200 + self.view.frame.size.width
        tblView.estimatedRowHeight = UITableView.automaticDimension
        
        emptyView = EmptyList(frame: CGRect(x: 0, y: -64, width: tblView.frame.size.width, height: tblView.frame.size.height))
        self.tblView.addSubview(emptyView!)
        emptyView?.imageView?.image = PZImages.noData 
        emptyView?.lblMsg?.text = "No Posts"
        emptyView?.isHidden = true
        
        self.isDataMoreAvailable = (arrwallPost.count > 6) ? true : false
        
        if controllerType == .isFromNotification {
            lblNavTitle.text = "Posts"
            getSingleWallPost()
        }else if controllerType == .isFromPost || controllerType == .isFromSharedPost || controllerType == .isFromTaggedPost {
            lblNavTitle.text = "Posts"
            
        }else if controllerType == .isFromSaved {
            lblNavTitle.text = "Saved Posts"
            getSavedPostListApi()
        }else if controllerType == .isFromTaggedPost {
            lblNavTitle.text = "Tagged Posts"
            
        }else if controllerType == .isFromSharedPost {
            lblNavTitle.text = "Shared Posts"
            
        }else if controllerType == .isFromLiveVideos {
            lblNavTitle.text = "Go Live Posts"
            
        }else if controllerType == .hashTag {
            lblNavTitle.text = "\(hashTag.length > 0 ? hashTag:"Posts")"
                pageNo = 1
                self.getPostByTagNameApi()
        }else if controllerType == .hashTagSearched || controllerType == .isFromRandomMedia {
            lblNavTitle.text = "\(hashTag.length > 0 ? hashTag:"Posts")"
        }
        
        self.states = [Bool](repeating: true, count: self.arrwallPost.count)
        self.tblView.separatorStyle = .none
        self.tblView.reloadData()
        
        if self.arrwallPost.count > 0 {
            self.tblView.isPagingEnabled = true
            self.tblView.scrollToRow(at: IndexPath(row: self.selRowIndex, section: 0), at: .top, animated: false)
            self.tblView.isPagingEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.playVideoAtIndexPath(selIndexPath: IndexPath(row: self.selRowIndex, section: 0))
            }
        }else if controllerType == .isFromPost{
            self.getUserPostListApi()
            self.tblView.refreshControl = topRefreshControl
        }
        self.addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isBackBtnPressed = false
        Themes.sharedInstance.isClipVideo = 0
        IQKeyboardManager.shared().isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isBackBtnPressed = true
        self.pauseAllVisiblePlayers()
        super.viewWillDisappear(animated)
    }
   
    deinit{
        
        self.delegate = nil
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: notif_FeedLiked, object: nil)
        NotificationCenter.default.removeObserver(self, name: notif_FeedRemoved, object: nil)
        NotificationCenter.default.removeObserver(self, name: notif_TagRemoved, object: nil)
        NotificationCenter.default.removeObserver(self, name: notif_feedExpanded, object: nil)
        NotificationCenter.default.removeObserver(self, name: notif_FeedFollowed, object: nil)
        NotificationCenter.default.removeObserver(self, name: nofit_CommentAdded, object: nil)
        NotificationCenter.default.removeObserver(self, name: nofit_FeedSaved, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Constant.sharedinstance.app_PausePlayer), object: nil)
    }
    
    
    //MARK: Pull to refresh
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
        if !isDataLoading{
            self.isDataLoading = true
            pageNo = 1
            self.getUserPostListApi()
        }
        refreshControl.endRefreshing()
        topRefreshControl.endRefreshing()
    }
    
    func addObservers() {
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedsLikedReceivedNotification(notification:)), name: notif_FeedLiked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedRemovedNotification(notification:)), name: notif_FeedRemoved, object: nil)
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.feedTagRemovedNotification(notification:)), name: notif_TagRemoved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedExpandedNotification(notification:)), name: notif_feedExpanded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedFollwedNotification(notification:)), name: notif_FeedFollowed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedCommentAddedNotification(notification:)), name: nofit_CommentAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedSavedNotification(notification:)), name: nofit_FeedSaved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(app_Minimize_PausePlayer), name: NSNotification.Name(Constant.sharedinstance.app_PausePlayer), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.noti_BoostedPost(notification:)), name: noti_Boosted, object: nil)
        
    }
   
    @objc func app_Minimize_PausePlayer() {
        self.pauseAllVisiblePlayers()

    }
    //MARK: - UIButton Action Methods
    @IBAction func backBtnAction(_ sender: Any) {
        isBackBtnPressed = true
        self.pauseAllVisiblePlayers()
        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.navigationController?.popViewController(animated: true)
        //}
    }
    
    //MARK: - API Implementation
        
        func getUserIdFromPickzonId(pickzonId:String){

        Themes.sharedInstance.activityView(View: self.view)
        
        let params = NSMutableDictionary()
        let url:String = Constant.sharedinstance.getmsisdn + "?pickzonId=\(pickzonId)"
        
        URLhandler.sharedinstance.makeGetAPICall(url:url, param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
                let message = result["message"] as? String ?? ""
                if status == 1{
                    let payload = result["payload"] as? Dictionary<String, Any> ?? [:]
                    DispatchQueue.main.async {
                        let viewController:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                        viewController.otherMsIsdn = payload["userId"] as? String ?? ""
                        self.navigationController?.pushView(viewController, animated: true)
                    }
                }else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    func getSingleWallPost(){
        
        let param:NSDictionary =  [:] //["wallPostId":postId]
        
        Themes.sharedInstance.activityView(View: self.view)
        
        let url = "\(Constant.sharedinstance.getSingleWallPost)/\(postId)"
        
        URLhandler.sharedinstance.makeGetAPICall(url: url, param: param) { responseObject, error in
    
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    self.arrwallPost.removeAll()

                    if  let payloadDict = result.value(forKey: "payload") as? NSDictionary{
                        if payloadDict.count > 0 {
                            let objPost = WallPostModel(dict: payloadDict)
                            self.arrwallPost.append(objPost)
                            
                            
                            self.states = [Bool](repeating: true, count: self.arrwallPost.count)
                            
                            DispatchQueue.main.async {
                                self.tblView.reloadData()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.playVideoAtIndexPath(selIndexPath: IndexPath(row: self.selRowIndex, section: 0))
                            }
                        }else {
                            
                            self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                        }
                    }
                }else{
                   // self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
                DispatchQueue.main.async {
                    self.emptyView?.isHidden = (self.arrwallPost.count) == 0 ? false : true
                    self.emptyView?.lblMsg?.text = message

                }
                
            }
        }
    }
    
        
    func getPostByTagNameApi(){
        
        let param:NSDictionary = ["keyword":hashTag,"pageNumber":pageNo]
      //  let param:Dictionary<String,Any> = ["keyword": hashTag,"pageNumber":pageNo]
              
        
        if self.pageNo == 1{
            Themes.sharedInstance.activityView(View: self.view)
        }
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.searchHashTagWallpost as String, param: param , completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                self.isDataLoading = false

            }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
               // self.totalPageNo = result["totalPages"] as? Int ?? 0
               
                if status == 1{
                    self.pageNo = self.pageNo + 1
                    if self.pageNo == 1{
                        self.arrwallPost.removeAll()
                    }
                    
                    var currentIndex = self.arrwallPost.count
                    if self.arrwallPost.count > 0 {
                        currentIndex = currentIndex - 1
                    }
                    
                    let data = result.value(forKey: "payload") as? NSArray ?? []
                   
                    for d in data{
                        
                        autoreleasepool {
                            let objPost = WallPostModel(dict: d as? NSDictionary ?? [:])
                            self.arrwallPost.append(objPost)
                        }
                    }
                    
                    self.isDataMoreAvailable = (data.count == 0) ? false : true
                    self.states = [Bool](repeating: true, count: self.arrwallPost.count)
                    
                    DispatchQueue.main.async {
                        self.tblView.reloadData {
                            self.isDataLoading = false
                        }
                    }
                    
                    self.preBufferNextFeedVideos(currentIndex: currentIndex)
                }
                else
                {
                    //self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                    self.isDataLoading = false

                }
                DispatchQueue.main.async {
                    
                    self.emptyView?.isHidden = (self.arrwallPost.count) == 0 ? false : true
                    self.emptyView?.lblMsg?.text = message

                }
                
            }
        })
    }
    
    func getSavedPostListApi(){
        
        let param:NSDictionary = [:]
        
        if self.pageNo == 1{
            Themes.sharedInstance.activityView(View: self.view)
            self.arrwallPost.removeAll()
        }
        self.isDataLoading = true
        
        URLhandler.sharedinstance.makeGetCall(url:Constant.sharedinstance.savePostList + "?pageNumber=\(self.pageNo)", param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
           
            if(error != nil){
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                self.isDataLoading = false

            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
                if status == 1{
                    let data = result.value(forKey: "payload") as? NSArray ?? []
                    //self.arrwallPost.removeAll()
                    
                    var currentIndex = self.arrwallPost.count
                    if self.arrwallPost.count > 0 {
                        currentIndex = currentIndex - 1
                    }
                    
                    for d in data{
                        
                        autoreleasepool {
                            let objPost = WallPostModel(dict: d as? NSDictionary ?? [:])
                            self.arrwallPost.append(objPost)
                        }
                    }
                    
                    self.isDataMoreAvailable = data.count > 0 ? true : false
                    self.states = [Bool](repeating: true, count: self.arrwallPost.count)
                    self.pageNo = self.pageNo + 1
                    
                    DispatchQueue.main.async {
                        self.emptyView?.isHidden = (self.arrwallPost.count) == 0 ? false : true
                        self.tblView.reloadData {
                            self.isDataLoading = false
                        }
                    }
                    
                    self.preBufferNextFeedVideos(currentIndex: currentIndex)
                    
                }else{
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                    self.isDataLoading = false

                }
                
            }
        })
    }
    
    
    func getRandomMediaPostList(){
        if (UIApplication.shared.delegate as! AppDelegate).IsInternetconnected == true {
            
            
            Themes.sharedInstance.activityView(View: self.view)
            
            var param = NSDictionary()
                param  = ["keyword":hashTag,"pageNumber":pageNo]
            let url = Constant.sharedinstance.SearchMediaURL
            
            
            isDataLoading = true
            
            URLhandler.sharedinstance.makeCall(url:url, param: param, completionHandler: {(responseObject, error) ->  () in
                if(error != nil)
                {
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                   // self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    print(error ?? "defaultValue")
                    self.isDataLoading = false

                }
                else{
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int16 ?? 0
                    let message = result["message"] as? String ?? ""
                   
                    
                    if status == 1{
                        Themes.sharedInstance.RemoveactivityView(View: self.view)
                        var currentIndex = self.arrwallPost.count
                       
                        if self.arrwallPost.count > 0 {
                            currentIndex = currentIndex - 1
                        }
                        
                            let data = result.value(forKey: "payload") as? NSArray ?? []
                            for d in data
                            {
                                self.arrwallPost.append(WallPostModel(dict: d as? NSDictionary ?? [:]))
                            }
                        
                        self.pageNo = self.pageNo + 1
                        self.isDataMoreAvailable = (data.count == 0) ? false : true
                        self.states = [Bool](repeating: true, count: self.arrwallPost.count)
                        DispatchQueue.main.async {
                            self.tblView.reloadData{
                                self.isDataLoading = false
                            }
                        }
                        self.preBufferNextFeedVideos(currentIndex: currentIndex)
                    }else{
                        self.isDataLoading = false
                        Themes.sharedInstance.RemoveactivityView(View: self.view)
                        
                        self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            })
            
            
        }else {
            //let msg = "No Network Connection"
           // self.view.makeToast(message: msg, duration: 3, position: HRToastActivityPositionDefault)
        }
    }
    
    
    func getUserPostListApi(){
        
        let followmsisdn = (followMsIsdn.count == 0) ? Themes.sharedInstance.Getuser_id() : followMsIsdn
        
        if pageNo == 1 {
            self.arrwallPost.removeAll()
            self.tblView.reloadData()
            DispatchQueue.main.async {
                Themes.sharedInstance.activityView(View: self.view)
            }
        }
        let param:NSDictionary = [:]
        
        let url = "\(Constant.sharedinstance.showUserFeedsList)/\(followmsisdn)/\(pageNo)"
        
        URLhandler.sharedinstance.makeGetCall(url: url, param: param) {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                self.isDataLoading = false

            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
               // self.totalPageNo = result["totalPages"] as? Int ?? 0
                //self.isDataLoading = false
                
                if status == 1 {
                    
                    var currentIndex = self.arrwallPost.count
                    if self.arrwallPost.count > 0 {
                        currentIndex = currentIndex - 1
                    }
                    
                    let postArr = result.value(forKey: "payload") as? NSArray ?? []
                    
                    var newPageArr = Array<WallPostModel>()
                    
                    for postDict in postArr {
                        autoreleasepool {
                            newPageArr.append(WallPostModel(dict: postDict as? NSDictionary ?? [:]))
                        }
                    }
                    
                    self.isDataMoreAvailable = postArr.count > 0 ? true : false

                    self.arrwallPost.append(contentsOf: newPageArr)
                    
                    self.delegate?.getNewPageList(listArray: newPageArr, pageNo: self.pageNo + 1,postType:self.controllerType)
                    self.emptyView?.lblMsg?.text = "Empty List"
                    self.emptyView?.isHidden = (self.arrwallPost.count == 0) ? false : true
                    
                    self.states = [Bool](repeating: true, count: self.arrwallPost.count)
                    self.tblView.reloadData{
                        self.isDataLoading = false
                    }
                    self.pageNo = self.pageNo + 1
                    
                    self.preBufferNextFeedVideos(currentIndex: currentIndex)
                    
                }else{
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                    self.isDataLoading = false

                }
            }
        }
    }
    
    
    func getUserTagPostApi(){
        
        let followmsisdn = (followMsIsdn.count == 0) ? Themes.sharedInstance.Getuser_id() : followMsIsdn
        
            let param:NSDictionary = [:]
            
              let url = "\(Constant.sharedinstance.getTagUserPost)?userId=\(followmsisdn)&pageNumber=\(pageNo)&pageLimit=\(pageLimit)"
              
            
            DispatchQueue.main.async {
                if self.pageNo == 1{
                    Themes.sharedInstance.activityView(View: self.view)
                }
            }
              URLhandler.sharedinstance.makeGetCall(url: url, param: param) {(responseObject, error) ->  () in
                  Themes.sharedInstance.RemoveactivityView(View: self.view)
                 
            
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                 self.isDataLoading = false

            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
              //  self.totalPageNo = result["totalPages"] as? Int ?? 0
                
                if status == 1{
                    var currentIndex = self.arrwallPost.count
                    if self.arrwallPost.count > 0 {
                        currentIndex = currentIndex - 1
                    }
                    

                    let data = result.value(forKey: "payload") as? NSArray ?? []
                    var newPageArr = Array<WallPostModel>()

                    for d in data
                    {
                        autoreleasepool {
                            let objPost = WallPostModel(dict: d as? NSDictionary ?? [:])
                            newPageArr.append(objPost)
                        }
                        
                    }
                    self.isDataMoreAvailable = data.count > 0 ? true : false

                    self.arrwallPost.append(contentsOf: newPageArr)

                    DispatchQueue.main.async {
                       
                        self.delegate?.getNewPageList(listArray: newPageArr, pageNo: self.pageNo + 1,postType:self.controllerType)
                        self.states = [Bool](repeating: true, count: self.arrwallPost.count)
                        self.tblView.reloadData {
                            self.isDataLoading = false
                        }
                        self.emptyView?.lblMsg?.text = "Empty List"
                        self.emptyView?.isHidden = (self.arrwallPost.count == 0) ? false : true
                    }
                    self.pageNo = self.pageNo + 1
                    
                    self.preBufferNextFeedVideos(currentIndex: currentIndex)

                }
                else
                {
                   // self.view.makeToast(message: message as! String, duration: 1, position: HRToastActivityPositionDefault)
                    self.isDataLoading = false

                }
                self.emptyView?.lblMsg?.text = message
                self.emptyView?.isHidden = (self.arrwallPost.count == 0) ? false : true
            }
        }
    }
    
    
   
    func getSharedPostListApi() -> () {
        
        let followmsisdn = (followMsIsdn.count == 0) ? Themes.sharedInstance.Getuser_id() : followMsIsdn
        let param:NSDictionary =  [:] //["followedUserId":followmsisdn,"pageNumber":pageNo,"pageLimit":pageLimit]

        DispatchQueue.main.async {
            if self.pageNo == 1{
                Themes.sharedInstance.activityView(View: self.view)
            }
        }
        
        let url = "\(Constant.sharedinstance.getSharedPost)?userId=\(followmsisdn)&pageNumber=\(pageNo)&pageLimit=\(pageLimit)"
        
        DispatchQueue.main.async {
            Themes.sharedInstance.activityView(View: self.view)
        }
        URLhandler.sharedinstance.makeGetCall(url:url, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
        
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                self.isDataLoading = false

            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
               // self.totalPageNo = result["totalPages"] as? Int ?? 0
                if status == 1 {
                    var currentIndex = self.arrwallPost.count
                    if self.arrwallPost.count > 0 {
                        currentIndex = currentIndex - 1
                    }
                    
                    let data = result.value(forKey: "payload") as? NSArray ?? []

                    var newPageArr = Array<WallPostModel>()

                    for d in data
                    {
                        autoreleasepool {
                            let objPost = WallPostModel(dict: d as? NSDictionary ?? [:])
                            newPageArr.append(objPost)
                        }
                        
                    }
                    self.isDataMoreAvailable = data.count > 0 ? true : false
                    self.arrwallPost.append(contentsOf: newPageArr)

                    DispatchQueue.main.async {
                    self.delegate?.getNewPageList(listArray: newPageArr, pageNo: self.pageNo + 1,postType:self.controllerType)

                    self.emptyView?.lblMsg?.text = "Empty List"
                    self.emptyView?.isHidden = (self.arrwallPost.count == 0) ? false : true
                    
                    self.states = [Bool](repeating: true, count: self.arrwallPost.count)
                        self.tblView.reloadData {
                            self.isDataLoading = false
                        }
                    }
                    self.pageNo = self.pageNo + 1
                    self.preBufferNextFeedVideos(currentIndex: currentIndex)

                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 1, position: HRToastActivityPositionDefault)
                    self.isDataLoading = false
                }
                
                self.emptyView?.lblMsg?.text = "Empty List"
                self.emptyView?.isHidden = (self.arrwallPost.count == 0) ? false : true
            }
        })
    }
    
   
    //MARK: - TableviewDataSource
        
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
      
    func numberOfSections(in tableView: UITableView) -> Int {
        
       /* if (controllerType == .isFromRandomMedia ||  controllerType == .hashTagSearched) && self.arrwallPost.count > 6{
            return 2

        }else if self.arrwallPost.count > 6 && pageNo < totalPageNo{
           return 2
        }
        */
        
        if self.arrwallPost.count > 6 && (isDataMoreAvailable == true){
           return 2
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1{
            return  (isDataMoreAvailable == true) ? 1 : 0
        }
        return arrwallPost.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            //Loading cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreTblCell", for: indexPath) as! LoadMoreTblCell
          //  cell.lblMessage.isHidden = true
            cell.activityIndicator.startAnimating()
            return cell
                        
        }
        
        let objWallPost = arrwallPost[indexPath.row]
        var cell: FeedsCell!

        if objWallPost.sharedWallData == nil {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "FeedsTableViewCell", for: indexPath) as! FeedsTableViewCell
            
            if controllerType == .isFromSaved{
                cell.isFromSavedList = true
            }
            
            cell.configureWallPostItem(objWallPost: objWallPost, indexPath: indexPath, states: (states.count > indexPath.row) ? states[indexPath.row] : false)
            cell.lblDescription.delegate = self
            cell.lblDescription.textReplacementType = .word
            cell.lblDescription.shouldCollapse = true
            cell.lblDescription.numberOfLines = 4
            cell.lblDescription.setLessLinkWith(lessLink: "Read less", attributes: [.foregroundColor:UIColor.red], position: .left)
            if states.count > indexPath.row {
                cell.lblDescription.collapsed = states[indexPath.row]
            }
                    
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "FeedsSharedTableViewCell", for: indexPath) as! FeedsSharedTableViewCell
                        
            if controllerType == .isFromSaved{
                cell.isFromSavedList = true
            }
            cell.configureSharedWallDataPost(objWallPost: objWallPost, indexPath: indexPath, states:(states.count > indexPath.row) ? states[indexPath.row] : false)
            
            cell.lblPostDate.text = objWallPost.sharedWallData.feedTime
            cell.lblSharedContents.textReplacementType = .word
            cell.lblSharedContents.shouldCollapse = true
            cell.lblSharedContents.numberOfLines = 4
            cell.lblSharedContents.delegate = self
           
            cell.lblDescription.delegate = self
            cell.lblDescription.textReplacementType = .word
            cell.lblDescription.shouldCollapse = true
            cell.lblDescription.numberOfLines = 4
            
            if states.count > indexPath.row {
                cell.lblDescription.collapsed = states[indexPath.row]
                cell.lblSharedContents.collapsed = states[indexPath.row]
            }
            cell.addTargetSharedWallButtons()
        }
        
        cell.addTargetButtons()
        cell.tableIndexPath = indexPath
        cell.cvFeedsPost.updateConstraints()
        cell.cvFeedsPost.reloadData()
        cell.superview?.updateConstraints()
        cell.selectionStyle = .none
        
        if controllerType == .isFromSaved || controllerType == .isFromNotification {
            cell.btnSavePost.isHidden = true
        }
        cell.hashTag = self.hashTag
        cell.controllerType = self.controllerType
       
        return cell
    }
    
   
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      
        if indexPath.row < arrwallPost.count{
            
            if let objWallPost = arrwallPost[indexPath.row] as? WallPostModel {
                if (objWallPost.sharedWallData == nil){
                    if let tblCell1 =  (cell as? FeedsTableViewCell)?.cvFeedsPost.visibleCells.first as? FeedsCollectionViewCell {
                        tblCell1.pauseVideo()
                    }
                }else {
                    if  let tblCell1 =  (cell as? FeedsSharedTableViewCell)?.cvFeedsPost.visibleCells.first as? FeedsCollectionViewCell {
                        tblCell1.pauseVideo()
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var objWallPost =  arrwallPost[indexPath.row]
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
        
        if indexPath.section == 1  && arrwallPost.count > 6 {
            
            if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                
                self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
                
            }else if isDataLoading == false{
                isDataLoading = true
                if controllerType == .hashTagSearched {
                    self.getPostByTagNameApi()
                }else if controllerType == .isFromRandomMedia{
                    self.getRandomMediaPostList()
                    
                } else if controllerType == .hashTag {
                    
                    self.getPostByTagNameApi()
                    
                }else if controllerType == .isFromPost{
                    
                    self.getUserPostListApi()
                    
                }else if controllerType == .isFromTaggedPost{
                    
                    self.getUserTagPostApi()
                    
                }else if controllerType == .isFromSharedPost{
                    
                    self.getSharedPostListApi()
                    
                }else if controllerType == .isFromSaved {
                    getSavedPostListApi()
                }
            }
            
        }
        
         if indexPath.section == 0 && indexPath.row % 3 == 0 {
            self.preBufferNextFeedVideos(currentIndex: indexPath.row)
        }
 }
    
    /*
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height + 60) >= scrollView.contentSize.height)
        {
            if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                
                self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
            }
            
            if !isDataLoading {
                
                if pageNo <= totalPageNo {
                    
                    isDataLoading = true
                    
                    if controllerType == .hashTag {
                        
                        self.getPostByTagNameApi()
                        
                    }else if controllerType == .isFromPost{
                        
                        self.getUserPostListApi()
                        
                    }else if controllerType == .isFromTaggedPost{
                        
                        self.getUserTagPostApi()
                        
                    }else if controllerType == .isFromSharedPost{
                        
                        self.getSharedPostListApi()
                    }
                    
                }
            }
        }
    }
    */
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let y = max(0.0, tblView.contentOffset.y)
        
        // point for the top visible content
        let pt: CGPoint = CGPoint(x: 0, y: y + 200)
        
        if let idx = tblView.indexPathForRow(at: pt) {
            if shoulAutoplayVideo() == true && isBackBtnPressed == false {
                
                
                let cellRect = tblView.rectForRow(at: idx)
                if let superview = tblView.superview {
                    let convertedRect = tblView.convert(cellRect, to:superview)
                    let intersect = tblView.frame.intersection(convertedRect)
                    let visibleHeight = intersect.height
                    let cellHeight = cellRect.height
                    //let ratio = visibleHeight / cellHeight
                    
                    if visibleHeight <= cellHeight/4 && arrwallPost.count > idx.row{
                        if idx.section == 0 {
                            if  let tblCell = tblView.cellForRow(at: idx) {
                                self.pauseAllVisiblePlayers()
                                /*
                                 let objWallPost = arrwallPost[idx.row]
                                
                                if (objWallPost.sharedWallData == nil){
                                    
                                    let tblCell1 =  (tblCell as! FeedsTableViewCell).cvFeedsPost.visibleCells.first as? FeedsCollectionViewCell
                                    
                                    
                                    if tblCell1?.videoView.state == .playing {
                                        //self.pauseAllVisiblePlayers()
                                        tblCell1?.pauseVideo()
                                    }
                                    
                                }else {
                                    let tblCell1 =  (tblCell as! FeedsSharedTableViewCell).cvFeedsPost.visibleCells.first as? FeedsCollectionViewCell
                                    if tblCell1?.videoView.state == .playing {
                                        //self.pauseAllVisiblePlayers()
                                        tblCell1?.pauseVideo()
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
    
    func preBufferNextFeedVideos(currentIndex:Int) {
        
        if (UIApplication.shared.delegate as! AppDelegate).IsInternetconnected == true {
            var urlArray:Array<URL> = Array()
            //for index in currentIndex..<arrwallPost.count {
            for index in currentIndex..<(currentIndex + 3) {
                //let index = ind + currentIndex
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
            //   print("Waiting urlArray :\(urlArray)")
            if urlArray.count > 0 {
                VideoPreloadManager.shared.set(waiting: urlArray)
            }
        }else {
            self.view.makeToast(message: "No Network Connection", duration: 2, position: HRToastActivityPositionDefault)
        }
    }
    
    
    
    func playVideoAtIndexPath(selIndexPath:IndexPath)  {
        
        let cellRect = tblView.rectForRow(at: selIndexPath)
        
        if let superview = tblView.superview {
            
            let convertedRect = tblView.convert(cellRect, to:superview)
            let intersect = tblView.frame.intersection(convertedRect)
            let visibleHeight = intersect.height
            let cellHeight = cellRect.height
          //  let ratio = visibleHeight / cellHeight
            
            if ((visibleHeight + 20.0) >= cellRect.width || (visibleHeight + 20.0) >= cellHeight) && (arrwallPost.count > selIndexPath.row) {
                
                let objWallPost = arrwallPost[selIndexPath.row]
                
                if shoulAutoplayVideo() == true {
                    
                    if selIndexPath.section == 0{
                        if  let tblCell = tblView.cellForRow(at: selIndexPath) {
                            
                            let isTrue = (objWallPost.sharedWallData == nil) ? (tblCell as? FeedsTableViewCell)?.isVideoActive  ?? false : (tblCell as? FeedsSharedTableViewCell)?.isVideoActive ?? false
                            
                            if  isTrue {
                                
                                if (objWallPost.sharedWallData == nil){
                                    if let tblCell1 =  (tblCell as? FeedsTableViewCell)?.cvFeedsPost.visibleCells.first as? FeedsCollectionViewCell {
                                        
                                        if tblCell1.videoView.state != .playing {
                                            pauseAllVisiblePlayers()
                                            tblCell1.playVideo()
                                            
                                        }
                                    }
                                }else {
                                    if let tblCell1 =  (tblCell as? FeedsSharedTableViewCell)?.cvFeedsPost.visibleCells.first as? FeedsCollectionViewCell {
                                        if tblCell1.videoView.state != .playing {
                                            pauseAllVisiblePlayers()
                                            tblCell1.playVideo()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            }else  if visibleHeight <= cellHeight/2   && arrwallPost.count > selIndexPath.row{
                if shoulAutoplayVideo() == true {
                    
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: noti_PausePlayer), object:nil ,userInfo: ["tag":selIndexPath.row])
                }
                
            }
            
        }
    }
    
    @objc func pauseAllVisiblePlayers(){
        if  let visibleIndexPaths = self.tblView.indexPathsForVisibleRows {
            for indexPath in visibleIndexPaths {
                if indexPath.section == 0 {
                    let tblCell = tblView.cellForRow(at: indexPath)
                    let objWallPost = arrwallPost[indexPath.row]
                    if (objWallPost.sharedWallData == nil){
                        if let tblCell1 =  (tblCell as? FeedsTableViewCell)?.cvFeedsPost.visibleCells.first as? FeedsCollectionViewCell {
                            tblCell1.pauseVideo()
                        }
                    }else {
                        if let tblCell1 =  (tblCell as? FeedsSharedTableViewCell)?.cvFeedsPost.visibleCells.first as? FeedsCollectionViewCell {
                            tblCell1.pauseVideo()
                        }
                    }
                }
                
            }
        }
    }
    
    
    
    
   
    
}



extension WallPostViewVC:ExpandableLabelDelegate{
    func hashTagTextClicked(_ label: ExpandableLabel, hashTag: String) {
        
        let destVc:WallPostViewVC = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
        destVc.controllerType = .hashTag
        destVc.hashTag = hashTag
        AppDelegate.sharedInstance.navigationController?.pushViewController(destVc, animated: true)
    }
    
    
    // MARK: ExpandableLabel Delegate
    func willExpandLabel(_ label: ExpandableLabel) {
        tblView.beginUpdates()
    }
    
    
    func didExpandLabel(_ label: ExpandableLabel) {
        let point = label.convert(CGPoint.zero, to: tblView)
        if let indexPath = tblView.indexPathForRow(at: point) as IndexPath? {
            if states.count > indexPath.row {
                states[indexPath.row] = false
            }
            DispatchQueue.main.async { [weak self] in
              //  self?.tblView.scrollToRow(at: indexPath, at: .none, animated: false)
            }
        }
        tblView.endUpdates()
    }
    
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        tblView.beginUpdates()
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        let point = label.convert(CGPoint.zero, to: tblView)
        if let indexPath = tblView.indexPathForRow(at: point) as IndexPath? {
            states[indexPath.row] = true
            DispatchQueue.main.async { [weak self] in
                self?.tblView.reloadRows(at: [indexPath], with: .none)
               // self?.tblView.scrollToRow(at: indexPath, at: .none, animated: false)
            }
        }
        tblView.endUpdates()
    }
    
    func mentionTextClicked(_ label: ExpandableLabel,mentionText:String){
        
        print("mentionTextClicked \(mentionText)")
        
        let mentionString:String = mentionText
        self.getUserIdFromPickzonId(pickzonId: mentionString.replacingOccurrences(of: "@", with: ""))
    }
    

    func urlTextClicked(_ label: ExpandableLabel,strURL:String) {
        let point = label.convert(CGPoint.zero, to: tblView)
        if let indexPath = tblView.indexPathForRow(at: point) as IndexPath? {
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
    
    func numberTextClicked(_ label: ExpandableLabel, number: String) {
        let point = label.convert(CGPoint.zero, to: tblView)
        if let indexPath = tblView.indexPathForRow(at: point) as IndexPath? {
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
    
}

extension WallPostViewVC {
       
    @objc func noti_BoostedPost(notification: Notification) {
        
        if let objDict = notification.object as? Dictionary<String, Any> {
            
            let feedId = objDict["feedId"] as? String ?? ""
            let boost = objDict["boost"] as? Int ?? 0
            
            if let selPostIndex = arrwallPost.firstIndex(where:{($0 as? WallPostModel)?.id == feedId}) {

                var objWallPost = arrwallPost[selPostIndex] 
                objWallPost.boost = boost
                arrwallPost[selPostIndex] = objWallPost
                
                let indexPth:IndexPath = IndexPath(row: selPostIndex, section: 0)
                if let cell1 = tblView.cellForRow(at: indexPth) as? FeedsTableViewCell {
                    
                    cell1.objWallPost = objWallPost
                    cell1.btnBoost.setTitle("In Review", for: .normal)
                }
                self.delegate?.getUpdatedData( postbj: objWallPost)

            }
        }
    }
    
    
    @objc func feedCommentAddedNotification(notification: Notification) {
        
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            let isFromShared = objDict["isFromShared"] as? Bool ?? false
            let isFromDelete = objDict["isFromDelete"] as? Bool ?? false
           // let commentCount = objDict["commentCount"] as? Int16 ?? 0
           
            if let selPostIndex = arrwallPost.firstIndex(where:{$0.id == feedId}) {
                guard  var objWallPost = arrwallPost[selPostIndex] as? WallPostModel else{
                    return
                }
                
                let count =  (isFromDelete == true ) ? (objWallPost.totalComment - 1) : (objWallPost.totalComment + 1)
                
                objWallPost.totalComment = count
                
                arrwallPost[selPostIndex] = objWallPost
                let indexPth:IndexPath = IndexPath(row: selPostIndex, section: 0)
                
                var cell:FeedsCell?
                if isFromShared == true {
                    if let  cell1 = tblView.cellForRow(at: indexPth) as? FeedsSharedTableViewCell {
                        cell = cell1
                    }
                }else{
                    if let cell1 = tblView.cellForRow(at: indexPth) as? FeedsTableViewCell {
                        cell = cell1
                    }
                }
                        
                cell?.objWallPost = objWallPost
                cell?.updatedCommentLikeAndShareCount(objwallpost: objWallPost)
                self.delegate?.getUpdatedData( postbj: objWallPost)
            }
        }
    }
    
    @objc func feedsLikedReceivedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            let isLike = objDict["isLike"] as? Int16 ?? 0
            let likeCount = objDict["likeCount"] as? UInt ?? 0
            
            if let objIndex = arrwallPost.firstIndex(where:{$0.id == feedId}) {
                var objWallPost = arrwallPost[objIndex]
                objWallPost.isLike = isLike
                objWallPost.totalLike = likeCount
                arrwallPost[objIndex] = objWallPost
                var cell:FeedsCell?
                if objWallPost.sharedWallData == nil {
                    if let cell1  = self.tblView.cellForRow(at: IndexPath(row: objIndex, section: 0)) as? FeedsTableViewCell {
                        cell = cell1
                    }
                }else{
                    if let cell1 = self.tblView.cellForRow(at: IndexPath(row: objIndex, section: 0)) as? FeedsSharedTableViewCell {
                        cell = cell1
                    }
                }
                
                cell?.btnLike.setImage((objWallPost.isLike == 1) ? PZImages.heart_Filled : PZImages.heart_blank, for: .normal)
                cell?.updatedCommentLikeAndShareCount(objwallpost: objWallPost)
                cell?.objWallPost = objWallPost
                self.delegate?.getUpdatedData( postbj: objWallPost)
            }
        }
    }
   
    
    @objc func feedRemovedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            
            if let objIndex = arrwallPost.firstIndex(where:{$0.id == feedId}) {
                
                DispatchQueue.main.async {
                    self.arrwallPost.remove(at: objIndex)
                    self.tblView.beginUpdates()
                    let indexPath = IndexPath(row: objIndex, section: 0)
                    self.tblView.deleteRows(at: [indexPath] , with: .fade)
                    self.tblView.endUpdates()
                    self.tblView.reloadData()
                    
                    
                    if  (AppDelegate.sharedInstance.navigationController?.topViewController?.isKind(of: WallPostViewVC.self))! {
                        
                        if self.arrwallPost.count == 0{
                            self.isBackBtnPressed = true
                            self.pauseAllVisiblePlayers()

                            self.navigationController?.popViewController(animated: true)
                            
                        }
                    }
                    
                    
                }
                
            }
            //removed all posts that is shared for current FeedId
            let arrSharedPosts = arrwallPost.filter({ $0.sharedWallData != nil && $0.sharedWallData?.id == feedId })
            for obj in arrSharedPosts as! Array<WallPostModel>{
                if let objIndex = arrwallPost.firstIndex(where:{$0.id == obj.id}) {
                    DispatchQueue.main.async {
                        self.arrwallPost.remove(at: objIndex)
                        self.tblView.beginUpdates()
                        let indexPath = IndexPath(row: objIndex, section: 0)
                        self.tblView.deleteRows(at: [indexPath] , with: .fade)
                        self.tblView.endUpdates()
                        self.tblView.reloadData()
                        
                        
                        if  (AppDelegate.sharedInstance.navigationController?.topViewController?.isKind(of: WallPostViewVC.self))! {
                            
                            if self.arrwallPost.count == 0{
                                self.isBackBtnPressed = true
                                self.pauseAllVisiblePlayers()
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
            }
        }
       
    }
    
    @objc func feedTagRemovedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
       
        if let objDict = notification.object as? Dictionary<String, Any> {
                let feedId = objDict["feedId"] as? String ?? ""
                
                if let objIndex = arrwallPost.firstIndex(where:{($0 as? WallPostModel)?.id == feedId}) {
                    if var objWallpost = arrwallPost[objIndex] as? WallPostModel {
                        objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "@\(Themes.sharedInstance.getPickzonId())", with: "")
                        objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "  ", with: " ")
                        self.arrwallPost[objIndex] = objWallpost
                        DispatchQueue.main.async {
                            self.tblView.reloadData()
                        }
                    }
                    
            }
        }
    }
    
    
    @objc func feedExpandedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            let isExpanded = objDict["isExpanded"] as? Bool ?? false
            
            if let objIndex = arrwallPost.firstIndex(where:{$0.id == feedId}) {
                
                var objWallPost = arrwallPost[objIndex]
                objWallPost.isExpanded = isExpanded
                arrwallPost[objIndex] = objWallPost
                tblView.reloadRows(at: [IndexPath(row: objIndex, section: 0)], with: .none)
            }
        }
    }
    
    //239033544
    
    @objc func feedFollwedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            let userId = objDict["userId"] as? String ?? ""
            let isFollowed = objDict["isFollowed"] as? Int ?? 0
           // let isCollageView = objDict["isCollageView"] as? Bool ?? false
            for index in 0..<arrwallPost.count {
                autoreleasepool {
                if var  objWallPost = arrwallPost[index] as? WallPostModel{
                    
                    if objWallPost.sharedWallData == nil {
                        if objWallPost.userInfo?.id == userId {
                            objWallPost.isFollowed = isFollowed
                            arrwallPost[index] = objWallPost
                            var cell:FeedsCell?
                            if let cell1 = self.tblView.cellForRow(at: IndexPath(row: index, section: 0)) as? FeedsTableViewCell {
                                cell = cell1
                            }
                            if isFollowed >= 1 {
                                cell?.btnFolow.isHidden = true
                            }else {
                                cell?.btnFolow.isHidden = false
                            }
                            cell?.objWallPost = objWallPost
                            self.delegate?.getUpdatedData( postbj: objWallPost)
                        }
                    }else {
                        
                        
                        if objWallPost.userInfo?.id == userId{
                            var cell:FeedsCell?
                            if let  cell1 = self.tblView.cellForRow(at: IndexPath(row: index, section: 0)) as? FeedsSharedTableViewCell {
                                cell = cell1
                            }
                            objWallPost.isFollowed = isFollowed
                            arrwallPost[index] = objWallPost
                            if isFollowed >= 1 {
                                cell?.btnFolow.isHidden = true
                            }else {
                                cell?.btnFolow.isHidden = false
                            }
                            cell?.objWallPost = objWallPost
                            self.delegate?.getUpdatedData( postbj: objWallPost)
                        }
                        if objWallPost.sharedWallData.userInfo?.id == userId{
                            var cell:FeedsCell?
                            if let  cell1 = self.tblView.cellForRow(at: IndexPath(row: index, section: 0)) as? FeedsSharedTableViewCell {
                                cell = cell1
                            }
                            
                            objWallPost.sharedWallData.isFollowed = isFollowed
                            arrwallPost[index] = objWallPost
                            if isFollowed >= 1 {
                                cell?.btnSharedFollow.isHidden = true
                            }else {
                                cell?.btnSharedFollow.isHidden = false
                            }
                            cell?.objWallPost = objWallPost
                            self.delegate?.getUpdatedData( postbj: objWallPost)
                        }
                        
                    }
                    
                    //self.delegate?.getUpdatedData( postbj: objWallPost)
                    
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
            
            if let objIndex = arrwallPost.firstIndex(where:{$0.id == feedId}) {
                
                var objWallPost = arrwallPost[objIndex]
                objWallPost.isSave = isSave
                arrwallPost[objIndex] = objWallPost
                
                var cell:FeedsCell?
                if isSave == 1 {
                    if objWallPost.sharedWallData == nil {
                        cell = self.tblView.cellForRow(at: IndexPath(row: objIndex, section: 0)) as? FeedsTableViewCell
                    }else{
                        cell = self.tblView.cellForRow(at: IndexPath(row: objIndex, section: 0)) as? FeedsSharedTableViewCell
                    }
                    
                    if objWallPost.isSave == 0{
                        cell?.btnSavePost.setImage(PZImages.feedsSavePost, for: .normal)
                    }else{
                        cell?.btnSavePost.setImage(PZImages.feedsSavePostRed, for: .normal)
                    }
                    
                }else if controllerType == .isFromSaved {
                    self.arrwallPost.remove(at: objIndex)
                    self.tblView.beginUpdates()
                    let indexPath = IndexPath(row: objIndex, section: 0)
                    self.tblView.deleteRows(at: [indexPath] , with: .fade)
                    self.tblView.endUpdates()
                    self.tblView.reloadData()
                }
                
                self.delegate?.getUpdatedData( postbj: objWallPost)
            }
        }
    }
    
}




extension UITableView {
    
    func setBottomInset(to value: CGFloat) {
        let edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: value, right: 0)
        
        self.contentInset = edgeInset
        self.scrollIndicatorInsets = edgeInset
    }
}

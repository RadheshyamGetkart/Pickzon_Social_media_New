//
//  ProfileVC.swift
//  SCIMBO
//
//  Created by Getkart on 25/06/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit
import Kingfisher
import FittedSheets
import MessageUI
import ShimmerView
import GSImageViewerController
import SDWebImage
import RSKImageCropper
import NSFWDetector

class ProfileVC: UIViewController, OptionDelegate,updatedProfileDelegate,ShimmerSyncTarget {
    
    var effectBeginTime: CFTimeInterval = 0.0
   
    var style: ShimmerViewStyle = {
        var style = ShimmerViewStyle.default
        style.baseColor = UIColor(dynamicProvider: { trait -> UIColor in
            if trait.userInterfaceStyle == .dark {
                return UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1.0)
            } else {
                return UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
            }
        })
        return style
    }()
    
    var isOptionProfileSelected = true
    var arrwallPost = [WallPostModel]()
    var tagArray = [WallPostModel]()
    var sharedArray = [WallPostModel]()
    var videoPostArray = [WallPostModel]()
    var isExpanded = true
    var isDataLoading = false
    var pageNo = 1
    var pageNoVideo = 1
    var pageNoPhoto = 1
    var pageNoTag = 1
    var pageNoShared = 1
    var pageLimit = 15
    var selectedTab = 0
    var otherMsIsdn = ""
    var objUser = PickzonUser(respdict: [:])
   
    @IBOutlet weak var tableViewProfile: UITableView!
    @IBOutlet weak var bgVwBackBtnSwipe: UIView!
    @IBOutlet weak var cnstrntHt_BackBtn:NSLayoutConstraint!
    @IBOutlet weak var lblSwipeName: UILabel!
    @IBOutlet weak var btnFollowSwipe: UIButtonX!
    @IBOutlet weak var btnThreeDotSwipe:UIButton!
    @IBOutlet weak var celebritySwipe: UIImageView!
    @IBOutlet weak var tblFooterVw:UIView!
    @IBOutlet weak var lblErrorMessage: UILabel!
    @IBOutlet weak var lblDescErrorMessage: UILabel!
    @IBOutlet weak var imgVwEmpty: UIImageView!
    
    lazy var picker = UIImagePickerController()
    var isFirstTime = true
    var isDataMoreAvailable = false
    
    private var shimmerReplicatorView: ShimmerReplicatorView = {
        let view = ShimmerReplicatorView(itemSize: .fixedHeight( UIScreen.main.bounds.height)) { () -> ShimmerReplicatorViewCell in
            return UINib(nibName: "ProfileCellShimmer", bundle: nil).instantiate(withOwner: nil, options: nil).first as! ProfileCellShimmer
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
        
    private  lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemBlue
        return refreshControl
    }()
    
    //MARK: Controller Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if otherMsIsdn == Themes.sharedInstance.Getuser_id()  || otherMsIsdn.count == 0{
            otherMsIsdn = Themes.sharedInstance.Getuser_id()
        }
        self.fetchUserInfoFromDB(userId: otherMsIsdn)
        self.btnThreeDotSwipe.setImageTintColor(UIColor.darkGray)
        registerCell()
        tableViewProfile.sectionHeaderHeight = 0
        tableViewProfile.estimatedSectionHeaderHeight = 0
        tableViewProfile.estimatedSectionFooterHeight = 0
        tableViewProfile.sectionFooterHeight = 0
        if #available(iOS 15.0, *) {
            tableViewProfile.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        tableViewProfile.bounces = true
        self.tblFooterVw.isHidden = true
        self.btnThreeDotSwipe.isHidden = true
        cnstrntHt_BackBtn.constant = 0
        getUserInfoDetails()
        self.getAllUserPostListApi()
        if #available(iOS 11.0, *) {
            self.tableViewProfile.contentInsetAdjustmentBehavior = .never
        }
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.leftSwiped))
        swipeLeft.direction = .left
        tblFooterVw.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.rightSwiped))
        swipeRight.direction = .right
        tblFooterVw.addGestureRecognizer(swipeRight)
        
        addObservers()
        self.tableViewProfile.refreshControl = self.topRefreshControl
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("UIViewController: ProfileVC")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        KingfisherManager.shared.cache.clearCache()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    deinit{
        self.removeObserverObservers()
    }
    
    
    func removeObserverObservers(){
       NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: notif_FeedFollowed, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(noti_RefreshProfile), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(notif_FeedRemoved.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(notif_TagRemoved.rawValue), object: nil)
        
    }
    
    func addObservers(){
        NotificationCenter.default.removeObserver(self)

        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshList), name: NSNotification.Name(rawValue: noti_RefreshProfile), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.feedFollwedNotification(notification:)),
                                               name: notif_FeedFollowed, object: nil)
      
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedRemovedNotification(notification:)),
                                               name: notif_FeedRemoved, object: nil)
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.feedTagRemovedNotification(notification:)),
                                               name: notif_TagRemoved, object: nil)
    }
    
    @objc func backButtonAction(){
        self.removeObserverObservers()
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: PULL TO referesh
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
       
        if isDataLoading == false {
            getUserInfoDetails()
            switch selectedTab {
                
            case 0:
                pageNo = 1
                getAllUserPostListApi()
                break
                
            case 1:
                pageNoVideo = 1
                getAllVideoList()
                break
            case 2:
                pageNoTag = 1
                getUserTagPostApi()
                break
            case 3:
                pageNoShared = 1
                getSharedPostListApi()
                break
         
            default:
                break
            }
        }
        refreshControl.endRefreshing()
    }
    
   
    
    //MARK: Left & Right swipe methods
    
    @objc  func rightSwiped()
    {
        let tabArray =  ["Posts","clips","Tags","Share"]

        if selectedTab > 0{
            selectedTab = selectedTab - 1
            self.selectedTabIndex(title: tabArray[selectedTab], index:selectedTab)
        }
        print("right swiped ")

    }

    @objc func leftSwiped()
    {
        let tabArray =  ["Posts","Clips","Tags","Share"]
        print("left swiped ")
        if selectedTab < tabArray.count - 1{
            selectedTab = selectedTab + 1
            self.selectedTabIndex(title: tabArray[selectedTab], index:selectedTab)
        }

    }
    
    func showHideShimmerView(isTohide:Bool){
        
        if isTohide{
            shimmerReplicatorView.stopAnimating()
            shimmerReplicatorView.removeFromSuperview()
        }else{
            view.addSubview(shimmerReplicatorView)
            NSLayoutConstraint.activate([
                shimmerReplicatorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                shimmerReplicatorView.leftAnchor.constraint(equalTo: view.leftAnchor),
                shimmerReplicatorView.rightAnchor.constraint(equalTo: view.rightAnchor),
                shimmerReplicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            shimmerReplicatorView.startAnimating()
        }
        
    }
    
    //MARK: - Delegete method of bottom sheet view
    
    func cameraAllowsAccessToApplicationCheck()
    {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorizationStatus {
        case .notDetermined:
            // permission dialog not yet presented, request authorization
            AVCaptureDevice.requestAccess(for: AVMediaType.video,
                completionHandler: { (granted:Bool) -> Void in
                    if granted {
                        print("access granted", terminator: "")
                    }
                    else {
                        print("access denied", terminator: "")
                    }
            })
        case .authorized:
            print("Access authorized", terminator: "")
            //self.presentPickerSelector()
         
            let viewController:ShareProfileVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "ShareProfileVC") as! ShareProfileVC
            viewController.pickzonId = objUser.pickzonId
            viewController.userId = objUser.id
            self.navigationController?.pushView(viewController, animated: true)
            
        case .denied, .restricted:
            alertToEncourageCameraAccessWhenApplicationStarts()
        
            break
        default:
            print("DO NOTHING", terminator: "")
        }
    }


func alertToEncourageCameraAccessWhenApplicationStarts()
{
    AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: "Please enable camera", buttonTitles: ["Cancel","Okay"], onController: self) { title, index in
        
        if index == 0{
            return
        }else{
            let settingsUrl = NSURL(string:UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                DispatchQueue.main.async {
                    UIApplication.shared.openURL(url as URL)
                }

            }
        }
    }
}
    
    
    
    func selectedOption(index:Int,videoIndex:Int,title:String){
        if isOptionProfileSelected == true {
            if otherMsIsdn == Themes.sharedInstance.Getuser_id()  || otherMsIsdn.count == 0{
                if title == "Share Profile" {
                    self.cameraAllowsAccessToApplicationCheck()
                    
                    /*let viewController:ShareProfileVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "ShareProfileVC") as! ShareProfileVC
                     viewController.pickzonId = objUser.pickzonId
                     viewController.userId = objUser.id
                     self.navigationController?.pushView(viewController, animated: true)
                     */
                    
                }else  if title == "Friend Request List"{
                    let viewController:SuggestionListVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "SuggestionListVC") as! SuggestionListVC
                    viewController.isRequestSelected = true
                    viewController.isContactSelected = false
                    viewController.isSuggestedSelected = false
                    self.navigationController?.pushView(viewController, animated: true)
                }else if title == "Blocked User List"{
                    let vc = StoryBoard.main.instantiateViewController(withIdentifier: "BlockedUserVC") as! BlockedUserVC
                    self.pushView(vc, animated: true)
                }else if title == "Edit Profile"{
                    let editProfileVC:ProfileEditVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "ProfileEditVC") as! ProfileEditVC
                    editProfileVC.pickzonUser = objUser
                    editProfileVC.delegate = self
                    self.pushView(editProfileVC, animated: true)
                }else if title == "Verification Request"{
                    let vc = StoryBoard.feeds.instantiateViewController(withIdentifier:"RequestVerificationViewController" ) as! RequestVerificationViewController
                    self.pushView(vc, animated: true)
               
                }else if title == "Saved Posts"{
                    
                    let destVc:WallPostViewVC = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
                    destVc.controllerType = .isFromSaved
                    self.navigationController?.pushViewController(destVc, animated: true)
               
                }else if title == "More Options"{
                   
                    let moreVC:MoreSettingVC = StoryBoard.main.instantiateViewController(withIdentifier: "MoreSettingVC") as! MoreSettingVC
                    moreVC.objUser = objUser
                    self.pushView(moreVC, animated: true)
               
                }else if title == "Entry Style" {
                   
                    let vc =  StoryBoard.feeds.instantiateViewController(withIdentifier: "EntryStyleSelectionVC") as! EntryStyleSelectionVC
                    vc.pickzonUser = self.objUser
                    self.navigationController?.pushViewController(vc, animated: true)
               
                }else if title == "Frame" {
                    
                    let vc =  StoryBoard.feeds.instantiateViewController(withIdentifier: "FrameSelectionVC") as! FrameSelectionVC
                    vc.pickzonUser = self.objUser
                    vc.frameDelegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
               
                }else if title == "Gallery" {
                    self.openGallary()
                    
                }else if title == "Camera" {
                    self.openCamera()
                }
                
            }else{
                if title == "Share Profile"{
                    ShareMedia.shareMediafrom(type: .profile, mediaId: otherMsIsdn, controller: self)
                }else if title == "Block" {
                    let message =  (objUser.isBlock == 1) ? "unblock" : "block"
                    
                    AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to \(message)?" as NSString, buttonTitles: ["Yes","No"], onController: self) { title, index in
                        
                        if index == 0{
                            
                            self.blockUnblockUserApi(isBlock: (self.objUser.isBlock == 1) ? false : true)
                        }
                    }
                }else if title == "Report"{
                    
                    let destVc:ReportUserVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ReportUserVC") as! ReportUserVC
                    destVc.modalPresentationStyle = .overCurrentContext
                    destVc.modalTransitionStyle = .coverVertical
                    destVc.reportType = .user
                    destVc.reportingId = otherMsIsdn
                    self.present(destVc, animated: true, completion: nil)
                    // self.messageAlertWithReport()
                }
            }
        }
    }
  
    func messageAlertWithReport() {
        
        let alertController = UIAlertController(title: "Report ", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Submit", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            if (firstTextField.text?.trim().count ?? 0 > 0){
                self.reportUserApi(reason: firstTextField.text!)
            }
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
   
    
    //MARK: User Edit Delegate
    
    func getUpdatedObject(user:UserModel){
        
        getUserInfoDetails()
    }
    
    //MARK: UIButton Action Methods
  
    func threeDotOptionsMethod(){
        
        isOptionProfileSelected = true
        
        let controller = UIStoryboard(name: "TableViewDemo", bundle: nil).instantiateInitialViewController()! as! TableViewDemo
        
        var percentage:Float = 0.40

        if otherMsIsdn == Themes.sharedInstance.Getuser_id()  || otherMsIsdn.count == 0{
            let msg = (objUser.requestCount == 0) ?  "" : "\(objUser.requestCount)"
            controller.listArray = (objUser.usertype == 1) ? ["Share Profile","Friend Request List","Blocked User List","Edit Profile","Verification Request", "Saved Posts","More Options"] : ["Share Profile","Blocked User List","Edit Profile","Verification Request", "Saved Posts","More Options"]
            controller.iconArray =  (objUser.usertype == 1) ? ["Shareicon","friend","BlockAccount","Edit-1", "verifyProfile","saveIcon","more1"] : ["Shareicon","BlockAccount","Edit-1","verifyProfile","saveIcon","more1"]
            
            controller.countRowIndex = 1
            controller.countNotification = msg
        }else{
            controller.listArray = ["Share Profile","Block","Report"]
            controller.iconArray = ["Shareicon","BlockAccount","Report"]
            percentage = 0.20
        }
        controller.isToHideSeperator = false
        controller.videoIndex = 0
        controller.delegate = self
        let useInlineMode = view != nil
        
        let sheet = SheetViewController(
            controller: controller,
            sizes: [.percent(percentage), .intrinsic],
            options: SheetOptions(useFullScreenMode:false, shrinkPresentingViewController:false, useInlineMode: useInlineMode))
        sheet.allowPullingPastMaxHeight = false
        if let view = view {
            sheet.animateIn(to: view, in: self)
        } else {
            self.present(sheet, animated: true, completion: nil)
        }
    }
   
    @IBAction func threeButtonSwipeAction(_ sender : UIButton){
        threeDotOptionsMethod()
    }
    
    @IBAction func followSwipeBtnAction(_ sender : UIButton){
        
        if (objUser.isFollow == 2) {
            
            AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to cancel request?", buttonTitles: ["Yes","No"], onController: self) { title, index in
                if index == 0{
                    self.cancelFriendRequestApi()
                }
            }
        }else{
            followBtn()
        }
    }
    
    @IBAction func backButtonSwipeAction(_ sender : UIButton){
        self.backButtonAction()
    }
    
    @objc func blockListBtnAction(_ sender: Any) {
        let vc = StoryBoard.main.instantiateViewController(withIdentifier: "BlockedUserVC") as! BlockedUserVC
        self.pushView(vc, animated: true)
    }
    
    @objc func friendRequestBtnAction(_ sender: Any) {
        
        let viewController:SuggestionListVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "SuggestionListVC") as! SuggestionListVC
        viewController.isRequestSelected = true
        viewController.isContactSelected = false
        viewController.isSuggestedSelected = false
        self.navigationController?.pushView(viewController, animated: true)
    }
  
    
    @objc func linkBtnAction(_ sender: Any) {
        
        if objUser.website.count == 0{
            return
        }
        var strURL = ""
        if objUser.website.starts(with: "http") == true {
            strURL = objUser.website
        }else {
            strURL = "https://" + objUser.website
        }
        guard let url = URL(string:strURL) ?? URL(string: "") else {
            self.view.makeToast(message: "This is not a valid URL." , duration: 3, position: HRToastActivityPositionDefault)
            return  }
        
        if UIApplication.shared.canOpenURL(url) {
            
            let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
            vc.urlString = strURL
            navigationController?.pushViewController(vc, animated: true)
        }else {
            print("Not able to open url")
        }
    }
   
    @objc func mutualFriendsBtnAction(_ sender: Any) {
        
        var userId = ""
        
        if otherMsIsdn == Themes.sharedInstance.Getuser_id()  || otherMsIsdn.count == 0{
            userId = Themes.sharedInstance.Getuser_id()
        }else{
            userId = otherMsIsdn
        }

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FollowingListViewController") as! FollowingListViewController
        vc.userType = .comonFriends
        vc.followUserId = userId
        navigationController?.pushViewController(vc, animated: true)
    }
    
   
    @objc func contactBtnAction(_ sender: UIButton){
       
        
        if (objUser.isFollow == 2) && objUser.usertype == 1 {
            
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Once request accepted you can contact")
            
        }else if ((objUser.isFollow == 2) || (objUser.isFollow == 0) || (objUser.isFollow == 3)) && objUser.usertype == 1  && otherMsIsdn != Themes.sharedInstance.Getuser_id(){
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Please follow to contact.")
       
        }else{
            
            let alert = UIAlertController(title: "Contact", message: nil, preferredStyle: .actionSheet)
            
            if objUser.showMobile == 1{
                alert.addAction(UIAlertAction(title: "Call: \(objUser.mobileNo)", style: .default, handler: { _ in
                    if let url = URL(string: "tel://\(self.objUser.mobileNo)") {
                        UIApplication.shared.openURL(url)
                    }
                }))
            }
            if objUser.showEmail == 1{
                alert.addAction(UIAlertAction(title: "Mail: \(objUser.email)", style: .default, handler: { _ in
                    self.sendEmail()
                    
                }))
            }
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
        
    
    
    func getMutualFriend(mutualArray:NSArray){
        /*
        var i = 0
        
        for mutualDict in mutualArray
        {
            
            var profilePic = (mutualDict as? NSDictionary)?.value(forKey: "ProfilePic") as? String ?? ""
            let name = (mutualDict as? NSDictionary)?.value(forKey: "Name") as? String ?? ""
            
            if profilePic.length > 0  && !profilePic.contains("http"){
                if profilePic.prefix(1) == "." {
                    profilePic = String(profilePic.dropFirst(1))
                }
                profilePic = Themes.sharedInstance.getURL() + profilePic
            }
            if i == 0{
                self.imgVwScndFollowedBy.kf.setImage(with: URL(string: profilePic), placeholder: UIImage(named: "avatar")!, options: nil, progressBlock: nil) { response in}
                self.btnFollowedBy.setAttributedText(firstText: "Followed by ", firstcolor: UIColor.darkGray, seconText: "\(name) and other", secondColor: UIColor.black)
             //   self.btnFollowedBy.setTitle("Followed by \(name) and others", for: .normal)
               // followUserId  = (mutualDict as? NSDictionary)?.value(forKey: "_id") as? String ?? ""
                self.imgVwScndFollowedBy.isHidden = false
            }else if i == 1{
                
                self.imgVwFollowedBy.kf.setImage(with: URL(string: profilePic), placeholder: UIImage(named: "avatar")!, options: nil, progressBlock: nil) { response in}
                self.btnFollowedBy.setAttributedText(firstText: "Followed by ", firstcolor: UIColor.darkGray, seconText: "\(name) and other", secondColor: UIColor.black)
                self.imgVwFollowedBy.isHidden = false
            }else{
                break
            }
            
            print(profilePic)

            i  = i + 1
        }
       */
    }
  
    
    //MARK: Database Operation
    
    func fetchUserInfoFromDB(userId:String){
        
        guard let realm = DBManager.openRealm() else {
            return
        }
        if let existingUser =  realm.object(ofType: DBUser.self, forPrimaryKey: userId) {
            
            objUser.name = existingUser.name
            objUser.email = existingUser.emailId
            objUser.pickzonId = existingUser.pickzonId
            objUser.description =  existingUser.desc
            objUser.dob = existingUser.dob
            objUser.headline = existingUser.organization
            objUser.gender = existingUser.gender
            objUser.jobProfile = existingUser.jobProfile
            objUser.livesIn = existingUser.livesIn
            objUser.followerCount = existingUser.totalFans
            objUser.followingCount = existingUser.totalFollowing
            objUser.postCount = existingUser.totalPost
            objUser.mobileNo = existingUser.mobileNo
            objUser.usertype = existingUser.usertype
            objUser.website = existingUser.website
            objUser.coverImage = existingUser.coverImage
            objUser.actualProfileImage = existingUser.actualProfilePic
            objUser.profilePic = existingUser.profilePic
            objUser.avatar = existingUser.avatar
            objUser.allGiftedCoins = existingUser.allGiftedCoins
            objUser.angelsCount = existingUser.angelsCount
            objUser.giftingLevel = existingUser.giftingLevel
        }
        
        UIView.setAnimationsEnabled(false)
        self.tableViewProfile.reloadSections(IndexSet(integer: 0), with: .none)
        UIView.setAnimationsEnabled(true)
    }
    
    //MARK: Api Methods
    func reportUserApi(reason:String){
        
        DispatchQueue.main.async {
        Themes.sharedInstance.showActivityViewTop(View: self.view, isTop: false)
        }
        let params = NSMutableDictionary()
        params.setValue(otherMsIsdn, forKey: "reportUserId")
        params.setValue(reason, forKey: "reason")

        URLhandler.sharedinstance.makePostAPICall(url: Constant.sharedinstance.reportUserProfile, param: params) { responseObject, error in
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)}
            self.isDataLoading = false
            
            if(error != nil)
            {
                DispatchQueue.main.async {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    print(error ?? "defaultValue")
                    self.isDataLoading = false
                }
            }else{
                let result = responseObject! as NSDictionary
              //  let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
            }
        }
    }
    
    func getAllVideoList(){
        
        if pageNoVideo == 1{
            DispatchQueue.main.async {
                Themes.sharedInstance.activityView(View: self.view)
            }
        }
        let url = Constant.sharedinstance.getUserVideosList + "/\(otherMsIsdn)/\(pageNoVideo)"
        self.isDataLoading = true


        URLhandler.sharedinstance.makeGetAPICall(url: url, param: NSMutableDictionary()) { responseObject, error in
                 
            if(error != nil)
            {
                DispatchQueue.main.async {
                    
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    print(error ?? "defaultValue")
                    self.isDataLoading = false
                }
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
               // let message = result["message"] as? String ?? ""
               
                self.isFirstTime = false

                if status == 1{
                    
                    if let data = result.value(forKey: "payload") as? NSArray {
                        
                        if self.pageNoVideo == 1{
                            self.videoPostArray.removeAll()
                            self.tableViewProfile.reloadData()
                        }
                        
                        for obj in data {
                            self.videoPostArray.append( WallPostModel(dict: obj as! NSDictionary))
                            autoreleasepool {
                                if let cell = self.tableViewProfile.cellForRow(at: IndexPath(row: 0, section: 1)) as? BusinessMediaTblCell {
                                    cell.wallPostArray = self.videoPostArray
                                    cell.isClipsVideo = true
                                    cell.cllctnVw?.insertItems(at: [IndexPath(row: self.videoPostArray.count - 1, section: 0)])
                                }
                            }
                        }
                        
                        self.isDataMoreAvailable = (data.count == 0) ? false : true
                    }
                    
                    self.isFirstTime = self.videoPostArray.count > 0 ? true : false
                    self.updateUserInfo()
                    self.tableViewProfile.reloadData({
                        self.isDataLoading = false
                    })
                    
                }else{
                    self.isDataLoading = false
                }
            }
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
            }
        }
    }
    
    
    func getAllUserPostListApi(){
      
        self.isDataLoading = true
        let followmsisdn = (otherMsIsdn.count == 0) ? Themes.sharedInstance.Getuser_id() : otherMsIsdn

        let url = "\(Constant.sharedinstance.showUserFeedsList)/\(followmsisdn)/\(pageNo)"
    

        
        URLhandler.sharedinstance.makeGetCall(url: url, param: NSDictionary()) {(responseObject, error) ->  () in
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                self.isDataLoading = false

           
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
                
                self.isFirstTime = false
                if self.pageNo == 1{
                    self.arrwallPost.removeAll()
                    self.tableViewProfile.reloadData()
                }
                if status == 1 {
                    
                    let postArr = result.value(forKey: "payload") as? NSArray ?? []
                    for postDict in postArr {
                        
                        self.arrwallPost.append(WallPostModel(dict: postDict as? NSDictionary ?? [:]))
                        
                        autoreleasepool {
                            
                            if let cell = self.tableViewProfile.cellForRow(at: IndexPath(row: 0, section: 1)) as? BusinessMediaTblCell {
                                cell.wallPostArray = self.arrwallPost
                                cell.cllctnVw?.insertItems(at: [IndexPath(row: self.arrwallPost.count - 1, section: 0)])
                            }
                        }
                    }
                    self.isDataMoreAvailable = (postArr.count == 0) ? false : true

                    self.isFirstTime = self.arrwallPost.count > 0 ? true : false
                    self.updateUserInfo()
                    
                    self.tableViewProfile.reloadAnimately({
                    })
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.isDataLoading = false
                    }
                   
                }else{
                    let status = result["status"] as? Int ?? 0
                    self.isDataLoading = false

                    if status == 0{
                        
                        if message as! String == "You have blocked this user" {
                            
                            AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: message as? NSString ?? "", buttonTitles: ["Unblock","Cancel"], onController: self) { title, index in
                                if index == 0{
                                    self.blockUnblockUserApi(isBlock: false)
                                }else{
                                    self.backButtonAction()
                                }
                            }
                        }else{
                           
                            AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: message as? NSString ?? "", buttonTitles: ["OK"], onController: self) { title, index in
                                self.backButtonAction()
                            }
                        }
                        
                    }else{
                        self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)

                    }
                }
            }
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
            }
        }
    }
  
    
     func getUserTagPostApi(){
         self.isDataLoading = true

         let followmsisdn = (otherMsIsdn.count == 0) ? Themes.sharedInstance.Getuser_id() : otherMsIsdn
         
        let url = "\(Constant.sharedinstance.getTagUserPost)?userId=\(followmsisdn)&pageNumber=\(pageNoTag)&pageLimit=\(pageLimit)"
         if self.pageNoTag == 1{
         DispatchQueue.main.async {
                 Themes.sharedInstance.activityView(View: self.view)
             }
         }
         
           URLhandler.sharedinstance.makeGetCall(url: url, param: NSDictionary()) {(responseObject, error) ->  () in
              
               if(error != nil)
               {
                   self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                   print(error ?? "defaultValue")
                   self.isDataLoading = false

               }else{
                   let result = responseObject! as NSDictionary
                   let status = result["status"] as? Int ?? 0
                   let message = result["message"]
                   self.isFirstTime = false

                 if status == 1{
                     if self.pageNoTag == 1{
                        self.tagArray.removeAll()
                         self.tableViewProfile.reloadData()
                     }
                     
                   if  let payloadArray = result.value(forKey: "payload") as? NSArray {
                      
                       for dict in payloadArray
                       {
                           self.tagArray.append(WallPostModel(dict: dict as? NSDictionary ?? [:]))
                           autoreleasepool {
                               if let cell = self.tableViewProfile.cellForRow(at: IndexPath(row: 0, section: 1)) as? BusinessMediaTblCell {
                                   cell.wallPostArray = self.tagArray
                                   cell.cllctnVw?.insertItems(at: [IndexPath(row: self.tagArray.count - 1, section: 0)])
                               }
                           }
                       }
                       self.isDataMoreAvailable = (payloadArray.count == 0) ? false : true
                   }
                    
                         self.isFirstTime = self.tagArray.count > 0 ? true : false
                         self.updateUserInfo()
                         self.tableViewProfile.reloadAnimately({ })
                         DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                             self.isDataLoading = false
                         }
                 }
                 else
                 {
                     self.view.makeToast(message: message as! String, duration: 1, position: HRToastActivityPositionDefault)
                     self.isDataLoading = false

                 }

             }
               DispatchQueue.main.async {
                   Themes.sharedInstance.RemoveactivityView(View: self.view)
               }
         }
     }
     
     
    
     func getSharedPostListApi() -> () {
         
         let followmsisdn = (otherMsIsdn.count == 0) ? Themes.sharedInstance.Getuser_id() : otherMsIsdn

         let url = "\(Constant.sharedinstance.getSharedPost)?userId=\(followmsisdn)&pageNumber=\(pageNoShared)&pageLimit=\(pageLimit)"
        
         if self.pageNoShared == 1{
             DispatchQueue.main.async {
                 Themes.sharedInstance.activityView(View: self.view)
             }
         }
         
         self.isDataLoading = true

         URLhandler.sharedinstance.makeGetCall(url:url, param: NSDictionary(), completionHandler: {(responseObject, error) ->  () in
             if(error != nil)
             {
                 self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                 print(error ?? "defaultValue")
                 self.isDataLoading = false

             }else{
                 let result = responseObject! as NSDictionary
                 let status = result["status"] as? Int16 ?? 0
                 let message = result["message"]
                 self.isFirstTime = false

                 if status == 1{
                     
                     if self.pageNoShared == 1{
                        self.sharedArray.removeAll()
                         self.tableViewProfile.reloadData()
                     }

                     if  let payloadArray = result.value(forKey: "payload") as? NSArray {
                         for dict in payloadArray
                         {
                             self.sharedArray.append(WallPostModel(dict: dict as? NSDictionary ?? [:]))
                             autoreleasepool {
                                 
                                 if let cell = self.tableViewProfile.cellForRow(at: IndexPath(row: 0, section: 1)) as? BusinessMediaTblCell {
                                     cell.wallPostArray = self.sharedArray
                                     cell.cllctnVw?.insertItems(at: [IndexPath(row: self.sharedArray.count - 1, section: 0)])
                                 }
                             }
                         }
                         self.isDataMoreAvailable = (payloadArray.count == 0) ? false : true

                     }
                     
                     
                     self.isFirstTime = self.sharedArray.count > 0 ? true : false
                     self.updateUserInfo()
                     
                     self.tableViewProfile.reloadAnimately({
                     })
                     DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                         self.isDataLoading = false
                     }
                     
                 }
                 else
                 {
                     self.view.makeToast(message: message as! String, duration: 1, position: HRToastActivityPositionDefault)
                     self.isDataLoading = false

                 }
             }
             DispatchQueue.main.async {
                 Themes.sharedInstance.RemoveactivityView(View: self.view)
             }
         })
     }
    
     
    func deleteClipVideoApi(index:Int){
        
        let id =  videoPostArray[safe: index]?.id ?? ""
       
        Themes.sharedInstance.activityView(View: self.view)
       
        URLhandler.sharedinstance.makeDeleteAPICall(url: Constant.sharedinstance.deleteWallPost + "/\(id)", param: NSDictionary()) { responseObject, error in

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
                    
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)

                    self.videoPostArray.remove(at: index)
                    self.tableViewProfile.reloadWithoutAnimation()
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
        
    }
    
    
    func blockUnblockUserApi(isBlock:Bool){
   
        let param:NSDictionary = ["blockuserId":otherMsIsdn,"key":(isBlock) ? 1 : 0]
       
        URLhandler.sharedinstance.makeCall(url: Constant.sharedinstance.blockUnblockuser, param: param, completionHandler: {(responseObject, error) ->  () in
                   Themes.sharedInstance.RemoveactivityView(View: self.view)
                   if(error != nil)
                   {
                       self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                   }
                   else{
                       let result = responseObject! as NSDictionary
                       let status = result["status"] as? Int ?? 0
                       let message = result["message"]
                      
                       if status == 1{
                        
                           if isBlock == false{

                               self.getUserInfoDetails()
                               self.getAllUserPostListApi()
                         
                           }else{
                               let params = ["authToken":Themes.sharedInstance.getAuthToken(),"blockUserId":self.otherMsIsdn] as NSDictionary
                               SocketIOManager.sharedInstance.emitEvent(Constant.sharedinstance.sio_check_block_unblock_user, params)
                               AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: message as? NSString ?? "", buttonTitles: ["OK"], onController: self) { title, index in
                                   self.backButtonAction()
                               }
                               NotificationCenter.default.post(name: NSNotification.Name(rawValue: noti_RefreshFeed), object:nil)
                           }
                       }
                       else
                       {
                           self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                       }
                   }
            })
    }
    
    
    func followBtn( ){
        
        if objUser.isBlock  == 1 {
            let message = (objUser.isBlock  == 0) ? "block" : "unblock"
            
            AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to \(message)?" as NSString, buttonTitles: ["Yes","No"], onController: self) { title, index in
                
                if index == 0{
                   // self.blockUnblockUserApi(isBlock: , )
                }
            }
            
        }else {
            
            Themes.sharedInstance.activityView(View: self.view)
        
             let status =  (objUser.isFollow == 0 || objUser.isFollow == 3) ? "1" : "0"
            
            let param:NSDictionary = ["followedUserId":otherMsIsdn,"status":status]
            
            URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.follow as String, param: param, completionHandler: {(responseObject, error) ->  () in
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                if(error != nil)
                {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    
                }else{
                    let result = responseObject! as NSDictionary
                    let status = result["status"] as? Int ?? 0
                    let message = result["message"]
                    let payloadDict = result["payload"] as? NSDictionary ?? [:]
                    
                    if status == 1{
                        
                        self.objUser.isFollow = payloadDict["isFollow"] as? Int ?? 0
                      
                      //  self.objUser.followStatusButton = getFollowUnfollowRequestedText(isFollowValue:self.objUser.followStatus)
                        self.tableViewProfile.reloadAnimately {
                        }
                        self.updateUserInfo()
                        self.updateSelectedArrayWithId(userId: self.otherMsIsdn, isFollwing: self.objUser.isFollow)
                       
                        let objDict:Dictionary<String, Any> = ["userId":self.otherMsIsdn , "isFollowed":self.objUser.isFollow]
                        NotificationCenter.default.post(name: notif_FeedFollowed, object: objDict)
                    }
                    else
                    {
                        self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
            })
        }
    }
    
    
    
    func cancelFriendRequestApi(){
        Themes.sharedInstance.activityView(View: self.view)
            
        let param:NSDictionary = ["followedUserId":otherMsIsdn]
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.cancelRequest as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }
            else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                let payloadDict = result["payload"] as? NSDictionary ?? [:]
                let isFollow = payloadDict["isFollow"] as? Int ?? 0
                
                if status == 1{
                    self.getUserInfoDetails()
                    let objDict:Dictionary<String, Any> = ["userId":self.otherMsIsdn , "isFollowed":isFollow]
                    NotificationCenter.default.post(name: notif_FeedFollowed, object: objDict)
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)

                }else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
   
   
   
    func updateUserInfo(){
        
        self.btnFollowSwipe.isHidden = true
        self.lblSwipeName.text = objUser.pickzonId
        self.btnThreeDotSwipe.isHidden = false
        
        self.celebritySwipe.isHidden = true
         if objUser.celebrity == 1{
            self.celebritySwipe.isHidden = false
            self.celebritySwipe.image = PZImages.greenVerification
        }else if objUser.celebrity == 4{
            self.celebritySwipe.isHidden = false
            self.celebritySwipe.image = PZImages.goldVerification
        }else if objUser.celebrity == 5{
            self.celebritySwipe.isHidden = false
            self.celebritySwipe.image = PZImages.blueVerification
        }
        
        if Themes.sharedInstance.Getuser_id() == objUser.id{
        }else{
            self.btnFollowSwipe.setTitleColor(CustomColor.sharedInstance.newThemeColor, for: .normal)
            if objUser.isFollow == 0 || objUser.isFollow == 3{
                self.btnFollowSwipe.isHidden = false
            }
            self.btnFollowSwipe.setTitle(getFollowUnfollowRequestedText(isFollowValue: objUser.isFollow), for: .normal)
        }
//                self.tblFooterVw.frame = .zero
//                self.tblFooterVw.isHidden = true
//                self.lblErrorMessage.text = ""
        
        if self.objUser.usertype == 1 && (self.objUser.isFollow == 0 || self.objUser.isFollow == 2 || self.objUser.isFollow == 3) && Themes.sharedInstance.Getuser_id() != self.otherMsIsdn{
            self.tblFooterVw.isHidden = false
            self.lblErrorMessage.text = "Private account"
            self.tblFooterVw.frame = CGRect(x:  self.tblFooterVw.frame.origin.x, y:  self.tblFooterVw.frame.origin.y, width: self.tblFooterVw.frame.size.width, height: 290)
            self.imgVwEmpty.image = UIImage(named: "LockProfile")
            self.lblDescErrorMessage.text = "Follow this account to see posts and videos"
        }else if selectedTab == 0 && arrwallPost.count == 0 && isFirstTime == false{
            
            self.tblFooterVw.isHidden = false
            self.lblErrorMessage.text = "No Post"
            self.tblFooterVw.frame = CGRect(x:  self.tblFooterVw.frame.origin.x, y:  self.tblFooterVw.frame.origin.y, width: self.tblFooterVw.frame.size.width, height: 290)
            
        }else if selectedTab == 1 && videoPostArray.count == 0 && isFirstTime == false{
            self.tblFooterVw.isHidden = false
            self.lblErrorMessage.text = "No Clips"
            self.tblFooterVw.frame = CGRect(x:  self.tblFooterVw.frame.origin.x, y:  self.tblFooterVw.frame.origin.y, width: self.tblFooterVw.frame.size.width, height: 290)
        }else if selectedTab == 2 && tagArray.count == 0 && isFirstTime == false{
            self.tblFooterVw.isHidden = false
            self.lblErrorMessage.text = "No Tagged Post"
            self.tblFooterVw.frame = CGRect(x:  self.tblFooterVw.frame.origin.x, y:  self.tblFooterVw.frame.origin.y, width: self.tblFooterVw.frame.size.width, height: 290)
        }else if selectedTab == 3 && sharedArray.count == 0 && isFirstTime == false{
            self.tblFooterVw.isHidden = false
            self.lblErrorMessage.text = "No Shared Post"
            self.tblFooterVw.frame = CGRect(x:  self.tblFooterVw.frame.origin.x, y:  self.tblFooterVw.frame.origin.y, width: self.tblFooterVw.frame.size.width, height: 290)
        }else{
            self.tblFooterVw.frame = .zero
            self.tblFooterVw.isHidden = true
            self.lblErrorMessage.text = ""
        }
        
    }
    
    
    func getUserMutualFriendsApi(){
        
        let followmsisdn =  (otherMsIsdn.count == 0) ? Themes.sharedInstance.Getuser_id() : otherMsIsdn
        
        let url = "\(Constant.sharedinstance.get_user_mutual)?userId=\(followmsisdn)"
        
        URLhandler.sharedinstance.makeGetCall(url: url, param: NSDictionary()) { [weak self] (responseObject, error) ->  () in
           
            if(error != nil)
            {
                self?.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                
                if status == 1 {
                    if let payload =   result["payload"] as? Dictionary<String,Any>{
                       
                        if let  mutualFriend = payload["mutualFriend"] as?  Array<Dictionary<String,Any>>{
                            self?.objUser.mutualFriend = mutualFriend
                        }
                        self?.tableViewProfile.reloadAnimately{}
                    }
                }
            }
        }
    }
    
    
    func getUserInfoDetails(){
        
        let followmsisdn =  (otherMsIsdn.count == 0) ? Themes.sharedInstance.Getuser_id() : otherMsIsdn
        
        DispatchQueue.main.async {
            if self.objUser.name.length == 0 {
                self.showHideShimmerView(isTohide: false)
            }
        }
        let url = "\(Constant.sharedinstance.showUserInfo)/\(followmsisdn)"
        
        URLhandler.sharedinstance.makeGetCall(url: url, param: NSDictionary()) { [weak self] (responseObject, error) ->  () in
            DispatchQueue.main.async {
                self?.showHideShimmerView(isTohide: true)
            }
            if(error != nil)
            {
                self?.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
            
                    self?.shimmerReplicatorView.startAnimating()
                    let result = responseObject! as NSDictionary
                    self?.updateData(result: result)
                
                //Call this api for other users and check if mutual dictonary count as well
                if (Themes.sharedInstance.Getuser_id() != followmsisdn)  && (self?.objUser.mutualFriend.count == 0){
                    self?.getUserMutualFriendsApi()
                }
            }
        }
    }
    
    
    func updateData(result:NSDictionary){
        
        let status = result["status"] as? Int ?? 0
        let message = result["message"] as? String ?? ""

        if status == 1 {
            if let payloadDict = result["payload"] as? NSDictionary {
                self.objUser = PickzonUser(respdict: payloadDict)
            }
            self.isExpanded = true
            DispatchQueue.main.async {
                self.updateUserInfo()
                self.tableViewProfile.reloadAnimately{
                }
            }
            
            if  self.objUser.profilePic.count > 0 && Themes.sharedInstance.Getuser_id() == self.objUser.id {
                let user_ID = Themes.sharedInstance.Getuser_id()
                let CheckUser:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString:user_ID as String?)
                if (!CheckUser){
                    
                }else{
                    let UpdateDict:[String:Any]=["profilepic": self.objUser.profilePic, "mobilenumber":"\(self.objUser.mobileNo)"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail , FetchString: user_ID, attribute:"user_id" , UpdationElements: UpdateDict as NSDictionary?)
                }
            }
            
            if self.otherMsIsdn == Themes.sharedInstance.Getuser_id() || self.otherMsIsdn.length == 0{
                DBManager.shared.insertOrUpdateUSerDetail(userId: self.objUser.id, userObj: self.objUser)
                Themes.sharedInstance.savePickZonID(pickzonId: self.objUser.pickzonId)
            }
            
        }else{
            
            if status == 0{
                
                if message == "You have blocked this user" {
                    
                    AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: message as NSString, buttonTitles: ["Unblock","Cancel"], onController: self) { title, index in
                        if index == 0{
                            self.blockUnblockUserApi(isBlock: false)
                        }else{
                            self.backButtonAction()
                        }
                    }
                }else{
                   

                    AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: message as NSString , buttonTitles: ["OK"], onController: self) { title, index in
                        self.backButtonAction()
                    }
                }
                
            }else{
                self.view.makeToast(message: message, duration: 3, position: HRToastActivityPositionDefault)
            }
        }
    }
    
    //MARK: NSNotification Observers methods
    
    @objc func feedRemovedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            
            if let objIndex = arrwallPost.firstIndex(where:{$0.id == feedId}) {
                DispatchQueue.main.async {
                    self.arrwallPost.remove(at: objIndex)
                    self.tableViewProfile.reloadData()
                }
            }
            
            if let objIndex = videoPostArray.firstIndex(where:{$0.id == feedId}) {
                DispatchQueue.main.async {
                    self.videoPostArray.remove(at: objIndex)
                    self.tableViewProfile.reloadData()
                }
            }
            
            if let objIndex = tagArray.firstIndex(where:{$0.id == feedId}) {
                DispatchQueue.main.async {
                    self.tagArray.remove(at: objIndex)
                    self.tableViewProfile.reloadData()
                }
            }
            
            if let objIndex = sharedArray.firstIndex(where:{$0.id == feedId}) {
                DispatchQueue.main.async {
                    self.sharedArray.remove(at: objIndex)
                    self.tableViewProfile.reloadData()
                }
            }
        }
    }
    
    @objc func feedTagRemovedNotification(notification: Notification) {
        //print("Value of notification : ", notification.object ?? "")
        
        if let objDict = notification.object as? Dictionary<String, Any> {
            let feedId = objDict["feedId"] as? String ?? ""
            
            if let objIndex = arrwallPost.firstIndex(where:{$0.id == feedId}) {
               
                if arrwallPost.count > objIndex {
                    var objWallpost = videoPostArray[objIndex]
                    objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "@\(Themes.sharedInstance.getPickzonId())", with: "")
                    objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "  ", with: " ")
                    self.arrwallPost[objIndex] = objWallpost
                    DispatchQueue.main.async {
                        self.tableViewProfile.reloadData()
                    }
                }
            }
            
            if let objIndex = videoPostArray.firstIndex(where:{$0.id == feedId}) {
              
                if videoPostArray.count > objIndex {
                 var objWallpost = videoPostArray[objIndex]
                    objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "@\(Themes.sharedInstance.getPickzonId())", with: "")
                    objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "  ", with: " ")
                    self.videoPostArray[objIndex] = objWallpost
                    DispatchQueue.main.async {
                        self.tableViewProfile.reloadData()
                    }
                }
            }
            if let objIndex = tagArray.firstIndex(where:{$0.id == feedId}) {
                if tagArray.count > objIndex {
                    var objWallpost = tagArray[objIndex]
                    objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "@\(Themes.sharedInstance.getPickzonId())", with: "")
                    objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "  ", with: " ")
                    self.tagArray[objIndex] = objWallpost
                    DispatchQueue.main.async {
                        self.tableViewProfile.reloadData()
                    }
                }
            }
            if let objIndex = sharedArray.firstIndex(where:{$0.id == feedId}) {
              
                    
                    if sharedArray.count > objIndex {
                     var objWallpost = sharedArray[objIndex]
                        
                    objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "@\(Themes.sharedInstance.getPickzonId())", with: "")
                    objWallpost.taggedPeople = objWallpost.taggedPeople.replacingOccurrences(of: "  ", with: " ")
                    self.sharedArray[objIndex] = objWallpost
                    DispatchQueue.main.async {
                        self.tableViewProfile.reloadData()
                    }
                }
            }
        }
    }
    
    
    @objc func refreshList(notification: Notification) {
        getUserInfoDetails()
    }
    
    @objc func feedFollwedNotification(notification: Notification) {
        if let objDict = notification.object as? Dictionary<String, Any> {
            let userId = objDict["userId"] as? String ?? ""
            let isFollowed = objDict["isFollowed"] as? Int ?? 0
            self.updateSelectedArrayWithId(userId: userId, isFollwing: isFollowed)
        }
    }
}



extension ProfileVC:MFMailComposeViewControllerDelegate{
    
    func sendEmail(){
        if (MFMailComposeViewController.canSendMail()) {
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self;
            mail.setToRecipients([objUser.email])
            mail.setSubject("")
            mail.setMessageBody("", isHTML: false)
            self.present(mail, animated: true, completion: nil)
        }
        else
        {
            self.view.makeToast(message: "Mail service not available", duration: 3, position: HRToastActivityPositionDefault)
        }
    }
  
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        self.dismissView(animated: true, completion: nil)
        
        var message = ""
        
        if(error != nil) {
            message = "Error Occurred."
        }
        else
        {
            switch result {
            case .cancelled:
                message = "Mail cancelled."
                break
            case .failed:
                message = "Mail failed."
                break
            case .sent:
                message = "Mail sent."
                break
            case .saved:
                message = "Mail saved."
                break
            default:
                break
            }
        }
        self.view.makeToast(message: message, duration: 3, position: HRToastActivityPositionDefault)
    }
}





extension ProfileVC:UITableViewDelegate,UITableViewDataSource{
    
    func registerCell(){
        tableViewProfile.register(UINib(nibName: "ProfileHeaderTblCell", bundle: nil),
                                  forCellReuseIdentifier: "ProfileHeaderTblCell")
 
        tableViewProfile.register(UINib(nibName: "TabHeaderTblCell", bundle: nil),
                                  forHeaderFooterViewReuseIdentifier: "TabHeaderTblCell")
        tableViewProfile.register(UINib(nibName: "SponserTblCell", bundle: nil),
                                  forCellReuseIdentifier: "SponserTblCell")
        tableViewProfile.register(UINib(nibName: "BusinessMediaTblCell", bundle: nil), forCellReuseIdentifier: "BusinessMediaTblCell")
        
        tableViewProfile.register(UINib(nibName: "LoadMoreTblCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTblCell")
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1{
            return 50
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let cell = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "TabHeaderTblCell")! as! TabHeaderTblCell
        
        if section == 1 {
            
            cell.cnstntHt_CollectionView.constant = 50
            cell.delegate = self
            cell.isToshow = true
            cell.selectedTab = selectedTab
            cell.tabArray =  ["Posts","Clips","Tags","Shared"]
            
        }else{
            cell.isToshow = false
            cell.cnstntHt_CollectionView.constant = 0
        }
        cell.collectionVw.reloadWithoutAnimation()
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if objUser.usertype == 1 && (objUser.isFollow == 0 || objUser.isFollow == 2 || objUser.isFollow == 3) && Themes.sharedInstance.Getuser_id() != otherMsIsdn && indexPath.section > 0{
            return 0
        }
        
        if (indexPath.section == 1 && selectedTab == 0) && indexPath.row == 0{
            
           return calculateHeightWithArray(withArray: arrwallPost, extraHt: 10)
            
        }else if (indexPath.section == 1 && selectedTab == 1) && indexPath.row == 0{
            
            return calculateHeightWithArray(withArray: videoPostArray, extraHt: 100)
            
        }else if (indexPath.section == 1 && selectedTab == 2) && indexPath.row == 0{
          
            return calculateHeightWithArray(withArray: tagArray, extraHt: 10)

        }else if (indexPath.section == 1 && selectedTab == 3) && indexPath.row == 0{
            
            return calculateHeightWithArray(withArray: sharedArray, extraHt: 10)
        }
     
        return UITableView.automaticDimension
    }
    
    
    
    func calculateHeightWithArray(withArray:[Any],extraHt:Int) -> CGFloat{
        
        let width = CGFloat(self.view.frame.size.width/3.0) + CGFloat(extraHt)
        let divide =  CGFloat( withArray.count/3) * width
        var remainder =  CGFloat(withArray.count % 3) * width
        if  (withArray.count % 3) > 0 && withArray.count % 3 < 3{
            remainder = width
        }else{
            remainder = 0
        }
        return  CGFloat(divide + remainder)
    }
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if section == 0{
            return 1
        }else if section == 1{
        
            if objUser.usertype == 1 && (objUser.isFollow == 0 || objUser.isFollow == 2 || objUser.isFollow == 3) && Themes.sharedInstance.Getuser_id() != otherMsIsdn{
                return 0
            }
            switch selectedTab{
            case 0:
                return (arrwallPost.count == 0) ?  0 : checkNumberOfRowType()
            case 1:
                return (videoPostArray.count == 0) ?  0 : checkNumberOfRowType()
            case 2:
                return (tagArray.count == 0) ?  0 : checkNumberOfRowType()
            case 3:
                return (sharedArray.count == 0) ?  0 : checkNumberOfRowType()

            default:
                break
            }
        
        }
        
        return 0
    }
    
    
    func checkNumberOfRowType() -> Int{
        
        switch selectedTab{
            
        case 0:
            if (arrwallPost.count > 14) && isDataMoreAvailable == true {
                return 2
            }
        case 1:
        
            if (videoPostArray.count > 14)  && isDataMoreAvailable == true{
                return 2
            }
        case 2:
            if (tagArray.count > 14)  && isDataMoreAvailable == true{
                return 2
            }
        case 3:
            if (sharedArray.count > 14)  && isDataMoreAvailable == true {
                return 2
            }
           
        default:
            return 1
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        if indexPath.section == 0{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderTblCell") as! ProfileHeaderTblCell
            cell.lblDescription.delegate = self
            cell.userId = otherMsIsdn
            cell.lblDescription.setLessLinkWith(lessLink: "Read less", attributes: [.foregroundColor:UIColor.red], position: .left)
            
            //  cell.lblDescription.collapsedAttributedLink = NSAttributedString(string: " Read more" ,attributes:  [.foregroundColor:UIColor.systemBlue])
            
            // cell.lblDescription.collapsed = true
            cell.lblDescription.shouldCollapse = true
            cell.lblDescription.textReplacementType = .word
            cell.lblDescription.collapsed = isExpanded
            cell.lblDescription.numberOfLines = 3
            
            if otherMsIsdn == Themes.sharedInstance.Getuser_id(){
                cell.bgVwBtnOption.isHidden = true
                cell.btnOption.isHidden = true
            }else{
                cell.bgVwBtnOption.isHidden = false
                cell.btnOption.isHidden = false
            }
            
            cell.setProfileInfoData(userObj: objUser)
            cell.suggestionArray = objUser.suggestedUsers
            cell.collectioVwSuggestion.reloadWithoutAnimation()
            cell.btnContact.addTarget(self, action: #selector(contactBtnAction(_ : )), for: .touchUpInside)
            cell.btnBack.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
            cell.btnOption.addTarget(self, action: #selector(optionButtonAction(_ : )), for: .touchUpInside)
            cell.btnMessage.addTarget(self, action: #selector(messageBtnAction(_ : )), for: .touchUpInside)
            cell.btnFollow.addTarget(self, action: #selector(followBtnAction(_ : )), for: .touchUpInside)
            cell.btnFollowerCount.addTarget(self, action: #selector(followersBtnAction(_ : )), for: .touchUpInside)
            cell.btnFollowingCount.addTarget(self, action: #selector(followingBtnAction(_ : )), for: .touchUpInside)
            cell.btnPostCount.addTarget(self, action: #selector(postCountBtnAction(_ : )), for: .touchUpInside)
            cell.btnEditProfile.addTarget(self, action: #selector(editProfileBtnAction(_ : )), for: .touchUpInside)
            cell.btnCopy.addTarget(self, action: #selector(copyPickzonIdBtnAction(_ : )), for: .touchUpInside)
            cell.btnAngel.addTarget(self, action: #selector(angelsBtnAction(_ : )), for: .touchUpInside)
            cell.imgVwGiftingLevel.isUserInteractionEnabled = true
            cell.btnNotVerified.addTarget(self, action: #selector(notVerifiedBtnAction(_ : )), for: .touchUpInside)
            cell.imgVwGiftingLevel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                               action:#selector(self.handleGiftingLevelTap(_:))))

            cell.profilePicView.remoteSVGAPlayer?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                          action:#selector(self.handleProfilePicTap(_:))))
            
            cell.imgVwBanner.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                         action:#selector(self.handleCoverTap(_:))))
            
            cell.btnMutualFriend.addTarget(self, action: #selector(mutualFriendsBtnAction(_ : )), for: .touchUpInside)
            cell.btnSeeMoreSuggestion.addTarget(self, action: #selector(seeAllList), for: .touchUpInside)
            cell.btnWallet.addTarget(self, action: #selector(walletBtnAction), for: .touchUpInside)
            cell.delegate = self
            cell.updateConstraints()
            cell.layoutIfNeeded()
            
            
            if (Themes.sharedInstance.Getuser_id() == otherMsIsdn || otherMsIsdn.count == 0) && (objUser.celebrity != 1 && objUser.celebrity != 4 && objUser.celebrity != 5) {
                cell.btnNotVerified.isHidden = false

            }else{
                cell.btnNotVerified.isHidden = true
            }
            return cell
            
        }else if indexPath.section == 1 && selectedTab == 0 && indexPath.row == 0{
                        
            let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessMediaTblCell") as! BusinessMediaTblCell
            cell.tabArray =  ["Posts","Clips","Tags","Share"]

            cell.selectedTab = selectedTab
            cell.tabDelegate = self
            cell.wallPostArray = arrwallPost
            cell.delegate = self
            cell.cllctnVw.isScrollEnabled = false
            cell.isClipsVideo = false
            cell.cllctnVw.reloadWithoutAnimation()

            return cell
            
        }
        else if indexPath.section == 1 && selectedTab == 1 && indexPath.row == 0{
            //Video
            let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessMediaTblCell") as! BusinessMediaTblCell
            cell.tabArray = ["Posts","Clips","Tags","Share"]
            cell.selectedTab = selectedTab
            cell.tabDelegate = self
            cell.wallPostArray = videoPostArray
            cell.delegate = self
            cell.isClipsVideo = true
            cell.isToHideOption = false
            cell.cllctnVw.reloadWithoutAnimation()
            
            return cell
            
        }
        else if indexPath.section == 1 && selectedTab == 2 && indexPath.row == 0{
            //Tag
            let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessMediaTblCell") as! BusinessMediaTblCell
            cell.tabArray =  ["Posts","Clips","Tags","Share"]

            cell.selectedTab = selectedTab
            cell.tabDelegate = self
            cell.wallPostArray = tagArray
            cell.delegate = self
            cell.isClipsVideo = false
            cell.cllctnVw.reloadWithoutAnimation()
           
            return cell
            
        }else if indexPath.section == 1 && selectedTab == 3 && indexPath.row == 0{
            //Shared
            let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessMediaTblCell") as! BusinessMediaTblCell
            cell.tabArray =  ["Posts","Clips","Tags","Share"]

            cell.selectedTab = selectedTab
            cell.tabDelegate = self
            cell.wallPostArray = sharedArray
            cell.isClipsVideo = false
            cell.delegate = self
            cell.cllctnVw.reloadWithoutAnimation()
            
            return cell
                        
        }else  if indexPath.row == 1  && indexPath.section == 1{
            //Loading cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreTblCell", for: indexPath) as! LoadMoreTblCell
            //cell.lblMessage.isHidden = true
            cell.activityIndicator.startAnimating()
            return cell
        }
        
        return UITableViewCell()
    }
 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // print("scrollView.contentOffset.y ==\(scrollView.contentOffset.y)")
        if scrollView.contentOffset.y > 200{
            if cnstrntHt_BackBtn.constant != 30 {
                cnstrntHt_BackBtn.constant = 30
            }
        }else{
            if cnstrntHt_BackBtn.constant != 0 {
                cnstrntHt_BackBtn.constant = 0
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
//        if indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 1){
        
        if indexPath.section == 1 && (indexPath.row == 1){

            
            if self.objUser.usertype == 1 && (self.objUser.isFollow == 0 || self.objUser.isFollow == 2 || objUser.isFollow == 3) && Themes.sharedInstance.Getuser_id() != self.otherMsIsdn{
                
            }else{
                if !(URLhandler.sharedinstance.isConnectedToNetwork()){
                    
                    self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
                    
                }else  if isDataLoading == false {
                    
                    switch selectedTab{
                        
                    case 0:
                            self.pageNo = self.pageNo + 1
                            isDataLoading = true
                            self.getAllUserPostListApi()
                        break
                    case 1:
                            isDataLoading = true
                            self.pageNoVideo = self.pageNoVideo + 1
                            getAllVideoList()
                    
                        break
                        
                    case 2:
                            isDataLoading = true
                            self.pageNoTag = self.pageNoTag + 1
                            self.getUserTagPostApi()
                        break
                    case 3:
                            isDataLoading = true
                            self.pageNoShared = self.pageNoShared + 1
                            self.getSharedPostListApi()
                        break
                        
                    default:
                        break
                        
                    }
                }
            }
        }
    }

    
    //MARK: Selectors
    
    @objc func notVerifiedBtnAction(_ sender: Any) {
        let changeNoVC = StoryBoard.feeds.instantiateViewController(withIdentifier:"RequestVerificationViewController" ) as! RequestVerificationViewController
        self.pushView(changeNoVC, animated: true)
    }

    @objc func angelsBtnAction(_ sender: Any) {
        
        if ((objUser.isFollow == 2) || (objUser.isFollow == 0) || (objUser.isFollow == 3)) && objUser.usertype == 1  && otherMsIsdn != Themes.sharedInstance.Getuser_id(){
        }else{
            let destVC:AngelListVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "AngelListVC") as! AngelListVC
            destVC.userId = otherMsIsdn
            destVC.totalCoinRecieved = objUser.allGiftedCoins
            self.navigationController?.pushViewController(destVC, animated: true)
        }
    }

    
    @objc func copyPickzonIdBtnAction(_ sender: Any) {
        UIPasteboard.general.string = objUser.pickzonId
        self.view.makeToast(message: "@\(objUser.pickzonId) has been copied to clipboard.", duration: 3, position: HRToastActivityPositionDefault)
    }
    
    @objc func optionButtonAction(_ sender: Any) {
        threeDotOptionsMethod()
    }
    
    @objc func editProfileBtnAction(_ sender: Any) {
        
//        if otherMsIsdn == Themes.sharedInstance.Getuser_id()  || otherMsIsdn.count == 0{
//            
//            let editProfileVC:ProfileEditVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "ProfileEditVC") as! ProfileEditVC
//            editProfileVC.pickzonUser = objUser
//            editProfileVC.delegate = self
//            self.pushView(editProfileVC, animated: true)
//        }
//        
//        {
            
            let controller = UIStoryboard(name: "TableViewDemo", bundle: nil).instantiateInitialViewController()! as! TableViewDemo
            var percentage:Float = 0.30
            controller.listArray = ["Entry Style","Frame","Gallery","Camera"]
            controller.iconArray = ["entryStyle","crown1","galley1","cameraFill"]
            controller.videoIndex = 0
            controller.delegate = self
            controller.isToHideSeperator = false
            
            let useInlineMode = view != nil
            let sheet = SheetViewController(
                controller: controller,
                sizes: [.percent(percentage), .intrinsic],
                options: SheetOptions(useFullScreenMode:false, shrinkPresentingViewController:false, useInlineMode: useInlineMode))
            sheet.allowPullingPastMaxHeight = false
            if let view = view {
                sheet.animateIn(to: view, in: self)
            } else {
                self.present(sheet, animated: true, completion: nil)
            }
       // }
    }
   
    
    @objc func postCountBtnAction(_ sender: UIButton){
    }
    
    @objc func followingBtnAction(_ sender: UIButton){
        
        if ((objUser.isFollow == 2) || (objUser.isFollow == 0) || (objUser.isFollow == 3)) && objUser.usertype == 1  && otherMsIsdn != Themes.sharedInstance.Getuser_id(){
        }else{
            let vc = StoryBoard.main.instantiateViewController(withIdentifier: "FollowingListViewController") as! FollowingListViewController
            vc.userType = .followingList
            vc.followUserId = otherMsIsdn
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func followersBtnAction(_ sender: UIButton){
        
        if ((objUser.isFollow == 2) || (objUser.isFollow == 0) || (objUser.isFollow == 3)) && objUser.usertype == 1  && otherMsIsdn != Themes.sharedInstance.Getuser_id(){
        }else{
            let vc = StoryBoard.main.instantiateViewController(withIdentifier: "FollowingListViewController") as! FollowingListViewController
            vc.userType = .followersList
            vc.followUserId = otherMsIsdn
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc  func handleProfilePicTap(_ sender: UITapGestureRecognizer? = nil){
        
        
        if objUser.usertype == 1 && otherMsIsdn != Themes.sharedInstance.Getuser_id() && ((objUser.isFollow == 2) || (objUser.isFollow == 0) || (objUser.isFollow == 3))
        {
            
        }else{
            
            if objUser.actualProfileImage.count > 0{
                
                let zoomCtrl = VKImageZoom()
                zoomCtrl.image_url = URL(string: objUser.actualProfileImage)
                //zoomCtrl.image = sender.currentImage
                zoomCtrl.modalPresentationStyle = .fullScreen
                self.present(zoomCtrl, animated: true, completion: nil)
            }
        }
    }
    
    
    @objc  func handleGiftingLevelTap(_ sender: UITapGestureRecognizer? = nil){
        
        if Settings.sharedInstance.giftingLevelDesc.count > 0{
            
            let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
            vc.strTitle = ""
            vc.urlString = Settings.sharedInstance.giftingLevelDesc
            //vc.isFromAvtar = true
            self.navigationController?.pushViewController(vc, animated: true)
            
//            let zoomCtrl = VKImageZoom()
//            zoomCtrl.image_url = URL(string: Settings.sharedInstance.giftingLevelDesc)
//            zoomCtrl.modalPresentationStyle = .fullScreen
//            self.present(zoomCtrl, animated: true, completion: nil)
        }
    }

    
    
    @objc  func handleCoverTap(_ sender: UITapGestureRecognizer? = nil){
        
        if objUser.usertype == 1 && otherMsIsdn != Themes.sharedInstance.Getuser_id() && ((objUser.isFollow == 2) || (objUser.isFollow == 0) || (objUser.isFollow == 3))
        {
            
        }else{
            
            if objUser.coverImage.count > 0{
                let zoomCtrl = VKImageZoom()
                zoomCtrl.image_url = URL(string: objUser.coverImage)
                //zoomCtrl.image = sender.currentImage
                zoomCtrl.modalPresentationStyle = .fullScreen
                self.present(zoomCtrl, animated: true, completion: nil)
            }
        }
    }
    
    @objc func followBtnAction(_ sender: UIButton){
        
        if (objUser.isFollow == 2) {
            
            AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to cancel request?", buttonTitles: ["Yes","No"], onController: self) { title, index in
                if index == 0{
                    self.cancelFriendRequestApi()
                }
            }
        }else{
            followBtn()
        }
    }
    
    @objc func messageBtnAction(_ sender: UIButton){
        
       /* if (objUser.followStatus == 2) && objUser.usertype == 1 {
            
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Once request accepted you can send message")
            
        }else
        */
        
        if ((objUser.isFollow == 2) || (objUser.isFollow == 0) || (objUser.isFollow == 3)) && objUser.isBlock == 1 {
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Please unblock user before")
        }
        /* else if objUser.isFollowBack == 0{
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Both of you needs to follow each other to send message.")
        }else if (objUser.followStatus == 2)  || (objUser.followStatus == 0){
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Please follow to send message")
        }*/
        else{
            
            let settingsVC:FeedChatVC = StoryBoard.chat.instantiateViewController(withIdentifier: "FeedChatVC") as! FeedChatVC
            settingsVC.toChat = objUser.id
            settingsVC.fromName = (objUser.showName == 1) ? objUser.name : ""
            settingsVC.fullUrl = objUser.profilePic
            settingsVC.pickzonId = objUser.pickzonId 
            self.navigationController?.pushViewController(settingsVC, animated: true)
        }
    }
    
    
    func followUnfollowApi(index:Int,isFromSuggestion:Bool = true,section:Int){
        
        let param:NSDictionary = ["followedUserId":objUser.suggestedUsers[index]["id"] as? String ?? "" ,"status":"1"]
        
        Themes.sharedInstance.activityView(View: self.view)
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.follow as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"]
               // let payloadDict = result["payload"] as? NSDictionary ?? [:]
                //let isFollow = payloadDict["isFollow"] as? Int ?? 0
                
                if status == 1{
                    
                    if isFromSuggestion == true {
                        
                        DispatchQueue.main.async {
                            self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                            self.objUser.suggestedUsers.remove(at: index)
                            self.tableViewProfile.reloadWithoutAnimation()
                            
                        }
                    }
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
   
    
}



extension ProfileVC:TabDelegate,SuggestionDelegate,BusinessMediaDelegate,SuggestionsDelegate,PostClipDelegate {
 
   
    
    func onSuccessClipUpload(clipObj:WallPostModel,selectedIndex:Int){
        videoPostArray[selectedIndex] = clipObj
    }
    
    
    //MARK: Suggestion Delegate
    
    func getSelectedUser() {
        
    }
  
    
    @objc func walletBtnAction(){
        let viewController:WalletVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
        viewController.isGiftedCoinsTabOpen = true
        self.navigationController?.pushView(viewController, animated: true)
    }
    
    @objc  func seeAllList(){
        
        let viewController:SuggestionListVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "SuggestionListVC") as! SuggestionListVC
        self.navigationController?.pushView(viewController, animated: true)
    }
    
    func clickedUserIndex(index:Int, section: Int){
        
        let profileVC:ProfileVC = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.otherMsIsdn = objUser.suggestedUsers[index]["id"] as? String ?? ""
        self.navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
    func cancelSuggestionUser(index:Int,section:Int){
        print("cancelSuggestionUser")
        
        AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: "Are you sure want to remove selected user from suggestion ?", buttonTitles: ["Yes","No"], onController: self) { title, btnIndex in
            
            if btnIndex == 0{
               // self.removeSuggestionApi(index: index,section:section)
            }
        }
    }
    func clickedFollowUser(index:Int,section:Int){
        
        followUnfollowApi(index: index,isFromSuggestion:true,section:section)
    }
    
    
    
    func deleteMediaWith(index:Int, parentIndex:Int){
                
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
          
        
        if (Calendar.current.dateComponents([.hour], from: self.videoPostArray[index].createdAt, to: Date()).hour ?? 0 < 24) && (self.videoPostArray[index].boost != 2 && self.videoPostArray[index].boost != 1 && self.videoPostArray[index].boost != 3){
            
            alert.addAction(UIAlertAction(title: "Edit", style: .default , handler:{ (UIAlertAction)in
                
                if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "PostClipVC") as? PostClipVC{
                    destVC.isEditVideoPost = true
                    destVC.clipObj = self.videoPostArray[index]
                    destVC.delegate = self
                    destVC.selectedIndex = index
                    self.navigationController?.pushViewController(destVC, animated: true)
                }
                
            }))
        }
          
          alert.addAction(UIAlertAction(title: "Delete", style: .destructive , handler:{ (UIAlertAction)in
            
              AlertView.sharedManager.presentAlertWith(title: "Pickzon", msg: "Are you sure want to delete selected clip ?", buttonTitles: ["Yes","No"], onController: self) { title, btnIndex in
                  
                  if btnIndex == 0{
                     self.deleteClipVideoApi(index: index)
                  }
              }
              
          }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
        }))
        //uncomment for iPad Support
          //alert.popoverPresentationController?.sourceView = self.view

          self.present(alert, animated: true, completion: {
              print("completion block")
          })
        
        
        
    }
    
    func editMediaWith(index:Int, parentIndex:Int){
        
//        if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "PostClipVC") as? PostClipVC{
//            destVC.isEditVideoPost = true
//            destVC.clipObj = clipArray[index]
//            destVC.delegate = self
//            destVC.selectedIndex = index
//            self.navigationController?.pushViewController(destVC, animated: true)
//        }
    }
    
  
    func clickedMediaWith(index:Int, parentIndex:Int){
       
        if selectedTab == 0 {
            
            let vc = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
//            var arr = arrwallPost
//            if index > 0 {
//                arr.removeSubrange(ClosedRange(uncheckedBounds: (lower: 0, upper: index-1)))
//            }
//            vc.selRowIndex = 0
//            vc.arrwallPost = arr
//            vc.controllerType = .isFromPost
//            vc.delegate = self
//            vc.followMsIsdn = otherMsIsdn
//            vc.totalPageNo = totalPageNo
//            vc.pageNo = pageNo
            print("index: \(index)")
            vc.selRowIndex = index
            vc.arrwallPost = arrwallPost
            vc.controllerType = .isFromPost
            vc.delegate = self
            vc.followMsIsdn = otherMsIsdn
           // vc.totalPageNo = totalPageNo
            vc.pageNo = pageNo + 1
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if selectedTab == 1 {
            
            let vc =
            StoryBoard.feeds.instantiateViewController(withIdentifier: "FeedsVideoViewController") as! FeedsVideoViewController
            vc.objWallPost = videoPostArray[index]
            vc.firstVideoIndex = 0
            vc.delegate = self
            vc.isClipVideo = true
            self.navigationController?.pushViewController(vc, animated: true)
            
       
            
        }else  if selectedTab == 2 {
            
            let vc = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
//            var arr = tagArray
//            if index > 0 {
//                arr.removeSubrange(ClosedRange(uncheckedBounds: (lower: 0, upper: index-1)))
//            }
            vc.selRowIndex = index
            vc.arrwallPost = tagArray
            vc.controllerType = .isFromTaggedPost
            vc.delegate = self
            vc.followMsIsdn = otherMsIsdn
           // vc.totalPageNo = totalPageTag
            vc.pageNo = pageNoTag + 1
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else  if selectedTab == 3 {
            
            
            let vc = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
//            var arr = sharedArray
//            if index > 0 {
//                arr.removeSubrange(ClosedRange(uncheckedBounds: (lower: 0, upper: index-1)))
//            }
            vc.selRowIndex = index
            vc.arrwallPost = sharedArray
            vc.controllerType = .isFromSharedPost
            vc.delegate = self
            vc.followMsIsdn = otherMsIsdn
          //vc.totalPageNo = totalPageShared
            vc.pageNo = pageNoShared + 1
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    
    func selectedTabIndex(title:String,index:Int){
        
        if objUser.usertype == 1 && (objUser.isFollow == 0 || objUser.isFollow == 2 || objUser.isFollow == 3) && Themes.sharedInstance.Getuser_id() != otherMsIsdn{
            return
        }
        
        selectedTab = index
       // self.tableViewProfile.reloadWithoutAnimation()
        
        switch index {
            
        case 0:
            if arrwallPost.count == 0{
                self.isFirstTime = true
                getAllUserPostListApi()
            }else{

                self.updateUserInfo()
            }
            break
            
        case 1:
            if videoPostArray.count == 0{
                self.isFirstTime = true
                getAllVideoList()
            }else{
                self.updateUserInfo()
            }
          
            break
        case 2:
            if tagArray.count == 0{
                self.isFirstTime = true
                getUserTagPostApi()
            }else{
                self.updateUserInfo()
            }
            break
        case 3:
            if sharedArray.count == 0{
                self.isFirstTime = true
                getSharedPostListApi()
            }else{
                self.updateUserInfo()
            }
            break
     
        default:
            break
        }
        
        UIView.setAnimationsEnabled(false)
        self.tableViewProfile.reloadSections(IndexSet(integer: 1), with: .fade)
       UIView.setAnimationsEnabled(true)
        
        if objUser.isFollow == 0 || objUser.isFollow == 3{
            self.btnFollowSwipe.isHidden = false
        }else{
            self.btnFollowSwipe.isHidden = true

        }
        cnstrntHt_BackBtn.constant = 0
        
        if Themes.sharedInstance.Getuser_id() == objUser.id{
            self.btnFollowSwipe.isHidden = true
        }
    }
}



extension ProfileVC:CallBackProfileDelegate{
    
    
    func getUpdatedData(postbj:WallPostModel){
        
       print("getUpdatedData ====")
        var isFound = false
      
        if postbj.sharedWallData == nil{
            if postbj.userInfo?.id == otherMsIsdn{
                isFound = true
            }
        }
        if postbj.sharedWallData != nil{
            if postbj.sharedWallData.userInfo?.id == otherMsIsdn{
                isFound = true

            }
        }
        
        if isFound == true {
//            self.pageNo = 0
//            self.totalPageNo = 0
//            getUserDetails()
        }
        
        
        //if selectedTab == 0{
            var index = 0
           
            for obj in arrwallPost{
                if obj.id == postbj.id{
                    arrwallPost[index] = postbj
                    //self.tableViewProfile.reloadWithoutAnimation()
                    break
                }
                index = index + 1
            }
            
      /*  }
        else if mediaType == .goLive{
            var index = 0
           
            for obj in goLiveArray{
                if obj.id == postbj.id{
                    goLiveArray[index] = postbj
                    self.collectionVw.reloadWithoutAnimation()
                    break
                }
                index = index + 1
            }
           */
        //}else if selectedTab == 1{
             index = 0
            for obj in videoPostArray{
                if obj.id == postbj.id{
                    videoPostArray[index] = postbj
                }
                index = index + 1
            }
            self.tableViewProfile.reloadWithoutAnimation()
            
        //}else if selectedTab == 2{
             index = 0
           
            for obj in tagArray{
                if obj.id == postbj.id{
                    tagArray[index] = postbj
                    //self.tableViewProfile.reloadWithoutAnimation()
                    break
                }
                index = index + 1
            }
            
        //}else if selectedTab == 3{
             index = 0
           
            for obj in sharedArray{
                if obj.id == postbj.id{
                    sharedArray[index] = postbj
                    //self.tableViewProfile.reloadWithoutAnimation()
                    break
                }
                index = index + 1
            }
            
        //}
        
    }
    
   
    func updateSelectedArrayWithId(userId:String,isFollwing:Int){
        print("=====\(isFollwing)")
        
        
        if otherMsIsdn == userId{
            if isFollwing == 0{
                self.objUser.isFollow = isFollwing
               // self.objUser.followStatusButton = "Follow"
            }else  if isFollwing == 1{
                self.objUser.isFollow = isFollwing
              //  self.objUser.followStatusButton = "Followed"
            }
            self.tableViewProfile.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
       // if selectedTab == 0{
            var index = 0
            
            for obj in arrwallPost{
                
                var postObj = obj
                if postObj.sharedWallData == nil{
                    if postObj.userInfo?.id == userId{
                        postObj.isFollowed = isFollwing
                    }
                }
                if postObj.sharedWallData != nil{
                    if postObj.sharedWallData.userInfo?.id == userId{
                        postObj.sharedWallData.isFollowed = isFollwing
                        
                    }
                }
                
                arrwallPost[index] = postObj
                index = index + 1
            }
            
    /*
        }
        else if mediaType == .goLive{
            var index = 0
            
            for obj in goLiveArray{
                
                var postObj = obj
                if postObj.sharedWallData == nil{
                    if postObj.userInfo?.id == userId{
                        postObj.isFollowed = isFollwing
                    }
                }
                if postObj.sharedWallData != nil{
                    if postObj.sharedWallData.userInfo?.id == userId{
                        postObj.sharedWallData.isFollowed = isFollwing
                        
                    }
                }
                
                goLiveArray[index] = postObj
                index = index + 1
            }
            
          */
       // }else if selectedTab == 3{
        index = 0
            
            for obj in sharedArray{
                
                var postObj = obj
                if postObj.sharedWallData == nil{
                    if postObj.userInfo?.id == userId{
                        postObj.isFollowed = isFollwing
                    }
                }
                if postObj.sharedWallData != nil{
                    if postObj.sharedWallData.userInfo?.id == userId{
                        postObj.sharedWallData.isFollowed = isFollwing
                        
                    }
                }
                
                sharedArray[index] = postObj
                index = index + 1
            }
            
       // }else if selectedTab == 2 {
             index = 0
            
            for obj in tagArray{
                
                var postObj = obj
                if postObj.sharedWallData == nil{
                    if postObj.userInfo?.id == userId{
                        postObj.isFollowed = isFollwing
                    }
                }
                if postObj.sharedWallData != nil{
                    if postObj.sharedWallData.userInfo?.id == userId{
                        postObj.sharedWallData.isFollowed = isFollwing
                        
                    }
                }
                
                tagArray[index] = postObj
                index = index + 1
            }
            
        //}
    }
    
    
    func getNewPageList(listArray:Array<WallPostModel>,pageNo:Int,postType:PostType){
        
        if postType == .isFromPost{
            
            self.arrwallPost.append(contentsOf: listArray)
            self.tableViewProfile.reloadWithoutAnimation()
            self.pageNo = pageNo
           // self.totalPageNo = totalPage
       
        }else if postType == .isFromSharedPost{
            
            self.sharedArray.append(contentsOf: listArray)
            self.tableViewProfile.reloadWithoutAnimation()
            self.pageNoShared = pageNo
           // self.totalPageShared = totalPage
       
        }else if postType == .isFromTaggedPost{
            
            self.tagArray.append(contentsOf: listArray)
            self.tableViewProfile.reloadWithoutAnimation()
            self.pageNoTag = pageNo
           // self.totalPageTag = totalPage
        }
    }

}


extension ProfileVC:ExpandableLabelDelegate{
    
    func numberTextClicked(_ label: ExpandableLabel, number: String) {
        if let url = URL(string: "tel://\(number)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func hashTagTextClicked(_ label: ExpandableLabel, hashTag: String) {
        
        let destVc:WallPostViewVC = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
        destVc.controllerType = .hashTag
        destVc.hashTag = hashTag
        AppDelegate.sharedInstance.navigationController?.pushViewController(destVc, animated: true)
    }
    
    // MARK: ExpandableLabel Delegate
    func willExpandLabel(_ label: ExpandableLabel) {
 
        tableViewProfile.beginUpdates()
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
          
        let point = label.convert(CGPoint.zero, to: tableViewProfile)
        if let indexPath = tableViewProfile.indexPathForRow(at: point) as IndexPath? {
            
            DispatchQueue.main.async { [weak self] in
                self?.isExpanded = false
                
                self?.tableViewProfile.scrollToRow(at: indexPath, at: .top, animated: false)
            }
        }
        
        tableViewProfile.endUpdates()
    }
   
    
    func willCollapseLabel(_ label: ExpandableLabel) {
   
        tableViewProfile.beginUpdates()
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        let point = label.convert(CGPoint.zero, to: tableViewProfile)
        if let indexPath = tableViewProfile.indexPathForRow(at: point) as IndexPath? {
          
            DispatchQueue.main.async { [weak self] in
                    self?.isExpanded = true
                self?.tableViewProfile.scrollToRow(at: indexPath, at: .top, animated: false)
            }
        }
        tableViewProfile.endUpdates()
    }
    
    
    func mentionTextClicked(_ label: ExpandableLabel,mentionText:String){
        
        print("mentionTextClicked \(mentionText)")
        
        let mentionString:String = mentionText
        self.getUserIdFromPickzonId(pickzonId: mentionString.replacingOccurrences(of: "@", with: ""))
    }
    
        
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
                        self.navigationController!.pushView(viewController, animated: true)
                    }
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    func urlTextClicked(_ label: ExpandableLabel,strURL:String) {
        
            //if objUser.celebrity == 1 {
                let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "WebviewVC") as! WebviewVC
                vc.urlString = "\(strURL)"
                AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
           // }
        
    }
}

extension ProfileVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate,RSKImageCropViewControllerDelegate,RSKImageCropViewControllerDataSource{
   
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.delegate=self
            self.presentView(picker, animated: true)
        }
        else
        {
            openGallary()
        }
    }
    
    func openGallary()
    {
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.delegate=self
        
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.presentView(picker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image : UIImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
        let compressedimg = image.jpegData(compressionQuality: 0.3)
        
        let imageCropVC = RSKImageCropViewController(image: UIImage(data: compressedimg!)!)
        imageCropVC.delegate = self
        imageCropVC.cropMode = .circle
        self.pushView(imageCropVC, animated: true)
        picker.dismissView(animated: true, completion: nil)
    }
    
    func imageCropViewControllerCustomMaskRect(_ controller: RSKImageCropViewController) -> CGRect {
        //let maskSize = CGSizeMake(320, 320)
        let maskRect = CGRectMake(0 , self.view.frame.size.height / 2.0 - self.view.frame.size.width / 4.0,  self.view.frame.size.width,  self.view.frame.size.width/2.0)
        return maskRect
    }

    func imageCropViewControllerCustomMaskPath(_ controller: RSKImageCropViewController) -> UIBezierPath {
       return UIBezierPath(rect: controller.maskRect)
    }

    func imageCropViewControllerCustomMovementRect(_ controller: RSKImageCropViewController) -> CGRect {
        let rect = controller.maskRect
        return rect;
    }
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        self.pop(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
       // profileImg_Btn.setBackgroundImage(croppedImage, for: .normal)
       // self.profilePicView.imgVwProfile?.image = croppedImage
        self.pop(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat)
    {
        self.pop(animated: true)
        
        //if Settings.sharedInstance.confidenceThreshold < 0.80 {
            self.CheckNudityforImage(image: croppedImage)
        //}
       /* if isCoverImage{
            imgVwCover.image = croppedImage
            uploadImage(image: croppedImage)
        }else{
            profileImg_Btn.setImage(croppedImage, for: .normal)
            uploadImage(image: croppedImage)
        }
       */
        uploadImage(image: croppedImage)

    }
    
    func showAlertForNudity() {
        // Create the alert controller
        let alertController = UIAlertController(title: "", message: "Uploading or sharing any form of vulgar or offensive content on this platform is strictly prohibited.", preferredStyle: .alert)
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
        }
        // Add the actions
        alertController.addAction(okAction)
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
   
    func CheckNudityforImage(image:UIImage) {
        NSFWDetector.shared.check(image: image) { result in
            switch result {
            case .error:
                print("Detection failed")
            case let .success(nsfwConfidence: confidence):
                print(String(format: "%.1f %% porn", confidence * 100.0))
                if Double(confidence)  > Settings.sharedInstance.confidenceThreshold {
                    DispatchQueue.main.async {
                            self.showAlertForNudity()
                    }
                    
                }else {
                   
                    self.uploadImage(image: image)
                }
            }
        }
    }
    
    func uploadImage(image:UIImage){
          
          Themes.sharedInstance.activityView(View: self.view)
          
        URLhandler.sharedinstance.uploadImageWithParameters(profileImg:image, imageName:"images", url: Constant.sharedinstance.updateProfileImage, params: [:])
          { response in
              Themes.sharedInstance.RemoveactivityView(View: self.view)
              let message = response["message"] as? String ?? ""
               let status = response["status"] as? Int16 ?? 0
               
              
              if status == 1 {
                 // let payload = response["payload"] as? NSDictionary ?? [:]
                  self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)

                  self.getUserInfoDetails()
              /*
                  if  let profileImage = payload["profileImage"] as? String {
                   
                      self.imageUrl = profileImage
                      
                      var image_Url = Themes.sharedInstance.CheckNullvalue(Passed_value: profileImage)
                      if(image_Url.substring(to: 1) == ".")
                      {
                          image_Url.remove(at: image_Url.startIndex)
                          image_Url = ("\(ImgUrl)\(image_Url)")
                      }
                      //let imageUrl:String = ("\(ImgUrl)\(image_Url)")
                      let user_ID = Themes.sharedInstance.Getuser_id()
                      let CheckUser:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString:user_ID as String?)
                      if (!CheckUser){
                      }
                      else{
                          let UpdateDict:[String:Any]=["profilepic": image_Url]
                          DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail , FetchString: user_ID, attribute:"user_id" , UpdationElements: UpdateDict as NSDictionary?)
                      }
                                      
                  }
                  */
                  
              }
          }
      }
}


extension ProfileVC:FrameSelectionDelegate{
    func getUpdatedObject(avatar:String, svgaUrl:String){
        if avatar.count > 0 {
            objUser.avatar = avatar
        }
        objUser.avatarSVGA = svgaUrl
        self.getUserInfoDetails()
     //   self.tableViewProfile.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
       // self.tableViewProfile.reloadData()
    }
}



//  ShareFeedPostViewController.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 11/12/21.
//  Copyright © 2021 CASPERON. All rights reserved.

import UIKit
import MobileCoreServices
import AVKit
import Kingfisher
import PhotosUI
import MapKit
import Kingfisher
import IQKeyboardManager
import GrowingTextView


class ShareFeedPostViewController: UIViewController{
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var vwSharedView: UIView!
    @IBOutlet weak var vwSubView: UIView!
    //@IBOutlet weak var imgUser:UIImageView!
    //@IBOutlet weak var imgUserShare:UIImageView!
    @IBOutlet weak var imgUserPicView:ImageWithFrameImgView!
    @IBOutlet weak var imgUserPicShareView:ImageWithFrameImgView!
    @IBOutlet weak var viewPostType:UIView!
    @IBOutlet weak var btnPostType:UIButton!
    @IBOutlet weak var imgPostType:UIImageView!
    @IBOutlet weak var tfDescription:GrowingTextView!
    @IBOutlet weak var lblTaggedItems:UILabel!
    @IBOutlet weak var lblTaggedItemsShared:UILabel!
    
    var arrTagPeople = Array<Dictionary<String, Any>>()
    var feelingActivity = Dictionary<String, Any>()
    var arrTagPeopleShared = Array<Dictionary<String, Any>>()
    var feelingActivityShared = Dictionary<String, Any>()
    
    var isFeeling = false
    var isActivity = false
    var locationString:String = ""
    var locationStringShared:String = ""
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    var cvHeight:Double = 0.0

    @IBOutlet weak var tblOption:UITableView!
    //var arrOptions = ["Public", "Friend","Only Me"]
    //var arrImages = ["menu_user", "list","logout1"]
    
    var arrOptions = ["Public", "Friend"]
    var arrImages = ["menu_user", "list"]
    var arrs3imgVideoURL:[String] = []
    var arrUrlDimension:[[String:String]] = []
    var objPost:WallPostModel?
    
    var postType = 1 //1 for public, 2 for friend, 3 for private
    var commentType = 0  //0 for anyone, 1 for no one
    var pageId = ""
    var fileName = ""
    var urlSelectedItemsArray = Array<URL>()
    var s3VideoUrl = Array<String>()
    var isFromEdit = false
    
    @IBOutlet weak var btnPost:UIButton!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblUserDetailsShared:UILabel!
    
    @IBOutlet weak var btnTagPeople:UIButton!
    @IBOutlet weak var btnAddFeelingActivity:UIButton!
    @IBOutlet weak var cvFeedsPost:UICollectionView!
    @IBOutlet weak var pageControl :UIPageControl!
    @IBOutlet weak var cnstrntCVHeight: NSLayoutConstraint!
    
    
    
    // MARK: - ViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        self.setUserProfile()
        cvFeedsPost.layer.cornerRadius = 10.0
        cvFeedsPost.clipsToBounds = true
       
       
        
        self.cnstrntCVHeight.constant = CGFloat(self.objPost?.clnViewHeight ?? 0.0)
        
        
        
            cvFeedsPost.isHidden = false
            DispatchQueue.main.async {
                self.cvFeedsPost.reloadData()
            }
            
        
        
        
       
        self.tblOption.layer.cornerRadius = 10
        self.tblOption.layer.borderColor = UIColor.darkGray.cgColor
        self.tblOption.layer.borderWidth = 1.0
        let nibName = UINib(nibName: "optWithImageTableViewCell", bundle: nil)
        self.tblOption.register(nibName, forCellReuseIdentifier: "optWithImageTableViewCell")
        
        
        //imgUser.setProfilePic(Themes.sharedInstance.Getuser_id(), "single")
        
       
        if pageId.length > 0{
            viewPostType.isHidden = true
        }
        if isFromEdit == true{
            
           /* imgUserShare.layer.borderWidth = 1.0
            imgUserShare.layer.borderColor = UIColor.darkGray.cgColor
            imgUserShare.layer.cornerRadius = 5.0
            imgUserShare.layer.cornerRadius = imgUser.frame.height / 2.0
            */
           /* if objPost?.sharedWallData == nil {
                
                imgUserShare.kf.setImage(with: URL(string: objPost?.userInfo!.profile_pic ?? ""), placeholder: UIImage(named: "avatar"), options: nil, progressBlock: nil) { response in}

            }else{
                imgUserShare.kf.setImage(with: URL(string:objPost?.sharedWallData.userInfo!.profile_pic ?? ""), placeholder: UIImage(named: "avatar"), options: nil, progressBlock: nil) { response in}
            }*/
            
            if objPost?.postType.lowercased() == "public"{
                postType = 1
            }else{
                postType = 2
            }
            
            /*else if objPost?.postType.lowercased() == "friend"{
                postType = 2
            }else{
                postType = 3
            }*/
            self.btnPostType.setTitle(arrOptions[postType-1], for: .normal)

            self.lblTaggedItems.text = ""
            self.lblTaggedItemsShared.text = ""
            self.lblTitle.text = "Share Post"
            self.btnPost.setTitle("Share", for: .normal)
            self.btnPost.isHidden = false
            self.tfDescription.text = ""
            self.locationString = ""
            self.latitude = 0.0
            self.longitude = 0.0
            if objPost!.sharedWallData == nil {
            self.locationStringShared = objPost?.place ?? ""
            }else {
            self.locationStringShared = objPost?.sharedWallData.place ?? ""
            }
           
            self.lblTaggedItemsShared.attributedText =  NSAttributedString(string: (objPost?.taggedPeople ?? ""), attributes: [ NSAttributedString.Key.foregroundColor:Themes.sharedInstance.tagAndLinkColor()])
            if objPost!.sharedWallData == nil {
            for str in (objPost?.taggedPeople ?? "").components(separatedBy: " ") {
                if str.count > 0 {
                let dict = ["pickzonId" :str.replacingOccurrences(of: "@", with: "").trim()]
                self.arrTagPeopleShared.append(dict)
                    
                }
                                
            }
            }else {
                for str in (objPost?.sharedWallData.taggedPeople ?? "").components(separatedBy: " ") {
                    if str.count > 0 {
                    let dict = ["pickzonId" :str.replacingOccurrences(of: "@", with: "").trim()]
                        self.arrTagPeopleShared.append(dict) }
                }
            }
            
            if objPost!.sharedWallData == nil {
                if (objPost?.feeling ?? [:]).count > 0 {
                    
                    self.feelingActivityShared = (objPost?.feeling as! [String : Any])
                    
                }else if (objPost?.activities ?? [:]).count > 0 {
                    
                    self.feelingActivityShared = (objPost?.activities as! [String : Any])
                }
            }else {
                if (objPost?.sharedWallData.feeling ?? [:]).count > 0 {
                    
                    self.feelingActivityShared = (objPost?.sharedWallData.feeling as! [String : Any])
                    
                }else if (objPost?.activities ?? [:]).count > 0 {
                    
                    self.feelingActivityShared = (objPost?.sharedWallData.activities as! [String : Any])
                }
            }
            
            self.updateUserDetailLabelShared()
            self.updatetaggedLabelShared()
        }else{
            /*if objPost?.sharedWallData == nil {
                
                imgUserShare.kf.setImage(with: URL(string: objPost?.userInfo!.profile_pic ?? ""), placeholder: UIImage(named: "avatar"), options: nil, progressBlock: nil) { response in}

            }else{
                imgUserShare.kf.setImage(with: URL(string:objPost?.sharedWallData.userInfo!.profile_pic ?? ""), placeholder: UIImage(named: "avatar"), options: nil, progressBlock: nil) { response in}
            }*/
        }
        
        self.updateColorBack()
        
        //userActivity: 1, // 0=user can't upload anything, 1= upload post, story, page-post, 2= upload post/story only, 3= upload page-post only
        if Settings.sharedInstance.userActivity == 0 {
            self.showPostNotAllowedAlert()
            return
        }
        
        //check if user account is private 1 or public 0
        if Settings.sharedInstance.usertype == 1  && pageId.length == 0{
            self.btnPostType.setTitle(arrOptions[1], for: .normal)
            imgPostType.image = UIImage(named: "friend")
            postType = 2
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        self.pauseAllVisiblePlayers()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("UIViewController: PostVideoVc")
        self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: vwSharedView.frame.origin.y + cvFeedsPost.frame.origin.y + cvFeedsPost.frame.height + 200)
    }
    
    func setUserProfile(){
        imgUserPicView.initializeView()
        imgUserPicShareView.initializeView()
        guard let realm = DBManager.openRealm() else {
            return
        }
        if let existingUser =  realm.object(ofType: DBUser.self, forPrimaryKey: Themes.sharedInstance.Getuser_id()) {
            
            if  existingUser.profilePic.length == 0{
                let  profilePic = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "profilepic")
                imgUserPicView.setImgView(profilePic: profilePic, frameImg: existingUser.avatar)
                
            }else{
                imgUserPicView.setImgView(profilePic: existingUser.profilePic, frameImg: existingUser.avatar)
                
            }
        }else{
            let  profilePic = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "profilepic")
            imgUserPicView.setImgView(profilePic: profilePic, frameImg: "")
        }
        
        
        //Shared User profile pic
        if objPost?.sharedWallData == nil {
            imgUserPicShareView.setImgView(profilePic: objPost?.userInfo!.profilePic ?? "", frameImg: objPost?.userInfo!.avatar ?? "")
        }else {
            imgUserPicShareView.setImgView(profilePic: objPost?.sharedWallData.userInfo!.profilePic ?? "", frameImg: objPost?.sharedWallData.userInfo!.avatar ?? "")
        }
        
        
    }
    
    
    func showPostNotAllowedAlert(){
        // Create the alert controller
            let alertController = UIAlertController(title: "PickZon", message: Settings.sharedInstance.userActivityMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                UIAlertAction in
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: Initial Setup Methods
    func initialSetup(){
        lblTaggedItemsShared.numberOfLines = 5
        viewPostType.layer.cornerRadius = viewPostType.frame.height / 2.0
        viewPostType.layer.borderWidth = 1.0
        viewPostType.layer.borderColor = UIColor.darkGray.cgColor
        
        tfDescription.layer.borderWidth = 0.2
        tfDescription.layer.borderColor = UIColor.lightGray.cgColor
        tfDescription.layer.cornerRadius = 2.0
        tfDescription.placeholder = "What do you want to talk about?"
        tfDescription.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        lblTaggedItems.textColor = UIColor(red: 30.0/255.0, green: 110.0/255.0, blue: 222.0/255.0, alpha: 1.0)
        cvFeedsPost.register(UINib(nibName: "FeedsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeedsCollectionViewCell")
        cvFeedsPost.delegate = self
        cvFeedsPost.dataSource = self
        cvFeedsPost.layoutSubviews()
        pageControl.isHidden = false
        pageControl.hidesForSinglePage = true
        cvHeight = self.view.frame.size.width
    }
    func updateColorBack(){
         
        let colorLeft = UIColor(red: 13.0/255.0, green: 107.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        
        let colorRight = UIColor(red: 21.0/255.0, green: 178.0/255.0, blue: 254.0/255.0, alpha: 1.0).cgColor
        let gradientLayerColor4 = CAGradientLayer()
        gradientLayerColor4.colors = [colorLeft, colorRight]
        gradientLayerColor4.locations = [0.0, 1.0]
        gradientLayerColor4.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayerColor4.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayerColor4.frame = self.btnPost.bounds
        
        self.btnPost.layer.cornerRadius = 5.0
        btnPost.clipsToBounds = true
        btnPost.layer.insertSublayer(gradientLayerColor4, at:0)
        btnPost.setTitleColor(UIColor.white, for: .normal)
        
    }
    
  
    //MARK: - Button Action Methods

    @IBAction func imageTapped(tapGestureRecognizer:UITapGestureRecognizer)
    {
        /*let viewController:FeedImagesVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "FeedImagesVC") as! FeedImagesVC
        viewController.urlSelectedItemsArray = urlSelectedItemsArray
        viewController.imgRemoveDelegate = self
        viewController.selIndex = tapGestureRecognizer.view?.tag ?? 0
        viewController.isSharingPost = true
        AppDelegate.sharedInstance.navigationController?.pushViewController(viewController, animated: true)
         */
    }
    
    func pauseAllVisiblePlayers() {
         let visibleIndexPaths = self.cvFeedsPost.indexPathsForVisibleItems
            for indexPath in visibleIndexPaths {
                if let cell = cvFeedsPost.cellForItem(at:indexPath) as? FeedsCollectionViewCell {
                    cell.pauseVideo()
                }
            }
    }
    
     
    @IBAction func backButtonAction()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func feedCommentOptionsAction() {
        let viewController:FeedCommentOptionsVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "FeedCommentOptionsVC") as! FeedCommentOptionsVC
        viewController.commentDelegate = self
        viewController.isToggleOn = commentType
        viewController.isToHideStory = true
        viewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.navigationController?.presentView(viewController, animated: true)
    }
    
    @IBAction func tagPeopleAction()
    {
        if postType == 3 {
            var dialogMessage = UIAlertController(title: "PickZon", message: "You cannot tag your friends in Private post.", preferredStyle: .alert)
            // Create OK button with action handler
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                print("Ok button tapped")
             })
            //Add OK button to a dialog message
            dialogMessage.addAction(ok)
            self.present(dialogMessage, animated: true, completion: nil)
        }else {
            let viewController:TagPeopleViewController = StoryBoard.main.instantiateViewController(withIdentifier: "TagPeopleViewController") as! TagPeopleViewController
            viewController.tagPeopleDelegate = self
            viewController.arrSelectedUser = arrTagPeople
            self.navigationController?.pushView(viewController, animated: true)
        }
    }
  
    @IBAction func addFeelingActivityAction()
    {
        let viewController:FeelingActivityTabViewController = StoryBoard.main.instantiateViewController(withIdentifier: "FeelingActivityTabViewController") as! FeelingActivityTabViewController
        viewController.feelingActivityDelegate = self
        self.navigationController?.pushView(viewController, animated: true)
    }
    
    @IBAction func showPostTypeAction(sender: UIButton){
     
            
            if tblOption.isHidden == true {
                tblOption.isHidden = false
            }else {
                tblOption.isHidden = true
            }
            
            if postType == 1 {
                imgPostType.image = PZImages.publicPost
            }else  if postType == 2 {
                imgPostType.image = PZImages.friendPost
                
            }else if postType == 3 {
                imgPostType.image = PZImages.privatePost
            }
    }
    
    
    @IBAction func shareWallPost()  {
        
  
            shareWallPost(asUser:true)
        }
    
    
   

//MARK: Other Helpfule Methods
    
    func updatetaggedLabel() {
        var str:String = ""
        let attributedString = NSMutableAttributedString()
        
        for objDict in self.arrTagPeople {
            if str.length == 0 {
                str = "@ " + (objDict["pickzonId"] as? String ?? "")
            }else {
                str = str + " @ " + (objDict["pickzonId"] as? String ?? "")
            }
        }
        
        if str.length > 0{
            str = str + "\n"
        }
        var myAttribute = [ NSAttributedString.Key.foregroundColor: Themes.sharedInstance.tagAndLinkColor()]
        var myAttrString = NSAttributedString(string: str, attributes: myAttribute)
        attributedString.append(myAttrString)
        
        str = ""
        if self.locationString.length > 0 {
            str = str + " " + self.locationString
        }
        if str.length > 0 {
            str = str + "\n"
        }
        myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.black ]
        myAttrString = NSAttributedString(string: str, attributes: myAttribute)
        attributedString.append(myAttrString)
        
        str = ""
        if self.feelingActivity.count > 0 {
            str = str + " " + (self.feelingActivity["image"] as? String ?? "")
            str = str + " " + (self.feelingActivity["name"] as? String ?? "")
        }
        myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.black ]
        myAttrString = NSAttributedString(string: str, attributes: myAttribute)
        attributedString.append(myAttrString)
        self.lblTaggedItems.numberOfLines = 0
        self.lblTaggedItems.attributedText = attributedString
        DispatchQueue.main.async {
            self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: self.vwSharedView.frame.origin.y + self.cvFeedsPost.frame.origin.y + self.cvFeedsPost.frame.height + 200)
        }
        
    }
    
    
    func updatetaggedLabelShared() {
        var str:String = ""
        
        let attributedString = NSMutableAttributedString()
        if objPost!.sharedWallData == nil {
        str = objPost?.payload ?? ""
        }else {
            str = objPost?.sharedWallData.payload ?? ""
        }
        if str.length > 0 {
            str = str + "\n"
        }
       var myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.label ]
        var myAttrString = NSAttributedString(string: str, attributes: myAttribute)
//        attributedString.append(myAttrString)
        
        attributedString.append(str.convertAttributtedColorText())
        str = ""
        
        for objDict in self.arrTagPeopleShared {
            print(objDict)

            if str.length == 0 {
                str = "@" + (objDict["pickzonId"] as? String ?? "")
            }else {
                str = str + " @" + (objDict["pickzonId"] as? String ?? "")
            }
        }
        if str.length > 0 {
            str = str + " " + "\n"
//            myAttribute = [ NSAttributedString.Key.foregroundColor: Themes.sharedInstance.tagAndLinkColor() ]
//            myAttrString = NSAttributedString(string: str, attributes: myAttribute)
//            attributedString.append(myAttrString)
            attributedString.append(str.convertAttributtedColorText())

        }
        
        str = ""
        if self.locationStringShared.length > 0 {
            str = str + " " + self.locationStringShared
        }
        
        if str.length > 0 {
            str = str + "\n"
//            myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.label ]
//            myAttrString = NSAttributedString(string: str, attributes: myAttribute)
//            attributedString.append(myAttrString)
            
            attributedString.append(str.convertAttributtedColorText())

        }
        
        str = ""
        if self.feelingActivityShared.count > 0 {
            print(self.feelingActivityShared)
            str = str + " " + (self.feelingActivityShared["image"] as? String ?? "")
            str = str + " " + (self.feelingActivityShared["name"] as? String ?? "")
        }
        if str.length > 0 {
//            myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.label ]
//            myAttrString = NSAttributedString(string: str, attributes: myAttribute)
//            attributedString.append(myAttrString)
            
            attributedString.append(str.convertAttributtedColorText())

        }
        self.lblTaggedItemsShared.attributedText = attributedString.string.convertAttributtedColorText()
        self.lblTaggedItemsShared.updateConstraints()
        self.view.updateConstraints()
        
        DispatchQueue.main.async {
            self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: self.vwSharedView.frame.origin.y + self.cvFeedsPost.frame.origin.y + self.cvFeedsPost.frame.height + 200)
        }
        
    }
    
    func updateUserDetailLabelShared() {
        var str:String = ""
        
        let attributedString = NSMutableAttributedString()
        
      
            if objPost!.sharedWallData == nil {
                str = objPost?.userInfo?.pickzonId ?? ""
            }else {
                str = objPost?.sharedWallData.userInfo?.pickzonId ?? ""
            }
        
        
        if str.length > 0 {
            str = str + "\n"
        }
        var myAttribute = [NSAttributedString.Key.foregroundColor: UIColor.label, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0) ]
        var myAttrString = NSAttributedString(string: str, attributes: myAttribute)
        attributedString.append(myAttrString)
        str = ""
        
        if objPost!.sharedWallData == nil {
        str = objPost?.place ?? ""
        }else {
            str = objPost?.sharedWallData.place ?? ""
        }
        if str.length > 0 {
            str = str + "\n"
            myAttribute = [NSAttributedString.Key.foregroundColor: UIColor.label, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10.0)]
            myAttrString = NSAttributedString(string: str, attributes: myAttribute)
            attributedString.append(myAttrString)
        }
        
        str = ""
        if objPost!.sharedWallData == nil {
            if objPost?.feedTime.length ?? 0 > 0 {
                str = str + " " + (self.objPost?.feedTime ?? "")
            }
        }else {
            if objPost?.sharedWallData.feedTime.length ?? 0 > 0 {
                str = str + " " + (objPost?.sharedWallData.feedTime ?? "")
            }
        }
        
        if str.length > 0 {
            str = str + "\n"
             myAttribute = [NSAttributedString.Key.foregroundColor: UIColor.label, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10.0) ]
            myAttrString = NSAttributedString(string: str, attributes: myAttribute)
            attributedString.append(myAttrString)
        }
        
        self.lblUserDetailsShared.attributedText = attributedString.string.convertAttributtedColorText()
    }
    
   //MARK: Api Methods
    
    func shareWallPost(asUser:Bool){
        
        Themes.sharedInstance.activityView(View: self.view)
        
        let params = NSMutableDictionary()
    
        if objPost?.sharedWallData == nil {
            params.setValue(  objPost?.id ?? "", forKey: "feedId")
        }else{
            params.setValue(objPost?.sharedWallData.id ?? "", forKey: "feedId")
        }
        params.setValue("\(self.tfDescription.text ?? "")", forKey: "payload")
        params.setValue("\(postType)", forKey: "postType")
        params.setValue(commentType, forKey: "commentType")

        if arrTagPeople.count > 0 {
            var tagArr:[String] = []
            for obj in arrTagPeople {
                tagArr.append(obj["pickzonId"] as? String ?? "")
            }
            print("\(tagArr)")
            params.setValue(tagArr, forKey: "tag")
        }else {
            params.setValue([], forKey: "tag")
        }
        
        if isFeeling == true {
            if feelingActivity.count > 0 {
                params.setValue("\(feelingActivity["_id"] ?? "")", forKey: "feeling")
            }else {
                params.setValue("", forKey: "feeling")
            }
        }else if isActivity == true{
            if feelingActivity.count > 0 {
                params.setValue("\(feelingActivity["_id"] ?? "")", forKey: "activities")
            }else {
                params.setValue("", forKey: "activities")
            }
        }
        
        
  
        
        URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.sharePost , param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                if status == 1{
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: noti_RefreshFeed), object:nil)
                    
                    AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["Ok"], onController: self, dismissBlock:{(title,index) in
                        self.navigationController?.popViewController(animated: true)
                        
                    })
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
}


extension ShareFeedPostViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Tableview data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView == tblOption {
            return arrOptions.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "optWithImageTableViewCell") as! optWithImageTableViewCell
        cell.selectionStyle = .none
        cell.imgOption.image = UIImage(named:arrImages[indexPath.row])
        cell.imgOption.image = nil
        cell.lblText.text = arrOptions[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //check if user account is private 1 or public 0
        if Settings.sharedInstance.usertype == 1  && indexPath.row == 0{
            self.tblOption.isHidden = true
            let alert = UIAlertController(title: "", message: "Your account is private. Please update your account privacy to public to post your feed as public", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
            
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                    
                    let editProfileVC:ProfileEditVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "ProfileEditVC") as! ProfileEditVC
                    editProfileVC.isCreatingNewPost = true
                    self.pushView(editProfileVC, animated: true)
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
        }else {
            self.btnPostType.setTitle(arrOptions[indexPath.row], for: .normal)
            self.postType = indexPath.row + 1
            self.showPostTypeAction(sender: btnPostType)
            if self.postType == 3 {
                self.arrTagPeople.removeAll()
                self.updatetaggedLabel()
            }
        }
    }
    
    //MARK: - UICollectionview delegate and datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.pageControl.numberOfPages = urlSelectedItemsArray.count
        return urlSelectedItemsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedsCollectionViewCell", for: indexPath) as! FeedsCollectionViewCell
        
        let objUrlString = urlSelectedItemsArray[indexPath.row].absoluteString as NSString
        cell.url = urlSelectedItemsArray[indexPath.row].absoluteString
        cell.urlArray = urlSelectedItemsArray.map({ url in
            return url.absoluteString
        })
        
        cell.pauseVideo()
        cell.imgImageView.contentMode = .scaleAspectFit
        if checkMediaTypes(strUrl:  urlSelectedItemsArray[indexPath.row].absoluteString) == 1 {
          
            if isFromEdit == true && objUrlString.contains("https") {
                cell.imgImageView.kf.setImage(with:  urlSelectedItemsArray[indexPath.row],placeholder: UIImage(named:"dummy"))
                
            }else{
                cell.imgImageView.image = UIImage(contentsOfFile: urlSelectedItemsArray[indexPath.row].path)
            }
            cell.configureCell(isToHidePlayer: true, indexPath: indexPath)
            cell.imgImageView.isHidden = false
            
        }else {
            cell.configureCell(isToHidePlayer: false, indexPath: indexPath)
            cell.imgImageView.isHidden = true
        }
       
        cell.btnPreview.isHidden = false
        //cell.controlView.constBottom.constant = 50
        cell.btnPreview.isHidden = true
        cell.btnPreview.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        cell.btnPreview.setImage(UIImage(named: "delete_white"), for: .normal)
        cell.btnPreview.tag = indexPath.item
        cell.btnPreview.backgroundColor = UIColor.systemRed
        cell.layoutIfNeeded()
        return cell
    }
        
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        let indexPath = IndexPath(row: Int(pageNumber), section: 0)
        let cell = cvFeedsPost.cellForItem(at:indexPath)  as? FeedsCollectionViewCell
        cell?.pauseVideo()
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        let indexPath = IndexPath(row: Int(pageNumber), section: 0)
        let cell = cvFeedsPost.cellForItem(at:indexPath) as? FeedsCollectionViewCell
        //cell?.mmPlayerLayer.currentPlayStatus = .pause
        //cell?.mmPlayerLayer.player?.pause()
        cell?.pauseVideo()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.item
       // let cell = cvFeedsPost.cellForItem(at:indexPath) as? FeedsCollectionViewCell
        //cell?.setPreviewBtnFrame(top: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width , height: self.cvFeedsPost.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /*let objUrlString = urlSelectedItemsArray[indexPath.row].absoluteString as NSString
        if objUrlString.pathExtension.lowercased() == "jpeg" || objUrlString.pathExtension.lowercased() == "jpg" || objUrlString.pathExtension.lowercased() == "png"  {
            var newArray = Array<String>()
            newArray.append(objUrlString as String)
            var selIndex = newArray.index(of: objUrlString as String) ?? 0
         let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "ZoomImageViewController") as! ZoomImageViewController
            vc.currentTag = selIndex
            vc.imageArrayUrl = newArray
            self.navigationController?.pushViewController(vc, animated: false)
        }else {
            
            /*let videoURL = URL(string: objUrlString as String)
            let player = AVPlayer(url: videoURL! )
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.presentView(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
             */
        }*/
    }
}


extension ShareFeedPostViewController:ImageRemovedDelegate,FeedCommentOptionDelegate, TagPeopleDelegate, FeelingActivityDelegate  {
    
     func whoCanCommentSelected(option:Int,isStory:Int) {
         print("Option selected : \(option)")
         commentType = option
     }
    
    func tagPeopleDoneAction(arrTagPeople : Array<Dictionary<String, Any>>) {
        print(arrTagPeople)
        self.arrTagPeople = arrTagPeople
        self.updatetaggedLabel()
    }
    
    func feeLingActivitySelected(feelingActivity: Dictionary<String, Any>,  isFeeling:Bool) {
        print(feelingActivity)
        self.feelingActivity = feelingActivity
        if isFeeling == true {
            self.isFeeling = true
            self.isActivity = false
        }else {
            self.isFeeling = false
            self.isActivity = true
        }
        self.updatetaggedLabel()
    }
 
    func imageRemoved(index: Int) {
        print("index: \(index)")
        
        if arrs3imgVideoURL.count > index {
            arrs3imgVideoURL.remove(at: index)
        }
        if arrUrlDimension.count > index {
            arrUrlDimension.remove(at: index)
        }
        
       
        
        if urlSelectedItemsArray.count > index {
            urlSelectedItemsArray.remove(at: index)
        }
        
        if s3VideoUrl.count > index {
            s3VideoUrl.remove(at: index)
        }
        self.updatetaggedLabel()
        
    }
}


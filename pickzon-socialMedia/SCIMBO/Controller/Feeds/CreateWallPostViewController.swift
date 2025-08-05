//
//  CreateWallPostViewController.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 6/12/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVKit
import PhotosUI
import MapKit
import Kingfisher
import IQKeyboardManager
import GrowingTextView
import Alamofire
import NSFWDetector
import QuartzCore


protocol ImageRemovedDelegate : AnyObject{
    func imageRemoved(index: Int)
}

protocol UploadFilesDelegate: AnyObject{
   
    func uploadSelectedFilesDuringPost(thumbUrlArray:Array<Any>,mediaArray : [URL],mediaName:String, url:String, params:NSMutableDictionary,method:HTTPMethod?)
}


class CreateWallPostViewController: UIViewController,GrowingTextViewDelegate {
    
    weak var uploadDelegate:UploadFilesDelegate? 
    var fromType:CreatePostType?
    var isSharingData:Bool = false
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var vwSubView: UIView!
    @IBOutlet weak var profilePicView:ImageWithFrameImgView!
    @IBOutlet weak var viewPostType:UIView!
    @IBOutlet weak var btnPostType:UIButton!
    @IBOutlet weak var imgPostType:UIImageView!
    @IBOutlet weak var tfDescription:GrowingTextView!
    @IBOutlet weak var lblTaggedItems:UILabel!
    @IBOutlet weak var btnAddLocation:UIButton!
    @IBOutlet weak var viewBottom:UIView!
    @IBOutlet weak var lblAddLocation:UILabel!
    var arrTagPeople = Array<Dictionary<String, Any>>()
    var arrTagPeopleDesc = Array<Dictionary<String, Any>>()
    var feelingActivity = Dictionary<String, Any>()
    var isFeeling = false
    var isActivity = false
    var locationString:String = ""
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    @IBOutlet weak var tblOption:UITableView!
    //var arrOptions = ["Public", "Friends","Only Me"]
    //var arrImages = ["menu_user", "list","logout1"]
    var arrOptions = ["Public", "Friends"]
    var arrImages = ["menu_user", "list"]
    var arrs3imgVideoURL:Array<String> = []
    var arrUrlDimension:[[String:String]] = []
    var thumbimgVideoURL:Array<String> = []
    var isFromProfile = false
    var objPost:WallPostModel?
    var isDisplayPhotos = false
    var isDisplayVideos = false
    var postType:Int = 1 //1 for public, 2 for friend, 3 for private
    var commentType = 0  //0 for anyone, 1 for no one
    var fileName = ""
    // isStory = 1 to post same feed on story, isStory = 0 normal feed.
    var isStory = 0
    var urlSelectedItemsArray = Array<URL>()
    var arrSoundInfo = Array<SoundInfo>()
    var selctedSoundInfo :SoundInfo!
    
    var urlThumnailSelectedItemsArray = Array<Any>()
    var s3VideoUrl = Array<String>()
    var locationManager = CLLocationManager()
    var isFromEdit = false
    var isDraftUsed = false
    @IBOutlet weak var btnPost:UIButton!
    @IBOutlet weak var btnSaveDraft:UIButton!
    @IBOutlet weak var lblTitle:UILabel!
    var cvHeight = 0.0
    var arrHeight = Array<CGFloat>()
    var selectedItems = [YPMediaItem]()
    @IBOutlet weak var tblTags:UITableView!
    var arrTags = [String]()
    var arrTagPeopleSearched:Array<Dictionary<String, Any>> = Array()
    var replaceText = ""
    var recordingHashTag = false
    var recordingUserTag = false
    var startParse = 0
    @IBOutlet weak var btnAddPhotoVideo:UIButton!
    @IBOutlet weak var btnTagPeople:UIButton!
    @IBOutlet weak var btnAddFeelingActivity:UIButton!
    var nudityContentsFound = false
    @IBOutlet weak var cvFeedsPost:UICollectionView!
    @IBOutlet weak var pageControl :UIPageControl!
    @IBOutlet weak var cnstrntCVHeight: NSLayoutConstraint!
    
    
   
    var selectedMediaIndex: Int = 0
    var musicId:String = ""
    var musicUrl:String = ""
    var audioWithImageArr = [Bool]()
    
    
    // MARK: - ViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        profilePicView.initializeView()
        initialSetupMethods()
        //imgUser.setProfilePic(Themes.sharedInstance.Getuser_id(), "single")
        
        self.setUserProfile()
        cvFeedsPost.layer.cornerRadius = 10.0
        cvFeedsPost.clipsToBounds = true
        
        tfDescription.layer.borderColor = UIColor.lightGray.cgColor
        tfDescription.layer.cornerRadius = 5.0
        tfDescription.layer.borderWidth = 0.5
       
        
        self.btnSaveDraft.isHidden = false
        if isFromEdit == true {
            self.btnSaveDraft.isHidden = true
            self.commentType = objPost?.commentType ?? 0
            self.thumbimgVideoURL = (objPost?.sharedWallData == nil) ? objPost?.thumbUrlArray ?? Array<String>() : objPost?.sharedWallData.thumbUrlArray ?? Array<String>()
            
            self.urlThumnailSelectedItemsArray.append(contentsOf: thumbimgVideoURL)
            self.audioWithImageArr =  Array(repeating: false, count: self.thumbimgVideoURL.count)
            
            if objPost?.soundInfo?.audio.length ?? 0 > 0 {
                let objSound = objPost?.soundInfo ?? SoundInfo()
                self.arrSoundInfo.append(objSound)
            }else {
                self.arrSoundInfo = Array(repeating: SoundInfo(), count: self.thumbimgVideoURL.count)
            }
            
            if objPost?.postType.lowercased() == "public"{
                postType = 1
                imgPostType.image = PZImages.publicPost
            }else {
                postType = 2
                imgPostType.image = PZImages.friendPost
            }
            
            
            self.btnPostType.setTitle(arrOptions[postType-1], for: .normal)
            
            self.lblTaggedItems.text = ""
            self.lblTitle.text = "Update Post"
            self.btnPost.setTitle("Save", for: .normal)
            self.btnPost.isHidden = false
            self.tfDescription.text = objPost?.payload ?? ""
            self.locationString = objPost?.place ?? ""
            self.latitude = objPost?.latitude ?? 0.0
            self.longitude = objPost?.longitude ?? 0.0
            self.lblTaggedItems.attributedText =  NSAttributedString(string: (objPost?.taggedPeople ?? ""), attributes: [ NSAttributedString.Key.foregroundColor: Themes.sharedInstance.tagAndLinkColor()])
            
            for str in (objPost?.taggedPeople ?? "").components(separatedBy: " ") {
                if str.count > 0 {
                    let dict = ["pickzonId" :str.replacingOccurrences(of: "@", with: "").trim()]
                    self.arrTagPeople.append(dict) }
                
            }
            
            if objPost?.sharedWallData == nil {
                
                for dict in objPost?.urlDimensionArray ?? []{
                    let height = dict["height"] as? Int ?? 0
                    let width = dict["width"] as? Int ?? 0
                    self.arrUrlDimension.append(["height":"\(height)", "width":"\(width)"])
                }
                self.arrHeight = objPost?.urlDimensionArray.map({ dict in
                    
                    let width = dict["width"] as? CGFloat ?? 0.0
                    var height = dict["height"] as? CGFloat ?? 0.0
                    if height > width {
                        let ratio = CGFloat(height) / CGFloat(width)
                        height = self.view.frame.width * ratio
                    }else {
                        height = self.view.frame.width
                    }
                    return (height)
                }) ?? []
            }else {
                self.arrHeight = objPost?.sharedWallData.urlDimensionArray.map({ dict in
                    let width = dict["width"] as? CGFloat ?? 0.0
                    var height = dict["height"] as? CGFloat ?? 0.0
                    if height > width {
                        let ratio = CGFloat(height) / CGFloat(width)
                        height = self.view.frame.width * ratio
                    }else {
                        height = self.view.frame.width
                    }
                    return (height)
                    
                }) ?? []
            }
            
            var  txtFeeling = ""
            
            if (objPost?.feeling ?? [:]).count > 0 {
                self.isFeeling = true
                self.isActivity = false
                self.feelingActivity = (objPost?.feeling as! [String : Any])
                txtFeeling = (objPost?.feeling["image"] as? String ?? "") + " " +  (objPost?.feeling["name"]  as? String ?? "")
            }else if (objPost?.activities ?? [:]).count > 0 {
                txtFeeling = (objPost?.activities["image"] as? String ?? "") + " " +  (objPost?.activities["name"] as? String ?? "")
                self.isFeeling = false
                self.isActivity = true
                self.feelingActivity = (objPost?.activities as! [String : Any])
            }
            
            self.updatetaggedLabel()
            
        }else if isSharingData == true {
            let arrData = Themes.sharedInstance.getSharedFilesURLArray()
            self.tfDescription.text = Themes.sharedInstance.getSharedText()
            self.fetchSharedDataFromGallery(arrData: arrData)
            self.updatetaggedLabel()
            
        }else if isDisplayVideos == true {
            self.showPicker()
            
        }else{
            //Check for saved draft
            var data =  Data()
            
            data = UserDefaults.standard.object(forKey: "WallPostDraft") as? Data ?? Data()
            
            if data.count > 0 {
                let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any] ?? [:]
                let type = dict["fromType"] as? Int ?? 1
                var fromTypeDraft:CreatePostType?
                if type == 1 {
                    fromTypeDraft = .feedPost
                }
                
                if self.fromType == fromTypeDraft {
                    
                    AlertView.sharedManager.presentAlertWith(title: "", msg: "Continue with draft?", buttonTitles: ["No","Yes"], onController: self) { title, index in
                        
                        if index == 0{
                            self.isDraftUsed = false
                        }else if index == 1{
                            self.isDraftUsed = true
                            self.fetchDraft()
                            self.updatetaggedLabel()
                        }
                    }
                }
            }else {
                //check if user account is private 1 or public 0
                if Settings.sharedInstance.usertype == 1 {
                    self.btnPostType.setTitle(arrOptions[1], for: .normal)
                    imgPostType.image = UIImage(named: "friend")
                    postType = 2
                }
            }
        }
        self.updateColorBack()
        
        //userActivity: 1, // 0=user can't upload anything, 1= upload post, story, page-post, 2= upload post/story only, 3= upload page-post only
        if Settings.sharedInstance.userActivity == 0 {
            self.showPostNotAllowedAlert()
        }else if fromType == .feedPost && Settings.sharedInstance.userActivity == 3 {
            self.showPostNotAllowedAlert()
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = false
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
       // scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 1000 )
        self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: cvFeedsPost.frame.origin.y + cvFeedsPost.frame.height + 200)
    }
    
    func setUserProfile(){
        
        guard let realm = DBManager.openRealm() else {
            return
        }
        if let existingUser =  realm.object(ofType: DBUser.self, forPrimaryKey: Themes.sharedInstance.Getuser_id()) {
            
            if  existingUser.profilePic.length == 0{
                let  profilePic = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "profilepic")
                profilePicView.setImgView(profilePic: profilePic, frameImg: existingUser.avatar)
                
            }else{
                profilePicView.setImgView(profilePic: existingUser.profilePic, frameImg: existingUser.avatar)
                
            }
        }else{
            let  profilePic = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "profilepic")
            profilePicView.setImgView(profilePic: profilePic, frameImg: "")
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
    func initialSetupMethods(){
        cvHeight = self.view.frame.width
        //cnstrnt_CollageViewHeight.constant = cvHeight
        //btnViewMore.isHidden = true
        
        
        viewPostType.layer.cornerRadius = viewPostType.frame.height / 2.0
        viewPostType.layer.borderWidth = 1.0
        viewPostType.layer.borderColor = UIColor.darkGray.cgColor
        
        tfDescription.layer.borderWidth = 0.2
        tfDescription.layer.borderColor = UIColor.lightGray.cgColor
        tfDescription.layer.cornerRadius = 5.0
        tfDescription.placeholder = "What do you want to talk about?"
        tfDescription.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        tfDescription.delegate = self
        lblTaggedItems.textColor = UIColor(red: 30.0/255.0, green: 110.0/255.0, blue: 222.0/255.0, alpha: 1.0)
        
        cvFeedsPost.register(UINib(nibName: "FeedsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeedsCollectionViewCell")
        cvFeedsPost.delegate = self
        cvFeedsPost.dataSource = self
        cvFeedsPost.layoutSubviews()
        cvFeedsPost.isPagingEnabled = true
        pageControl.isHidden = false
        pageControl.hidesForSinglePage = true
        
        
        tblTags.layer.borderWidth = 0.5
        tblTags.layer.borderColor = UIColor.gray.cgColor
        
        self.tblOption.layer.cornerRadius = 10
        self.tblOption.layer.borderColor = UIColor.darkGray.cgColor
        self.tblOption.layer.borderWidth = 1.0
        let nibName = UINib(nibName: "optWithImageTableViewCell", bundle: nil)
        self.tblOption.register(nibName, forCellReuseIdentifier: "optWithImageTableViewCell")
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
        
        let gradientLayerColor5 = CAGradientLayer()
        gradientLayerColor5.colors = [colorLeft, colorRight]
        gradientLayerColor5.locations = [0.0, 1.0]
        gradientLayerColor5.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayerColor5.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayerColor5.frame = self.btnSaveDraft.bounds
        self.btnSaveDraft.layer.cornerRadius = 5.0
        btnSaveDraft.clipsToBounds = true
        btnSaveDraft.layer.insertSublayer(gradientLayerColor5, at:0)
        btnSaveDraft.setTitleColor(UIColor.white, for: .normal)
        
    }
    
    
    func fetchSharedDataFromGallery(arrData:Array<Data>) {
        for data in arrData{
            
            if let image = UIImage(data: data) {
                do {
                    let fileName = "file \(Date().currentTimeInMiliseconds()).jpeg"
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileURL = documentsDirectory.appendingPathComponent(fileName)
                    
                    do {
                        if FileManager.default.fileExists(atPath: fileURL.path) {
                            try FileManager.default.removeItem(at: fileURL)
                        }
                    }catch{
                        
                    }
                    try data.write(to: fileURL)
                    print("saved Success")
                    self.urlSelectedItemsArray.append(fileURL)
                    urlThumnailSelectedItemsArray.append(fileURL)
                    self.arrUrlDimension.append(["height":"\(Int(image.size.height))", "width":"\(Int(image.size.width))"])
                    self.updateCVHeight(image: image)
                    self.audioWithImageArr.append(false)

                } catch {
                    print("error saving file to documents:", error)
                }
                
            }else {
                
               
                    
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                    let fileName = "file\(Date().currentTimeInMiliseconds()).mp4"
                    guard let targetURL = documentsDirectory?.appendingPathComponent(fileName) else { return }
                    
                    do {
                        if FileManager.default.fileExists(atPath: targetURL.path) {
                            try FileManager.default.removeItem(at: targetURL)
                        }
                    }catch {
                    }
                    do {
                        try data.write(to: targetURL)
                    } catch {
                        print("Error creating temporary file: \(error)")
                    }
                    
                    let asset = AVAsset(url: targetURL)
                    let duration = asset.duration
                    let durationMilliseconds: Double? = CMTimeGetSeconds(duration)
                    if durationMilliseconds ?? 0.0 <= Settings.sharedInstance.feedVideoDuration {
                        
                        self.urlSelectedItemsArray.append(targetURL)
                        self.urlThumnailSelectedItemsArray.append(targetURL)
                        self.audioWithImageArr.append(false)

                        self.arrUrlDimension.append(["height":"\(Int(targetURL.getVideoSize()?.height ?? 0))", "width":"\(Int(targetURL.getVideoSize()?.width ?? 0))"])
                        
                            self.arrHeight.append(self.view.frame.width)
                            self.updatetaggedLabel()
                            
                        
                        
                    }else {
                        DispatchQueue.main.async {
                            self.showAlert("Video exceeds the size limit of \(Int(Settings.sharedInstance.feedVideoDuration / 60)) Minute.")
                            do {
                                if FileManager.default.fileExists(atPath: targetURL.path) {
                                    try FileManager.default.removeItem(at: targetURL)
                                    
                                }
                            }catch {
                                
                            }
                        }
                    }
                
            }
            
        }
        
        //Because previous video has no thumbnail
        if self.urlThumnailSelectedItemsArray.count == 0{
            self.urlThumnailSelectedItemsArray = urlSelectedItemsArray
            
        }
    }
    
   
    
        
   
    
    @IBAction func imageTapped(tapGestureRecognizer:UITapGestureRecognizer)
    {
        /*let viewController:FeedImagesVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "FeedImagesVC") as! FeedImagesVC
        viewController.urlSelectedItemsArray = urlSelectedItemsArray
        viewController.imgRemoveDelegate = self
        viewController.selIndex = tapGestureRecognizer.view?.tag ?? 0
        AppDelegate.sharedInstance.navigationController?.pushViewController(viewController, animated: true)
         */
    }
    
 
    //MARK: -  UITextview Delegate
    func textViewDidEndEditing(_ textView: UITextView) {
        
        //DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) {
            self.tblTags.isHidden = true
        //}
        
    }
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if  text == "\n" {
            recordingHashTag = false
            startParse = 0
        }else  if text.length > 0 {
            let words = (self.tfDescription.text ?? "").components(separatedBy: CharacterSet.whitespacesAndNewlines)
            let arrHashTags = words.filter { $0.hasPrefix("#") }
            
            if arrHashTags.count > 20 && text.hasPrefix("#"){
                self.view.makeToast(message: "You can use 20 hashtag at a time." , duration: 3, position: HRToastPositionTop)
                
                return false
            }else if arrTagPeople.count > 20 && text.hasPrefix("@"){
                self.view.makeToast(message: "You can tag 20 people at a time." , duration: 3, position: HRToastPositionTop)
                return false
            }
            
            if (text == "#") {
                recordingHashTag = true
                startParse = range.location
                
                self.arrTags.removeAll()
                self.tblTags.reloadData()
            }else if (text == "@") {
                recordingUserTag = true
                startParse = range.location
                
                self.arrTagPeopleSearched.removeAll()
                self.tblTags.reloadData()
            }else if (text == " ") {
                recordingHashTag = false
                recordingUserTag = false
                tblTags.isHidden = true
            }
            
            if (recordingHashTag == true || recordingUserTag == true) {
                
                let currentText = textView.text ?? ""
                // attempt to read the range they are trying to change, or exit if we can't
                guard let stringRange = Range(range, in: currentText) else { return false }
                
                // add their new text to the existing text
                let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
                print("range.location: ", range.location, "startParse: ", startParse, "text:",text)
                replaceText = ""
                if text != "" {
                    if range.location > startParse {
                        replaceText = updatedText.substring(with: NSMakeRange(startParse, range.location + 1  - startParse ))
                    }
                }else {
                    if range.location > startParse {
                        replaceText = updatedText.substring(with: NSMakeRange(startParse, range.location  - startParse ))
                    }else{
                        recordingHashTag = false
                        recordingUserTag = false
                        tblTags.isHidden = true
                        replaceText = ""
                    }
                }
                if replaceText.length >= 3 {
                    if recordingHashTag == true {
                        self.searchHashTagPostApi(keyword: replaceText)
                    }else if recordingUserTag == true{
                        var keyword:String  = replaceText
                        if keyword.starts(with: "@") {
                            keyword.removeFirst()
                        }
                        if keyword.length > 0 {
                            self.getFriendsListAPI(keyword: keyword)
                        }
                    }
                }else {
                    self.tblTags.isHidden = true
                }
            }
        }
        return true
    }
    
    
    //MARK: - API Implementation

    func searchHashTagPostApi(keyword:String){
        
        let param:NSDictionary = ["keyword":keyword]
        if URLhandler.sharedinstance.isUploadingNewPost == false {
            AF.cancelAllRequests()
        }
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.searchHashTag as String, param: param, completionHandler: {(responseObject, error) ->  () in
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    let data = result.value(forKey: "payload") as? NSArray ?? []
                    self.arrTags.removeAll()
                    
                    for d in data
                    {
                        if let sectionDict = d as? Dictionary<String, Any>{
                            self.arrTags.append(sectionDict["sectionname"] as? String ?? "")
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.tblTags.isHidden = (self.arrTags.count == 0) ? true : false
                        self.tblTags.reloadData()
                    }
                }
                else
                {
                    self.view.makeToast(message: message , duration: 1, position: HRToastActivityPositionDefault)
                }
                
            }
        })
    }
    
  
    func getFriendsListAPI(keyword:String) {
        
        let url = Constant.sharedinstance.getFriendsURL
        
        let params = NSMutableDictionary()
        params.setValue(1, forKey: "pageNumber")
        params.setValue(25, forKey: "pageLimit")
        params.setValue("\(keyword)", forKey: "search")
        
        if URLhandler.sharedinstance.isUploadingNewPost == false {
            AF.cancelAllRequests()
        }
        URLhandler.sharedinstance.makePostAPICall(url:url as String, param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                if error != Alamofire.AFError.explicitlyCancelled as NSError {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    print(error ?? "defaultValue")
                }
                
            }
            else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    self.arrTagPeopleSearched = result["payload"] as? Array<Dictionary<String,Any>> ?? Array<Dictionary<String, Any>>()
                    
                    DispatchQueue.main.async {
                        self.tblTags.isHidden = (self.arrTagPeopleSearched.count == 0) ? true : false
                        self.tblTags.reloadData()
                    }
                    
                }else {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
                
            }
        })
    }
    
    func createNewPostApi(urlArray:[String], uploadArray:[URL],dimesionArr:Array<Any>)
    {
        var methodType:HTTPMethod = .post
        var strUrl = Constant.sharedinstance.addNewPost
        
        let params = NSMutableDictionary()
        params.setValue("\(Themes.sharedInstance.GetMyPhonenumber())", forKey: "msisdn")
        print(arrs3imgVideoURL)
        params.setValue(urlArray, forKey: "url")
        //params.setValue(arrUrlDimension, forKey: "dimension")
        params.setValue(dimesionArr, forKey: "dimension")
        params.setValue(thumbimgVideoURL, forKey: "thumbUrl")
        params.setValue("\(self.tfDescription.text ?? "")", forKey: "payload")
        params.setValue("\(postType)", forKey: "postType")
        params.setValue("\(locationString)", forKey: "place")
        params.setValue("\(self.latitude)", forKey: "latitude")
        params.setValue("\(self.longitude)", forKey: "longitude")
        
        params["isClip"] = 0
        params["isDownload "] = 1
        params["isShare "] = 1
        

        let words = (self.tfDescription.text ?? "").components(separatedBy: CharacterSet.whitespacesAndNewlines)
        let arrHashTags = words.filter { $0.hasPrefix("#") }
        
        params.setValue(arrHashTags.joined(separator: ","), forKey: "hashtag")
        
        //isImageSong for audio with image 
        for item in audioWithImageArr{
            if item == true{
                params.setValue(1, forKey: "isImageSong")
            }
        }
        
        //there will be
        for sound in arrSoundInfo {
            if sound.audio.count > 0 {
                let songInfo = ["id":sound.id ?? "" , "name":sound.name ?? "" , "thumb": sound.thumb ?? "", "url":sound.audio ?? ""]
                params.setValue(songInfo, forKey: "soundInfo")
            }
        }
        
        //remove the tags which has been removed from description text
        for obj in arrTagPeopleDesc {
            if !self.tfDescription.text.contains("@\(obj["pickzonId"] as? String ?? "")") {
                if let index = self.arrTagPeopleDesc.firstIndex(where:{ $0["pickzonId"] as? String ?? "" == obj["pickzonId"] as? String ?? "" }) {
                    self.arrTagPeopleDesc.remove(at: index)
                }
            }
        }
        
        arrTagPeopleDesc.append(contentsOf: arrTagPeople)
        arrTagPeople = arrTagPeopleDesc
        
        var tagArr:Array<String> = Array()
        if arrTagPeople.count > 0 {
            for obj in arrTagPeople {
                tagArr.append(obj["pickzonId"] as? String ?? "")
            }
            print("\(tagArr)")
            params.setValue(tagArr, forKey: "tag")
        }else{
            params.setValue(tagArr, forKey: "tag")
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
        
        //0 for anyone, 1 for no one
        params.setValue(commentType, forKey: "commentType")
        //isStory = 1 to post same feed on story, isStory = 0 normal feed.
        params.setValue(isStory, forKey: "isStory")
          
        if isFromEdit == true {
            params.setValue("\(self.objPost?.id ?? "")", forKey: "feedId")
            methodType = .put
            strUrl = Constant.sharedinstance.updateFeedPost
        }
        
        
        uploadDelegate?.uploadSelectedFilesDuringPost(thumbUrlArray: urlThumnailSelectedItemsArray, mediaArray: uploadArray, mediaName: "media", url: strUrl, params: params, method: methodType)
   
        
       // self.removeDraftAction()
        if self.isFromEdit == true  {
            
            for controller in self.navigationController?.viewControllers ?? [] {
                if controller.isKind(of: ProfileVC.self) && self.isFromProfile == true{
                    self.navigationController?.popToViewController(controller, animated: true)
                    
                }else  if controller.isKind(of: HomeBaseViewController.self) && self.isFromProfile == false{
                    self.navigationController?.popToViewController(controller, animated: true)
                }
            }
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    //MARK: - Button Action Methods
   
    @IBAction func imagePickerBtnAction()
    {
        if (urlSelectedItemsArray.count) < Settings.sharedInstance.maxPostUpload{
            
            self.showPicker()
        }else{
            showAlert("You have already selected \(Settings.sharedInstance.maxPostUpload) photo/video")
        }
    }
    
    
    @IBAction func feedCommentOptionsAction() {
        let viewController:FeedCommentOptionsVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "FeedCommentOptionsVC") as! FeedCommentOptionsVC
        viewController.commentDelegate = self
        viewController.isToggleOn = commentType
        viewController.isStory = isStory
        
        viewController.isToHideStory = true
        viewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.navigationController?.presentView(viewController, animated: true)
    }
    
    @IBAction func backButtonAction()
    {
        if self.urlSelectedItemsArray.count == 0  && self.tfDescription.text.count == 0{
            self.removeDraftAction()
        }
        self.navigationController?.popViewController(animated: true)
       /* if isFromEdit == true {
            self.navigationController?.popViewController(animated: true)
        }else  if self.urlSelectedItemsArray.count > 0 || self.tfDescription.text.count > 0{
            // Create the alert controller
            let alertController = UIAlertController(title: "", message: "Do you want to save the Draft?", preferredStyle: .alert)
            
            // Create the actions
            let okAction = UIAlertAction(title: "Save Draft", style: UIAlertAction.Style.default) {
                UIAlertAction in
                self.saveDraftAction()
                self.navigationController?.popViewController(animated: true)
            }
            let cancelAction = UIAlertAction(title: "Discard", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
                
                self.removeDraftAction()
                self.navigationController?.popViewController(animated: true)
            }
            
            // Add the actions
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            // Present the controller
            self.present(alertController, animated: true, completion: nil)
        }else {
            self.removeDraftAction()
            self.navigationController?.popViewController(animated: true)
        }*/
        
        
        
    }
    
    
    
    
    
   
    @IBAction func tagPeopleAction(){
        if postType == 3 {
            let dialogMessage = UIAlertController(title: "PickZon", message: "You cannot tag your friends in Private post.", preferredStyle: .alert)
            // Create OK button with action handler
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                print("Ok button tapped")
            })
            //Add OK button to a dialog message
            dialogMessage.addAction(ok)
            self.present(dialogMessage, animated: true, completion: nil)
        }else {
            print("tagPeopleAction")
            let viewController:TagPeopleViewController = StoryBoard.main.instantiateViewController(withIdentifier: "TagPeopleViewController") as! TagPeopleViewController
            viewController.tagPeopleDelegate = self
            viewController.arrSelectedUser = arrTagPeople + arrTagPeopleDesc
            self.navigationController?.pushView(viewController, animated: true)
        }
    }
   
    
    
    @IBAction func addLocationAction() {
        
        if self.locationString.length > 0 {
            
            let alert = UIAlertController(title: "",
                                          message: "Update or Remove Feed Location",
                                          preferredStyle: .alert)
            
            let updateLocationAction = UIAlertAction(title: "Update Location",
                                                     style: .default) { [unowned self] (_) in
                self.view.endEditing(true)
                let destVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "SearchLocationVC") as! SearchLocationVC
                destVC.delegate = self
                self.navigationController?.pushViewController(destVC, animated: true)
            }
            alert.addAction(updateLocationAction)
            let removeLocationAction = UIAlertAction(title: "Remove Location",
                                                     style: .default) { [unowned self] (_) in
                self.locationString = ""
                self.latitude = 0.0
                self.longitude = 0.0
                self.updatetaggedLabel()
            }
            alert.addAction(removeLocationAction)
            let cancelLocationAction = UIAlertAction(title: "Cancel",
                                                     style: .default) { [unowned self] (_) in
            }
            alert.addAction(cancelLocationAction)
            present(alert, animated: true, completion: nil)
        }else {
            self.view.endEditing(true)
            let destVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "SearchLocationVC") as! SearchLocationVC
            destVC.delegate = self
            self.navigationController?.pushViewController(destVC, animated: true)
        }
    }
  
    @IBAction func addFeelingActivityAction()
    {
        print("addFeelingActivityAction")
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
    
    
    func checkValidNoOfVideosAndImages() ->Bool{
        //Only Video or multiple images allowed
      var noOfVideos = 0
        var noOfImages = 0
        
        for url in self.urlSelectedItemsArray {
            let pathExtension = url.pathExtension
            if checkMediaTypes(strUrl: url.absoluteString) == 1 {
                noOfImages = noOfImages + 1
            }else if checkMediaTypes(strUrl: url.absoluteString) == 3 {
                noOfVideos = noOfVideos + 1
            }
        }
        
        
        
        if (noOfVideos > 1) || (noOfVideos > 0 && noOfImages > 0) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "", message:"Only one video or multiple images is allowed to select.", preferredStyle: UIAlertController.Style.alert)
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
            return false
        }
        
        return true
    }
    
    
    @IBAction func addNewPost() {
        if self.nudityContentsFound == true {
            self.showAlertForNudity()
        }else  if (UIApplication.shared.delegate as! AppDelegate).IsInternetconnected == true {
            self.tfDescription.text = self.tfDescription.text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let words = (self.tfDescription.text ?? "").components(separatedBy: CharacterSet.whitespacesAndNewlines)
            let arrHashTags = words.filter { $0.hasPrefix("#") }
            
            if arrHashTags.count > 20{
                self.view.makeToast(message: "You can use 20 hashtag at a time." , duration: 3, position: HRToastPositionCenter)
                return
            }else if (arrTagPeople.count + arrTagPeopleDesc.count) > 20 {
                self.view.makeToast(message: "You can tag 20 people at a time." , duration: 3, position: HRToastPositionCenter)
                return
            }else if self.tfDescription.text.length == 0 && self.urlSelectedItemsArray.count == 0{
                self.view.makeToast(message: "Please select at least one image or video or text before post a new feed" , duration: 3, position: HRToastPositionCenter)
                return
            }else if self.checkValidNoOfVideosAndImages() == true {
                
                var sendUploadMediaArray = [URL]()
                var dimensionArray = [[String:String]]()
                var urlArray = [String]()
                
                if self.urlSelectedItemsArray.count > 0 {
                    
                    var index = 0
                    
                    for url in self.urlSelectedItemsArray{
                        let strURL =  url.absoluteString
                        
                        if strURL.hasPrefix("http") {
                            if arrUrlDimension.count > index {
                                // dimensionArray.append(arrUrlDimension[index])
                                urlArray.append(strURL)
                                index = index + 1
                            }
                        }else{
                            sendUploadMediaArray.append(url)
                        }
                    }
                    dimensionArray = arrUrlDimension
                }
                if isFromEdit == false {
                    self.saveDraftAction()
                }
                self.createNewPostApi(urlArray:urlArray, uploadArray: sendUploadMediaArray, dimesionArr: dimensionArray)
            }
        }
        
    }
        
    func showAlert(_ message: String) {
        
        let alertController = UIAlertController(title: "PickZon", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    //MARK: Other Helpful Methods
    func removeDraftAction() {
        if isDraftUsed == true {
            //remove the draft
            UserDefaults.standard.removeObject(forKey: "WallPostDraft")
            UserDefaults.standard.synchronize()
        }
    }
    
    @IBAction func saveDraftAlert()
    {
        if self.urlSelectedItemsArray.count > 0 || self.tfDescription.text.count > 0{
            // Create the alert controller
            let alertController = UIAlertController(title: "", message: "Do you want to save the Draft?", preferredStyle: .alert)
            
            // Create the actions
            let okAction = UIAlertAction(title: "Save Draft", style: UIAlertAction.Style.default) {
                UIAlertAction in
                self.saveDraftAction()
                AppDelegate.sharedInstance.navigationController?.view.makeToast(message: "Draft saved successfully." , duration: 3, position: HRToastActivityPositionDefault)
                self.navigationController?.popViewController(animated: true)

            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
                
            }
            
            // Add the actions
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            // Present the controller
            self.present(alertController, animated: true, completion: nil)
        }else {
            self.view.makeToast(message: "Please select at least one image or video or text to save post as draft." , duration: 3, position: HRToastPositionCenter)
        }
        
    }
   @IBAction func saveDraftAction() {
        
        var dict:Dictionary<String, Any> = [:]
        dict["urlSelectedItemsArray"] = self.urlSelectedItemsArray
        dict["urlThumnailSelectedItemsArray"] = self.urlThumnailSelectedItemsArray
        
        dict["audioWithImageArr"] = self.audioWithImageArr
        //dict["arrSoundInfo"] = self.arrSoundInfo
        
        dict["payload"] = "\(self.tfDescription.text ?? "")"
        dict["postType"] = postType
        
        dict["place"] = "\(locationString)"
        dict["latitude"] = latitude
        dict["longitude"] = longitude
        dict["taggedPeople"] = arrTagPeople
        
        dict["isFeeling"] = isFeeling
        dict["isActivity"] = isActivity
        dict["feelingActivity"] = feelingActivity
        
        dict["commentType"] = commentType
        
        dict["fromType"] = 1
        
        
        
        
        dict["isFromEdit"] = isFromEdit
        dict["wallPostId"] = "\(self.objPost?.id ?? "")"
        
        
        print(dict)
        
        do {
            let archivedObject = try NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: false)
                UserDefaults.standard.set(archivedObject, forKey: "WallPostDraft")
            UserDefaults.standard.synchronize()
        } catch {
            print("Couldn't Archive")
        }
    }
    
    func fetchDraft(){
        var data =  Data()
            data = UserDefaults.standard.object(forKey: "WallPostDraft") as? Data ?? Data()
        
        if data.count > 0 {
            let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any] ?? [:]
            self.urlSelectedItemsArray = dict["urlSelectedItemsArray"] as? Array<URL> ?? Array<URL>()
            self.audioWithImageArr = dict["audioWithImageArr"] as? Array<Bool> ?? Array<Bool>()
            //self.arrSoundInfo = dict["arrSoundInfo"] as? Array<SoundInfo> ?? Array<SoundInfo>()
            self.arrSoundInfo = Array(repeating: SoundInfo(), count: self.urlSelectedItemsArray.count)
            
            self.urlThumnailSelectedItemsArray = dict["urlThumnailSelectedItemsArray"] as? Array<Any> ?? Array<Any>()
            
            self.tfDescription.text = dict["payload"] as? String ?? ""
            postType = dict["postType"] as? Int ?? 1
            
            locationString = dict["place"] as? String ?? ""
            latitude = dict["latitude"] as? Double ?? 0.0
            longitude = dict["longitude"] as? Double ?? 0.0
            arrTagPeople = dict["taggedPeople"] as? Array<Dictionary<String, Any>> ?? Array<Dictionary<String, Any>>()
            isFeeling = dict["isFeeling"] as? Bool ?? false
            isActivity = dict["isActivity"] as? Bool ?? false
            feelingActivity =  dict["feelingActivity"] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
            commentType = dict["commentType"] as? Int ?? 0
            
            let type = dict["fromType"] as? Int ?? 1
            
            fromType = .feedPost
            
            
            
            isFromEdit = dict["isFromEdit"] as? Bool ?? false
            if isFromEdit == true {
                self.objPost?.id = dict["wallPostId"] as? String ?? ""
            }
    
            //1 for public, 2 for friend, 3 for private
            if postType >= 1 && postType <= 3 {
                self.btnPostType.setTitle(arrOptions[postType - 1], for: .normal)
                
                if postType == 1 {
                    imgPostType.image = PZImages.publicPost
                }else  if postType == 2 {
                    imgPostType.image = PZImages.friendPost
                    
                }else if postType == 3 {
                    imgPostType.image = PZImages.privatePost
                }
            }
        }
    }
    
    func updatetaggedLabel() {
        var str:String = ""
        
        let attributedString = NSMutableAttributedString()
        
        for objDict in self.arrTagPeople {
            
            if str.length == 0 {
                str = "@" + (objDict["pickzonId"] as? String ?? "")
            }else {
                str = str + " @" + (objDict["pickzonId"] as? String ?? "")
            }
        }
        if str.length > 0 {
            str = str + "\n"
        }
        var myAttribute = [ NSAttributedString.Key.foregroundColor: Themes.sharedInstance.tagAndLinkColor() ]
        var myAttrString = NSAttributedString(string: str, attributes: myAttribute)
        attributedString.append(myAttrString)
        
        str = ""
        if self.locationString.length > 0 {
            str = str + " " + self.locationString
        }
        
        if str.length > 0 {
            str = str + "\n"
        }
        myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.label ]
        myAttrString = NSAttributedString(string: str, attributes: myAttribute)
        attributedString.append(myAttrString)
        
        str = ""
        if self.feelingActivity.count > 0 {
            print(self.feelingActivity)
            str = str + " " + (self.feelingActivity["image"] as? String ?? "")
            str = str + " " + (self.feelingActivity["name"] as? String ?? "")
        }
        myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.label]
        myAttrString = NSAttributedString(string: str, attributes: myAttribute)
        attributedString.append(myAttrString)
        
        self.lblTaggedItems.attributedText = attributedString
        
        
        
        cvHeight = self.view.frame.width
        
        //cnstrnt_CollageViewHeight.constant = cvHeight
        cnstrntCVHeight.constant = cvHeight
        
        
        
        cvFeedsPost.isHidden = false
        cvFeedsPost.reloadData()
        
        
        if locationString.length == 0 {
            lblAddLocation.text = "Add Location"
        }else {
            lblAddLocation.text = "Update Location"
            
        }
        
        self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: cvFeedsPost.frame.origin.y + cvFeedsPost.frame.height + 200)
        
        print("self.scrollView.contentSize: \(self.scrollView.contentSize)")
        
    }
 
    
    
    func updateCVHeight (image: UIImage){
        let width = image.size.width
        var height = image.size.height
        if height > width {
            let ratio = CGFloat(height) / CGFloat(width)
            height = self.view.frame.width * ratio
        }else {
            height = self.view.frame.width
        }
        self.arrHeight.append(height)
        self.updatetaggedLabel()
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
        
        if self.nudityContentsFound == true {
            return
        }
        
        NSFWDetector.shared.check(image: image) { result in
            switch result {
            case .error:
                print("Detection failed")
            case let .success(nsfwConfidence: confidence):
                print(String(format: "%.1f %% porn", confidence * 100.0))
                if Double(confidence) > Settings.sharedInstance.confidenceThreshold {
                    self.nudityContentsFound = true
                    DispatchQueue.main.async {
                        self.showAlertForNudity()
                        
                    }
                    
                }
            }
        }
    }
    
    
    func checkNudityContent() {
        
        self.nudityContentsFound = false
        for index in 0..<urlSelectedItemsArray.count {
            let objUrlString = (urlSelectedItemsArray[index].absoluteString) as NSString
            if checkMediaTypes(strUrl: urlSelectedItemsArray[index].absoluteString) == 1 {
                if isFromEdit == true && objUrlString.contains("https") {
                    let imgView:UIImageView = UIImageView()
                    imgView.kf.setImage(with: urlSelectedItemsArray[index], placeholder: UIImage(named: "video_thumbnail"), options:[.cacheOriginalImage], progressBlock: nil, completionHandler: { (resp) in
                        self.CheckNudityforImage(image: imgView.image!)
                    })
                }else{
                    let imgView:UIImageView = UIImageView()
                    imgView.image = UIImage(contentsOfFile: urlSelectedItemsArray[index].path)
                    self.CheckNudityforImage(image: imgView.image!)
                }
                
            }else {
                
                let url = urlSelectedItemsArray[index]
                let videoAsset = AVAsset(url: url)
                let duration:Float = Float(videoAsset.duration.seconds)
                let div:Float = duration / 5
                var timesArray:Array<NSValue> = []
                for index in 1...5 {
                    var val:Int64 = 0
                    if div > 0 {
                        val = Int64((Float)(index) * div)
                    }else {
                        val = Int64(div)
                    }
                    if Int64(duration) >= val {
                        let t = CMTime(value: val, timescale: 1)
                        timesArray.append(NSValue(time: t))
                    }
                }
                
                
                if timesArray.count > 0 {
                    let generator = AVAssetImageGenerator(asset: videoAsset)
                    generator.requestedTimeToleranceBefore = .zero
                    generator.requestedTimeToleranceAfter = .zero
                    
                    for obj in timesArray {
                        generator.generateCGImagesAsynchronously(forTimes: [obj] ) { requestedTime, image, actualTime, result, error in
                            if image != nil && error == nil {
                                let img = UIImage(cgImage: image!)
                                self.CheckNudityforImage(image: img)
                            }
                        }
                        if self.nudityContentsFound == true {
                            break
                        }
                    }
                }
                
                
            }
            if self.nudityContentsFound == true {
                break
            }
        }
        
    }

    
    func fileSizeinMB(filePath:String) {
        var fileSize : UInt64

        do {
            //return [FileAttributeKey : Any]
            let attr = try FileManager.default.attributesOfItem(atPath: filePath)
            fileSize = attr[FileAttributeKey.size] as! UInt64
            let sizeinMB = Double(fileSize) / (1024.0 * 1024.0)
            print("fileSize: ", String(format: "%4.2f MB", sizeinMB))
        } catch {
            print("Error: \(error)")
        }
    }
    
}



// Support methods
extension CreateWallPostViewController:YPImagePickerDelegate {
    
    
        
    // MARK: - Configuration
    @objc func showPicker() {
        
       
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photoAndVideo
        config.library.itemOverlayType = .grid
        config.shouldSaveNewPicturesToAlbum = false
        config.video.compression = AVAssetExportPresetPassthrough
        // config.video.compression = AVAssetExportPresetMediumQuality
        config.albumName = "PickZon"
        config.startOnScreen = .library
        config.screens = [.library, .photo, .video]
        config.isToCompressUsingThirdPartyLibrary = true
        
        if Settings.sharedInstance.isCompressRequired == 0{
            config.isToCompressUsingThirdPartyLibrary = false
        }
        /* Can forbid the items with very big height with this property */
        // config.library.minWidthForItem = UIScreen.main.bounds.width * 0.5
        
        /* Defines the time limit for recording videos.
         Default is 30 seconds. */
        config.video.recordingTimeLimit = Settings.sharedInstance.feedVideoDurationCam
       
       
        
        /* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
        config.showsCrop = .none
        /* Customize wordings */
        config.wordings.libraryTitle = "Gallery"
        /* Defines if the status bar should be hidden when showing the picker. Default is true */
        config.hidesStatusBar = false
        
        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false
        config.maxCameraZoomFactor = 2.0
        
        
        config.library.maxNumberOfItems =  Settings.sharedInstance.maxPostUpload - (urlSelectedItemsArray.count)
        config.gallery.hidesRemoveButton = false
        config.video.fileType = .mp4
        
        config.video.trimmerMaxDuration = Settings.sharedInstance.feedVideoDuration
        config.video.trimmerMinDuration = 3.0
        /* Defines the time limit for videos from the library.
         Defaults to 60 seconds. */
        config.video.libraryTimeLimit = 60 * 30
        config.video.minimumTimeLimit = 3.0
        
        config.library.preselectedItems = selectedItems
        config.onlySquareImagesFromCamera = false
        
        let picker = YPImagePicker(configuration: config)
        picker.imagePickerDelegate = self
        
        picker.didFinishPicking { [weak picker] items, cancelled in
            
            if cancelled {
                print("Picker was canceled")
                picker?.dismiss(animated: true, completion: nil)
                return
            }
            _ = items.map { print("🧀 \($0)") }
            
            for value in items {
                switch value {
                case .photo(let photo):
                    
                    let fileName = "file\(Date().currentTimeInMiliseconds()).jpeg"
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileURL = documentsDirectory.appendingPathComponent(fileName)
                    if let data = photo.image.jpegData(compressionQuality: 1.0) {
                        do {
                            try data.write(to: fileURL)
                            
                            let imageSize: Int = data.count
                            print("actual size of image in MB: %f ", Double(imageSize) / 1024.0 / 1024.0)
                            self.arrUrlDimension.append(["height":"\(Int(photo.image.size.height))", "width":"\(Int(photo.image.size.width))"])
                            self.urlSelectedItemsArray.append(fileURL)
                            self.urlThumnailSelectedItemsArray.append(fileURL)
                            self.updateCVHeight(image: photo.image)
                            self.audioWithImageArr.append(false)
                            self.arrSoundInfo.append(SoundInfo())
                            
                        } catch {
                            print("error saving file to documents:", error)
                        }
                    }
                    
                case .video(let video):
                    
                        self.fileSizeinMB(filePath: video.url.path)
                    
                        self.arrUrlDimension.append(["height":"\(Int(video.url.getVideoSize()?.height ?? 0))", "width":"\(Int(video.url.getVideoSize()?.width ?? 0))"])
                        self.urlSelectedItemsArray.append(video.url)
                        self.urlThumnailSelectedItemsArray.append(video.thumbnail)
                        self.arrHeight.append(self.view.frame.width)
                        self.audioWithImageArr.append(false)
                        self.arrSoundInfo.append(SoundInfo())
                        DispatchQueue.main.async {
                            self.updatetaggedLabel()
                        }
                    
                }
                
            }
            picker?.dismiss(animated: true, completion: nil)
            DispatchQueue.main.async {
                if Settings.sharedInstance.confidenceThreshold < 0.80 {
                    self.checkNudityContent()
                }
            }
        }
        present(picker, animated: true, completion: nil)
        
    }
    
    
 
    func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker) {
        // PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
    }

    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true // indexPath.row != 2
    }
    
    
    
    func itemsPicked() {
        print("Items Picked")
    }
    
    
}


extension CreateWallPostViewController : UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK:  Tableview Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if tableView == tblTags{
            if recordingHashTag == true {
                return arrTags.count
            }else {
                return arrTagPeopleSearched.count
            }
            
        }else if tableView == tblOption {
            return arrOptions.count
        }else{
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if tableView == tblTags{
            let cell = tableView.dequeueReusableCell(withIdentifier: "tagCell")!
            if recordingHashTag == true {
                if arrTags.count > indexPath.row {
                    cell.textLabel?.text = arrTags[indexPath.row] as? String ?? ""
                }else {
                    cell.textLabel?.text = ""
                }
            }else {
                if arrTagPeopleSearched.count > indexPath.row {
                    cell.textLabel?.text = arrTagPeopleSearched[indexPath.row]["pickzonId"] as? String ?? ""
                }else {
                    cell.textLabel?.text = ""
                }
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "optWithImageTableViewCell") as! optWithImageTableViewCell
        cell.selectionStyle = .none
        cell.imgOption.image = UIImage(named:arrImages[indexPath.row])
        cell.imgOption.image = nil
        cell.lblText.text = arrOptions[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == tblTags{
            print("didSelectRowAt---")
            let range = NSMakeRange(startParse, replaceText.length)
            guard let stringRange = Range(range, in: tfDescription.text) else { return  }
            // add their new text to the existing text
            if recordingHashTag == true {
                tfDescription.text = tfDescription.text.replacingCharacters(in: stringRange, with: "\(arrTags[indexPath.row]) ")
            }else {
                let filterArray =  arrTagPeople.filter {$0["pickzonId"] as? String ?? "" == arrTagPeopleSearched[indexPath.row]["pickzonId"] as? String ?? "" }
                
                let filterArray1 = arrTagPeopleDesc.filter {$0["pickzonId"] as? String ?? "" == arrTagPeopleSearched[indexPath.row]["pickzonId"] as? String ?? "" }
                
                if filterArray.isEmpty == false {
                    self.view.makeToast(message: "You have already tagged this user." , duration: 3, position: HRToastPositionCenter)
                    
                } else if filterArray1.isEmpty == false {
                    self.view.makeToast(message: "You have already tagged this user." , duration: 3, position: HRToastPositionCenter)
                    
                } else  {
                    tfDescription.text = tfDescription.text.replacingCharacters(in: stringRange, with: "@\(arrTagPeopleSearched[indexPath.row]["pickzonId"] as? String ?? "") ")
                    arrTagPeopleDesc.append(arrTagPeopleSearched[indexPath.row])
                }
            }
            self.arrTags.removeAll()
            self.arrTagPeopleSearched.removeAll()
            self.tblTags.reloadData()
            self.tblTags.isHidden = true
            tfDescription.becomeFirstResponder()
            
        }else{
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
                //self.imgPostType.image = UIImage(named:arrImages[indexPath.row])
                self.postType = indexPath.row + 1
                self.showPostTypeAction(sender: btnPostType)
                if self.postType == 3 {
                    self.arrTagPeople.removeAll()
                    self.updatetaggedLabel()
                }
            }
        }
    }
    
    
    
    
     //MARK: - UICollectionview delegate and datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         self.pageControl.numberOfPages = urlSelectedItemsArray.count
         return   urlThumnailSelectedItemsArray.count
        // return  urlSelectedItemsArray.count
         
     }
     
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedsCollectionViewCell", for: indexPath) as! FeedsCollectionViewCell
        cell.url = urlSelectedItemsArray[indexPath.row].absoluteString
        cell.urlArray = urlSelectedItemsArray.map({ url in
            return url.absoluteString
        })
        cell.selIndex = indexPath.item
        cell.btnAddMusic.isHidden = false
        cell.btnAddMusic.tag = indexPath.item
        cell.btnAddMusic.addTarget(self, action: #selector(addsoundBtn(_ : )), for: .touchUpInside)
        if isFromEdit == true {
            cell.btnAddMusic.isHidden = true
        }
        let objUrlString = (urlSelectedItemsArray[indexPath.row].absoluteString) as NSString
        
        if objUrlString.contains("https") {
            cell.btnAddMusic.isHidden = true
        }

        print("urlSelectedItemsArray[indexPath.row] : ",urlSelectedItemsArray[indexPath.row].absoluteString)
        cell.imgImageView.image = nil
        
        if checkMediaTypes(strUrl: urlSelectedItemsArray[indexPath.row].absoluteString) == 1  {
            
            cell.imgImageView.kf.setImage(with:  urlSelectedItemsArray[indexPath.row],placeholder:  PZImages.dummyCover)
            
            if isFromEdit == true && objUrlString.contains("https") {
                cell.imgImageView.kf.setImage(with: urlSelectedItemsArray[indexPath.row],placeholder:  PZImages.dummyCover)
            }else{
                cell.imgImageView.image = UIImage(contentsOfFile: urlSelectedItemsArray[indexPath.row].path)
                
            }
            cell.configureCell(isToHidePlayer: true, indexPath: indexPath)
            cell.imgImageView.contentMode = .scaleAspectFill
            
        }else{
            if let img = urlThumnailSelectedItemsArray[indexPath.item] as? UIImage{
                cell.imgImageView.image = img
                
            } else if let imgStr = urlThumnailSelectedItemsArray[indexPath.item] as? String{
                cell.imgImageView.kf.setImage(with: URL(string: imgStr),placeholder: PZImages.dummyCover)
                
            }else if let imgUrl = urlThumnailSelectedItemsArray[indexPath.item] as? URL{
                
                cell.imgImageView.image = UIImage(contentsOfFile: imgUrl.path)
            }
            cell.configureCell(isToHidePlayer: false, indexPath: indexPath)
            cell.imgImageView.contentMode = .scaleAspectFill
         
        }
        
        
        cell.btnPreview.isHidden = false
        cell.btnPreview.setImage(UIImage(named: "delete_white"), for: .normal)
        cell.btnPreview.backgroundColor = UIColor.systemRed

        cell.btnPreview.tag = indexPath.item
        cell.btnPreview.addTarget(self, action: #selector(deleteSelectedMedia(_ : )), for: .touchUpInside)
        
        cell.layoutIfNeeded()
        cell.updateConstraints()
        
        return cell
    }
    
      func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
          self.pageControl.currentPage = indexPath.item
          //let cell = cvFeedsPost.cellForItem(at:indexPath) as? FeedsCollectionViewCell
          //cell?.setPreviewBtnFrame(top: true)
      }
      
      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          print(urlSelectedItemsArray)
          return CGSize(width: self.cvFeedsPost.frame.size.width , height:cvHeight)
      }
      
      func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         
          let objUrlString = (urlSelectedItemsArray[indexPath.row].absoluteString) as NSString
          if checkMediaTypes(strUrl: urlSelectedItemsArray[indexPath.row].absoluteString) == 1 {
              var newArray = Array<String>()
              newArray.append(objUrlString as String)
              let selIndex = newArray.firstIndex(of: objUrlString as String) ?? 0
              let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "ZoomImageViewController") as! ZoomImageViewController
              vc.currentTag = selIndex
              vc.imageArrayUrl = newArray
              if let cell = cvFeedsPost.cellForItem(at:indexPath)  as? FeedsCollectionViewCell{
                  vc.imageColor = cell.imgImageView.image?.getAverageColour ?? .darkGray
              }
              self.navigationController?.pushViewController(vc, animated: true)
          }else{
              
              /*let videoURL = URL(string: objUrlString as String)
               let player = AVPlayer(url: videoURL! )
               let playerViewController = AVPlayerViewController()
               playerViewController.player = player
               self.presentView(playerViewController, animated: true) {
               playerViewController.player!.play()
               }
               */
          }
      }
      
    @objc func deleteSelectedMedia(_ sender:UIButton){
        
        AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to remove selected image/video", buttonTitles: ["Yes","No"], onController: self) { title, selIndex in
            
            if selIndex == 0{
                print("self.audioWithImageArr.count: \(self.audioWithImageArr.count) sender.tag: \(sender.tag)")
                if self.audioWithImageArr[sender.tag] == true {
                    self.audioWithImageArr[sender.tag] = false
                }

                self.checkAndDelete(indexOfCell: sender.tag)
                if Settings.sharedInstance.confidenceThreshold < 0.80 {
                    self.checkNudityContent()
                }
                
                self.cvFeedsPost.reloadData()
            }
        }
    }
     
    func pauseAllVisiblePlayers() {
         let visibleIndexPaths = self.cvFeedsPost.indexPathsForVisibleItems
            for indexPath in visibleIndexPaths {
                if let cell = cvFeedsPost.cellForItem(at:indexPath) as? FeedsCollectionViewCell {
                    cell.pauseVideo()
                }
            }
    }
    
    func checkAndDelete(indexOfCell:Int){
        
        let indexPath = IndexPath(row: indexOfCell, section: 0)
        if let cell = cvFeedsPost.cellForItem(at:indexPath) as? FeedsCollectionViewCell {
            cell.pauseVideo()
        }
        let objUrlString = (urlSelectedItemsArray[indexPath.row].absoluteString) as NSString
        
        if checkMediaTypes(strUrl: urlSelectedItemsArray[indexOfCell].absoluteString) == 1 {
            
            do {
                
                let url = URL(string: objUrlString as String)
                if FileManager.default.fileExists(atPath: (url?.path)!) {
                    try FileManager.default.removeItem(at: url!)
                    print(" Image DEleted")
                    
                }
                
                
            } catch let err as NSError {
                print("Not able to remove\(err)")
            }
            
            
        }else {
            /*
             let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
             //let fileName = "file\(indexOfCell).mp4"
             let fileName =  "\(urlSelectedItemsArray[indexOfCell])"
             
             guard let targetURL = documentsDirectory?.appendingPathComponent(fileName) else { return }
             
             print(targetURL)
             do {
             
             let url = URL(string: objUrlString as String)
             if FileManager.default.fileExists(atPath: (url?.path)!) {
             try FileManager.default.removeItem(at: url!)
             print("DEleted")
             }
             
             
             } catch let err as NSError {
             print("Not able to remove\(err)")
             } */
        }
        
        if isFromEdit && indexOfCell < self.thumbimgVideoURL.count{
            
            self.thumbimgVideoURL.remove(at: indexOfCell)
        }
        self.urlSelectedItemsArray.remove(at: indexOfCell)
        self.urlThumnailSelectedItemsArray.remove(at: indexOfCell)
        

        if self.arrs3imgVideoURL.count > indexOfCell{
            self.arrs3imgVideoURL.remove(at: indexOfCell)
        }
        self.cvFeedsPost.reloadData()
        
        if arrHeight.count > indexOfCell {
            arrHeight.remove(at: indexOfCell)
        }
        
        if audioWithImageArr.count > indexOfCell {
            
            self.audioWithImageArr.remove(at: indexOfCell)
        }
        if arrSoundInfo.count > indexOfCell {
            self.arrSoundInfo.remove(at: indexOfCell)
        }
        
        self.updatetaggedLabel()
    }
         
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
         
         let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
         pageControl.currentPage = Int(pageNumber)
         let indexPath = IndexPath(row: Int(pageNumber), section: 0)

         let cell = cvFeedsPost.cellForItem(at:indexPath)  as? FeedsCollectionViewCell
        // cell?.mmPlayerLayer.currentPlayStatus = .pause
         //cell?.mmPlayerLayer.player?.pause()
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
    
    @objc func addsoundBtn(_ sender: UIButton) {
        if  checkMediaTypes(strUrl: urlSelectedItemsArray[sender.tag].absoluteString) == 1{
            AlertView.sharedManager.presentAlertWith(title: "", msg: "Audio will be applied to all images. Please make sure to select identical images for better video. Do you wish to continue", buttonTitles: ["Yes","No"], onController: self) { title, selIndex in
                
                if selIndex == 0{
                    self.selectedMediaIndex = sender.tag
                    if let cell = self.cvFeedsPost.cellForItem(at:IndexPath(row: self.selectedMediaIndex, section: 0)) as? FeedsCollectionViewCell{
                        cell.pauseVideo()
                    }
                    
                    let viewController:SpotifyCategoriesVC = StoryBoard.spotify.instantiateViewController(withIdentifier: "SpotifyCategoriesVC") as! SpotifyCategoriesVC
                    viewController.onSongSelection = self
                    self.pushView(viewController, animated: true)
                    
                }
            }
        }else {
            self.selectedMediaIndex = sender.tag
            if let cell = self.cvFeedsPost.cellForItem(at:IndexPath(row: self.selectedMediaIndex, section: 0)) as? FeedsCollectionViewCell{
                cell.pauseVideo()
            }
            
            let viewController:SpotifyCategoriesVC = StoryBoard.spotify.instantiateViewController(withIdentifier: "SpotifyCategoriesVC") as! SpotifyCategoriesVC
            viewController.onSongSelection = self
            self.pushView(viewController, animated: true)
        }
        
        
       
    }
}


extension CreateWallPostViewController:FeedCommentOptionDelegate,ImageRemovedDelegate,SearchLocationDelegate,TagPeopleDelegate,FeelingActivityDelegate{
    
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
    
    
    func tagPeopleDoneAction(arrTagPeople : Array<Dictionary<String, Any>>) {
        self.arrTagPeople = arrTagPeople
        for obj in arrTagPeopleDesc {
            
            if let index = self.arrTagPeople.firstIndex(where:{ $0["pickzonId"] as? String ?? "" == obj["pickzonId"] as? String ?? "" }) {
                self.arrTagPeople.remove(at: index)
            }
        }
        self.updatetaggedLabel()
    }
    
    func selectedSearchedLocation(place:MKPlacemark,mapItem:MKMapItem,title:String,Subtitle:String){
        self.latitude = place.location?.coordinate.latitude ?? 0.0
        self.longitude = place.location?.coordinate.longitude ?? 0.0
        self.locationString = "\(title), \(Subtitle)"
        self.updatetaggedLabel()
    }
    
    func whoCanCommentSelected(option:Int,isStory:Int) {
        print("Option selected : \(option)")
        commentType = option
        self.isStory = isStory
    }
    
    func imageRemoved(index: Int) {
        print("index: \(index)")
        
        if arrs3imgVideoURL.count > index {
            arrs3imgVideoURL.remove(at: index)
        }
        if arrUrlDimension.count > index {
            arrUrlDimension.remove(at: index)
        }
        
        if thumbimgVideoURL.count > index {
            thumbimgVideoURL.remove(at: index)
        }
        
        if urlSelectedItemsArray.count > index {
            urlSelectedItemsArray.remove(at: index)
            self.urlThumnailSelectedItemsArray.remove(at: index)
        }
        
        if audioWithImageArr.count > index {
            
            self.audioWithImageArr.remove(at: index)
        }

        
        if s3VideoUrl.count > index {
            s3VideoUrl.remove(at: index)
        }
        if arrSoundInfo.count > index {
            arrSoundInfo.remove(at: index)
        }
        self.updatetaggedLabel()
        
    }
}


extension CreateWallPostViewController:onSongSelectionDelegate,onCancelClick,onDonePreviewClick,GalleryVideoDelegate {
 
    
    //MARK: onSongSelectionDelegate
    
    func onDone(soundID:String,url:URL,fileName:String){
        if checkMediaTypes(strUrl: urlSelectedItemsArray[selectedMediaIndex].absoluteString) == 1{
            //Remove all images
            for url in self.urlSelectedItemsArray {
                let objUrlString = url.absoluteString
                if  checkMediaTypes(strUrl:objUrlString) == 1 {
                    if let index = self.urlSelectedItemsArray.firstIndex(of: url){
                        if index != self.selectedMediaIndex {
                            self.imageRemoved(index: index)
                            if index < self.selectedMediaIndex {
                                self.selectedMediaIndex = self.selectedMediaIndex - 1
                            }
                        }
                        
                    }
                }
            }
            
            //Need to set true when only song is added to image
            audioWithImageArr[selectedMediaIndex] = true
        }
        
        if let soundInfo = selctedSoundInfo {
            arrSoundInfo[selectedMediaIndex] = soundInfo
        }
        selctedSoundInfo = nil
        
        self.urlSelectedItemsArray[selectedMediaIndex] = url
        self.cvFeedsPost.reloadData()
    }
    
    
    func onDismiss() {
        if selctedSoundInfo != nil {
            arrSoundInfo[selectedMediaIndex] = SoundInfo()
            selctedSoundInfo = nil
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func onSelection(id: String, url: String,name:String, timeLimit: Int,thumbUrl:String,originalUrl:String) {
        
        musicUrl = url
        musicId = id
        
        selctedSoundInfo = SoundInfo()
        selctedSoundInfo.id = musicId
        selctedSoundInfo.audio = originalUrl
        selctedSoundInfo.thumb = thumbUrl
        selctedSoundInfo.name = name
            
       
        if  checkMediaTypes(strUrl: urlSelectedItemsArray[selectedMediaIndex].absoluteString) == 1{
            
            var selectedImages = [UIImage]()
            var imgSize:CGSize = .zero
            
            for url in urlSelectedItemsArray {
                let objUrlString = url.absoluteString
               if  checkMediaTypes(strUrl:objUrlString) == 1 {
                   let image:UIImage = UIImage(contentsOfFile: url.path) ?? UIImage()
                   selectedImages.append(image)
                   imgSize = image.size
                }
            }
            
            if selectedImages.count == 1{
                selectedImages.append(selectedImages.first!)
            }
            LoadingView.lockView()
            let fileName = "\(Int64(Date().timeIntervalSince1970))pickZone"
            let audio = AVURLAsset(url: URL(fileURLWithPath: url))
            let audioDuration = CMTime(seconds: Double(timeLimit), preferredTimescale: audio.duration.timescale)
            let timeRange:CMTimeRange = CMTimeRange(start: CMTime.zero, duration: audioDuration)
               
            let maker = VideoMaker(images: selectedImages, transition: ImageTransition.crossFade)
            maker.contentMode =  (urlSelectedItemsArray.count == 1) ? .scaleAspectFit : .scaleAspectFill
            maker.videoDuration = timeLimit
            maker.quarity = .high
           
            if (urlSelectedItemsArray.count == 1){
                maker.movement = .none
                if imgSize.height > imgSize.width {
                    let ratio = imgSize.height / imgSize.width
                    var size  = CGSize(width: (UIScreen.ft_height()/ratio)*3, height: UIScreen.ft_height()*3)
                    if size.height > imgSize.height {
                        maker.size = imgSize
                    }else {
                        maker.size = size
                    }
                }else {
                    let ratio = imgSize.width / imgSize.height
                    var size  = CGSize(width: UIScreen.ft_width()*3, height: (UIScreen.ft_width()/ratio)*3)
                    if size.width > imgSize.width {
                        maker.size = imgSize
                    }else {
                        maker.size = size
                    }
                }
                print(maker.size)
            }
            
            maker.exportVideo(audio: AVURLAsset(url: URL(fileURLWithPath: url)), audioTimeRange:timeRange , completed: { success, videoURL in
                LoadingView.unlockView()
                if let url = videoURL {
                    print(url)
                    DispatchQueue.main.async {
                          let vc = StoryBoard.main.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
                          vc.url = url
                          vc.onCancel = self
                          vc.soundID = id
                          vc.onDone = self
                          vc.fileName = fileName
                          vc.modalPresentationStyle = .fullScreen
                          self.navigationController?.presentView(vc, animated: true)
                  }
                    
                }
            }).progress = { progress in
                print(progress)
            }
            
           /* let fileName = "\(Int64(Date().timeIntervalSince1970))pickZone"
            VideoGenerator.fileName = fileName
            VideoGenerator.shouldOptimiseImageForVideo = true
            LoadingView.lockView()
                VideoGenerator.current.generate(withImages: selectedImages, andAudios: [URL(fileURLWithPath: url)], andType: .singleAudioMultipleImage, { (progress) in
                    print(progress)
                }) { (result) in
                    LoadingView.unlockView()
                    switch result {
                    case .success(let url):
                              DispatchQueue.main.async {
                                    let vc = StoryBoard.main.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
                                    vc.url = url
                                    vc.onCancel = self
                                    vc.soundID = id
                                    vc.onDone = self
                                    vc.fileName = fileName
                                    vc.modalPresentationStyle = .fullScreen
                                    self.navigationController?.presentView(vc, animated: true)
                            }
                    case .failure(let error):
                        print(error)
                    }
                }*/
            
        }else{
            

            DispatchQueue.main.async {
            let videoAsset = AVAsset(url: self.urlSelectedItemsArray[self.selectedMediaIndex])
            let ObjMultiRecord:MultimediaRecord = MultimediaRecord()
            ObjMultiRecord.StartTime = 0.0
            ObjMultiRecord.FileSize = videoAsset.calculateFileSize()/1024/1024
            ObjMultiRecord.totalDuration = videoAsset.duration.seconds
                
            ObjMultiRecord.Endtime = videoAsset.duration.seconds
            ObjMultiRecord.assetname = (self.urlSelectedItemsArray[self.selectedMediaIndex].absoluteString as  NSString).lastPathComponent
            ObjMultiRecord.assetpathname = self.urlSelectedItemsArray[self.selectedMediaIndex].absoluteString
            
                let vc = StoryBoard.main.instantiateViewController(withIdentifier: "EditVideoVC") as! EditVideoVC
                vc.ObjMultimedia = ObjMultiRecord
                vc.delegateVideo = self
                vc.audioURL = self.musicUrl
                vc.audioID = self.musicId
                vc.audioLength = timeLimit
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.presentView(vc, animated: true)
            }
        }

    }
        
    
  
                                                                                             
    func mergeVideoAndAudio(videoUrl: URL,
                            audioUrl: URL,savePathUrl:URL,
                            shouldFlipHorizontally: Bool = false,
                            completion: @escaping (_ error: Error?, _ url: URL?) -> Void) {
        
        let mixComposition = AVMutableComposition()
        var mutableCompositionVideoTrack = [AVMutableCompositionTrack]()
        var mutableCompositionAudioTrack = [AVMutableCompositionTrack]()
        var mutableCompositionAudioOfVideoTrack = [AVMutableCompositionTrack]()
        
        //start merge
        
        let aVideoAsset = AVAsset(url: videoUrl.standardizedFileURL)
        let aAudioAsset = AVAsset(url: audioUrl)
        
        let compositionAddVideo = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                                 preferredTrackID: kCMPersistentTrackID_Invalid)
        
        
        let compositionAddAudio = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                 preferredTrackID: kCMPersistentTrackID_Invalid)!
        
        let compositionAddAudioOfVideo = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                        preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaType.video)[0]
        //  let aAudioOfVideoAssetTrack: AVAssetTrack? = aVideoAsset.tracks(withMediaType: AVMediaType.audio).first
        let aAudioAssetTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaType.audio)[0]
        
        // Default must have tranformation
        compositionAddVideo?.preferredTransform = aVideoAssetTrack.preferredTransform
        
        if shouldFlipHorizontally {
            // Flip video horizontally
            var frontalTransform: CGAffineTransform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            frontalTransform = frontalTransform.translatedBy(x: -aVideoAssetTrack.naturalSize.width, y: 0.0)
            frontalTransform = frontalTransform.translatedBy(x: 0.0, y: -aVideoAssetTrack.naturalSize.width)
            compositionAddVideo?.preferredTransform = frontalTransform
        }
        
        mutableCompositionVideoTrack.append(compositionAddVideo!)
        mutableCompositionAudioTrack.append(compositionAddAudio)
        mutableCompositionAudioOfVideoTrack.append(compositionAddAudioOfVideo!)
        
        do {
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                                                                duration: aVideoAssetTrack.timeRange.duration),
                                                                of: aVideoAssetTrack,
                                                                at: CMTime.zero)
            
            //In my case my audio file is longer then video file so i took videoAsset duration
            //instead of audioAsset duration
            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                                                                duration: aVideoAssetTrack.timeRange.duration),
                                                                of: aAudioAssetTrack,
                                                                at: CMTime.zero)
            
            /*  // adding audio (of the video if exists) asset to the final composition
             if let aAudioOfVideoAssetTrack = aAudioOfVideoAssetTrack {
             try mutableCompositionAudioOfVideoTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
             duration: aVideoAssetTrack.timeRange.duration),
             of: aAudioOfVideoAssetTrack,
             at: CMTime.zero)
             }*/
        } catch {
            print(error.localizedDescription)
        }
        
        // Exporting
        //let savePathUrl: URL = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/newVideo.mp4")
       // let savePathUrl : URL = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/\(Int64(Date().timeIntervalSince1970))pickZone.mp4")
        do { // delete old video
            try FileManager.default.removeItem(at: savePathUrl)
        } catch { print(error.localizedDescription) }
        
        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = savePathUrl
        assetExport.shouldOptimizeForNetworkUse = true
        
        assetExport.exportAsynchronously { () -> Void in
            switch assetExport.status {
            case AVAssetExportSession.Status.completed:
                print("success")
                completion(nil, savePathUrl)
            case AVAssetExportSession.Status.failed:
                print("failed \(assetExport.error?.localizedDescription ?? "error nil")")
                completion(assetExport.error, nil)
            case AVAssetExportSession.Status.cancelled:
                print("cancelled \(assetExport.error?.localizedDescription ?? "error nil")")
                completion(assetExport.error, nil)
            default:
                print("complete")
                completion(assetExport.error, nil)
            }
        }
        
    }


    func onVideoPicked(_ asset: AVAsset, start:CGFloat ,endTime:CGFloat) {
        
        let savePathUrl : URL = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/\(Int64(Date().timeIntervalSince1970))pickZone.mp4")
        let fileName = "\(Int64(Date().timeIntervalSince1970))pickZone.mp4"

        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = savePathUrl
        assetExport.shouldOptimizeForNetworkUse = true
        let timeRange = CMTimeRange(start: CMTime(seconds: Double(start), preferredTimescale: 1000), duration: CMTime(seconds: Double(endTime - start), preferredTimescale: 1000))
        assetExport.timeRange = timeRange
        
      
         assetExport.exportAsynchronously { () -> Void in
             switch assetExport.status {
             case AVAssetExportSession.Status.completed:

                 if self.musicUrl.length == 0{
                    DispatchQueue.main.async {
                        let vc = StoryBoard.main.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
                        vc.url = savePathUrl
                        vc.onCancel = self
                        vc.soundID = ""
                        vc.onDone = self
                        vc.fileName = fileName
                        vc.modalPresentationStyle = .fullScreen
                        self.navigationController?.presentView(vc, animated: true)
                    }
                }else {
                    
                    let audioURl = URL(fileURLWithPath: self.musicUrl)
                    if  audioURl != nil {
                        DispatchQueue.main.async {

                            self.mergeVideoAndAudio(videoUrl: savePathUrl, audioUrl: audioURl, savePathUrl: savePathUrl) { error, url in
                                if url != nil {
                                    DispatchQueue.main.async {
                                        let vc = StoryBoard.main.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
                                        vc.url = url
                                        vc.onCancel = self
                                        vc.soundID = self.musicId
                                        vc.onDone = self
                                        vc.fileName = fileName
                                        vc.modalPresentationStyle = .fullScreen
                                        self.navigationController?.presentView(vc, animated: true)
                                    }
                                    
                                }
                            }
                            
                        }
                        
                    }
                    
                }
                
                
            case  AVAssetExportSession.Status.failed:
                DispatchQueue.main.async {
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                    self.view.makeToast("Failed to save..")
                }
            case AVAssetExportSession.Status.cancelled:
                DispatchQueue.main.async {
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                    self.view.makeToast("Cancelled..")
                }
            default:
                print("complete")
            }
        }
            
    }
}



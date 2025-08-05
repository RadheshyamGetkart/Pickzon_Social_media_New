//
//  CreateWallPostViewController.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 6/12/21.
//  Copyright © 2021 CASPERON. All rights reserved.


import UIKit
import MobileCoreServices
import AVKit
import PhotosUI
import MapKit
import IQKeyboardManager
import NSFWDetector


class CreateWallStatusVC: UIViewController {
   
    @IBOutlet weak var cnstrnt_HtNAvBar:NSLayoutConstraint!
    @IBOutlet weak var cvFeedsPost:UICollectionView!
    @IBOutlet weak var btnPost:UIButton!
    @IBOutlet weak var btnAdd:UIButton!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
   
    var isDisplayPhotos = false
    var isDisplayVideos = false
    var fileName = ""
    var uploadedCount = 0
    var selectedItems = [YPMediaItem]()
    var nudityContentsFound = false
    var selectedMediaIndex = 0
    var storyArray = Array<StoryUploadModel>()

    // MARK: - ViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrnt_HtNAvBar.constant = self.getNavBarHt
        updateColorBack()
        cvFeedsPost.register(UINib(nibName: "FeedsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeedsCollectionViewCell")
        cvFeedsPost.register(UINib(nibName: "CommentCVCell", bundle: nil), forCellWithReuseIdentifier: "CommentCVCell")
        cvFeedsPost.delegate = self
        cvFeedsPost.dataSource = self
        cvFeedsPost.isPagingEnabled = true
        self.showPicker()
        cvFeedsPost.layer.cornerRadius = 10.0
        cvFeedsPost.clipsToBounds = true
        self.pageControl.addTarget(self, action: #selector(pageControltapped(_:)), for: .valueChanged)
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 25
        pageControl.numberOfPages = storyArray.count
        print("UIViewController: CreateWallStatusVC")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        PlayerHelper.shared.pause()
        self.pauseAllVideos()
        super.viewWillDisappear(animated)
    }
    
    //MARK: Initial Setup Methods
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
    
    
    @objc func pageControltapped(_ sender: Any) {
        guard let pageControl = sender as? UIPageControl else { return }
        print("pageControl=======\(pageControl.currentPage)")
        self.cvFeedsPost.scrollToItem(at:  IndexPath(row: pageControl.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    
    @objc func pauseAllVisiblePlayers(){
        
        var index = 0
        for _ in storyArray {
            if let cell =  self.cvFeedsPost.cellForItem(at: IndexPath(row: index, section: 0)) as? CommentCVCell {
               // if cell.videoView.state == .playing {
                    cell.pauseVideo()
                //}
            }
            index += 1
        }
    }
    
    //MARK: - Button Action Methods
    @IBAction func backButtonAction(){
        pauseAllVisiblePlayers()
        for obj in storyArray {
            do {
                if ((obj.mediaUrl as? URL) != nil){
                    if FileManager.default.fileExists(atPath: (obj.mediaUrl.path)) {
                        try FileManager.default.removeItem(at: obj.mediaUrl)
                        print("Media DEleted \(obj.mediaUrl.path)")
                    }
                }
            } catch let err as NSError {
                print("Not able to remove\(err)")
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addNewPost() {
        self.view.endEditing(true)
        pauseAllVisiblePlayers()
        if nudityContentsFound == true {
            self.showAlertForNudity()
        }else  if (UIApplication.shared.delegate as! AppDelegate).IsInternetconnected == true {
            if storyArray.count == 0 {
                
                AlertView.sharedManager.displayMessage(title: "", msg: "Please select image", controller: self)
            }else{
                wallPostStatusApi(mediaIndex: 0)
            }
        }else {
            let msg = "No Network Connection"
            self.view.makeToast(message: msg, duration: 3, position: HRToastActivityPositionDefault)
        }
    }
     
    
    @IBAction func imagePickerBtnAction(){
        if storyArray.count + uploadedCount >= Settings.sharedInstance.maxStatusUpload {
            
            AlertView.sharedManager.displayMessage(title: "", msg: "You have already selected \(Settings.sharedInstance.maxStatusUpload) images/video", controller: self)
        }else {
            self.showPicker()
        }
    }
    
    //MARK: Api Methods
    
    func wallPostStatusApi(mediaIndex:Int) {
        
        let strURL = storyArray[mediaIndex].mediaUrl.absoluteString as NSString
        self.fileName = strURL.lastPathComponent
        print(self.fileName)
        let params = NSMutableDictionary()
        params.setValue(storyArray[mediaIndex].statusMessage.trimmingLeadingAndTrailingSpaces(), forKey: "statusMessage")
        params.setValue(storyArray[mediaIndex].musicTitle, forKey: "soundTitle")
        params.setValue(storyArray[mediaIndex].statusMessage, forKey: "statusMessage")
        params.setValue(storyArray[mediaIndex].musicThumbUrl, forKey: "soundThumbUrl")
        params.setValue(storyArray[mediaIndex].musicId, forKey: "soundId")
        params.setValue(storyArray[mediaIndex].originalUrl, forKey: "soundUrl")
        
        var tagArr:Array<String> = Array<String>()
        if storyArray[mediaIndex].tagStory.count > 0 {
            for obj in storyArray[mediaIndex].tagStory {
                tagArr.append(obj["id"] as? String ?? "")
            }
            print("\(tagArr)")
            params.setValue(tagArr, forKey: "tagStory")
        }else{
            params.setValue(tagArr, forKey: "tagStory")
        }
        
        if checkMediaTypes(strUrl: strURL as String) == 3 {
            
            DispatchQueue.main.async {
                Themes.sharedInstance.activityView(View: self.view)
                
                URLhandler.sharedinstance.uploadWallStatus(fileName: "\(self.fileName)", param: params as! [String : AnyObject], file: self.storyArray[mediaIndex].mediaUrl, url: Constant.sharedinstance.uploadWallStatus, mimeType:"video/*"){
                    (msg,status,message, s3VideoUrl) in
                    
                    print(msg,status,message,s3VideoUrl)
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                    if status == "1"{
                        
                        self.checkAndDelete(indexOfCell: 0)
                    }
                    if self.storyArray.count == 0{
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: noti_RefreshStory), object:nil)
                        
                        if status == "1"{
                            
                            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: msg)
                            
                            self.navigationController?.popViewController(animated: true)
                            
                        }else {
                            AlertView.sharedManager.displayMessage(title: "", msg: msg, controller:  self)
                        }
                    }else {
                       
                        if status == "1"{
                            self.addNewPost()
                        }else{
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }else if checkMediaTypes(strUrl: strURL as String) == 1{
            
            DispatchQueue.main.async {
                Themes.sharedInstance.activityView(View: self.view)
                
                URLhandler.sharedinstance.uploadWallStatus(fileName: "\(self.fileName)", param: params as! [String : AnyObject], file: self.storyArray[mediaIndex].mediaUrl, url: Constant.sharedinstance.uploadWallStatus, mimeType: "image/*"){
                    (msg,status,message, s3VideoUrl) in
                    
                    print(msg,status,message,s3VideoUrl)
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                    if status == "1"{
                        self.checkAndDelete(indexOfCell: 0)
                    }
                    if self.storyArray.count == 0{
                        
                        if status == "1"{
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: noti_RefreshStory), object:nil)
                            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: msg)
                            
                            self.navigationController?.popViewController(animated: true)
                        }else{
                            AlertView.sharedManager.displayMessage(title: "", msg: msg, controller:  self)
                        }
                    }else {
                        if status == "1"{
                            self.addNewPost()
                        }else{
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }

}

extension CreateWallStatusVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func pauseAllVideos(){
        for cell in cvFeedsPost.visibleCells as! [CommentCVCell]{
            cell.pauseVideo()
        }
    }
    //MARK: - UICollectionview delegate and datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return storyArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommentCVCell", for: indexPath) as! CommentCVCell
        
        
        let storyObj:StoryUploadModel = storyArray[indexPath.item]
        
        cell.url = storyObj.mediaUrl.absoluteString
        
        cell.imgImageView.image = UIImage(contentsOfFile: storyObj.mediaUrl.path)
        //cell.btnTagUser.isHidden = true
        cell.btnAddMusic.tag = indexPath.row
        cell.btnTagUser.tag = indexPath.row
        
        cell.btnAddMusic.addTarget(self, action: #selector(addsoundBtn(_ : )), for: .touchUpInside)
        cell.btnTagUser.addTarget(self, action: #selector(tagUserBtn(_ : )), for: .touchUpInside)
        
        cell.btnTagUser.setImageTintColor(.white)
        cell.btnAddMusic.setImageTintColor(.white)

        cell.urlArray = storyArray.map({ obj in
            return obj.mediaUrl.absoluteString
        })
        cell.selIndex = indexPath.item
        
        if checkMediaTypes(strUrl:storyObj.mediaUrl.absoluteString) == 1 {
            cell.configureCell(isToHidePlayer: true, indexPath: indexPath)
            
        }else {
            cell.configureCell(isToHidePlayer: false, indexPath: indexPath)
            
            /*cell.mmPlayerLayer.currentPlayStatus = .pause
            cell.mmPlayerLayer.player?.pause()*/
            cell.pauseVideo()
        }
        
        cell.btnDelete.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        cell.btnDelete.tag = indexPath.item
        cell.btnDelete.addTarget(self, action: #selector(deleteSelectedMedia(_ : )), for: .touchUpInside)
        
        cell.txtFdComment.tag = indexPath.item
        cell.txtFdComment.delegate = self
        cell.txtFdComment.text =  storyObj.statusMessage
        
        var str:String =  storyObj.tagStory.compactMap { objDict in
            (objDict["pickzonId"] as? String ?? "")
        }.joined(separator:  " @")
        
        if str.count > 1{
            str =  "@" + str
        }
        
        cell.lblTaggedUser.attributedText = str.convertAttributtedColorText(linkAndMentionColor: .white)
        cell.lblTaggedUser.delegate = self
        cell.layoutIfNeeded()
        
        return cell
        
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width , height: collectionView.frame.width + 100)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.numberOfPages = storyArray.count
        self.pageControl.currentPage = indexPath.item
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        let indexPath = IndexPath(row: Int(pageNumber), section: 0)
        
        let cell = cvFeedsPost.cellForItem(at:indexPath)  as? CommentCVCell
       // cell?.mmPlayerLayer.currentPlayStatus = .pause
        //cell?.mmPlayerLayer.player?.pause()
        cell?.pauseVideo()
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        let indexPath = IndexPath(row: Int(pageNumber), section: 0)
        let cell = cvFeedsPost.cellForItem(at:indexPath) as? CommentCVCell
        
       //cell?.mmPlayerLayer.currentPlayStatus = .pause
        //cell?.mmPlayerLayer.player?.pause()
        
        cell?.pauseVideo()
    }
    
    //MARK: Selector Methods
    
    @objc func deleteSelectedMedia(_ sender:UIButton){
        
        AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to remove selected image/video", buttonTitles: ["Yes","No"], onController: self) { title, selIndex in
            
            if selIndex == 0{
                self.checkAndDelete(indexOfCell: sender.tag)
                
                
            }
        }
    }
    
    
    @objc func checkAndDelete(indexOfCell:Int){
        let indexPath = IndexPath(row: indexOfCell, section: 0)
        storyArray[indexPath.row].statusMessage = ""
        if let cell = cvFeedsPost.cellForItem(at:indexPath) as? CommentCVCell {
            //cell.mmPlayerLayer.currentPlayStatus = .pause
            //cell.mmPlayerLayer.player?.pause()
            cell.pauseVideo()
        }
        
        do {
            let url = URL(string: storyArray[indexPath.row].mediaUrl.absoluteString)
            if FileManager.default.fileExists(atPath: (url?.path)!) {
                try FileManager.default.removeItem(at: url!)
                print("Image DEleted")
            }
        } catch let err as NSError {
            print("Not able to remove\(err)")
        }
        
        self.storyArray.remove(at: indexOfCell)
        self.cvFeedsPost.reloadData()
        self.cvFeedsPost.layoutIfNeeded()
        self.pageControl.isHidden = (self.storyArray.count > 1) ? false : true

    }
    
    
    @objc func tagUserBtn(_ sender:UIButton){
        print("tagPeopleAction")
        selectedMediaIndex = sender.tag
        let viewController:TagPeopleViewController = StoryBoard.main.instantiateViewController(withIdentifier: "TagPeopleViewController") as! TagPeopleViewController
        viewController.tagPeopleDelegate = self
        viewController.arrSelectedUser = storyArray[sender.tag].tagStory
        viewController.limitToselectMax = 10
        self.navigationController?.pushView(viewController, animated: true)
    }
    
    @objc func addsoundBtn(_ sender: UIButton) {
        
        selectedMediaIndex = sender.tag
        if let cell = cvFeedsPost.cellForItem(at:IndexPath(row: selectedMediaIndex, section: 0)) as? CommentCVCell{
            //cell.mmPlayerLayer.currentPlayStatus = .pause
            //cell.mmPlayerLayer.player?.pause()
            cell.pauseVideo()
        }
        /*let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddSoundVC") as! AddSoundVC
         vc.onSongSelection = self
         vc.timeLimit = timerValue ?? 30
         vc.modalPresentationStyle = .fullScreen
         self.presentView(vc, animated: true)
         */
        
        let viewController:SpotifyCategoriesVC = StoryBoard.spotify.instantiateViewController(withIdentifier: "SpotifyCategoriesVC") as! SpotifyCategoriesVC
        viewController.onSongSelection = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}



// Support methods
extension CreateWallStatusVC:YPImagePickerDelegate {
    
    // MARK: - Configuration
    @objc
    func showPicker() {

        var config = YPImagePickerConfiguration()

        /* Uncomment and play around with the configuration 👨‍🔬 🚀 */

        /* Set this to true if you want to force the  library output to be a squared image. Defaults to false */
        // config.library.onlySquare = true

        /* Set this to true if you want to force the camera output to be a squared image. Defaults to true */
        // config.onlySquareImagesFromCamera = false

        /* Ex: cappedTo:1024 will make sure images from the library or the camera will be
           resized to fit in a 1024x1024 box. Defaults to original image size. */
        // config.targetImageSize = .cappedTo(size: 1024)

        /* Choose what media types are available in the library. Defaults to `.photo` */
        config.library.mediaType = .photoAndVideo
        config.library.itemOverlayType = .grid
        /* Enables selecting the front camera by default, useful for avatars. Defaults to false */
        // config.usesFrontCamera = true

        /* Adds a Filter step in the photo taking process. Defaults to true */
        // config.showsFilters = false

        /* Manage filters by yourself */
        // config.filters = [YPFilter(name: "Mono", coreImageFilterName: "CIPhotoEffectMono"),
        //                   YPFilter(name: "Normal", coreImageFilterName: "")]
        // config.filters.remove(at: 1)
        // config.filters.insert(YPFilter(name: "Blur", coreImageFilterName: "CIBoxBlur"), at: 1)

        /* Enables you to opt out from saving new (or old but filtered) images to the
           user's photo library. Defaults to true. */
        config.shouldSaveNewPicturesToAlbum = false
        config.isToCompressUsingThirdPartyLibrary = true
        /* Choose the videoCompression. Defaults to AVAssetExportPresetHighestQuality */
       // config.video.compression = AVAssetExportPresetPassthrough

        /* Choose the recordingSizeLimit. If not setted, then limit is by time. */
        // config.video.recordingSizeLimit = 10000000

        /* Defines the name of the album when saving pictures in the user's photo library.
           In general that would be your App name. Defaults to "DefaultYPImagePickerAlbumName" */
         config.albumName = "PickZon"

        /* Defines which screen is shown at launch. Video mode will only work if `showsVideo = true`.
           Default value is `.photo` */
        config.startOnScreen = .library

        /* Defines which screens are shown at launch, and their order.
           Default value is `[.library, .photo]` */
        config.screens = [.library, .photo, .video]

        /* Can forbid the items with very big height with this property */
        //config.library.minWidthForItem = UIScreen.main.bounds.width * 0.5

        /* Defines the time limit for recording videos.
           Default is 30 seconds. */
         config.video.recordingTimeLimit = Settings.sharedInstance.statusDuration

        /* Defines the time limit for videos from the library.
           Defaults to 60 seconds. */
        config.video.libraryTimeLimit = 600.0
        config.showsVideoTrimmer = true
        config.video.trimmerMaxDuration = Settings.sharedInstance.statusDuration
        
        /* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
        config.showsCrop = .none
        //config.showsCrop = .rectangle(ratio: (16/16))

        /* Changes the crop mask color */
         //config.colors.cropOverlayColor = .green

        /* Defines the overlay view for the camera. Defaults to UIView(). */
        // let overlayView = UIView()
        // overlayView.backgroundColor = .red
        // overlayView.alpha = 0.3
        // config.overlayView = overlayView

        /* Customize wordings */
        config.wordings.libraryTitle = "Gallery"
        /* Defines if the status bar should be hidden when showing the picker. Default is true */
        config.hidesStatusBar = false

        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false

        config.maxCameraZoomFactor = 2.0

        //config.library.maxNumberOfItems = 5
        
        config.library.maxNumberOfItems = Settings.sharedInstance.maxStatusUpload - uploadedCount
        if storyArray.count + uploadedCount < Settings.sharedInstance.maxStatusUpload {
           
            config.library.maxNumberOfItems = Settings.sharedInstance.maxStatusUpload - storyArray.count - uploadedCount
        }
        
        config.gallery.hidesRemoveButton = false
        config.video.fileType = .mp4
        config.video.compression = AVAssetExportPresetPassthrough
        
       // config.video = 30.0

        /* Disable scroll to change between mode */
        // config.isScrollToChangeModesEnabled = false
        // config.library.minNumberOfItems = 2

        /* Skip selection gallery after multiple selections */
        // config.library.skipSelectionsGallery = true

        /* Here we use a per picker configuration. Configuration is always shared.
           That means than when you create one picker with configuration, than you can create other picker with just
           let picker = YPImagePicker() and the configuration will be the same as the first picker. */

        /* Only show library pictures from the last 3 days */
        //let threDaysTimeInterval: TimeInterval = 3 * 60 * 60 * 24
        //let fromDate = Date().addingTimeInterval(-threDaysTimeInterval)
        //let toDate = Date()
        //let options = PHFetchOptions()
        // options.predicate = NSPredicate(format: "creationDate > %@ && creationDate < %@", fromDate as CVarArg, toDate as CVarArg)
        //
        ////Just a way to set order
        //let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        //options.sortDescriptors = [sortDescriptor]
        //
        //config.library.options = options

        config.library.preselectedItems = selectedItems
        config.onlySquareImagesFromCamera = false

        // Customise fonts
        //config.fonts.menuItemFont = UIFont.systemFont(ofSize: 22.0, weight: .semibold)
        //config.fonts.pickerTitleFont = UIFont.systemFont(ofSize: 22.0, weight: .black)
        //config.fonts.rightBarButtonFont = UIFont.systemFont(ofSize: 22.0, weight: .bold)
        //config.fonts.navigationBarTitleFont = UIFont.systemFont(ofSize: 22.0, weight: .heavy)
        //config.fonts.leftBarButtonFont = UIFont.systemFont(ofSize: 22.0, weight: .heavy)

        let picker = YPImagePicker(configuration: config)
        picker.imagePickerDelegate = self
        

        /* Change configuration directly */
        // YPImagePickerConfiguration.shared.wordings.libraryTitle = "Gallery2"

        /* Multiple media implementation */
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
                            print("saved Success")
                            
                            self.storyArray.append(StoryUploadModel(mediaUrl: fileURL, musicTitle: "", musicId: "", musicUrl: "", musicThumbUrl: "", statusMessage: "", tagStory: Array()))
                            
                            DispatchQueue.main.async {
                                self.cvFeedsPost.reloadData()
                            }


                        } catch {
                            print("error saving file to documents:", error)
                        }
                    }
                    
                case .video(let video):
                    print("=====video.url==\(video.url)")
                    self.storyArray.append(StoryUploadModel(mediaUrl: video.url, musicTitle: "", musicId: "", musicUrl: "", musicThumbUrl: "", statusMessage: "", tagStory: Array()))
                    DispatchQueue.main.async {
                        self.cvFeedsPost.reloadData()
                    }

                }
            }
            
            picker?.dismiss(animated: true, completion: nil)
            
            if Settings.sharedInstance.confidenceThreshold < 0.80 {
                self.checkNudityContent()
            }

            self.pageControl.isHidden = (self.storyArray.count > 1) ? false : true
           /*
            DispatchQueue.main.async {
                self.pageControl.numberOfPages = self.storyArray.count
                self.cvFeedsPost.reloadData()
                self.cvFeedsPost.layoutIfNeeded()
            }
            */
        }

        present(picker, animated: true, completion: nil)
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
                    DispatchQueue.main.async {
                        self.pageControl.numberOfPages = self.storyArray.count
                        self.cvFeedsPost.reloadData()
                        self.cvFeedsPost.layoutIfNeeded()
                    }
                
            }
        }
    }
    
    
    func checkNudityContent() {
        self.nudityContentsFound = false
        for index in 0..<storyArray.count {
            let objUrlString = (storyArray[index].mediaUrl.absoluteString) as NSString
            if checkMediaTypes(strUrl: storyArray[index].mediaUrl.absoluteString) == 1 {
                
                let imgView:UIImageView = UIImageView()
                imgView.image = UIImage(contentsOfFile: storyArray[index].mediaUrl.path)
                self.CheckNudityforImage(image: imgView.image!)
                
                
            }else {
                
                let url = storyArray[index].mediaUrl
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
    /* Gives a resolution for the video by URL */
    func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker) {
        // PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
    }

    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true // indexPath.row != 2
    }
}


extension CreateWallStatusVC:UITextFieldDelegate{
    
    //MARK: UItextField Delegate methods
    func textFieldDidEndEditing(_ textField: UITextField) {

        storyArray[textField.tag].statusMessage = textField.text ?? ""
        self.cvFeedsPost.reloadItems(at: [IndexPath(item: textField.tag , section: 0)])
        self.cvFeedsPost.layoutIfNeeded()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
        let previousText:NSString = textField.text! as NSString
        let updatedText = previousText.replacingCharacters(in: range, with: string)
        if updatedText.length>100{
            return false
        }
        return true
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension CreateWallStatusVC:onSongSelectionDelegate,onCancelClick,onDonePreviewClick,GalleryVideoDelegate,TagPeopleDelegate {
    //MARK: Tag People Delegate
    func tagPeopleDoneAction(arrTagPeople : Array<Dictionary<String, Any>>) {
        self.storyArray[selectedMediaIndex].tagStory = arrTagPeople
        self.cvFeedsPost.reloadData()
    }
    
    //MARK: onSongSelectionDelegate
    
    func onDone(soundID:String,url:URL,fileName:String){
        
        self.storyArray[selectedMediaIndex].mediaUrl = url

        self.cvFeedsPost.reloadData()
    }
    
    func onDismiss() {
        self.storyArray[selectedMediaIndex].musicId = ""
        self.storyArray[selectedMediaIndex].musicUrl = ""
        self.storyArray[selectedMediaIndex].musicTitle = ""
        self.storyArray[selectedMediaIndex].musicThumbUrl = ""
        self.storyArray[selectedMediaIndex].originalUrl = ""
    }
    
  
    
    func onSelection(id: String, url: String,name:String, timeLimit: Int,thumbUrl:String,originalUrl:String) {
        
        self.storyArray[selectedMediaIndex].musicId = id
        self.storyArray[selectedMediaIndex].musicUrl = url
        self.storyArray[selectedMediaIndex].musicThumbUrl = thumbUrl
        self.storyArray[selectedMediaIndex].musicTitle = name
        self.storyArray[selectedMediaIndex].originalUrl = originalUrl
            
       // PlayerHelper.shared.startAudioWithLocalFile(url: url)
        
        if  checkMediaTypes(strUrl: storyArray[selectedMediaIndex].mediaUrl.absoluteString) == 1{
            
          /*  let image:UIImage = UIImage(contentsOfFile: storyArray[selectedMediaIndex].mediaUrl.path) ?? UIImage()
            let fileName = "\(Int64(Date().timeIntervalSince1970))pickZone"
            VideoGenerator.fileName = fileName
            VideoGenerator.maxVideoLengthInSeconds = Settings.sharedInstance.statusDuration
            VideoGenerator.shouldOptimiseImageForVideo = false
            LoadingView.lockView()
                VideoGenerator.current.generate(withImages: [image,image,image], andAudios: [URL(fileURLWithPath: self.storyArray[selectedMediaIndex].musicUrl)], andType: .singleAudioMultipleImage, { (progress) in
                    print(progress)
                }) { (result) in
                    
                    switch result {
                    case .success(let url):
                        LoadingView.unlockView()
                        DispatchQueue.main.async {
                            let vc = StoryBoard.main.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
                            vc.url = url
                            vc.onCancel = self
                            vc.soundID = self.storyArray[self.selectedMediaIndex].musicId
                            vc.onDone = self
                            vc.fileName = fileName
                            vc.modalPresentationStyle = .fullScreen
                            self.navigationController?.presentView(vc, animated: true)
                        }
                    case .failure(let error):
                        print(error)
                        LoadingView.unlockView()
                    }
                }
            
            */
            
            LoadingView.lockView()
            
            let image:UIImage = UIImage(contentsOfFile: storyArray[selectedMediaIndex].mediaUrl.path) ?? UIImage()
            let fileName = "\(Int64(Date().timeIntervalSince1970))pickZone"
            let audio = AVURLAsset(url: URL(fileURLWithPath: url))
            let audioDuration = CMTime(seconds: Double(timeLimit), preferredTimescale: audio.duration.timescale)
            let timeRange:CMTimeRange = CMTimeRange(start: CMTime.zero, duration: audioDuration)
               
            let maker = VideoMaker(images: [image,image], transition: ImageTransition.crossFade)
            maker.contentMode = .scaleAspectFit
            maker.videoDuration = timeLimit
            maker.quarity = .default
            
            let imgSize:CGSize = image.size
                maker.movement = .none
            if imgSize.height > imgSize.width {
                let ratio = imgSize.height / imgSize.width
                let size  = CGSize(width: (UIScreen.ft_height()/ratio)*3, height: UIScreen.ft_height()*3)
                if size.height > imgSize.height {
                    maker.size = imgSize
                }else {
                    maker.size = size
                }
            }else {
                let ratio = imgSize.width / imgSize.height
                let size  = CGSize(width: UIScreen.ft_width()*3, height: (UIScreen.ft_width()/ratio)*3)
                if size.width > imgSize.width {
                    maker.size = imgSize
                }else {
                    maker.size = size
                }
            }
                print(maker.size)
            
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
                        
        }else{
            
            DispatchQueue.main.async {
                
                let videoAsset = AVAsset(url: self.storyArray[self.selectedMediaIndex].mediaUrl)
                let ObjMultiRecord:MultimediaRecord = MultimediaRecord()
                ObjMultiRecord.StartTime = 0.0
                ObjMultiRecord.FileSize = videoAsset.calculateFileSize()/1024/1024
                ObjMultiRecord.totalDuration = videoAsset.duration.seconds
                ObjMultiRecord.Endtime = videoAsset.duration.seconds
                ObjMultiRecord.assetname = (self.storyArray[self.selectedMediaIndex].mediaUrl.absoluteString as  NSString).lastPathComponent
                ObjMultiRecord.assetpathname = self.storyArray[self.selectedMediaIndex].mediaUrl.absoluteString
                
                let vc = StoryBoard.main.instantiateViewController(withIdentifier: "EditVideoVC") as! EditVideoVC
                vc.ObjMultimedia = ObjMultiRecord
                vc.delegateVideo = self
                vc.audioURL = self.storyArray[self.selectedMediaIndex].musicUrl
                vc.audioID = self.storyArray[self.selectedMediaIndex].musicId
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
    
    func mergeImageAndAudio(imageUrl: URL, audioURL: URL, outputURL: URL, completion: @escaping (URL?, Error?) -> Void) {
            let composition = AVMutableComposition()
    
           guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
                 let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
               completion(nil, NSError(domain: "com.example.video", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create composition tracks"]))
           return
            }
    
            do {
                let videoAsset = AVAsset(url: imageUrl)
                try videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .video)[0], at: .zero)
   
    
                let audioAsset = AVAsset(url: audioURL)
                try audioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: audioAsset.duration), of: audioAsset.tracks(withMediaType: .audio)[0], at: .zero)
            } catch {
                completion(nil, error)
                return
            }
    
            let videoComposition = AVMutableVideoComposition()
            videoComposition.frameDuration = CMTime(value: 1, timescale: 30) // Assuming 30 frames per second
            videoComposition.renderSize = videoTrack.naturalSize
    
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
    
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            instruction.layerInstructions = [layerInstruction]
    
            videoComposition.instructions = [instruction]
    
           let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
            exportSession?.outputURL = outputURL
            exportSession?.outputFileType = .mp4
           exportSession?.videoComposition = videoComposition
    
            exportSession?.exportAsynchronously {
                switch exportSession?.status {
                case .completed:
                    completion(outputURL, nil)
                case .failed, .cancelled:
                    completion(nil, exportSession?.error)
                default:
                    completion(nil, NSError(domain: "com.example.video", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown export session status"]))
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

                 if self.storyArray[self.selectedMediaIndex].musicUrl.length == 0{
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
                    
                    let audioURl = URL(fileURLWithPath: self.storyArray[self.selectedMediaIndex].musicUrl)
                    if  audioURl != nil {
                        DispatchQueue.main.async {

                            self.mergeVideoAndAudio(videoUrl: savePathUrl, audioUrl: audioURl, savePathUrl: savePathUrl) { error, url in
                                if url != nil {
                                    DispatchQueue.main.async {
                                        let vc = StoryBoard.main.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
                                        vc.url = url
                                        vc.onCancel = self
                                        vc.soundID = self.storyArray[self.selectedMediaIndex].musicId
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


extension  CreateWallStatusVC:ExpandableLabelDelegate{
  
    func hashTagTextClicked(_ label: ExpandableLabel, hashTag: String) {
        let destVc:WallPostViewVC = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
        destVc.controllerType = .hashTag
        destVc.hashTag = hashTag
        AppDelegate.sharedInstance.navigationController?.pushViewController(destVc, animated: true)
    }
    
    // MARK: ExpandableLabel Delegate
    func willExpandLabel(_ label: ExpandableLabel) {
 
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
    
    }
    
    
    func mentionTextClicked(_ label: ExpandableLabel,mentionText:String){
        
        print("mentionTextClicked \(mentionText)")
        
       // let mentionString:String = mentionText
       // self.getUserIdFromPickzonId(pickzonId: mentionString.replacingOccurrences(of: "@", with: ""))
    }
    

    
    func willCollapseLabel(_ label: ExpandableLabel) {
   
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
       
    }
    func urlTextClicked(_ label: ExpandableLabel,strURL:String) {
        
    }
    
    func numberTextClicked(_ label: ExpandableLabel, number: String) {
   
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
                        self.navigationController?.pushView(viewController, animated: true)
                    }
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
}


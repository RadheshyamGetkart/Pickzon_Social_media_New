//
//  PostClipVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 1/22/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Kingfisher
import Photos

protocol PostClipDelegate{
    func onSuccessClipUpload(clipObj:WallPostModel,selectedIndex:Int)
}


class PostClipVC: UIViewController {
    
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var thumbNailImgVw:UIImageView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var btnFollowers:UIButton!
    @IBOutlet weak var btnPublic:UIButton!
    @IBOutlet weak var btnPostVideo:UIButton!
    @IBOutlet weak var btnSaveVideo:UIButton!
    @IBOutlet weak var descTxtVw:IQTextView!
    @IBOutlet weak var btnSwitchShare:UISwitch!
    @IBOutlet weak var btnSwitchComment:UISwitch!
    @IBOutlet weak var btnSwitchDownload:UISwitch!
    var selectedIndex = 0
    var delegate:PostClipDelegate?
    var url:URL?
    var isEditVideoPost = false
    var arrTagPeople = Array<Dictionary<String, Any>>()
    var clipObj = WallPostModel(dict: [:])
    private var arrUrlDimension:[[String:String]] = []
    
    private var mediaArr = [URL]()
    
    //MARK: Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        btnPublic.isSelected = true
        btnPostVideo.roundCorners(.allCorners, radius: 5)
        btnSaveVideo.roundCorners(.allCorners, radius: 5)
        self.thumbNailImgVw.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleCoverTap(_:)))
        self.thumbNailImgVw.addGestureRecognizer(tap)
        updateData()
        descTxtVw.delegate = self
    }
    
    //MARK: Other Helpful Methods
    func updateData(){
        
        if isEditVideoPost{
                    
            self.btnPostVideo.setTitle("Update Video", for: .normal)
            self.url = URL(string: clipObj.urlArray.first ?? "")
            self.lblTitle.text = "Update Clip"
            thumbNailImgVw.kf.setImage(with: URL(string: clipObj.thumbUrlArray.first ?? ""), placeholder:PZImages.dummyCover , options: nil, progressBlock: nil, completionHandler: { response in  })
            descTxtVw.text = clipObj.payload
            
            for str in clipObj.tagArray {
                if str.count > 0 {
                    let dict = ["pickzonId" :str.replacingOccurrences(of: "@", with: "").trim()]
                    self.arrTagPeople.append(dict) }
            }
            
        }else{
            clipObj.isShare = 1
            clipObj.commentType = 0 // 0 for all 1 for not
            clipObj.isDownload = 1
            thumbNailImgVw.image = createThumbnailOfVideoFromFileURL(videoURL: url!.absoluteString)
            
                        
            if let mediaUrl = url {
                
                self.arrUrlDimension.append(["height":"\(Int(mediaUrl.getVideoSize()?.height ?? 0))", "width":"\(Int(mediaUrl.getVideoSize()?.width ?? 0))"])
                
                if mediaUrl.sizePerMB() > 4.0 {
                    DispatchQueue.main.async {
                        Themes.sharedInstance.activityView(View: self.view)
                    }
                    FYVideoCompressor().compressVideo(mediaUrl, quality: .highQuality) { [self] result in
                        DispatchQueue.main.async {
                            Themes.sharedInstance.RemoveactivityView(View: self.view)
                        }
                        
                        switch result {
                        case .success(let compressedVideoURL):
                            
                            self.mediaArr.append(compressedVideoURL)
                            print("file size After compression in MB: %f ", compressedVideoURL.sizePerMB())
                            
                            break

                        case .failure(let error):
                            print(error.localizedDescription)
                            mediaArr.append(mediaUrl)
                            break
                        }
                    }
                }else{
                    self.mediaArr.append(mediaUrl)
                }
            }
        }
        
        btnSwitchShare.isOn = (clipObj.isShare == 0) ? false : true
        btnSwitchComment.isOn = (clipObj.commentType == 1) ? false : true
        btnSwitchDownload.isOn = (clipObj.isDownload == 0) ? false : true
        descTxtVw.text = clipObj.payload
    }
    
    @objc func handleCoverTap(_ sender: UITapGestureRecognizer? = nil) {
        
        if isEditVideoPost == true {
            
            if let videoURL = URL(string: clipObj.urlArray.first ?? ""){
                let player = AVPlayer(url: videoURL)
                let playervc = AVPlayerViewController()
                playervc.player = player
                self.navigationController?.present(playervc, animated: true) {
                    playervc.player!.play()
                }
            }
            
        }else{
            
            if let videoURL = url{
                let player = AVPlayer(url: videoURL.absoluteURL)
                let playervc = AVPlayerViewController()
                playervc.player = player
                self.present(playervc, animated: true) {
                    playervc.player!.play()
                }
            }
        }
    }

    
    func createThumbnailOfVideoFromFileURL(videoURL: String) -> UIImage? {
        let asset = AVAsset(url: URL(string: videoURL)!)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(1), preferredTimescale: 100)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            return PZImages.dummyCover
        }
    }
    
    func requestAuthorization(completion: @escaping ()->Void) {
            if PHPhotoLibrary.authorizationStatus() == .notDetermined {
                PHPhotoLibrary.requestAuthorization { (status) in
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            } else if PHPhotoLibrary.authorizationStatus() == .authorized{
                completion()
            }
        }
    
    //MARK: UIButton Action Methods
    @IBAction func backButtonActionMethods(_ sender : UIButton){
        
        if isEditVideoPost == true {
           
            AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to go back ?", buttonTitles: ["Yes","No"], onController: (AppDelegate.sharedInstance.navigationController?.topViewController)!) { title, index in
                if index == 0{
                    self.navigationController?.popViewController(animated: true)
                }
            }
       
        }else {
            if let url = url{
                [url].removeSavedURLFiles()
            }
            
            AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure want to go back ?", buttonTitles: ["Yes","No"], onController: self) { title, index in
                if index == 0{
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }

    
    @IBAction func postVideoButtonActionMethods(_ sender : UIButton){
        self.view.endEditing(true)
        
        if isEditVideoPost == true {
            self.updateClipVideoApi()
        }else{
            
            let asset = AVAsset(url: url!)
            let seconds = CMTimeGetSeconds(asset.duration)
            if seconds < 3 {
                
            self.view.makeToast(message:"Minimum duration limit is 3 seconds.", duration: 3, position: HRToastActivityPositionDefault)

            }else if seconds > Settings.sharedInstance.clipDuration{
                self.view.makeToast(message:"Maximum duration limit is \(Int(Settings.sharedInstance.clipDuration)) seconds.", duration: 3, position: HRToastActivityPositionDefault)
            }else{
                self.uploadClipVideoApi()
            }
        }
    }
    
    @IBAction func saveDraftButtonActionMethods(_ sender : UIButton){
        
        requestAuthorization {
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .video, fileURL: self.url!, options: nil)
            }) { (result, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("Saved successfully")
                        let alertController = UIAlertController(title: "PickZon", message: "Draft saved successfully!", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            // self.backButtonActionMethods(sender)
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func followersButtonActionMethods(_ sender : UIButton){
        
        btnPublic.isSelected = false
        btnFollowers.isSelected = true
    }
    
    @IBAction func publicButtonActionMethods(_ sender : UIButton){
        
        btnPublic.isSelected = true
        btnFollowers.isSelected = false
    }
    
    @IBAction func tagButtonActionMethods(_ sender : UIButton){
        
        let destVC:TagPeopleViewController = StoryBoard.main.instantiateViewController(withIdentifier: "TagPeopleViewController") as! TagPeopleViewController
        destVC.tagPeopleDelegate = self
        destVC.arrSelectedUser = arrTagPeople
        AppDelegate.sharedInstance.navigationController?.pushViewController(destVC, animated: true)

    }
    
    
    @IBAction func  commentsSwitchAction(_ sender: UISwitch) {
        
        
        clipObj.commentType = (sender.isOn == true) ? 0 : 1
        
    }
    
    @IBAction func  sharingSwitchAction(_ sender: UISwitch) {
        clipObj.isShare = (sender.isOn == true) ? 1 : 0

    }
    
    @IBAction func  saveAndDownloadSwitchAction(_ sender: UISwitch) {
        clipObj.isDownload = (sender.isOn == true) ? 1 : 0

    }
    
    //MARK: Api Methods
    
    func updateClipVideoApi(){
                
        let params = NSMutableDictionary()
       
        params.setValue(self.clipObj.id, forKey: "feedId")
        params["isShare"] =   clipObj.isShare
        params["commentType"] =  clipObj.commentType
        params["isDownload"] =  clipObj.isDownload
        params.setValue(descTxtVw.text, forKey: "payload")
        params["hashTags"] = ""
        params["isClip"] = 1
        
        params.setValue(clipObj.urlArray, forKey: "url")
        //params.setValue(arrUrlDimension, forKey: "dimension")
        params.setValue(clipObj.urlDimensionArray, forKey: "dimension")
        params.setValue(clipObj.thumbUrlArray, forKey: "thumbUrl")
        
        if (clipObj.soundInfo?.id ?? "").count > 0{
            let songInfo = ["id":clipObj.soundInfo?.id ?? "" , "name":clipObj.soundInfo?.name ?? "" , "thumb": clipObj.soundInfo?.thumb ?? "", "url":clipObj.soundInfo?.audio ?? ""]
            params.setValue(songInfo, forKey: "soundInfo")
        }
        
        let words = (self.descTxtVw.text ?? "").components(separatedBy: CharacterSet.whitespacesAndNewlines)
        let arrHashTags = words.filter { $0.hasPrefix("#") }
        params["hashTags"] = arrHashTags.joined(separator: ",")
        
        var tagArr:Array<String> = Array()
        for obj in arrTagPeople {
            tagArr.append(obj["pickzonId"] as? String ?? "")
        }
        params["tag"] = tagArr
       
        DispatchQueue.main.async {
            Themes.sharedInstance.activityView(View: self.view)
        }
       
        URLhandler.sharedinstance.makePostAPICall(url:Constant.sharedinstance.updateFeedPost, param: params , methodType: .put) {(responseObject, error) ->  () in
       
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
            }
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    
                                     
                    DispatchQueue.main.async {
                        AppDelegate.sharedInstance.navigationController?.view.makeToast(message:message, duration: 1, position: HRToastActivityPositionDefault)
                    }
                    
                    self.clipObj.payload = self.descTxtVw.text
                    self.delegate?.onSuccessClipUpload(clipObj: self.clipObj, selectedIndex: self.selectedIndex)
                    self.navigationController?.popViewController(animated: true)
                    
                }else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
        
    }
   
    
    func uploadClipVideoApi(){
        
        let params = NSMutableDictionary()
        params["isShare"] =   clipObj.isShare
        params["commentType"] =  clipObj.commentType
        params["isDownload"] =  clipObj.isDownload
        params.setValue(descTxtVw.text, forKey: "payload")
        params["hashTags"] = ""
        params["isClip"] = 1
        
        let songInfo = ["id":clipObj.soundInfo?.id ?? "" , "name":clipObj.soundInfo?.name ?? "" , "thumb": clipObj.soundInfo?.thumb ?? "", "url":clipObj.soundInfo?.audio ?? "" ]

        params.setValue(songInfo, forKey: "soundInfo")
        
        let words = (self.descTxtVw.text ?? "").components(separatedBy: CharacterSet.whitespacesAndNewlines)
        let arrHashTags = words.filter { $0.hasPrefix("#") }
        params["hashTags"] = arrHashTags.joined(separator: ",")
        
        var tagArr:Array<String> = Array()
        for obj in arrTagPeople {
            tagArr.append(obj["pickzonId"] as? String ?? "")
        }
        params["tag"] = tagArr
   
        DispatchQueue.main.async {
            Themes.sharedInstance.activityView(View: self.view)
        }
        
     /*   var mediaArr = [URL]()
        
        if let mediaUrl = url {
            
            if mediaUrl.sizePerMB() > 4.0 {
                
                self.arrUrlDimension.append(["height":"\(Int(mediaUrl.getVideoSize()?.height ?? 0))", "width":"\(Int(mediaUrl.getVideoSize()?.width ?? 0))"])
                params.setValue(self.arrUrlDimension, forKey: "dimension")
                
                FYVideoCompressor().compressVideo(mediaUrl, quality: .highQuality) { result in
                    switch result {
                    case .success(let compressedVideoURL):
                        
                        mediaArr.append(compressedVideoURL)
                        print("file size After compression in MB: %f ", compressedVideoURL.sizePerMB())
                        //[mediaUrl].removeSavedURLFiles()
                        self.uploadMediaApi(mediaArr: mediaArr, paramDict: params)
                        break

                    case .failure(let error):
                        print(error.localizedDescription)
                        mediaArr.append(mediaUrl)
                        self.uploadMediaApi(mediaArr: mediaArr, paramDict: params)
                        break
                    }
                }
            }else{
                mediaArr.append(mediaUrl)
                self.uploadMediaApi(mediaArr: mediaArr, paramDict: params)
            }
        }
        */
        self.uploadMediaApi(mediaArr: mediaArr, paramDict: params)

    }

    
    func uploadMediaApi(mediaArr:[URL],paramDict:NSMutableDictionary){
        
        URLhandler.sharedinstance.uploadArrayOfMediaWithParameters(thumbUrlArray: [Any](), mediaArray:mediaArr , mediaName: "media", url: Constant.sharedinstance.addNewPost, params: paramDict , isToCallProgress: false) {(responseObject, error) ->  () in
          
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
            }
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    
                    if let mediaUrl = self.url {
                        [mediaUrl].removeSavedURLFiles()
                    }
                    mediaArr.removeSavedURLFiles()
                    DispatchQueue.main.async {
                        AppDelegate.sharedInstance.navigationController?.view.makeToast(message:message, duration: 1, position: HRToastActivityPositionDefault)
                    }
                    self.navigationController?.popToRootViewController(animated: true)
                  
                }else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
    }
}



extension PostClipVC:TagPeopleDelegate,UITextViewDelegate{
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        textView.text = (textView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let previousText:NSString = textView.text! as NSString
        let updatedText = previousText.replacingCharacters(in: range, with: text)
        
        if updatedText.length > 180 {
            return false
        }        
        return true
    }
    
    func tagPeopleDoneAction(arrTagPeople : Array<Dictionary<String, Any>>) {
        self.arrTagPeople = arrTagPeople
        
        // for obj in arrTagPeople {
        //
        //  if let index = self.arrTagPeople.firstIndex(where:{ $0["pickzonId"] as? String ?? "" == obj["pickzonId"] as? String ?? "" }) {
        //    self.arrTagPeople.remove(at: index)
        //     }
        // }
    }
}

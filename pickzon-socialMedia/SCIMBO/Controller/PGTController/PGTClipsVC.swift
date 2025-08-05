//
//  PGTClipsVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 09/07/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import FittedSheets
import AVKit
import AVFoundation
import Alamofire

class PGTClipsVC: UIViewController {

    @IBOutlet weak var pgtClipImgView:UIImageView!
    @IBOutlet weak var lblHashTitlePgt:UILabel!
    @IBOutlet weak var lblPoweredBy:UILabel!
    @IBOutlet weak var lblTotalViews:UILabel!
    @IBOutlet weak var btnRulesAndGuidelines:UIButton!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnCreateVideo:UIButton!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var lblNavTitle:UILabel!

    var listArray = [WallPostModel]()
    var isDataLoading = false
    var isDataMoreAvailable = false
    var pageNo = 1
    var pgtObj = PGTModel(respDict: [:])
    var guidelineVideoURL = ""
    var guidelines = ""
    var audioUrl = ""
    var audioThumbUrl = ""
    var audioName = ""

    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        registerCell()
        btnCreateVideo.layer.cornerRadius = btnCreateVideo.frame.size.height/2.0
        btnCreateVideo.clipsToBounds = true
        lblTotalViews.text = pgtObj.totalViews.asFormatted_k_String + " Plays"
        lblHashTitlePgt.text =  pgtObj.title
        lblNavTitle.text = pgtObj.title
        getGuidelinesApi()
        getHashTagVideosApi()
    }
    
    //MARKK: Other Helpful Methods
    func registerCell(){
        tblView.register(UINib(nibName: "BusinessMediaTblCell", bundle: nil), forCellReuseIdentifier: "BusinessMediaTblCell")
        tblView.register(UINib(nibName: "LoadMoreTblCell", bundle: nil),
                          forCellReuseIdentifier: "LoadMoreTblCell")
    }
    
    //MARK: UIButton action methods

    @IBAction func backButtonActionMethods(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createVideoButtonActionMethods(_ sender : UIButton){
        
        downloadAndPush()
    
    }
    
    @IBAction func videoButtonActionMethods(_ sender : UIButton){
        
         let vc = StoryBoard.premium.instantiateViewController(withIdentifier: "VideoPlayerVC") as! VideoPlayerVC
         vc.videoURL = guidelineVideoURL
         vc.strTitle = "How To Participate"
         AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
    }

    
    @IBAction func rulesAndGuidelinesButtonActionMethods(_ sender : UIButton){
        
        if #available(iOS 13.0, *) {
            
            let controller = StoryBoard.promote.instantiateViewController(identifier: "GuideLinesVC")
            as! GuideLinesVC
            controller.isHtmlText = guidelines
            controller.title = ""
            let useInlineMode = view != nil
            let nav = UINavigationController(rootViewController: controller)
            let sheet = SheetViewController(
                controller: nav,
                sizes: [.percent(0.55),.intrinsic],
                options: SheetOptions(presentingViewCornerRadius : 0 , useInlineMode: useInlineMode))
            sheet.allowGestureThroughOverlay = false
            sheet.cornerRadius = 20
            
            if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
                sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
            } else {
                (AppDelegate.sharedInstance.navigationController?.topViewController)?.present(sheet, animated: true, completion: nil)
            }
        } else {
            // Fallback on earlier versions
        }
    }
        
//        
//        let vc:PKLegendVC = StoryBoard.letGo.instantiateViewController(withIdentifier: "PKLegendVC") as! PKLegendVC
//        self.navigationController?.pushView(vc, animated: true)
//    }
    
    //MARK: Api methods
    
    
    func downloadAndPush(){
        
        DispatchQueue.main.async {
            
            if URLhandler.sharedinstance.isConnectedToNetwork() == true {
                
                if let url = URL(string:self.audioUrl){
                    
                  
                    let documentsURL = Themes.sharedInstance.getLocalURLForAudioFileServerURL(Url: url)
                    print("Audio File URL :",documentsURL)
                    if !FileManager.default.fileExists(atPath: documentsURL.path)
                    {
                        let destination: DownloadRequest.Destination = { _, _ in
                            return (documentsURL, [.removePreviousFile])
                        }
                        
                        Themes.sharedInstance.activityView(View: self.view)
                        
                        AF.download(self.audioUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil, to: destination).downloadProgress(queue: DispatchQueue.global(qos: .background)) {
                            (progress) in
                            // print("Completed Progress: \(progress.fractionCompleted)")
                            //print("Totaldddd Progress: \(progress.completedUnitCount)....\(url)")
                            
                            
                        }.validate().responseData { ( response ) in
                            Themes.sharedInstance.RemoveactivityView(View: self.view)
                            DispatchQueue.main.async {
                                switch response.result {
                                    
                                case .success(_):
                                    print("success")
                                    
                                    let audioAsset = AVURLAsset.init(url: documentsURL, options: nil)
                                    let duration = audioAsset.duration
                                    let durationInSeconds = CMTimeGetSeconds(duration)
                                    
                                    
                                    let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "RecordVideoVC") as! RecordVideoVC
                                    destVC.audioId = ""
                                    destVC.audioName = self.audioName
                                    destVC.audioURL = documentsURL.path
                                    destVC.audioOriginalURL = self.audioUrl
                                    destVC.timerValue = Int(durationInSeconds)
                                    destVC.hashTag = self.pgtObj.title
                                    self.navigationController?.pushViewController(destVC, animated: true)
                                    
                                case let .failure(error):
                                    print("\(error.localizedDescription)")
                                }
                            }
                        }
                    }
                    else
                    {
                        
                        let audioAsset = AVURLAsset.init(url: documentsURL, options: nil)
                        let duration = audioAsset.duration
                        let durationInSeconds = CMTimeGetSeconds(duration)
                        
                        
                        let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "RecordVideoVC") as! RecordVideoVC
                        destVC.audioId = ""
                        destVC.audioName = self.audioName
                        destVC.audioURL = documentsURL.path
                        destVC.audioOriginalURL = self.audioUrl
                        destVC.timerValue = Int(durationInSeconds)
                        destVC.hashTag = self.pgtObj.title
                        self.navigationController?.pushViewController(destVC, animated: true)
                    }
                }
                else
                {
                    let vc = StoryBoard.main.instantiateViewController(withIdentifier: "RecordVideoVC") as! RecordVideoVC
                    vc.hashTag = self.pgtObj.title
                    vc.audioName = self.audioName
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }else {
                
            }
        }
        
    }
    func getGuidelinesApi(){
        
        let strUrl = "\(Constant.sharedinstance.hash_tag_guidelines)?hashTag=\(pgtObj.title)"

        URLhandler.sharedinstance.makeGetCall(url: strUrl, param: [:]) {(responseObject, error) ->  () in
            
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int ?? 0
                _ = result["message"]
                
                if status == 1 {
                    
                    if let payload = result["payload"] as? Dictionary<String,Any> {
                        
                       if let totalViews = payload["totalViews"] as? Int{
                            self.lblTotalViews.text = totalViews.asFormatted_k_String + " Plays"
                        }
                       
                        if  let guidelineVideo = payload["guidelineVideo"] as? Dictionary<String,Any> {
                            
                            self.guidelineVideoURL = guidelineVideo["url"] as? String ?? ""
                            let thumbUrl = guidelineVideo["thumbUrl"] as? String ?? ""
                            self.pgtClipImgView.kf.setImage(with:  URL(string: thumbUrl))
                            
                            self.audioUrl = guidelineVideo["audioUrl"] as? String ?? ""
                            self.audioThumbUrl = guidelineVideo["audioThumbUrl"] as? String ?? ""
                            self.audioName = guidelineVideo["audioName"] as? String ?? ""

                        }
                        if  let guideline = payload["guideline"] as? String {
                            self.guidelines = guideline
                        }
                    }
                }
            }
        }
    }
    
        
    /*func getHashTagVideosApi(){
        
        self.isDataLoading = true
    
        let param = ["type":"hashTag","keyword":pgtObj.title,"pageNumber":pageNo, "pageLimit":18] as [String : Any]
        
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.SearchKeyWord, param: param as NSDictionary, completionHandler: {(responseObject, error) ->  () in
            if(error != nil)
            {
                //Themes.sharedInstance.RemoveactivityView(View: self.view)
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                self.isDataLoading = false
                
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 1{
                    
                    let data = result.value(forKey: "payload") as? NSArray ?? []
                    for d in data
                    {
                        self.listArray.append(WallPostModel(dict: d as? NSDictionary ?? [:]))
                    }
                    self.isDataMoreAvailable = (data.count > 9) ? true : false
                    self.pageNo = self.pageNo + 1
                    
                    self.tblView.reloadAnimately{}
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.isDataLoading = false
                    }
                    
                }else{
                    self.isDataLoading = false
                    // Themes.sharedInstance.RemoveactivityView(View: self.view)
                }
            }
        })
    }
    */

     //MARK: -  API's Methods
     func getHashTagVideosApi(){
         self.isDataLoading = true
    
         let  url = "\(Constant.sharedinstance.getFeedVideosURL as String)?pageNumber=\(self.pageNo)&hashtag=\(pgtObj.title)"

         URLhandler.sharedinstance.makeGetAPICall(url:url, param: NSMutableDictionary(), completionHandler: {(responseObject, error) ->  () in
            
             
             if(error != nil)
             {
                 DispatchQueue.main.async {
                     self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                     print(error ?? "defaultValue")
                 }
             }else{
                 
                 let result = responseObject! as NSDictionary
                 let status = result["status"] as? Int ?? 0
                 let message = result["message"] as? String ?? ""
                
                 if status == 1 {
                 
                     let data = result.value(forKey: "payload") as? NSArray ?? []
                     for d in data
                     {
                         self.listArray.append(WallPostModel(dict: d as? NSDictionary ?? [:]))
                     }
                     self.isDataMoreAvailable = (data.count > 9) ? true : false
                     self.pageNo = self.pageNo + 1
                     
                     self.tblView.reloadAnimately{}
                     DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                         self.isDataLoading = false
                     }
                     
                 } else {
                     DispatchQueue.main.async {
                         self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                     }
                     self.isDataLoading = false
                 }
             }
         })
         
     }
}


extension PGTClipsVC:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
                
        if (indexPath.section == 0) {
            let width = CGFloat(self.view.frame.size.width/3.0 + 70)
            let divide =  CGFloat(listArray.count/3) * width
            var  remainder = CGFloat(listArray.count % 3) * width
            if  (listArray.count % 3) > 0 && listArray.count % 3 < 3{
                remainder = width
            }else{
                remainder = 0
            }
            return  CGFloat(divide + remainder)
        }
        
        return 60   
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return 1
        }else if section == 1{
            if (listArray.count > 14) && isDataMoreAvailable == true {
                return 1
            }
        }
        
        return 0
    }
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1{
            //Loading cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreTblCell", for: indexPath) as! LoadMoreTblCell
            cell.activityIndicator.startAnimating()
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessMediaTblCell") as! BusinessMediaTblCell
        cell.setCollectionLayout()
        cell.isClipsVideo = true
        cell.isToHideOption = true
        cell.wallPostArray = listArray
        cell.delegate = self
        cell.cllctnVw.reloadWithoutAnimation()
        cell.cllctnVw.isScrollEnabled = false
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if !(URLhandler.sharedinstance.isConnectedToNetwork()){
            
            self.view.makeToast(message: "No network connection" , duration: 2, position: HRToastActivityPositionDefault)
            
        }else  if isDataLoading == false && indexPath.section == 1 {
            isDataLoading = true
          self.getHashTagVideosApi()
        }
    }

}


extension PGTClipsVC: BusinessMediaDelegate{
    
    func clickedMediaWith(index:Int, parentIndex:Int){
        let vc =
        StoryBoard.feeds.instantiateViewController(withIdentifier: "FeedsVideoViewController") as! FeedsVideoViewController
        vc.firstVideoIndex = index
        vc.playingIndex = index
       // vc.arrFeedsVideo =  [listArray[index]]
        vc.objWallPost = listArray[index]
        vc.isHashTagVideos = true
        vc.hashTag = pgtObj.title
        vc.videoType = .feed
        vc.isClipVideo = true
        //vc.pageNo = self.pageNo
        self.navigationController?.pushViewController(vc, animated: true)
    }
   
}

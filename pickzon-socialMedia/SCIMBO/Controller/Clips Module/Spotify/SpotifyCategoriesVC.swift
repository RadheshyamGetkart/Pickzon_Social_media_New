//
//  SpotifyCategoriesVC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 8/23/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit
import Alamofire
import IQKeyboardManager

protocol onSongSelectionDelegate: AnyObject {
    func onSelection(id:String,url:String,name:String, timeLimit: Int, thumbUrl:String,originalUrl:String)
}

class SpotifyCategoriesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SPCategoryProtocol,UISearchBarDelegate {
    
    @IBOutlet weak var tblCategories:UITableView!
    @IBOutlet weak var sbSearchbar:UISearchBar!
    @IBOutlet weak var btnUseSong:UIButton!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var btnLibrary:UIButton!
    @IBOutlet weak var btnSaved:UIButton!
    @IBOutlet weak var lblSelection:UILabel!
    var isSaved = false
    
    var arrItems:Array<SpotifyCategory> = Array()
    var arrTopTrending:Array<SPTrack> = Array()
    var arrFeatured:Array<SPPlayList> = Array()
    
    var arrSearched:Array<SPTrack> = Array()
    var arrSaved:Array<SPTrack> = Array()
    
    var isSearched = false
    
    var offset:Int64 = 0
    var limit:Int64 = 10
    var total:Int64 = -1
    
    var playIndex = -1
    var playSection = -1
    
    var playlistId =   "37i9dQZF1DXcBWIGoYBM5M"
    

    weak var onSongSelection:onSongSelectionDelegate?

    var isFirtTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        btnUseSong.layer.cornerRadius = 5.0
        btnUseSong.layer.borderColor = UIColor.lightGray.cgColor
        btnUseSong.layer.borderWidth = 1.0
        btnUseSong.isHidden = true
        
        tblCategories.register(UINib(nibName: "SPCategoryPlayListCell", bundle: nil), forCellReuseIdentifier: "SPCategoryPlayListCell")
        tblCategories.register(UINib(nibName: "SPCategoryCell", bundle: nil), forCellReuseIdentifier: "SPCategoryCell")
        
        let attrString = NSMutableAttributedString(string: "Search Song")
        attrString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)], range: NSRange(location: 0, length: attrString.length))
        sbSearchbar.searchTextField.attributedPlaceholder = attrString
        sbSearchbar.searchTextField.textColor = UIColor.gray
        sbSearchbar.searchTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        sbSearchbar.searchTextField.tintColor = UIColor.gray
        if let leftView = sbSearchbar.searchTextField.leftView as? UIImageView {
            leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
            leftView.tintColor = UIColor.lightGray
        }
        
        let clearButton = sbSearchbar.searchTextField.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        clearButton.tintColor = UIColor.lightGray
        
        // self.fetchsTracklist(isTopTrending: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        
        self.fetchsMusicToken()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        super.viewWillDisappear(animated)
    }
    
    
    @IBAction func backButtonAction(){
        PlayerHelper.shared.pausePlayer()
        self.dismissView(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func libraryButtonAction() {
        sbSearchbar.text = ""
        sbSearchbar.resignFirstResponder()
        self.isSearched = false
        
        DispatchQueue.main.async {
            self.playIndex = -1
            self.playSection = -1
            self.btnUseSong.isHidden = true
            PlayerHelper.shared.pause()
            
            self.isSaved = false

            self.lblSelection.translatesAutoresizingMaskIntoConstraints = true
            self.lblSelection.frame = CGRect(x: self.btnLibrary.frame.origin.x + 10 , y: self.lblSelection.frame.origin.y, width: self.btnLibrary.frame.width, height: self.lblSelection.frame.height)
            self.tblCategories.reloadData()
        }
        
    }
    @IBAction func savedButtonAction(){
        sbSearchbar.text = ""
        sbSearchbar.resignFirstResponder()
        self.isSearched = false
        
        DispatchQueue.main.async {
            self.playIndex = -1
            self.playSection = -1
            self.btnUseSong.isHidden = true
            PlayerHelper.shared.pause()
            
            self.isSaved = true
            
            self.lblSelection.translatesAutoresizingMaskIntoConstraints = true
            self.lblSelection.frame = CGRect(x: self.btnSaved.frame.origin.x + 10, y: self.lblSelection.frame.origin.y, width: self.btnSaved.frame.width, height: self.lblSelection.frame.height)
            if self.arrSaved.count > 0 {
                self.tblCategories.reloadData()
            }else{
                self.showSaveListAction()
            }
            
        }
    }
    
    
     func showSaveListAction() {
        
        Themes.sharedInstance.activityView(View: self.view)
        let url = Constant.sharedinstance.getSavedAudioURL
        print("url : ", url)
        let param:NSDictionary = [:]
        URLhandler.sharedinstance.makePostAPICall(url:url, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
            }
            else{
                let result = responseObject! as NSDictionary
                let errNo = result["errNum"] as! String
                let message = result["message"]
                print(result)
                if errNo == "99"{
                    
                    
                    let soundAry = result.value(forKey: "result") as? Array<Dictionary<String, Any>> ?? []
                    for obj in soundAry {
                        self.arrSaved.append(SPTrack.init(dictSong: obj))
                    }
                    
                    self.tblCategories.reloadData()
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    
    func fetchsMusicToken()  {
        
        Themes.sharedInstance.activityView(View: self.view)
        let params = NSMutableDictionary()
        
        
        let param = ""
        
        let url = "\(Constant.sharedinstance.getmusictokenURL)\(param)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        URLhandler.sharedinstance.makeGetAPICall(url:url , param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int64 ?? 0
                let message = result["message"] as? String ?? ""
                if status == 1{
                    
                    let  payload = result["payload"] as? Dictionary<String, Any> ?? [:]
                    let token = payload["token"] as? String ?? ""
                    if token.length > 0 {
                        Themes.sharedInstance.saveSpotifyToken(token: token)
                    }
                    if self.isFirtTime == true {
                        self.isFirtTime = false
                    self.fetchsTracklist()
                    }
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    
    func fetchsTracklist()  {
        
        Themes.sharedInstance.activityView(View: self.view)
        let params = NSMutableDictionary()
        let locale: NSLocale = NSLocale.current as NSLocale
        let countryCode: String = locale.countryCode ?? ""
                    
        let param = "?playlistId=\(playlistId)&limit=\(limit)&offset=\(offset)&country=\(countryCode)&locale=\(locale.languageCode)"
        
        let url = "\(Constant.sharedinstance.spotifyTrackByPlaylistIdURL)\(param)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        URLhandler.sharedinstance.makeGetAPICall(url:url , param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int64 ?? 0
                let message = result["message"] as? String ?? ""
                if status == 1{
                    
                    let payload = result["payload"] as? Dictionary ?? [:]
                    
                    //let tracks = payload["tracks"] as? Dictionary<String, Any> ?? [:]
                    let items = payload["items"] as? Array<Dictionary<String, Any>> ?? []
                    
                    for obj in items {
                        let track = obj["track"] as? Dictionary<String, Any> ?? [:]
                        if (track["preview_url"] as? String ?? "").length > 0 {
                        self.arrTopTrending.append(SPTrack.init(dict: track))
                        }
                    }
                    
                    self.tblCategories.reloadData()
                    self.fetchSpotifyCategories()
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    func fetchSpotifyCategories()  {
        
        Themes.sharedInstance.activityView(View: self.view)
        let params = NSMutableDictionary()
        
        
        let locale: NSLocale = NSLocale.current as NSLocale
        let countryCode: String = locale.countryCode ?? ""
        let languageCode = locale.languageCode
        
        let param = "?limit=\(10)&offset=\(0)&country=\(countryCode)&locale=\(languageCode)"
        let url = "\(Constant.sharedinstance.spotifyCategoriesURL)\(param)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        URLhandler.sharedinstance.makeGetAPICall(url:url , param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int64 ?? 0
                let message = result["message"] as? String ?? ""
                if status == 1{
                    
                    let payload = result["payload"] as? Dictionary ?? [:]
                    let categories = payload["categories"] as? Dictionary<String, Any> ?? [:]
                    self.offset = categories["offset"] as? Int64 ?? 0
                    self.limit = categories["limit"] as? Int64 ?? 0
                    self.total = categories["total"] as? Int64 ?? 0
                    
                    let items = categories["items"] as? Array<Dictionary<String, Any>> ?? []
                    
                    for obj in items {
                        self.arrItems.append(SpotifyCategory.init(dict: obj))
                    }
                    
                    print(self.arrItems)
                    
                    
                    self.tblCategories.reloadData()
                    
                     self.fetchFeaturedPlaylist()
                    
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    func fetchFeaturedPlaylist ()  {
        
        Themes.sharedInstance.activityView(View: self.view)
        let params = NSMutableDictionary()
        let locale: NSLocale = NSLocale.current as NSLocale
        let countryCode: String = locale.countryCode ?? ""
        let languageCode = locale.languageCode
        let param = "?offset=0&limit=10&country=\(countryCode)&locale=\(languageCode)"
        
        let url = "\(Constant.sharedinstance.featuredPlaylistURL)\(param)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        URLhandler.sharedinstance.makeGetAPICall(url:url , param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int64 ?? 0
                let message = result["message"] as? String ?? ""
                if status == 1{
                    let payload = result["payload"] as? Dictionary ?? [:]
                    let playlists = payload["playlists"] as? Dictionary<String, Any> ?? [:]
                    let items = playlists["items"] as? Array<Dictionary<String, Any>> ?? []
                    
                    for obj in items {
                        self.arrFeatured.append(SPPlayList.init(dict: obj))
                    }
                    self.tblCategories.reloadData()
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    func fetchsSearchlist()  {
        
        Themes.sharedInstance.activityView(View: self.view)
        let params = NSMutableDictionary()
        let locale: NSLocale = NSLocale.current as NSLocale
        let countryCode: String = locale.countryCode ?? ""
        
        let param = "?searchValue=\(self.sbSearchbar.text ?? "")&type=track&offset=0&limit=50&market=\(countryCode)"
        
        let url = "\(Constant.sharedinstance.spotifySearchURL)\(param)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        URLhandler.sharedinstance.makeGetAPICall(url:url , param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int64 ?? 0
                let message = result["message"] as? String ?? ""
                if status == 1{
                    
                    let payload = result["payload"] as? Dictionary ?? [:]
                    
                    
                    
                    let tracks = payload["tracks"] as? Dictionary<String, Any> ?? [:]
                    let items = tracks["items"] as? Array<Dictionary<String, Any>> ?? []
                    self.offset = tracks["offset"] as? Int64 ?? 0
                    self.limit = tracks["limit"] as? Int64 ?? 0
                    self.total = tracks["total"] as? Int64 ?? 0
                    
                    for obj in items {
                        if (obj["preview_url"] as? String ?? "").length > 0 {
                            self.arrSearched.append(SPTrack.init(dict: obj))
                        }
                    }
                    self.isSaved = false
                    self.tblCategories.reloadData()
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    @IBAction func useSongAction() {
        if playIndex == -1 {
            return
        }
        
        
        DispatchQueue.main.async {
            
            if URLhandler.sharedinstance.isConnectedToNetwork() == true {
                
                var objTracks:SPTrack?
                if self.isSaved == true {
                    objTracks = self.arrSaved[self.playIndex]
                }else if self.isSearched == true {
                    objTracks = self.arrSearched[self.playIndex]
                }else if self.playSection == 0 {
                    objTracks = self.arrTopTrending[self.playIndex]
                }
                
                
                
                let aurdioUrl = objTracks?.preview_url ?? ""
                let titlename = objTracks?.name ?? ""
                
                
                let Url:URL? = URL(string:aurdioUrl)
                
                if(Url != nil)
                {
                    
            
                    let documentsURL = Themes.sharedInstance.getLocalURLForAudioFileServerURL(Url: Url)
                    
                    if !FileManager.default.fileExists(atPath: documentsURL.path)
                    {
                        let destination: DownloadRequest.Destination = { _, _ in
                            return (documentsURL, [.removePreviousFile])
                        }
                        
                        
                        if Themes.sharedInstance.getAuthToken().length == 0  && Themes.sharedInstance.Getuser_id().length > 0{
                            AlertView.sharedManager.displayMessageWithAlert(title: "Your session is expired!", msg: "Please login again.")
                            AppDelegate.sharedInstance.Logout()
                            return
                        }
                        
                        print("Destintion ==\(String(describing: destination))")
                        Themes.sharedInstance.activityView(View: self.view)
                        
                        AF.download("\(aurdioUrl)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil, to: destination).downloadProgress(queue: DispatchQueue.global(qos: .background)) {
                            (progress) in
                            // print("Completed Progress: \(progress.fractionCompleted)")
                            //print("Totaldddd Progress: \(progress.completedUnitCount)....\(url)")
                            
                            
                        }.validate().responseData { ( response ) in
                            Themes.sharedInstance.RemoveactivityView(View: self.view)
                            DispatchQueue.main.async {
                                switch response.result {
                                    
                                case .success(_):
                                    print("success")
                                   // self.showViewTrimAudio()
                                    
                                    
                                    let destVc:TrimAudioVC = StoryBoard.main.instantiateViewController(withIdentifier: "TrimAudioVC") as! TrimAudioVC
                                    destVc.modalPresentationStyle = .overCurrentContext
                                    destVc.modalTransitionStyle = .coverVertical
                                    destVc.audioUrl = aurdioUrl
                                    destVc.audioId = objTracks?.id ?? ""
                                    destVc.audioName = titlename
                                    destVc.delegate = self
                                    if  let arrIcons = objTracks?.images {
                                        if arrIcons.count > 0 {
                                            destVc.audiothumbImgUrl = arrIcons[0]["url"] as? String ?? ""
                                        }
                                    }
                                   // self.present(destVc, animated: true, completion: nil)
                                   // self.pushView(destVc, animated: false)
                                    //self.navigationController?.present(destVc, animated: true, completion: {
                                        
                                    //})
                                    self.navigationController?.pushViewController(destVc, animated: true)
                                    return
                                    
                                    
//                                    let documentsURL = Themes.sharedInstance.getLocalURLForAudioFileServerURL(Url: URL(string: aurdioUrl))
//                                    
//                                    if FileManager.default.fileExists(atPath: documentsURL.path) {
//                                        self.trimAudioExportAsset(AVAsset(url: URL(fileURLWithPath: documentsURL.path)), fileName: titlename)
//                                    }
                                    
                                case let .failure(error):
                                    print("Failed")
                                }
                            }
                        }
                    }
                    else
                    {
                        // completionHandler(nil, nil)
                        //self.showViewTrimAudio()
                        
                        
                        let destVc:TrimAudioVC = StoryBoard.main.instantiateViewController(withIdentifier: "TrimAudioVC") as! TrimAudioVC
                        destVc.modalPresentationStyle = .overCurrentContext
                        destVc.modalTransitionStyle = .coverVertical
                        destVc.audioUrl = aurdioUrl
                        destVc.delegate = self
                        destVc.audioId = objTracks?.id ?? ""
                        destVc.audioName = titlename
                        if  let arrIcons = objTracks?.images {
                            if arrIcons.count > 0 {
                                destVc.audiothumbImgUrl = arrIcons[0]["url"] as? String ?? ""
                            }
                        }
                       // self.present(destVc, animated: true, completion: nil)
                       // self.pushView(destVc, animated: false)
                        /*self.navigationController?.present(destVc, animated: true, completion: {
                            
                        })*/
                        self.navigationController?.pushViewController(destVc, animated: true)
                        
                        return
                    }
                }
                else
                {
                    /* DispatchQueue.main.async {
                     self.Delegate?.ReturnDownloadProgress(id: id, Dict: [:],status: "0")
                     }*/
                }
                
            }
            
            else {
                /*DispatchQueue.main.async {
                 self.Delegate?.ReturnDownloadProgress(id: id, Dict: [:],status: "0")
                 }*/
            }
        }
        
    }
    func trimAudioExportAsset(_ asset: AVAsset, fileName: String) {
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let trimmedSoundFileURL = documentsDirectory.appendingPathComponent("fileName"+"\(Int(Date().timeIntervalSince1970))"+".m4a")
        print("saving to \(trimmedSoundFileURL.path)")
        if FileManager.default.fileExists(atPath: trimmedSoundFileURL.path) {
            print("sound exists, removing \(trimmedSoundFileURL.path)")
            do {
                if try trimmedSoundFileURL.checkResourceIsReachable() {
                    print("is reachable")
                }
                try FileManager.default.removeItem(atPath: trimmedSoundFileURL.absoluteString)
            } catch {
                print("could not remove \(trimmedSoundFileURL)")
                print(error.localizedDescription)
                Themes.sharedInstance.RemoveactivityView(View: self.view)
            }
        }
        
        if let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) {
            exporter.outputFileType = AVFileType.m4a
            exporter.outputURL = trimmedSoundFileURL
            let duration = CMTimeGetSeconds(asset.duration)
            //let duration = rangeSlider1.upperValue - rangeSlider1.lowerValue
            if duration < Float64(5.0) {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                print("sound is not long enough")
                self.view.makeToast("Sound is not long enough")
                return
            }
            let startTime = CMTimeMake(value: 0, timescale: 1)
            let stopTime = CMTimeMake(value: Int64(duration), timescale: 1)
            
            //let startTime = CMTimeMake(value: Int64(rangeSlider1.lowerValue), timescale: 1)
            //let stopTime = CMTimeMake(value: Int64(rangeSlider1.upperValue), timescale: 1)
            
            
            
            exporter.timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: stopTime)
            exporter.exportAsynchronously(completionHandler: {
                switch exporter.status {
                case  AVAssetExportSession.Status.failed:
                    if let e = exporter.error {
                        DispatchQueue.main.async {
                            Themes.sharedInstance.RemoveactivityView(View: self.view)
                            self.view.makeToast("export failed \(e)")
                        }
                    }
                case AVAssetExportSession.Status.cancelled:
                    DispatchQueue.main.async {
                        Themes.sharedInstance.RemoveactivityView(View: self.view)
                        self.view.makeToast("export cancelled \(String(describing: exporter.error))")
                    }
                default:
                    print("Success")
                    
                    
                    var objTracks:SPTrack?
                    if self.isSaved == true {
                        objTracks = self.arrSaved[self.playIndex]
                    }else  if self.isSearched == true {
                        objTracks = self.arrSearched[self.playIndex]
                    }else if self.playSection == 0 {
                        objTracks = self.arrTopTrending[self.playIndex]
                    }
                    
                    
                    let id = objTracks?.id ?? ""
                    let aurdioUrl = objTracks?.preview_url ?? ""
                    let titlename = objTracks?.name ?? ""
                    
                    
                    let documentsURL = Themes.sharedInstance.getLocalURLForAudioFileServerURL(Url: URL(string: aurdioUrl))
                    
                    
                    if FileManager.default.fileExists(atPath: documentsURL.path) {
                        do {
                            if try documentsURL.checkResourceIsReachable() {
                                print("is reachable")
                            }
                            try FileManager.default.removeItem(atPath: documentsURL.path)
                        } catch {
                            print("could not remove \(documentsURL)")
                            
                        }
                    }
                    
                    
                    let audio_path = trimmedSoundFileURL.path
                    if audio_path.length > 0 {
                        self.onSongSelection?.onSelection(id: id, url: audio_path, name: titlename, timeLimit: Int(duration), thumbUrl: (objTracks?.images.last?["url"] as? String ?? ""), originalUrl: aurdioUrl)
                    }
                    DispatchQueue.main.async {
                        for controller in self.navigationController!.viewControllers as Array {
                            if controller.isKind(of: CreateWallStatusVC.self) {
                                self.navigationController!.popToViewController(controller, animated: true)
                                break
                            }else  if controller.isKind(of: CreateWallPostViewController.self) {
                                self.navigationController!.popToViewController(controller, animated: true)
                                break
                            }
                        }
                       
                      //  self.backButtonAction()
                    }
                }
            })
        } else {
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                self.view.makeToast("cannot create AVAssetExportSession for asset \(asset)")
            }}
    }
    
    @IBAction func playPauseAction() {
        
        let indexPath = IndexPath(row: playIndex, section: playSection)
        
        if PlayerHelper.shared.isPaused == true {
            PlayerHelper.shared.playPlayer()
            
            DispatchQueue.main.async {
                if let  cell = self.tblCategories.cellForRow(at: indexPath) as? SPCategoryPlayListCell {
                    cell.btnPlayPause.setImage(UIImage(named: "ic_pause_circle_filled"), for: .normal)
                    
                    cell.btnPlayPause.isHidden = false
                    cell.btnSave.isHidden = true
                    cell.lblName.textColor = CustomColor.sharedInstance.themeColor
                   
                    if self.isSaved == true {
                        cell.btnSave.isHidden = false
                    }
                }
            }
            
        }else {
            PlayerHelper.shared.pause()
            DispatchQueue.main.async {
                if let  cell = self.tblCategories.cellForRow(at: indexPath) as? SPCategoryPlayListCell {
                    cell.btnPlayPause.setImage(UIImage(named: "ic_play_circle_filled"), for: .normal)
                    cell.btnPlayPause.isHidden = false
                    cell.btnSave.isHidden = true
                    cell.lblName.textColor =  UIColor.label //CustomColor.sharedInstance.themeColor
                    
                    if self.isSaved == true {
                        cell.btnSave.isHidden = false
                    }
                    
                }
            }
        }
        
        
        
        
    }
    
    
    
    @IBAction func saveSongAction(sender:UIButton) {
        if isSaved == true {
            //remove the saved song
            self.playIndex = -1
            self.playSection = -1
            self.btnUseSong.isHidden = true
            PlayerHelper.shared.pause()
            
            let obj = arrSaved[sender.tag]
            self.removeSavedAudioAPI(soundId: obj.id, row: sender.tag)
        }
    }
    
    func removeSavedAudioAPI(soundId:String, row:Int) {
        var url = Constant.sharedinstance.deleteAudioURL
        
        Themes.sharedInstance.activityView(View: self.view)
        let params = NSMutableDictionary()
        params.setValue(soundId, forKey: "soundId")
         
        URLhandler.sharedinstance.makePostAPICall(url:url , param: params, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let errNo = result["errNum"] as? String ?? ""
                let message = result["message"] as? String ?? ""
                if errNo == "99"{
                    self.arrSaved.remove(at: row)
                    self.tblCategories.reloadData()
                    
                    AlertView.sharedManager.displayMessage(title: "PickZon", msg: message, controller: self)
                    
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    
    func categorySelected(index:Int){
        PlayerHelper.shared.pause()
        
        let viewController:SPCategoriesPlayListVC = StoryBoard.spotify.instantiateViewController(withIdentifier: "SPCategoriesPlayListVC") as! SPCategoriesPlayListVC
        let objSpotifyCategory = arrItems[index]
        viewController.category =  objSpotifyCategory.id
        viewController.strTitle = objSpotifyCategory.name
        viewController.onSongSelection = self.onSongSelection
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    //MARK:- TableView Data source and Delegates
    func numberOfSections(in tableView: UITableView) -> Int  {
        if isSearched == true || isSaved == true{
            return 1
        }else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSaved == true {
            return arrSaved.count
        }else if isSearched == true {
            return arrSearched.count
        }else {
            if section == 0 {
                return arrTopTrending.count
            }else if section == 1 {
                return 1
            }else  {
                return arrFeatured.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SPCategoryPlayListCell", for: indexPath) as! SPCategoryPlayListCell
            cell.selectionStyle = .none
            
            
            var objTracks:SPTrack!
           if isSaved == true {
               objTracks = arrSaved[indexPath.row]
           }else if isSearched == true {
               objTracks = arrSearched[indexPath.row]
           }else  if indexPath.section == 0 {
               objTracks = arrTopTrending[indexPath.row]
           }
           if isSaved == true {
               let url = objTracks.thum
               cell.imgPlayList.kf.setImage(with: URL(string: "\(url)"), placeholder: PZImages.dummyCover, options: [.fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: { (resp) in
               })
               cell.lblName.text = objTracks.name
               cell.lblDescription.text = objTracks.description
               
           }else {
               let arrIcons = objTracks.images
               if arrIcons.count > 0 {
                   let icon = arrIcons[0]
                   let url = icon["url"] as? String ?? ""
                   cell.imgPlayList.kf.setImage(with: URL(string: "\(url)"), placeholder: PZImages.dummyCover, options: [.fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: { (resp) in
                   })
               }
               cell.lblName.text = objTracks.name
               cell.lblDescription.text = ""
               for str in objTracks.artists {
                   if cell.lblDescription.text?.length == 0 {
                       cell.lblDescription.text = str["name"] as? String ?? ""
                   }else {
                       cell.lblDescription.text = (cell.lblDescription!.text ?? "") + ", " + (str["name"] as? String  ?? "")
                   }
               }
           }
            if indexPath.row == playIndex && indexPath.section == playSection{
                cell.lblName.textColor = CustomColor.sharedInstance.themeColor
                cell.btnPlayPause.isHidden = false
                if isSaved == true {
                    cell.btnSave.isHidden = false
                    cell.btnSave.setImage(UIImage(named: "menu_delete"), for: .normal)
                }else {
                    cell.btnSave.setImage(UIImage(named: "feedsSavePost"), for: .normal)
                    cell.btnSave.isHidden = true
                }
                
            }else {
                if isSaved == true {
                    cell.btnSave.isHidden = false
                    cell.btnSave.setImage(UIImage(named: "menu_delete"), for: .normal)
                }else {
                    cell.btnSave.setImage(UIImage(named: "feedsSavePost"), for: .normal)
                    cell.btnSave.isHidden = true
                }
                
                cell.lblName.textColor = UIColor.label
                cell.btnPlayPause.isHidden = true
                
            }
           cell.btnSave.tag = indexPath.row
            cell.btnPlayPause.addTarget(self, action:#selector(self.playPauseAction), for: .touchUpInside)
            cell.btnSave.addTarget(self, action:#selector(self.saveSongAction(sender:)), for: .touchUpInside)
           
            
            return cell
            
        }else if indexPath.section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SPCategoryPlayListCell", for: indexPath) as! SPCategoryPlayListCell
            cell.selectionStyle = .none
            
            
            var objTracks:SPPlayList = arrFeatured[indexPath.row]
            
            
            let arrIcons = objTracks.images
            if arrIcons.count > 0 {
                let icon = arrIcons[0]
                let url = icon["url"] as? String ?? ""
                cell.imgPlayList.kf.setImage(with: URL(string: "\(url)"), placeholder: PZImages.dummyCover, options: [.fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: { (resp) in
                })
            }
            cell.btnPlayPause.isHidden = true
            cell.btnSave.isHidden = true
            
            
            cell.lblName.text = objTracks.name
            cell.lblDescription.text = objTracks.description
            cell.lblName.textColor = UIColor.label
            return cell
            
        }else   { //Spotify categories
            let cell = tableView.dequeueReusableCell(withIdentifier: "SPCategoryCell", for: indexPath) as! SPCategoryCell
            cell.selectionStyle = .none
            cell.arrItems = self.arrItems
            cell.clnView.reloadData()
            cell.objSPCategoryDelegate = self
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 150
        }else {
            return 69
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0  {
            var objTracks:SPTrack?
            if isSaved == true {
                objTracks = arrSaved[indexPath.row]
            }else if isSearched == true {
                objTracks = arrSearched[indexPath.row]
            }else if indexPath.section == 0 {
                objTracks = arrTopTrending[indexPath.row]
            }
            let aurdioURl = objTracks?.preview_url ?? ""
            if aurdioURl.hasPrefix("http"){
                PlayerHelper.shared.startAudio(url: "\(aurdioURl)".replacingOccurrences(of: "%20", with: " "))
                if playIndex != -1 && playSection != -1 {
                    if playIndex != indexPath.row  || playSection != indexPath.section{
                        
                        let indPath = IndexPath(row: playIndex, section: playSection)
                        DispatchQueue.main.async {
                            if let cell = tableView.cellForRow(at: indPath) as? SPCategoryPlayListCell  {
                                if self.isSaved == true {
                                    cell.btnPlayPause.isHidden = true
                                    cell.btnSave.isHidden = false
                                }else {
                                cell.btnPlayPause.isHidden = true
                                cell.btnSave.isHidden = true
                                }
                                cell.lblName.textColor = UIColor.label
                            }
                        }
                        
                        PlayerHelper.shared.pause()
                    }
                }
                
                playIndex = indexPath.row
                playSection = indexPath .section
                
                
                btnUseSong.isHidden = false
                self.playPauseAction()
            }
        }else if indexPath.section == 2 {
            let viewController:SPTrackVC = StoryBoard.spotify.instantiateViewController(withIdentifier: "SPTrackVC") as! SPTrackVC
            let objPlaylist = arrFeatured[indexPath.row]
            viewController.playlistId =  objPlaylist.id
            viewController.strTitle = objPlaylist.name
            viewController.onSongSelection = self.onSongSelection
           self.navigationController?.pushViewController(viewController, animated: true)
           //self.pushView(viewController, animated: true)
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        headerView.backgroundColor = UIColor.systemBackground
        let label = UILabel()
        let btnSeeeAll = UIButton()
        
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width/2, height: headerView.frame.height-10)
        if isSaved {
            label.text = "Saved"
            btnSeeeAll.setTitle("", for: .normal)
        }else  if isSearched == true {
            label.text = "Searched Result"
            btnSeeeAll.setTitle("", for: .normal)
        }else  if section == 0 {
            if arrTopTrending.count > 0 {
                label.text = "Top Trending"
                btnSeeeAll.setTitle("See More", for: .normal)
            }else {
                label.text = ""
                btnSeeeAll.setTitle("", for: .normal)
            }
            
        }else if section == 1 {
            if arrItems.count > 0 {
                label.text = "Genres"
                btnSeeeAll.setTitle("See More", for: .normal)
            }else {
                btnSeeeAll.setTitle("", for: .normal)
                btnSeeeAll.setTitle("", for: .normal)
            }
        }else if section == 2 {
            if arrFeatured.count > 0 {
                label.text = "Featured"
                btnSeeeAll.setTitle("See More", for: .normal)
            }else {
                label.text = ""
                btnSeeeAll.setTitle("", for: .normal)
            }
        }
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .label
        headerView.addSubview(label)
        
        if label.text?.length ?? 0 > 0 {
            label.isHidden = false
        }else {
            label.isHidden = true
        }
        if btnSeeeAll.titleLabel?.text?.length  ?? 0 > 0 {
            btnSeeeAll.isHidden = false
        }else {
            btnSeeeAll.isHidden = true
        }
        
        btnSeeeAll.tag = section
        btnSeeeAll.frame = CGRect.init(x: headerView.frame.width - 100, y: 5, width: 100, height: headerView.frame.height-10)
        btnSeeeAll.addTarget(self, action: #selector(self.seeAllAction(sender:)), for: .touchUpInside)
        btnSeeeAll.setTitleColor(CustomColor.sharedInstance.lightBlueColor, for: .normal)
        btnSeeeAll.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        headerView.addSubview(btnSeeeAll)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    @objc func seeAllAction(sender:UIButton){
        if sender.tag == 0 {
            let viewController:SPTrackVC = StoryBoard.spotify.instantiateViewController(withIdentifier: "SPTrackVC") as! SPTrackVC
            viewController.playlistId =  self.playlistId
            viewController.strTitle = "Top Trending"
            viewController.onSongSelection = self.onSongSelection
           // self.navigationController?.pushViewController(viewController, animated: true)
            self.pushView(viewController, animated: true)

        }else if sender.tag == 1 {
            PlayerHelper.shared.pause()
            
            let viewController:SPCategoriesAllViewController = StoryBoard.spotify.instantiateViewController(withIdentifier: "SPCategoriesAllViewController") as! SPCategoriesAllViewController
            viewController.onSongSelection = self.onSongSelection
            //self.navigationController?.pushViewController(viewController, animated: true)
            self.pushView(viewController, animated: true)

            
        }else if sender.tag == 2 {
            PlayerHelper.shared.pause()
            
            let viewController:SPCategoriesPlayListVC = StoryBoard.spotify.instantiateViewController(withIdentifier: "SPCategoriesPlayListVC") as! SPCategoriesPlayListVC
            viewController.category =  ""
            viewController.strTitle = "Featured"
            viewController.isFeatured = true
            viewController.onSongSelection = self.onSongSelection
           // self.navigationController?.pushViewController(viewController, animated: true)
            self.pushView(viewController, animated: true)

        }
        
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        PlayerHelper.shared.pause()
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        print(searchBar.searchTextField.text)
        isSaved = false
        
        self.arrSearched.removeAll()
        sbSearchbar.resignFirstResponder()
        
        PlayerHelper.shared.pause()
        playIndex = -1
        playSection = -1
        btnUseSong.isHidden = true
        
        if (searchBar.searchTextField.text ?? "").length > 0 {
            isSearched = true
            self.fetchsSearchlist()
        }else {
            isSearched = false
            tblCategories.reloadData()
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchBar.text)
        if (searchBar.searchTextField.text ?? "").length == 0 {
            isSearched = false
            
            PlayerHelper.shared.pause()
            playIndex = -1
            playSection = -1
            btnUseSong.isHidden = true
            
            sbSearchbar.resignFirstResponder()
            tblCategories.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.arrSearched.removeAll()
        isSearched = false
        sbSearchbar.text = ""
        sbSearchbar.resignFirstResponder()
        
        tblCategories.reloadData()
    }
    
}


extension SpotifyCategoriesVC:TrimAudioDelegate{
    func dismissTrimAudio()
    {
        
    }
    func selectedTrimmedAudio(id:String,audioPath:String,audioName:String,timeLimit:Int, thumbImageUrl:String,originalUrl:String){
        
        if audioPath.length > 0 {
             self.onSongSelection?.onSelection(id: id, url: audioPath, name: audioName, timeLimit: timeLimit, thumbUrl: thumbImageUrl,originalUrl:originalUrl)
         }
        
        /*DispatchQueue.main.async {
            for controller in (self.navigationController?.viewControllers ?? []) as Array {
                if controller.isKind(of: CreateWallStatusVC.self) {
                    self.navigationController!.popToViewController(controller, animated: false)
                    break
                }else  if controller.isKind(of: CreateWallPostViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: false)
                    break
                }else if controller.isKind(of: RecordVideoVC.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }else if controller.isKind(of: YPBottomPager.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
            }
        }*/
    }
}

class SpotifyCategory{
    var  icons:Array<Dictionary<String,Any>>
    var id:String = ""
    var name:String = ""
    init(dict:Dictionary<String, Any>){
        self.icons = dict["icons"] as? Array<Dictionary<String, Any>> ?? Array()
        self.id = dict["id"] as? String ?? ""
        self.name = dict["name"] as? String ?? ""
    }
}


protocol SPCategoryProtocol: AnyObject{
    func categorySelected(index:Int)
}

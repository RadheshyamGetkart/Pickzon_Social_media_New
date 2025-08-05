//
//  SPTrackVC.swift
//  SCIMBO
//
//  Created by gurmukh singh on 8/23/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class SPTrackVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var tblTrackList:UITableView!
    @IBOutlet weak var btnUseSong:UIButton!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!

    var strTitle = ""
    var playlistId = ""
    var offset:Int64 = 0
    var limit:Int64 = 20
    var total:Int64 = -1
    var arrItems:Array<SPTrack> = Array()
    var arrSearched:Array<SPTrack> = Array()
    var isLoading = false
    var isSearched = false
    
    var playIndex = -1
    var playSection = -1
    weak var onSongSelection:onSongSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        btnUseSong.layer.cornerRadius = 5.0
        btnUseSong.layer.borderColor = UIColor.lightGray.cgColor
        btnUseSong.layer.borderWidth = 1.0
        btnUseSong.isHidden = true
        
        self.lblTitle.text = strTitle
        tblTrackList.register(UINib(nibName: "SPCategoryPlayListCell", bundle: nil), forCellReuseIdentifier: "SPCategoryPlayListCell")
        
        // Do any additional setup after loading the view.
        self.fetchsTracklist()
    }
    
    
    @IBAction func backButtonAction(){
        PlayerHelper.shared.pausePlayer()
        self.navigationController?.popViewController(animated: true)
    }
    
    func fetchsTracklist()  {
        
        if arrItems.count != self.total {
        isLoading = true
        Themes.sharedInstance.activityView(View: self.view)
        let params = NSMutableDictionary()
        let locale: NSLocale = NSLocale.current as NSLocale
        let countryCode: String = locale.countryCode ?? ""
            offset = Int64(self.arrItems.count)
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
                    
                    let categories = payload["categories"] as? Dictionary<String, Any> ?? [:]
                    self.offset = payload["offset"] as? Int64 ?? 0
                    self.limit = payload["limit"] as? Int64 ?? 0
                    self.total = payload["total"] as? Int64 ?? 0
                    
                    //let tracks = payload["tracks"] as? Dictionary<String, Any> ?? [:]
                    if  let items = payload["items"] as? Array<Dictionary<String, Any>>  {
                    
                    for obj in items {
                        let track = obj["track"] as? Dictionary<String, Any> ?? [:]
                        if (track["preview_url"] as? String ?? "").length > 0 {
                        self.arrItems.append(SPTrack.init(dict: track))
                        }else {
                           // self.arrItems.append(SPTrack.init(dict: [:]))
                        }
                    }
                    }else {
                        self.total = Int64(self.arrItems.count)
                    }
                    self.tblTrackList.reloadData()

                    self.isLoading = false
                }
                else
                {
                    self.isLoading = false
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
            
        }
        //isLoading = false
    }
    
    @IBAction func playPauseAction() {
        
        let indexPath = IndexPath(row: playIndex, section: playSection)
        
        if PlayerHelper.shared.isPaused == true {
            PlayerHelper.shared.playPlayer()
            
            DispatchQueue.main.async {
                if let  cell = self.tblTrackList.cellForRow(at: indexPath) as? SPCategoryPlayListCell {
                    cell.btnPlayPause.setImage(UIImage(named: "ic_pause_circle_filled"), for: .normal)
                    cell.btnPlayPause.isHidden = false
                    cell.btnSave.isHidden = true
                cell.lblName.textColor =  CustomColor.sharedInstance.themeColor
                }
            }
            
        }else {
            PlayerHelper.shared.pause()
            DispatchQueue.main.async {
                if let  cell = self.tblTrackList.cellForRow(at: indexPath) as? SPCategoryPlayListCell {
                    cell.btnPlayPause.setImage(UIImage(named: "ic_play_circle_filled"), for: .normal)
                    cell.btnPlayPause.isHidden = false
                    cell.btnSave.isHidden = true
                cell.lblName.textColor = UIColor.label // CustomColor.sharedInstance.themeColor
                }
            }
        }
        
        
    }
    
    @IBAction func useSongAction() {
        DispatchQueue.main.async {
            
            if URLhandler.sharedinstance.isConnectedToNetwork() == true {
                
                var objTracks:SPTrack? = self.arrItems[self.playIndex]
                if self.isSearched == true {
                    objTracks = self.arrSearched[self.playIndex]
                }else if self.playSection == 0 {
                    objTracks = self.arrItems[self.playIndex]
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
                                    //self.showViewTrimAudio()
                                    
                                    let destVc:TrimAudioVC = StoryBoard.main.instantiateViewController(withIdentifier: "TrimAudioVC") as! TrimAudioVC
                                    destVc.modalPresentationStyle = .overCurrentContext
                                    destVc.modalTransitionStyle = .coverVertical
                                    destVc.audioUrl = aurdioUrl
                                    destVc.audioId = objTracks?.id ?? ""
                                    destVc.audioName = titlename
                                    if  let arrIcons = objTracks?.images {
                                        if arrIcons.count > 0 {
                                            destVc.audiothumbImgUrl = arrIcons[0]["url"] as? String ?? ""
                                        }
                                    }
                                    destVc.delegate = self

                                    //self.present(destVc, animated: true, completion: nil)
                                    //self.navigationController?.present(destVc, animated: true, completion: {
                                        
                                    //})
                                    self.navigationController?.pushViewController(destVc, animated: true)
                                    return
//                                    
//                                    let documentsURL = Themes.sharedInstance.getLocalURLForAudioFileServerURL(Url: URL(string: aurdioUrl))
//                                    
//                                    if FileManager.default.fileExists(atPath: documentsURL.path) {
//                                        self.trimAudioExportAsset(AVAsset(url: URL(fileURLWithPath: documentsURL.path)), fileName: titlename)
//                                     }
                                    
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
                        destVc.audioId = objTracks?.id ?? ""
                        destVc.audioName = titlename
                        if  let arrIcons = objTracks?.images {
                            if arrIcons.count > 0 {
                                destVc.audiothumbImgUrl = arrIcons[0]["url"] as? String ?? ""
                            }
                        }
                        destVc.delegate = self
                       // self.present(destVc, animated: true, completion: nil)
                        self.navigationController?.present(destVc, animated: true, completion: {
                            
                        })
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
                    if self.isSearched == true {
                        objTracks = self.arrSearched[self.playIndex]
                    }else  {
                        objTracks = self.arrItems[self.playIndex]
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
                        self.onSongSelection?.onSelection(id: id, url: audio_path, name: titlename, timeLimit: Int(duration), thumbUrl: (objTracks?.images.last?["url"] as? String ?? ""),originalUrl:aurdioUrl)
                    }
                    
                    
                    
                    DispatchQueue.main.async {
                        
                        for controller in self.navigationController!.viewControllers as Array {
                            if controller.isKind(of: CreateWallStatusVC.self) {
                                self.navigationController!.popToViewController(controller, animated: true)
                                break
                            }else  if controller.isKind(of: CreateWallPostViewController.self) {
                                self.navigationController!.popToViewController(controller, animated: true)
                                break
                            }else if controller.isKind(of: RecordVideoVC.self){
                                self.navigationController?.popToViewController(controller, animated: true)
                                return
                            }
                        }
                      
                    }
                    
                    
            }
            })
        } else {
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
            self.view.makeToast("cannot create AVAssetExportSession for asset \(asset)")
        }}
    }
    
    
    @IBAction func saveSongAction() {
    }
  
   
    

    //MARK:- TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return arrItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SPCategoryPlayListCell", for: indexPath) as! SPCategoryPlayListCell
        cell.selectionStyle = .none
        
        let objTracks = arrItems[indexPath.row]
        
        let arrIcons = objTracks.images
        if arrIcons.count > 0 {
            let icon = arrIcons[0]
            let url = icon["url"] as? String ?? ""
            cell.imgPlayList.kf.setImage(with: URL(string: "\(url)"), placeholder: PZImages.dummyCover, options: [.fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: { (resp) in
            })
        }
        if indexPath.row == playIndex {
            cell.lblName.textColor = CustomColor.sharedInstance.themeColor
            cell.btnPlayPause.isHidden = false
            cell.btnSave.isHidden = true
        }else {
            cell.lblName.textColor = UIColor.label
            cell.btnPlayPause.isHidden = true
            cell.btnSave.isHidden = true
        }
        
        cell.btnPlayPause.addTarget(self, action:#selector(self.playPauseAction), for: .touchUpInside)
        cell.btnSave.addTarget(self, action:#selector(self.saveSongAction), for: .touchUpInside)
        cell.lblName.text = objTracks.name
        cell.lblDescription.text = ""
        for str in objTracks.artists {
            if cell.lblDescription.text?.length == 0 {
                cell.lblDescription.text = str["name"] as? String ?? ""
            }else {
                cell.lblDescription.text = (cell.lblDescription!.text ?? "") + ", " + (str["name"] as? String  ?? "")
            }
        }
    return cell
    }
    
    
    
    
    //MARK:- TableviewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objTracks = arrItems[indexPath.row]
        let aurdioURl = objTracks.preview_url
        if aurdioURl.hasPrefix("http"){
            PlayerHelper.shared.startAudio(url: "\(aurdioURl)".replacingOccurrences(of: "%20", with: " "))
            
            if playIndex != indexPath.row {
                if playIndex != -1 {
                    let indPath = IndexPath(row: playIndex, section: playSection)
                    DispatchQueue.main.async {
                        if let cell = tableView.cellForRow(at: indPath) as? SPCategoryPlayListCell  {
                            cell.btnPlayPause.isHidden = true
                            cell.btnSave.isHidden = true
                        cell.lblName.textColor = UIColor.label
                        }
                    }
                }
                
                btnUseSong.isHidden = false
                playIndex = indexPath.row
                playSection = indexPath.section
                PlayerHelper.shared.pause()
            }
            
            self.playPauseAction()
        }else {
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Song is not available.")
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == arrItems.count - 1  {
            if isLoading == false && arrItems.count < total{
                    self.fetchsTracklist()
                }
        }
        
    }

}


extension SPTrackVC:TrimAudioDelegate{
    
    func dismissTrimAudio()
    {
        
    }
    
    func selectedTrimmedAudio(id:String,audioPath:String,audioName:String,timeLimit:Int, thumbImageUrl:String,originalUrl:String){
        
        if audioPath.length > 0 {
            self.onSongSelection?.onSelection(id: id, url: audioPath, name: audioName, timeLimit: timeLimit, thumbUrl: thumbImageUrl,originalUrl:originalUrl)
        }
      
                
        /*DispatchQueue.main.async {
            

            for controller in self.navigationController?.viewControllers as Array {
                if controller.isKind(of: CreateWallStatusVC.self) {
                    self.navigationController!.popToViewController(controller, animated: false)
                    break
                }else  if controller.isKind(of: CreateWallPostViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: false)
                    break
                }else if controller.isKind(of: RecordVideoVC.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
            }
            
         
        }*/
    }
}


class SPTrack{
    
    var id:String = ""
    var images:Array<Dictionary<String, Any>> = []
    var artists:Array<Dictionary<String, Any>> = []
    var name:String = ""
    var preview_url:String = ""
    
    //Saved Song
    var description: String = ""
    var thum: String = ""
    
    init(dict:Dictionary<String, Any>){
        
        self.id = dict["id"] as? String ?? ""
         let album = dict["album"] as? Dictionary<String, Any> ?? [:]
            self.images = album["images"] as? Array<Dictionary<String, Any>> ?? Array()
        
        
        self.artists = dict["artists"] as? Array<Dictionary<String, Any>> ?? Array()
        self.name = dict["name"] as? String ?? ""
        self.preview_url = dict["preview_url"] as? String ?? ""
    }
    
    init(dictSong:Dictionary<String, Any>){
        
        self.id = dictSong["id"] as? String ?? ""
        self.name = dictSong["soundname"] as? String ?? ""
        self.preview_url = dictSong["audio_path"] as? String ?? ""
        
        self.description = dictSong["description"] as? String ?? ""
        self.thum = dictSong["thum"] as? String ?? ""
    }
}

//
//  AddSoundVC.swift
//  SCIMBO
//
//  Created by SachTech on 29/07/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import UIKit
import MediaPlayer
import IQMediaPickerController
import Kingfisher
import Alamofire
import SCIMBOEx



class AddSoundVC: UIViewController,IQMediaPickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var audioCollection: UICollectionView!
    @IBOutlet weak var searchTf: UITextField!
    @IBOutlet weak var searchPlayList: UITextField!
    @IBOutlet weak var detailListView: UIView!
    @IBOutlet weak var audiolistTbl: UITableView!
    @IBOutlet weak var noSongLbl: UILabel!
    @IBOutlet weak var btnCloseDetailView:UIButton!
    
    @IBOutlet weak var btnShowSaveList:UIButton!
    
    var selectedSectionList:NSArray?
    var searchedList:NSMutableArray?
    var playIndex:Int?
    var audioList = [SoundModel]()
    var parentAudioList = [SoundModel]()
    let picker = IQMediaPickerController()
    var onSongSelection:onSongSelectionDelegate?
    var timeLimit:Int = 30
    var isUpdatedTimeLimit = false
    var isSavedList = false
    
    //Trim Audio
    @IBOutlet weak var viewTrim:UIView!
    @IBOutlet weak var imgSong:UIImageView!
    @IBOutlet weak var btnCancel:UIButton!
    @IBOutlet weak var btnDone:UIButton!
    @IBOutlet weak var btnPlayPause:UIButton!
    @IBOutlet weak var lblStartTime:UILabel!
    @IBOutlet weak var lblEndTime:UILabel!
    @IBOutlet weak var lblSongTrimmed: UILabel!
    
    let rangeSlider1 = RangeSlider(frame: CGRect.zero)
    var selectedIndex = -1
    var timer = Timer()
    var currentTime:Double = 0.0
    @IBOutlet weak var lblCurrentTime:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("UIViewController : AddSoundVC")
        picker.delegate = self
        var mediaType = [NSNumber]()
        mediaType.append(NSNumber(value: PHAssetMediaType.audio.rawValue))
        picker.mediaTypes = mediaType
        picker.allowsPickingMultipleItems = false

        btnShowSaveList.layer.cornerRadius = 10.0
        btnShowSaveList.layer.borderColor = UIColor.darkGray.cgColor
        btnShowSaveList.layer.borderWidth = 0.5
        
        
//        picker.showsCloudItems = false
//        picker.showsItemsWithProtectedAssets = false
        getAllSound()
        
       // searchTf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
       // searchPlayList.addTarget(self, action: #selector(textFieldDidChange2(_:)), for: .editingChanged)
        
        searchTf.delegate = self
        searchPlayList.delegate = self
        
        
        noSongLbl.isHidden = true
        
        audioCollection.layer.cornerRadius = 20.0
        
        btnDone.layer.cornerRadius = 5.0
        btnCancel.layer.cornerRadius = 5.0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        view.endEditing(true)
        PlayerHelper.shared.pausePlayerNow()
    }
    
    @IBAction func dismissDetailsView(_ sender: Any) {
        view.endEditing(true)
        PlayerHelper.shared.pausePlayer()
        detailListView.isHidden = true
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
                        self.searchedList?.removeObject(at: row)
                        self.audiolistTbl.reloadData()
                    
                    AlertView.sharedManager.displayMessage(title: "PickZon", msg: message, controller: self)
                    
                }
                else
                {
                    self.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    @IBAction func showSaveListAction() {
        
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
                    
                    self.isSavedList = true
                    self.selectedSectionList = []
                    self.searchedList = []
                    let soundAry = result.value(forKey: "result") as? NSMutableArray ?? []
                    self.selectedSectionList = soundAry
                    self.searchedList = soundAry
                    self.audiolistTbl.reloadData()
                    self.detailListView.isHidden = false
                    
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func searchSong(keyword:String) -> NSArray
       {
        let filtered = searchedList?.filter {
            let data = $0 as? NSDictionary ?? [:]
            return (data.value(forKey: "soundname") as! String).range(of: keyword, options: .caseInsensitive) != nil
           }
        return filtered! as NSArray
       }
    
    
    func searchPlayList(keyword:String) -> [SoundModel]
          {
            let filtered = audioList.filter {
                let data = $0.section_name as? String ?? ""
                return data.range(of: keyword, options: .caseInsensitive) != nil
              }
            return filtered
          }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField.text?.count)! > 0
        {
            self.searchedList = searchSong(keyword: textField.text!) as! NSMutableArray
            self.audiolistTbl.reloadData()
        }
        else
        {
            self.searchedList = selectedSectionList as! NSMutableArray
            self.audiolistTbl.reloadData()
        }
}
     @objc func textFieldDidChange2(_ textField: UITextField) {
    if (textField.text?.count)! > 0
    {
        self.audioList = searchPlayList(keyword: textField.text!)
        self.audioCollection.reloadData()
    }
    else
    {
        self.audioList = parentAudioList
        self.audioCollection.reloadData()
    }
    }

    @IBAction func closeView(_ sender: Any) {
        self.isSavedList = false
        self.dismissView(animated: true)
    }
    
    @IBAction func openMediaPickerController(sender: AnyObject) {
        
        picker.allowsPickingMultipleItems = false
        //picker.prompt = NSLocalizedString("Chose audio file", comment: "Please chose an audio file")
        self.present(picker, animated: true, completion: nil)
 
        /*let btn = sender as! UIButton
        self.selectSongs(btn)
 */
    }
    /*
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
    }*/
//    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
//        let sound = mediaItemCollection.representativeItem
//        let titlename  = sound?.title ?? "trimmed"
//        let url = sound?.assetURL
//        if url != nil{
////            DispatchQueue.main.asyncAfter(deadline: .now()+0.2){
////                Themes.sharedInstance.activityView(View: self.view)
////
////            }
//        exportAsset(AVAsset(url: url!), fileName: titlename)
//         mediaPicker.dismiss(animated: true, completion: nil)
//            
//        }
//    }
    
    func mediaPickerController(_ controller: IQMediaPickerController, didFinishMedias selection: IQMediaPickerSelection) {
        let sound = selection.selectedAudios[0]
        let titlename  = sound.title ?? "PickZon-Audio\(Date.timeStamp)"
        print(sound.assetURL)
        print(sound.value(forProperty: MPMediaItemPropertyAssetURL))
        print(sound.hasProtectedAsset)
        if let url = sound.assetURL{
            
            exportAsset(AVAsset(url: url), fileName: titlename)
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func mediaPickerControllerDidCancel(_ controller: IQMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
    }
   /*
    //Media Picker Starts
    @IBAction func selectSongs(_ sender: UIButton) {
        let controller = MPMediaPickerController(mediaTypes: .music)
        controller.allowsPickingMultipleItems = false
        controller.popoverPresentationController?.sourceView = sender
        controller.delegate = self
        present(controller, animated: true)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController,
                     didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        if mediaItemCollection.items.count > 0 {
        let sound = mediaItemCollection.items[0]
        print(sound.assetURL)
        
        }
        // Get the system music player.
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
        musicPlayer.setQueue(with: mediaItemCollection)
        mediaPicker.dismiss(animated: true)
        // Begin playback.
        musicPlayer.play()
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true)
    }*/
    
    
    //MARK: Api Methods
    
   
    
    
    //Media Picker Ends
   
    func getAllSound()
    {
        
        self.audioList.removeAll()
        self.parentAudioList.removeAll()
        Themes.sharedInstance.activityView(View: self.view)
        let url = Constant.sharedinstance.getAllSounds+"?msisdn=\(Themes.sharedInstance.GetMyPhonenumber())"
        print("url : ", url)
        URLhandler.sharedinstance.makeGetAPICall(url:url, param: nil, completionHandler: {(responseObject, error) ->  () in
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
                    let data = result.value(forKey: "result") as? NSArray ?? []
                    for d in data
                    {
                        self.audioList.append(SoundModel(dict: d as? NSDictionary ?? [:]))
                        self.parentAudioList.append(SoundModel(dict: d as? NSDictionary ?? [:]))
                    }
                    self.audioCollection.reloadData()
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    
    func getSearchedSong(strSearch:String)
    {
        
       // Themes.sharedInstance.activityView(View: self.view)
        let url = Constant.sharedinstance.getsearchSong
        print("url : ", url)
        let param:NSDictionary = ["searchKey":strSearch]
        print("param: ",param)
        
        URLhandler.sharedinstance.makePostAPICall(url:url, param: param, completionHandler: {(responseObject, error) ->  () in
           // Themes.sharedInstance.RemoveactivityView(View: self.view)
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
                    let data = result.value(forKey: "result") as? NSMutableArray ?? []
                    /*
                    for d in data
                    {
                        self.audioList.append(SoundModel(dict: d as? NSDictionary ?? [:]))
                        self.parentAudioList.append(SoundModel(dict: d as? NSDictionary ?? [:]))
                    }
                    self.audioCollection.reloadData()
                     */
                    self.searchedList = data
                    self.audiolistTbl.reloadData()
                    
                    
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    
    
    
    func exportAsset(_ asset: AVAsset, fileName: String) {
    
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let trimmedSoundFileURL = documentsDirectory.appendingPathComponent("\(fileName)"+"\(Int(Date().timeIntervalSince1970))"+".m4a")
        print("saving to \(trimmedSoundFileURL.absoluteString)")
        if FileManager.default.fileExists(atPath: trimmedSoundFileURL.absoluteString) {
            print("sound exists, removing \(trimmedSoundFileURL.absoluteString)")
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
            if duration < Float64(timeLimit) {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                print("sound is not long enough")
                self.view.makeToast("Failed: Sound is not long enough")
                return
            }
            let startTime = CMTimeMake(value: 0, timescale: 1)
            let stopTime = CMTimeMake(value: Int64(timeLimit), timescale: 1)
            
            
            
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
                    DispatchQueue.main.async {
                        Themes.sharedInstance.activityView(View: self.view)
                    URLhandler.sharedinstance.uploadAudio(fileName: fileName, file: trimmedSoundFileURL, url: "https://www.gupsup.com/api/UploadSong")
                    {
                        (msg,status,audiourl) in
                        if status == "99"
                        {
                            print(audiourl)
                            let param:NSDictionary = ["msisdn":Themes.sharedInstance.GetMyPhonenumber(),"soundname":fileName,"url":audiourl]
                            URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.UploadSongEntry as String, param: param, completionHandler: {(responseObject, error) ->  () in
                                if(error != nil)
                                {
                                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                                    print(error ?? "defaultValue")
                                }
                                else{
                                    let result = responseObject! as NSDictionary
                                    let errNo = result["errNum"] as! String
                                    let message = result["message"]
                                    if errNo == "99"{
                                        print(result)
                                     Themes.sharedInstance.RemoveactivityView(View: self.view)
                                        self.view.makeToast("Uploaded")
                                        self.getAllSound()
                                    }
                                    else
                                    {
                                        Themes.sharedInstance.RemoveactivityView(View: self.view)
                                        self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                                    }
                                }
                            })
                        }
                        else{
                            Themes.sharedInstance.RemoveactivityView(View: self.view)
                            self.view.makeToast(message: msg, duration: 3, position: HRToastActivityPositionDefault)
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == searchPlayList {
            
            //load the first index songs from collecgtion view
            self.selectedSectionList = []
            self.searchedList = []
            
            if audioList.count > 0 {
            let soundAry = audioList[0].sections_sounds as? NSMutableArray ?? []
            self.selectedSectionList = soundAry
            self.searchedList = soundAry
            }
            
            audiolistTbl.reloadData()
            detailListView.isHidden = false
            searchTf.becomeFirstResponder()
            
            return false
        }
        return true
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //searchTf
        //searchPlayList
        if textField == searchTf {
            
            let  char = string.cString(using: String.Encoding.utf8)!
            let isBackSpace = strcmp(char, "\\b")
            var currentText = ""
            if (isBackSpace == -92) {
                currentText = textField.text!.substring(to: textField.text!.index(before: textField.text!.endIndex))
            }
            else {
                currentText = textField.text! + string
            }
            
            //call API to search the song
            self.getSearchedSong(strSearch: currentText)
            
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddSoundVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return audioList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = audioCollection.dequeueReusableCell(withReuseIdentifier: "SoundCVC", for: indexPath) as! SoundCVC
        cell.audioName.text = audioList[indexPath.row].section_name as? String ?? ""
        cell.audioThumbnail.layer.cornerRadius = 10.0
        
        cell.audioThumbnail.kf.setImage(with: URL(string: Constant.sharedinstance.ImgBaseURL+"/\(audioList[indexPath.row].thum as? String ?? "")"), placeholder: UIImage(named: "music")!, progressBlock: nil) { response in}
    
    
 //   cell.audioThumbnail.sd_setImage(with: URL(string: Constant.sharedinstance.ImgBaseURL+"/\(audioList[indexPath.row].thum as? String ?? "")"), completed: nil)
       
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width/2.2, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.isSavedList = false
        
        self.selectedSectionList = []
        self.searchedList = []
        let soundAry = audioList[indexPath.row].sections_sounds as? NSMutableArray ?? []
        self.selectedSectionList = soundAry
        self.searchedList = soundAry
        audiolistTbl.reloadData()
        detailListView.isHidden = false
    }
}

extension AddSoundVC:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchedList?.count ?? 0 < 1
        {
            noSongLbl.isHidden = false
        }
        else
        {
            noSongLbl.isHidden = true
        }
        return searchedList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = audiolistTbl.dequeueReusableCell(withIdentifier: "SoundTVC") as! SoundTVC
        let dict = searchedList?[indexPath.row] as? NSDictionary ?? [:]
        cell.soundName.text = dict.value(forKey: "soundname") as? String ?? ""
        cell.useSong.tag = indexPath.row
        cell.useSong.addTarget(self, action: #selector(useSong(sender:)), for: .touchUpInside)
        cell.songIcon.layer.cornerRadius = cell.songIcon.frame.size.width/2.0
        cell.songIcon.clipsToBounds = true
        
        if indexPath.row == playIndex{
            cell.songIcon.rotate()
            cell.useSong.isHidden = false
        }
        else
        {
            cell.useSong.isHidden = true
        }
        
        
        let dt = searchedList?[indexPath.row] as? NSDictionary ?? [:]
        let thum = dt.value(forKey: "thum") as? String ?? ""
        if thum.length > 0 {
            let audioThumbimageURL = URL(string: thum.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? "")
            
            cell.songIcon.kf.setImage(with: audioThumbimageURL, placeholder:  UIImage(named: "Song"), options: nil, progressBlock: nil) { (response) in
            }
        } else {
            cell.songIcon.image =  UIImage(named: "Song")
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = searchedList?[indexPath.row] as? NSDictionary ?? [:]
        let aurdioURl = "\(dict.value(forKey: "audio_path") as? String ?? "")"
        print(aurdioURl)
        
            if aurdioURl.hasPrefix("http"){
                PlayerHelper.shared.startAudio(url: "\(dict.value(forKey: "audio_path") as? String ?? "")".replacingOccurrences(of: "%20", with: " "))
            }else {
                PlayerHelper.shared.startAudio(url: "\(Constant.sharedinstance.ImgBaseURL)/\(dict.value(forKey: "audio_path") as? String ?? "")".replacingOccurrences(of: "%20", with: " "))
            }
            playIndex = indexPath.row
            PlayerHelper.shared.playPlayer()
        
        audiolistTbl.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if isSavedList == true {
        return true
        }else {
            return false
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
           print("Deleted")
            PlayerHelper.shared.pause()
            let dict = searchedList?[indexPath.row] as? NSDictionary ?? [:]
            let soundId = dict["id"] as? String ?? ""
            self.removeSavedAudioAPI(soundId: soundId, row:indexPath.row)
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    @objc func useSong(sender:UIButton)
    {
        /*
        PlayerHelper.shared.pausePlayer()
        let dict = searchedList?[sender.tag]as? NSDictionary ?? [:]
         let audio_path = dict.value(forKey: "audio_path") as? String ?? ""
        if audio_path.length > 0 {
            onSongSelection?.onSelection(id: dict.value(forKey: "id") as? String ?? "", url: "\(dict.value(forKey: "audio_path") as? String ?? "")".replacingOccurrences(of: "%20", with: " "), name: dict.value(forKey: "soundname") as? String ?? "")
        }
        self.dismissView(animated: true)
        */
        
        PlayerHelper.shared.pausePlayer()
        selectedIndex = sender.tag
        
        
        self.downloadAudioFile()
    }
    
    
    
    
    
    
    
    
    func downloadAudioFile()
    {
        
        
        
        DispatchQueue.main.async {
            
            if URLhandler.sharedinstance.isConnectedToNetwork() == true {
                let dict = self.searchedList?[self.selectedIndex]as? NSDictionary ?? [:]
                let aurdioUrl = dict.value(forKey: "audio_path") as? String ?? ""
                
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
                           /* if(self.Delegate !=  nil)
                            {
                                DispatchQueue.main.async {
                                    let Dict:NSDictionary = ["url":"\(url)","completed_progress":"\(progress.completedUnitCount)","total_progress":"\(progress.totalUnitCount)"]
                                    
                                    self.Delegate?.ReturnDownloadProgress(id: id, Dict: Dict,status: "1")
                                    
                                }
                            }*/
                            
                        }.validate().responseData { ( response ) in
                            Themes.sharedInstance.RemoveactivityView(View: self.view)
                            DispatchQueue.main.async {
                                switch response.result {
                                
                                case .success(_):
                                    print("success")
                                    self.showViewTrimAudio()
                                case let .failure(error):
                                    print("Failed")
                                }
                            }
                        }
                    }
                    else
                    {
                       // completionHandler(nil, nil)
                        self.showViewTrimAudio()
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
    
    //MARK:- Trim Audio song
    func showViewTrimAudio() {
        let dict = searchedList?[selectedIndex]as? NSDictionary ?? [:]
        let aurdioURl = dict.value(forKey: "audio_path") as? String ?? ""
        if aurdioURl.length > 0 {
            audiolistTbl.isUserInteractionEnabled = false
            searchTf.isUserInteractionEnabled = false
            btnCloseDetailView.isUserInteractionEnabled = false
            isUpdatedTimeLimit = false
            viewTrim.isHidden(value: false)
            lblSongTrimmed.text = dict.value(forKey: "soundname") as? String ?? ""
            let margin: CGFloat = 20.0
            let width = view.bounds.width - 2.0 * margin
            rangeSlider1.frame = CGRect(x: margin, y: viewTrim.frame.height - 50,
                                        width: width, height: 31.0)
            
            viewTrim.addSubview(rangeSlider1)
            rangeSlider1.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .valueChanged)
            self.imgSong.layer.cornerRadius = self.imgSong.frame.size.width/2.0
            self.imgSong.clipsToBounds = true
            
            let thum = dict.value(forKey: "thum") as? String ?? ""
            if thum.length > 0 {
                let audioThumbimageURL = URL(string: thum.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? "")
                
                self.imgSong.kf.setImage(with: audioThumbimageURL, placeholder:  UIImage(named: "Song"), options: nil, progressBlock: nil) { (response) in
                }
            } else {
                self.imgSong.image =  UIImage(named: "Song")
            }
            
            
            let documentsURL = Themes.sharedInstance.getLocalURLForAudioFileServerURL(Url: URL(string:aurdioURl))
            
            if FileManager.default.fileExists(atPath: documentsURL.path)
            {
                PlayerHelper.shared.startAudioWithLocalFile(url: documentsURL.path)
                DispatchQueue.main.async(execute: { [self] in
                    let durartion = PlayerHelper.shared.avPlayerItem?.duration
                    print("Duration: ",PlayerHelper.shared.player?.currentItem?.duration.seconds)
                    timeLimit = 30
                    rangeSlider1.minimumValue = 0
                    rangeSlider1.maximumValue = Double(timeLimit)
                    rangeSlider1.lowerValue = rangeSlider1.minimumValue
                    rangeSlider1.upperValue = rangeSlider1.maximumValue
                    self.lblStartTime.text = String(format: "%0.1f", arguments: [rangeSlider1.minimumValue])
                    self.lblEndTime.text = String(format: "%0.1f", arguments: [rangeSlider1.maximumValue])
                    
                    self.imgSong.rotate()
                    PlayerHelper.shared.playPlayer()
                    btnPlayPause.setBackgroundImage(UIImage(named: "pauseIcon"), for: .normal)
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
                    currentTime = 0.0
                })
                
                
            }
            
            
           /* if aurdioURl.hasPrefix("http"){
                PlayerHelper.shared.startAudio(url: "\(dict.value(forKey: "audio_path") as? String ?? "")".replacingOccurrences(of: "%20", with: " "))
            }else {
                PlayerHelper.shared.startAudio(url: "\(Constant.sharedinstance.ImgBaseURL)/\(dict.value(forKey: "audio_path") as? String ?? "")".replacingOccurrences(of: "%20", with: " "))
            }
            
            */
        }
    }
    
    // must be internal or public.
    @objc func update() {
        currentTime = currentTime + 1.0
        if currentTime >= rangeSlider1.upperValue {
            self.timer.invalidate()
            currentTime = rangeSlider1.lowerValue
            PlayerHelper.shared.pause()
            btnPlayPause.setBackgroundImage(UIImage(named: "play_white"), for: .normal)
            PlayerHelper.shared.seekTimeto(seekTo: rangeSlider1.lowerValue)
            imgSong.removeRotation()
        }
        
        if isUpdatedTimeLimit == false {
            isUpdatedTimeLimit = true
        print(PlayerHelper.shared.player?.currentItem?.duration.seconds)
            DispatchQueue.main.async{
                self.timeLimit = Int((PlayerHelper.shared.player?.currentItem?.duration.seconds) ?? 0.0)
                self.rangeSlider1.minimumValue = 0
                self.rangeSlider1.maximumValue = Double(PlayerHelper.shared.player?.currentItem?.duration.seconds ?? 0.0)
                self.rangeSlider1.lowerValue = self.rangeSlider1.minimumValue
                self.rangeSlider1.upperValue = self.rangeSlider1.maximumValue
                self.lblStartTime.text = String(format: "%0.1f", arguments: [self.rangeSlider1.minimumValue])
                self.lblEndTime.text = String(format: "%0.1f", arguments: [self.rangeSlider1.maximumValue])
            }
            
        }
        
            
        self.lblCurrentTime.text = String(format: "%0.0f", arguments: [Double((PlayerHelper.shared.player?.currentTime().seconds)!)])
        
        
    }
    
    @IBAction func playPauseAction(){
        self.timer.invalidate()
        
        if PlayerHelper.shared.isPaused == true {
            PlayerHelper.shared.playPlayer()
            btnPlayPause.setBackgroundImage(UIImage(named: "pauseIcon"), for: .normal)
            imgSong.rotate()
            
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
            
        }else {
            PlayerHelper.shared.pause()
            imgSong.removeRotation()
            btnPlayPause.setBackgroundImage(UIImage(named: "play_white"), for: .normal)
        }
    }
    
    @objc func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
        print("Range slider value changed: (\(rangeSlider.lowerValue) , \(rangeSlider.upperValue))")
        DispatchQueue.main.async(execute: { [self] in
            self.lblStartTime.text = String(format: "%0.1f", arguments: [rangeSlider.lowerValue])
            self.lblEndTime.text = String(format: "%0.1f", arguments: [rangeSlider.upperValue])
            PlayerHelper.shared.seekTimeto(seekTo: rangeSlider.lowerValue)
            
            
            
            currentTime = rangeSlider.lowerValue
            PlayerHelper.shared.play()
            btnPlayPause.setBackgroundImage(UIImage(named: "pauseIcon"), for: .normal)
            lblCurrentTime.text = String(format: "%0.1f", arguments: [currentTime])
            self.timer.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        })
        
    }
   @IBAction func doneTrimAction(){
      /* audiolistTbl.isUserInteractionEnabled = true
       searchTf.isUserInteractionEnabled = true
       btnCloseDetailView.isUserInteractionEnabled = true
       */
        self.timer.invalidate()
        PlayerHelper.shared.pause()
        imgSong.removeRotation()
        btnPlayPause.setBackgroundImage(UIImage(named: "play_white"), for: .normal)
       // viewTrim.isHidden(value: true)
        
       
       let dict = searchedList?[selectedIndex]as? NSDictionary ?? [:]
       let aurdioURl = dict.value(forKey: "audio_path") as? String ?? ""
       let titlename = dict.value(forKey: "soundname") as? String ?? ""
       
       let documentsURL = Themes.sharedInstance.getLocalURLForAudioFileServerURL(Url: URL(string: aurdioURl))
       
       if FileManager.default.fileExists(atPath: documentsURL.path) {
           trimAudioExportAsset(AVAsset(url: URL(fileURLWithPath: documentsURL.path)), fileName: titlename)
        }
    }
    
    @IBAction func cancelTrimAction(){
        audiolistTbl.isUserInteractionEnabled = true
        searchTf.isUserInteractionEnabled = true
        btnCloseDetailView.isUserInteractionEnabled = true
        self.timer.invalidate()
        PlayerHelper.shared.pause()
        imgSong.removeRotation()
        btnPlayPause.setBackgroundImage(UIImage(named: "play_white"), for: .normal)
        viewTrim.isHidden(value: true)
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
            //let duration = CMTimeGetSeconds(asset.duration)
            let duration = rangeSlider1.upperValue - rangeSlider1.lowerValue
            if duration < Float64(5.0) {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                print("sound is not long enough")
                self.view.makeToast("Sound is not long enough")
                return
            }
            //let startTime = CMTimeMake(value: 0, timescale: 1)
            //let stopTime = CMTimeMake(value: Int64(timeLimit), timescale: 1)
            
            let startTime = CMTimeMake(value: Int64(rangeSlider1.lowerValue), timescale: 1)
            let stopTime = CMTimeMake(value: Int64(rangeSlider1.upperValue), timescale: 1)
            
            
            
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
                   
                    let dict = self.searchedList?[self.selectedIndex]as? NSDictionary ?? [:]
                    
                    let aurdioURl = dict.value(forKey: "audio_path") as? String ?? ""
                    let documentsURL = Themes.sharedInstance.getLocalURLForAudioFileServerURL(Url: URL(string: aurdioURl))
                    
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
                        self.onSongSelection?.onSelection(id: dict.value(forKey: "id") as? String ?? "", url: audio_path, name: dict.value(forKey: "soundname") as? String ?? "", timeLimit: (Int(self.rangeSlider1.upperValue) - Int(self.rangeSlider1.lowerValue)),thumbUrl:"",originalUrl:aurdioURl)
                    }
                    DispatchQueue.main.async {
                    self.dismissView(animated: true)
                    }
                    
                    
            }
            })
        } else {
            DispatchQueue.main.async {
                Themes.sharedInstance.RemoveactivityView(View: self.view)
            self.view.makeToast("cannot create AVAssetExportSession for asset \(asset)")
        }}
    }
}
extension UIImageView{
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func removeRotation(){
        self.layer.removeAllAnimations()
    }
}

//
//  TrimAudioVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 1/25/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import MediaPlayer
import IQMediaPickerController
import Kingfisher
import Alamofire
import SCIMBOEx




protocol TrimAudioDelegate {
    
func selectedTrimmedAudio(id:String,audioPath:String,audioName:String,timeLimit:Int, thumbImageUrl:String,originalUrl:String)
    func dismissTrimAudio()
}

class TrimAudioVC: UIViewController {
    
    var delegate:TrimAudioDelegate? = nil
    
    //Trim Audio
    @IBOutlet weak var viewTrim:UIView!
    @IBOutlet weak var imgSong:UIImageView!
    @IBOutlet weak var btnCancel:UIButton!
    @IBOutlet weak var btnDone:UIButton!
    @IBOutlet weak var btnPlayPause:UIButton!
    @IBOutlet weak var lblStartTime:UILabel!
    @IBOutlet weak var lblEndTime:UILabel!
    @IBOutlet weak var lblSongTrimmed: UILabel!
    @IBOutlet weak var topBGView: UIView!
    @IBOutlet weak var lblCurrentTime:UILabel!
    
    let rangeSlider1 = RangeSlider(frame: CGRect.zero)
    var selectedIndex = -1
    var timer = Timer()
    var currentTime:Double = 0.0
    var timeLimit:Int = 30
    var isUpdatedTimeLimit = false
    
    var audioUrl:String = ""
    var audioName = ""
    var audiothumbImgUrl = ""
    var audioId = ""
    
    //MARK: Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        showViewTrimAudio()
        view.backgroundColor = .clear
         view.backgroundColor =  UIColor.black.withAlphaComponent(0.8)
        self.topBGView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnView)))
        btnDone.layer.cornerRadius = 5.0
        btnCancel.layer.cornerRadius = 5.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK: UIBUtton Action Methods
    
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
    
    @IBAction func doneTrimAction(){
        
        self.timer.invalidate()
        PlayerHelper.shared.pause()
        imgSong.removeRotation()
        btnPlayPause.setBackgroundImage(UIImage(named: "play_white"), for: .normal)
        
        let documentsURL = Themes.sharedInstance.getLocalURLForAudioFileServerURL(Url: URL(string: audioUrl))
        
        if FileManager.default.fileExists(atPath: documentsURL.path) {
            trimAudioExportAsset(AVAsset(url: URL(fileURLWithPath: documentsURL.path)), fileName: audioName)
        }
    }
    
    @IBAction func cancelTrimAction(){
        self.timer.invalidate()
        PlayerHelper.shared.pause()
        imgSong.removeRotation()
        btnPlayPause.setBackgroundImage(UIImage(named: "play_white"), for: .normal)
        
        let documentsURL = Themes.sharedInstance.getLocalURLForAudioFileServerURL(Url: URL(string: audioUrl))
        self.timer.invalidate()

        self.dismissView(animated: true) {
            self.delegate?.selectedTrimmedAudio(id: self.audioId, audioPath: documentsURL.path, audioName: self.audioName, timeLimit: Int(self.rangeSlider1.upperValue), thumbImageUrl: self.audiothumbImgUrl, originalUrl: self.audioUrl)
        }

    }
    
   
    
    @objc func tapOnView(){
        self.timer.invalidate()
        PlayerHelper.shared.pause()
        imgSong.removeRotation()
        btnPlayPause.setBackgroundImage(UIImage(named: "play_white"), for: .normal)
                                        
        self.dismissView(animated: true) {
            
            self.delegate?.dismissTrimAudio()
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
            exporter.exportAsynchronously(completionHandler: { [self] in
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
        
                    let documentsURL = Themes.sharedInstance.getLocalURLForAudioFileServerURL(Url: URL(string: self.audioUrl))
                    
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
                        
                  
                    //    self.onSongSelection?.onSelection(id: audioId, url: audio_path, name:audioName, timeLimit: (Int(self.rangeSlider1.upperValue) - Int(self.rangeSlider1.lowerValue)),thumbUrl:"",originalUrl:audioUrl)
                    }
                        
                        
                    DispatchQueue.main.async {
                     // self.navigationController?.popViewController(animated: false)
                        //self.navigationController?.pop(animated: false)
                        //self.dismissView(animated: true)
                        
                        
                        
                        //self.dismissView(animated: true) {
                            self.delegate?.selectedTrimmedAudio(id: self.audioId, audioPath: audio_path, audioName: self.audioName, timeLimit: (Int(self.rangeSlider1.upperValue) - Int(self.rangeSlider1.lowerValue)), thumbImageUrl: self.audiothumbImgUrl, originalUrl: self.audioUrl)
                        //}

                        
                        
                       
                        for controller in (self.navigationController?.viewControllers.reversed() ?? []) as Array {
                                if controller.isKind(of: CreateWallStatusVC.self) {
                                    self.navigationController!.popToViewController(controller, animated: false)
                                    break
                                }else  if controller.isKind(of: CreateWallPostViewController.self) {
                                    self.navigationController!.popToViewController(controller, animated: false)
                                    break
                                }else if controller.isKind(of: RecordVideoVC.self){
                                    self.navigationController?.popToViewController(controller, animated: false)
                                    return
                                }else if controller.isKind(of: YPPickerVC.self){
                                    self.navigationController?.popToViewController(controller, animated: false)
                                    return
                                }else if controller.isKind(of: YPVideoFiltersVC.self){
                                    self.navigationController?.popToViewController(controller, animated: false)
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
    
    
    //MARK:- Trim Audio song
    func showViewTrimAudio() {
        
        if audioUrl.length > 0 {
            
            lblSongTrimmed.text = audioName
            let margin: CGFloat = 20.0
            let width = view.bounds.width - 2.0 * margin
            let originY = lblStartTime.frame.origin.y + lblStartTime.frame.height + 5
//            rangeSlider1.frame = CGRect(x: margin, y: viewTrim.frame.height - 50,
//                                        width: width, height: 31.0)
            rangeSlider1.frame = CGRect(x: margin, y: originY,
                                        width: width, height: 25.0)

            viewTrim.addSubview(rangeSlider1)
            rangeSlider1.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .valueChanged)
            self.imgSong.layer.cornerRadius = self.imgSong.frame.size.width/2.0
            self.imgSong.clipsToBounds = true
            print("audiothumbImgUrl==\(audiothumbImgUrl)")
            if audiothumbImgUrl.length > 0 {
                let audioThumbimageURL = URL(string: audiothumbImgUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? "")
                
                self.imgSong.kf.setImage(with: audioThumbimageURL, placeholder:  UIImage(named: "Song"), options: nil, progressBlock: nil) { (response) in
                }
            } else {
                self.imgSong.image =  UIImage(named: "Song")
            }
            
            
            let documentsURL = Themes.sharedInstance.getLocalURLForAudioFileServerURL(Url: URL(string:audioUrl))
            
            if FileManager.default.fileExists(atPath: documentsURL.path)
            {
                PlayerHelper.shared.startAudioWithLocalFile(url: documentsURL.path)
                DispatchQueue.main.async(execute: { [self] in
                    let durartion = PlayerHelper.shared.avPlayerItem?.duration
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

}

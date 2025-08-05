//
//  EditVideoVC.swift
//  SCIMBO
//
//  Created by Sachtech on 22/09/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import UIKit
import ICGVideoTrimmer
import MobileCoreServices

protocol GalleryVideoDelegate: AnyObject{
//    func onVideoPicked(_ asset: AVAsset)
    
    func onVideoPicked(_ asset: AVAsset, start:CGFloat ,endTime:CGFloat)

}

class EditVideoVC: SwiftBaseViewController, ICGVideoTrimmerDelegate {

    //MARK:- Outlets
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var vwPlayer: UIView!
    @IBOutlet weak var vwTrimmer: ICGVideoTrimmerView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
   
    var playerLayer: AVPlayerLayer! = AVPlayerLayer()
    var isPlaying: Bool = false
    var restartOnPlay: Bool = false
    var avPlayer: AVPlayer!
    var videoPlaybackPosition: CGFloat = 0.0
    var playbackTimeCheckerTimer: Timer = Timer()
    var ObjMultimedia: MultimediaRecord = MultimediaRecord()
    var delegateVideo: GalleryVideoDelegate?
    var audioID = "0"
    var audioURL = ""
    var audioLength = 0
    
    //MARK:- Lifecycles
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print("ViewController: EditVideoVC")
        self.ConfigureVideo(videoURl: self.ObjMultimedia.assetpathname,ObjRecord:self.ObjMultimedia)
        self.btnBack.setImageTintColor(UIColor.white)
    }
    
    deinit {
        avPlayer = nil
        playerLayer = nil
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        PlayerHelper.shared.pausePlayer()
        playerLayer.player?.pause()
        stopPlaybackTimeChecker()
        
    }
    
    //MARK:- Button Action
    @IBAction func btnPlay(_ sender: UIButton) {
        if isPlaying {
            avPlayer.pause()
            self.btnPlay.setImage(#imageLiteral(resourceName: "playIcon"), for: .normal)
            stopPlaybackTimeChecker()
            //Pause Mixing audio player
            PlayerHelper.shared.pausePlayer()
        }else {
            if restartOnPlay {
                seekVideo(toPos: CGFloat(ObjMultimedia.StartTime))
                vwTrimmer.seek(toTime: CGFloat(ObjMultimedia.StartTime))
                restartOnPlay = false
            }
            self.btnPlay.setImage(#imageLiteral(resourceName: "pauseIcon"), for: .normal)
            avPlayer.play()
            
            if audioURL.length > 0 {
                //Set the player volume to 0.0 if user has selected the sound to merger in selected video
                avPlayer.volume = 0.0
                //PlayerHelper.shared.startAudio(url: audioURL)
                PlayerHelper.shared.startAudioWithLocalFile(url: audioURL)
                PlayerHelper.shared.playPlayer()
            }
           
            startPlaybackTimeChecker()
        }
        isPlaying = !isPlaying
        vwTrimmer.hideTracker(!isPlaying)
    }
    
    func trimmerView(_ trimmerView: ICGVideoTrimmerView, didChangeLeftPosition startTime: CGFloat, rightPosition endTime: CGFloat) {
            restartOnPlay = true
            avPlayer.pause()
            self.btnPlay.setImage(#imageLiteral(resourceName: "playIcon"), for: .normal)
            isPlaying = false
            stopPlaybackTimeChecker()
            vwTrimmer.hideTracker(false)
            if startTime != CGFloat(ObjMultimedia.StartTime) {
                //then it moved the left position, we should rearrange the bar
                seekVideo(toPos: CGFloat(ObjMultimedia.StartTime))
            }
            else {
                // right has changed
                seekVideo(toPos: endTime)
            }
            ObjMultimedia.StartTime = Double(startTime)
            ObjMultimedia.Endtime = Double(endTime)
        
       // print("ObjMultimedia.StartTime:\(ObjMultimedia.StartTime) ObjMultimedia.StartTime: \(ObjMultimedia.Endtime)")
        self.lblStartTime.text = "\(Int(startTime))"
        self.lblEndTime.text = "\(Int(endTime))"
        }
        
        func startPlaybackTimeChecker() {
            stopPlaybackTimeChecker()
            playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.onPlaybackTimeCheckerTimer), userInfo: nil, repeats: true)
        }
        
        func stopPlaybackTimeChecker() {
            if (playbackTimeCheckerTimer != nil) {
                playbackTimeCheckerTimer.invalidate()
                playbackTimeCheckerTimer.invalidate()
            }
        }
        @objc func onPlaybackTimeCheckerTimer() {
            let curTime: CMTime = avPlayer.currentTime()
            var seconds: Float64 = CMTimeGetSeconds(curTime)
            if seconds < 0 {
                seconds = 0
                // this happens! dont know why.
            }
            videoPlaybackPosition = CGFloat(seconds)
            vwTrimmer.seek(toTime: CGFloat(seconds))
            if Int(videoPlaybackPosition) >= Int(CGFloat(ObjMultimedia.Endtime)) {
                videoPlaybackPosition = CGFloat(ObjMultimedia.StartTime)
                seekVideo(toPos: CGFloat(ObjMultimedia.StartTime))
                vwTrimmer.seek(toTime: CGFloat(ObjMultimedia.StartTime))
                
                //Pause Mixing audio player
                PlayerHelper.shared.pausePlayer()
                avPlayer.pause()
                self.btnPlay.setImage(#imageLiteral(resourceName: "playIcon"), for: .normal)
            }
        }
        
        func seekVideo(toPos pos: CGFloat) {
            videoPlaybackPosition = pos
            let time: CMTime = CMTimeMakeWithSeconds(Float64(videoPlaybackPosition), preferredTimescale: avPlayer.currentTime().timescale)
            //NSLog(@"seekVideoToPos time:%.2f", CMTimeGetSeconds(time));
            avPlayer.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        }
        @objc func playerItemDidReachEnd(notification: NSNotification) {
            if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
                playerItem.seek(to: CMTime.zero) { success in
                    print(success)
                }
                if(avPlayer != nil)
                {
                    avPlayer.pause()
                }
                self.btnPlay.setImage(#imageLiteral(resourceName: "playIcon"), for: .normal)
            }
        }
        
        func ConfigureVideo(videoURl:String,ObjRecord:MultimediaRecord)
        {
            DispatchQueue.main.async {
                if(self.avPlayer == nil)
                {
                    let videoURL = URL(string: videoURl)!
                    self.avPlayer = AVPlayer(url: videoURL)
                    self.avPlayer.pause()
                    self.playerLayer.player = self.avPlayer
                    self.playerLayer.contentsGravity = CALayerContentsGravity.resize
    //                self.playerLayer.contentsGravity = AVLayerVideoGravity.resize
                    self.playerLayer.frame = CGRect(x: 0, y: 0, width: self.vwPlayer.frame.size.width, height: self.vwPlayer.frame.size.height)
                    self.SetvwTrimmer(videoURL: videoURL as URL,ObjRecord:ObjRecord)
                    self.vwPlayer.layer.addSublayer(self.playerLayer)
                }
            }
            
                self.btnPlay.setImage(#imageLiteral(resourceName: "playIcon"), for: .normal)
        }
        
        func SetvwTrimmer(videoURL:URL,ObjRecord:MultimediaRecord)
        {
            if(ObjRecord.Endtime <= 5.0)
            {
                vwTrimmer.isUserInteractionEnabled = false
            }
            else
            {
                vwTrimmer.isUserInteractionEnabled = true
            }
            let AVasset:AVAsset = AVAsset(url: videoURL)
            vwTrimmer.themeColor = UIColor.lightGray
            vwTrimmer.asset =  AVasset
            vwTrimmer.rulerLabelInterval = 8
            
            vwTrimmer.minLength = CGFloat(5)
            
            if audioLength != 0 {
                vwTrimmer.maxLength = CGFloat(audioLength)
            }else {
                vwTrimmer.maxLength = CGFloat(Settings.sharedInstance.clipDuration)
            }
            
            vwTrimmer.showsRulerView = false
            vwTrimmer.trackerColor = UIColor.yellow
            vwTrimmer.delegate = self
            vwTrimmer.resetSubviews()
        }
        
    @IBAction func btnSaveCroppedImage(_ sender: UIButton) {
        
        PlayerHelper.shared.pausePlayer()
        self.dismiss(animated: false) {
            self.delegateVideo?.onVideoPicked(self.vwTrimmer.asset ?? AVAsset(),start: CGFloat(self.ObjMultimedia.StartTime), endTime: CGFloat(self.ObjMultimedia.Endtime))

        }
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        avPlayer.pause()
        self.dismiss(animated: false, completion: nil)
    }
}

//
//  AudioPlayerVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 5/25/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayerVC: UIViewController {
    
    var player: AVPlayer?
    var playerItem:AVPlayerItem?
    fileprivate let seekDuration: Float64 = 10
    @IBOutlet weak var labelOverallDuration: UILabel!
    @IBOutlet weak var labelCurrentTime: UILabel!
    @IBOutlet weak var playbackSlider: UISlider!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var topBGView: UIView!
    var audioUrl:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAudioPlayer()
        view.backgroundColor = .clear
       // view.backgroundColor =  UIColor.black.withAlphaComponent(0.8)
        self.topBGView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnView)))
        btnPlay.setImageTintColor(.blue)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
    
    @objc func tapOnView(){
        self.dismissView(animated: true)
    }
    
    
    //call this mehtod to init audio player
    func initAudioPlayer(){
        // let url = URL(string: "https://argaamplus.s3.amazonaws.com/eb2fa654-bcf9-41de-829c-4d47c5648352.mp3")
        let playerItem:AVPlayerItem = AVPlayerItem(url: audioUrl!)
        player = AVPlayer(playerItem: playerItem)
        playbackSlider.minimumValue = 0
        
        //To get overAll duration of the audio
        let duration : CMTime = playerItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        labelOverallDuration.text = self.stringFromTimeInterval(interval: seconds)
        
        //To get the current duration of the audio
        let currentDuration : CMTime = playerItem.currentTime()
        let currentSeconds : Float64 = CMTimeGetSeconds(currentDuration)
        labelCurrentTime.text = self.stringFromTimeInterval(interval: currentSeconds)
        
        playbackSlider.maximumValue = Float(seconds)
        playbackSlider.isContinuous = true
                
        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player!.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                self.playbackSlider.value = Float ( time );
                self.labelCurrentTime.text = self.stringFromTimeInterval(interval: time)
            }
            let playbackLikelyToKeepUp = self.player?.currentItem?.isPlaybackLikelyToKeepUp
            if playbackLikelyToKeepUp == false{
                print("IsBuffering")
               // self.btnPlay.isHidden = true
                //self.loadingView.isHidden = false
            } else {
                //stop the activity indicator
                //print("Buffering completed")
              //  self.btnPlay.isHidden = false
                // self.loadingView.isHidden = true
            }
        }
        
        //change the progress value
        playbackSlider.addTarget(self, action: #selector(playbackSliderValueChanged(_:)), for: .valueChanged)
        
        //check player has completed playing audio
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        playButton(btnPlay)
    }
    
    
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider) {
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        player!.seek(to: targetTime)
        if player!.rate == 0 {
            player?.play()
        }
    }
    
    @objc func finishedPlaying( _ myNotification:NSNotification) {
        btnPlay.setImage(UIImage(named: "play_triangle"), for: .normal)
        //reset player when finish
        btnPlay.setImageTintColor(.blue)
        playbackSlider.value = 0
        btnPlay.setImageTintColor(.blue)
        let targetTime:CMTime = CMTimeMake(value: 0, timescale: 1)
        player!.seek(to: targetTime)
    }
    
    @IBAction func playButton(_ sender: UIButton) {
        print("play Button")
        if player?.rate == 0
        {
            player!.play()
           // self.btnPlay.isHidden = true
            //self.loadingView.isHidden = false
            btnPlay.setImage(UIImage(named: "pause"), for: .normal)
        } else {
            player!.pause()
            btnPlay.setImage(UIImage(named: "play_triangle"), for: .normal)
            
        }
        btnPlay.setImageTintColor(.blue)

    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
//      return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @IBAction func seekBackWards(_ sender: Any) {
        if player == nil { return }
        let playerCurrenTime = CMTimeGetSeconds(player!.currentTime())
        var newTime = playerCurrenTime - seekDuration
        if newTime < 0 { newTime = 0 }
        player?.pause()
        let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player?.seek(to: selectedTime)
        player?.play()
    }
    
    @IBAction func seekForward(_ sender: Any) {
        if player == nil { return }
        if let duration = player!.currentItem?.duration {
            let playerCurrentTime = CMTimeGetSeconds(player!.currentTime())
            let newTime = playerCurrentTime + seekDuration
            if newTime < CMTimeGetSeconds(duration)
            {
                let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as
                                                                   Float64), timescale: 1000)
                player!.seek(to: selectedTime)
            }
            player?.pause()
            player?.play()
        }
    }
}

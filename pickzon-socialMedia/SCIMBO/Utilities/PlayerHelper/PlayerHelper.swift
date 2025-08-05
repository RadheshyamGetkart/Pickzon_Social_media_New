//
//  PlayerHelper.swift
//  SCIMBO
//
//  Created by SachTech on 05/08/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import Foundation
import MKVideoCacher
import AVFoundation

protocol PlayerDelegate: AnyObject {
    func onPlayerStateChange(_ value:String)
    func isToCallViewApi(time:CMTime)
}

let VideoCacheLimit: Double = 1000.0

class PlayerHelper: NSObject {
    var notificationObserver:NSObjectProtocol?
    
    static let shared:PlayerHelper = PlayerHelper()
    //private var player:AVPlayer?
    var player:AVPlayer?
    var playerLayer : AVPlayerLayer?
    var manager : VideoCache?
    var avPlayerItem:AVPlayerItem?
    
    var playerDelegate:PlayerDelegate?
    var isPaused:Bool = false
    var timeObserverToken: Any?
    
    private override init() {
        
    }
    
    
    func startAudio(url:String)
    {
        pausePlayer()
        
        var urlString = url.replacingOccurrences(of: "%20", with: " ")
        urlString = urlString.replacingOccurrences(of: "%21", with: "!")
        urlString = urlString.replacingOccurrences(of: "%22", with: "\"")
        urlString = urlString.replacingOccurrences(of: "%3C", with: "<")
        urlString = urlString.replacingOccurrences(of: "%3E", with: ">")
        urlString = urlString.replacingOccurrences(of: "%23", with: "#")
        urlString = urlString.replacingOccurrences(of: "%25", with: "%")
        urlString = urlString.replacingOccurrences(of: "%7C", with: "|")
        
        
        
        let audioUrl = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? "")
        
        
        if audioUrl != nil{
            avPlayerItem = AVPlayerItem(url: audioUrl!)
            player = AVPlayer(playerItem: avPlayerItem)
            player?.volume = 1.0
            
        }
    }
    
    func startAudioWithLocalFile(url:String)
    {
        pausePlayer()
        let audioUrl = URL(fileURLWithPath: url)
        if audioUrl != nil{
            
            avPlayerItem = AVPlayerItem(url: audioUrl)
            player = AVPlayer(playerItem: avPlayerItem)
            player?.volume = 1.0
        }
    }
    
    func isPlaying () -> Bool
    {
        return player?.isPlaying ?? false
    }
    
    func startPlayer(url:String,view:UIView){
        pausePlayer()
        /*
         if url.contains("tempMovie"){
         if let url = URL(string: url) {
         self.player = AVPlayer(url: url)
         self.player?.automaticallyWaitsToMinimizeStalling = false
         playerLayer = AVPlayerLayer(player: player)
         player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
         player?.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
         playerLayer?.videoGravity = .resizeAspectFill
         // playerLayer?.videoGravity = .resizeAspect
         playerLayer?.frame = view.bounds
         }
         }*/
        self.manager = VideoCache(limit : VideoCacheLimit)
        let cacheUrl = self.manager!.createLocalUrl(with: URL(fileURLWithPath:url))
        
        if self.manager!.isFileExist(at:cacheUrl?.path ?? "") == true{
            //print("Played from Cache")
            self.player = AVPlayer(url:cacheUrl!)
            self.player?.automaticallyWaitsToMinimizeStalling = false
            playerLayer = AVPlayerLayer(player: player)
            //player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
            //player?.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
            playerLayer?.videoGravity = .resizeAspect
            //playerLayer?.videoGravity = .resizeAspectFill
            playerLayer?.frame = view.bounds
            
        }else{
            // self.manager = VideoCache(limit : 1024)
            if let manager = self.manager, let url = URL(string: url) {
                self.player = manager.setPlayer(with : url)
                self.player?.automaticallyWaitsToMinimizeStalling = false
                playerLayer = AVPlayerLayer(player: player)
                player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
                player?.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
                playerLayer?.videoGravity = .resizeAspect
                //playerLayer?.videoGravity = .resizeAspectFill
                playerLayer?.frame = view.bounds
                //playerLayer?.
            }
        }
        addPeriodicTimeObserver()
    }
    
    func showplayerLayer() -> AVPlayerLayer
    {
        return playerLayer!
    }
    func playPlayer(){
        player?.play()
        self.isPaused = false
    }
    func pausePlayer(){
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        self.player = nil
        //self.isPaused = true
    }
    func pausePlayerNow(){
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        //  self.player = nil
        //self.isPaused = true
    }
    
    func pause(){
        player?.pause()
        self.isPaused = true
    }
    
    func play(){
        player?.play()
        self.isPaused = false
    }
    
    func loopVideo() {
        
        
        NotificationCenter.default.removeObserver(self.notificationObserver ?? self)
        
        
        self.notificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) {[weak self]  notification in
            
            if Themes.sharedInstance.isFeedsView == 0 {
                //self.player?.play()
                if ((Themes.sharedInstance.selectedTabIndex == 0 || Themes.sharedInstance.selectedTabIndex == 3) && Themes.sharedInstance.isClipVideo == 1) {
                    self?.player?.seek(to: CMTime.zero)
                    self?.player?.play()
                    
                    
                }else if Themes.sharedInstance.selectedTabIndex == 0{
                }else if Themes.sharedInstance.selectedTabIndex == 1 && Themes.sharedInstance.isClipVideo == 0 {
                    
                }else if Themes.sharedInstance.selectedTabIndex == 1{
                    self?.player?.seek(to: CMTime.zero)
                    self?.player?.play()
                    
                }/*else {
                  self.player?.seek(to: CMTime.zero)
                  self.player?.play()
                  }*/
            }
        }
        
        
        
    }
    
    
    
    func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 5, preferredTimescale: timeScale)
        
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: time,
                                                            queue: .main) {
            [weak self] time in
            // update player transport UI
            print("TIME ====== \(time.seconds)")
            /*if time.seconds > 5  && time.seconds < 10 {
                self?.removePeriodicTimeObserver()
                self?.playerDelegate?.isToCallViewApi(time:time)
            }*/
        }
    }
    
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    func seekTimeto(seekTo:Double) {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: seekTo, preferredTimescale: timeScale)
        self.player?.seek(to: time)
        self.player?.pause()
        self.isPaused = true
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            switch keyPath {
            case "playbackBufferEmpty":
                playerDelegate?.onPlayerStateChange("loading")
            case "playbackLikelyToKeepUp":
                playerDelegate?.onPlayerStateChange("ready")
            case .none: break
                //none
            case .some(_): break
                //some
            }
        }
    }
}


extension AVPlayer {
    func isToCallViewApi(time:CMTime)
    {
        // https://developer.apple.com/documentation/avfoundation/media_playback_and_selection/observing_the_playback_time
    }
    
    var isPlaying: Bool {
        if (self.rate != 0 && self.error == nil) {
            return true
        } else {
            return false
        }
    }
}

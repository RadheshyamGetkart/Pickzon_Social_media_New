//
//  FeedsCollectionViewCell.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 6/26/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit
import AVKit
import _AVKit_SwiftUI

class FeedsCollectionViewCell: UICollectionViewCell {    
        
    @IBOutlet weak var imgImageView: UIImageView!
    @IBOutlet weak var btnPlayPause:UIButton!
    @IBOutlet weak var controlView: GSPlayerControlUIView!
    @IBOutlet weak var videoView: VideoPlayerView!
    @IBOutlet weak var btnPreview:UIButton!
    @IBOutlet weak var cnstrntBottomBtnPreview:NSLayoutConstraint!
    @IBOutlet weak var viewBorderBottom: UIView!
    @IBOutlet weak var cnstrnt_BorderHeight: NSLayoutConstraint!
    @IBOutlet weak var btnAddMusic:UIButton!

    var isZooming = false
    var originalImageCenter:CGPoint?
    var url:String = ""
    var thumbURL:String = ""
    var mediaId:String = ""
    var isFirstTime = true
    var isVideo = false
    var urlArray = Array<String>()
    var selIndex = 0
    var objWallPost:WallPostModel!
    var isRandomVideos = false
    var controllerType:PostType = .isFromPost
    var hashTag = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btnPlayPause.isHidden = true
        self.btnAddMusic.isHidden = true
        self.btnAddMusic.layer.cornerRadius = self.btnAddMusic.frame.size.height/2.0
        self.btnAddMusic.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        /*let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(sender:)))
         pinch.delegate = self
         imgImageView.addGestureRecognizer(pinch)
         
         let pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan(sender:)))
         pan.delegate = self
         imgImageView.addGestureRecognizer(pan)
         */
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configureCell(isToHidePlayer:Bool,indexPath:IndexPath){
        selIndex = indexPath.row
       
        if (isToHidePlayer == true){
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
             tap.numberOfTapsRequired = 1
             self.imgImageView.addGestureRecognizer(tap)
            self.imgImageView.isHidden = false
            self.videoView.isHidden  = true
            controlView.isHidden = true
            
        }else{
              let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
             tap.numberOfTapsRequired = 1
             self.controlView.addGestureRecognizer(tap)
             
            videoView.player?.isMuted = !UserDefaults.standard.bool(forKey: videosStartWithSound)
            videoView.contentMode = .scaleAspectFill
            videoView.pausedReason = .userInteraction
            videoView.setURLToPlay(for: URL(string:url)!)
            
            self.imgImageView.isHidden = true
            self.videoView.isHidden = false
            self.controlView.isHidden = false
            
            controlView.populate(with: videoView)
            self.view.bringSubviewToFront(controlView)
           
        }
        
    }
    
    func playVideo() {
        if videoView.isEndPlaying == true {
            videoView.isEndPlaying  = false
            videoView.player?.seek(to: CMTime.zero)
            videoView.resume()
        }else if videoView.state != .playing {
            videoView.resume()
        }
        
        videoView.player?.isMuted = !UserDefaults.standard.bool(forKey: videosStartWithSound)
        controlView.updateSpeakerImage()
    }
    
    func pauseVideo() {
        
        videoView.player?.isMuted = !UserDefaults.standard.bool(forKey: videosStartWithSound)
        videoView.pause(reason:.userInteraction)
        controlView.updateSpeakerImage()
        
    }
    
    func pauseVideoHidden() {
        videoView.player?.isMuted = !UserDefaults.standard.bool(forKey: videosStartWithSound)
        videoView.pause(reason:.hidden)
        controlView.updateSpeakerImage()
        
    }
    
    
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if URL(string:url) != nil {
            if checkMediaTypes(strUrl: url) == 3{
                
                if self.objWallPost != nil {
                    self.pauseVideo()
                    let vc =
                    StoryBoard.feeds.instantiateViewController(withIdentifier: "FeedsVideoViewController") as! FeedsVideoViewController
                    
                    vc.objWallPost = self.objWallPost
                    vc.videoView = self.videoView
                    if self.objWallPost.sharedWallData == nil {
                        vc.objWallPost.urlArray.removeAll()
                        vc.objWallPost.urlArray.append(self.url)
                        vc.objWallPost.thumbUrlArray.removeAll()
                        vc.objWallPost.thumbUrlArray.append(thumbURL)
//                        vc.objWallPost.mediaArr.removeAll()
//                        vc.objWallPost.mediaArr.append(mediaId)
                        
                    }else {
                        vc.objWallPost.sharedWallData.urlArray.removeAll()
                        vc.objWallPost.sharedWallData.urlArray.append(self.url)
                        vc.objWallPost.sharedWallData.thumbUrlArray.removeAll()
                        vc.objWallPost.sharedWallData.thumbUrlArray.append(thumbURL)
//                        vc.objWallPost.sharedWallData.mediaArr.removeAll()
//                        vc.objWallPost.sharedWallData.mediaArr.append(mediaId)
                    }
                    vc.firstVideoIndex = self.selIndex
                    vc.videoType = .feed
                    vc.isRandomVideos = self.isRandomVideos
                    if self.controllerType == .hashTag || self.controllerType == .hashTagSearched{
                        vc.isHashTagVideos = true
                        vc.hashTag = self.hashTag
                    }
                    
                    if self.isRandomVideos == true {
                        vc.arrFeedsVideo = Themes.sharedInstance.arrFeedsVideo
                    }
                 //   vc.totalPages = Themes.sharedInstance.totalPagesFeedsVideo
                    vc.isClipVideo = true
                    self.parentContainerViewController?.navigationController?.pushViewController(vc, animated: true)
                    
                }else {
                   
                    /*//when user is posting new feed and playing the video
                    if mmPlayerLayer.currentPlayStatus == .pause {
                        self.playVideo()
                    }else if mmPlayerLayer.currentPlayStatus == .playing {
                        self.pauseVideo()
                    }else{
                        self.mmPlayerLayer.player?.seek(to: CMTime.zero)
                        self.mmPlayerLayer.player?.play()
                    }*/
                }
                
            }else {
                var newArray = Array<String>()
                for urlStr in self.urlArray{
                    autoreleasepool {
                        if checkMediaTypes(strUrl: urlStr) == 1{
                            newArray.append(urlStr)
                        }else{
                            // selIndex = selIndex - 1
                        }
                    }
                }
                selIndex = newArray.firstIndex(of: url) ?? 0
                
                let vc = StoryBoard.feeds.instantiateViewController(withIdentifier: "ZoomImageViewController") as! ZoomImageViewController
                vc.currentTag = selIndex
                vc.imageArrayUrl = newArray
                vc.imageColor = self.imgImageView.image?.getAverageColour ?? .darkGray
                self.parentContainerViewController?.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
    }
    
    
    
    
    func handlePlayPause() {
        
        /*  if isFirstTime == true {
         
         isFirstTime = false
         PlayerHelper.shared.startPlayer(url: url, view: self.videoView)
         let playerLayer = PlayerHelper.shared.showplayerLayer()
         videoView.layer.sublayers?.removeAll()
         videoView.layer.addSublayer(playerLayer)
         PlayerHelper.shared.playPlayer()
         DispatchQueue.main.asyncAfter(deadline: .now()+1)
         {
         self.btnPlayPause.isHidden = true
         }
         }else {
         btnPlayPause.isHidden = false
         if PlayerHelper.shared.isPlaying()
         {
         btnPlayPause.setImage(UIImage(named: "pause"), for: .normal)
         PlayerHelper.shared.pause()
         }
         else if PlayerHelper.shared.isPaused == true
         {
         btnPlayPause.setImage(UIImage(named: "playa"), for: .normal)
         PlayerHelper.shared.playPlayer()
         }else {
         PlayerHelper.shared.startPlayer(url: url, view: self.videoView)
         let playerLayer = PlayerHelper.shared.showplayerLayer()
         videoView.layer.sublayers?.removeAll()
         videoView.layer.addSublayer(playerLayer)
         PlayerHelper.shared.playPlayer()
         DispatchQueue.main.asyncAfter(deadline: .now()+1)
         {
         self.btnPlayPause.isHidden = true
         }
         }
         DispatchQueue.main.asyncAfter(deadline: .now()+1)
         {
         self.btnPlayPause.isHidden = true
         }
         } */
    }
    
}


extension FeedsCollectionViewCell:UIGestureRecognizerDelegate{
    
    @objc  func pan(sender: UIPanGestureRecognizer) {
        if self.isZooming && sender.state == .began {
            self.originalImageCenter = sender.view?.center
        } else if self.isZooming && sender.state == .changed {
            let translation = sender.translation(in: self)
            if let view = sender.view {
                view.center = CGPoint(x:view.center.x + translation.x,
                                      y:view.center.y + translation.y)
            }
            sender.setTranslation(CGPoint.zero, in: self.imgImageView.superview)
        }
    }
    
    
    @objc func pinch(sender:UIPinchGestureRecognizer) {
        if sender.state == .began {
            let currentScale = self.imgImageView.frame.size.width / self.imgImageView.bounds.size.width
            let newScale = currentScale*sender.scale
            if newScale > 1 {
                self.isZooming = true
            }
        } else if sender.state == .changed {
            guard let view = sender.view else {return}
            let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
                                      y: sender.location(in: view).y - view.bounds.midY)
            let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: sender.scale, y: sender.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            let currentScale = self.imgImageView.frame.size.width / self.imgImageView.bounds.size.width
            var newScale = currentScale*sender.scale
            if newScale < 1 {
                newScale = 1
                let transform = CGAffineTransform(scaleX: newScale, y: newScale)
                self.imgImageView.transform = transform
                sender.scale = 1
            }else {
                view.transform = transform
                sender.scale = 1
            }
        } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
            guard let center = self.originalImageCenter else {return}
            UIView.animate(withDuration: 0.2, animations: {
                self.imgImageView.transform = CGAffineTransform.identity
                self.imgImageView.center = center
            }, completion: { _ in
                self.isZooming = false
            })
        }
        
        self.imgImageView.reloadInputViews()
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}


























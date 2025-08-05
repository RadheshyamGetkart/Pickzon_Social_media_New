//
//  CommentCVCell.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 7/28/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit
import AVFoundation

class CommentCVCell: UICollectionViewCell {
    
   
    
    @IBOutlet weak var txtFdComment:UITextField!
    @IBOutlet weak var imgImageView: UIImageView!
    
    @IBOutlet weak var controlView: GSPlayerControlUIView!
    @IBOutlet weak var videoView: VideoPlayerView!
    
    @IBOutlet weak var btnDelete:UIButton!
    @IBOutlet weak var btnAddMusic:UIButton!
    @IBOutlet weak var btnTagUser:UIButton!
    @IBOutlet weak var lblTaggedUser:ExpandableLabel!

    var isZooming = false
    var originalImageCenter:CGPoint?
    var url:String = ""
    var isFirstTime = true
    var isVideo = false
    var urlArray = Array<String>()
    var selIndex = 0

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.txtFdComment.layer.cornerRadius = 22.5
        self.txtFdComment.clipsToBounds = true
        self.txtFdComment.addLeftPadding()
        self.btnTagUser.layer.cornerRadius = self.btnTagUser.frame.size.height/2.0
        self.btnAddMusic.layer.cornerRadius = self.btnAddMusic.frame.size.height/2.0
        self.btnAddMusic.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        self.btnTagUser.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
       // self.lblTaggedUser.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.6)
        self.lblTaggedUser.numberOfLines = 5
        self.lblTaggedUser.collapsed = true
        self.lblTaggedUser.collapsedAttributedLink = NSAttributedString(string: " Read more" ,attributes:  [.foregroundColor:UIColor.systemBlue])
       // self.imgImageView.contentMode = .scaleAspectFit
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    func configureCell(isToHidePlayer:Bool,indexPath:IndexPath){
         selIndex = indexPath.row
       
        if (isToHidePlayer == true){
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            self.imgImageView.addGestureRecognizer(tap)
            self.imgImageView.isHidden = false
            
            /*self.mmPlayerLayer.playView = nil
            self.mmPlayerLayer.isHidden = true
            */
            self.videoView.isHidden  = true
            controlView.isHidden = true
        }else{
            /*self.mmPlayerLayer.isHidden = false
            self.videoView.isHidden = false
            self.imgImageView.isHidden = true
            self.mmPlayerLayer.coverView?.isHidden = false
            self.mmPlayerLayer.playView = self.videoView
            self.mmPlayerLayer.set(url: URL(string: url))
            self.mmPlayerLayer.resume()
            self.mmPlayerLayer.currentPlayStatus = .pause
            self.mmPlayerLayer.autoHideCoverType = .disable
            self.mmPlayerLayer.player?.pause()
            self.mmPlayerLayer.coverFitType = .fitToPlayerView
            self.mmPlayerLayer.player?.isMuted =   !UserDefaults.standard.bool(forKey: videosStartWithSound)
            self.mmPlayerLayer.showCover(isShow: true)
            self.mmPlayerLayer.thumbImageView.contentMode = .scaleAspectFit
            */
            
            videoView.contentMode = .scaleAspectFill
            videoView.pausedReason = .userInteraction
            videoView.setURLToPlay(for: URL(string:url)!)
            controlView.isHidden = false
            controlView.populate(with: videoView)
            self.view.bringSubviewToFront(controlView)
            
        }
        
    }
    
  
    func playVideo() {
        
        /*if mmPlayerLayer.currentPlayStatus != .playing {
        mmPlayerLayer.player?.isMuted = !UserDefaults.standard.bool(forKey: videosStartWithSound)
        mmPlayerLayer.currentPlayStatus = .playing
        mmPlayerLayer.player?.play()
        mmPlayerLayer.showCover(isShow: true)
        }*/
        if videoView.isEndPlaying == true {
            videoView.isEndPlaying  = false
            videoView.player?.seek(to: CMTime.zero)
            videoView.resume()
        }else if videoView.state != .playing {
            videoView.resume()
        }
        
    }
    
    func pauseVideo() {
        /*
        if mmPlayerLayer.currentPlayStatus != .pause {
        mmPlayerLayer.player?.isMuted = !UserDefaults.standard.bool(forKey: videosStartWithSound)
        mmPlayerLayer.currentPlayStatus = .pause
        mmPlayerLayer.player?.pause()
        mmPlayerLayer.showCover(isShow: true)
        }*/
        videoView.pause(reason:.userInteraction)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if URL(string:url) != nil {
            if checkMediaTypes(strUrl: url) == 3{
                
            }else {

                var newArray = Array<String>()
                for urlStr in self.urlArray{
                        if checkMediaTypes(strUrl: urlStr) == 1{
                            newArray.append(urlStr)
                        }else{
                           // selIndex = selIndex - 1
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
  
}

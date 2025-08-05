//
//  GSPlayerControlUIView.swift
//  Spotlighter
//
//  Created by Abdullah Ibrahim on 28.02.2021.
//

import UIKit
import CoreMedia


@IBDesignable
class GSPlayerControlUIView: UIView {
    
    // MARK: IBOutlet
    @IBOutlet weak var play_Button: UIButton!
    @IBOutlet weak var duration_Slider: MyCustomSlider!
    @IBOutlet weak var currentDuration_Label: UILabel!
    @IBOutlet weak var totalDuration_Label: UILabel!
    @IBOutlet weak var btnSpeaker: UIButton!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var constThumbImageBottom: NSLayoutConstraint!
    @IBOutlet weak var constBottom: NSLayoutConstraint!
    @IBOutlet weak var stackViewBottom:UIStackView!
    // MARK: Variables
     var videoPlayer: VideoPlayerView!
    
    // MARK: Listeners
    var onStateDidChanged: ((VideoPlayerView.State) -> Void)?
    
    var isManualSeek = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.commonInit()
    }
    
    func commonInit() {
        guard let view = Bundle(for: GSPlayerControlUIView.self).loadNibNamed("GSPlayerControlUIView", owner: self, options: nil)?.first as? UIView else { return }
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.isUserInteractionEnabled = false
        
        self.addSubview(view)
    }
}

// MARK: Functions
extension GSPlayerControlUIView {
    
    func populate(with videoPlayer: VideoPlayerView) {
        self.videoPlayer = videoPlayer
        self.isUserInteractionEnabled = true
        duration_Slider.isContinuous = true
        self.isManualSeek = false
        
        self.currentDuration_Label.text = String(format: "%02d:%02d", 0, 0)
        self.totalDuration_Label.text = String(format: "%02d:%02d", 0, 0)
        self.duration_Slider.setValue(Float(0), animated: false)
        
        setPeriodicTimer()
        setOnClicked_VideoPlayer()
        setStateDidChangedListener()
        
        duration_Slider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSlider(_:))))
        
        duration_Slider.setThumbImage(UIImage(named: "Ellipse"), for: .normal)
        self.updateSpeakerImage()
    }
    
    private func setStateDidChangedListener()  {
        videoPlayer.stateDidChanged = { [weak self] state in
            guard let self = self else { return }
            
            if case .playing = state {
                self.setOnStartPlaying()
            }
                
            switch state {
            case .playing, .paused:
                self.duration_Slider.isEnabled = true
               // self.thumbImageView.isHidden = true
                
            default:
                self.duration_Slider.isEnabled = false
                self.thumbImageView.isHidden = false
            }
               
            
            self.play_Button.setImage(state == .playing ? #imageLiteral(resourceName: "pauseWhite") : #imageLiteral(resourceName: "playA"), for: .normal)
                
            if let listener = self.onStateDidChanged { listener(state) }
        }
        
        videoPlayer.replay = { [weak self] in
            if self != nil
            {
                self!.currentDuration_Label.text = "00:00"
                self!.duration_Slider.setValue(0, animated: false)
            }
        }
        
        self.updateSpeakerImage()
    }
    
    @IBAction func speakerBtnAction(sender:UIButton) {
        if UserDefaults.standard.bool(forKey: videosStartWithSound) == true {
            let imgHeart = UIImage(named: "mutePlayer")
            btnSpeaker.setImage(imgHeart, for: .normal)
            UserDefaults.standard.setValue(false, forKey: videosStartWithSound)
            self.videoPlayer?.player?.isMuted = true
        }else{
            let imgHeart = UIImage(named: "unMutePlayer")
            UserDefaults.standard.setValue(true, forKey: videosStartWithSound)
            self.videoPlayer?.player?.isMuted = false
            btnSpeaker.setImage(imgHeart, for: .normal)
        }
    }
    
    
    func updateSpeakerImage(){
        btnSpeaker.layer.cornerRadius = btnSpeaker.frame.width / 2
        self.videoPlayer?.player?.isMuted = UserDefaults.standard.bool(forKey: videosStartWithSound) ? false : true
        if UserDefaults.standard.bool(forKey: videosStartWithSound)  {
            let imgHeart = UIImage(named: "unMutePlayer")
            btnSpeaker.setImage(imgHeart, for: .normal)
        }else{
            let imgHeart = UIImage(named: "mutePlayer")
            btnSpeaker.setImage(imgHeart, for: .normal)
        }
    }
    
    
    
    private func setOnStartPlaying() {
        let totalDuration = videoPlayer.totalDuration
        duration_Slider.maximumValue = Float(totalDuration)
        totalDuration_Label.text = getTimeString(seconds: Int(totalDuration))
    }
    
    private func setPeriodicTimer() {
        videoPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 60), using: { [weak self] _ in
            if self != nil
            {
                
                if self!.isManualSeek == false {
                    let currentDuration = Float(round(self!.videoPlayer.currentDuration*10)/10)
                    let sliderCurrentvalue = Float(round(self!.duration_Slider.value*10)/10)
                   
                    self!.currentDuration_Label.text = self!.getTimeString(seconds: Int(currentDuration))
                    if currentDuration != sliderCurrentvalue {
                        if currentDuration > 0.2 {
                            self!.duration_Slider.setValue(currentDuration, animated: true)
                        }
                    }
                    if self!.videoPlayer.currentDuration > 0.1 {
                        self!.thumbImageView.isHidden = true
                    }
                }
                
            }
        })
    }
    
    private func getTimeString(seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

// MARK: onClicked
extension GSPlayerControlUIView {
    
    @IBAction func onClicked_Play(_ sender: Any) {
                
        if videoPlayer.isEndPlaying == true {
            videoPlayer.isEndPlaying  = false
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: noti_PauseAllFeedsVideos), object:nil, userInfo: ["tag":play_Button.tag])
            videoPlayer.player?.seek(to: CMTime.zero)
            videoPlayer.resume()
        }else if (videoPlayer.state == .playing) {
            videoPlayer.pause(reason: .userInteraction)
        } else  {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: noti_PauseAllFeedsVideos), object:nil, userInfo: ["tag":play_Button.tag])
            videoPlayer.resume()
            
        }
        self.updateSpeakerImage()
    }
    
    @IBAction func onClicked_Backward(_ sender: Any) {
        videoPlayer.seek(to: CMTime(seconds: Double(max(videoPlayer.currentDuration - 10, 0)), preferredTimescale: 60))
    }
    
    @IBAction func onClicked_Forward(_ sender: Any) {
        videoPlayer.seek(to: CMTime(seconds: Double(min(videoPlayer.currentDuration + 10, videoPlayer.totalDuration)), preferredTimescale: 60))
    }
    
    private func setOnClicked_VideoPlayer() {
        videoPlayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClicked_Video(_:))))
    }
    
    @IBAction func onClicked_Video(_ sender: Any) {
        UIView.animate(withDuration: 0.2) {
            self.alpha = self.alpha == 0 ? 1 : 0
        }
    }
    
    @IBAction func tapSlider(_ gestureRecognizer: UIGestureRecognizer) {
        let pointTapped: CGPoint = gestureRecognizer.location(in: self)
        let positionOfSlider: CGPoint = duration_Slider.frame.origin
        let widthOfSlider: CGFloat = duration_Slider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(duration_Slider.maximumValue) / widthOfSlider)
        
        duration_Slider.setValue(Float(newValue), animated: false)
        onValueChanged_DurationSlider(duration_Slider)
        
    }
    
    @IBAction func onValueChanged_DurationSlider(_ sender: UISlider) {
        self.isManualSeek = true
        self.currentDuration_Label.text = self.getTimeString(seconds: Int(sender.value))
        videoPlayer.seek(to: CMTime(seconds: Double(sender.value), preferredTimescale: 60))
        duration_Slider.setValue(Float(sender.value), animated: false)
        if Int(sender.value) == 0 || sender.value >= Float(videoPlayer.totalDuration){
            self.isManualSeek = false
        }
    }
    
    @IBAction func touchUpInside_DurationSlider(_ sender: UISlider) {
        videoPlayer.seek(to: CMTime(seconds: Double(sender.value), preferredTimescale: 60))
        duration_Slider.setValue(Float(sender.value), animated: false)
        self.isManualSeek = false
        videoPlayer.player?.play()
    }
}

class MyCustomSlider: UISlider {

    @IBInspectable var trackHeight: CGFloat = 2.0

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
         //set your bounds here
        let origin = CGPoint(x: bounds.origin.x, y: 15)
         return CGRect(origin: origin, size: CGSizeMake(bounds.width, trackHeight))
       }
}



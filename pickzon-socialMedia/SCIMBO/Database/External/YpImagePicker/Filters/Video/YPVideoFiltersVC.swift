//
//  VideoFiltersVC.swift
//  YPImagePicker
//
//  Created by Nik Kov || nik-kov.com on 18.04.2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit
import Photos
import PryntTrimmerView
import Stevia

public final class YPVideoFiltersVC: UIViewController, IsMediaFilterVC {

    /// Designated initializer
    public class func initWith(video: YPMediaVideo,
                               isFromSelectionVC: Bool) -> YPVideoFiltersVC {
        let vc = YPVideoFiltersVC()
        vc.inputVideo = video
        vc.isFromSelectionVC = isFromSelectionVC
        return vc
    }

    // MARK: - Public vars

    public var inputVideo: YPMediaVideo!
    public var inputAsset: AVAsset { return AVAsset(url: inputVideo.url) }
    public var didSave: ((YPMediaItem) -> Void)?
    public var didCancel: (() -> Void)?

    // MARK: - Private vars

    private var playbackTimeCheckerTimer: Timer?
    private var imageGenerator: AVAssetImageGenerator?
    private var isFromSelectionVC = false

    private let trimmerContainerView: UIView = {
        let v = UIView()
        return v
    }()
    private let trimmerView: TrimmerView = {
        let v = TrimmerView()
        v.mainColor = YPConfig.colors.trimmerMainColor
        v.handleColor = YPConfig.colors.trimmerHandleColor
        v.positionBarColor = YPConfig.colors.positionLineColor
        v.maxDuration = YPConfig.video.trimmerMaxDuration
        v.minDuration = YPConfig.video.trimmerMinDuration
        return v
    }()
    private let coverThumbSelectorView: ThumbSelectorView = {
        let v = ThumbSelectorView()
        v.thumbBorderColor = YPConfig.colors.coverSelectorBorderColor
        v.isHidden = true
        return v
    }()
   /* private let trimBottomItem: YPMenuItem = {
        let v = YPMenuItem()
        v.textLabel.text = YPConfig.wordings.trim
        v.button.addTarget(self, action: #selector(selectTrim), for: .touchUpInside)
        return v
    }()
     let coverBottomItem: YPMenuItem = {
        let v = YPMenuItem()
        v.textLabel.text = YPConfig.wordings.cover
        v.button.addTarget(self, action: #selector(selectCover), for: .touchUpInside)
        return v
    }()*/
    private let trimBottomItem: YPMenuItem = {
        let v = YPMenuItem()
        v.textLabel.text = "Edit"
        v.button.addTarget(self, action: #selector(editVideo), for: .touchUpInside)
        return v
    }()
     let coverBottomItem: YPMenuItem = {
        let v = YPMenuItem()
        v.textLabel.text = "Merge"
         v.button.addTarget(self, action: #selector(mergeVideo), for: .touchUpInside)
        return v
    }()
    private let videoView: YPVideoView = {
        let v = YPVideoView()
        return v
    }()
    private let coverImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.isHidden = true
        return v
    }()
    
    let btnAddSound:UIButton = UIButton()

    // MARK: - Live cycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        //title = YPConfig.wordings.trim
        view.backgroundColor = YPConfig.colors.filterBackgroundColor
        setupNavigationBar(isFromSelectionVC: self.isFromSelectionVC)
        
        
        btnAddSound.frame = CGRectMake(self.view.frame.width/2 - 100, 10, 200, 20)
        
        if AppDelegate.sharedInstance.soundInfoSelected.name.length > 0 {
            btnAddSound.setTitle(AppDelegate.sharedInstance.soundInfoSelected.name, for: .normal)
            let audioUrl = URL(fileURLWithPath: AppDelegate.sharedInstance.soundInfoSelected.audioLocalURL)
            self.mergeVideoAndAudio(videoUrl: self.inputVideo.url, audioUrl: audioUrl) { error, url in
                if url != nil {
                    self.inputVideo.url = url!
                    DispatchQueue.main.async {
                        self.videoView.loadVideo(self.inputVideo)
                    }
                    
                }
            }
        }else {
            btnAddSound.setTitle("Add Song", for: .normal)
        }
        
        btnAddSound.addTarget(self, action: #selector(addSongButtonTapped), for: .touchUpInside)
        btnAddSound.titleLabel?.textAlignment = .center
        self.view.addSubview(btnAddSound)
        
        
        // Remove the default and add a notification to repeat playback from the start
        videoView.removeReachEndObserver()
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(itemDidFinishPlaying(_:)),
                         name: .AVPlayerItemDidPlayToEndTime,
                         object: nil)
        
        // Set initial video cover
        imageGenerator = AVAssetImageGenerator(asset: self.inputAsset)
        imageGenerator?.appliesPreferredTrackTransform = true
        didChangeThumbPosition(CMTime(seconds: 1, preferredTimescale: 1))
        
        //hide the trimmer view and cover selection view.
        trimmerView.isHidden = true
        coverThumbSelectorView.isHidden = true
        
        
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trimmerView.asset = inputAsset
        trimmerView.delegate = self
        
        coverThumbSelectorView.asset = inputAsset
        coverThumbSelectorView.delegate = self
        
        //selectTrim()
        
        
        videoView.loadVideo(inputVideo)

        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        
        //self.navigationController?.navigationBar.isHidden = true
        stopPlaybackTimeChecker()
        videoView.stop()
        super.viewWillDisappear(animated)
        
    }

    // MARK: - Setup

    private func setupNavigationBar(isFromSelectionVC: Bool) {
        if isFromSelectionVC {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: YPConfig.wordings.cancel,
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(cancel))
            navigationItem.leftBarButtonItem?.setFont(font: YPConfig.fonts.leftBarButtonFont, forState: .normal)
        }
        setupRightBarButtonItem()
    }

    private func setupRightBarButtonItem() {
        let rightBarButtonTitle = isFromSelectionVC ? YPConfig.wordings.done : YPConfig.wordings.next
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: rightBarButtonTitle,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(save))
        navigationItem.rightBarButtonItem?.tintColor = YPConfig.colors.tintColor
        navigationItem.rightBarButtonItem?.setFont(font: YPConfig.fonts.rightBarButtonFont, forState: .normal)
    }

    private func setupLayout() {
        
        view.sv(
            trimBottomItem,
            coverBottomItem,
            videoView,
            coverImageView,
            trimmerContainerView.sv(
                trimmerView,
                coverThumbSelectorView
            )
        )

        trimBottomItem.leading(0).height(40)
        trimBottomItem.Bottom == view.safeAreaLayoutGuide.Bottom
        trimBottomItem.Trailing == coverBottomItem.Leading
        coverBottomItem.Bottom == view.safeAreaLayoutGuide.Bottom
        coverBottomItem.trailing(0)
        equal(sizes: trimBottomItem, coverBottomItem)

        
       // videoView.heightEqualsWidth().fillHorizontally().top(0)
        //videoView.Bottom == trimmerContainerView.Top
        
        //Added Following
        videoView.fillHorizontally().top(0)
        videoView.Bottom == trimBottomItem.Top
        videoView.Trailing == 0
        videoView.Leading == 0
        
        coverImageView.followEdges(videoView)

        trimmerContainerView.fillHorizontally()
        trimmerContainerView.Top == videoView.Bottom
        trimmerContainerView.Bottom == trimBottomItem.Top

        trimmerView.fillHorizontally(m: 30).centerVertically()
        trimmerView.Height == trimmerContainerView.Height / 3

        coverThumbSelectorView.followEdges(trimmerView)
    }

    // MARK: - Actions

    @objc private func save() {
        guard let didSave = didSave else {
            return ypLog("Don't have saveCallback")
        }

        navigationItem.rightBarButtonItem = YPLoaders.defaultLoader

        do {
            let asset = AVURLAsset(url: inputVideo.url)
            let trimmedAsset = try asset
                .assetByTrimming(startTime: trimmerView.startTime ?? CMTime.zero,
                                 endTime: trimmerView.endTime ?? inputAsset.duration)
            
            
            let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingUniquePathComponent(pathExtension: YPConfig.video.fileType.fileExtension)
            
            _ = trimmedAsset.export(to: destinationURL) { [weak self] session in
                switch session.status {
                case .completed:
                    DispatchQueue.main.async {
                        if let coverImage = self?.coverImageView.image {
                            let resultVideo = YPMediaVideo(thumbnail: coverImage,
														   videoURL: destinationURL,
														   asset: self?.inputVideo.asset)
                            didSave(YPMediaItem.video(v: resultVideo))
                            self?.setupRightBarButtonItem()
                        } else {
                            ypLog("Don't have coverImage.")
                        }
                    }
                case .failed:
                    ypLog("Export of the video failed. Reason: \(String(describing: session.error))")
                    
                    if let coverImage = self?.coverImageView.image {
                        let resultVideo = YPMediaVideo(thumbnail: coverImage,
                                                       videoURL: self?.inputVideo.url ?? URL(fileURLWithPath: ""),
                                                       asset: self?.inputVideo.asset)
                        didSave(YPMediaItem.video(v: resultVideo))
                        self?.setupRightBarButtonItem()
                    } else {
                        ypLog("Don't have coverImage.")
                    }
                    
                default:
                    ypLog("Export session completed with \(session.status) status. Not handled")
                }
            }
        } catch let error {
            ypLog("Error: \(error)")
        }
    }
    
    @objc private func cancel() {
        didCancel?()
    }

    // MARK: - Bottom buttons

    @objc private func selectTrim() {
        title = YPConfig.wordings.trim
        
        trimBottomItem.select()
        coverBottomItem.deselect()

        trimmerView.isHidden = false
        videoView.isHidden = false
        coverImageView.isHidden = true
        coverThumbSelectorView.isHidden = true
    }
    
    
    
    @objc private func selectCover() {
        title = YPConfig.wordings.cover
        
        trimBottomItem.deselect()
        coverBottomItem.select()
        
        trimmerView.isHidden = true
        videoView.isHidden = true
        coverImageView.isHidden = false
        coverThumbSelectorView.isHidden = false
        
        stopPlaybackTimeChecker()
        videoView.stop()
    }
    
    @objc private func editVideo() {
        DispatchQueue.main.async {
        let lfVideoEditVC = LFVideoEditingController()
        lfVideoEditVC.delegate = self;
        lfVideoEditVC.minClippingDuration = 5.0;
        lfVideoEditVC.menuBackColor = UIColor.systemBackground
        lfVideoEditVC.headerBackColor = UIColor.systemBackground
        lfVideoEditVC.cancelButtonTitleColorNormal = UIColor.white
        lfVideoEditVC.oKButtonTitleColorNormal = UIColor.white
        lfVideoEditVC.headerTitle = "Video Editing"
        lfVideoEditVC.titleTextColor = UIColor.white
        //lfVideoEditVC.hedaderFont =  [UIFont fontWithName:FONT_BOLD size:18];
            lfVideoEditVC.setVideoURL(self.inputVideo.url, placeholderImage: self.inputVideo.thumbnail)

        self.navigationController?.pushViewController(lfVideoEditVC, animated: true)
        }
    }
    
    
    @objc private func mergeVideo() {
        let nextVC : MergeVideoVC = StoryBoard.feeds.instantiateViewController(withIdentifier: "MergeVideoVC") as! MergeVideoVC
        nextVC.maincolor = UIColor.black
        nextVC.mainBackcolor = UIColor.black
        nextVC.delegate = self
        if self.inputVideo.originalUrl != nil {
            nextVC.mainVideoURL = self.inputVideo.originalUrl
        }else {
            nextVC.mainVideoURL = self.inputVideo.url
        }
        self.navigationController?.pushViewController(nextVC, animated:true)
    }
    
    // MARK: - Various Methods

    // Updates the bounds of the cover picker if the video is trimmed
    // TODO: Now the trimmer framework doesn't support an easy way to do this.
    // Need to rethink a flow or search other ways.
    private func updateCoverPickerBounds() {
        if let startTime = trimmerView.startTime,
            let endTime = trimmerView.endTime {
            if let selectedCoverTime = coverThumbSelectorView.selectedTime {
                let range = CMTimeRange(start: startTime, end: endTime)
                if !range.containsTime(selectedCoverTime) {
                    // If the selected before cover range is not in new trimeed range,
                    // than reset the cover to start time of the trimmed video
                }
            } else {
                // If none cover time selected yet, than set the cover to the start time of the trimmed video
            }
        }
    }
    
    // MARK: - Trimmer playback
    
    @objc private func itemDidFinishPlaying(_ notification: Notification) {
        if let startTime = trimmerView.startTime {
            videoView.player.seek(to: startTime)
        }
    }
    
    private func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer
            .scheduledTimer(timeInterval: 0.05, target: self,
                            selector: #selector(onPlaybackTimeChecker),
                            userInfo: nil,
                            repeats: true)
    }
    
    private func stopPlaybackTimeChecker() {
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    @objc private func onPlaybackTimeChecker() {
        guard let startTime = trimmerView.startTime,
            let endTime = trimmerView.endTime else {
            return
        }
        
        let playBackTime = videoView.player.currentTime()
        trimmerView.seek(to: playBackTime)
        
        if playBackTime >= endTime {
            videoView.player.seek(to: startTime,
                                  toleranceBefore: CMTime.zero,
                                  toleranceAfter: CMTime.zero)
            trimmerView.seek(to: startTime)
        }
    }
}

// MARK: - TrimmerViewDelegate
extension YPVideoFiltersVC: TrimmerViewDelegate {
    public func positionBarStoppedMoving(_ playerTime: CMTime) {
        videoView.player.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        videoView.play()
        startPlaybackTimeChecker()
        updateCoverPickerBounds()
    }
    
    public func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        videoView.pause()
        videoView.player.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
}

// MARK: - ThumbSelectorViewDelegate
extension YPVideoFiltersVC: ThumbSelectorViewDelegate {
    public func didChangeThumbPosition(_ imageTime: CMTime) {
        if let imageGenerator = imageGenerator,
            let imageRef = try? imageGenerator.copyCGImage(at: imageTime, actualTime: nil) {
            coverImageView.image = UIImage(cgImage: imageRef)
        }
    }
}


extension YPVideoFiltersVC: LFVideoEditingControllerDelegate{
    public func lf_VideoEditingController(_ videoEditingVC: LFVideoEditingController!, didCancelPhotoEdit videoEdit: LFVideoEdit!) {
        videoEditingVC.navigationController?.popViewController(animated: true)
        
    }
    public func lf_VideoEditingController(_ videoEditingVC: LFVideoEditingController!, didFinishPhotoEdit videoEdit: LFVideoEdit!) {
        if videoEdit != nil {
            if videoEdit.editFinalURL != nil {
                inputVideo.url = videoEdit.editFinalURL
                self.inputVideo.originalUrl = videoEdit.editFinalURL
            }
        }
        videoEditingVC.navigationController?.popViewController(animated: true)
    }
}

extension YPVideoFiltersVC: LFVideoMergedControllerDelegate{
    public func lf_VideoMergedController(_ videoVC: MergeVideoVC!, didCancelVideoMerged url: URL!) {
        videoVC.navigationController?.popViewController(animated: true)
    }
    public func lf_VideoMergedController(_ videoVC: MergeVideoVC!, didFinishVideoMerged url: URL!) {
        if url != nil {
            inputVideo.url = url
        }
        videoVC.navigationController?.popViewController(animated: true)
    }
    
}


extension YPVideoFiltersVC: onSongSelectionDelegate {
    @objc func addSongButtonTapped() {
        print("addSongButtonTapped")
        let viewController:SpotifyCategoriesVC = StoryBoard.spotify.instantiateViewController(withIdentifier: "SpotifyCategoriesVC") as! SpotifyCategoriesVC
        viewController.onSongSelection = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    //MARK: Song Selected Delegate Methods
    func onSelection(id: String, url: String,name:String, timeLimit: Int,thumbUrl:String,originalUrl:String) {
       
        AppDelegate.sharedInstance.soundInfoSelected = SoundInfo(dict: [:])
        AppDelegate.sharedInstance.soundInfoSelected.id = id
        AppDelegate.sharedInstance.soundInfoSelected.name = name
        AppDelegate.sharedInstance.soundInfoSelected.audio = originalUrl
        AppDelegate.sharedInstance.soundInfoSelected.thumb = thumbUrl
        AppDelegate.sharedInstance.soundInfoSelected.audioLocalURL = url
        
        
        DispatchQueue.main.async {
            self.btnAddSound.setTitle(name, for: .normal)
        }
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let audioUrl = URL(fileURLWithPath: AppDelegate.sharedInstance.soundInfoSelected.audioLocalURL)
        self.mergeVideoAndAudio(videoUrl: self.inputVideo.url, audioUrl: audioUrl) { error, url in
            if url != nil {
                self.inputVideo.url = url!
                self.videoView.loadVideo(self.inputVideo)
            }
        }
    }
    
    func mergeVideoAndAudio(videoUrl: URL,
                            audioUrl: URL,
                            shouldFlipHorizontally: Bool = false,
                            completion: @escaping (_ error: Error?, _ url: URL?) -> Void) {

        Themes.sharedInstance.activityView(View: self.view)

        
        let mixComposition = AVMutableComposition()
        var mutableCompositionVideoTrack = [AVMutableCompositionTrack]()
        var mutableCompositionAudioTrack = [AVMutableCompositionTrack]()
        var mutableCompositionAudioOfVideoTrack = [AVMutableCompositionTrack]()

        //start merge

        let aVideoAsset = AVAsset(url: videoUrl)
        let aAudioAsset = AVAsset(url: audioUrl)

        let compositionAddVideo = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                                       preferredTrackID: kCMPersistentTrackID_Invalid)
        
        
        let compositionAddAudio = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                 preferredTrackID: kCMPersistentTrackID_Invalid)!

        let compositionAddAudioOfVideo = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                            preferredTrackID: kCMPersistentTrackID_Invalid)

        let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaType.video)[0]
        let aAudioOfVideoAssetTrack: AVAssetTrack? = aVideoAsset.tracks(withMediaType: AVMediaType.audio).first
        let aAudioAssetTrack: AVAssetTrack? = aAudioAsset.tracks(withMediaType: AVMediaType.audio).first

        // Default must have tranformation
        compositionAddVideo?.preferredTransform = aVideoAssetTrack.preferredTransform

        if shouldFlipHorizontally {
            // Flip video horizontally
            var frontalTransform: CGAffineTransform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            frontalTransform = frontalTransform.translatedBy(x: -aVideoAssetTrack.naturalSize.width, y: 0.0)
            frontalTransform = frontalTransform.translatedBy(x: 0.0, y: -aVideoAssetTrack.naturalSize.width)
            compositionAddVideo?.preferredTransform = frontalTransform
        }

        mutableCompositionVideoTrack.append(compositionAddVideo!)
        mutableCompositionAudioTrack.append(compositionAddAudio)
        mutableCompositionAudioOfVideoTrack.append(compositionAddAudioOfVideo!)

        do {
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                                                                duration: aVideoAssetTrack.timeRange.duration),
                                                                of: aVideoAssetTrack,
                                                                at: CMTime.zero)

            //In my case my audio file is longer then video file so i took videoAsset duration
            //instead of audioAsset duration
            if let aAudioAssetTrack = aAudioAssetTrack {
                try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                                                                    duration: aVideoAssetTrack.timeRange.duration),
                                                                    of: aAudioAssetTrack,
                                                                    at: CMTime.zero)
            }

          /*  // adding audio (of the video if exists) asset to the final composition
            if let aAudioOfVideoAssetTrack = aAudioOfVideoAssetTrack {
                try mutableCompositionAudioOfVideoTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                                                                           duration: aVideoAssetTrack.timeRange.duration),
                                                                           of: aAudioOfVideoAssetTrack,
                                                                           at: CMTime.zero)
            }*/
        } catch {
            print(error.localizedDescription)
        }

        // Exporting
        //let savePathUrl: URL = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/newVideo.mp4")
        let savePathUrl : URL = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/\(Int64(Date().timeIntervalSince1970))pickZone.mp4")
        do { // delete old video
            try FileManager.default.removeItem(at: savePathUrl)
        } catch { print(error.localizedDescription) }

        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = savePathUrl
        assetExport.shouldOptimizeForNetworkUse = true

        assetExport.exportAsynchronously { () -> Void in
            DispatchQueue.main.async{
                Themes.sharedInstance.RemoveactivityView(View: self.view)
            }
            switch assetExport.status {
            case AVAssetExportSession.Status.completed:
                print("success")
                completion(nil, savePathUrl)
            case AVAssetExportSession.Status.failed:
                print("failed \(assetExport.error?.localizedDescription ?? "error nil")")
                completion(assetExport.error, nil)
            case AVAssetExportSession.Status.cancelled:
                print("cancelled \(assetExport.error?.localizedDescription ?? "error nil")")
                completion(assetExport.error, nil)
            default:
                print("complete")
                completion(assetExport.error, nil)
            }
        }

    }
}

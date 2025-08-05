//
//  YPVideoHelper.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 27/01/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion
import DeepAR


/// Abstracts Low Level AVFoudation details.
class YPVideoCaptureHelper: NSObject {
    public var isRecording: Bool {
       // return videoOutput.isRecording
        return isVideoRecording
    }
    public var didCaptureVideo: ((URL) -> Void)?
    public var videoRecordingProgress: ((Float, TimeInterval) -> Void)?
    
    private let session = AVCaptureSession()
    public var timer = Timer()
    private var dateVideoStarted = Date()
    private let sessionQueue = DispatchQueue(label: "YPVideoCaptureHelperQueue")
    private var videoInput: AVCaptureDeviceInput?
    private var videoOutput = AVCaptureMovieFileOutput()
    private var videoRecordingTimeLimit: TimeInterval = 0
    private var isCaptureSessionSetup: Bool = false
    private var isPreviewSetup = false
    public var previewView: UIView!
    private var motionManager = CMMotionManager()
    private var initVideoZoomFactor: CGFloat = 1.0
    
    public var isVideoRecording = false
    //

    //Implementing Deep AR Effects
    var cameraController: CameraController?
    public var deepAR: DeepAR?
    private var deepARView:UIView?
    private var currentRecordingMode: RecordingMode! {
        didSet {
            updateRecordingModeAppearance()
        }
    }
    
    var filterIndex = 0
    
   
    
    func setupDeepARAndCamera() {
        self.deepAR = DeepAR()
        self.deepAR?.delegate = self
        self.deepAR?.setLicenseKey(Settings.sharedInstance.deepARLicenseKey)
        self.deepAR?.videoRecordingWarmupEnabled = false
        cameraController = CameraController(deepAR: self.deepAR)
        if let deepARView = deepAR?.createARView(withFrame: self.previewView.frame) {
            self.deepARView = deepARView
            self.deepARView?.frame = self.previewView.frame
            self.previewView.insertSubview(self.deepARView!, at: 0)
        }
        cameraController?.startCamera()
        
    }
    
    private func updateRecordingModeAppearance() {
        
       // buttonRecordingModePairs.forEach { (button, recordingMode) in
          //  button.isSelected = recordingMode == currentRecordingMode
       // }
    }
    //
    
    // MARK: - Init
    
    public func start(previewView: UIView, withVideoRecordingLimit: TimeInterval, completion: @escaping () -> Void) {
        self.previewView = previewView
        self.videoRecordingTimeLimit = withVideoRecordingLimit
        
        // added by me
        let timeScale: Int32 = 30 // FPS
        let maxDuration =
            CMTimeMakeWithSeconds(self.videoRecordingTimeLimit, preferredTimescale: timeScale)
        videoOutput.maxRecordedDuration = maxDuration
        if let sizeLimit = YPConfig.video.recordingSizeLimit {
            videoOutput.maxRecordedFileSize = sizeLimit
        }
        videoOutput.minFreeDiskSpaceLimit = YPConfig.video.minFreeDiskSpaceLimit
        if YPConfig.video.fileType == .mp4,
           YPConfig.video.recordingSizeLimit != nil {
            videoOutput.movieFragmentInterval = .invalid // Allows audio for MP4s over 10 seconds.
        }
        self.setupDeepARAndCamera()
        //
        
       /* sessionQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            if !strongSelf.isCaptureSessionSetup {
                strongSelf.setupCaptureSession()
            }
            strongSelf.startCamera(completion: {
                completion()
            })
        }
        */
        
    }
    
    
    public func removeLoader(){
        
        if self.previewView != nil {
            Themes.sharedInstance.RemoveactivityView(View: self.previewView)
        }

    }
    // MARK: - Start Camera
    
    public func startCamera(completion: @escaping (() -> Void)) {
        guard !session.isRunning else {
            print("Session is already running. Returning.")
            return
        }

        sessionQueue.async { [weak self] in
            // Re-apply session preset
            self?.session.sessionPreset = .photo
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch status {
            case .notDetermined, .restricted, .denied:
                self?.session.stopRunning()
            case .authorized:
                self?.session.startRunning()
                completion()
                self?.tryToSetupPreview()
            @unknown default:
                ypLog("unknown default reached. Check code.")
            }
        }
    }
    
    // MARK: - Flip Camera
    
    public func flipCamera(completion: @escaping () -> Void) {
       /* sessionQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.session.beginConfiguration()
            strongSelf.session.resetInputs()
            
            if let videoInput = strongSelf.videoInput {
                strongSelf.videoInput = flippedDeviceInputForInput(videoInput)
            }
            
            if let videoInput = strongSelf.videoInput {
                if strongSelf.session.canAddInput(videoInput) {
                    strongSelf.session.addInput(videoInput)
                }
            }
            
            // Re Add audio recording
            if let audioDevice = AVCaptureDevice.audioCaptureDevice,
               let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
               strongSelf.session.canAddInput(audioInput) {
                strongSelf.session.addInput(audioInput)
            }

            strongSelf.session.commitConfiguration()

            DispatchQueue.main.async {
                completion()
            }
        }
        */
        
        if cameraController?.position == .front {
            cameraController?.position = .back
        }else {
            cameraController?.position = .front
        }
    }
    
    // MARK: - Focus
    
    public func focus(onPoint point: CGPoint) {
        if let device = videoInput?.device {
            setFocusPointOnDevice(device: device, point: point)
        }
    }
    
    // MARK: - Zoom
    
    public func zoom(began: Bool, scale: CGFloat) {
        guard let device = videoInput?.device else {
            return
        }

        if began {
            initVideoZoomFactor = device.videoZoomFactor
            return
        }

        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }

            var minAvailableVideoZoomFactor: CGFloat = 1.0
            if #available(iOS 11.0, *) {
                minAvailableVideoZoomFactor = device.minAvailableVideoZoomFactor
            }
            var maxAvailableVideoZoomFactor: CGFloat = device.activeFormat.videoMaxZoomFactor
            if #available(iOS 11.0, *) {
                maxAvailableVideoZoomFactor = device.maxAvailableVideoZoomFactor
            }
            maxAvailableVideoZoomFactor = min(maxAvailableVideoZoomFactor, YPConfig.maxCameraZoomFactor)

            let desiredZoomFactor = initVideoZoomFactor * scale
            device.videoZoomFactor = max(minAvailableVideoZoomFactor,
                                         min(desiredZoomFactor, maxAvailableVideoZoomFactor))
        } catch let error {
            ypLog("Error: \(error)")
        }
    }
    
    // MARK: - Stop Camera
    
    public func stopCamera() {
        
    
        cameraController?.deepAR?.pause()
        deepAR?.pause()
        deepAR?.shutdown()
        cameraController?.deepAR?.shutdown()
        deepAR = nil
        cameraController = nil
        self.deepARView?.removeFromSuperview()
//        guard session.isRunning else {
//            return
//        }
//
//        sessionQueue.async { [weak self] in
//            self?.session.stopRunning()
//        }
    }
    
    // MARK: - Torch
    
    public func hasTorch() -> Bool {
        return videoInput?.device.hasTorch ?? false
    }
    
    public func currentTorchMode() -> AVCaptureDevice.TorchMode {
        guard let device = videoInput?.device else {
            return .off
        }
        if !device.hasTorch {
            return .off
        }
        return device.torchMode
    }
    
    public func toggleTorch() {
        videoInput?.device.tryToggleTorch()
    }
    
    // MARK: - Recording
    
    public func startRecording() {
      /*  let outputURL = YPVideoProcessor.makeVideoPathURL(temporaryFolder: true, fileName: "recordedVideoRAW")

        checkOrientation { [weak self] orientation in
            guard let strongSelf = self else {
                return
            }
            if let connection = strongSelf.videoOutput.connection(with: .video) {
                if let orientation = orientation, connection.isVideoOrientationSupported {
                    connection.videoOrientation = orientation
                }
                
                strongSelf.videoOutput.movieFragmentInterval = .invalid
                
                strongSelf.videoOutput.startRecording(to: outputURL, recordingDelegate: strongSelf)
            }
        }
        */
        didTapRecordActionButton()
    }
    
    public func stopRecording() {
        didTapRecordActionButton()
        videoOutput.stopRecording()
        deepAR?.finishVideoRecording()
    }
    
    // Private
    
    private func setupCaptureSession() {
        session.beginConfiguration()
        let cameraPosition: AVCaptureDevice.Position = YPConfig.usesFrontCamera ? .front : .back
        let aDevice = AVCaptureDevice.deviceForPosition(cameraPosition)
        
        if let d = aDevice {
            videoInput = try? AVCaptureDeviceInput(device: d)
        }
        
        if let videoInput = videoInput {
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }
            
            // Add audio recording
            if let audioDevice = AVCaptureDevice.audioCaptureDevice,
               let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
               session.canAddInput(audioInput) {
                session.addInput(audioInput)
            }

            let timeScale: Int32 = 30 // FPS
            let maxDuration =
                CMTimeMakeWithSeconds(self.videoRecordingTimeLimit, preferredTimescale: timeScale)
            videoOutput.maxRecordedDuration = maxDuration
            if let sizeLimit = YPConfig.video.recordingSizeLimit {
                videoOutput.maxRecordedFileSize = sizeLimit
            }
            videoOutput.minFreeDiskSpaceLimit = YPConfig.video.minFreeDiskSpaceLimit
            if YPConfig.video.fileType == .mp4,
               YPConfig.video.recordingSizeLimit != nil {
                videoOutput.movieFragmentInterval = .invalid // Allows audio for MP4s over 10 seconds.
                
            }
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }
            session.sessionPreset = .high
        }
        session.commitConfiguration()
        isCaptureSessionSetup = true
    }
    
    // MARK: - Recording Progress
    
    @objc
    func tick() {
        let timeElapsed = Date().timeIntervalSince(dateVideoStarted)
        var progress: Float
        if let recordingSizeLimit = YPConfig.video.recordingSizeLimit {
            progress = Float(videoOutput.recordedFileSize) / Float(recordingSizeLimit)
        } else {
            progress = Float(timeElapsed) / Float(videoRecordingTimeLimit)
        }
        // VideoOutput configuration is responsible for stopping the recording. Not here.
        DispatchQueue.main.async {
            self.videoRecordingProgress?(progress, timeElapsed)
        }
        if timeElapsed >= videoRecordingTimeLimit - 1{
            self.didTapRecordActionButton()
        }
    }
    
    // MARK: - Orientation

    /// This enables to get the correct orientation even when the device is locked for orientation \o/
    private func checkOrientation(completion: @escaping(_ orientation: AVCaptureVideoOrientation?) -> Void) {
        motionManager.accelerometerUpdateInterval = 5
        motionManager.startAccelerometerUpdates( to: OperationQueue() ) { [weak self] data, _ in
            self?.motionManager.stopAccelerometerUpdates()
            guard let data = data else {
                completion(nil)
                return
            }
            let orientation: AVCaptureVideoOrientation = abs(data.acceleration.y) < abs(data.acceleration.x)
                ? data.acceleration.x > 0 ? .landscapeLeft : .landscapeRight
                : data.acceleration.y > 0 ? .portraitUpsideDown : .portrait
            DispatchQueue.main.async {
                completion(orientation)
            }
        }
    }

    // MARK: - Preview
    
    func tryToSetupPreview() {
        if !isPreviewSetup {
            setupPreview()
            isPreviewSetup = true
        }
    }
    
    func setupPreview() {
        let videoLayer = AVCaptureVideoPreviewLayer(session: session)
        DispatchQueue.main.async {
            videoLayer.frame = self.previewView.bounds
            videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.previewView.layer.addSublayer(videoLayer)
        }
    }
}

extension YPVideoCaptureHelper: AVCaptureFileOutputRecordingDelegate {
    
    public func fileOutput(_ captureOutput: AVCaptureFileOutput,
                           didStartRecordingTo fileURL: URL,
                           from connections: [AVCaptureConnection]) {
      /*  timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(tick),
                                     userInfo: nil,
                                     repeats: true)
        dateVideoStarted = Date()*/
    }
    
    public func fileOutput(_ captureOutput: AVCaptureFileOutput,
                           didFinishRecordingTo outputFileURL: URL,
                           from connections: [AVCaptureConnection],
                           error: Error?) {
       /* if let error = error {
            ypLog("Error: \(error)")
        }

        if YPConfig.onlySquareImagesFromCamera {
            YPVideoProcessor.cropToSquare(filePath: outputFileURL) { [weak self] url in
                guard let _self = self, let u = url else { return }
                _self.didCaptureVideo?(u)
            }
        } else {
            self.didCaptureVideo?(outputFileURL)
        }
        timer.invalidate()*/
    }
}


// MARK: - ARViewDelegate -

extension YPVideoCaptureHelper: DeepARDelegate {
    
    
    @objc
    private func didTapRecordActionButton() {
        currentRecordingMode = .video
//        if (currentRecordingMode == RecordingMode.photo) {
//            deepARView.takeScreenshot()
//            return
//        }

    
        if (isVideoRecording) {
            deepAR?.finishVideoRecording()
            isVideoRecording = false
            Themes.sharedInstance.activityView(View: self.previewView)
            return
        }
        
        
        let width: Int32 = Int32(deepAR?.renderingResolution.width ?? 0)
        let height: Int32 =  Int32(deepAR?.renderingResolution.height ?? 0)
        
        if (currentRecordingMode == RecordingMode.video) {
            if(deepAR!.videoRecordingWarmupEnabled) {
                deepAR!.resumeVideoRecording()
            } else {
                deepAR!.startVideoRecording(withOutputWidth: width, outputHeight: height)
            }
            deepAR!.delegate = self
           // isRecordingInProcess = true
            self.isVideoRecording = true
            

            return
        }
        
        if (currentRecordingMode == RecordingMode.lowQualityVideo) {
            if(deepAR!.videoRecordingWarmupEnabled) {
                NSLog("Can't change video recording settings when video recording warmap enabled")
                return
            }
            let videoQuality = 0.1
            let bitrate =  1250000
            let videoSettings:[AnyHashable : AnyObject] = [
                AVVideoQualityKey : (videoQuality as AnyObject),
                AVVideoAverageBitRateKey : (bitrate as AnyObject)
            ]
            
            let frame = CGRect(x: 0, y: 0, width: 1, height: 1)
            
            deepAR!.startVideoRecording(withOutputWidth: width, outputHeight: height, subframe: frame, videoCompressionProperties: videoSettings, recordAudio: true)
            isVideoRecording = true
        }
        
    }
  
    func didFinishPreparingForVideoRecording() {
        NSLog("didFinishPreparingForVideoRecording!!!!!")
    }
    
    func didStartVideoRecording() {
        NSLog("didStartVideoRecording!!!!!")
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(tick),
                                     userInfo: nil,
                                     repeats: true)
        dateVideoStarted = Date()
    }
    
    func didFinishVideoRecording(_ videoFilePath: String!) {
        
        
        NSLog("didFinishVideoRecording!!!!!")

        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let components = videoFilePath.components(separatedBy: "/")
        guard let last = components.last else { return }
        let outputFileURL = URL(fileURLWithPath: String(format: "%@/%@", documentsDirectory, last))
       
        if YPConfig.onlySquareImagesFromCamera {
            YPVideoProcessor.cropToSquare(filePath: outputFileURL) { [weak self] url in

                guard let _self = self, let u = url else { return }
                _self.didCaptureVideo?(u)
              //  Themes.sharedInstance.RemoveactivityView(View: self!.previewView)

            }
        } else {
            self.didCaptureVideo?(outputFileURL)
           // Themes.sharedInstance.RemoveactivityView(View: self.previewView)

        }
        timer.invalidate()

    }
    
    
    func recordingFailedWithError(_ error: Error!) {
        Themes.sharedInstance.RemoveactivityView(View: self.previewView)

    }
    
    func didTakeScreenshot(_ screenshot: UIImage!) {
     /*   UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil)
        
        let imageView = UIImageView(image: screenshot)
        imageView.frame = view.frame
        view.insertSubview(imageView, aboveSubview: arView)
        
        let flashView = UIView(frame: view.frame)
        flashView.alpha = 0
        flashView.backgroundColor = .black
        view.insertSubview(flashView, aboveSubview: imageView)
        
        UIView.animate(withDuration: 0.1, animations: {
            flashView.alpha = 1
        }) { _ in
            flashView.removeFromSuperview()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                imageView.removeFromSuperview()
            }
        }*/
    }
    
    func didInitialize() {
        if (deepAR!.videoRecordingWarmupEnabled) {
            DispatchQueue.main.async { [self] in
                let width: Int32 = Int32(deepAR!.renderingResolution.width)
                let height: Int32 =  Int32(deepAR!.renderingResolution.height)
                deepAR!.startVideoRecording(withOutputWidth: width, outputHeight: height)
            }
        }
    }
 
    func didFinishShutdown (){
        NSLog("didFinishShutdown!!!!!")
    }
    
    
    func faceVisiblityDidChange(_ faceVisible: Bool) { }
}

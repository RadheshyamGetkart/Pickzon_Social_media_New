//
//  PreviewVC.swift
//  SCIMBO
//
//  Created by SachTech on 10/08/20.
//  Copyright © 2020 CASPERON. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import AssetsLibrary
import IQKeyboardManager

protocol onCancelClick: AnyObject {
  func onDismiss()
}

protocol onDonePreviewClick: AnyObject {
    func onDone(soundID:String,url:URL,fileName:String)
    
}

class PreviewVC: UIViewController {
  
    var url:URL?
    var fileName = ""
    var soundID = "0"
    @IBOutlet weak var videoView :UIView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var btnDone: UIButton!

    var onCancel:onCancelClick?
    var parentVC: RecordVideoVC?
    var onDone:onDonePreviewClick?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("UIViewController: PreviewVC")
        play()
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        NotificationCenter.default
            .addObserver(self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
        self.btnCross.layer.cornerRadius = self.btnCross.frame.size.height/2.0
        self.btnCross.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        self.btnDone.layer.cornerRadius = self.btnDone.frame.size.height/2.0
        self.btnDone.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        PlayerHelper.shared.pausePlayer()
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        PlayerHelper.shared.seekTimeto(seekTo: 0.0)
        playBtn.setImage(UIImage(named: "playIcon"), for: .normal)
    }
  
    
    @objc func rotated() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        super.viewWillDisappear(animated)
        
    }
    
    @IBAction func closeView(_ sender: Any) {
        if FileManager.default.fileExists(atPath: url?.absoluteString ?? "") {
            do {
                try FileManager.default.removeItem(atPath: url?.absoluteString ?? "")
            } catch { }
        }
        
        self.onCancel?.onDismiss()
       // DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.dismissView(animated: true)
       // }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            if FileManager.default.fileExists(atPath: self.url?.absoluteString ?? "") {
                do {
                    try FileManager.default.removeItem(atPath: self.url?.absoluteString ?? "")
                } catch { }
            }
            if self.onDone == nil {
                self.onCancel?.onDismiss()
            }
        }
        PlayerHelper.shared.pause()
        
    }
    
    func play()
    {
        DispatchQueue.main.async {
            print(self.url!.absoluteString)
            PlayerHelper.shared.pausePlayer()
            PlayerHelper.shared.startPlayer(url: self.url!.absoluteString, view: self.view)
            let playerLayer = PlayerHelper.shared.showplayerLayer()
            self.videoView.layer.addSublayer(playerLayer)
            PlayerHelper.shared.playPlayer()
        }
        
    }
    
    @IBAction func playPause(_ sender: Any) {
        if playBtn.image(for: .normal) == UIImage(named: "playIcon")
        {
            //play()
            PlayerHelper.shared.play()
            playBtn.setImage(UIImage(named: "pauseIcon"), for: .normal)

        }
        else{
            playBtn.setImage(UIImage(named: "playIcon"), for: .normal)
        //PlayerHelper.shared.pausePlayer()
            PlayerHelper.shared.pause()
        }}
    
    @IBAction func done(_ sender: Any) {
        PlayerHelper.shared.pausePlayer()
        
        if onDone != nil {
            //For Story for feeds if needed delegate call
            onDone?.onDone(soundID: soundID, url: url!, fileName: fileName)
            self.dismiss(animated: false)
             
        }else{
            
            //let vc = self.storyboard?.instantiateViewController(withIdentifier: "PostVideoVc") as! PostVideoVC
            
            if let vc = StoryBoard.main.instantiateViewController(withIdentifier: "PostClipVC") as? PostClipVC {
                var songInfo = SoundInfo(dict: [:])
                songInfo.id = soundID
                vc.clipObj = WallPostModel(dict: [:])
                vc.clipObj.soundInfo = songInfo
                vc.url = url
               // vc.fileName = fileName
               // vc.onSuccess = parentVC
                vc.modalPresentationStyle = .fullScreen
                if let nav = self.presentingViewController as? UINavigationController{
                    PlayerHelper.shared.pausePlayer()
                    playBtn.setImage(UIImage(named: "playIcon"), for: .normal)
                    nav.presentView(vc, animated: true)
                }
            }
        }
    }
}

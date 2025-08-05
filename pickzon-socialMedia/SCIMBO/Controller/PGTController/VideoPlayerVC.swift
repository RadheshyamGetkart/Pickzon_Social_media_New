//
//  VideoPlayerVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 12/07/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoPlayerVC: UIViewController {

    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var bgVideoView:UIView!
    var videoURL = ""
    var strTitle = ""
    var player: AVPlayer!
    var avpController = AVPlayerViewController()
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        
        if let url = URL(string:videoURL){
            player = AVPlayer(url: url)
            avpController.player = player
            avpController.view.frame.size.height = bgVideoView.frame.size.height
            avpController.view.frame.size.width = bgVideoView.frame.size.width
            self.bgVideoView.addSubview(avpController.view)
            player.play()
        }
    }
    

    //MARK: UIButton Action Methods
    @IBAction func backButtonActionMethod(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}

//
//  CoinUpSuccessAlertView.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/26/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher
import AVFoundation

class CoinUpSuccessAlertView: UIView {
    
    @IBOutlet weak var lblMessage:UILabel!
    @IBOutlet weak var imgVwCoin:UIImageView!
    @IBOutlet weak var bgView:UIView!
    var timerTest: Timer? = nil
    var player: AVAudioPlayer?

    func initializeMethods(frame:CGRect,message:String,icon:String)  {
        self.removeFromSuperview()
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        lblMessage.text = "CoinUp \(message)"

        UIView.animate(withDuration: 0.1) {

            self.imgVwCoin.frame = CGRectMake(self.imgVwCoin.frame.origin.x, self.imgVwCoin.frame.origin.y, self.imgVwCoin.frame.size.width + 100, self.imgVwCoin.frame.size.height + 100)
        }
        
       
//        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
//                
//               // HERE
//            self.imgVwCoin.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5) // Scale your image
//
//         }) { (finished) in
//             UIView.animate(withDuration: 1, animations: {
//               
//              self.imgVwCoin.transform = CGAffineTransform.identity // undo in 1 seconds
//
//           })
//        }
      
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        if   let url = Bundle.main.url(forResource: "jazzclap", withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        
        view.backgroundColor =  UIColor.black.withAlphaComponent(0.5)
        bgView.backgroundColor =  UIColor.black.withAlphaComponent(0.5)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnView)))
        timerTest =  Timer.scheduledTimer(
            timeInterval: TimeInterval(0.5),
              target      : self,
              selector    : #selector(tapOnView),
              userInfo    : nil,
              repeats     : true)
    }
  
    @objc func tapOnView(){
        self.removeFromSuperview()
        timerTest = nil
        player = nil
    }
    

    
}

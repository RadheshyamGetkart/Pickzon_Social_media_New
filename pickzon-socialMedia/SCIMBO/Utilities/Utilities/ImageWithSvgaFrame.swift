//
//  ImageWithSvgaFrame.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 2/26/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import SVGAPlayer

class ImageWithSvgaFrame: UIView {
    
    var imgVwProfile:UIImageView? = nil
   // var imgVwFrame:IgnoreTouchImageView? = nil
    var remoteSVGAPlayer:SVGAPlayer? = nil

    
    func initializeView() {
        
        // Drawing code
        self.backgroundColor = .clear
        imgVwProfile = UIImageView()
        // imgVwFrame = IgnoreTouchImageView()
        //imgVwFrame?.contentMode = .scaleAspectFill
        
        self.imgVwProfile?.frame = CGRectMake(8, 8, self.frame.size.width-16, self.frame.size.height-16)
        self.imgVwProfile?.layer.cornerRadius = (self.imgVwProfile?.frame.size.height ?? 0)/2.0
        self.imgVwProfile?.clipsToBounds = true
        
        //self.isPlayingGift = true
        self.remoteSVGAPlayer?.stopAnimation()
        
        if remoteSVGAPlayer == nil {
            remoteSVGAPlayer = SVGAPlayer(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
            remoteSVGAPlayer?.backgroundColor = .clear
            //remoteSVGAPlayer?.delegate = self
            remoteSVGAPlayer?.loops = 0
            remoteSVGAPlayer?.clearsAfterStop = false
        }
        self.remoteSVGAPlayer?.contentMode = .scaleAspectFill
        self.remoteSVGAPlayer?.isUserInteractionEnabled = true
        self.addSubview(self.imgVwProfile!)
        self.addSubview(self.remoteSVGAPlayer!)
    }
    
    
    func updateFrame(changeValue:Int=2) {
        
        self.imgVwProfile?.frame = CGRectMake(CGFloat(changeValue), CGFloat(changeValue), self.frame.size.width-CGFloat((2*changeValue)), self.frame.size.height-CGFloat((changeValue*2)))
        self.imgVwProfile?.layer.cornerRadius = (self.imgVwProfile?.frame.size.height ?? 0)/2.0
        self.imgVwProfile?.clipsToBounds = true
        self.remoteSVGAPlayer?.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
    }
    
    
    @objc func setImgView(profilePic:String,remoteSVGAUrl:String,changeValue:Int = 12){
        
        self.imgVwProfile?.kf.setImage(with: URL(string: profilePic), placeholder: PZImages.avatar , options: nil, progressBlock: nil, completionHandler: { response in        })
        
        if remoteSVGAUrl.length > 0{
            self.updateFrame(changeValue: changeValue)
            
            if let url = URL(string: remoteSVGAUrl) {
                let remoteSVGAParser = SVGAParser()
                remoteSVGAParser.enabledMemoryCache = true
                
                remoteSVGAParser.parse(with: url, completionBlock: { (svgaItem) in
                    self.remoteSVGAPlayer?.videoItem = svgaItem
                    self.remoteSVGAPlayer?.startAnimation()
                }, failureBlock: { (error) in
                    print("--------------------- \(String(describing: error))")
                    
                })
            }
            
        }else{
            self.remoteSVGAPlayer?.stopAnimation()
            self.remoteSVGAPlayer?.clear()
            self.updateFrame()
        }
    }
    
}

//
//  ImageWithSvgaFrame.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 2/26/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import SVGAPlayer
import Kingfisher

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
        
        
        let processor = CroppingImageProcessor(size: CGSize(width: self.frame.width, height: self.frame.height), anchor: CGPoint(x: 0.5, y: 0.5))

        self.imgVwProfile?.kf.setImage(with: URL(string: profilePic), placeholder: PZImages.avatar , options: [.processor(processor)], progressBlock: nil, completionHandler: { response in        })
        
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



extension UIImage {
    func centerCropped(to size: CGSize) -> UIImage? {
        let scale = max(size.width / self.size.width, size.height / self.size.height)
        let width = size.width / scale
        let height = size.height / scale
        let x = (self.size.width - width) / 2.0
        let y = (self.size.height - height) / 2.0
        let cropRect = CGRect(x: x, y: y, width: width, height: height)

        guard let cgImage = self.cgImage?.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
    }
}

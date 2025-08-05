//
//  ImageWithFrameImgView.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 2/15/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher

class ImageWithFrameImgView: UIView {

    var imgVwProfile:UIImageView? = nil
    var imgVwFrame:IgnoreTouchImageView? = nil
    
   
    
    func initializeView() {
        
        // Drawing code
        self.backgroundColor = .clear
        imgVwProfile = UIImageView()
        imgVwFrame = IgnoreTouchImageView()
        //imgVwFrame?.contentMode = .scaleAspectFill
        
        self.imgVwProfile?.frame = CGRectMake(10, 10, self.frame.size.width-20, self.frame.size.height-20)
        
        self.imgVwProfile?.layer.cornerRadius = (self.imgVwProfile?.frame.size.height ?? 2)/2.0
        self.imgVwProfile?.clipsToBounds = true
        
        self.imgVwFrame?.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        self.imgVwProfile?.isUserInteractionEnabled = true
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleProfilePicTap(_:)))
//        self.imgVwProfile.addGestureRecognizer(tap)

        self.addSubview(self.imgVwProfile!)
        self.addSubview(self.imgVwFrame!)
    }

    func updateFrame(changeValue:Int=2){
        self.imgVwProfile?.frame = CGRectMake(CGFloat(changeValue), CGFloat(changeValue), self.frame.size.width - CGFloat((changeValue*2)), self.frame.size.height - CGFloat(changeValue*2))
       // print("self.imgVwProfile?.frame ",self.imgVwProfile?.frame)
        self.imgVwProfile?.layer.cornerRadius = (self.imgVwProfile?.frame.size.height ?? 2)/2.0
        self.imgVwProfile?.clipsToBounds = true
        
        self.imgVwFrame?.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
    }
    
    
    @objc func setImgView(profilePic:String,frameImg:String,changeValue:Int = 8){
        
        self.imgVwProfile?.kf.setImage(with: URL(string: profilePic), placeholder: PZImages.avatar , options: nil, progressBlock: nil, completionHandler: { response in        })
        
        if frameImg.length > 0{
            self.imgVwFrame?.kf.setImage(with: URL(string: frameImg), options: nil, progressBlock: nil, completionHandler: { response in  })
            self.updateFrame(changeValue: changeValue)
        }else{
            self.imgVwFrame?.image = nil
            if changeValue == 8{
                self.updateFrame()
            }else{
                self.updateFrame(changeValue: changeValue)
            }

        }
    }
    
}

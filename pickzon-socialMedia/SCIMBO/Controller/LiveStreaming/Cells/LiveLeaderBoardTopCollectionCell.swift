//
//  LeaderBoardTopCollectionCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 7/4/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class LiveLeaderBoardTopCollectionCell: UICollectionViewCell {

    @IBOutlet weak var bgImgView: UIImageView!
  //  @IBOutlet weak var cnstrntTopCenterImg: NSLayoutConstraint!

    @IBOutlet weak var btnProfileFirstPosition: UIButton!
    @IBOutlet weak var viewProfileFirstPosition: ImageWithSvgaFrame!
    @IBOutlet weak var btnProfileSecondPosition: UIButton!
    @IBOutlet weak var viewProfileSecondPosition: ImageWithSvgaFrame!
    @IBOutlet weak var btnProfileThirdPosition: UIButton!
    @IBOutlet weak var viewProfileThirdPosition: ImageWithSvgaFrame!
    @IBOutlet weak var btnSeeAll: UIButton!

    @IBOutlet weak var lblFirstPerson: UILabel!
    @IBOutlet weak var lblSecondPerson: UILabel!
    @IBOutlet weak var lblThirdPerson: UILabel!
    
    @IBOutlet weak var btnGiftCoinFirst: UIButton!
    @IBOutlet weak var btnGiftCoinSecond: UIButton!
    @IBOutlet weak var btnGiftCoinThird: UIButton!
    
    @IBOutlet weak var lblGiverFirstPerson: UILabel!
    @IBOutlet weak var lblGiverSecondPerson: UILabel!
    @IBOutlet weak var lblGiverThirdPerson: UILabel!

//    @IBOutlet weak var imgVwGiverFirstPerson: UIImageView!
//    @IBOutlet weak var imgVwGiverSecondPerson: UIImageView!
//    @IBOutlet weak var imgVwGiverThirdPerson: UIImageView!
//    
    @IBOutlet weak var imgVwGiverFirstPersonView: ImageWithFrameImgView!
    @IBOutlet weak var imgVwGiverSecondPersonView: ImageWithFrameImgView!
    @IBOutlet weak var imgVwGiverThirdPersonView: ImageWithFrameImgView!
    
    
    @IBOutlet weak var btnGiverFirstPerson: UIButton!
    @IBOutlet weak var btnGiverSecondPerson: UIButton!
    @IBOutlet weak var btnGiverThirdPerson: UIButton!
    
    @IBOutlet weak var btnInfo: UIButton!
  //  @IBOutlet weak var btnTopOuterClick: UIButton!
    
    @IBOutlet weak var bgVwGiverFirstPerson: UIView!
    @IBOutlet weak var bgVwGiverSecondPerson: UIView!
    @IBOutlet weak var bgVwGiverThirdPerson: UIView!
    @IBOutlet weak var cnstrntBottomCenterGifter: NSLayoutConstraint!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnSeeAll.isHidden = true
        viewProfileFirstPosition.initializeView()
        viewProfileSecondPosition.initializeView()
        viewProfileThirdPosition.initializeView()
        
        imgVwGiverFirstPersonView.initializeView()
        imgVwGiverSecondPersonView.initializeView()
        imgVwGiverThirdPersonView.initializeView()
        
        bgImgView.addShadowToView(corner: 10.0, shadowColor: .lightGray, shadowRadius: 1, shadowOpacity: 0.5)
       
       /* imgVwGiverFirstPerson.layer.cornerRadius = imgVwGiverFirstPerson.frame.size.height/2.0
        imgVwGiverFirstPerson.clipsToBounds = true
        
        imgVwGiverSecondPerson.layer.cornerRadius = imgVwGiverSecondPerson.frame.size.height/2.0
        imgVwGiverSecondPerson.clipsToBounds = true
        
        imgVwGiverThirdPerson.layer.cornerRadius = imgVwGiverThirdPerson.frame.size.height/2.0
        imgVwGiverThirdPerson.clipsToBounds = true
        */
        
        /*
         first (FDD45C to 6B2C00)
         second (E3E3E3 to 676767)
         third (B08D57 to 800000)
         */
        
       /* self.btnProfileFirstPosition.addGradientBorderColor(firstColor: Themes.sharedInstance.colorWithHexString(hex: "FDD45C"), secondColor: Themes.sharedInstance.colorWithHexString(hex: "6B2C00"),borderWidth:7.0)
        self.btnProfileSecondPosition.addGradientBorderColor(firstColor: Themes.sharedInstance.colorWithHexString(hex: "E3E3E3"), secondColor: Themes.sharedInstance.colorWithHexString(hex: "676767"),borderWidth:7.0)
        self.btnProfileThirdPosition.addGradientBorderColor(firstColor: Themes.sharedInstance.colorWithHexString(hex: "B08D57"), secondColor: Themes.sharedInstance.colorWithHexString(hex: "800000"),borderWidth:7.0)
        */
    }

}



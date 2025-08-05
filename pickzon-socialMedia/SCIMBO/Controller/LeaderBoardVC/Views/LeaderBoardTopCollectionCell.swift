//
//  LeaderBoardTopCollectionCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 7/4/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class LeaderBoardTopCollectionCell: UICollectionViewCell {
    
    
    @IBOutlet weak var cnstrntBottomCenterGifter: NSLayoutConstraint!


    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var cnstrntHeightImg: NSLayoutConstraint!

    @IBOutlet weak var btnProfileFirstPosition: UIButton!
    @IBOutlet weak var btnProfileSecondPosition: UIButton!
    @IBOutlet weak var btnProfileThirdPosition: UIButton!
    
    @IBOutlet weak var imgProfileFirstPosition: ImageWithSvgaFrame!
    @IBOutlet weak var imgProfileSecondPosition: ImageWithSvgaFrame!
    @IBOutlet weak var imgProfileThirdPosition: ImageWithSvgaFrame!

    @IBOutlet weak var lblFirstPerson: UILabel!
    @IBOutlet weak var lblSecondPerson: UILabel!
    @IBOutlet weak var lblThirdPerson: UILabel!
    
    @IBOutlet weak var btnGiftCoinFirst: UIButton!
    @IBOutlet weak var btnGiftCoinSecond: UIButton!
    @IBOutlet weak var btnGiftCoinThird: UIButton!
    
    @IBOutlet weak var lblGiverFirstPerson: UILabel!
    @IBOutlet weak var lblGiverSecondPerson: UILabel!
    @IBOutlet weak var lblGiverThirdPerson: UILabel!

    @IBOutlet weak var imgVwGiverFirstPerson: UIImageView!
    @IBOutlet weak var imgVwGiverSecondPerson: UIImageView!
    @IBOutlet weak var imgVwGiverThirdPerson: UIImageView!
    
    @IBOutlet weak var btnGiverFirstPerson: UIButton!
    @IBOutlet weak var btnGiverSecondPerson: UIButton!
    @IBOutlet weak var btnGiverThirdPerson: UIButton!
    
    
    @IBOutlet weak var bgVwGiverFirstPerson: UIView!
    @IBOutlet weak var bgVwGiverSecondPerson: UIView!
    @IBOutlet weak var bgVwGiverThirdPerson: UIView!
    
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var btnTopOuterClick: UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        
        imgProfileFirstPosition.initializeView()
        imgProfileSecondPosition.initializeView()
        imgProfileThirdPosition.initializeView()
        imgVwGiverFirstPerson.layer.cornerRadius = imgVwGiverFirstPerson.frame.size.height/2.0
        imgVwGiverFirstPerson.clipsToBounds = true
        
        imgVwGiverSecondPerson.layer.cornerRadius = imgVwGiverSecondPerson.frame.size.height/2.0
        imgVwGiverSecondPerson.clipsToBounds = true
        
        imgVwGiverThirdPerson.layer.cornerRadius = imgVwGiverThirdPerson.frame.size.height/2.0
        imgVwGiverThirdPerson.clipsToBounds = true
        /*
         first (FDD45C to 6B2C00)
         second (E3E3E3 to 676767)
         third (B08D57 to 800000)
         */
        
        /*self.btnProfileFirstPosition.addGradientBorderColor(firstColor: Themes.sharedInstance.colorWithHexString(hex: "FDD45C"), secondColor: Themes.sharedInstance.colorWithHexString(hex: "6B2C00"),borderWidth:7.0)
        self.btnProfileSecondPosition.addGradientBorderColor(firstColor: Themes.sharedInstance.colorWithHexString(hex: "E3E3E3"), secondColor: Themes.sharedInstance.colorWithHexString(hex: "676767"),borderWidth:7.0)
        self.btnProfileThirdPosition.addGradientBorderColor(firstColor: Themes.sharedInstance.colorWithHexString(hex: "B08D57"), secondColor: Themes.sharedInstance.colorWithHexString(hex: "800000"),borderWidth:7.0)
         */
    }

}


extension UIButton{
    
    func addGradientBorderColor(firstColor:UIColor,secondColor:UIColor,borderWidth:CGFloat){
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
        
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: self.frame.size)
        gradient.colors =  [firstColor.cgColor, secondColor.cgColor]
        
        let shape = CAShapeLayer()
        shape.lineWidth = borderWidth
        shape.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        shape.strokeColor = firstColor.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        self.layer.addSublayer(gradient)
    }
}


extension UIView{
    func dropShadowWithCornerRaduis(cornerRadius:CGFloat) {
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
       
    }
}

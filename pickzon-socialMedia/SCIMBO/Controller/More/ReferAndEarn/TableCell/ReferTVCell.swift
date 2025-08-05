//
//  ReferTVCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 4/11/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit

class ReferTVCell: UITableViewCell {
    @IBOutlet weak var imgBack:UIImageView!
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var btnWallet:UIButton!
    @IBOutlet weak var imgLogo:UIImageView!
    @IBOutlet weak var lblShare_Earn:UILabel!
    //@IBOutlet weak var lblCurrencysymbol:UILabel!
    @IBOutlet weak var lblCurrenyValue:UILabel!
    
    @IBOutlet weak var lblTotalAmtValue:UILabel!
    
    @IBOutlet weak var viewReferalCode:UIView!
    @IBOutlet weak var lblReferalCode:UILabel!
    @IBOutlet weak var btnCopyReferalCode:UIButton!
   
    @IBOutlet weak var btnShare:UIButton!
    @IBOutlet weak var btnShareImage:UIButton!
    
    @IBOutlet weak var btnCoin:UIButton!
    @IBOutlet weak var btnCash:UIButton!
    
    @IBOutlet weak var viewCoinSelection:UIView!
    @IBOutlet weak var viewCashSelection:UIView!
    
    @IBOutlet weak var btnHowToEarn:UIButton!
    
    @IBOutlet weak var lblreferralMessage:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgLogo.setImageColor(color: UIColor.white)
        
        imgBack.layer.cornerRadius = 30
        imgBack.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        imgBack.clipsToBounds = true
        
        
        
        let myMutableString = NSMutableAttributedString(string: "Share and earn with your family & friends")
        myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0,length: 9))
        myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red:245.00/255.0, green:189.0/255.0, blue:0, alpha:1.0), range: NSRange(location: 10,length: 31))
        lblShare_Earn.attributedText = myMutableString
        
/*        lblCurrencysymbol.layer.cornerRadius = lblCurrencysymbol.frame.height / 2.0
        lblCurrencysymbol.layer.borderColor = UIColor.yellow.cgColor
        lblCurrencysymbol.layer.borderWidth = 1.0
        lblCurrencysymbol.clipsToBounds = true
        
        lblCurrencysymbol.textColor = UIColor.yellow
  */
        btnCopyReferalCode.titleLabel?.numberOfLines = 0
        
        viewReferalCode.addDashBorder(color: UIColor.white)
        
        btnShareImage.layer.cornerRadius = btnShareImage.frame.height / 2.0
        btnShareImage.backgroundColor =  UIColor(red:0.0/255.0, green:18.0/255.0, blue:226.0/255.0, alpha:1.0)
        
        let attributedString = NSMutableAttributedString.init(string: "How to earn Money?")

         attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range:
            NSRange.init(location: 0, length: attributedString.length));
        btnHowToEarn.setAttributedTitle(attributedString, for: .normal)
        
        
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func facebookBtnAction(){
        
    }
    
    @IBAction func whatsAppBtnAction(){
        
    }
    
   
}


extension UIView {
    func addDashBorder(color:UIColor) {
       // let color = UIColor.white.cgColor

        let shapeLayer:CAShapeLayer = CAShapeLayer()

        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)

        shapeLayer.bounds = shapeRect
        shapeLayer.name = "DashBorder"
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.lineJoin = .round
        shapeLayer.lineDashPattern = [10,10]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath

        self.layer.masksToBounds = false

        self.layer.addSublayer(shapeLayer)
    }
}

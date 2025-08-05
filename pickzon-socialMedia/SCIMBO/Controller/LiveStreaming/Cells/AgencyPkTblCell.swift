//
//  AgencyPkTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 11/10/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class AgencyPkTblCell: UITableViewCell {
    
    @IBOutlet weak var lblTime:UILabel!
    @IBOutlet weak var bgVwLblTime:UIView!
    @IBOutlet weak var imgbtnProfileLeftView:ImageWithFrameImgView!
    @IBOutlet weak var btnProfileLeft:UIButton!
    @IBOutlet weak var btnNameLeft:UIButton!
    @IBOutlet weak var imgVwCelebrityLeft:UIImageView!
    @IBOutlet weak var lblLeftStatus:UILabel!
    @IBOutlet weak var imgbtnProfileRightView:ImageWithFrameImgView!
    @IBOutlet weak var btnProfileRight:UIButton!
    @IBOutlet weak var btnNameRight:UIButton!
    @IBOutlet weak var imgVwCelebrityRight:UIImageView!
    @IBOutlet weak var lblRightStatus:UILabel!
    @IBOutlet weak var imgVwBG:UIImageView!
    
    @IBOutlet weak var lblCoinLeft:UILabel!
    @IBOutlet weak var lblCoinRight:UILabel!
   
    
    @IBOutlet weak var btnGifter1Right:UIButton!
    @IBOutlet weak var btnGifter2Right:UIButton!
    @IBOutlet weak var btnGifter3Right:UIButton!
    
    @IBOutlet weak var btnGifter1Left:UIButton!
    @IBOutlet weak var btnGifter2Left:UIButton!
    @IBOutlet weak var btnGifter3Left:UIButton!



    
    override func awakeFromNib(){
        super.awakeFromNib()
        // Initialization code
//        btnProfileLeft.layer.cornerRadius = btnProfileLeft.frame.size.height/2.0
//        btnProfileLeft.clipsToBounds = true
//        btnProfileRight.layer.cornerRadius = btnProfileRight.frame.size.height/2.0
//        btnProfileRight.clipsToBounds = true
       
        imgbtnProfileRightView.initializeView()
        imgbtnProfileLeftView.initializeView()
        
        self.cornerRadius(btn: btnGifter1Left)
        self.cornerRadius(btn: btnGifter2Left)
        self.cornerRadius(btn: btnGifter3Left)
        self.cornerRadius(btn: btnGifter1Right)
        self.cornerRadius(btn: btnGifter2Right)
        self.cornerRadius(btn: btnGifter3Right)
    }
    
    
   @objc func cornerRadius(btn:UIButton){
        btn.layer.cornerRadius = btn.frame.size.height/2.0
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = UIColor.white.cgColor
        btn.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool){
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

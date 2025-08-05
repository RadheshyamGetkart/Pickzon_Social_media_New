//
//  TrendingGifterInfoTCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 11/7/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class TrendingGifterInfoTCell: UITableViewCell {
    
    @IBOutlet weak var profileImgView:ImageWithFrameImgView!

    @IBOutlet weak var lblSNo:UILabel!
   // @IBOutlet weak var btnProfile:UIButton!
  //  @IBOutlet weak var btnCrown:UIButton!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var imgCelebrity:UIImageView!
    //@IBOutlet weak var imgVwCrown:IgnoreTouchImageView!
    //@IBOutlet weak var imgVw1stCrown:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       // btnProfile.layer.cornerRadius = btnProfile.frame.height / 2.0
       // btnProfile.clipsToBounds = true
        
        //btnCrown.layer.cornerRadius = btnCrown.frame.height / 2.0
        //        btnCrown.clipsToBounds = true
        profileImgView.initializeView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

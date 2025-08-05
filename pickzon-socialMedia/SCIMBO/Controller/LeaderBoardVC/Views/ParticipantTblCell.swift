//
//  ParticipantTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 7/4/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class ParticipantTblCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imgVwCoin: UIImageView!
   // @IBOutlet weak var btnProfilePic: UIButton!
    @IBOutlet weak var btnProfilePicView: ImageWithFrameImgView!
    @IBOutlet weak var lblRankNumber: UILabel!
    @IBOutlet weak var lblCoinCount: UILabel!
    @IBOutlet weak var btnPIckzonId: UIButton!
    @IBOutlet weak var imgVwCelebrity: UIImageView!
    @IBOutlet weak var imgVwGoldBg: UIImageView!
  //  @IBOutlet weak var imgVwProfileBorder: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        btnProfilePicView.initializeView()
        imgVwGoldBg.isHidden = true
        bgView.layer.cornerRadius = 5.0
        bgView.layer.borderWidth = 1.0
        bgView.layer.borderColor = CustomColor.sharedInstance.newThemeColor.cgColor
        bgView.clipsToBounds = true
        bgView.dropShadowWithCornerRaduis(cornerRadius:5.0)
        // Initialization code
        btnPIckzonId.titleLabel?.numberOfLines = 1
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  JoinedUserTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 9/4/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class JoinedUserTblCell: UITableViewCell {

    @IBOutlet weak var profileImgView:ImageWithFrameImgView!

    @IBOutlet weak var lblName:UILabel!
  //  @IBOutlet weak var imgVwProfile:UIImageView!
    @IBOutlet weak var btnTotalCoin:UIButton!
    @IBOutlet weak var imgVwCelebrity:UIImageView!
    @IBOutlet weak var vwSeperator:UIView!
    @IBOutlet weak var cnstrntWidthImgVw:NSLayoutConstraint!
    @IBOutlet weak var cnstrntHeightImgVw:NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        imgVwProfile.layer.cornerRadius = imgVwProfile.frame.size.height/2.0
//        imgVwProfile.clipsToBounds = true
        profileImgView.initializeView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

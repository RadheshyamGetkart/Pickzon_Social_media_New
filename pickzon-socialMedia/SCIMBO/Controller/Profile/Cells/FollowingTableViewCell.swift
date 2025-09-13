//
//  FollowingTableViewCell.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 5/24/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit

class FollowingTableViewCell: UITableViewCell {
    
  //  @IBOutlet weak var imgUser:UIImageView!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var lblPhone:UILabel!
    @IBOutlet weak var btnUnfollow:UIButton!
    //@IBOutlet weak var btnBgView:UIView!
  //  @IBOutlet weak var btnProfile:UIButton!
    @IBOutlet weak var imgVwCelebrity:UIImageView!
    @IBOutlet weak var profilePicView:ImageWithFrameImgView!

    @IBOutlet weak var btnfollowMid:UIButton!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       // imgUser.layer.cornerRadius = imgUser.frame.height / 2.0
        btnUnfollow.layer.cornerRadius = btnUnfollow.frame.height / 2.0
        btnUnfollow.clipsToBounds = true
        btnUnfollow.backgroundColor = CustomColor.sharedInstance.newThemeColor
        profilePicView.initializeView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

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


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       // imgUser.layer.cornerRadius = imgUser.frame.height / 2.0
        //btnProfile.layer.cornerRadius = btnProfile.frame.height / 2.0
        profilePicView.initializeView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

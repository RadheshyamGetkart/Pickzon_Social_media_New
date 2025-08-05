//
//  PeopleTableViewCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 12/9/22.
//  Copyright © 2022 Pickzon Inc. All rights reserved.
//

import UIKit

class PeopleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicView:ImageWithFrameImgView!
   // @IBOutlet weak var btnUSerImage:UIButton!
    @IBOutlet weak var btnName:UIButton!
    @IBOutlet weak var lblDesig:UILabel!
    @IBOutlet weak var lblLocation:UILabel!
    @IBOutlet weak var btnFollow:UIButton!
    @IBOutlet weak var imgCelebrity:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profilePicView.initializeView()
        btnFollow.layer.cornerRadius = 5.0 // btnFollow.frame.height / 2.0
        btnFollow.clipsToBounds = true
        //        btnUSerImage.layer.cornerRadius = btnUSerImage.frame.height / 2.0
        //
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

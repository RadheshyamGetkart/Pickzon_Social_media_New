//
//  TagPeopleTableViewCell.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 7/2/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit

class TagPeopleTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicView:ImageWithFrameImgView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgCelebrity:UIImageView!
    @IBOutlet weak var btnSelectUser:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profilePicView.initializeView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

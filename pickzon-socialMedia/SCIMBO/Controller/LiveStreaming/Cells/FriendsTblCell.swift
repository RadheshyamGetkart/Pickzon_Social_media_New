//
//  FriendsTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 8/25/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class FriendsTblCell: UITableViewCell {

    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var imgVwProfilePic:UIImageView!
    @IBOutlet weak var imgVwCelebrity:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgVwProfilePic.layer.cornerRadius = imgVwProfilePic.frame.size.height/2.0
        imgVwProfilePic.layer.borderColor =  UIColor.white.cgColor
        imgVwProfilePic.layer.borderWidth = 1.0
        imgVwProfilePic.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

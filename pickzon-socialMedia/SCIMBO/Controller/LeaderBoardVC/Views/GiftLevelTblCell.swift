//
//  GiftLevelTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 2/2/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class GiftLevelTblCell: UITableViewCell {

    @IBOutlet weak var bgView:UIViewX!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var imgVwGift:UIImageView!
    @IBOutlet weak var lblCounter:UILabel!
    @IBOutlet weak var lblGiftCount:UILabel!
    @IBOutlet weak var imgVwCelebrity:UIImageView!
    @IBOutlet weak var imgVwProfile:ImageWithFrameImgView!
    @IBOutlet weak var imgVwRow:UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgVwProfile.initializeView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

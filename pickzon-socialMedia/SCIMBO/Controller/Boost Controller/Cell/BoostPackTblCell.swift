//
//  BoostPackTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/3/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class BoostPackTblCell: UITableViewCell {
    @IBOutlet weak var lblVIewCount: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var cnstrntLeadingClipImg: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgVwClipIcon: UIImageView!
    @IBOutlet weak var lblCoin: UILabel!
    @IBOutlet weak var lblRecommended: UILabel!
    @IBOutlet weak var rightImgVwIcon: UIImageView!

    @IBOutlet weak var cnstrntHeightClipImg: NSLayoutConstraint!
    @IBOutlet weak var cnstrntWidthClipImg: NSLayoutConstraint!

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblRecommended.layer.cornerRadius = 3
        lblRecommended.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

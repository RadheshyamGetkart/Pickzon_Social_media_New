//
//  SettingTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 3/20/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class SettingTblCell: UITableViewCell {
    
    @IBOutlet weak  var imgViewIcon: UIImageView!
    @IBOutlet weak  var btnSwitch: UISwitch!
    @IBOutlet weak  var btnBAck: UIButton!
    @IBOutlet weak  var lblTitle: UILabel!
    @IBOutlet weak  var cnstrntWidthImgVwIcon: NSLayoutConstraint!
    @IBOutlet weak  var lblNotificationCount: UILabel!
    @IBOutlet weak  var lblNew: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnSwitch.isHidden = true
        lblNotificationCount.isHidden = true
        lblNew.isHidden = true
        lblNew.layer.cornerRadius = 2.0
        lblNew.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  SellerTblCell.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 5/19/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit

class SellerTblCell: UITableViewCell {

    @IBOutlet weak var txtFdName: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var btnSwitch: UISwitch!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

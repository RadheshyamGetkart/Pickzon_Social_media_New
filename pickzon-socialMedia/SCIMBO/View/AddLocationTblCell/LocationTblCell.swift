//
//  LocationTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 1/4/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class LocationTblCell: UITableViewCell {

    @IBOutlet weak var txtFdName:SkyFloatingLabelTextFieldWithIcon!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

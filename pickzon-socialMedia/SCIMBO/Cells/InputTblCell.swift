//
//  InputTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 3/26/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class InputTblCell: UITableViewCell {

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

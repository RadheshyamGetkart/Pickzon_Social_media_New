//
//  EmailCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 9/13/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class EmailCell: UITableViewCell {
    @IBOutlet weak var txtfield:SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var bgView:UIView!
    @IBOutlet weak var btnVerify:UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

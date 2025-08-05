//
//  CreateBusinessTblCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 3/3/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class CreateBusinessTblCell: UITableViewCell {

    @IBOutlet weak var ddImgVw: UIImageView!
    @IBOutlet weak var txtFd: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var bgView: UIViewX!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


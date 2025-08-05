//
//  DescriptionTblCell.swift
//  SCIMBO
//
//  Created by Naresh Kumar on 3/29/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit
import GrowingTextView

class DescriptionTblCell: UITableViewCell {
    @IBOutlet weak var seperatorVw: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var txtVwDesc: GrowingTextView!
    @IBOutlet weak var iconImgVw: UIImageView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  EventTypeTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 2/5/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class EventTypeTblCell: UITableViewCell {

    
    @IBOutlet  weak var lblTitle:UILabel!
    @IBOutlet  weak var btnCheckBox:UIButton!
    @IBOutlet  weak var bgVw:UIViewX!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

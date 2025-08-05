//
//  NotificationCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 4/4/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblSubTitle:UILabel!
    @IBOutlet weak var optionSwitch:UISwitch!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

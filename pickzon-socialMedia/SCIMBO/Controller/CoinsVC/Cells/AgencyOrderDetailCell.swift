//
//  AgencyOrderDetailCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 8/25/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class AgencyOrderDetailCell: UITableViewCell {
    @IBOutlet weak var lblPickZonId:UILabel!
    @IBOutlet weak var lblCoinCount:UILabel!
    @IBOutlet weak var lblCoinAmount:UILabel!
    @IBOutlet weak var lblname:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

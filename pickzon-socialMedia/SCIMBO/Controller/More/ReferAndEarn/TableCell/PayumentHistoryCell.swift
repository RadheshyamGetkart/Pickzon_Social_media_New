//
//  PayumentHistoryCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 4/11/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit

class PayumentHistoryCell: UITableViewCell {
    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var lblAmt:UILabel!
    @IBOutlet weak var lblMessage:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

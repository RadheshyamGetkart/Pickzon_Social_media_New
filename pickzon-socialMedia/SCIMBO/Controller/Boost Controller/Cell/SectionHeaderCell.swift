//
//  SectionHeaderCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/4/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class SectionHeaderCell: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblCount:UILabel!
    @IBOutlet weak var seperatorVw:UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

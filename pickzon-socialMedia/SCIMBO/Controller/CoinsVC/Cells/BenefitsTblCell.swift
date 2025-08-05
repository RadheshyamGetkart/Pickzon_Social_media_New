//
//  BenefitsTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/16/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class BenefitsTblCell: UITableViewCell {
    
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lblTitle: UILabel!

    @IBOutlet weak var cnstrntStackVwTop: NSLayoutConstraint!
    @IBOutlet weak var cnstrntStackVwBottom: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

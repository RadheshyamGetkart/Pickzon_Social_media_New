//
//  GenderCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 3/4/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class GenderCell: UITableViewCell {
    @IBOutlet weak var btnMale:UIButton!
    @IBOutlet weak var btnFeMale:UIButton!
    @IBOutlet weak var btnBoth:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

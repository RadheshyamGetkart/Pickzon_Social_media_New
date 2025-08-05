//
//  PremiumPlanCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 6/17/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class PremiumPlanCell: UITableViewCell {
    @IBOutlet weak var viewBack:UIView!
    @IBOutlet weak var lblTimeDuration:UILabel!
    @IBOutlet weak var lblTotal:UILabel!
    @IBOutlet weak var lblPerMonth:UILabel!
    @IBOutlet weak var btnSelect:UIButton!
    var isPlanSelected = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewBack.layer.cornerRadius = 5.0
        viewBack.layer.borderColor = UIColor.black.cgColor
        viewBack.layer.borderWidth = 1.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

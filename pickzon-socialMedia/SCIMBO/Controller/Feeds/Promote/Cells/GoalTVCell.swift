//
//  GoalTVCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 5/18/22.
//  Copyright © 2022 Radheshyam Yadav. All rights reserved.
//

import UIKit

class GoalTVCell: UITableViewCell {

    @IBOutlet weak var imgSymbol:UIImageView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblSubtitle:UILabel!
    @IBOutlet weak var viewBack:UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewBack.layer.cornerRadius = 10.0
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

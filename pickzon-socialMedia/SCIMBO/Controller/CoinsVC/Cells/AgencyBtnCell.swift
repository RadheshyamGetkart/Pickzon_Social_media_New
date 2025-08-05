//
//  AgencyBtnCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 8/23/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class AgencyBtnCell: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var cnstrnt_topView:NSLayoutConstraint!
    @IBOutlet weak var viewBack:UIViewX!
    @IBOutlet weak var btnInfo:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

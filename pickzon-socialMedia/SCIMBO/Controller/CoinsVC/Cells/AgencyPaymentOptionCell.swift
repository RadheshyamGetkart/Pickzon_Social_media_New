//
//  AgencyPaymentOptionCell.swift
//  SCIMBO
//
//  Created by gurmukh singh on 8/25/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class AgencyPaymentOptionCell: UITableViewCell {
    @IBOutlet weak var lblMethod:UILabel!
    @IBOutlet weak var lblReferenceID:UILabel!
    @IBOutlet weak var imgLogo:UIImageView!
    @IBOutlet weak var bgVw:UIViewX!
    @IBOutlet weak var imgVwCheck:UIImageView!
    @IBOutlet weak var btnCopy:UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgVwCheck.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

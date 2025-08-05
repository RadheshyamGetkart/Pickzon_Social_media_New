//
//  TitleDetailTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 8/28/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class TitleDetailTblCell: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblDetail:UILabel!
    @IBOutlet weak var imgVWCoin:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

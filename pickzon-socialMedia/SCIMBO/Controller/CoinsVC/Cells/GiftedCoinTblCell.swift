//
//  GiftedCoinTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 5/23/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

import UIKit

class GiftedCoinTblCell: UITableViewCell {

    @IBOutlet weak var lblCoinAndValue:UILabel!
    @IBOutlet weak var btnHistory:UIButton!
    @IBOutlet weak var btnWithdraw:UIButton!
    @IBOutlet weak var btnExchangeForCheerCoin:UIButton!
    @IBOutlet weak var imgVwArrow:UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgVwArrow.setImageColor(color: .black)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  PurchaseHistTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/22/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class PurchaseHistTblCell: UITableViewCell {
  
    @IBOutlet weak var lblCoinValue: UILabel!
    @IBOutlet weak var lblTransactionDate: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblTransactionId: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var imgVwCoin: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

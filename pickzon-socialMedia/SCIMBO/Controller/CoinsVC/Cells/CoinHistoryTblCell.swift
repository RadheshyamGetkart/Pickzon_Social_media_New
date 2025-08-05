//
//  CoinHistoryTblCell.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 6/16/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit

class CoinHistoryTblCell: UITableViewCell {

    @IBOutlet weak var imgVwGiftCoin: UIImageView!
    @IBOutlet weak var lblGiftCoinValue: UILabel!
    @IBOutlet weak var imgVwCoin: UIImageView!
    @IBOutlet weak var lblCoinValue: UILabel!
    @IBOutlet weak var lblTransactionDate: UILabel!
    @IBOutlet weak var lblTransactionType: ExpandableLabel!
    @IBOutlet weak var imgVwType: UIImageViewX!
    @IBOutlet weak var lblReferenceNo: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblTransactionType.numberOfLines = 4
        lblTransactionType.collapsed = true
        lblTransactionType.collapsedAttributedLink = NSAttributedString(string: " Read more" ,attributes:  [.foregroundColor:UIColor.systemBlue])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
